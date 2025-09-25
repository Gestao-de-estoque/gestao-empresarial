<template>
  <div class="dashboard-container">
    <!-- Header Principal -->
    <header class="dashboard-header">
      <div class="header-main">
        <div class="header-left">
          <div class="welcome-section">
            <h1 class="welcome-title">
              <span class="greeting">{{ getGreeting() }}</span>
              <span class="username">{{ user?.name || 'Usuário' }}! 👋</span>
            </h1>
            <p class="welcome-subtitle">{{ getCurrentDateFormatted() }}</p>
          </div>
        </div>

        <div class="header-right">
          <div class="header-actions">
            <!-- Notificações -->
            <NotificationCenter />

            <!-- Busca rápida -->
            <div class="search-container">
              <Search :size="18" />
              <input
                v-model="quickSearch"
                type="text"
                placeholder="Busca rápida..."
                class="search-input"
                @keyup.enter="performQuickSearch"
              />
            </div>

            <!-- Perfil do usuário -->
            <div class="user-profile" @click="showProfile = !showProfile">
              <div class="user-avatar">
                <User :size="20" />
              </div>
              <div class="user-info">
                <span class="user-name">{{ user?.name }}</span>
                <span class="user-role">{{ getUserRole() }}</span>
              </div>
              <ChevronDown :size="16" class="dropdown-icon" />
            </div>

            <!-- Logout -->
            <button @click="handleLogout" class="logout-btn">
              <LogOut :size="18" />
            </button>
          </div>
        </div>
      </div>

      <!-- Estatísticas rápidas -->
      <div class="quick-stats">
        <div class="stat-card" v-for="stat in quickStats" :key="stat.label" :class="stat.type">
          <div class="stat-icon">
            <component :is="stat.icon" :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
            <div class="stat-change" :class="stat.changeType">
              <component :is="stat.changeType === 'positive' ? TrendingUp : TrendingDown" :size="14" />
              {{ stat.change }}
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Conteúdo Principal -->
    <main class="dashboard-main">
      <div class="dashboard-grid">
        <!-- Painel de Controle Rápido -->
        <section class="quick-actions-panel">
          <div class="panel-header">
            <h2>
              <Zap :size="20" />
              Ações Rápidas
            </h2>
          </div>
          <div class="quick-actions-grid">
            <router-link to="/inventory" class="quick-action-card inventory">
              <div class="action-icon">
                <Package :size="24" />
              </div>
              <div class="action-content">
                <h3>Gestão de Estoque</h3>
                <p>Gerenciar produtos e estoque</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/reports" class="quick-action-card reports">
              <div class="action-icon">
                <BarChart3 :size="24" />
              </div>
              <div class="action-content">
                <h3>Relatórios - Análises</h3>
                <p>Gráficos e relatórios completos</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/financial" class="quick-action-card financial">
              <div class="action-icon">
                <DollarSign :size="24" />
              </div>
              <div class="action-content">
                <h3>Análise Financeira</h3>
                <p>Receitas, salários e insights IA</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/ai" class="quick-action-card ai">
              <div class="action-icon">
                <Brain :size="24" />
              </div>
              <div class="action-content">
                <h3>Análise com IA</h3>
                <p>Insights inteligentes</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/suppliers" class="quick-action-card suppliers">
              <div class="action-icon">
                <Users :size="24" />
              </div>
              <div class="action-content">
                <h3>Fornecedores</h3>
                <p>Gerenciar fornecedores</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/menu" class="quick-action-card menu">
              <div class="action-icon">
                <ChefHat :size="24" />
              </div>
              <div class="action-content">
                <h3>Cardápio</h3>
                <p>Menu e planejamento</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/settings" class="quick-action-card settings">
              <div class="action-icon">
                <Settings :size="24" />
              </div>
              <div class="action-content">
                <h3>Configurações</h3>
                <p>Configurações do app</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/about" class="quick-action-card about">
              <div class="action-icon">
                <Info :size="24" />
              </div>
              <div class="action-content">
                <h3>Sobre</h3>
                <p>Informações do sistema</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>

            <router-link to="/doc" class="quick-action-card documentation">
              <div class="action-icon">
                <FileText :size="24" />
              </div>
              <div class="action-content">
                <h3>Documentação</h3>
                <p>Docs para desenvolvedores</p>
              </div>
              <ArrowRight :size="16" class="action-arrow" />
            </router-link>
          </div>
        </section>

        <!-- Gráfico de Vendas -->
        <section class="chart-panel sales-chart">
          <div class="panel-header">
            <h2>
              <TrendingUp :size="20" />
              Vendas dos Últimos 7 Dias
            </h2>
            <div class="chart-controls">
              <button
                v-for="period in ['7d', '30d', '90d']"
                :key="period"
                @click="selectedPeriod = period"
                :class="{ active: selectedPeriod === period }"
                class="period-btn"
              >
                {{ period }}
              </button>
            </div>
          </div>
          <div class="chart-container">
            <Line
              v-if="salesChartData.datasets.length > 0"
              :data="salesChartData"
              :options="salesChartOptions"
            />
            <div v-else class="chart-loading">
              <Loader2 :size="32" class="animate-spin" />
              <p>Carregando dados...</p>
            </div>
          </div>
        </section>

        <!-- Produtos em Falta -->
        <section class="alerts-panel">
          <div class="panel-header">
            <h2>
              <AlertTriangle :size="20" />
              Alertas do Sistema
            </h2>
            <button @click="refreshAlerts" class="refresh-btn">
              <RefreshCw :size="16" />
            </button>
          </div>
          <div class="alerts-list">
            <div v-if="alerts.length === 0" class="no-alerts">
              <CheckCircle :size="32" />
              <p>Tudo certo! Nenhum alerta no momento.</p>
            </div>
            <div v-else>
              <div
                v-for="alert in alerts"
                :key="alert.id"
                class="alert-item"
                :class="alert.type"
              >
                <div class="alert-icon">
                  <component :is="alert.icon" :size="20" />
                </div>
                <div class="alert-content">
                  <h4>{{ alert.title }}</h4>
                  <p>{{ alert.description }}</p>
                  <small>{{ formatDate(alert.date) }}</small>
                </div>
                <button @click="dismissAlert(alert.id)" class="dismiss-btn">
                  <X :size="16" />
                </button>
              </div>
            </div>
          </div>
        </section>

        <!-- Gráfico de Categorias -->
        <section class="chart-panel category-chart">
          <div class="panel-header">
            <h2>
              <PieChart :size="20" />
              Distribuição por Categoria
            </h2>
          </div>
          <div class="chart-container">
            <Doughnut
              v-if="categoryChartData.datasets.length > 0"
              :data="categoryChartData"
              :options="categoryChartOptions"
            />
            <div v-else class="chart-loading">
              <Loader2 :size="32" class="animate-spin" />
              <p>Carregando dados...</p>
            </div>
          </div>
        </section>

        <!-- Atividade Recente -->
        <section class="activity-panel">
          <div class="panel-header">
            <h2>
              <Activity :size="20" />
              Atividade Recente
            </h2>
            <router-link to="/logs" class="view-all-btn">
              Ver tudo
              <ExternalLink :size="14" />
            </router-link>
          </div>
          <div class="activity-list">
            <div
              v-for="activity in recentActivity"
              :key="activity.id"
              class="activity-item"
            >
              <div class="activity-icon" :class="activity.type">
                <component :is="activity.icon" :size="16" />
              </div>
              <div class="activity-content">
                <p>{{ activity.description }}</p>
                <small>{{ formatTimeAgo(activity.timestamp) }}</small>
              </div>
            </div>
          </div>
        </section>

        <!-- Estatísticas do Banco de Dados -->
        <section class="database-panel">
          <DatabaseStats />
        </section>

        <!-- Widget de Performance -->
        <section class="performance-panel">
          <div class="panel-header">
            <h2>
              <Gauge :size="20" />
              Performance do Sistema
            </h2>
          </div>
          <div class="performance-metrics">
            <div class="metric-item">
              <div class="metric-label">CPU</div>
              <div class="metric-bar">
                <div class="metric-fill" :style="{ width: systemMetrics.cpu + '%' }"></div>
              </div>
              <div class="metric-value">{{ systemMetrics.cpu }}%</div>
            </div>
            <div class="metric-item">
              <div class="metric-label">Memória</div>
              <div class="metric-bar">
                <div class="metric-fill" :style="{ width: systemMetrics.memory + '%' }"></div>
              </div>
              <div class="metric-value">{{ systemMetrics.memory }}%</div>
            </div>
            <div class="metric-item">
              <div class="metric-label">Storage</div>
              <div class="metric-bar">
                <div class="metric-fill" :style="{ width: systemMetrics.storage + '%' }"></div>
              </div>
              <div class="metric-value">{{ systemMetrics.storage }}%</div>
            </div>
          </div>
        </section>
      </div>
    </main>

    <!-- Modais e Overlays -->
    <Teleport to="body">

      <!-- Perfil do usuário -->
      <div v-if="showProfile" class="profile-overlay" @click="showProfile = false">
        <div class="profile-panel" @click.stop>
          <div class="profile-header">
            <div class="profile-avatar">
              <User :size="32" />
            </div>
            <div class="profile-info">
              <h3>{{ user?.name }}</h3>
              <p>{{ user?.email }}</p>
              <span class="profile-role">{{ getUserRole() }}</span>
            </div>
          </div>
          <div class="profile-actions">
            <button @click="editProfile" class="profile-action">
              <Settings :size="16" />
              Editar Perfil
            </button>
            <button @click="showSettings = true" class="profile-action">
              <Sliders :size="16" />
              Configurações
            </button>
            <hr>
            <button @click="handleLogout" class="profile-action logout">
              <LogOut :size="16" />
              Sair
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { productService } from '@/services/productService'
import { salesService } from '@/services/salesService'
import { Line, Doughnut } from 'vue-chartjs'
import { formatDistanceToNow, format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import NotificationCenter from '@/components/NotificationCenter.vue'
import DatabaseStats from '@/components/DatabaseStats.vue'

// Importar ícones do Lucide
import {
  Search, User, ChevronDown, LogOut, Zap, Package, Brain,
  BarChart3, Plus, ArrowRight, TrendingUp, TrendingDown, AlertTriangle,
  RefreshCw, CheckCircle, X, PieChart, Activity, ExternalLink,
  Gauge, Loader2, Settings, Sliders, Users, ChefHat, Info, DollarSign, FileText
} from 'lucide-vue-next'

// Importar configurações do Chart.js
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from 'chart.js'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
)

