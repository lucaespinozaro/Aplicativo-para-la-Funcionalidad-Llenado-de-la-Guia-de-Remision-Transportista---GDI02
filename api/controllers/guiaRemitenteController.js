/**
 * CONTROLLER - Capa de presentación REST
 * Expone endpoints, parsea requests, devuelve JSON uniforme
 * Formato de respuesta: { ok: true/false, data, error }
 */

const guiaRemitenteService = require('../services/guiaRemitenteService');

class GuiaRemitenteController {

    /**
     * POST /api/gr/draft
     * Guardar borrador de guía remitente
     */
    async saveDraft(req, res) {
        try {
            const data = {
                ...req.body,
                usuario: req.body.usuario || 'API_USER' // En producción: obtener de sesión/token
            };

            const result = await guiaRemitenteService.saveDraft(data);
            
            res.status(201).json({
                ok: true,
                data: result,
                message: 'Borrador guardado exitosamente'
            });
        } catch (error) {
            console.error('Error en saveDraft:', error);
            res.status(422).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * POST /api/gr/finalize/:numero
     * Finalizar guía remitente
     */
    async finalize(req, res) {
        try {
            const numeroGuia = req.params.numero;
            const usuario = req.body.usuario || 'API_USER';

            const result = await guiaRemitenteService.finalize(numeroGuia, usuario);
            
            res.json({
                ok: true,
                data: result,
                message: 'Guía finalizada exitosamente'
            });
        } catch (error) {
            console.error('Error en finalize:', error);
            res.status(422).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * POST /api/gr/detalle
     * Agregar detalle a guía remitente
     */
    async addDetalle(req, res) {
        try {
            const data = {
                ...req.body,
                usuario: req.body.usuario || 'API_USER'
            };

            const result = await guiaRemitenteService.addDetalle(data);
            
            res.status(201).json({
                ok: true,
                data: result,
                message: 'Detalle agregado exitosamente'
            });
        } catch (error) {
            console.error('Error en addDetalle:', error);
            res.status(422).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * PUT /api/gr/detalle
     * Actualizar detalle
     */
    async updateDetalle(req, res) {
        try {
            const data = {
                ...req.body,
                usuario: req.body.usuario || 'API_USER'
            };

            const result = await guiaRemitenteService.updateDetalle(data);
            
            res.json({
                ok: true,
                data: result,
                message: 'Detalle actualizado exitosamente'
            });
        } catch (error) {
            console.error('Error en updateDetalle:', error);
            res.status(422).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * DELETE /api/gr/detalle/:numero/:item
     * Eliminar detalle (lógico)
     */
    async deleteDetalle(req, res) {
        try {
            const numeroGuia = req.params.numero;
            const numeroItem = parseInt(req.params.item);
            const usuario = req.body.usuario || 'API_USER';

            const result = await guiaRemitenteService.deleteDetalle(numeroGuia, numeroItem, usuario);
            
            res.json({
                ok: true,
                data: result,
                message: 'Detalle eliminado exitosamente'
            });
        } catch (error) {
            console.error('Error en deleteDetalle:', error);
            res.status(422).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * GET /api/gr
     * Listar guías remitente
     */
    async list(req, res) {
        try {
            const filters = {
                fecha_desde: req.query.fecha_desde,
                fecha_hasta: req.query.fecha_hasta,
                ruc_transportista: req.query.ruc_transportista
            };

            const result = await guiaRemitenteService.list(filters);
            
            res.json({
                ok: true,
                data: result,
                count: result.length
            });
        } catch (error) {
            console.error('Error en list:', error);
            res.status(500).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * GET /api/gr/:numero
     * Obtener guía con detalles
     */
    async getWithDetails(req, res) {
        try {
            const numeroGuia = req.params.numero;
            const result = await guiaRemitenteService.getWithDetails(numeroGuia);
            
            res.json({
                ok: true,
                data: result
            });
        } catch (error) {
            console.error('Error en getWithDetails:', error);
            res.status(404).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * POST /api/gt/from_remitentes
     * Crear guía transportista desde remitentes
     */
    async createGTFromRemitentes(req, res) {
        try {
            const data = {
                ...req.body,
                usuario: req.body.usuario || 'API_USER'
            };

            const result = await guiaRemitenteService.createGTFromRemitentes(data);
            
            res.status(201).json({
                ok: true,
                data: result,
                message: 'Guía transportista creada exitosamente'
            });
        } catch (error) {
            console.error('Error en createGTFromRemitentes:', error);
            res.status(422).json({
                ok: false,
                error: error.message
            });
        }
    }

    /**
     * GET /api/report/:id
     * Ejecutar reporte
     */
    async executeReport(req, res) {
        try {
            const reportId = req.params.id;
            const params = req.query;

            const result = await guiaRemitenteService.executeReport(reportId, params);
            
            res.json({
                ok: true,
                data: result,
                count: result.length
            });
        } catch (error) {
            console.error('Error en executeReport:', error);
            res.status(400).json({
                ok: false,
                error: error.message
            });
        }
    }
}

module.exports = new GuiaRemitenteController();
