<template>
  <div class="db-explorer">
    <div class="explorer-header">
      <h3>
        <Table2 :size="18" />
        Explorador de Tabelas
      </h3>
      <div class="controls">
        <button class="btn" @click="loadTables" :disabled="loadingTables">
          <RefreshCw :size="16" :class="{ 'animate-spin': loadingTables }" />
          Atualizar
        </button>
      </div>
    </div>

    <div class="explorer-toolbar">
      <div class="field">
        <label>Tabela</label>
        <select v-model="selectedTable" @change="onChangeTable">
          <option v-for="t in tables" :key="t" :value="t">{{ t }}</option>
        </select>
      </div>

      <div class="field grow">
        <label>Busca rápida</label>
        <input v-model="searchText" type="text" placeholder="Buscar texto em colunas comuns (nome, email, status, ...)" @keyup.enter="runQuery" />
      </div>

      <div class="field">
        <label>Ordenar por</label>
        <select v-model="orderBy.column">
          <option v-for="c in columns" :key="c" :value="c">{{ c }}</option>
        </select>
      </div>

      <div class="field small">
        <label>Ordem</label>
        <select v-model="orderBy.ascending">
          <option :value="true">Asc</option>
          <option :value="false">Desc</option>
        </select>
      </div>

      <div class="field small">
        <label>Limite</label>
        <input v-model.number="limit" type="number" min="5" max="200" />
      </div>

      <div class="actions">
        <button class="btn primary" @click="runQuery" :disabled="loading">Consultar</button>
        <button class="btn" @click="exportCSV" :disabled="loading || rows.length===0 || exportLoading">Exportar CSV</button>
        <button class="btn" @click="exportJSON" :disabled="loading || rows.length===0 || exportLoading">Exportar JSON</button>
        <button class="btn" @click="exportAllCSV" :disabled="loading || exportLoading">Exportar Tudo (CSV)</button>
        <button class="btn" @click="exportAllJSON" :disabled="loading || exportLoading">Exportar Tudo (JSON)</button>
        <button class="btn" @click="exportXLSX" :disabled="loading || rows.length===0 || exportLoading">Exportar XLSX</button>
        <button class="btn" @click="exportAllXLSX" :disabled="loading || exportLoading">Exportar Tudo (XLSX)</button>
        <button class="btn" @click="copyQuery">Copiar Consulta</button>
      </div>
    </div>

    <div class="filters">
      <div class="filters-header">
        <strong>Filtros avançados</strong>
        <button class="link" @click="addFilter">+ adicionar</button>
      </div>
      <div class="filters-grid" v-if="filters.length">
        <div v-for="(f, i) in filters" :key="i" class="filter-row">
          <select v-model="f.column">
            <option v-for="c in columns" :key="c" :value="c">{{ c }}</option>
          </select>
          <select v-model="f.operator">
            <option v-for="op in operatorOptions(f.column)" :key="op.v" :value="op.v">{{ op.l }}</option>
          </select>
          <template v-if="getColumnKind(f.column) === 'number' && f.operator !== 'between'">
            <input v-model.number="f.value" type="number" />
          </template>
          <template v-else-if="getColumnKind(f.column) === 'date' && f.operator !== 'between'">
            <input v-model="f.value" type="date" />
          </template>
          <template v-else-if="getColumnKind(f.column) === 'boolean'">
            <select v-model="f.value">
              <option :value="true">true</option>
              <option :value="false">false</option>
            </select>
          </template>
          <template v-else-if="f.operator === 'between'">
            <div class="between">
              <input :type="getColumnKind(f.column)==='date' ? 'date' : 'number'" v-model="f.value" />
              <span>e</span>
              <input :type="getColumnKind(f.column)==='date' ? 'date' : 'number'" v-model="f.value2" />
            </div>
          </template>
          <template v-else>
            <input v-model="f.value" type="text" />
          </template>
          <button class="link danger" @click="removeFilter(i)">remover</button>
        </div>
      </div>
    </div>

    <div class="export-settings">
      <div class="setting">
        <label>Limite de exportação</label>
        <select v-model.number="exportLimit">
          <option :value="100">100</option>
          <option :value="500">500</option>
          <option :value="1000">1000</option>
        </select>
      </div>
      <div class="setting grow">
        <label>Colunas para exportação</label>
        <div class="cols-picker">
          <select multiple v-model="selectedExportColumns">
            <option v-for="c in columns" :key="c" :value="c">{{ c }}</option>
          </select>
          <div class="cols-actions">
            <button class="link" type="button" @click="selectAllColumns">Selecionar todos</button>
            <button class="link" type="button" @click="clearSelectedColumns">Limpar</button>
          </div>
        </div>
      </div>
    </div>

    <div class="saved-queries">
      <div class="setting grow">
        <label>Salvar consulta atual</label>
        <div class="save-row">
          <input v-model="savedName" type="text" placeholder="Nome da consulta (ex.: Produtos ativos ordenados)" />
          <button class="btn" @click="saveCurrentQuery" :disabled="!selectedTable || !savedName.trim()">Salvar</button>
        </div>
      </div>
      <div class="setting grow">
        <label>Consultas salvas</label>
        <div class="load-row">
          <select v-model="selectedSavedId">
            <option v-for="q in savedQueries" :key="q.id" :value="q.id">
              {{ q.name }} • {{ new Date(q.createdAt).toLocaleString() }}
            </option>
          </select>
          <button class="btn" @click="loadSavedQuery" :disabled="!selectedSavedId">Carregar</button>
          <button class="btn" @click="deleteSavedQuery" :disabled="!selectedSavedId">Excluir</button>
          <button class="btn" @click="copyShareLink()">Copiar Link</button>
          <button class="btn" @click="fixShareLink()">Aplicar e Fixar Link</button>
        </div>
        <div class="load-row">
          <input v-model="renameText" type="text" placeholder="Novo nome" />
          <button class="btn" @click="renameSavedQuery" :disabled="!selectedSavedId || !renameText.trim()">Renomear</button>
        </div>
      </div>
    </div>

    <div class="results" v-if="rows.length || loading">
      <div class="results-info">
        <span>{{ rows.length }} registros</span>
        <span v-if="total !== undefined">• total: {{ total }}</span>
      </div>
      <div class="table-wrapper">
        <table class="data-table">
          <thead>
            <tr>
              <th v-for="c in columns" :key="c">{{ c }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td :colspan="columns.length" class="loading-cell">
                <Loader2 :size="18" class="animate-spin" /> Carregando...
              </td>
            </tr>
            <tr v-for="(r, idx) in rows" :key="idx">
              <td v-for="c in columns" :key="c">
                <span class="cell" :title="formatCell(r[c])">{{ formatCell(r[c]) }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="pager">
        <button class="btn" @click="prevPage" :disabled="offset===0 || loading">Anterior</button>
        <span>Página {{ Math.floor(offset/limit)+1 }}</span>
        <button class="btn" @click="nextPage" :disabled="loading || (total!==undefined && offset+limit >= total)">Próxima</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Table2, RefreshCw, Loader2 } from 'lucide-vue-next'
import * as XLSX from 'xlsx'
import { databaseExplorerService, type ExplorerFilter, type ColumnMeta } from '@/services/databaseExplorerService'

const tables = ref<string[]>([])
const selectedTable = ref<string>('')
const columns = ref<string[]>([])
const columnsMeta = ref<ColumnMeta[]>([])
const searchText = ref('')
const orderBy = ref<{ column: string; ascending: boolean }>({ column: 'id', ascending: false })
const limit = ref(20)
const offset = ref(0)
const filters = ref<ExplorerFilter[]>([])

const rows = ref<any[]>([])
const total = ref<number | undefined>(undefined)
const loading = ref(false)
const loadingTables = ref(false)
const exportLoading = ref(false)
const exportLimit = ref(1000)
const selectedExportColumns = ref<string[]>([])
const lastQuery = ref<any>(null)
const savedQueries = ref<Array<{ id: string; name: string; createdAt: string; query: any }>>([])
const savedName = ref('')
const selectedSavedId = ref('')
const renameText = ref('')

function formatCell(val: any): string {
  if (val === null || val === undefined) return ''
  if (typeof val === 'object') return JSON.stringify(val)
  return String(val)
}

function getColumnKind(col: string) {
  return columnsMeta.value.find(c => c.name === col)?.kind || 'unknown'
}

function operatorOptions(col: string) {
  const kind = getColumnKind(col)
  if (kind === 'number' || kind === 'date') {
    return [
      { v: 'eq', l: '=' }, { v: 'gt', l: '>' }, { v: 'gte', l: '>=' }, { v: 'lt', l: '<' }, { v: 'lte', l: '<=' }, { v: 'between', l: 'entre' }, { v: 'is', l: 'é nulo' }, { v: 'notnull', l: 'não é nulo' }
    ]
  }
  if (kind === 'boolean') {
    return [ { v: 'eq', l: '=' }, { v: 'is', l: 'é nulo' }, { v: 'notnull', l: 'não é nulo' } ]
  }
  if (kind === 'json') {
    return [ { v: 'contains', l: 'contém JSON' }, { v: 'ilike', l: 'contém texto' } ]
  }
  return [ { v: 'eq', l: '=' }, { v: 'ilike', l: 'contém' }, { v: 'neq', l: '!=' }, { v: 'is', l: 'é nulo' }, { v: 'notnull', l: 'não é nulo' } ]
}

function addFilter() {
  const first = columns.value[0] || 'id'
  const kind = getColumnKind(first)
  const op = (kind === 'number' || kind === 'date') ? 'gte' : (kind === 'boolean' ? 'eq' : 'ilike')
  filters.value.push({ column: first, operator: op as any, value: '' })
}
function removeFilter(i: number) {
  filters.value.splice(i, 1)
}

async function loadTables() {
  loadingTables.value = true
  try {
    tables.value = await databaseExplorerService.getAllTables()
    if (!selectedTable.value && tables.value.length) {
      selectedTable.value = tables.value[0]
    }
  } finally {
    loadingTables.value = false
  }
  await onChangeTable()
}

async function onChangeTable() {
  if (!selectedTable.value) return
  columnsMeta.value = await databaseExplorerService.getColumnsMeta(selectedTable.value)
  columns.value = columnsMeta.value.map(c => c.name)
  if (!columns.value.includes(orderBy.value.column)) {
    orderBy.value.column = columns.value[0] || 'id'
  }
  offset.value = 0
  await runQuery()
}

async function runQuery() {
  if (!selectedTable.value) return
  loading.value = true
  try {
    const q = {
      table: selectedTable.value,
      filters: filters.value,
      searchText: searchText.value.trim() || undefined,
      orderBy: orderBy.value,
      limit: limit.value,
      offset: offset.value
    }
    lastQuery.value = q
    const res = await databaseExplorerService.query(q)
    rows.value = res.rows
    total.value = res.count
  } catch (e) {
    console.error('Erro ao consultar tabela:', e)
    rows.value = []
  } finally {
    loading.value = false
  }
}

async function prevPage() {
  offset.value = Math.max(0, offset.value - limit.value)
  await runQuery()
}
async function nextPage() {
  offset.value += limit.value
  await runQuery()
}

onMounted(loadTables)
onMounted(loadSavedQueries)
onMounted(applyQueryFromUrl)

function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  a.remove()
  URL.revokeObjectURL(url)
}