const router = useRouter()
const authStore = useAuthStore()

// Estados reativas
const user = computed(() => authStore.user)
const quickSearch = ref('')
const showProfile = ref(false)
const showSettings = ref(false)
// Removidas variáveis não utilizadas
// const showReports = ref(false)
// const showAddProduct = ref(false)
const selectedPeriod = ref('7d')

// Dados do dashboard
const quickStats = ref([
  {
    label: 'Produtos',
    value: '0',
    change: '+0%',
    changeType: 'positive',
    icon: Package,
    type: 'primary'
  },
  {
    label: 'Estoque Baixo',
    value: '0',
    change: '-0%',
    changeType: 'negative',
    icon: AlertTriangle,
    type: 'warning'
  },
  {
    label: 'Vendas Hoje',
    value: 'R$ 0',
    change: '+0%',
    changeType: 'positive',
    icon: TrendingUp,
    type: 'success'
  },
  {
    label: 'Valor Total',
    value: 'R$ 0',
    change: '+0%',
    changeType: 'positive',
    icon: BarChart3,
    type: 'info'
  }
])

const alerts = ref([
  {
    id: 1,
    type: 'warning',
    title: 'Estoque Baixo',
    description: '3 produtos com estoque abaixo do mínimo',
    icon: AlertTriangle,
    date: new Date()
  },
  {
    id: 2,
    type: 'info',
    title: 'Backup Realizado',
    description: 'Backup automático concluído com sucesso',
    icon: CheckCircle,
    date: new Date(Date.now() - 2 * 60 * 60 * 1000)
  }
])


