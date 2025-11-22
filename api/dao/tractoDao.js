const pool = require('../db');

async function listActive() {
  const [rows] = await pool.query('SELECT placa_tracto, marca_unidad, certificado_inscripcion, activo FROM tracto WHERE activo = 1');
  return rows;
}

async function getByPlaca(placa) {
  const [rows] = await pool.query('SELECT placa_tracto, marca_unidad, certificado_inscripcion, activo FROM tracto WHERE placa_tracto = ? LIMIT 1', [placa]);
  return rows[0] || null;
}

async function callInsert({ placa_tracto, marca_unidad, certificado_inscripcion, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_tracto_insert(?,?,?,?)', [placa_tracto, marca_unidad, certificado_inscripcion, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callUpdate({ placa_tracto, marca_unidad, certificado_inscripcion, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_tracto_update(?,?,?,?)', [placa_tracto, marca_unidad, certificado_inscripcion, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callSoftDelete({ placa_tracto, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_tracto_soft_delete(?,?)', [placa_tracto, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

module.exports = { listActive, getByPlaca, callInsert, callUpdate, callSoftDelete };
