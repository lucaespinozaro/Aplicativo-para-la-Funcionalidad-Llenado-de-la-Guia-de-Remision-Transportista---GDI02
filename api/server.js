const http = require('http');
const fs = require('fs');
const path = require('path');
const { URL } = require('url');
require('dotenv').config();

// Controllers (mantén tus archivos tal como están)
const guiaRemitenteController = require('./controllers/guiaRemitenteController');
const empresaController = require('./controllers/empresaController');
const conductorController = require('./controllers/conductorController');
const vehiculosController = require('./controllers/vehiculosController');
const productoController = require('./controllers/productoController');

const PORT = process.env.PORT || process.env.APP_PORT || 3000;
const WEB_ROOT = path.join(__dirname, '..', 'web');

// mime types simples
const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.txt': 'text/plain; charset=utf-8'
};

// CORS headers (ajusta en producción)
function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Accept');
}

// respuesta JSON util
function sendJsonRaw(nodeRes, statusCode, payload) {
  const body = JSON.stringify(payload);
  nodeRes.writeHead(statusCode, { 'Content-Type': 'application/json; charset=utf-8' });
  nodeRes.end(body);
}

// crea un objeto "res" compatible con Express básico (.json, .status().json)
function makeResponder(nodeRes) {
  return {
    json(payload) { return sendJsonRaw(nodeRes, 200, payload); },
    status(code) { return { json(payload) { return sendJsonRaw(nodeRes, code, payload); } } }
  };
}

// parse body JSON (promise)
function parseJsonBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', chunk => raw += chunk.toString());
    req.on('end', () => {
      if (!raw) return resolve({});
      try {
        const parsed = JSON.parse(raw);
        resolve(parsed);
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

// servir archivos estáticos de web/
function serveStatic(req, res) {
  let requestPath = req.url.split('?')[0];
  if (requestPath === '/' || requestPath === '') requestPath = '/index.html';
  const filePath = path.join(WEB_ROOT, decodeURIComponent(requestPath));
  if (!filePath.startsWith(WEB_ROOT)) {
    res.writeHead(403); res.end('Forbidden'); return;
  }
  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // fallback: enviar index.html (SPA client-side routes)
      const index = path.join(WEB_ROOT, 'index.html');
      fs.readFile(index, (e, data) => {
        if (e) { res.writeHead(500); res.end('Server error'); return; }
        res.writeHead(200, { 'Content-Type': MIME['.html'] });
        res.end(data);
      });
      return;
    }
    const ext = path.extname(filePath).toLowerCase();
    const ct = MIME[ext] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': ct });
    fs.createReadStream(filePath).pipe(res);
  });
}

