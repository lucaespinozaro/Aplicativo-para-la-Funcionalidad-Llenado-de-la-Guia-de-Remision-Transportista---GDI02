const pool = require('../db');

async function listActive() {
    const [rows] = await pool.query('SELECT dni_conductor, nombre_conductor, numero_licencia_conductor, activo FROM conductor WHERE activo = 1');
    return rows;
}

async function callInsert({ dni_conductor, nombre_conductor, numero_licencia_conductor, usuario }) {
    const conn = await pool.getConnection();
    try {
        const [rows] = await conn.query('CALL sp_conductor_insert(?,?,?,?)', [dni_conductor, nombre_conductor, numero_licencia_conductor, usuario]);
        conn.release();
        return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
    } catch (err) {
        conn.release();
        throw err;
    }
}

async function callUpdate({ dni_conductor, nombre_conductor, numero_licencia_conductor, usuario }) {
    const conn = await pool.getConnection();
    try {
        const [rows] = await conn.query('CALL sp_conductor_update(?,?,?,?)', [dni_conductor, nombre_conductor, numero_licencia_conductor, usuario]);
        conn.release();
        return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
    } catch (err) {
        conn.release();
        throw err;
    }
}

async function callSoftDelete({ dni_conductor, usuario }) {
    const conn = await pool.getConnection();
    try {
        const [rows] = await conn.query('CALL sp_conductor_soft_delete(?,?)', [dni_conductor, usuario]);
        conn.release();
        return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
    } catch (err) {
        conn.release();
        throw err;
    }
}

module.exports = { listActive, callInsert, callUpdate, callSoftDelete };
