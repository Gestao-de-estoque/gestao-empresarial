<template>
  <div class="database-stats">
    <!-- Card Principal -->
    <div class="panel database-panel">
      <div class="panel-header">
        <h2>
          <svg class="supabase-icon" width="22" height="22" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <defs>
              <linearGradient id="sbG" x1="0" x2="1" y1="0" y2="1">
                <stop offset="0%" stop-color="#3ECF8E"/>
                <stop offset="100%" stop-color="#2EB67D"/>
              </linearGradient>
            </defs>
            <path fill="url(#sbG)" d="M153.1 16c-5.5 0-10.8 2.5-14.2 6.8L48.8 132.7c-9 11-1 27.3 13.1 27.3h64.6l-23.6 79.1c-4.9 16.4 16.3 27.2 27.2 14.2l118.8-140.6c9.2-10.9 1.3-27.5-12.8-27.5h-67.5l22-53.2c4.4-10.6-3.4-22-13.6-22z"/>
          </svg>
          Banco de Dados
        </h2>
        <div class="status-indicator" :class="getStatusClass()">
          <component :is="getStatusIcon()" :size="14" />
          {{ getStatusText() }}
        </div>
      </div>

      <div class="panel-content">
        <div class="tabs">
          <button class="tab" :class="{active: activeTab==='overview'}" @click="activeTab='overview'">Resumo</button>
          <button class="tab" :class="{active: activeTab==='explorer'}" @click="activeTab='explorer'">Explorar</button>
        </div>

        <div v-if="activeTab==='overview'">
        <!-- Indicador de Uso Principal -->
        <div class="usage-section">
          <div class="usage-header">
            <span class="usage-label">Espaço Utilizado</span>
            <span class="usage-value">
              {{ formatSize(stats?.usedSpace || 0) }} / {{ formatSize(stats?.projectInfo.maxDbSize || 500) }}
            </span>
          </div>

          <div class="progress-container">
            <div class="progress-track">
              <div
                class="progress-fill"
                :class="getProgressClass()"
                :style="{ width: `${Math.min(100, stats?.usagePercentage || 0)}%` }"
              ></div>
            </div>
            <div class="usage-percentage">
              {{ Math.round(stats?.usagePercentage || 0) }}%
            </div>
          </div>
        </div>

        <!-- Métricas em Grid -->
        <div class="metrics-grid">
          <div class="metric-card">
            <div class="metric-icon available">
              <HardDrive :size="18" />
            </div>
            <div class="metric-info">
              <div class="metric-value">{{ formatSize(systemMetrics?.memoryAvailable || 0) }}</div>
              <div class="metric-label">Memória Disponível</div>
            </div>
          </div>

          <div class="metric-card">
            <div class="metric-icon records">
              <Database :size="18" />
            </div>
            <div class="metric-info">
              <div class="metric-value">{{ (systemMetrics?.totalRecords || 0).toLocaleString() }}</div>
              <div class="metric-label">Total de Registros</div>
            </div>
          </div>

          <div class="metric-card">
            <div class="metric-icon storage">
              <Image :size="18" />
            </div>
            <div class="metric-info">
              <div class="metric-value">{{ systemMetrics?.filesCount || 0 }}</div>
              <div class="metric-label">Arquivos</div>
            </div>
          </div>

          <div class="metric-card">
            <div class="metric-icon size">
              <Gauge :size="18" />
            </div>
            <div class="metric-info">
              <div class="metric-value">{{ formatSize(systemMetrics?.storageUsed || 0) }}</div>
              <div class="metric-label">Storage</div>
            </div>
          </div>
        </div>

        <!-- Resumo das Tabelas -->
        <div class="tables-summary" v-if="tablesInfo">
          <div class="summary-header">
            <h3>
              <Table2 :size="18" />
              Resumo das Tabelas
            </h3>
            <div class="summary-badges">
              <span class="badge total">{{ tablesInfo.summary.totalTables }} tabelas</span>
              <span class="badge active">{{ tablesInfo.summary.activeTables }} ativas</span>
            </div>
          </div>

          <div class="summary-stats">
            <div class="summary-stat">
              <div class="stat-icon">
                <Database :size="16" />
              </div>
              <div class="stat-info">
                <span class="stat-value">{{ tablesInfo.summary.totalRecords.toLocaleString() }}</span>
                <span class="stat-label">Total de Registros</span>
              </div>
            </div>

            <div class="summary-stat">
              <div class="stat-icon">
                <HardDrive :size="16" />
              </div>
              <div class="stat-info">
                <span class="stat-value">{{ tablesInfo.summary.totalSize }}</span>
                <span class="stat-label">Tamanho Total</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Detalhes das Tabelas (Expansível) -->
        <div class="details-section" v-if="showDetails">
          <div class="details-header">
            <h3>
              <Table2 :size="18" />
              Tabelas por Tamanho
            </h3>
            <button @click="showDetails = false" class="collapse-btn">
              <ChevronUp :size="16" />
            </button>
          </div>

          <div class="tables-list">
            <div
              v-for="table in (stats?.tableStats || []).slice(0, 6)"
              :key="table.tableName"
              class="table-row"
            >
              <div class="table-info">
                <span class="table-name">{{ table.tableName }}</span>
                <span class="table-records">{{ table.rowCount.toLocaleString() }} registros</span>
              </div>
              <div class="table-size">{{ formatSize(table.sizeInMB) }}</div>
            </div>
          </div>
        </div>

        <!-- Recomendações (Se houver) -->
        <div class="recommendations-section" v-if="recommendations.length > 0 && showRecommendations">
          <div class="recommendations-header">
            <h3>
              <Lightbulb :size="18" />
              Recomendações
            </h3>
            <button @click="showRecommendations = false" class="collapse-btn">
              <X :size="16" />
            </button>
          </div>

          <div class="recommendations-list">
            <div
              v-for="(rec, index) in recommendations.slice(0, 3)"
              :key="index"
              class="recommendation-item"
            >
              <Info :size="14" />
              <span>{{ rec }}</span>
            </div>
          </div>
        </div>

        <!-- Ações do Painel -->
        <div class="panel-actions">
          <button
            v-if="!showDetails"
            @click="showDetails = true"
            class="action-btn secondary"
          >
            <ChevronDown :size="16" />
            Ver Detalhes
          </button>

          <button @click="refreshStats" class="action-btn primary" :disabled="isLoading">
            <RefreshCw :size="16" :class="{ 'animate-spin': isLoading }" />
            Atualizar
          </button>
        </div>
        </div>

        <div v-else class="explorer-tab">
          <!-- Filtros e Busca -->
          <div class="explorer-filters">
            <div class="filter-group">
              <label>Filtrar por categoria:</label>
              <select v-model="selectedCategory" class="filter-select">
                <option value="">Todas as categorias</option>
                <option value="Estoque">Estoque</option>
                <option value="Cardápio">Cardápio</option>
                <option value="Sistema">Sistema</option>
                <option value="API">API</option>
                <option value="Suporte">Suporte</option>
                <option value="Segurança">Segurança</option>
                <option value="Financeiro">Financeiro</option>
                <option value="Analytics">Analytics</option>
                <option value="Gestão">Gestão</option>
                <option value="Autenticação">Autenticação</option>
              </select>
            </div>

            <div class="filter-group">
              <label>Filtrar por status:</label>
              <select v-model="selectedStatus" class="filter-select">
                <option value="">Todos os status</option>
                <option value="active">Ativas</option>
                <option value="large">Grandes</option>
                <option value="empty">Vazias</option>
              </select>
            </div>

            <div class="search-group">
              <Search :size="16" />
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Buscar tabelas..."
                class="search-input"
              />
            </div>
          </div>

          <!-- Lista de Tabelas -->
          <div class="tables-explorer" v-if="filteredTables">
            <div class="explorer-header">
              <h3>
                <Database :size="18" />
                Explorar Tabelas ({{ filteredTables.length }})
              </h3>
              <div class="view-toggle">
                <button
                  @click="viewMode = 'grid'"
                  :class="{ active: viewMode === 'grid' }"
                  class="view-btn"
                >
                  <Grid3x3 :size="16" />
                </button>
                <button
                  @click="viewMode = 'list'"
                  :class="{ active: viewMode === 'list' }"
                  class="view-btn"
                >
                  <List :size="16" />
                </button>
              </div>
            </div>

            <div :class="['tables-container', viewMode]">
              <div
                v-for="table in filteredTables"
                :key="table.name"
                class="table-explorer-card"
                :class="table.status"
              >
                <div class="table-card-header">
                  <div class="table-icon">
                    <component :is="getTableIcon(table.category)" :size="20" />
                  </div>
                  <div class="table-title">
                    <h4>{{ table.name }}</h4>
                    <span class="table-category">{{ table.category }}</span>
                  </div>
                  <div class="table-status-badge" :class="table.status">
                    {{ getStatusLabel(table.status) }}
                  </div>
                </div>

                <div class="table-card-content">
                  <div class="table-metrics">
                    <div class="metric">
                      <Database :size="14" />
                      <span>{{ table.records.toLocaleString() }} registros</span>
                    </div>
                    <div class="metric">
                      <HardDrive :size="14" />
                      <span>{{ table.size }}</span>
                    </div>
                    <div class="metric">
                      <Calendar :size="14" />
                      <span>{{ table.lastUpdate }}</span>
                    </div>
                  </div>

                  <div class="table-actions">
                    <button @click="viewTableDetails(table)" class="action-button">
                      <Eye :size="14" />
                      Ver Detalhes
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading Overlay -->
      <div v-if="isLoading" class="loading-overlay">
        <Loader2 :size="24" class="animate-spin" />
      </div>
    </div>

    <!-- Database Alert -->
    <DatabaseAlert
      v-if="stats && healthStatus.usagePercentage >= 80"
      :usage-percentage="healthStatus.usagePercentage"
      :alert-message="healthStatus.message"
      :alert-type="healthStatus.status === 'critical' ? 'critical' : 'warning'"
      @dismissed="handleAlertDismissed"
      @view-details="showDetails = true"
      @view-recommendations="showRecommendations = true"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Database, HardDrive, Image, Lightbulb, Info, Gauge,
  ChevronDown, ChevronUp, X, Table2, Loader2, RefreshCw,
  CheckCircle, AlertTriangle, XCircle, Search, Grid3x3, List,
  Calendar, Eye, Package, Users, Settings, Shield, DollarSign,
  BarChart3, HeadphonesIcon, Lock, Cog
} from 'lucide-vue-next'
import { databaseStatsService, type DatabaseStats } from '@/services/databaseStatsService'
import DatabaseAlert from './DatabaseAlert.vue'

