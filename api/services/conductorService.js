const conductorDao = require('../dao/conductorDao');

async function list() {
  return conductorDao.listActive();
}

async function create(payload) {
  return conductorDao.callInsert(payload);
}

async function update(payload) {
  return conductorDao.callUpdate(payload);
}

async function softDelete(payload) {
  return conductorDao.callSoftDelete(payload);
}

module.exports = { list, create, update, softDelete };
