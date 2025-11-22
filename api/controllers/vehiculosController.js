const vehiculosService = require('../services/vehiculosService');

async function list(req, res) {
  try {
    const { placa } = req.query; // opcional: ?placa=...
    const rows = await vehiculosService.list({ placa });
    res.json({ ok: true, data: rows });
  } catch (err) {
    console.error('vehiculosController.list', err);
    res.status(500).json({ ok: false, error: err.message });
  }
}

async function create(req, res) {
  try {
    // payload must include a type: 'tracto' or 'semirremolque'
    const result = await vehiculosService.create(req.body);
    res.json({ ok: true, message: result.mensaje || 'Creado', data: result });
  } catch (err) {
    console.error('vehiculosController.create', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

async function update(req, res) {
  try {
    const { placa } = req.params; // placa used to identify
    const result = await vehiculosService.update({ placa, ...req.body });
    res.json({ ok: true, message: result.mensaje || 'Actualizado' });
  } catch (err) {
    console.error('vehiculosController.update', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

module.exports = { list, create, update };
