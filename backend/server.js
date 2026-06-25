/**
 * server.js
 * Punto de entrada principal del backend REST de Visitas Comerciales.
 * Define los middlewares de autenticación JWT, los endpoints de la API
 * y arranca el servidor Express en el puerto 3000.
 *
 * Recursos expuestos:
 *   - POST   /login                          → Autenticación de usuarios
 *   - GET    /clientes                       → Lista todos los clientes (admin)
 *   - GET    /clientes/:userId               → Clientes asignados a un empleado
 *   - GET    /usuario/:id                    → Perfil del usuario autenticado
 *   - PUT    /usuario/:id                    → Actualización de teléfono y/o contraseña
 *   - GET    /visitas/:usuarioId             → Historial de visitas del empleado
 *   - GET    /visitas/hoy/:usuarioId         → Visitas del día para un empleado
 *   - POST   /visitas/iniciar                → Inicia una nueva visita
 *   - PUT    /visitas/finalizar              → Finaliza la visita activa
 *   - PUT    /visitas/notas                  → Actualiza las notas de una visita
 *   - GET    /asignaciones/hoy/:userId       → Asignaciones del día para un empleado
 *   - POST   /admin/empleados                → Crea un nuevo empleado (solo admin)
 *   - GET    /admin/listaEmpleados           → Lista todos los usuarios (solo admin)
 *   - GET    /admin/visitas-filtrado         → Visitas con filtros opcionales (solo admin)
 *   - DELETE /admin/visitas/:id              → Elimina una visita (solo admin)
 *   - PUT    /admin/empleados/:id            → Actualiza datos de un empleado (solo admin)
 *   - POST   /admin/asignaciones             → Crea asignaciones cliente-empleado (solo admin)
 *   - DELETE /admin/asignaciones             → Elimina una asignación (solo admin)
 *   - GET    /admin/estadisticas             → Métricas y KPIs del sistema (solo admin)
 *   - PUT    /admin/clientes/:id             → Actualiza datos de un cliente (solo admin)
 *   - POST   /admin/clientes/importar        → Importación masiva de clientes (solo admin)
 */
// server.js
const express = require('express');
const cors = require('cors');
const pool = require('./db');

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();

app.use(cors());
app.use(express.json());

// Clave secreta para firmar y verificar tokens JWT
const SECRET = "mi_clave_super_secreta";

/* ==========================
  AUTH MIDDLEWARE
  Extrae y verifica el token JWT del header Authorization.
  Si el token es válido, adjunta el payload decodificado a req.user.
  Si no hay token o es inválido, req.user queda como null.
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
   Comprueba que el usuario autenticado tenga rol "admin".
   Devuelve 403 si el usuario no existe o no es administrador.
========================== */
function esAdmin(req, res, next) {
  if (!req.user || req.user.rol !== "admin") {
    return res.status(403).json({ error: "Acceso solo admin" });
  }
  next();
}

/* ==========================
  LOGIN
  Valida credenciales de usuario (email + password bcrypt),
  genera un token JWT con id y rol, y lo devuelve junto al perfil.
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

    // Genera token con expiración de 7 días
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
  Endpoints para consultar clientes.
  - GET /clientes           → devuelve todos los clientes del sistema.
  - GET /clientes/:userId   → devuelve solo los clientes asignados al empleado.
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

// Clientes asignados a un empleado concreto mediante JOIN con tabla asignaciones
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
  Devuelve el perfil del usuario autenticado.
  Solo permite acceder al propio perfil (id del token == id del parámetro).
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
   Permite al usuario actualizar su teléfono y, opcionalmente,
   cambiar la contraseña previa verificación de la contraseña actual.
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

    // Actualiza el teléfono siempre que se envíe
    await pool.query(
      `UPDATE usuarios SET telefono=$1 WHERE id=$2`,
      [telefono, req.params.id]
    );

    // Cambia la contraseña solo si se proporcionan ambas (actual y nueva)
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
   Endpoints para la gestión del historial y estado de visitas.
   - GET /visitas/:usuarioId       → historial completo del empleado (solo propio).
   - GET /visitas/hoy/:usuarioId   → visitas del día (accesible también por admin).
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

// Visitas registradas en el día actual para el empleado indicado
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
   Crea un nuevo registro de visita en estado 'en_curso' con la
   ubicación GPS de inicio. Impide iniciar si ya hay una visita activa.
========================== */
app.post('/visitas/iniciar', auth, async (req, res) => {

  const { usuario_id, cliente_id, lat, lon } = req.body;

  if (req.user.id != usuario_id) {
    return res.status(403).json({ error: "No autorizado" });
  }

  try {
    // Comprueba que no exista ya una visita sin finalizar
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
   Marca como 'finalizada' la visita activa del empleado,
   registrando la ubicación GPS de fin, las notas y la duración calculada.
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
   Actualiza el campo de notas de una visita existente
   identificada por su id.
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
  Devuelve los clientes asignados al empleado para el día actual,
  incluyendo el estado de visita de cada uno.
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
   Endpoints exclusivos para el rol administrador.
   Cubren la gestión de empleados, visitas, asignaciones,
   estadísticas y clientes.
========================== */
// Crea un nuevo empleado con contraseña hasheada y rol comercial por defecto
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

// Devuelve el listado completo de empleados del sistema
app.get('/admin/listaEmpleados', auth, esAdmin, async (req, res) => {

  const result = await pool.query(
    `SELECT id, nombre_completo, email, telefono, rol, activo FROM usuarios`
  );

  res.json(result.rows);
});

// Consulta visitas con filtros opcionales por empleado, cliente y/o fecha
app.get('/admin/visitas-filtrado', auth, esAdmin, async (req, res) => {
  const { usuario_id, cliente_id, fecha } = req.query;

  try {
    // Construcción dinámica de la query según los filtros recibidos
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

// Elimina una visita por su id
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

// Actualiza los datos de un empleado existente
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


// Crea asignaciones cliente-empleado usando INSERT con ON CONFLICT DO NOTHING
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


// Elimina una asignación concreta entre empleado y cliente
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

// Devuelve métricas agregadas: visitas hoy, semana, empleados, clientes, ranking y gráfico 7 días
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

    // Top 5 empleados por número de visitas realizadas
    const ranking = await pool.query(`
      SELECT u.nombre_completo as nombre, COUNT(v.id) as total
      FROM usuarios u
      LEFT JOIN visitas v ON v.usuario_id = u.id
      WHERE u.rol = 'comercial'
      GROUP BY u.id
      ORDER BY total DESC
      LIMIT 5
    `);

    // Visitas agrupadas por día en los últimos 7 días (para el gráfico de barras)
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

// Actualiza los datos de un cliente existente (incluidas coordenadas geográficas)
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

// Importa un array de clientes recibido en el cuerpo de la petición
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
   Arranca el servidor HTTP en el puerto 3000.
========================== */
app.listen(3000, () => {
  console.log("Servidor funcionando en http://localhost:3000");
});