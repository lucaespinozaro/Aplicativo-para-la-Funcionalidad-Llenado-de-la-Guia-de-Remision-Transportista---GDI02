const empresaDao = require('../dao/empresaDao');

async function list() {
  // lista empresas activas
  return empresaDao.listActive();
}

async function create(payload) {
  // payload: { ruc, provincia, departamento, distrito, domicilio, razon_social, usuario }
  return empresaDao.callInsert(payload);
}

async function update(payload) {
  // payload: { ruc, provincia, departamento, distrito, domicilio, razon_social, usuario }
  return empresaDao.callUpdate(payload);
}

async function softDelete(payload) {
  // payload: { ruc, usuario }
  return empresaDao.callSoftDelete(payload);
}

module.exports = { list, create, update, softDelete };
