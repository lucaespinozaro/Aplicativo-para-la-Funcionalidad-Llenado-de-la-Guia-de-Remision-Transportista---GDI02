const productoService = require('../services/productoService');

async function list(req, res) {
  try {
    const q = req.query.q || null; // búsqueda por código o descripción
    const rows = await productoService.list({ q });
    res.json({ ok: true, data: rows });
  } catch (err) {
    console.error('productoController.list', err);
    res.status(500).json({ ok: false, error: err.message });
  }
}

async function create(req, res) {
  try {
    const { codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, usuario } = req.body;
    const result = await productoService.create({ codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, usuario });
    res.json({ ok: true, message: result.mensaje || 'Creado' });
  } catch (err) {
    console.error('productoController.create', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

async function update(req, res) {
  try {
    const { codigo } = req.params;
    const { lote, descripcion, material, unidad_medida, peso_bruto, usuario } = req.body;
    const result = await productoService.update({ codigo_producto: codigo, lote, descripcion, material, unidad_medida, peso_bruto, usuario });
    res.json({ ok: true, message: result.mensaje || 'Actualizado' });
  } catch (err) {
    console.error('productoController.update', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

async function softDelete(req, res) {
  try {
    const { codigo } = req.params;
    const { usuario } = req.body;
    const result = await productoService.softDelete({ codigo_producto: codigo, usuario });
    res.json({ ok: true, message: result.mensaje || 'Desactivado' });
  } catch (err) {
    console.error('productoController.softDelete', err);
    res.status(400).json({ ok: false, error: err.message });
  }
}

module.exports = { list, create, update, softDelete };
