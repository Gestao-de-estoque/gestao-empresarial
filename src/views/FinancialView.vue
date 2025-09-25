<template>
  <div class="financial-container">
    <!-- Header Principal -->
    <div class="financial-header">
      <div class="header-main">
        <div class="header-left">
          <div class="title-section">
            <h1 class="page-title">
              <DollarSign :size="32" />
              Análise Financeira Avançada
            </h1>
            <p class="page-subtitle">
              Insights inteligentes sobre receitas, análise de desempenho e otimização de resultados
            </p>
          </div>
        </div>
        <div class="header-actions">
          <div class="stat-card primary">
            <div class="stat-icon">
              <TrendingUp :size="20" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatCurrency(summary.totalRevenue || 0) }}</div>
              <div class="stat-label">Receita Total</div>
            </div>
          </div>
          <div class="stat-card success">
            <div class="stat-icon">
              <Users :size="20" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatCurrency(summary.totalWaiterSalary || 0) }}</div>
              <div class="stat-label">Salários Garçons</div>
            </div>
          </div>
          <div class="stat-card warning">
            <div class="stat-icon">
              <Target :size="20" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatCurrency(summary.averageDailyRevenue || 0) }}</div>
              <div class="stat-label">Média Diária</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner">
        <RefreshCw :size="32" class="animate-spin" />
        <p>Carregando análise financeira...</p>
      </div>
    </div>

    <!-- Main Content -->
    <div v-else class="financial-content">
      <!-- Action Buttons -->
      <div class="action-buttons">
        <button @click="showAddForm = true" class="btn-primary">
          <Plus :size="18" />
          Adicionar Registro
        </button>
        <button @click="refreshData" class="btn-secondary" :disabled="refreshing">
          <RefreshCw :size="18" :class="{ 'animate-spin': refreshing }" />
          Atualizar
        </button>
        <button @click="generateAIInsights" class="btn-ai" :disabled="generatingInsights">
          <Brain :size="18" />
          Insights IA
        </button>
        <button @click="exportData" class="btn-export">
          <Download :size="18" />
          Exportar
        </button>
      </div>

      <!-- AI Insights Section -->
      <section v-if="aiInsights" class="ai-insights-section">
        <div class="section-header">
          <h2>
            <Sparkles :size="24" />
            Insights da Inteligência Artificial
          </h2>
        </div>
        <div class="insights-grid">
          <div class="insight-card" v-for="insight in aiInsights" :key="insight.id">
            <div class="insight-icon">
              <component :is="insight.icon" :size="24" />
            </div>
            <div class="insight-content">
              <h3>{{ insight.title }}</h3>
              <p>{{ insight.description }}</p>
              <div v-if="insight.recommendation" class="insight-recommendation">
                <strong>Recomendação:</strong> {{ insight.recommendation }}
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Charts Grid -->
      <div class="charts-grid">
        <!-- Revenue Trend Chart -->
        <div class="chart-container">
          <div class="chart-header">
            <h3>
              <TrendingUp :size="20" />
              Tendência de Receitas
            </h3>
            <div class="chart-controls">
              <select v-model="chartPeriod" @change="updateCharts" class="select-modern">
                <option value="7">Últimos 7 dias</option>
                <option value="30">Últimos 30 dias</option>
                <option value="90">Últimos 90 dias</option>
                <option value="365">Último ano</option>
              </select>
            </div>
          </div>
          <div class="chart-wrapper">
            <Line
              v-if="revenueChartData.datasets.length"
              :data="revenueChartData"
              :options="chartOptions"
            />
          </div>
        </div>

        <!-- Revenue vs Waiter Salary Comparison -->
        <div class="chart-container">
          <div class="chart-header">
            <h3>
              <BarChart3 :size="20" />
              Receita vs Salário Garçons
            </h3>
          </div>
          <div class="chart-wrapper">
            <Bar
              v-if="comparisonChartData.datasets.length"
              :data="comparisonChartData"
              :options="barChartOptions"
            />
          </div>
        </div>

        <!-- Monthly Performance Pie -->
        <div class="chart-container">
          <div class="chart-header">
            <h3>
              <PieChart :size="20" />
              Distribuição Mensal
            </h3>
          </div>
          <div class="chart-wrapper">
            <Doughnut
              v-if="pieChartData.datasets.length"
              :data="pieChartData"
              :options="pieChartOptions"
            />
          </div>
        </div>

        <!-- Performance Metrics -->
        <div class="chart-container metrics-container">
          <div class="chart-header">
            <h3>
              <Activity :size="20" />
              Métricas de Performance
            </h3>
          </div>
          <div class="metrics-grid">
            <div class="metric-card">
              <div class="metric-value">{{ analyticsData?.performanceMetrics.growth }}%</div>
              <div class="metric-label">Crescimento</div>
              <div class="metric-indicator" :class="analyticsData?.performanceMetrics.growth > 0 ? 'positive' : 'negative'">
                <component :is="analyticsData?.performanceMetrics.growth > 0 ? TrendingUp : TrendingDown" :size="16" />
              </div>
            </div>
            <div class="metric-card">
              <div class="metric-value">{{ analyticsData?.performanceMetrics.consistency }}%</div>
              <div class="metric-label">Consistência</div>
              <div class="metric-indicator">
                <Activity :size="16" />
              </div>
            </div>
            <div class="metric-card">
              <div class="metric-value">{{ analyticsData?.performanceMetrics.efficiency }}</div>
              <div class="metric-label">Eficiência</div>
              <div class="metric-indicator">
                <Target :size="16" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Financial Records Table -->
      <section class="records-section">
        <div class="section-header">
          <h2>
            <Table :size="24" />
            Registros Financeiros
          </h2>
          <div class="table-controls">
            <div class="search-container">
              <Search :size="18" />
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Buscar por data..."
                class="search-input"
              />
            </div>
            <select v-model="sortBy" class="select-modern">
              <option value="full_day">Data</option>
              <option value="total">Receita Total</option>
              <option value="amount">Salário Garçom</option>
            </select>
          </div>
        </div>

        <div class="table-container">
          <table class="financial-table">
            <thead>
              <tr>
                <th @click="setSortBy('full_day')" class="sortable">
                  Data
                  <ArrowUpDown :size="14" />
                </th>
                <th @click="setSortBy('total')" class="sortable">
                  Receita Total
                  <ArrowUpDown :size="14" />
                </th>
                <th @click="setSortBy('amount')" class="sortable">
                  Salário Garçom (10%)
                  <ArrowUpDown :size="14" />
                </th>
                <th>% do Garçom</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="record in filteredRecords" :key="record.id" class="table-row">
                <td class="date-cell">{{ formatDate(record.full_day) }}</td>
                <td class="currency-cell">{{ formatCurrency(record.total) }}</td>
                <td class="currency-cell secondary">{{ formatCurrency(record.amount) }}</td>
                <td class="percentage-cell">{{ calculatePercentage(record.amount, record.total) }}%</td>
                <td class="actions-cell">
                  <button @click="editRecord(record)" class="btn-icon edit">
                    <Edit :size="16" />
                  </button>
                  <button @click="record.id && deleteRecord(record.id)" class="btn-icon delete">
                    <Trash2 :size="16" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="table-summary">
          <div class="summary-stats">
            <div class="summary-stat">
              <span class="stat-label">Total de Registros:</span>
              <span class="stat-value">{{ filteredRecords.length }}</span>
            </div>
            <div class="summary-stat">
              <span class="stat-label">Receita Total:</span>
              <span class="stat-value">{{ formatCurrency(getTotalRevenue(filteredRecords)) }}</span>
            </div>
            <div class="summary-stat">
              <span class="stat-label">Total Salários:</span>
              <span class="stat-value">{{ formatCurrency(getTotalWaiterSalary(filteredRecords)) }}</span>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- Add/Edit Record Modal -->
    <div v-if="showAddForm || editingRecord" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ editingRecord ? 'Editar' : 'Adicionar' }} Registro Financeiro</h3>
          <button @click="closeModal" class="btn-close">
            <X :size="20" />
          </button>
        </div>
        <form @submit.prevent="saveRecord" class="record-form">
          <div class="form-group">
            <label for="date">Data:</label>
            <input
              id="date"
              v-model="recordForm.full_day"
              type="date"
              required
              class="form-input"
            />
          </div>
          <div class="form-group">
            <label for="total">Receita Total (R$):</label>
            <input
              id="total"
              v-model.number="recordForm.total"
              type="number"
              step="0.01"
              min="0"
              required
              class="form-input"
            />
          </div>
          <div class="form-group">
            <label for="amount">Salário Garçom (R$):</label>
            <input
              id="amount"
              v-model.number="recordForm.amount"
              type="number"
              step="0.01"
              min="0"
              required
              class="form-input"
            />
          </div>
          <div class="form-actions">
            <button type="button" @click="closeModal" class="btn-secondary">
              Cancelar
            </button>
            <button type="submit" class="btn-primary" :disabled="saving">
              {{ saving ? 'Salvando...' : 'Salvar' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from 'vue'
import {
  DollarSign, TrendingUp, TrendingDown, Users, Target, RefreshCw, Plus, Brain,
  Download, Sparkles, BarChart3, PieChart, Activity, Table,
  Search, ArrowUpDown, Edit, Trash2, X
} from 'lucide-vue-next'
import { Line, Bar, Doughnut } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js'
import { financialService, FinancialRecord, FinancialSummary } from '@/services/financialService'
import { executeMigration } from '@/utils/migrateFinancialData'

// Register Chart.js components
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
)

// Reactive data
const loading = ref(true)
const refreshing = ref(false)
const saving = ref(false)
const generatingInsights = ref(false)
const showAddForm = ref(false)
const editingRecord = ref<FinancialRecord | null>(null)
const searchTerm = ref('')
const sortBy = ref('full_day')
const chartPeriod = ref('30')

const records = ref<FinancialRecord[]>([])
const summary = ref<FinancialSummary>({
  totalRevenue: 0,
  totalWaiterSalary: 0,
  averageDailyRevenue: 0,
  averageWaiterSalary: 0,
  bestDay: null,
  worstDay: null,
  monthlyData: [],
  yearlyData: []
})
const analyticsData = ref<any>(null)
const aiInsights = ref<any[]>([])

const recordForm = reactive({
  full_day: '',
  total: 0,
  amount: 0
})

// Computed properties
const filteredRecords = computed(() => {
  let filtered = records.value.filter(record =>
    record.full_day.toLowerCase().includes(searchTerm.value.toLowerCase())
  )

  // Sort records
  filtered.sort((a, b) => {
    if (sortBy.value === 'full_day') {
      return new Date(a.full_day.split('/').reverse().join('-')).getTime() -
             new Date(b.full_day.split('/').reverse().join('-')).getTime()
    } else if (sortBy.value === 'total') {
      return b.total - a.total
    } else if (sortBy.value === 'amount') {
      return b.amount - a.amount
    }
    return 0
  })

  return filtered
})

const revenueChartData = computed(() => {
  const data = records.value.slice(-parseInt(chartPeriod.value))
  return {
    labels: data.map(r => r.full_day),
    datasets: [{
      label: 'Receita Total',
      data: data.map(r => r.total),
      borderColor: '#3b82f6',
      backgroundColor: 'rgba(59, 130, 246, 0.1)',
      fill: true,
      tension: 0.4
    }, {
      label: 'Salário Garçom',
      data: data.map(r => r.amount),
      borderColor: '#10b981',
      backgroundColor: 'rgba(16, 185, 129, 0.1)',
      fill: true,
      tension: 0.4
    }]
  }
})

const comparisonChartData = computed(() => {
  const monthlyData = summary.value.monthlyData.slice(-6) // Últimos 6 meses
  return {
    labels: monthlyData.map(d => d.month),
    datasets: [{
      label: 'Receita',
      data: monthlyData.map(d => d.revenue),
      backgroundColor: '#3b82f6',
    }, {
      label: 'Salários',
      data: monthlyData.map(d => d.waiterSalary),
      backgroundColor: '#10b981',
    }]
  }
})

const pieChartData = computed(() => {
  const yearlyData = summary.value.yearlyData
  return {
    labels: yearlyData.map(d => d.year),
    datasets: [{
      data: yearlyData.map(d => d.revenue),
      backgroundColor: [
        '#3b82f6',
        '#10b981',
        '#f59e0b',
        '#ef4444',
        '#8b5cf6',
        '#06b6d4'
      ]
    }]
  }
})

// Chart options
const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top' as const,
    },
    title: {
      display: false,
    }
  },
  scales: {
    y: {
      beginAtZero: true,
      ticks: {
        callback: function(value: any) {
          return 'R$ ' + value.toFixed(2)
        }
      }
    }
  }
}

const barChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top' as const,
    }
  },
  scales: {
    y: {
      beginAtZero: true,
      ticks: {
        callback: function(value: any) {
          return 'R$ ' + value.toFixed(2)
        }
      }
    }
  }
}

const pieChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'right' as const,
    }
  }
}

// Methods
async function loadData() {
  try {
    loading.value = true

    // First try to get data
    const recordsData = await financialService.getAllFinancialData()

    // If no data exists, try migration first
    if (recordsData.length === 0) {
      console.log('Nenhum dado encontrado, iniciando migração...')
      const migrationResult = await executeMigration()

      if (migrationResult.success) {
        // Get data after migration
        const newRecordsData = await financialService.getAllFinancialData()
        records.value = newRecordsData
      } else {
        console.error('Migração falhou:', migrationResult.error)
        records.value = []
      }
    } else {
      records.value = recordsData
    }

    // Load summary and analytics
    const [summaryData, analyticsResult] = await Promise.all([
      financialService.getFinancialSummary(),
      financialService.getFinancialAnalyticsData()
    ])

    summary.value = summaryData
    analyticsData.value = analyticsResult

  } catch (error) {
    console.error('Erro ao carregar dados financeiros:', error)
    // Set default values on error
    records.value = []
    summary.value = {
      totalRevenue: 0,
      totalWaiterSalary: 0,
      averageDailyRevenue: 0,
      averageWaiterSalary: 0,
      bestDay: null,
      worstDay: null,
      monthlyData: [],
      yearlyData: []
    }
    analyticsData.value = null
  } finally {
    loading.value = false
  }
}