const recentActivity = ref([
  {
    id: 1,
    type: 'add',
    description: 'Produto "Feijão Preto" adicionado',
    timestamp: new Date(Date.now() - 5 * 60 * 1000),
    icon: Plus
  },
  {
    id: 2,
    type: 'edit',
    description: 'Estoque de "Arroz" atualizado',
    timestamp: new Date(Date.now() - 15 * 60 * 1000),
    icon: Package
  },
  {
    id: 3,
    type: 'ai',
    description: 'Análise de IA executada',
    timestamp: new Date(Date.now() - 30 * 60 * 1000),
    icon: Brain
  }
])

const systemMetrics = ref({
  cpu: 45,
  memory: 62,
  storage: 78
})

// Dados dos gráficos
const salesChartData = ref<any>({
  labels: [],
  datasets: []
})

const categoryChartData = ref<any>({
  labels: [],
  datasets: []
})

// Configurações dos gráficos
const salesChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    },
    tooltip: {
      mode: 'index' as const,
      intersect: false,
    }
  },
  scales: {
    x: {
      display: true,
      grid: {
        display: false
      }
    },
    y: {
      display: true,
      grid: {
        color: 'rgba(0,0,0,0.1)'
      }
    }
  },
  elements: {
    line: {
      tension: 0.4
    },
    point: {
      radius: 4,
      hoverRadius: 6
    }
  }
}

const categoryChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom' as const,
      labels: {
        padding: 20,
        usePointStyle: true
      }
    }
  }
}

// Métodos
function getGreeting() {
  const hour = new Date().getHours()
  if (hour < 12) return 'Bom dia'
  if (hour < 18) return 'Boa tarde'
  return 'Boa noite'
}

function getCurrentDateFormatted() {
  return format(new Date(), 'EEEE, d \'de\' MMMM \'de\' yyyy', { locale: ptBR })
}

function getUserRole() {
  const roles: Record<string, string> = {
    admin: 'Administrador',
    manager: 'Gerente',
    stock_controller: 'Controlador de Estoque'
  }
  return roles[user.value?.role || ''] || 'Usuário'
}

function formatDate(date: Date) {
  return format(date, 'dd/MM/yyyy HH:mm')
}

function formatTimeAgo(date: Date) {
  return formatDistanceToNow(date, { addSuffix: true, locale: ptBR })
}

async function loadDashboardData() {
  try {
    // Carregar produtos
    const products = await productService.getProducts()
    const categories = await productService.getCategories()

    // Atualizar estatísticas básicas
    quickStats.value[0].value = products.length.toString()
    quickStats.value[1].value = products.filter(p => p.current_stock <= p.min_stock).length.toString()
    quickStats.value[3].value = `R$ ${formatCurrency(products.reduce((acc, p) => acc + (p.preco * p.current_stock), 0))}`

    // Buscar dados de vendas para estatísticas
    try {
      const salesSummary = await salesService.getSalesSummary()
      quickStats.value[2].value = `R$ ${formatCurrency(salesSummary.totalSales)}`
      quickStats.value[2].change = `${salesSummary.growth > 0 ? '+' : ''}${salesSummary.growth.toFixed(1)}%`
      quickStats.value[2].changeType = salesSummary.growth >= 0 ? 'positive' : 'negative'
    } catch (error) {
      console.warn('Erro ao buscar resumo de vendas:', error)
    }

    // Gerar dados de vendas (reais do Supabase)
    await updateSalesChart()

    // Gerar dados de categorias
    const categoryData = generateCategoryData(categories, products)
    categoryChartData.value = {
      labels: categoryData.labels,
      datasets: [{
        data: categoryData.values,
        backgroundColor: [
          '#667eea',
          '#764ba2',
          '#f093fb',
          '#4facfe',
          '#43e97b',
          '#fa709a'
        ]
      }]
    }

  } catch (error) {
    console.error('Erro ao carregar dados do dashboard:', error)
  }
}