// Estados reativos
const stats = ref<DatabaseStats | null>(null)
const healthStatus = ref({ status: 'healthy', message: '', usagePercentage: 0 })
const recommendations = ref<string[]>([])
const systemMetrics = ref<{
  memoryAvailable: number
  totalRecords: number
  filesCount: number
  storageUsed: number
} | null>(null)
const tablesInfo = ref<{
  tables: Array<{
    name: string
    records: number
    size: string
    category: string
    lastUpdate: string
    status: 'active' | 'empty' | 'large'
  }>
  summary: {
    totalTables: number
    totalRecords: number
    totalSize: string
    activeTables: number
  }
} | null>(null)
const isLoading = ref(false)
const error = ref(false)
const showDetails = ref(false)
const showRecommendations = ref(false)
const activeTab = ref<'overview' | 'explorer'>('overview')

// Explorer state
const selectedCategory = ref('')
const selectedStatus = ref('')
const searchTerm = ref('')
const viewMode = ref<'grid' | 'list'>('grid')

// Computed

const filteredTables = computed(() => {
  if (!tablesInfo.value) return []

  let filtered = tablesInfo.value.tables

  // Filtrar por categoria
  if (selectedCategory.value) {
    filtered = filtered.filter(table => table.category === selectedCategory.value)
  }

  // Filtrar por status
  if (selectedStatus.value) {
    filtered = filtered.filter(table => table.status === selectedStatus.value)
  }

  // Filtrar por termo de busca
  if (searchTerm.value) {
    const term = searchTerm.value.toLowerCase()
    filtered = filtered.filter(table =>
      table.name.toLowerCase().includes(term) ||
      table.category.toLowerCase().includes(term)
    )
  }

  return filtered
})