function exportCSV() {
  if (!rows.value.length) return
  const cols = selectedExportColumns.value.length ? selectedExportColumns.value : columns.value
  const csvRows = [] as string[]
  csvRows.push(cols.map(c => `"${c.replace(/"/g, '""')}"`).join(','))
  for (const r of rows.value) {
    const line = cols.map(c => {
      const v = r[c]
      const s = v === null || v === undefined ? '' : (typeof v === 'object' ? JSON.stringify(v) : String(v))
      return `"${s.replace(/"/g, '""')}"`
    }).join(',')
    csvRows.push(line)
  }
  const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const ts = new Date().toISOString().replace(/[:T]/g,'-').split('.')[0]
  downloadBlob(blob, `${selectedTable.value || 'dados'}-${ts}.csv`)
}

function exportJSON() {
  if (!rows.value.length) return
  const cols = selectedExportColumns.value.length ? selectedExportColumns.value : columns.value
  const sliced = rows.value.map((r) => {
    const obj: Record<string, any> = {}
    cols.forEach(c => { obj[c] = (r as any)[c] })
    return obj
  })
  const blob = new Blob([JSON.stringify(sliced, null, 2)], { type: 'application/json' })
  const ts = new Date().toISOString().replace(/[:T]/g,'-').split('.')[0]
  downloadBlob(blob, `${selectedTable.value || 'dados'}-${ts}.json`)
}

