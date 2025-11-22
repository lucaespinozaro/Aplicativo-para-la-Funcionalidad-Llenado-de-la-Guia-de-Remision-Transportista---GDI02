const pool = require('../db');

async function listActive() {
  const [rows] = await pool.query('SELECT placa_semirremolque, numero_guia_remitente, certificado_inscripcion_semiremolque, activo FROM semirremolque WHERE activo = 1');
  return rows;
}

async function getByPlaca(placa) {
  const [rows] = await pool.query('SELECT placa_semirremolque, numero_guia_remitente, certificado_inscripcion_semiremolque, activo FROM semirremolque WHERE placa_semirremolque = ? LIMIT 1', [placa]);
  return rows[0] || null;
}

async function callInsert({ placa_semirremolque, numero_guia_remitente, certificado_inscripcion_semiremolque, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_semirremolque_insert(?,?,?)', [placa_semirremolque, certificado_inscripcion_semiremolque, usuario]);
    // si quieres relacionarlo con numero_guia_remitente, deberías actualizar después; SP actual insert solo placa y certificado
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callUpdate({ placa_semirremolque, certificado_inscripcion_semiremolque, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_semirremolque_update(?,?,?)', [placa_semirremolque, certificado_inscripcion_semiremolque, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callSoftDelete({ placa_semirremolque, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_semirremolque_soft_delete(?,?)', [placa_semirremolque, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

module.exports = { listActive, getByPlaca, callInsert, callUpdate, callSoftDelete };
