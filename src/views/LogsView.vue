<template>
  <div class="logs-view">
    <div class="logs-header">
      <h1>📊 Logs do Sistema</h1>
      <p>Histórico completo de atividades e movimentações</p>
    </div>

    <div class="logs-filters">
      <div class="filter-group">
        <label>Tipo de Log:</label>
        <select v-model="selectedType" @change="filterLogs">
          <option value="all">Todos</option>
          <option value="inventory">Estoque</option>
          <option value="sales">Vendas</option>
          <option value="users">Usuários</option>
          <option value="system">Sistema</option>
        </select>
      </div>

      <div class="filter-group">
        <label>Data Inicial:</label>
        <input type="date" v-model="startDate" @change="filterLogs">
      </div>

      <div class="filter-group">
        <label>Data Final:</label>
        <input type="date" v-model="endDate" @change="filterLogs">
      </div>

      <div class="filter-group">
        <button @click="clearFilters" class="clear-filters-btn">
          Limpar Filtros
        </button>
      </div>
    </div>

    <div class="logs-stats">
      <div class="stat-card">
        <div class="stat-icon">📝</div>
        <div class="stat-info">
          <h3>{{ stats.totalLogs }}</h3>
          <p>Total de Logs</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">📈</div>
        <div class="stat-info">
          <h3>{{ stats.todayLogs }}</h3>
          <p>Logs de Hoje</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">⚠️</div>
        <div class="stat-info">
          <h3>{{ stats.errorLogs }}</h3>
          <p>Erros</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">✅</div>
        <div class="stat-info">
          <h3>{{ stats.successLogs }}</h3>
          <p>Sucessos</p>
        </div>
      </div>
    </div>

    <div class="logs-table-container">
      <div class="table-header">
        <h2>Registro de Atividades</h2>
        <div class="table-actions">
          <button @click="exportLogs" class="export-btn">
            📤 Exportar CSV
          </button>
          <button @click="refreshLogs" class="refresh-btn">
            🔄 Atualizar
          </button>
        </div>
      </div>

      <div class="logs-table">
        <table>
          <thead>
            <tr>
              <th>Data/Hora</th>
              <th>Tipo</th>
              <th>Ação</th>
              <th>Usuário</th>
              <th>Detalhes</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="log in filteredLogs" :key="log.id" :class="getLogRowClass(log.level)">
              <td class="datetime-cell">
                {{ formatDateTime(log.created_at) }}
              </td>
              <td>
                <span :class="getTypeClass(log.type)">
                  {{ getTypeIcon(log.type) }} {{ log.type }}
                </span>
              </td>
              <td class="action-cell">{{ log.action }}</td>
              <td class="user-cell">{{ log.user_name || 'Sistema' }}</td>
              <td class="details-cell">
                <div class="details-content" v-html="formatDetails(log.details)"></div>
              </td>
              <td>
                <span :class="getStatusClass(log.level)">
                  {{ getStatusIcon(log.level) }} {{ log.level }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>

        <div v-if="isLoading" class="loading-state">
          <div class="spinner"></div>
          <p>Carregando logs...</p>
        </div>

        <div v-else-if="filteredLogs.length === 0" class="empty-state">
          <div class="empty-icon">📋</div>
          <h3>Nenhum log encontrado</h3>
          <p>Não há registros para os filtros selecionados</p>
        </div>
      </div>

      <div class="pagination" v-if="totalPages > 1">
        <button
          @click="goToPage(currentPage - 1)"
          :disabled="currentPage === 1"
          class="page-btn"
        >
          ← Anterior
        </button>

        <span class="page-info">
          Página {{ currentPage }} de {{ totalPages }}
        </span>

        <button
          @click="goToPage(currentPage + 1)"
          :disabled="currentPage === totalPages"
          class="page-btn"
        >
          Próxima →
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { logsService, type LogEntry, type LogStats } from '@/services/logsService'

const logs = ref<LogEntry[]>([])
const stats = ref<LogStats>({
  totalLogs: 0,
  todayLogs: 0,
  errorLogs: 0,
  warningLogs: 0,
  successLogs: 0,
  infoLogs: 0,
  logsByType: {},
  logsByLevel: {}
})
const isLoading = ref(false)
const selectedType = ref('all')
const startDate = ref('')
const endDate = ref('')
const currentPage = ref(1)
const itemsPerPage = 50
const totalLogs = ref(0)

const filteredLogs = computed(() => {
  return logs.value
})

const totalPages = computed(() => {
  return Math.ceil(totalLogs.value / itemsPerPage)
})

const loadLogs = async () => {
  isLoading.value = true
  try {
    const filters = {
      type: selectedType.value !== 'all' ? selectedType.value : undefined,
      startDate: startDate.value || undefined,
      endDate: endDate.value || undefined,
      page: currentPage.value,
      limit: itemsPerPage
    }

    const [logsResult, statsResult] = await Promise.all([
      logsService.getLogs(filters),
      logsService.getLogStats()
    ])

    logs.value = logsResult.logs
    totalLogs.value = logsResult.total
    stats.value = statsResult

    console.log('Logs carregados:', logs.value.length)
  } catch (error) {
    console.error('Erro ao carregar logs:', error)
  } finally {
    isLoading.value = false
  }
}

const filterLogs = () => {
  currentPage.value = 1
  loadLogs()
}

const clearFilters = () => {
  selectedType.value = 'all'
  startDate.value = ''
  endDate.value = ''
  currentPage.value = 1
}

const refreshLogs = () => {
  loadLogs()
}

const exportLogs = async () => {
  try {
    const filters = {
      type: selectedType.value !== 'all' ? selectedType.value : undefined,
      startDate: startDate.value || undefined,
      endDate: endDate.value || undefined
    }

    const blob = await logsService.exportLogs(filters, 'csv')
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `logs-${new Date().toISOString().split('T')[0]}.csv`
    a.click()
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Erro ao exportar logs:', error)
  }
}

const goToPage = (page: number) => {
  currentPage.value = page
  loadLogs()
}

const formatDateTime = (dateString: string) => {
  return new Date(dateString).toLocaleString('pt-BR')
}

const formatDetails = (details: any) => {
  if (!details) return '-'

  if (typeof details === 'string') return details

  if (typeof details === 'object') {
    return Object.entries(details)
      .map(([key, value]) => `<strong>${key}:</strong> ${value}`)
      .join('<br>')
  }

  return JSON.stringify(details)
}

const getTypeClass = (type: string) => {
  const classes = {
    inventory: 'type-inventory',
    sales: 'type-sales',
    users: 'type-users',
    system: 'type-system'
  }
  return classes[type as keyof typeof classes] || 'type-default'
}

const getTypeIcon = (type: string) => {
  const icons = {
    inventory: '📦',
    sales: '💰',
    users: '👤',
    system: '⚙️'
  }
  return icons[type as keyof typeof icons] || '📝'
}

const getStatusClass = (level: string) => {
  const classes = {
    info: 'status-info',
    warning: 'status-warning',
    error: 'status-error',
    success: 'status-success'
  }
  return classes[level as keyof typeof classes] || 'status-default'
}

const getStatusIcon = (level: string) => {
  const icons = {
    info: 'ℹ️',
    warning: '⚠️',
    error: '❌',
    success: '✅'
  }
  return icons[level as keyof typeof icons] || 'ℹ️'
}

const getLogRowClass = (level: string) => {
  return `log-row log-${level}`
}

onMounted(() => {
  loadLogs()
})
</script>

<style scoped>
.logs-view {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.logs-header {
  text-align: center;
  margin-bottom: 30px;
}

.logs-header h1 {
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 10px;
  font-weight: 700;
}

.logs-header p {
  color: #7f8c8d;
  font-size: 1.1rem;
}

.logs-filters {
  display: flex;
  gap: 20px;
  align-items: end;
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07);
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.9rem;
}

.filter-group select,
.filter-group input {
  padding: 10px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.filter-group select:focus,
.filter-group input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.clear-filters-btn {
  padding: 10px 20px;
  background: #e74c3c;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.clear-filters-btn:hover {
  background: #c0392b;
  transform: translateY(-1px);
}

.logs-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07);
  display: flex;
  align-items: center;
  gap: 15px;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  border-radius: 50%;
}