async function copyQuery() {
  const q = lastQuery.value || {
    table: selectedTable.value,
    filters: filters.value,
    searchText: searchText.value || undefined,
    orderBy: orderBy.value,
    limit: limit.value,
    offset: offset.value
  }
  try {
    await navigator.clipboard.writeText(JSON.stringify(q, null, 2))
    console.log('✅ Consulta copiada para a área de transferência')
  } catch (e) {
    console.warn('Falha ao copiar consulta:', e)
  }
}

async function exportAllCSV() {
  exportLoading.value = true
  try {
    const q = lastQuery.value || {
      table: selectedTable.value,
      filters: filters.value,
      searchText: searchText.value || undefined,
      orderBy: orderBy.value,
      limit: limit.value,
      offset: 0
    }
    const res = await databaseExplorerService.query({ ...q, limit: exportLimit.value, offset: 0 })
    const allRows = res.rows || []
    if (!allRows.length) return
    const cols = selectedExportColumns.value.length ? selectedExportColumns.value : (columns.value.length ? columns.value : Object.keys(allRows[0] || {}))
    const csvRows = [] as string[]
    csvRows.push(cols.map(c => `"${c.replace(/"/g, '""')}"`).join(','))
    for (const r of allRows) {
      const line = cols.map(c => {
        const v = r[c]
        const s = v === null || v === undefined ? '' : (typeof v === 'object' ? JSON.stringify(v) : String(v))
        return `"${s.replace(/"/g, '""')}"`
      }).join(',')
      csvRows.push(line)
    }
    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const ts = new Date().toISOString().replace(/[:T]/g,'-').split('.')[0]
    downloadBlob(blob, `${selectedTable.value || 'dados'}-ALL-${ts}.csv`)
  } finally {
    exportLoading.value = false
  }
}

