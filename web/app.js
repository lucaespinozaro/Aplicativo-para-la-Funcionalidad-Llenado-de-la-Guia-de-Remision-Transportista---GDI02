// app.js — versión corregida
// Configuración
const API_BASE_URL = 'http://localhost:3000/api';
const DEFAULT_USER = 'FRONTEND_USER';

// IDs de elementos de mensaje (NO son contenedores de datos)
const MSG_IDS = {
  empresas: 'empresa-msg',
  conductores: 'conductor-msg',
  vehiculos: 'vehiculo-msg',
  productos: 'producto-msg',
  gr: 'gr-draft-result',
  gt: 'gt-result'
};

// Variables globales
let currentGRNumber = null;
let selectedRemitentes = [];

// ============================================================================
// UTILIDADES
// ============================================================================

function showSection(sectionId) {
  document.querySelectorAll('.content-section').forEach(section => section.classList.remove('active'));
  document.getElementById(sectionId).classList.add('active');
}

// showMessage ahora **nunca** debe usarse con el id del contenedor de la tabla.
// Usa los divs dedicados (empresa-msg, conductor-msg, vehiculo-msg, producto-msg, gr-draft-result, gt-result).
function showMessage(elementId, message, type = 'success') {
  const el = document.getElementById(elementId);
  if (!el) {
    console.warn('showMessage: elemento no encontrado', elementId, message);
    return;
  }
  el.textContent = message;
  el.className = `result-box ${type}`;
  el.style.display = 'block';

  // Ocultar después de 5s
  setTimeout(() => {
    el.style.display = 'none';
  }, 5000);
}

function validateRuc(ruc) {
  return /^[0-9]{11}$/.test(ruc);
}

function validateDni(dni) {
  return /^[0-9]{8}$/.test(dni);
}

function getFormData(formId) {
  const form = document.getElementById(formId);
  if (!form) return {};
  const formData = new FormData(form);
  const data = {};

  for (let [key, value] of formData.entries()) {
    const el = form.elements[key];
    if (el && el.type === 'checkbox') {
      data[key] = el.checked ? 1 : 0;
    } else {
      data[key] = value;
    }
  }

  data.usuario = DEFAULT_USER;
  return data;
}

// Helper: attach Enter to search inputs
function attachEnterToSearch(inputId, searchFn) {
  const el = document.getElementById(inputId);
  if (!el) return;
  el.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      searchFn();
    }
  });
}

// Helper para renderizar tablas (no toca divs de mensajes)
function renderTable(containerId, columns, rows, actionsRenderer) {
  const container = document.getElementById(containerId);
  container.innerHTML = '';
  if (!rows || rows.length === 0) {
    container.innerHTML = '<p>No hay registros.</p>';
    return;
  }
  const table = document.createElement('table');
  table.className = 'data-table';
  // Crear encabezado
  const thead = document.createElement('thead');
  const trHead = document.createElement('tr');
  columns.forEach(c => {
    const th = document.createElement('th');
    th.textContent = c.label;
    trHead.appendChild(th);
  });
  const thAcc = document.createElement('th');
  thAcc.textContent = 'Acciones';
  trHead.appendChild(thAcc);
  thead.appendChild(trHead);
  table.appendChild(thead);

  const tbody = document.createElement('tbody');
  rows.forEach(row => {
    const tr = document.createElement('tr');
    columns.forEach(c => {
      const td = document.createElement('td');
      const v = (row[c.key] === null || row[c.key] === undefined) ? '' : row[c.key];
      td.textContent = v;
      tr.appendChild(td);
    });

    const tdActions = document.createElement('td');
    tdActions.className = 'actions-cell';
    tdActions.innerHTML = actionsRenderer(row);
    tr.appendChild(tdActions);

    tbody.appendChild(tr);
  });
  table.appendChild(tbody);
  container.appendChild(table);
}

// ============================================================================
// GUÍA REMITENTE - BORRADOR (sin cambios funcionales; solo showMessage con id correcto)
// ============================================================================

