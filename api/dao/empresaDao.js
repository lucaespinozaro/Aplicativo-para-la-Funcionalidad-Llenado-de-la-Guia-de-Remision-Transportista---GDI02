const pool = require('../db');

async function listActive() {
  const [rows] = await pool.query('SELECT ruc, razon_social, provincia, departamento, distrito, domicilio, activo FROM empresa WHERE activo = 1');
  return rows;
}

async function callInsert({ ruc, provincia, departamento, distrito, domicilio, razon_social, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_empresa_insert(?,?,?,?,?,?,?)', [ruc, provincia, departamento, distrito, domicilio, razon_social, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callUpdate({ ruc, provincia, departamento, distrito, domicilio, razon_social, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_empresa_update(?,?,?,?,?,?,?)', [ruc, provincia, departamento, distrito, domicilio, razon_social, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callSoftDelete({ ruc, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_empresa_soft_delete(?,?)', [ruc, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

module.exports = { listActive, callInsert, callUpdate, callSoftDelete };