.stat-info h3 {
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

.stat-info p {
  color: #7f8c8d;
  margin: 5px 0 0 0;
  font-size: 0.9rem;
}

.logs-table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07);
  overflow: hidden;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e9ecef;
}

.table-header h2 {
  color: #2c3e50;
  margin: 0;
  font-size: 1.5rem;
}

.table-actions {
  display: flex;
  gap: 10px;
}

.export-btn,
.refresh-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.export-btn {
  background: #27ae60;
  color: white;
}

.export-btn:hover {
  background: #229954;
}

.refresh-btn {
  background: #3498db;
  color: white;
}

.refresh-btn:hover {
  background: #2980b9;
}

.logs-table {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  background: #f8f9fa;
  padding: 15px;
  text-align: left;
  font-weight: 600;
  color: #2c3e50;
  border-bottom: 2px solid #e9ecef;
}

td {
  padding: 15px;
  border-bottom: 1px solid #e9ecef;
  vertical-align: top;
}

.log-row {
  transition: all 0.3s ease;
}

.log-row:hover {
  background: #f8f9fa;
}

.log-error {
  background: rgba(231, 76, 60, 0.05);
  border-left: 4px solid #e74c3c;
}

.log-warning {
  background: rgba(241, 196, 15, 0.05);
  border-left: 4px solid #f1c40f;
}