// Funções
function formatSize(sizeInMB: number): string {
  return databaseStatsService.formatSize(sizeInMB)
}

function getStatusIcon() {
  switch (healthStatus.value.status) {
    case 'healthy': return CheckCircle
    case 'warning': return AlertTriangle
    case 'critical': return XCircle
    default: return CheckCircle
  }
}

function getStatusText(): string {
  switch (healthStatus.value.status) {
    case 'healthy': return 'Saudável'
    case 'warning': return 'Atenção'
    case 'critical': return 'Crítico'
    default: return 'Normal'
  }
}

function getStatusClass(): string {
  return healthStatus.value.status
}

function getProgressClass(): string {
  const percentage = stats.value?.usagePercentage || 0
  if (percentage >= 95) return 'critical'
  if (percentage >= 80) return 'warning'
  return 'normal'
}

function handleAlertDismissed() {
  console.log('🔔 Alerta do banco de dados dispensado')
}

function getTableIcon(category: string) {
  const icons: { [key: string]: any } = {
    'Estoque': Package,
    'Cardápio': Database,
    'Sistema': Settings,
    'API': Cog,
    'Suporte': HeadphonesIcon,
    'Segurança': Shield,
    'Financeiro': DollarSign,
    'Analytics': BarChart3,
    'Gestão': Users,
    'Autenticação': Lock
  }
  return icons[category] || Database
}

