const { Pool } = require("pg");

const pool = new Pool({
 user: "postgres",
 host: "localhost",
 database: "visitas_comerciales",
 password: "12345",
 port: 5432
});

module.exports = pool;

