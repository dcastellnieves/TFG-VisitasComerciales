// server.js
const express = require('express');
const cors = require('cors');
const pool = require('./db');

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();

app.use(cors());
app.use(express.json());

// CLAVE JWT
const SECRET = "mi_clave_super_secreta";

/* ==========================
  AUTH MIDDLEWARE
========================== */
function auth(req, res, next) {
  const header = req.headers['authorization'];

  if (!header) {
    req.user = null;
    return next();
  }

  const token = header.replace("Bearer ", "");

  try {
    const decoded = jwt.verify(token, SECRET);
    req.user = decoded;
  } catch (err) {
    console.log("Token inválido");
    req.user = null;
  }

  next();
}

/* ==========================
   ADMIN MIDDLEWARE
========================== */
function esAdmin(req, res, next) {
  if (!req.user || req.user.rol !== "admin") {
    return res.status(403).json({ error: "Acceso solo admin" });
  }
  next();
}

/* ==========================
  LOGIN
========================== */
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM usuarios WHERE email=$1',
      [email]
    );

    if (result.rows.length === 0)
      return res.status(400).json({ error: 'Usuario no encontrado' });

    const user = result.rows[0];

    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword)
      return res.status(400).json({ error: 'Contraseña incorrecta' });

    const token = jwt.sign(
      { id: user.id, rol: user.rol },
      SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      id: user.id,
      nombre: user.nombre_completo,
      email: user.email,
      telefono: user.telefono,
      rol: user.rol,
      activo: user.activo
    });

  } catch (err) {
    res.status(500).json({ error: "Error en login" });
  }
});

/* ==========================
  CLIENTES
========================== */
app.get('/clientes', auth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, nombre, direccion, telefono, email, latitud, longitud FROM clientes'
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: "Error obteniendo clientes" });
  }
});