function getStatusLabel(status: string): string {
  const labels: { [key: string]: string } = {
    'active': 'Ativa',
    'large': 'Grande',
    'empty': 'Vazia'
  }
  return labels[status] || status
}

function viewTableDetails(table: any) {
  console.log('📋 Visualizando detalhes da tabela:', table.name)
  // Aqui você pode implementar um modal ou navegar para uma página de detalhes
}

async function refreshStats() {
  await loadStats()
}

async function loadStats() {
  isLoading.value = true
  error.value = false

  try {
    console.log('📊 Atualizando estatísticas do banco...')

    const [dbStats, health, recs, metrics, tables] = await Promise.all([
      databaseStatsService.getDatabaseStats(),
      databaseStatsService.checkDatabaseHealth(),
      databaseStatsService.getOptimizationRecommendations(),
      databaseStatsService.getSystemMetrics(),
      databaseStatsService.getAllTablesInfo()
    ])

    stats.value = dbStats
    healthStatus.value = health
    recommendations.value = recs
    systemMetrics.value = metrics
    tablesInfo.value = tables

    // Auto-mostrar recomendações se houver e uso >= 70%
    if (recs.length > 0 && health.usagePercentage >= 70) {
      showRecommendations.value = true
    }

    console.log('✅ Estatísticas atualizadas:', {
      size: formatSize(dbStats.totalSize),
      usage: `${Math.round(dbStats.usagePercentage)}%`,
      status: health.status,
      totalRecords: metrics.totalRecords,
      totalTables: tables.summary.totalTables
    })

  } catch (err: any) {
    console.error('❌ Erro:', err)
    error.value = true
  } finally {
    isLoading.value = false
  }
}

// Lifecycle
onMounted(() => {
  loadStats()

  // Auto-refresh a cada 5 minutos
  setInterval(loadStats, 5 * 60 * 1000)
})
</script>

<style scoped>
.database-stats {
  width: 100%;
}

.database-panel {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
  position: relative;
  overflow: hidden;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 24px 0;
  margin-bottom: 24px;
}