document.getElementById('form-gr-draft')?.addEventListener('submit', async (e) => {
  e.preventDefault();

  const data = getFormData('form-gr-draft');

  if (!validateRuc(data.ruc_transportista)) {
    showMessage(MSG_IDS.gr, 'RUC transportista inválido (11 dígitos)', 'error');
    return;
  }
  if (!validateRuc(data.ruc_remitente)) {
    showMessage(MSG_IDS.gr, 'RUC remitente inválido (11 dígitos)', 'error');
    return;
  }
  if (!validateRuc(data.ruc_destinatario)) {
    showMessage(MSG_IDS.gr, 'RUC destinatario inválido (11 dígitos)', 'error');
    return;
  }
  if (!validateDni(data.dni_conductor)) {
    showMessage(MSG_IDS.gr, 'DNI conductor inválido (8 dígitos)', 'error');
    return;
  }

  try {
    const response = await fetch(`${API_BASE_URL}/gr/draft`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    const result = await response.json();

    if (result.ok) {
      showMessage(MSG_IDS.gr, result.message || 'Borrador guardado', 'success');
      currentGRNumber = data.numero_guia_remitente;
      document.getElementById('detalle-section').style.display = 'block';
      const detalleNum = document.getElementById('detalle-numero-guia');
      if (detalleNum) detalleNum.value = currentGRNumber;
      // deshabilitar form
      document.getElementById('form-gr-draft').querySelectorAll('input, select, textarea').forEach(el => el.disabled = true);
      loadDetalles(currentGRNumber);
    } else {
      showMessage(MSG_IDS.gr, result.error || 'Error guardando borrador', 'error');
    }
  } catch (error) {
    showMessage(MSG_IDS.gr, 'Error de conexión: ' + error.message, 'error');
  }
});

document.getElementById('form-detalle')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const data = getFormData('form-detalle');
  data.numero_guia_remitente = currentGRNumber;
  try {
    const response = await fetch(`${API_BASE_URL}/gr/detalle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    const result = await response.json();
    if (result.ok) {
      alert('Detalle agregado exitosamente');
      document.getElementById('form-detalle').reset();
      document.getElementById('detalle-numero-guia').value = currentGRNumber;
      loadDetalles(currentGRNumber);
    } else {
      alert('Error: ' + result.error);
    }
  } catch (error) {
    alert('Error de conexión: ' + error.message);
  }
});

async function loadDetalles(numeroGuia) {
  try {
    const response = await fetch(`${API_BASE_URL}/gr/${numeroGuia}`);
    const result = await response.json();
    const container = document.getElementById('detalles-list');
    if (result.ok && result.data && result.data.detalles) {
      container.innerHTML = '<h4>Detalles Agregados:</h4>';
      const table = document.createElement('table');
      table.innerHTML = `
        <thead>
          <tr><th>Ítem</th><th>Producto</th><th>Peso Tara</th><th>Peso Neto</th><th>Peso Bruto</th></tr>
        </thead>
        <tbody>
          ${result.data.detalles.map(d => `
            <tr>
              <td>${d.numero_item}</td>
              <td>${d.codigo_producto}</td>
              <td>${d.peso_tara}</td>
              <td>${d.peso_neto}</td>
              <td>${d.peso_bruto}</td>
            </tr>
          `).join('')}
        </tbody>
      `;
      container.appendChild(table);
    } else {
      if (container) container.innerHTML = '<p>No hay detalles todavía.</p>';
    }
  } catch (error) {
    console.error('Error cargando detalles:', error);
  }
}

// ----------------------
// Autocompletar peso_neto y calcular peso_bruto automático
// ----------------------

async function fetchProductByCode(code) {
    if (!code) return null;
    try {
        const res = await fetch(`${API_BASE_URL}/producto?q=${encodeURIComponent(code)}`);
        const j = await res.json();
        if (!j.ok) return null;
        // j.data puede ser array
        if (Array.isArray(j.data)) {
            if (j.data.length === 0) return null;
            // si hay varios, tomar el primero (esperamos coincidencia por código exacto)
            return j.data[0];
        }
        // si devuelve objeto directo
        return j.data || null;
    } catch (err) {
        console.error('fetchProductByCode error', err);
        return null;
    }
}

function calculatePesoBrutoInDetalleForm() {
    const form = document.getElementById('form-detalle');
    if (!form) return;
    const tara = parseFloat(form.peso_tara.value || 0);
    const neto = parseFloat(form.peso_neto.value || 0);
    const bruto = (isNaN(tara) ? 0 : tara) + (isNaN(neto) ? 0 : neto);
    // fijar con 3 decimales (ajusta si quieres más/menos)
    form.peso_bruto.value = bruto.toFixed(3);
}

document.getElementById('form-detalle') && (function() {
    const form = document.getElementById('form-detalle');
    const codigoInput = form.elements['codigo_producto'];
    const taraInput = form.elements['peso_tara'];
    const netoInput = form.elements['peso_neto'];

    // cuando cambie el código — buscar producto y autocompletar peso_neto
    codigoInput?.addEventListener('change', async (e) => {
        const code = (e.target.value || '').trim();
        if (!code) return;
        const product = await fetchProductByCode(code);
        if (product) {
            // Intentar usar product.peso_neto si existe, sino product.peso_bruto como fallback
            const productPesoNeto = (product.peso_neto !== undefined && product.peso_neto !== null)
                ? product.peso_neto
                : (product.peso_bruto !== undefined && product.peso_bruto !== null)
                    ? product.peso_bruto
                    : 0;
            netoInput.value = parseFloat(productPesoNeto) ? parseFloat(productPesoNeto).toFixed(3) : '0.000';
            // recalcular bruto
            calculatePesoBrutoInDetalleForm();
            showMessage(MSG_IDS.gr, `Peso neto autocompletado desde producto (${code})`, 'success');
        } else {
            // no encontrado: limpiar peso_neto (dejar 0) y avisar
            netoInput.value = '0.000';
            calculatePesoBrutoInDetalleForm();
            showMessage(MSG_IDS.gr, `Producto ${code} no encontrado`, 'error');
        }
    });

    // recalcular cuando el usuario cambia tara o neto manualmente
    taraInput?.addEventListener('input', calculatePesoBrutoInDetalleForm);
    netoInput?.addEventListener('input', calculatePesoBrutoInDetalleForm);
})();


async function finalizeGR() {
  if (!currentGRNumber) { alert('No hay guía para finalizar'); return; }
  if (!confirm('¿Está seguro de finalizar esta guía? No podrá modificarla después.')) return;
  try {
    const response = await fetch(`${API_BASE_URL}/gr/finalize/${currentGRNumber}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ usuario: DEFAULT_USER })
    });
    const result = await response.json();
    if (result.ok) {
      alert('Guía finalizada exitosamente');
      document.getElementById('form-gr-draft').reset();
      document.getElementById('form-gr-draft').querySelectorAll('input, select, textarea').forEach(el => el.disabled = false);
      document.getElementById('detalle-section').style.display = 'none';
      currentGRNumber = null;
      loadGRList();
    } else {
      alert('Error: ' + result.error);
    }
  } catch (error) {
    alert('Error de conexión: ' + error.message);
  }
}