async function generateSalesData() {
  try {
    console.log(`🔄 Buscando dados reais de vendas para ${selectedPeriod.value}...`)

    const salesData = await salesService.getSalesByPeriod(selectedPeriod.value as '7d' | '30d' | '90d')

    const labels: string[] = []
    const values: number[] = []

    salesData.forEach(dayData => {
      const date = new Date(dayData.date)
      labels.push(format(date, 'dd/MM'))
      values.push(Math.round(dayData.total_sales * 100) / 100)
    })

    console.log('✅ Dados de vendas carregados:', { labels, values })

    return { labels, values }
  } catch (error) {
    console.error('❌ Erro ao buscar dados de vendas, usando dados simulados:', error)

    // Fallback para dados simulados
    const labels: string[] = []
    const values: number[] = []

    const days = selectedPeriod.value === '7d' ? 7 : selectedPeriod.value === '30d' ? 30 : 90

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      labels.push(format(date, 'dd/MM'))
      values.push(Math.floor(Math.random() * 1000) + 500)
    }

    return { labels, values }
  }
}

async function updateSalesChart() {
  const salesData = await generateSalesData()
  salesChartData.value = {
    labels: salesData.labels,
    datasets: [{
      label: 'Vendas (R$)',
      data: salesData.values,
      borderColor: '#667eea',
      backgroundColor: 'rgba(102, 126, 234, 0.1)',
      fill: true
    }]
  }
}

function generateCategoryData(categories: any[], products: any[]) {
  const categoryCount: { [key: string]: number } = {}

  products.forEach(product => {
    const category = categories.find(c => c.id === product.categoria_id)
    const categoryName = category?.nome || 'Sem categoria'
    categoryCount[categoryName] = (categoryCount[categoryName] || 0) + 1
  })

  return {
    labels: Object.keys(categoryCount),
    values: Object.values(categoryCount)
  }
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

function performQuickSearch() {
  if (quickSearch.value.trim()) {
    router.push(`/inventory?search=${encodeURIComponent(quickSearch.value)}`)
  }
}

function refreshAlerts() {
  // Recarregar alertas
  loadDashboardData()
}

function dismissAlert(alertId: number) {
  const index = alerts.value.findIndex(alert => alert.id === alertId)
  if (index !== -1) {
    alerts.value.splice(index, 1)
  }
}

function editProfile() {
  showProfile.value = false
  router.push('/profile')
}

async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}

// Simular métricas do sistema
function updateSystemMetrics() {
  systemMetrics.value.cpu = Math.max(20, Math.min(80, systemMetrics.value.cpu + (Math.random() - 0.5) * 10))
  systemMetrics.value.memory = Math.max(30, Math.min(90, systemMetrics.value.memory + (Math.random() - 0.5) * 5))
  systemMetrics.value.storage = Math.max(50, Math.min(95, systemMetrics.value.storage + (Math.random() - 0.5) * 2))
}

let metricsInterval: NodeJS.Timeout

// Watcher para atualizar gráfico quando mudar o período
watch(selectedPeriod, () => {
  updateSalesChart()
})

onMounted(() => {
  loadDashboardData()
  metricsInterval = setInterval(updateSystemMetrics, 5000)
})