app.get('/clientes/:userId', auth, async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT c.id, c.nombre, c.direccion, c.telefono, c.email, c.latitud, c.longitud
      FROM asignaciones a
      JOIN clientes c ON a.cliente_id = c.id
      WHERE a.usuario_id = $1
    `, [userId]);

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({ error: "Error obteniendo clientes" });
  }
});

/* ==========================
  USUARIO PERFIL
========================== */
app.get('/usuario/:id', auth, async (req, res) => {

  if (req.user.id != req.params.id) {
    return res.status(403).json({ error: "No autorizado" });
  }

  try {
    const result = await pool.query(
      `SELECT id, nombre_completo, email, telefono, rol, activo
       FROM usuarios WHERE id=$1`,
      [req.params.id]
    );

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({ error: "Error obteniendo usuario" });
  }
});

/* ==========================
   UPDATE USUARIO 
========================== */
app.put('/usuario/:id', auth, async (req, res) => {

  if (req.user.id != req.params.id) {
    return res.status(403).json({ error: "No autorizado" });
  }

  const { telefono, password_actual, password_nueva } = req.body;

  try {
    const user = await pool.query("SELECT * FROM usuarios WHERE id=$1", [req.params.id]);

    if (user.rows.length === 0)
      return res.status(400).json({ error: "Usuario no encontrado" });

    const u = user.rows[0];

    await pool.query(
      `UPDATE usuarios SET telefono=$1 WHERE id=$2`,
      [telefono, req.params.id]
    );

    if (password_actual && password_nueva) {

      const valid = await bcrypt.compare(password_actual, u.password);

      if (!valid)
        return res.status(400).json({ error: "Contraseña actual incorrecta" });

      const hashed = await bcrypt.hash(password_nueva, 10);

      await pool.query(
        `UPDATE usuarios SET password=$1 WHERE id=$2`,
        [hashed, req.params.id]
      );
    }

    res.json({ ok: true });

  } catch (err) {
    res.status(500).json({ error: "Error actualizando usuario" });
  }
});

/* ==========================
   VISITAS 
========================== */
app.get('/visitas/:usuarioId', auth, async (req, res) => {

  if (req.user.id != req.params.usuarioId) {
    return res.status(403).json({ error: "No autorizado" });
  }

  try {
    const result = await pool.query(`
      SELECT v.id, v.cliente_id, u.nombre_completo AS usuario, c.nombre AS cliente,
             v.fecha, v.estado, v.duracion_minutos, v.hora_inicio,
             v.lat_inicio, v.lon_inicio, v.lat_fin, v.lon_fin, v.notas
      FROM visitas v
      JOIN usuarios u ON v.usuario_id = u.id
      JOIN clientes c ON v.cliente_id = c.id
      WHERE v.usuario_id = $1
      ORDER BY v.hora_inicio DESC
    `, [req.params.usuarioId]);

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({ error: 'Error consultando visitas' });
  }
});

app.get('/visitas/hoy/:usuarioId', auth, async (req, res) => {

  if (req.user.rol !== "admin" && req.user.id != req.params.usuarioId) {
    return res.status(403).json({ error: "No autorizado" });
  }

  try {
    const result = await pool.query(`
      SELECT cliente_id, estado
      FROM visitas
      WHERE usuario_id = $1
      AND DATE(fecha) = CURRENT_DATE
    `, [req.params.usuarioId]);

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({ error: 'Error visitas hoy' });
  }
});

/* ==========================
   INICIAR VISITA
========================== */
app.post('/visitas/iniciar', auth, async (req, res) => {

  const { usuario_id, cliente_id, lat, lon } = req.body;

  if (req.user.id != usuario_id) {
    return res.status(403).json({ error: "No autorizado" });
  }

  try {
    const visitaActiva = await pool.query(
      "SELECT * FROM visitas WHERE usuario_id=$1 AND estado!='finalizada'",
      [usuario_id]
    );

    if (visitaActiva.rows.length > 0)
      return res.status(400).json({ error: "Ya hay una visita en curso" });

    const result = await pool.query(`
      INSERT INTO visitas
      (usuario_id, cliente_id, fecha, hora_inicio, lat_inicio, lon_inicio, estado)
      VALUES ($1,$2,CURRENT_DATE,CURRENT_TIMESTAMP,$3,$4,'en_curso')
      RETURNING *
    `, [usuario_id, cliente_id, lat, lon]);

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({ error: 'Error iniciando visita' });
  }
});

/* ==========================
   FINALIZAR VISITA
========================== */
app.put('/visitas/finalizar', auth, async (req, res) => {

  const { usuario_id, cliente_id, lat, lon, notas } = req.body;

  if (req.user.id != usuario_id) {
    return res.status(403).json({ error: "No autorizado" });
  }

  try {
    const result = await pool.query(`
      UPDATE visitas
      SET hora_fin = CURRENT_TIMESTAMP,
          lat_fin = $1,
          lon_fin = $2,
          notas = $3,
          estado = 'finalizada',
          duracion_minutos = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - hora_inicio))/60
      WHERE usuario_id=$4 AND estado='en_curso'
      RETURNING *
    `, [lat, lon, notas, usuario_id]);

    if (result.rows.length === 0)
      return res.status(400).json({ error: "No hay visitas activas" });

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({ error: "Error finalizando visita" });
  }
});

/* ==========================
   NOTAS
========================== */
app.put('/visitas/notas', auth, async (req, res) => {

  const { visita_id, notas } = req.body;

  try {
    await pool.query(
      "UPDATE visitas SET notas=$1 WHERE id=$2",
      [notas, visita_id]
    );

    res.json({ success: true });

  } catch (err) {
    res.status(500).json({ error: "Error actualizando notas" });
  }
});

/* ==========================
  ASIGNACIONES
========================== */
app.get('/asignaciones/hoy/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT c.id as id, 
      c.nombre, 
      c.direccion, 
      c.telefono, 
      a.visitado 
      FROM asignaciones a JOIN clientes c ON a.cliente_id = c.id 
      WHERE a.usuario_id = $1 AND a.fecha = CURRENT_DATE` 
      , [userId]);

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error asignaciones hoy" });
  }
});

/* ==========================
   ADMIN 
========================== */
app.post('/admin/empleados', auth, esAdmin, async (req, res) => {

  const { nombre, email, telefono, password, rol } = req.body;

  try {
    const hash = await bcrypt.hash(password, 10);

    const result = await pool.query(`
      INSERT INTO usuarios(nombre_completo, email, telefono, password, rol, activo)
      VALUES ($1,$2,$3,$4,$5,true)
      RETURNING id, nombre_completo, email, telefono, rol
    `, [nombre, email, telefono, hash, rol || 'comercial']);

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({ error: "Error creando usuario" });
  }
});

app.get('/admin/listaEmpleados', auth, esAdmin, async (req, res) => {

  const result = await pool.query(
    `SELECT id, nombre_completo, email, telefono, rol, activo FROM usuarios`
  );

  res.json(result.rows);
});

app.get('/admin/visitas-filtrado', auth, esAdmin, async (req, res) => {
  const { usuario_id, cliente_id, fecha } = req.query;

  try {
    let query = `
      SELECT v.*, u.nombre_completo AS usuario, c.nombre AS cliente
      FROM visitas v
      JOIN usuarios u ON v.usuario_id = u.id
      JOIN clientes c ON v.cliente_id = c.id
      WHERE 1=1
    `;

    const params = [];
    let i = 1;

    if (usuario_id) {
      query += ` AND v.usuario_id = $${i++}`;
      params.push(usuario_id);
    }

    if (cliente_id) {
      query += ` AND v.cliente_id = $${i++}`;
      params.push(cliente_id);
    }

    if (fecha) {
      query += ` AND v.fecha = $${i++}`;
      params.push(fecha);
    }

    query += ` ORDER BY v.hora_inicio DESC`;

    const result = await pool.query(query, params);

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error filtrando visitas" });
  }
});