// ============================================================================
// LISTAR GUÍAS REMITENTE
// ============================================================================

async function loadGRList() {
  const fechaDesde = document.getElementById('filter-fecha-desde').value;
  const fechaHasta = document.getElementById('filter-fecha-hasta').value;
  const rucTransportista = document.getElementById('filter-ruc').value;

  const params = new URLSearchParams();
  if (fechaDesde) params.append('fecha_desde', fechaDesde);
  if (fechaHasta) params.append('fecha_hasta', fechaHasta);
  if (rucTransportista) params.append('ruc_transportista', rucTransportista);

  try {
    const response = await fetch(`${API_BASE_URL}/gr?${params}`);
    const result = await response.json();
    if (result.ok) {
      displayGRList(result.data);
    } else {
      alert('Error: ' + result.error);
    }
  } catch (error) {
    alert('Error de conexión: ' + error.message);
  }
}

function displayGRList(data) {
  const container = document.getElementById('gr-list-content');
  if (!data || data.length === 0) {
    container.innerHTML = '<p>No se encontraron guías remitente</p>';
    return;
  }
  const table = document.createElement('table');
  table.innerHTML = `
    <thead>
      <tr>
        <th>Número</th><th>Fecha</th><th>Remitente</th><th>Destinatario</th><th>Peso Total</th><th>GT Asociada</th>
      </tr>
    </thead>
    <tbody>
      ${data.map(gr => `
        <tr>
          <td>${gr.numero_guia_remitente}</td>
          <td>${gr.fecha_emision}</td>
          <td>${gr.remitente_razon || gr.ruc_remitente}</td>
          <td>${gr.destinatario_razon || gr.ruc_destinatario}</td>
          <td>${gr.peso_total_traslado}</td>
          <td>${gr.numero_guia_transportista || 'Sin asignar'}</td>
        </tr>
      `).join('')}
    </tbody>
  `;
  container.innerHTML = `<p>Encontradas: ${data.length} guías</p>`;
  container.appendChild(table);
}

// ============================================================================
// WIZARD GUÍA TRANSPORTISTA
// ============================================================================

function wizardNext(step) {
  document.querySelectorAll('.wizard-step').forEach(s => s.style.display = 'none');
  document.getElementById(`wizard-step-${step}`).style.display = 'block';
  if (step === 3) showGTSummary();
}

async function loadAvailableGR() {
  try {
    const response = await fetch(`${API_BASE_URL}/gr`);
    const result = await response.json();
    if (result.ok) {
      const available = result.data.filter(gr => !gr.numero_guia_transportista);
      displayAvailableGR(available);
    }
  } catch (error) { alert('Error: ' + error.message); }
}

function displayAvailableGR(data) {
  const container = document.getElementById('available-gr-list');
  if (!data || data.length === 0) { container.innerHTML = '<p>No hay guías remitente disponibles</p>'; return; }
  container.innerHTML = '<div class="selectable-list">' + data.map(gr => `
    <div class="selectable-item">
      <label>
        <input type="checkbox" value="${gr.numero_guia_remitente}" onchange="toggleGRSelection(this)">
        <strong>${gr.numero_guia_remitente}</strong> - 
        ${gr.remitente_razon || gr.ruc_remitente} → ${gr.destinatario_razon || gr.ruc_destinatario} 
        (${gr.peso_total_traslado} KG)
      </label>
    </div>
  `).join('') + '</div>';
}

function toggleGRSelection(checkbox) {
  if (checkbox.checked) {
    selectedRemitentes.push(checkbox.value);
    checkbox.closest('.selectable-item').classList.add('selected');
  } else {
    selectedRemitentes = selectedRemitentes.filter(n => n !== checkbox.value);
    checkbox.closest('.selectable-item').classList.remove('selected');
  }
}