async function refreshData() {
  refreshing.value = true
  await loadData()
  refreshing.value = false
}

async function generateAIInsights() {
  generatingInsights.value = true

  try {
    // Tenta usar a IA real se disponível
    if (import.meta.env.VITE_GEMINI_API_KEY) {
      const { aiService } = await import('@/services/aiService')
      aiInsights.value = await aiService.generateFinancialInsights(analyticsData.value)
    } else {
      // Fallback para insights simulados
      await new Promise(resolve => setTimeout(resolve, 1000))

      aiInsights.value = [
        {
          id: 1,
          icon: 'TrendingUp',
          title: 'Tendência de Crescimento',
          description: `Suas receitas apresentam crescimento de ${analyticsData.value?.performanceMetrics.growth || 5}% no período analisado.`,
          recommendation: 'Continue investindo nas estratégias atuais para manter este crescimento.',
          type: 'positive'
        },
        {
          id: 2,
          icon: 'Target',
          title: 'Oportunidade de Otimização',
          description: 'Dias com baixo movimento podem ser otimizados com promoções estratégicas.',
          recommendation: 'Considere implementar promoções nos dias de menor movimento.',
          type: 'info'
        },
        {
          id: 3,
          icon: 'Activity',
          title: 'Consistência Operacional',
          description: `Sua operação apresenta ${analyticsData.value?.performanceMetrics.consistency || 85}% de consistência.`,
          recommendation: 'Padronize processos para aumentar a previsibilidade dos resultados.',
          type: 'info'
        }
      ]
    }
  } catch (error) {
    console.error('Erro ao gerar insights:', error)
    aiInsights.value = [{
      id: 1,
      icon: 'RefreshCw',
      title: 'Insights em Processamento',
      description: 'Não foi possível gerar insights no momento. Tente novamente mais tarde.',
      type: 'info'
    }]
  } finally {
    generatingInsights.value = false
  }
}