onUnmounted(() => {
  if (metricsInterval) {
    clearInterval(metricsInterval)
  }
})
</script>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  width: 100vw;
  background: var(--theme-background);
  font-family: 'Inter', system-ui, sans-serif;
  overflow-x: hidden;
}

/* Header */
.dashboard-header {
  background: var(--theme-surface);
  box-shadow: 0 2px 20px var(--theme-shadow);
  border-bottom: 1px solid var(--theme-border);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 20px 20px 80px; /* Espaço extra à esquerda para o botão hambúrguer */
  width: 100%;
  margin: 0;
}

.welcome-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.welcome-title {
  font-size: 28px;
  font-weight: 700;
  margin: 0;
  color: var(--theme-text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
}

.greeting {
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.welcome-subtitle {
  color: var(--theme-text-secondary);
  font-size: 14px;
  font-weight: 500;
  text-transform: capitalize;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notification-btn {
  position: relative;
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #64748b;
}

.notification-btn:hover {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.notification-btn.has-notifications {
  background: #fef3cd;
  border-color: #fbbf24;
  color: #d97706;
}

.notification-count {
  position: absolute;
  top: -4px;
  right: -4px;
  background: #ef4444;
  color: white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  font-size: 11px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-container {
  position: relative;
  display: flex;
  align-items: center;
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 0 16px;
  transition: all 0.3s ease;
}

.search-container:focus-within {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.search-input {
  background: none;
  border: none;
  outline: none;
  padding: 12px 8px;
  font-size: 14px;
  width: 200px;
  color: #1a202c;
}

.search-input::placeholder {
  color: #94a3b8;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 8px 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.user-profile:hover {
  background: #e2e8f0;
}

.user-avatar {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.user-name {
  font-size: 14px;
  font-weight: 600;
  color: #1a202c;
}

.user-role {
  font-size: 12px;
  color: #64748b;
}

.logout-btn {
  background: #fef2f2;
  border: 2px solid #fecaca;
  border-radius: 12px;
  padding: 12px;
  color: #dc2626;
  cursor: pointer;
  transition: all 0.3s ease;
}

.logout-btn:hover {
  background: #dc2626;
  color: white;
  border-color: #dc2626;
}

/* Estatísticas rápidas */
.quick-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  padding: 20px;
  width: 100%;
  margin: 0;
}

.stat-card {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px var(--theme-shadow);
  border: 1px solid var(--theme-border);
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.stat-card.primary .stat-icon {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.stat-card.warning .stat-icon {
  background: linear-gradient(135deg, #f59e0b, #d97706);
}

.stat-card.success .stat-icon {
  background: linear-gradient(135deg, #10b981, #059669);
}

.stat-card.info .stat-icon {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 800;
  color: var(--theme-text-primary);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: var(--theme-text-secondary);
  font-weight: 500;
  margin-bottom: 8px;
}

.stat-change {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.stat-change.positive {
  color: #10b981;
}

.stat-change.negative {
  color: #ef4444;
}

/* Conteúdo principal */
.dashboard-main {
  padding: 20px;
  width: 100%;
  max-width: none;
  margin: 0;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 24px;
}

/* Painéis */
.quick-actions-panel {
  grid-column: span 12;
}

.sales-chart {
  grid-column: span 8;
}

.alerts-panel {
  grid-column: span 4;
}

.category-chart {
  grid-column: span 6;
}

.activity-panel {
  grid-column: span 6;
}

.database-panel {
  grid-column: span 8;
}

.performance-panel {
  grid-column: span 4;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.panel-header h2 {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 700;
  color: var(--theme-text-primary);
  margin: 0;
}

.chart-panel,
.alerts-panel,
.activity-panel,
.performance-panel,
.quick-actions-panel {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px var(--theme-shadow);
  border: 1px solid var(--theme-border);
}

/* Ações rápidas */
.quick-actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
}

.quick-action-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  text-decoration: none;
  color: inherit;
  transition: all 0.3s ease;
  cursor: pointer;
}

.quick-action-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #667eea;
}

.quick-action-card.inventory:hover {
  background: linear-gradient(135deg, #667eea10, #764ba210);
}

.quick-action-card.reports:hover {
  background: linear-gradient(135deg, #4facfe10, #00f2fe10);
}

.quick-action-card.financial:hover {
  background: linear-gradient(135deg, #10b98110, #06b6d410);
}
.quick-action-card.ai:hover {
  background: linear-gradient(135deg, #f093fb10, #f5576c10);
}

.quick-action-card.suppliers:hover {
  background: linear-gradient(135deg, #8b5cf610, #a855f710);
}

.quick-action-card.menu:hover {
  background: linear-gradient(135deg, #f59e0b10, #d9770610);
}

.quick-action-card.settings:hover {
  background: linear-gradient(135deg, #64748b10, #47556910);
}

.quick-action-card.about:hover {
  background: linear-gradient(135deg, #06b6d410, #0891b210);
}

.quick-action-card.documentation:hover {
  background: linear-gradient(135deg, #8b5cf610, #a855f710);
}

.action-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #667eea;
  background: white;
}

.action-content h3 {
  font-size: 16px;
  font-weight: 600;
  color: #1a202c;
  margin: 0 0 4px 0;
}

.action-content p {
  font-size: 14px;
  color: #64748b;
  margin: 0;
}

.action-arrow {
  color: #94a3b8;
  transition: transform 0.3s ease;
}

.quick-action-card:hover .action-arrow {
  transform: translateX(4px);
}

/* Controles de gráfico */
.chart-controls {
  display: flex;
  gap: 8px;
}

.period-btn {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 6px 12px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #64748b;
}

.period-btn:hover {
  background: #e2e8f0;
}

.period-btn.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

/* Container de gráfico */
.chart-container {
  height: 300px;
  position: relative;
}

.chart-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #64748b;
  gap: 16px;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Alertas */
.alerts-list {
  max-height: 400px;
  overflow-y: auto;
}

.no-alerts {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #64748b;
  gap: 12px;
}

.alert-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
  margin-bottom: 12px;
  border-left: 4px solid #e2e8f0;
}

.alert-item.warning {
  border-left-color: #f59e0b;
  background: #fffbeb;
}

.alert-item.info {
  border-left-color: #3b82f6;
  background: #eff6ff;
}

.alert-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  color: #64748b;
}

.alert-content {
  flex: 1;
}

.alert-content h4 {
  font-size: 14px;
  font-weight: 600;
  color: #1a202c;
  margin: 0 0 4px 0;
}

.alert-content p {
  font-size: 13px;
  color: #64748b;
  margin: 0 0 8px 0;
}

.alert-content small {
  font-size: 12px;
  color: #94a3b8;
}

.dismiss-btn {
  background: none;
  border: none;
  color: #94a3b8;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.dismiss-btn:hover {
  background: #f1f5f9;
  color: #64748b;
}

/* Atividade recente */
.activity-list {
  max-height: 400px;
  overflow-y: auto;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f1f5f9;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8fafc;
  color: #64748b;
}

.activity-icon.add {
  background: #dcfce7;
  color: #16a34a;
}

.activity-icon.edit {
  background: #fef3c7;
  color: #d97706;
}

.activity-icon.ai {
  background: #f3e8ff;
  color: #9333ea;
}

.activity-content p {
  font-size: 14px;
  color: #1a202c;
  margin: 0 0 4px 0;
}

.activity-content small {
  font-size: 12px;
  color: #94a3b8;
}

/* Performance */
.performance-metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 24px;
}

.metric-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.metric-label {
  font-size: 14px;
  font-weight: 600;
  color: #1a202c;
  min-width: 60px;
}

.metric-bar {
  flex: 1;
  height: 8px;
  background: #f1f5f9;
  border-radius: 4px;
  overflow: hidden;
}

.metric-fill {
  height: 100%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 4px;
  transition: width 0.3s ease;
}

.metric-value {
  font-size: 14px;
  font-weight: 600;
  color: #1a202c;
  min-width: 40px;
  text-align: right;
}

/* Overlays e modais */
.notifications-overlay,
.profile-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
  padding: 20px;
}

.notifications-panel,
.profile-panel {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 400px;
  max-height: 80vh;
  overflow: hidden;
  animation: slideInRight 0.3s ease-out;
}

.profile-panel {
  width: 300px;
}

@keyframes slideInRight {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.notifications-header,
.profile-header {
  padding: 20px;
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.profile-header {
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 12px;
}

.profile-avatar {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.profile-info h3 {
  font-size: 18px;
  font-weight: 700;
  color: #1a202c;
  margin: 0;
}

.profile-info p {
  font-size: 14px;
  color: #64748b;
  margin: 4px 0;
}

.profile-role {
  background: #f8fafc;
  color: #667eea;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.notifications-list {
  max-height: 400px;
  overflow-y: auto;
  padding: 0 20px 20px;
}

.profile-actions {
  padding: 20px;
}

.profile-action {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 12px 16px;
  background: none;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  color: #1a202c;
  text-align: left;
}

.profile-action:hover {
  background: #f8fafc;
}

.profile-action.logout {
  color: #dc2626;
}

.profile-action.logout:hover {
  background: #fef2f2;
}

.no-notifications {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #64748b;
  gap: 16px;
}

.notification-item {
  padding: 16px;
  border-radius: 12px;
  margin-bottom: 12px;
  background: #f8fafc;
  border-left: 4px solid #e2e8f0;
}

.notification-item.unread {
  background: #eff6ff;
  border-left-color: #3b82f6;
}

.notification-content h4 {
  font-size: 14px;
  font-weight: 600;
  color: #1a202c;
  margin: 0 0 4px 0;
}

.notification-content p {
  font-size: 13px;
  color: #64748b;
  margin: 0 0 8px 0;
}

.notification-content small {
  font-size: 12px;
  color: #94a3b8;
}

/* Utilitários */
.view-all-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #667eea;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.3s ease;
}

.view-all-btn:hover {
  color: #5a67d8;
}

.refresh-btn {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #64748b;
}

.refresh-btn:hover {
  background: #e2e8f0;
  color: #1a202c;
}

/* Responsividade */
@media (max-width: 1200px) {
  .dashboard-grid {
    grid-template-columns: repeat(8, 1fr);
  }

  .sales-chart {
    grid-column: span 8;
  }

  .alerts-panel {
    grid-column: span 8;
  }

  .category-chart,
  .activity-panel {
    grid-column: span 4;
  }
}

@media (max-width: 768px) {
  .dashboard-container {
    background: white;
  }

  .header-main {
    flex-direction: column;
    gap: 20px;
    align-items: stretch;
    padding: 20px 20px 20px 60px; /* Menor espaçamento à esquerda em mobile */
  }

  .header-actions {
    justify-content: space-between;
  }

  .quick-stats {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    padding: 20px;
  }

  .dashboard-main {
    padding: 20px;
  }

  .dashboard-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .sales-chart,
  .alerts-panel,
  .category-chart,
  .activity-panel,
  .performance-panel,
  .quick-actions-panel {
    grid-column: span 1;
  }

  .quick-actions-grid {
    grid-template-columns: 1fr;
  }

  .search-input {
    width: 150px;
  }

  .user-info {
    display: none;
  }

  .notifications-panel,
  .profile-panel {
    width: calc(100vw - 40px);
    max-width: 400px;
  }
}

@media (max-width: 480px) {
  .quick-stats {
    grid-template-columns: 1fr;
  }

  .stat-card {
    padding: 16px;
  }

  .stat-value {
    font-size: 24px;
  }

  .welcome-title {
    font-size: 20px;
  }

  .header-actions {
    gap: 12px;
  }

  .search-container {
    display: none;
  }
}
</style>