async function exportAllJSON() {
  exportLoading.value = true
  try {
    const q = lastQuery.value || {
      table: selectedTable.value,
      filters: filters.value,
      searchText: searchText.value || undefined,
      orderBy: orderBy.value,
      limit: limit.value,
      offset: 0
    }
    const res = await databaseExplorerService.query({ ...q, limit: exportLimit.value, offset: 0 })
    const allRows = res.rows || []
    const cols = selectedExportColumns.value.length ? selectedExportColumns.value : (columns.value.length ? columns.value : (allRows[0] ? Object.keys(allRows[0]) : []))
    const sliced = allRows.map((r: any) => {
      const obj: Record<string, any> = {}
      cols.forEach((c: string) => { obj[c] = r[c] })
      return obj
    })
    const blob = new Blob([JSON.stringify(sliced, null, 2)], { type: 'application/json' })
    const ts = new Date().toISOString().replace(/[:T]/g,'-').split('.')[0]
    downloadBlob(blob, `${selectedTable.value || 'dados'}-ALL-${ts}.json`)
  } finally {
    exportLoading.value = false
  }
}

function buildWorkbookFromRows(rowsToExport: any[], cols: string[]) {
  const data = rowsToExport.map((r: any) => {
    const obj: Record<string, any> = {}
    const keys: string[] = (cols && cols.length ? cols : Object.keys(r || {})) as string[]
    keys.forEach((c: string) => {
      obj[c] = r[c]
    })
    return obj
  })
  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Dados')
  return wb
}