.panel-header h2 {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: var(--theme-text-primary, #1a202c);
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-indicator.healthy {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.status-indicator.warning {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.status-indicator.critical {
  background: rgba(239, 68, 68, 0.1);
  color: #dc2626;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.panel-content {
  padding: 0 24px 24px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.usage-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.usage-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.usage-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--theme-text-secondary, #64748b);
}

.usage-value {
  font-size: 14px;
  font-weight: 700;
  color: var(--theme-text-primary, #1a202c);
}

.progress-container {
  display: flex;
  align-items: center;
  gap: 16px;
}

.progress-track {
  flex: 1;
  height: 8px;
  background: #f1f5f9;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 4px;
  transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

.progress-fill.normal {
  background: linear-gradient(90deg, #10b981, #059669);
}

.progress-fill.warning {
  background: linear-gradient(90deg, #f59e0b, #d97706);
}

.progress-fill.critical {
  background: linear-gradient(90deg, #ef4444, #dc2626);
  animation: criticalPulse 1.5s infinite;
}

@keyframes criticalPulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.usage-percentage {
  font-size: 14px;
  font-weight: 700;
  color: var(--theme-text-primary, #1a202c);
  min-width: 48px;
  text-align: right;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 16px;
}

.metric-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: rgba(248, 250, 252, 0.8);
  border-radius: 16px;
  border: 1px solid rgba(226, 232, 240, 0.5);
  transition: all 0.3s ease;
}

.metric-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.metric-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.metric-icon.available {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.metric-icon.records {
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
}

.metric-icon.storage {
  background: rgba(168, 85, 247, 0.1);
  color: #9333ea;
}

.metric-icon.size {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.metric-info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.metric-value {
  font-size: 18px;
  font-weight: 700;
  color: var(--theme-text-primary, #1a202c);
  line-height: 1.2;
}

.metric-label {
  font-size: 12px;
  font-weight: 500;
  color: var(--theme-text-secondary, #64748b);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.details-section,
.recommendations-section {
  border-top: 1px solid rgba(226, 232, 240, 0.5);
  padding-top: 20px;
}

.details-header,
.recommendations-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.details-header h3,
.recommendations-header h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--theme-text-primary, #1a202c);
}

.collapse-btn {
  background: rgba(100, 116, 139, 0.1);
  border: none;
  border-radius: 8px;
  padding: 6px;
  cursor: pointer;
  color: #64748b;
  transition: all 0.2s ease;
}

.collapse-btn:hover {
  background: rgba(100, 116, 139, 0.2);
  color: #475569;
}

.tables-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.table-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  border: 1px solid rgba(226, 232, 240, 0.3);
}

.table-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.table-name {
  font-weight: 600;
  color: var(--theme-text-primary, #1a202c);
  font-size: 14px;
}

.table-records {
  font-size: 12px;
  color: var(--theme-text-secondary, #64748b);
}

.table-size {
  font-weight: 700;
  color: #667eea;
  font-size: 14px;
}

.recommendations-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.recommendation-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 16px;
  background: rgba(245, 158, 11, 0.05);
  border-radius: 12px;
  border: 1px solid rgba(245, 158, 11, 0.1);
  font-size: 13px;
  line-height: 1.4;
  color: #92400e;
}

.panel-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  border-top: 1px solid rgba(226, 232, 240, 0.5);
  padding-top: 20px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.action-btn.primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.action-btn.primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
}

.action-btn.secondary {
  background: rgba(100, 116, 139, 0.1);
  color: #64748b;
  border: 1px solid rgba(100, 116, 139, 0.2);
}

.action-btn.secondary:hover {
  background: rgba(100, 116, 139, 0.15);
  color: #475569;
  transform: translateY(-1px);
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 20px;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Tabs */
.tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  background: rgba(248, 250, 252, 0.8);
  padding: 4px;
  border-radius: 12px;
}

.tab {
  flex: 1;
  padding: 12px 16px;
  border: none;
  background: transparent;
  border-radius: 8px;
  font-weight: 600;
  color: var(--theme-text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
}

.tab.active {
  background: white;
  color: var(--theme-primary);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* Tables Summary */
.tables-summary {
  background: rgba(248, 250, 252, 0.6);
  border-radius: 16px;
  padding: 20px;
  border: 1px solid rgba(226, 232, 240, 0.5);
  margin: 20px 0;
}

.summary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.summary-header h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.summary-badges {
  display: flex;
  gap: 8px;
}

.badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.badge.total {
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
}

.badge.active {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.summary-stats {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.summary-stat {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stat-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 18px;
  font-weight: 700;
  color: var(--theme-text-primary);
  line-height: 1.2;
}

.stat-label {
  font-size: 12px;
  color: var(--theme-text-secondary);
  font-weight: 500;
}

/* Explorer Tab */
.explorer-tab {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.explorer-filters {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 16px;
  padding: 20px;
  background: rgba(248, 250, 252, 0.6);
  border-radius: 16px;
  border: 1px solid rgba(226, 232, 240, 0.5);
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  font-size: 12px;
  font-weight: 600;
  color: var(--theme-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid rgba(226, 232, 240, 0.8);
  border-radius: 8px;
  background: white;
  font-size: 14px;
  color: var(--theme-text-primary);
}

.search-group {
  display: flex;
  align-items: center;
  gap: 8px;
  position: relative;
}

.search-group svg {
  position: absolute;
  left: 12px;
  color: var(--theme-text-secondary);
}

.search-input {
  width: 100%;
  padding: 8px 12px 8px 36px;
  border: 1px solid rgba(226, 232, 240, 0.8);
  border-radius: 8px;
  background: white;
  font-size: 14px;
  color: var(--theme-text-primary);
}

.search-input::placeholder {
  color: var(--theme-text-secondary);
}

.explorer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.explorer-header h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.view-toggle {
  display: flex;
  gap: 4px;
  background: rgba(248, 250, 252, 0.8);
  padding: 4px;
  border-radius: 8px;
}

.view-btn {
  padding: 8px;
  border: none;
  background: transparent;
  border-radius: 4px;
  cursor: pointer;
  color: var(--theme-text-secondary);
  transition: all 0.2s ease;
}

.view-btn.active {
  background: white;
  color: var(--theme-primary);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.tables-container.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

.tables-container.list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.table-explorer-card {
  background: white;
  border-radius: 16px;
  border: 1px solid rgba(226, 232, 240, 0.8);
  padding: 20px;
  transition: all 0.3s ease;
}

.table-explorer-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.table-explorer-card.large {
  border-left: 4px solid #f59e0b;
}

.table-explorer-card.empty {
  border-left: 4px solid #9ca3af;
  opacity: 0.7;
}

.table-explorer-card.active {
  border-left: 4px solid #10b981;
}

.table-card-header {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 16px;
}

.table-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.table-title {
  flex: 1;
  min-width: 0;
}

.table-title h4 {
  margin: 0 0 4px;
  font-size: 16px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.table-category {
  font-size: 12px;
  color: var(--theme-text-secondary);
  background: rgba(100, 116, 139, 0.1);
  padding: 2px 8px;
  border-radius: 12px;
}

.table-status-badge {
  padding: 4px 8px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.table-status-badge.active {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.table-status-badge.large {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.table-status-badge.empty {
  background: rgba(156, 163, 175, 0.1);
  color: #6b7280;
}

.table-card-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.table-metrics {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.metric {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--theme-text-secondary);
}

.metric svg {
  flex-shrink: 0;
}

.table-actions {
  display: flex;
  gap: 8px;
}

.action-button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border: 1px solid rgba(59, 130, 246, 0.3);
  background: rgba(59, 130, 246, 0.05);
  color: #2563eb;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.action-button:hover {
  background: rgba(59, 130, 246, 0.1);
  border-color: rgba(59, 130, 246, 0.5);
}

/* Responsividade */
@media (max-width: 768px) {
  .panel-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .metrics-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .panel-actions {
    flex-direction: column;
  }

  .action-btn {
    justify-content: center;
  }

  .table-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .table-size {
    align-self: flex-end;
  }

  .explorer-filters {
    grid-template-columns: 1fr;
  }

  .tables-container.grid {
    grid-template-columns: 1fr;
  }

  .summary-stats {
    grid-template-columns: 1fr;
  }
}
</style>
