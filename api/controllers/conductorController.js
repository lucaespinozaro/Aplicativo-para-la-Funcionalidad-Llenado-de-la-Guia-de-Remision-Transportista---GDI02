const conductorService = require('../services/conductorService');

async function list(req, res) {
  try {
    const rows = await conductorService.list();
    res.json({ ok: true, data: rows });
  } catch (err) {
    console.error('conductorController.list', err);
    res.status(500).json({ ok: false, error: err.message });
  }
}

async function create(req, res) {
  try {
    const { dni_conductor, nombre_conductor, numero_licencia_conductor, usuario } = req.body;
    const result = await conductorService.create({ dni_conductor, nombre_conductor, numero_licencia_conductor, usuario });
    res.json({ ok: true, message: result.mensaje || 'Creado' });
  } catch (err) {
    console.error('conductorController.create', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

async function update(req, res) {
  try {
    const { dni } = req.params; // ruta: /api/conductor/:dni
    const { nombre_conductor, numero_licencia_conductor, usuario } = req.body;
    const result = await conductorService.update({ dni_conductor: dni, nombre_conductor, numero_licencia_conductor, usuario });
    res.json({ ok: true, message: result.mensaje || 'Actualizado' });
  } catch (err) {
    console.error('conductorController.update', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

async function softDelete(req, res) {
  try {
    const { dni } = req.params;
    const { usuario } = req.body;
    const result = await conductorService.softDelete({ dni_conductor: dni, usuario });
    res.json({ ok: true, message: result.mensaje || 'Desactivado' });
  } catch (err) {
    console.error('conductorController.softDelete', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

module.exports = { list, create, update, softDelete };