app.delete('/admin/visitas/:id', auth, esAdmin, async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query(
      'DELETE FROM visitas WHERE id = $1',
      [id]
    );

    res.json({ ok: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error eliminando visita" });
  }
});

app.put('/admin/empleados/:id', auth, esAdmin, async (req, res) => {

  const { id } = req.params;
  const { nombre_completo, email, telefono, rol, activo } = req.body;

  const result = await pool.query(`
    UPDATE usuarios
    SET nombre_completo=$1,email=$2,telefono=$3,rol=$4,activo=$5
    WHERE id=$6
    RETURNING *
  `, [nombre_completo, email, telefono, rol, activo, id]);

  res.json(result.rows[0]);
});


app.post('/admin/asignaciones', auth, esAdmin, async (req, res) => {
  const { usuario_id, clientes } = req.body;

  if (!usuario_id || !Array.isArray(clientes)) {
    return res.status(400).json({ error: "Datos inválidos" });
  }

  try {

    for (const cliente_id of clientes) {
      await pool.query(`
        INSERT INTO asignaciones (usuario_id, cliente_id)
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING
      `, [usuario_id, cliente_id]);
    }

    res.json({ ok: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error creando asignaciones" });
  }
});


app.delete('/admin/asignaciones', auth, esAdmin, async (req, res) => {
 const { usuario_id, cliente_id } = req.body;

  try {
    await pool.query(`
      DELETE FROM asignaciones
      WHERE usuario_id = $1 AND cliente_id = $2
    `, [usuario_id, cliente_id]);

    res.json({ ok: true });

  } catch (err) {
    res.status(500).json({ error: "Error eliminando asignación" });
  }
});

app.get('/admin/estadisticas', auth, esAdmin, async (req, res) => {
  try {

    const hoy = await pool.query(`
      SELECT COUNT(*) FROM visitas
      WHERE DATE(fecha) = CURRENT_DATE
    `);

    const semana = await pool.query(`
      SELECT COUNT(*) FROM visitas
      WHERE fecha >= CURRENT_DATE - INTERVAL '7 days'
    `);

    const empleados = await pool.query(`
      SELECT COUNT(*) FROM usuarios WHERE rol = 'comercial'
    `);

    const clientes = await pool.query(`
      SELECT COUNT(*) FROM clientes
    `);

    const ranking = await pool.query(`
      SELECT u.nombre_completo as nombre, COUNT(v.id) as total
      FROM usuarios u
      LEFT JOIN visitas v ON v.usuario_id = u.id
      WHERE u.rol = 'comercial'
      GROUP BY u.id
      ORDER BY total DESC
      LIMIT 5
    `);

    const visitas7dias = await pool.query(`
      SELECT 
        TO_CHAR(fecha, 'DD') as dia,
        COUNT(*) as total
      FROM visitas
      WHERE fecha >= CURRENT_DATE - INTERVAL '7 days'
      GROUP BY dia
      ORDER BY dia
    `);

    res.json({
      visitas_hoy: parseInt(hoy.rows[0].count),
      visitas_semana: parseInt(semana.rows[0].count),
      empleados_activos: parseInt(empleados.rows[0].count),
      clientes_total: parseInt(clientes.rows[0].count),
      ranking: ranking.rows,
      visitas_7_dias: visitas7dias.rows
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error estadísticas" });
  }
});

app.put('/admin/clientes/:id', auth, esAdmin, async (req, res) => {
  const { id } = req.params;
  const { nombre, email, direccion, telefono, latitud, longitud } = req.body;

  try {
    const result = await pool.query(
      `
      UPDATE clientes
      SET nombre=$1,
          email=$2,
          direccion=$3,
          telefono=$4,
          latitud=$5,
          longitud=$6
      WHERE id=$7
      RETURNING *
      `,
      [nombre, email, direccion, telefono, latitud, longitud, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Cliente no encontrado" });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error actualizando cliente" });
  }
});

app.post('/admin/clientes/importar', auth, esAdmin, async (req, res) => {
  const { clientes } = req.body;

  if (!Array.isArray(clientes)) {
    return res.status(400).json({ error: "Formato inválido" });
  }

  try {
    let insertados = 0;

    for (const c of clientes) {
      await pool.query(`
        INSERT INTO clientes (nombre, direccion, telefono, email, latitud, longitud)
        VALUES ($1, $2, $3, $4, $5, $6)
      `, [
        c.nombre,
        c.direccion,
        c.telefono,
        c.email,
        c.latitud,
        c.longitud
      ]);

      insertados++;
    }

    res.json({ ok: true, insertados });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error importando clientes" });
  }
});

/* ==========================
   SERVIDOR
========================== */
app.listen(3000, () => {
  console.log("Servidor funcionando en http://localhost:3000");
});