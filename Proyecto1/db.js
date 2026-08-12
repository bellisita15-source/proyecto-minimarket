const mysql = require('mysql2/promise');

// Pool de conexiones hacia MySQL
const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'root',
  database: 'minimarket',
  waitForConnections: true,
  connectionLimit: 10
});

module.exports = db;