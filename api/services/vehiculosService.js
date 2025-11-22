const tractoDao = require('../dao/tractoDao');
const semirremolqueDao = require('../dao/semirremolqueDao');

async function list({ placa } = {}) {
  // si placa especificada, buscar en tracto y semirremolque
  if (placa) {
    const tracto = await tractoDao.getByPlaca(placa);
    const semirremolque = await semirremolqueDao.getByPlaca(placa);
    return { tracto: tracto || null, semirremolque: semirremolque || null };
  }

  // si no placa, devolver listas combinadas
  const [tractos, semirremolques] = await Promise.all([tractoDao.listActive(), semirremolqueDao.listActive()]);
  return { tractos, semirremolques };
}

async function create(payload) {
  // payload.type = 'tracto' | 'semirremolque'
  if (!payload.type) throw new Error('Debe indicar type: "tracto" or "semirremolque"');
  if (payload.type === 'tracto') return tractoDao.callInsert(payload);
  if (payload.type === 'semirremolque') return semirremolqueDao.callInsert(payload);
  throw new Error('Type inválido');
}

async function update(payload) {
  // if payload.has tracto fields -> update tracto, else semirremolque
  if (payload.type === 'tracto' || payload.marca_unidad || payload.certificado_inscripcion) {
    return tractoDao.callUpdate({ placa_tracto: payload.placa, marca_unidad: payload.marca_unidad, certificado_inscripcion: payload.certificado_inscripcion, usuario: payload.usuario });
  }
  if (payload.type === 'semirremolque' || payload.certificado_inscripcion_semiremolque) {
    return semirremolqueDao.callUpdate({ placa_semirremolque: payload.placa, certificado_inscripcion_semiremolque: payload.certificado_inscripcion_semiremolque, usuario: payload.usuario });
  }
  throw new Error('No se pudo determinar tipo de vehículo para actualizar');
}

module.exports = { list, create, update };