// simple router: mapea URL y método a handler que recibe (reqObj, resObj)
async function handleApi(req, res) {
  setCorsHeaders(res);
  // OPTIONS preflight
  if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }

  const urlObj = new URL(req.url, `http://${req.headers.host}`);
  const pathname = urlObj.pathname;
  const responder = makeResponder(res);

  try {
    // ---------- GUÍA REMITENTE ----------
    if (req.method === 'POST' && pathname === '/api/gr/draft') {
      const body = await parseJsonBody(req);
      return guiaRemitenteController.saveDraft({ body }, responder);
    }
    if (req.method === 'POST' && /^\/api\/gr\/finalize\/[^/]+$/.test(pathname)) {
      const numero = pathname.split('/').pop();
      const body = await parseJsonBody(req);
      return guiaRemitenteController.finalize({ params: { numero }, body }, responder);
    }
    if (req.method === 'POST' && pathname === '/api/gr/detalle') {
      const body = await parseJsonBody(req);
      return guiaRemitenteController.addDetalle({ body }, responder);
    }
    if (req.method === 'PUT' && pathname === '/api/gr/detalle') {
      const body = await parseJsonBody(req);
      return guiaRemitenteController.updateDetalle({ body }, responder);
    }
    if (req.method === 'DELETE' && /^\/api\/gr\/detalle\/[^/]+\/\d+$/.test(pathname)) {
      // DELETE /api/gr/detalle/:numero/:item
      const parts = pathname.split('/');
      const numero = parts[4];
      const item = parts[5];
      // try parse body if any (usuario)
      let body = {};
      try { body = await parseJsonBody(req); } catch (e) { body = {}; }
      return guiaRemitenteController.deleteDetalle({ params: { numero, item }, body }, responder);
    }
    if (req.method === 'GET' && pathname === '/api/gr') {
      const query = Object.fromEntries(urlObj.searchParams.entries());
      return guiaRemitenteController.list({ query }, responder);
    }
    if (req.method === 'GET' && /^\/api\/gr\/[^/]+$/.test(pathname)) {
      const numero = pathname.split('/').pop();
      return guiaRemitenteController.getWithDetails({ params: { numero } }, responder);
    }

    // ---------- GUÍA TRANSPORTISTA ----------
    if (req.method === 'POST' && pathname === '/api/gt/from_remitentes') {
      const body = await parseJsonBody(req);
      return guiaRemitenteController.createGTFromRemitentes({ body }, responder);
    }

    // ---------- REPORTES ----------
    if (req.method === 'GET' && /^\/api\/report\/\d+$/.test(pathname)) {
      const id = pathname.split('/').pop();
      const query = Object.fromEntries(urlObj.searchParams.entries());
      return guiaRemitenteController.executeReport({ params: { id }, query }, responder);
    }

    // ---------- EMPRESA (CRUD) ----------
    if (req.method === 'GET' && pathname === '/api/empresa') {
      const query = Object.fromEntries(urlObj.searchParams.entries());
      return empresaController.list({ query }, responder);
    }
    if (req.method === 'GET' && /^\/api\/empresa\/[^/]+$/.test(pathname)) {
      const ruc = pathname.split('/').pop();
      return empresaController.get ? empresaController.get({ params: { ruc } }, responder) : empresaController.list({ query: { ruc } }, responder);
    }
    if (req.method === 'POST' && pathname === '/api/empresa') {
      const body = await parseJsonBody(req);
      return empresaController.create({ body }, responder);
    }
    if (req.method === 'PUT' && /^\/api\/empresa\/[^/]+$/.test(pathname)) {
      const ruc = pathname.split('/').pop();
      const body = await parseJsonBody(req);
      return empresaController.update({ params: { ruc }, body }, responder);
    }
    if (req.method === 'DELETE' && /^\/api\/empresa\/[^/]+$/.test(pathname)) {
      const ruc = pathname.split('/').pop();
      let body = {};
      try { body = await parseJsonBody(req); } catch(e){}
      return empresaController.softDelete({ params: { ruc }, body }, responder);
    }

    // ---------- CONDUCTOR ----------
    if (req.method === 'GET' && pathname === '/api/conductor') {
      const query = Object.fromEntries(urlObj.searchParams.entries());
      return conductorController.list({ query }, responder);
    }
    if (req.method === 'POST' && pathname === '/api/conductor') {
      const body = await parseJsonBody(req);
      return conductorController.create({ body }, responder);
    }
    if (req.method === 'PUT' && /^\/api\/conductor\/[^/]+$/.test(pathname)) {
      const dni = pathname.split('/').pop();
      const body = await parseJsonBody(req);
      return conductorController.update({ params: { dni }, body }, responder);
    }
    if (req.method === 'DELETE' && /^\/api\/conductor\/[^/]+$/.test(pathname)) {
      const dni = pathname.split('/').pop();
      let body = {};
      try { body = await parseJsonBody(req); } catch(e){}
      return conductorController.softDelete({ params: { dni }, body }, responder);
    }

    // ---------- PRODUCTO ----------
    if (req.method === 'GET' && pathname === '/api/producto') {
      const query = Object.fromEntries(urlObj.searchParams.entries());
      return productoController.list({ query }, responder);
    }
    if (req.method === 'POST' && pathname === '/api/producto') {
      const body = await parseJsonBody(req);
      return productoController.create({ body }, responder);
    }
    if (req.method === 'PUT' && /^\/api\/producto\/[^/]+$/.test(pathname)) {
      const codigo = pathname.split('/').pop();
      const body = await parseJsonBody(req);
      return productoController.update({ params: { codigo }, body }, responder);
    }
    if (req.method === 'DELETE' && /^\/api\/producto\/[^/]+$/.test(pathname)) {
      const codigo = pathname.split('/').pop();
      let body = {};
      try { body = await parseJsonBody(req); } catch(e){}
      return productoController.softDelete({ params: { codigo }, body }, responder);
    }

    // ---------- VEHÍCULOS (tracto + semirremolque combinado) ----------
    if (req.method === 'GET' && pathname === '/api/vehiculos') {
      const query = Object.fromEntries(urlObj.searchParams.entries());
      return vehiculosController.list({ query }, responder);
    }
    if (req.method === 'POST' && pathname === '/api/vehiculos') {
      const body = await parseJsonBody(req);
      return vehiculosController.create({ body }, responder);
    }
    if (req.method === 'PUT' && /^\/api\/vehiculos\/[^/]+$/.test(pathname)) {
      const placa = pathname.split('/').pop();
      const body = await parseJsonBody(req);
      return vehiculosController.update({ params: { placa }, body }, responder);
    }

    // ---------- HEALTH ----------
    if (req.method === 'GET' && pathname === '/health') {
      setCorsHeaders(res);
      return sendJsonRaw(res, 200, { status: 'OK', timestamp: new Date().toISOString() });
    }

    // si no matchea: devolver 404
    return sendJsonRaw(res, 404, { ok: false, error: 'Endpoint no encontrado' });
  } catch (err) {
    console.error('API handler error:', err);
    return sendJsonRaw(res, 500, { ok: false, error: err.message || 'Error interno' });
  }
}

// servidor principal
const server = http.createServer((req, res) => {
  console.log(new Date().toISOString(), req.method, req.url);

  // si empieza /api -> manejar API
  if (req.url.startsWith('/api/') || /^\/api(\/|$)/.test(req.url)) {
    return handleApi(req, res);
  }

  // servir estático (SPA fallback)
  return serveStatic(req, res);
});

server.listen(PORT, () => {
  console.log(`✓ Servidor (nativo) escuchando en http://localhost:${PORT}`);
  console.log(`✓ Health check: http://localhost:${PORT}/health`);
});