function exportData() {
  const csvContent = 'data:text/csv;charset=utf-8,' +
    'Data,Receita Total,Salário Garçom,Percentual\n' +
    filteredRecords.value.map(record =>
      `${record.full_day},${record.total},${record.amount},${calculatePercentage(record.amount, record.total)}%`
    ).join('\n')

  const link = document.createElement('a')
  link.setAttribute('href', encodeURI(csvContent))
  link.setAttribute('download', 'analise_financeira.csv')
  link.click()
}

function setSortBy(field: string) {
  sortBy.value = field
}

function updateCharts() {
  // Charts will be updated automatically due to computed properties
}

function editRecord(record: FinancialRecord) {
  editingRecord.value = record
  recordForm.full_day = record.full_day
  recordForm.total = record.total
  recordForm.amount = record.amount
}

async function saveRecord() {
  try {
    saving.value = true

    if (editingRecord.value) {
      await financialService.updateFinancialRecord(editingRecord.value.id!, recordForm)
    } else {
      await financialService.addFinancialRecord(recordForm)
    }

    await loadData()
    closeModal()
  } catch (error) {
    console.error('Erro ao salvar registro:', error)
  } finally {
    saving.value = false
  }
}

async function deleteRecord(id: number) {
  if (confirm('Tem certeza que deseja deletar este registro?')) {
    try {
      await financialService.deleteFinancialRecord(id)
      await loadData()
    } catch (error) {
      console.error('Erro ao deletar registro:', error)
    }
  }
}