function exportXLSX() {
  if (!rows.value.length) return
  const cols = selectedExportColumns.value.length ? selectedExportColumns.value : columns.value
  const wb = buildWorkbookFromRows(rows.value, cols)
  const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([wbout], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
  const ts = new Date().toISOString().replace(/[:T]/g,'-').split('.')[0]
  downloadBlob(blob, `${selectedTable.value || 'dados'}-${ts}.xlsx`)
}

async function exportAllXLSX() {
  exportLoading.value = true
  try {
    const q = lastQuery.value || {
      table: selectedTable.value,
      filters: filters.value,
      searchText: searchText.value || undefined,
      orderBy: orderBy.value,
      limit: limit.value,
      offset: 0
    }
    const res = await databaseExplorerService.query({ ...q, limit: exportLimit.value, offset: 0 })
    const allRows = res.rows || []
    const cols = selectedExportColumns.value.length ? selectedExportColumns.value : (columns.value.length ? columns.value : (allRows[0] ? Object.keys(allRows[0]) : []))
    const wb = buildWorkbookFromRows(allRows, cols)
    const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
    const blob = new Blob([wbout], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const ts = new Date().toISOString().replace(/[:T]/g,'-').split('.')[0]
    downloadBlob(blob, `${selectedTable.value || 'dados'}-ALL-${ts}.xlsx`)
  } finally {
    exportLoading.value = false
  }
}

function loadSavedQueries() {
  try {
    const raw = localStorage.getItem('db_explorer_saved_queries')
    savedQueries.value = raw ? JSON.parse(raw) : []
  } catch {
    savedQueries.value = []
  }
}

function persistSavedQueries() {
  try {
    localStorage.setItem('db_explorer_saved_queries', JSON.stringify(savedQueries.value))
  } catch (e) {
    console.warn('Não foi possível salvar consultas localmente:', e)
  }
}

function buildCurrentQueryObject() {
  return {
    table: selectedTable.value,
    filters: filters.value,
    searchText: searchText.value.trim() || undefined,
    orderBy: orderBy.value,
    limit: limit.value,
    offset: 0,
    exportLimit: exportLimit.value,
    exportColumns: selectedExportColumns.value
  }
}

function saveCurrentQuery() {
  const name = savedName.value.trim()
  if (!name || !selectedTable.value) return
  const item = {
    id: `q_${Date.now()}_${Math.random().toString(36).slice(2,8)}`,
    name,
    createdAt: new Date().toISOString(),
    query: buildCurrentQueryObject()
  }
  savedQueries.value.unshift(item)
  persistSavedQueries()
  savedName.value = ''
  selectedSavedId.value = item.id
  console.log('✅ Consulta salva:', item)
}

async function loadSavedQuery() {
  const id = selectedSavedId.value
  const item = savedQueries.value.find(q => q.id === id)
  if (!item) return

  const q = item.query || {}
  if (!q.table) return

  // Aplicar tabela e metadados antes dos filtros
  selectedTable.value = q.table
  columnsMeta.value = await databaseExplorerService.getColumnsMeta(selectedTable.value)
  columns.value = columnsMeta.value.map(c => c.name)
  // Aplicar demais campos
  filters.value = Array.isArray(q.filters) ? q.filters : []
  searchText.value = q.searchText || ''
  orderBy.value = q.orderBy || orderBy.value
  limit.value = q.limit || limit.value
  offset.value = 0
  // Export prefs
  exportLimit.value = q.exportLimit || exportLimit.value
  selectedExportColumns.value = Array.isArray(q.exportColumns) ? q.exportColumns : []

  await runQuery()
}

function deleteSavedQuery() {
  const id = selectedSavedId.value
  const idx = savedQueries.value.findIndex(q => q.id === id)
  if (idx >= 0) {
    savedQueries.value.splice(idx, 1)
    persistSavedQueries()
    selectedSavedId.value = ''
  }
}

function renameSavedQuery() {
  const id = selectedSavedId.value
  const item = savedQueries.value.find(q => q.id === id)
  const name = renameText.value.trim()
  if (item && name) {
    item.name = name
    persistSavedQueries()
    renameText.value = ''
  }
}

function copyShareLink() {
  // Usa consulta salva selecionada se houver, senão a consulta atual
  let q: any
  const selected = savedQueries.value.find(qi => qi.id === selectedSavedId.value)
  if (selected) q = selected.query
  else q = buildCurrentQueryObject()

  try {
    const enc = encodeURIComponent(btoa(unescape(encodeURIComponent(JSON.stringify(q)))))
    const url = new URL(window.location.href)
    url.searchParams.set('dbq', enc)
    navigator.clipboard.writeText(url.toString())
    console.log('✅ Link copiado: ', url.toString())
  } catch (e) {
    console.warn('Falha ao copiar link:', e)
  }
}

async function applyQueryFromUrl() {
  try {
    const url = new URL(window.location.href)
    const param = url.searchParams.get('dbq')
    if (!param) return
    const json = decodeURIComponent(escape(atob(decodeURIComponent(param))))
    const q = JSON.parse(json)
    await applyQueryObject(q)
    await runQuery()
  } catch (e) {
    console.warn('Não foi possível aplicar consulta da URL:', e)
  }
}

async function applyQueryObject(q: any) {
  if (!q || !q.table) return
  selectedTable.value = q.table
  columnsMeta.value = await databaseExplorerService.getColumnsMeta(selectedTable.value)
  columns.value = columnsMeta.value.map(c => c.name)
  filters.value = Array.isArray(q.filters) ? q.filters : []
  searchText.value = q.searchText || ''
  orderBy.value = q.orderBy || orderBy.value
  limit.value = q.limit || limit.value
  offset.value = q.offset || 0
  exportLimit.value = q.exportLimit || exportLimit.value
  selectedExportColumns.value = Array.isArray(q.exportColumns) ? q.exportColumns : []
}

function fixShareLink() {
  // Usa consulta salva selecionada se houver, senão a consulta atual
  let q: any
  const selected = savedQueries.value.find(qi => qi.id === selectedSavedId.value)
  if (selected) q = selected.query
  else q = buildCurrentQueryObject()

  try {
    const enc = encodeURIComponent(btoa(unescape(encodeURIComponent(JSON.stringify(q)))))
    const url = new URL(window.location.href)
    url.searchParams.set('dbq', enc)
    // Atualiza a URL atual sem recarregar a página
    window.history.replaceState(null, '', url.toString())
    console.log('✅ Link fixado na URL')
  } catch (e) {
    console.warn('Falha ao fixar link:', e)
  }
}

function selectAllColumns() {
  selectedExportColumns.value = [...columns.value]
}

function clearSelectedColumns() {
  selectedExportColumns.value = []
}
</script>

<style scoped>
.db-explorer { border-top: 1px solid rgba(226,232,240,0.5); padding-top: 20px; display:flex; flex-direction:column; gap:16px; }
.explorer-header { display:flex; align-items:center; justify-content:space-between; }
.explorer-header h3 { display:flex; gap:8px; align-items:center; margin:0; font-size:16px; font-weight:700; color:var(--theme-text-primary,#1a202c); }
.controls { display:flex; gap:8px; }
.btn { display:flex; gap:8px; align-items:center; padding:8px 12px; border:1px solid var(--theme-border,#e2e8f0); background:#fff; border-radius:8px; cursor:pointer; }
.btn.primary { background:#4f46e5; border-color:#4f46e5; color:#fff; }
.btn:disabled { opacity:0.6; cursor:not-allowed; }
.explorer-toolbar { display:grid; grid-template-columns: 220px 1fr 220px 120px 100px auto; gap:12px; }
.field { display:flex; flex-direction:column; gap:6px; }
.field.grow { grid-column: span 1; }
.field.small input, .field.small select { width: 100%; }
label { font-size:12px; color:var(--theme-text-secondary,#64748b); font-weight:600; text-transform:uppercase; letter-spacing:0.5px; }
input, select { padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; background:#fff; }
.actions { display:flex; align-items:flex-end; }
.filters { background: rgba(248,250,252,0.6); border:1px solid rgba(226,232,240,0.6); padding:12px; border-radius:12px; }
.filters-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; }
.filters-grid { display:flex; flex-direction:column; gap:8px; }
.filter-row { display:grid; grid-template-columns: 1fr 120px 1fr 100px; gap:8px; }
.link { background:none; border:none; color:#4f46e5; cursor:pointer; padding:0; }
.link.danger { color:#dc2626; }
.export-settings { display:flex; gap:12px; align-items:flex-end; background: rgba(248,250,252,0.6); border:1px solid rgba(226,232,240,0.6); padding:12px; border-radius:12px; }
.setting { display:flex; flex-direction:column; gap:6px; }
.setting.grow { flex:1; }
.cols-picker { display:flex; gap:8px; align-items:flex-start; }
.cols-picker select { min-width: 240px; min-height: 96px; }
.cols-actions { display:flex; gap:8px; align-items:center; }
.saved-queries { display:flex; gap:12px; background: rgba(248,250,252,0.6); border:1px solid rgba(226,232,240,0.6); padding:12px; border-radius:12px; }
.save-row, .load-row { display:flex; gap:8px; }
.saved-queries select { min-width: 280px; }
.results-info { display:flex; gap:8px; color:#64748b; font-size:13px; }
.table-wrapper { overflow:auto; border:1px solid #e2e8f0; border-radius:12px; }
table { width:100%; border-collapse:collapse; }
th, td { padding:10px 12px; border-bottom:1px solid #eef2f7; text-align:left; font-size:13px; }
th { position:sticky; top:0; background:#f8fafc; z-index:1; }
.cell { display:inline-block; max-width:260px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.pager { display:flex; gap:12px; align-items:center; justify-content:flex-end; padding-top:8px; }
.loading-cell { text-align:center; color:#64748b; }
</style>
