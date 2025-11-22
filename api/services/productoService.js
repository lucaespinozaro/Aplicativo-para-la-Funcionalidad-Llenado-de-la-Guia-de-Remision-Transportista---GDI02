const productoDao = require('../dao/productoDao');

async function list({ q } = {}) {
  if (!q) return productoDao.listActive();
  return productoDao.search(q);
}

async function create(payload) {
  return productoDao.callInsert(payload);
}

async function update(payload) {
  return productoDao.callUpdate(payload);
}

async function softDelete(payload) {
  return productoDao.callSoftDelete(payload);
}

module.exports = { list, create, update, softDelete };
