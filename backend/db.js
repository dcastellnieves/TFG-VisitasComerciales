/**
 * db.js
 * Módulo de configuración y exportación del pool de conexiones a PostgreSQL.
 * Centraliza los parámetros de acceso a la base de datos para que el resto
 * del backend pueda reutilizar una única instancia del pool.
 */

const { Pool } = require("pg");

// Parámetros de conexión a la base de datos PostgreSQL local
const pool = new Pool({
 user: "postgres",
 host: "localhost",
 database: "visitas_comerciales",
 password: "12345",
 port: 5432
});

module.exports = pool;