function closeModal() {
  showAddForm.value = false
  editingRecord.value = null
  recordForm.full_day = ''
  recordForm.total = 0
  recordForm.amount = 0
}

// Utility functions
function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(value)
}

function formatDate(dateStr: string): string {
  const [day, month, year] = dateStr.split('/')
  return `${day}/${month}/${year}`
}

function calculatePercentage(amount: number, total: number): string {
  return total > 0 ? ((amount / total) * 100).toFixed(1) : '0.0'
}

function getTotalRevenue(records: FinancialRecord[]): number {
  return records.reduce((sum, record) => sum + record.total, 0)
}

function getTotalWaiterSalary(records: FinancialRecord[]): number {
  return records.reduce((sum, record) => sum + record.amount, 0)
}

// Lifecycle
onMounted(() => {
  loadData()
})
</script>

<style scoped>
.financial-container {
  padding: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.financial-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.header-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 2rem;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 2.5rem;
  font-weight: 800;
  color: #1e293b;
  margin: 0;
}

.page-subtitle {
  font-size: 1.1rem;
  color: #64748b;
  margin: 0.5rem 0 0 0;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 16px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  min-width: 200px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

.stat-card.primary { border-left: 4px solid #3b82f6; }
.stat-card.success { border-left: 4px solid #10b981; }
.stat-card.warning { border-left: 4px solid #f59e0b; }

.stat-icon {
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  padding: 0.75rem;
  border-radius: 12px;
  display: flex;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
}

.stat-label {
  font-size: 0.9rem;
  color: #64748b;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  margin: 2rem 0;
}

.loading-spinner {
  text-align: center;
  color: #3b82f6;
}

.loading-spinner p {
  margin-top: 1rem;
  font-size: 1.1rem;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.financial-content {
  space-y: 2rem;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.btn-primary, .btn-secondary, .btn-ai, .btn-export {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.875rem 1.5rem;
  border-radius: 12px;
  font-weight: 600;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: linear-gradient(45deg, #3b82f6, #1d4ed8);
  color: white;
  box-shadow: 0 10px 25px rgba(59, 130, 246, 0.3);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 15px 35px rgba(59, 130, 246, 0.4);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.9);
  color: #374151;
  border: 1px solid #e5e7eb;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
}

.btn-ai {
  background: linear-gradient(45deg, #8b5cf6, #7c3aed);
  color: white;
  box-shadow: 0 10px 25px rgba(139, 92, 246, 0.3);
}

.btn-export {
  background: linear-gradient(45deg, #10b981, #059669);
  color: white;
  box-shadow: 0 10px 25px rgba(16, 185, 129, 0.3);
}

.ai-insights-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.section-header h2 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.75rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.insights-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.insight-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1.5rem;
  display: flex;
  gap: 1rem;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.insight-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
}

.insight-icon {
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  padding: 1rem;
  border-radius: 12px;
  display: flex;
  align-self: flex-start;
}

.insight-content h3 {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 0.5rem 0;
}

.insight-content p {
  color: #64748b;
  margin: 0 0 1rem 0;
  line-height: 1.6;
}

.insight-recommendation {
  background: rgba(59, 130, 246, 0.1);
  border-left: 3px solid #3b82f6;
  padding: 0.75rem;
  border-radius: 8px;
  font-size: 0.9rem;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.chart-container {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.metrics-container {
  grid-column: 1 / -1;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.chart-header h3 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.chart-wrapper {
  height: 400px;
  position: relative;
}

.select-modern {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
  color: #374151;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.metric-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 2rem;
  text-align: center;
  position: relative;
  overflow: hidden;
}

.metric-value {
  font-size: 2.5rem;
  font-weight: 800;
  color: #1e293b;
  margin-bottom: 0.5rem;
}

.metric-label {
  font-size: 1rem;
  color: #64748b;
  margin-bottom: 1rem;
}

.metric-indicator {
  position: absolute;
  top: 1rem;
  right: 1rem;
  padding: 0.5rem;
  border-radius: 8px;
}

.metric-indicator.positive {
  background: rgba(16, 185, 129, 0.2);
  color: #10b981;
}

.metric-indicator.negative {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

.records-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.table-controls {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-container {
  position: relative;
  display: flex;
  align-items: center;
}

.search-container svg {
  position: absolute;
  left: 1rem;
  color: #9ca3af;
}

.search-input {
  padding: 0.75rem 1rem 0.75rem 2.5rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 0.9rem;
  background: rgba(255, 255, 255, 0.9);
  min-width: 250px;
}

.table-container {
  overflow-x: auto;
  margin: 2rem 0;
}

.financial-table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

.financial-table th {
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  padding: 1.25rem 1rem;
  text-align: left;
  font-weight: 600;
  font-size: 0.95rem;
}

.financial-table th.sortable {
  cursor: pointer;
  user-select: none;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.financial-table td {
  padding: 1rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.3);
}

.table-row:hover {
  background: rgba(255, 255, 255, 0.5);
}

.date-cell {
  font-weight: 600;
  color: #374151;
}

.currency-cell {
  font-weight: 700;
  color: #059669;
}

.currency-cell.secondary {
  color: #3b82f6;
}

.percentage-cell {
  font-weight: 600;
  color: #7c3aed;
}

.actions-cell {
  display: flex;
  gap: 0.5rem;
}

.btn-icon {
  padding: 0.5rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.btn-icon.edit {
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
}

.btn-icon.delete {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.btn-icon:hover {
  transform: scale(1.1);
}

.table-summary {
  background: rgba(255, 255, 255, 0.7);
  border-radius: 12px;
  padding: 1.5rem;
  margin-top: 2rem;
}

.summary-stats {
  display: flex;
  justify-content: space-around;
  flex-wrap: wrap;
  gap: 2rem;
}

.summary-stat {
  text-align: center;
}

.summary-stat .stat-label {
  font-size: 0.9rem;
  color: #64748b;
  display: block;
  margin-bottom: 0.5rem;
}

.summary-stat .stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(10px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 20px;
  padding: 2rem;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.btn-close {
  background: none;
  border: none;
  cursor: pointer;
  color: #9ca3af;
  padding: 0.5rem;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.btn-close:hover {
  background: rgba(0, 0, 0, 0.1);
  color: #374151;
}

.record-form {
  space-y: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.5rem;
}

.form-input {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

@media (max-width: 768px) {
  .financial-container {
    padding: 1rem;
  }

  .header-main {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
  }

  .stat-card {
    min-width: unset;
    width: 100%;
  }

  .charts-grid {
    grid-template-columns: 1fr;
  }

  .chart-wrapper {
    height: 300px;
  }

  .action-buttons {
    flex-direction: column;
  }

  .table-controls {
    flex-direction: column;
    align-items: flex-start;
  }

  .search-input {
    min-width: unset;
    width: 100%;
  }

  .summary-stats {
    flex-direction: column;
    gap: 1rem;
  }
}
</style>