.log-success {
  background: rgba(39, 174, 96, 0.05);
  border-left: 4px solid #27ae60;
}

.log-info {
  background: rgba(52, 152, 219, 0.05);
  border-left: 4px solid #3498db;
}

.datetime-cell {
  font-family: monospace;
  font-size: 0.85rem;
  color: #7f8c8d;
  white-space: nowrap;
}

.action-cell {
  font-weight: 600;
  color: #2c3e50;
}

.user-cell {
  color: #34495e;
}

.details-cell {
  max-width: 300px;
}

.details-content {
  font-size: 0.85rem;
  line-height: 1.4;
  color: #5a6c7d;
}

.type-inventory {
  background: #e8f5e8;
  color: #27ae60;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.type-sales {
  background: #fff3cd;
  color: #856404;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.type-users {
  background: #d1ecf1;
  color: #0c5460;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.type-system {
  background: #e2e3e5;
  color: #383d41;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-info {
  background: #d1ecf1;
  color: #0c5460;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-warning {
  background: #fff3cd;
  color: #856404;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-error {
  background: #f8d7da;
  color: #721c24;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-success {
  background: #d4edda;
  color: #155724;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.loading-state {
  padding: 60px 20px;
  text-align: center;
  color: #7f8c8d;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e9ecef;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  padding: 60px 20px;
  text-align: center;
  color: #7f8c8d;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.empty-state h3 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  padding: 20px;
  border-top: 1px solid #e9ecef;
}

.page-btn {
  padding: 10px 20px;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.page-btn:hover:not(:disabled) {
  background: #2980b9;
}

.page-btn:disabled {
  background: #bdc3c7;
  cursor: not-allowed;
}

.page-info {
  color: #7f8c8d;
  font-weight: 600;
}

@media (max-width: 768px) {
  .logs-view {
    padding: 10px;
  }

  .logs-filters {
    flex-direction: column;
    gap: 15px;
  }

  .filter-group {
    width: 100%;
  }

  .logs-stats {
    grid-template-columns: 1fr;
  }

  .table-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }

  .table-actions {
    justify-content: center;
  }

  .logs-table {
    font-size: 0.85rem;
  }

  .details-cell {
    max-width: 200px;
  }
}
</style>