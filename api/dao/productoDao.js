const pool = require('../db');

async function listActive() {
  const [rows] = await pool.query('SELECT codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, activo FROM producto WHERE activo = 1');
  return rows;
}

async function search(q) {
  // buscar por código exacto o por descripcion (FULLTEXT o LIKE)
  const [rowsByCode] = await pool.query('SELECT codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto FROM producto WHERE codigo_producto = ? AND activo = 1', [q]);
  if (rowsByCode.length) return rowsByCode;

  // usar LIKE como fallback
  const like = `%${q}%`;
  const [rows] = await pool.query('SELECT codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto FROM producto WHERE (descripcion LIKE ? OR material LIKE ?) AND activo = 1', [like, like]);
  return rows;
}

async function callInsert({ codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_producto_insert(?,?,?,?,?,?)', [codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, usuario].slice(0,7));
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callUpdate({ codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_producto_update(?,?,?,?,?,?,?)', [codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

async function callSoftDelete({ codigo_producto, usuario }) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query('CALL sp_producto_soft_delete(?,?)', [codigo_producto, usuario]);
    conn.release();
    return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
  } catch (err) {
    conn.release();
    throw err;
  }
}

module.exports = { listActive, search, callInsert, callUpdate, callSoftDelete };
