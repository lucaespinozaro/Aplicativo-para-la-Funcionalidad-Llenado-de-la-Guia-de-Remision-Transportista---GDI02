const empresaService = require('../services/empresaService');

async function list(req, res) {
  try {
    const rows = await empresaService.list();
    res.json({ ok: true, data: rows });
  } catch (err) {
    console.error('empresaController.list', err);
    res.status(500).json({ ok: false, error: err.message || 'Error listando empresas' });
  }
}

async function create(req, res) {
  try {
    const { ruc, provincia, departamento, distrito, domicilio, razon_social, usuario } = req.body;
    const result = await empresaService.create({ ruc, provincia, departamento, distrito, domicilio, razon_social, usuario });
    res.json({ ok: true, message: result.mensaje, data: result });
  } catch (err) {
    console.error('empresaController.create', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

async function update(req, res) {
  try {
    const { ruc } = req.params;
    const { provincia, departamento, distrito, domicilio, razon_social, usuario } = req.body;
    const result = await empresaService.update({ ruc, provincia, departamento, distrito, domicilio, razon_social, usuario });
    res.json({ ok: true, message: result.mensaje });
  } catch (err) {
    console.error('empresaController.update', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

async function softDelete(req, res) {
  try {
    const { ruc } = req.params;
    const { usuario } = req.body;
    const result = await empresaService.softDelete({ ruc, usuario });
    res.json({ ok: true, message: result.mensaje });
  } catch (err) {
    console.error('empresaController.softDelete', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

module.exports = { list, create, update, softDelete };