document.querySelector('input[name="indicador_transporte_subcontratado"]')?.addEventListener('change', function() {
  document.getElementById('subcontrato-fields').style.display = this.checked ? 'block' : 'none';
});

function showGTSummary() {
  const formData = getFormData('form-gt');
  const summary = document.getElementById('gt-summary');
  summary.innerHTML = `
    <h4>Resumen de Guía Transportista</h4>
    <p><strong>Número:</strong> ${formData.numero_guia_transportista}</p>
    <p><strong>Transportista:</strong> ${formData.ruc_transportista}</p>
    <p><strong>Fecha Inicio:</strong> ${formData.fecha_inicio_traslado}</p>
    <p><strong>Guías Remitente Seleccionadas:</strong> ${selectedRemitentes.length}</p>
    <ul>${selectedRemitentes.map(n => `<li>${n}</li>`).join('')}</ul>
    <p><strong>Transporte Subcontratado:</strong> ${formData.indicador_transporte_subcontratado ? 'Sí' : 'No'}</p>
  `;
}

async function createGT() {
  if (selectedRemitentes.length === 0) { alert('Debe seleccionar al menos una guía remitente'); return; }
  const formData = getFormData('form-gt');
  formData.remitentes = selectedRemitentes;
  try {
    const response = await fetch(`${API_BASE_URL}/gt/from_remitentes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData)
    });
    const result = await response.json();
    if (result.ok) {
      showMessage(MSG_IDS.gt, (result.message || 'OK') + ' - Número: ' + (result.data?.numero || ''), 'success');
      selectedRemitentes = [];
      document.getElementById('form-gt').reset();
      wizardNext(1);
      loadGRList();
    } else {
      showMessage(MSG_IDS.gt, result.error || 'Error creando GT', 'error');
    }
  } catch (error) {
    showMessage(MSG_IDS.gt, 'Error de conexión: ' + error.message, 'error');
  }
}

// ============================================================================
// REPORTES
// ============================================================================

function showReportParams() {
  const reportId = document.getElementById('report-select').value;
  if (!reportId) { document.getElementById('report-params').style.display = 'none'; return; }

  const paramsConfig = {
    '1': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }],
    '2': [{ name: 'numero_guia', label: 'Número de Guía', type: 'text' }],
    '3': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }, { name: 'ruc_transportista', label: 'RUC Transportista', type: 'text' }],
    '4': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }, { name: 'hora_ini', label: 'Hora Inicial', type: 'time' }, { name: 'hora_fin', label: 'Hora Final', type: 'time' }],
    '5': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }],
    '6': [{ name: 'numero_guia_remitente', label: 'Número Guía Remitente', type: 'text' }],
    '7': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }],
    '8': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }],
    '9': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }],
    '10': [{ name: 'fecha_ini', label: 'Fecha Inicial', type: 'date' }, { name: 'fecha_fin', label: 'Fecha Final', type: 'date' }]
  };

  const params = paramsConfig[reportId] || [];
  const container = document.getElementById('params-container');
  container.innerHTML = params.map(p => `
    <div class="form-group">
      <label>${p.label}</label>
      <input type="${p.type}" name="${p.name}" required>
    </div>
  `).join('');
  document.getElementById('report-params').style.display = 'block';
}

document.getElementById('form-report')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const reportId = document.getElementById('report-select').value;
  if (!reportId) { alert('Seleccione un reporte'); return; }
  const form = e.target;
  const formData = new FormData(form);
  const params = new URLSearchParams();
  for (let [k, v] of formData.entries()) params.append(k, v);

  try {
    const response = await fetch(`${API_BASE_URL}/report/${reportId}?${params.toString()}`);
    const result = await response.json();
    if (result.ok) displayReportResults(result.data, reportId);
    else document.getElementById('report-results').innerHTML = `<div class="result-box error">${result.error}</div>`;
  } catch (error) {
    document.getElementById('report-results').innerHTML = `<div class="result-box error">Error de conexión: ${error.message}</div>`;
  }
});

function displayReportResults(data, reportId) {
  const container = document.getElementById('report-results');
  container.innerHTML = '';
  if (!data || (Array.isArray(data) && data.length === 0)) { container.innerHTML = '<p>No se encontraron resultados.</p>'; return; }
  if (Array.isArray(data)) {
    const table = document.createElement('table');
    const keys = Object.keys(data[0] || {});
    table.innerHTML = `
      <thead><tr>${keys.map(k => `<th>${k}</th>`).join('')}</tr></thead>
      <tbody>
        ${data.map(row => `<tr>${keys.map(k => `<td>${(row[k] === null || row[k] === undefined) ? '' : row[k]}</td>`).join('')}</tr>`).join('')}
      </tbody>
    `;
    container.appendChild(table);
  } else if (typeof data === 'object') {
    const table = document.createElement('table');
    table.innerHTML = `
      <thead><tr><th>Campo</th><th>Valor</th></tr></thead>
      <tbody>
      ${Object.keys(data).map(k => `<tr><td>${k}</td><td>${data[k]}</td></tr>`).join('')}
      </tbody>
    `;
    container.appendChild(table);
  } else {
    container.textContent = String(data);
  }
}

// ============================================================================
// EMPRESAS
// ============================================================================

function showEmpresaForm(editData) {
  document.getElementById('empresa-form-container').style.display = 'block';
  const form = document.getElementById('form-empresa');
  form.reset();
  if (editData) {
    document.getElementById('empresa-form-title').textContent = 'Editar Empresa';
    form.ruc.value = editData.ruc;
    form.razon_social.value = editData.razon_social || '';
    form.provincia.value = editData.provincia || '';
    form.departamento.value = editData.departamento || '';
    form.distrito.value = editData.distrito || '';
    form.domicilio.value = editData.domicilio || '';
    form.ruc.disabled = true;
    form.dataset.editing = '1';
  } else {
    document.getElementById('empresa-form-title').textContent = 'Crear Empresa';
    form.ruc.disabled = false;
    delete form.dataset.editing;
  }
}

function hideEmpresaForm() {
  document.getElementById('empresa-form-container').style.display = 'none';
}

async function loadEmpresas(query = '') {
  try {
    const url = new URL(`${API_BASE_URL}/empresa`);
    const res = await fetch(url);
    const j = await res.json();
    if (!j.ok) { showMessage(MSG_IDS.empresas, j.error || 'Error cargando empresas', 'error'); return; }

    let rows = Array.isArray(j.data) ? j.data : (j.data || []);
    if (query) {
      const q = query.toLowerCase();
      rows = rows.filter(r =>
        String(r.ruc).includes(query) ||
        (r.razon_social && r.razon_social.toLowerCase().includes(q))
      );
    }

    const cols = [
      { key: 'ruc', label: 'RUC' },
      { key: 'razon_social', label: 'Razón Social' },
      { key: 'departamento', label: 'Departamento' },
      { key: 'distrito', label: 'Distrito' }
    ];
    renderTable('empresa-list', cols, rows, (row) => `
      <button onclick='editEmpresa(${JSON.stringify(row)})'>Editar</button>
      <button onclick='deleteEmpresa("${row.ruc}")'>Borrar</button>
    `);
  } catch (err) {
    console.error(err);
    showMessage(MSG_IDS.empresas, 'Error de conexión', 'error');
  }
}

window.editEmpresa = function(row) { showEmpresaForm(row); };

document.getElementById('form-empresa')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const editing = form.dataset.editing;
  const data = getFormData('form-empresa');
  try {
    if (editing) {
      const ruc = form.ruc.value;
      const res = await fetch(`${API_BASE_URL}/empresa/${ruc}`, { method: 'PUT', headers: {'Content-Type':'application/json'}, body: JSON.stringify(data) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.empresas, j.message || 'Empresa actualizada', 'success'); hideEmpresaForm(); loadEmpresas(); }
      else showMessage(MSG_IDS.empresas, j.error || 'Error', 'error');
    } else {
      const res = await fetch(`${API_BASE_URL}/empresa`, { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(data) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.empresas, j.message || 'Empresa creada', 'success'); hideEmpresaForm(); loadEmpresas(); }
      else showMessage(MSG_IDS.empresas, j.error || 'Error', 'error');
    }
  } catch (err) {
    console.error(err); showMessage(MSG_IDS.empresas, 'Error de conexión', 'error');
  }
});

async function deleteEmpresa(ruc) {
  if (!confirm(`Desactivar empresa ${ruc}?`)) return;
  try {
    const res = await fetch(`${API_BASE_URL}/empresa/${ruc}`, { method: 'DELETE', headers: {'Content-Type':'application/json'}, body: JSON.stringify({ usuario: DEFAULT_USER }) });
    const j = await res.json();
    if (j.ok) { showMessage(MSG_IDS.empresas, j.message || 'Empresa desactivada', 'success'); loadEmpresas(); }
    else showMessage(MSG_IDS.empresas, j.error || 'Error', 'error');
  } catch (err) { console.error(err); showMessage(MSG_IDS.empresas, 'Error de conexión', 'error'); }
}

function searchEmpresas() {
  const q = document.getElementById('empresa-search').value.trim();
  loadEmpresas(q);
}

// ============================================================================
// CONDUCTORES
// ============================================================================

function showConductorForm(editData) {
  document.getElementById('conductor-form-container').style.display = 'block';
  const form = document.getElementById('form-conductor');
  form.reset();
  if (editData) {
    document.getElementById('conductor-form-title').textContent = 'Editar Conductor';
    form.dni_conductor.value = editData.dni_conductor;
    form.nombre_conductor.value = editData.nombre_conductor || '';
    form.numero_licencia_conductor.value = editData.numero_licencia_conductor || '';
    form.dni_conductor.disabled = true;
    form.dataset.editing = '1';
  } else {
    document.getElementById('conductor-form-title').textContent = 'Crear Conductor';
    form.dni_conductor.disabled = false;
    delete form.dataset.editing;
  }
}

function hideConductorForm() { document.getElementById('conductor-form-container').style.display = 'none'; }

async function loadConductores(query = '') {
  try {
    const url = new URL(`${API_BASE_URL}/conductor`);
    const res = await fetch(url);
    const j = await res.json();
    if (!j.ok) { showMessage(MSG_IDS.conductores, j.error || 'Error cargando conductores', 'error'); return; }

    let rows = Array.isArray(j.data) ? j.data : (j.data || []);
    if (query) {
      const q = query.toLowerCase();
      rows = rows.filter(c =>
        String(c.dni_conductor).includes(query) ||
        (c.nombre_conductor && c.nombre_conductor.toLowerCase().includes(q))
      );
    }

    const cols = [{key:'dni_conductor',label:'DNI'},{key:'nombre_conductor',label:'Nombre'},{key:'numero_licencia_conductor',label:'Licencia'}];
    renderTable('conductor-list', cols, rows, (row) => `
      <button onclick='editConductor(${JSON.stringify(row)})'>Editar</button>
      <button onclick='deleteConductor("${row.dni_conductor}")'>Borrar</button>
    `);
  } catch (err) { console.error(err); showMessage(MSG_IDS.conductores,'Error conexión','error'); }
}

window.editConductor = function(row) { showConductorForm(row); };

document.getElementById('form-conductor')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const editing = form.dataset.editing;
  const data = getFormData('form-conductor');
  try {
    if (editing) {
      const dni = form.dni_conductor.value;
      const res = await fetch(`${API_BASE_URL}/conductor/${dni}`, { method: 'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.conductores, j.message || 'Conductor actualizado', 'success'); hideConductorForm(); loadConductores(); } else showMessage(MSG_IDS.conductores, j.error || 'Error', 'error');
    } else {
      const res = await fetch(`${API_BASE_URL}/conductor`, { method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.conductores, j.message || 'Conductor creado', 'success'); hideConductorForm(); loadConductores(); } else showMessage(MSG_IDS.conductores, j.error || 'Error', 'error');
    }
  } catch (err) { console.error(err); showMessage(MSG_IDS.conductores,'Error conexión','error'); }
});

async function deleteConductor(dni) {
  if (!confirm(`Desactivar conductor ${dni}?`)) return;
  try {
    const res = await fetch(`${API_BASE_URL}/conductor/${dni}`, { method: 'DELETE', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ usuario: DEFAULT_USER }) });
    const j = await res.json();
    if (j.ok) { showMessage(MSG_IDS.conductores, j.message || 'Conductor desactivado', 'success'); loadConductores(); } else showMessage(MSG_IDS.conductores, j.error || 'Error', 'error');
  } catch (err) { console.error(err); showMessage(MSG_IDS.conductores,'Error conexión','error'); }
}

function searchConductores() { loadConductores(document.getElementById('conductor-search').value.trim()); }

// ============================================================================
// VEHÍCULOS (TRACTO + SEMIRREMOLQUE COMBINADO)
// ============================================================================

async function loadVehiculos(query = '') {
  try {
    const url = new URL(`${API_BASE_URL}/vehiculos`);
    const res = await fetch(url);
    const j = await res.json();
    if (!j.ok) { showMessage(MSG_IDS.vehiculos, j.error || 'Error cargando vehículos', 'error'); return; }

    let tractos = [], semis = [];
    if (Array.isArray(j.data)) {
      // Si API devolvió array, asumimos tractos en array (compatibilidad)
      tractos = j.data;
    } else {
      tractos = j.data?.tractos || [];
      semis = j.data?.semirremolques || j.data?.semis || [];
    }

    const combined = [];
    tractos.forEach(t => combined.push({
      placa: t.placa_tracto,
      tipo: 'TR',
      marca: t.marca_unidad || '',
      certificado: t.certificado_inscripcion || ''
    }));
    semis.forEach(s => combined.push({
      placa: s.placa_semirremolque,
      tipo: 'SR',
      marca: s.marca_unir || '',
      certificado: s.certificado_inscripcion_semiremolque || ''
    }));

    let rows = combined;
    if (query) {
      const q = query.toLowerCase();
      rows = combined.filter(r => (r.placa || '').toLowerCase().includes(q));
    }

    renderTable('vehiculo-list', [
      { key: 'placa', label: 'Placa' },
      { key: 'tipo', label: 'Tipo' },
      { key: 'marca', label: 'Marca/Certificado' }
    ], rows, (row) => `
      <button onclick='editVehiculo("${row.placa}", "${row.tipo}")'>Editar</button>
      <button onclick='deleteVehiculo("${row.placa}", "${row.tipo}")'>Borrar</button>
    `);
  } catch (err) { console.error(err); showMessage(MSG_IDS.vehiculos, 'Error conexión', 'error'); }
}

window.editVehiculo = async function(placa, tipoHint) {
  try {
    const url = new URL(`${API_BASE_URL}/vehiculos`);
    url.searchParams.append('placa', placa);
    const res = await fetch(url);
    const j = await res.json();
    if (!j.ok) { showMessage(MSG_IDS.vehiculos, j.error || 'Error', 'error'); return; }

    const data = j.data || {};
    if (data.tracto || data.semirremolque || data.tracto === null) {
      if (data.tracto) showTractoForm(data.tracto);
      else if (data.semirremolque) showSemirremolqueForm(data.semirremolque);
      else showMessage(MSG_IDS.vehiculos, 'Vehículo no encontrado', 'error');
      return;
    }

    // Si API devolvió directamente un objeto con campos de tracto/semiremolque
    if (data.placa_tracto || data.placa_semirremolque) {
      if (data.placa_tracto) showTractoForm(data);
      else showSemirremolqueForm(data);
      return;
    }

    // fallback: recargar lista y mostrar error
    await loadVehiculos();
    showMessage(MSG_IDS.vehiculos, 'No se encontró el vehículo para editar', 'error');
  } catch (err) { console.error(err); showMessage(MSG_IDS.vehiculos, 'Error conexión', 'error'); }
};

document.getElementById('form-tracto')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const data = getFormData('form-tracto');
  const editing = e.target.dataset.editing;
  try {
    if (editing) {
      const placa = e.target.placa_tracto.value;
      const payload = { ...data, type: 'tracto' };
      const res = await fetch(`${API_BASE_URL}/vehiculos/${placa}`, { method: 'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.vehiculos, j.message || 'Tracto actualizado', 'success'); hideTractoForm(); loadVehiculos(); } else showMessage(MSG_IDS.vehiculos, j.error || 'Error', 'error');
    } else {
      const payload = { ...data, type: 'tracto' };
      const res = await fetch(`${API_BASE_URL}/vehiculos`, { method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.vehiculos, j.message || 'Tracto creado', 'success'); hideTractoForm(); loadVehiculos(); } else showMessage(MSG_IDS.vehiculos, j.error || 'Error', 'error');
    }
  } catch (err) { console.error(err); showMessage(MSG_IDS.vehiculos,'Error conexión','error'); }
});

document.getElementById('form-semirremolque')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const data = getFormData('form-semirremolque');
  const editing = e.target.dataset.editing;
  try {
    if (editing) {
      const placa = e.target.placa_semirremolque.value;
      const payload = { ...data, type: 'semirremolque' };
      const res = await fetch(`${API_BASE_URL}/vehiculos/${placa}`, { method: 'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.vehiculos, j.message || 'Semirremolque actualizado', 'success'); hideSemirremolqueForm(); loadVehiculos(); } else showMessage(MSG_IDS.vehiculos, j.error || 'Error', 'error');
    } else {
      const payload = { ...data, type: 'semirremolque' };
      const res = await fetch(`${API_BASE_URL}/vehiculos`, { method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.vehiculos, j.message || 'Semirremolque creado', 'success'); hideSemirremolqueForm(); loadVehiculos(); } else showMessage(MSG_IDS.vehiculos, j.error || 'Error', 'error');
    }
  } catch (err) { console.error(err); showMessage(MSG_IDS.vehiculos,'Error conexión','error'); }
});

function showTractoForm(editData) {
  document.getElementById('tracto-form-container').style.display = 'block';
  const form = document.getElementById('form-tracto');
  form.reset();
  if (editData) {
    form.placa_tracto.value = editData.placa_tracto;
    form.marca_unidad.value = editData.marca_unidad || '';
    form.certificado_inscripcion.value = editData.certificado_inscripcion || '';
    form.placa_tracto.disabled = true;
    form.dataset.editing = '1';
  } else { form.placa_tracto.disabled = false; delete form.dataset.editing; }
}
function hideTractoForm() { document.getElementById('tracto-form-container').style.display = 'none'; }

function showSemirremolqueForm(editData) {
  document.getElementById('semirremolque-form-container').style.display = 'block';
  const form = document.getElementById('form-semirremolque');
  form.reset();
  if (editData) {
    form.placa_semirremolque.value = editData.placa_semirremolque;
    form.certificado_inscripcion_semiremolque.value = editData.certificado_inscripcion_semiremolque || '';
    form.placa_semirremolque.disabled = true;
    form.dataset.editing = '1';
  } else { form.placa_semirremolque.disabled = false; delete form.dataset.editing; }
}
function hideSemirremolqueForm() { document.getElementById('semirremolque-form-container').style.display = 'none'; }

async function deleteVehiculo(placa, tipo) {
  if (!confirm(`Desactivar ${tipo==='TR'?'Tracto':'Semirremolque'} ${placa}?`)) return;
  try {
    const endpoint = (tipo === 'TR') ? 'tracto' : 'semirremolque';
    let res = await fetch(`${API_BASE_URL}/${endpoint}/${placa}`, {
      method: 'DELETE',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({ usuario: DEFAULT_USER })
    });

    if (res.status === 404 || (res.status >= 400 && res.status < 500)) {
      res = await fetch(`${API_BASE_URL}/vehiculos/${placa}`, {
        method: 'DELETE',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({ usuario: DEFAULT_USER, type: (tipo === 'TR' ? 'tracto' : 'semirremolque') })
      });
    }

    const j = await res.json();
    if (j.ok) { showMessage(MSG_IDS.vehiculos, j.message || 'Vehículo desactivado', 'success'); loadVehiculos(); } else showMessage(MSG_IDS.vehiculos, j.error || 'Error', 'error');
  } catch (err) { console.error(err); showMessage(MSG_IDS.vehiculos,'Error conexión','error'); }
}

function searchVehiculos() { loadVehiculos(document.getElementById('vehiculo-search').value.trim()); }

// ============================================================================
// PRODUCTOS
// ============================================================================

function showProductoForm(editData) {
  document.getElementById('producto-form-container').style.display = 'block';
  const form = document.getElementById('form-producto');
  form.reset();
  if (editData) {
    document.getElementById('producto-form-title').textContent = 'Editar Producto';
    form.codigo_producto.value = editData.codigo_producto;
    form.lote.value = editData.lote || '';
    form.descripcion.value = editData.descripcion || '';
    form.material.value = editData.material || '';
    form.unidad_medida.value = editData.unidad_medida || '';
    form.peso_bruto.value = editData.peso_bruto || 0;
    form.codigo_producto.disabled = true;
    form.dataset.editing = '1';
  } else {
    document.getElementById('producto-form-title').textContent = 'Crear Producto';
    form.codigo_producto.disabled = false;
    delete form.dataset.editing;
  }
}
function hideProductoForm() { document.getElementById('producto-form-container').style.display = 'none'; }

async function loadProductos(query = '') {
  try {
    const url = new URL(`${API_BASE_URL}/producto`);
    const res = await fetch(url);
    const j = await res.json();
    if (!j.ok) { showMessage(MSG_IDS.productos, j.error || 'Error cargando productos', 'error'); return; }

    let rows = Array.isArray(j.data) ? j.data : (j.data || []);
    if (query) {
      const q = query.toLowerCase();
      rows = rows.filter(p =>
        (p.codigo_producto && p.codigo_producto.toLowerCase().includes(q)) ||
        (p.descripcion && p.descripcion.toLowerCase().includes(q))
      );
    }

    const cols = [
      {key:'codigo_producto',label:'Código'},
      {key:'descripcion',label:'Descripción'},
      {key:'material',label:'Material'},
      {key:'unidad_medida',label:'Unidad'},
      {key:'peso_bruto',label:'Peso'}
    ];
    renderTable('producto-list', cols, rows, (row) => `
      <button onclick='editProducto(${JSON.stringify(row)})'>Editar</button>
      <button onclick='deleteProducto("${row.codigo_producto}")'>Borrar</button>
    `);
  } catch (err) { console.error(err); showMessage(MSG_IDS.productos,'Error conexión','error'); }
}

window.editProducto = function(row) { showProductoForm(row); };

document.getElementById('form-producto')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  const editing = form.dataset.editing;
  const data = getFormData('form-producto');
  try {
    if (editing) {
      const codigo = form.codigo_producto.value;
      const res = await fetch(`${API_BASE_URL}/producto/${codigo}`, { method: 'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.productos, j.message || 'Producto actualizado', 'success'); hideProductoForm(); loadProductos(); } else showMessage(MSG_IDS.productos, j.error || 'Error', 'error');
    } else {
      const res = await fetch(`${API_BASE_URL}/producto`, { method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) });
      const j = await res.json();
      if (j.ok) { showMessage(MSG_IDS.productos, j.message || 'Producto creado', 'success'); hideProductoForm(); loadProductos(); } else showMessage(MSG_IDS.productos, j.error || 'Error', 'error');
    }
  } catch (err) { console.error(err); showMessage(MSG_IDS.productos,'Error conexión','error'); }
});

async function deleteProducto(codigo) {
  if (!confirm(`Desactivar producto ${codigo}?`)) return;
  try {
    const res = await fetch(`${API_BASE_URL}/producto/${codigo}`, { method: 'DELETE', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ usuario: DEFAULT_USER }) });
    const j = await res.json();
    if (j.ok) { showMessage(MSG_IDS.productos, j.message || 'Producto desactivado', 'success'); loadProductos(); } else showMessage(MSG_IDS.productos, j.error || 'Error', 'error');
  } catch (err) { console.error(err); showMessage(MSG_IDS.productos,'Error conexión','error'); }
}

function searchProductos() { loadProductos(document.getElementById('producto-search').value.trim()); }

// ============================================================================
// Inicialización
// ============================================================================

document.addEventListener('DOMContentLoaded', () => {
  // attach Enter key for search inputs
  attachEnterToSearch('empresa-search', searchEmpresas);
  attachEnterToSearch('conductor-search', searchConductores);
  attachEnterToSearch('vehiculo-search', searchVehiculos);
  attachEnterToSearch('producto-search', searchProductos);

  // Carga inicial
  loadGRList();
  loadEmpresas();
  loadConductores();
  loadVehiculos();
  loadProductos();
});
