
require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',        
    database: process.env.DB_NAME || 'transportista',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
    multipleStatements: false
});


(async () => {
    try {
        const conn = await pool.getConnection();
        console.log('Conexión a MySQL establecida');
        conn.release();
    } catch (err) {
        console.error('Error conectando a MySQL:', err.message);
    }
})();

module.exports = pool;


