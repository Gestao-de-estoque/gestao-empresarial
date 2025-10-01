<template>
  <div class="employee-management-container">
    <!-- Header Principal -->
    <div class="management-header">
      <div class="header-main">
        <div class="header-left">
          <div class="title-section">
            <h1 class="page-title">
              <Users :size="32" />
              Gestão de Funcionários
            </h1>
            <p class="page-subtitle">
              Gerencie sua equipe, pagamentos e desempenho em um só lugar
            </p>
          </div>
        </div>
        <div class="header-actions">
          <button @click="showAddEmployeeModal = true" class="btn-primary">
            <UserPlus :size="18" />
            Adicionar Funcionário
          </button>
          <button @click="showProcessPaymentsModal = true" class="btn-success">
            <DollarSign :size="18" />
            Processar Pagamentos
          </button>
          <button @click="refreshData" class="btn-secondary" :disabled="loading">
            <RefreshCw :size="18" :class="{ 'animate-spin': loading }" />
            Atualizar
          </button>
        </div>
      </div>

      <!-- Quick Stats -->
      <div class="quick-stats-grid">
        <div class="stat-card primary">
          <div class="stat-icon">
            <Users :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ employees.filter(e => e.status === 'ativo').length }}</div>
            <div class="stat-label">Funcionários Ativos</div>
          </div>
        </div>
        <div class="stat-card success">
          <div class="stat-icon">
            <DollarSign :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatCurrency(totalPaymentsThisMonth) }}</div>
            <div class="stat-label">Pagamentos do Mês</div>
          </div>
        </div>
        <div class="stat-card warning">
          <div class="stat-icon">
            <Clock :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ pendingPayments.length }}</div>
            <div class="stat-label">Pagamentos Pendentes</div>
          </div>
        </div>
        <div class="stat-card info">
          <div class="stat-icon">
            <TrendingUp :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatCurrency(averageDailyPayment) }}</div>
            <div class="stat-label">Média Diária</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs Navigation -->
    <div class="tabs-container">
      <div class="tabs-nav">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          @click="activeTab = tab.id"
          :class="['tab-button', { active: activeTab === tab.id }]"
        >
          <component :is="tab.icon" :size="18" />
          {{ tab.label }}
        </button>
      </div>
    </div>

    <!-- Tab Content -->
    <div class="tab-content">
      <!-- Tab: Funcionários -->
      <div v-if="activeTab === 'employees'" class="employees-tab">
        <div class="toolbar">
          <div class="search-container">
            <Search :size="18" />
            <input
              v-model="searchTerm"
              type="text"
              placeholder="Buscar funcionários..."
              class="search-input"
            />
          </div>
          <div class="filters">
            <select v-model="filterPosition" class="select-modern">
              <option value="">Todas as Funções</option>
              <option value="garcom">Garçom</option>
              <option value="balconista">Balconista</option>
              <option value="barmen">Barmen</option>
              <option value="cozinheiro">Cozinheiro</option>
              <option value="cozinheiro_chef">Cozinheiro Chef</option>
            </select>
            <select v-model="filterStatus" class="select-modern">
              <option value="">Todos os Status</option>
              <option value="ativo">Ativo</option>
              <option value="inativo">Inativo</option>
              <option value="ferias">Férias</option>
              <option value="afastado">Afastado</option>
            </select>
          </div>
        </div>

        <div class="employees-grid">
          <div
            v-for="employee in filteredEmployees"
            :key="employee.id"
            class="employee-card"
            @click="selectEmployee(employee)"
          >
            <div class="employee-header">
              <div class="employee-photo">
                <img v-if="employee.photo_url" :src="employee.photo_url" :alt="employee.name" />
                <User v-else :size="32" />
              </div>
              <div class="employee-badges">
                <span :class="['badge', 'status', employee.status]">
                  {{ employee.status }}
                </span>
                <span :class="['badge', 'position']">
                  {{ EMPLOYEE_POSITIONS[employee.position] }}
                </span>
              </div>
            </div>
            <div class="employee-info">
              <h3>{{ employee.name }}</h3>
              <p class="email">
                <Mail :size="14" />
                {{ employee.email }}
              </p>
              <p v-if="employee.phone" class="phone">
                <Phone :size="14" />
                {{ employee.phone }}
              </p>
            </div>
            <div class="employee-stats">
              <div class="stat">
                <span class="stat-label">Contratado em</span>
                <span class="stat-value">{{ formatDate(employee.hire_date) }}</span>
              </div>
            </div>
            <div class="employee-actions">
              <button @click.stop="editEmployee(employee)" class="btn-icon edit">
                <Edit :size="16" />
              </button>
              <button @click.stop="viewPayments(employee)" class="btn-icon view">
                <DollarSign :size="16" />
              </button>
              <button @click.stop="manageBankAccounts(employee)" class="btn-icon bank">
                <CreditCard :size="16" />
              </button>
              <button @click.stop="deleteEmployee(employee)" class="btn-icon delete">
                <Trash2 :size="16" />
              </button>
            </div>
          </div>
        </div>

        <div v-if="filteredEmployees.length === 0" class="empty-state">
          <Users :size="64" />
          <h3>Nenhum funcionário encontrado</h3>
          <p>Adicione funcionários para começar a gerenciar sua equipe</p>
          <button @click="showAddEmployeeModal = true" class="btn-primary">
            <UserPlus :size="18" />
            Adicionar Funcionário
          </button>
        </div>
      </div>

      <!-- Tab: Pagamentos -->
      <div v-if="activeTab === 'payments'" class="payments-tab">
        <div class="toolbar">
          <div class="date-range">
            <label>De</label>
            <input v-model="paymentDateFrom" type="date" class="date-input" />
            <label>Até</label>
            <input v-model="paymentDateTo" type="date" class="date-input" />
            <button @click="loadPayments" class="btn-secondary">
              <Filter :size="16" />
              Filtrar
            </button>
          </div>
          <div class="actions">
            <button @click="exportPayments" class="btn-export">
              <Download :size="16" />
              Exportar
            </button>
          </div>
        </div>

        <div class="payments-table-container">
          <table class="payments-table">
            <thead>
              <tr>
                <th>Data</th>
                <th>Funcionário</th>
                <th>Função</th>
                <th>Receita Diária</th>
                <th>Salário Base</th>
                <th>Bônus</th>
                <th>Deduções</th>
                <th>Valor Final</th>
                <th>Status</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="payment in payments" :key="payment.id" class="payment-row">
                <td class="date-cell">{{ formatDate(payment.payment_date) }}</td>
                <td class="employee-cell">
                  <div class="employee-mini">
                    <div class="mini-photo">
                      <img v-if="payment.employee?.photo_url" :src="payment.employee.photo_url" alt="" />
                      <User v-else :size="20" />
                    </div>
                    <span>{{ payment.employee?.name }}</span>
                  </div>
                </td>
                <td>{{ EMPLOYEE_POSITIONS[payment.employee?.position || 'garcom'] }}</td>
                <td class="currency">{{ formatCurrency(payment.daily_revenue) }}</td>
                <td class="currency">{{ formatCurrency(payment.base_salary) }}</td>
                <td class="currency bonus">{{ formatCurrency(payment.bonus) }}</td>
                <td class="currency deduction">{{ formatCurrency(payment.deductions) }}</td>
                <td class="currency total">{{ formatCurrency(payment.final_amount) }}</td>
                <td>
                  <span :class="['status-badge', payment.payment_status]">
                    {{ PAYMENT_STATUS_LABELS[payment.payment_status] }}
                  </span>
                </td>
                <td class="actions-cell">
                  <button
                    v-if="payment.payment_status === 'pendente'"
                    @click="markAsPaid(payment)"
                    class="btn-icon success"
                    title="Marcar como pago"
                  >
                    <Check :size="16" />
                  </button>
                  <button @click="viewPaymentDetails(payment)" class="btn-icon view" title="Ver detalhes">
                    <Eye :size="16" />
                  </button>
                  <button
                    v-if="payment.payment_status === 'pendente'"
                    @click="editPayment(payment)"
                    class="btn-icon edit"
                    title="Editar"
                  >
                    <Edit :size="16" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="payments.length === 0" class="empty-state">
          <DollarSign :size="64" />
          <h3>Nenhum pagamento encontrado</h3>
          <p>Processe pagamentos para ver o histórico aqui</p>
        </div>
      </div>

      <!-- Tab: Configurações de Salário -->
      <div v-if="activeTab === 'salary'" class="salary-tab">
        <div class="salary-configs-grid">
          <div
            v-for="config in salaryConfigs"
            :key="config.position"
            class="salary-config-card"
          >
            <div class="config-header">
              <h3>{{ EMPLOYEE_POSITIONS[config.position] }}</h3>
              <span :class="['type-badge', config.calculation_type]">
                {{ config.calculation_type === 'fixed' ? 'Fixo' : config.calculation_type === 'percentage' ? 'Percentual' : 'Misto' }}
              </span>
            </div>
            <div class="config-details">
              <div v-if="config.fixed_daily_amount > 0" class="detail-item">
                <span class="label">Valor Fixo Diário:</span>
                <span class="value">{{ formatCurrency(config.fixed_daily_amount) }}</span>
              </div>
              <div v-if="config.percentage_rate > 0" class="detail-item">
                <span class="label">Taxa Percentual:</span>
                <span class="value">{{ config.percentage_rate }}%</span>
              </div>
              <div v-if="config.min_daily_guarantee > 0" class="detail-item">
                <span class="label">Garantia Mínima:</span>
                <span class="value">{{ formatCurrency(config.min_daily_guarantee) }}</span>
              </div>
              <div v-if="config.max_daily_limit" class="detail-item">
                <span class="label">Limite Máximo:</span>
                <span class="value">{{ formatCurrency(config.max_daily_limit) }}</span>
              </div>
            </div>
            <div v-if="config.description" class="config-description">
              <p>{{ config.description }}</p>
            </div>
            <div class="config-actions">
              <button @click="editSalaryConfig(config)" class="btn-edit">
                <Settings :size="16" />
                Configurar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Dashboard -->
      <div v-if="activeTab === 'dashboard'" class="dashboard-tab">
        <div class="dashboard-grid">
          <!-- Performance de Garçons -->
          <div class="dashboard-card full-width">
            <div class="card-header">
              <h3>
                <Award :size="20" />
                Performance dos Garçons - Este Mês
              </h3>
            </div>
            <div class="garcom-performance-list">
              <div
                v-for="(garcom, index) in garcomPerformance"
                :key="garcom.id"
                class="garcom-performance-item"
              >
                <div class="rank">{{ index + 1 }}</div>
                <div class="garcom-info">
                  <div class="photo">
                    <img v-if="garcom.photo_url" :src="garcom.photo_url" :alt="garcom.name" />
                    <User v-else :size="24" />
                  </div>
                  <div class="info">
                    <h4>{{ garcom.name }}</h4>
                    <p>{{ garcom.days_worked_this_month }} dias trabalhados</p>
                  </div>
                </div>
                <div class="garcom-stats">
                  <div class="stat">
                    <span class="label">Total Ganho</span>
                    <span class="value primary">{{ formatCurrency(garcom.total_earned_this_month) }}</span>
                  </div>
                  <div class="stat">
                    <span class="label">Média Diária</span>
                    <span class="value">{{ formatCurrency(garcom.average_daily_earning) }}</span>
                  </div>
                  <div class="stat">
                    <span class="label">Melhor Dia</span>
                    <span class="value success">{{ formatCurrency(garcom.best_day_earning) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Gráfico de Pagamentos por Função -->
          <div class="dashboard-card">
            <div class="card-header">
              <h3>
                <BarChart3 :size="20" />
                Pagamentos por Função
              </h3>
            </div>
            <div class="chart-wrapper">
              <Bar v-if="paymentsByPositionData.datasets.length" :data="paymentsByPositionData" :options="barChartOptions" />
            </div>
          </div>

          <!-- Tendência de Pagamentos -->
          <div class="dashboard-card">
            <div class="card-header">
              <h3>
                <TrendingUp :size="20" />
                Tendência de Pagamentos
              </h3>
            </div>
            <div class="chart-wrapper">
              <Line v-if="paymentsTrendData.datasets.length" :data="paymentsTrendData" :options="lineChartOptions" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <EmployeeFormModal
      v-if="showAddEmployeeModal || editingEmployee"
      :employee="editingEmployee"
      @close="closeEmployeeModal"
      @save="handleSaveEmployee"
    />

    <BankAccountModal
      v-if="showBankAccountModal"
      :employee="selectedEmployee"
      @close="showBankAccountModal = false"
      @refresh="loadEmployees"
    />

    <ProcessPaymentsModal
      v-if="showProcessPaymentsModal"
      @close="showProcessPaymentsModal = false"
      @success="handlePaymentsProcessed"
    />

    <PaymentDetailsModal
      v-if="showPaymentDetailsModal && selectedPayment"
      :payment="selectedPayment"
      @close="showPaymentDetailsModal = false"
    />

    <SalaryConfigModal
      v-if="showSalaryConfigModal && editingSalaryConfig"
      :config="editingSalaryConfig"
      @close="closeSalaryConfigModal"
      @save="handleSaveSalaryConfig"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Users, UserPlus, DollarSign, RefreshCw, Clock, TrendingUp,
  Search, Edit, Trash2, User, Mail, Phone, CreditCard, Download,
  Filter, Check, Eye, Settings, Award, BarChart3
} from 'lucide-vue-next'
import { Bar, Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js'
import { employeeService } from '@/services/employeeService'
import type {
  Employee,
  DailyPayment,
  SalaryConfig,
  GarcomPerformance,
  PendingPayment,
  MonthlyPaymentAnalysis
} from '@/types/employee'
import { EMPLOYEE_POSITIONS, PAYMENT_STATUS_LABELS } from '@/types/employee'
import EmployeeFormModal from '@/components/employee/EmployeeFormModal.vue'
import BankAccountModal from '@/components/employee/BankAccountModal.vue'
import ProcessPaymentsModal from '@/components/employee/ProcessPaymentsModal.vue'
import PaymentDetailsModal from '@/components/employee/PaymentDetailsModal.vue'
import SalaryConfigModal from '@/components/employee/SalaryConfigModal.vue'

// Register Chart.js components
ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
)

// State
const loading = ref(false)
const activeTab = ref('employees')
const searchTerm = ref('')
const filterPosition = ref('')
const filterStatus = ref('')
const paymentDateFrom = ref('')
const paymentDateTo = ref('')

const employees = ref<Employee[]>([])
const payments = ref<DailyPayment[]>([])
const salaryConfigs = ref<SalaryConfig[]>([])
const garcomPerformance = ref<GarcomPerformance[]>([])
const pendingPayments = ref<PendingPayment[]>([])
const monthlyAnalysis = ref<MonthlyPaymentAnalysis[]>([])

const showAddEmployeeModal = ref(false)
const showBankAccountModal = ref(false)
const showProcessPaymentsModal = ref(false)
const showPaymentDetailsModal = ref(false)
const showSalaryConfigModal = ref(false)

const editingEmployee = ref<Employee | null>(null)
const selectedEmployee = ref<Employee | null>(null)
const selectedPayment = ref<DailyPayment | null>(null)
const editingSalaryConfig = ref<SalaryConfig | null>(null)

// Tabs configuration
const tabs = [
  { id: 'employees', label: 'Funcionários', icon: Users },
  { id: 'payments', label: 'Pagamentos', icon: DollarSign },
  { id: 'salary', label: 'Configurações de Salário', icon: Settings },
  { id: 'dashboard', label: 'Dashboard', icon: BarChart3 }
]

// Computed
const filteredEmployees = computed(() => {
  return employees.value.filter(emp => {
    const matchesSearch = emp.name.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
                         emp.email.toLowerCase().includes(searchTerm.value.toLowerCase())
    const matchesPosition = !filterPosition.value || emp.position === filterPosition.value
    const matchesStatus = !filterStatus.value || emp.status === filterStatus.value
    return matchesSearch && matchesPosition && matchesStatus
  })
})

const totalPaymentsThisMonth = computed(() => {
  const now = new Date()
  const thisMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
  return payments.value
    .filter(p => p.payment_date.startsWith(thisMonth) && p.payment_status === 'pago')
    .reduce((sum, p) => sum + p.final_amount, 0)
})

const averageDailyPayment = computed(() => {
  const paidPayments = payments.value.filter(p => p.payment_status === 'pago')
  return paidPayments.length > 0
    ? paidPayments.reduce((sum, p) => sum + p.final_amount, 0) / paidPayments.length
    : 0
})

const paymentsByPositionData = computed(() => {
  const positionTotals = new Map<string, number>()

  payments.value
    .filter(p => p.payment_status === 'pago')
    .forEach(payment => {
      const position = payment.employee?.position || 'garcom'
      const current = positionTotals.get(position) || 0
      positionTotals.set(position, current + payment.final_amount)
    })

  return {
    labels: Array.from(positionTotals.keys()).map(p => EMPLOYEE_POSITIONS[p as keyof typeof EMPLOYEE_POSITIONS]),
    datasets: [{
      label: 'Total de Pagamentos',
      data: Array.from(positionTotals.values()),
      backgroundColor: [
        'rgba(59, 130, 246, 0.8)',
        'rgba(16, 185, 129, 0.8)',
        'rgba(245, 158, 11, 0.8)',
        'rgba(239, 68, 68, 0.8)',
        'rgba(139, 92, 246, 0.8)'
      ]
    }]
  }
})

const paymentsTrendData = computed(() => {
  // Group by date
  const dateMap = new Map<string, number>()
  payments.value
    .filter(p => p.payment_status === 'pago')
    .forEach(payment => {
      const current = dateMap.get(payment.payment_date) || 0
      dateMap.set(payment.payment_date, current + payment.final_amount)
    })

  const sortedDates = Array.from(dateMap.keys()).sort()

  return {
    labels: sortedDates.map(d => formatDate(d)),
    datasets: [{
      label: 'Total de Pagamentos',
      data: sortedDates.map(d => dateMap.get(d) || 0),
      borderColor: '#3b82f6',
      backgroundColor: 'rgba(59, 130, 246, 0.1)',
      fill: true,
      tension: 0.4
    }]
  }
})

const barChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
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

const lineChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
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

// Methods
async function loadEmployees() {
  try {
    employees.value = await employeeService.getAllEmployees()
  } catch (error) {
    console.error('Erro ao carregar funcionários:', error)
  }
}

async function loadPayments() {
  try {
    if (paymentDateFrom.value && paymentDateTo.value) {
      payments.value = await employeeService.getPaymentsByDateRange(paymentDateFrom.value, paymentDateTo.value)
    } else {
      payments.value = await employeeService.getAllPayments()
    }
  } catch (error) {
    console.error('Erro ao carregar pagamentos:', error)
  }
}

async function loadSalaryConfigs() {
  try {
    salaryConfigs.value = await employeeService.getAllSalaryConfigs()
  } catch (error) {
    console.error('Erro ao carregar configurações de salário:', error)
  }
}

async function loadDashboardData() {
  try {
    const [garcomPerf, pending, monthly] = await Promise.all([
      employeeService.getGarcomPerformance(),
      employeeService.getPendingPayments(),
      employeeService.getMonthlyPaymentAnalysis()
    ])
    garcomPerformance.value = garcomPerf
    pendingPayments.value = pending
    monthlyAnalysis.value = monthly
  } catch (error) {
    console.error('Erro ao carregar dados do dashboard:', error)
  }
}

async function refreshData() {
  loading.value = true
  try {
    await Promise.all([
      loadEmployees(),
      loadPayments(),
      loadSalaryConfigs(),
      loadDashboardData()
    ])
  } finally {
    loading.value = false
  }
}

function selectEmployee(employee: Employee) {
  selectedEmployee.value = employee
}

function editEmployee(employee: Employee) {
  editingEmployee.value = employee
}

function viewPayments(employee: Employee) {
  selectedEmployee.value = employee
  activeTab.value = 'payments'
  // Filter payments by employee
}

function manageBankAccounts(employee: Employee) {
  selectedEmployee.value = employee
  showBankAccountModal.value = true
}

async function deleteEmployee(employee: Employee) {
  if (!confirm(`Tem certeza que deseja remover ${employee.name}?`)) return

  try {
    await employeeService.deleteEmployee(employee.id!)
    await loadEmployees()
  } catch (error) {
    console.error('Erro ao remover funcionário:', error)
    alert('Erro ao remover funcionário')
  }
}

function closeEmployeeModal() {
  showAddEmployeeModal.value = false
  editingEmployee.value = null
}

async function handleSaveEmployee() {
  closeEmployeeModal()
  await loadEmployees()
}

async function handlePaymentsProcessed() {
  showProcessPaymentsModal.value = false
  await loadPayments()
  await loadDashboardData()
}

async function markAsPaid(payment: DailyPayment) {
  const method = prompt('Método de pagamento (pix, transferencia, dinheiro, cheque):')
  if (!method) return

  try {
    await employeeService.markPaymentAsPaid(payment.id!, method)
    await loadPayments()
    await loadDashboardData()
  } catch (error) {
    console.error('Erro ao marcar pagamento como pago:', error)
    alert('Erro ao processar pagamento')
  }
}

function viewPaymentDetails(payment: DailyPayment) {
  selectedPayment.value = payment
  showPaymentDetailsModal.value = true
}

function editPayment(_payment: DailyPayment) {
  // TODO: Implement edit payment
  console.log('Edit payment functionality to be implemented')
}

function editSalaryConfig(config: SalaryConfig) {
  editingSalaryConfig.value = config
  showSalaryConfigModal.value = true
}

function closeSalaryConfigModal() {
  showSalaryConfigModal.value = false
  editingSalaryConfig.value = null
}

async function handleSaveSalaryConfig() {
  closeSalaryConfigModal()
  await loadSalaryConfigs()
}

function exportPayments() {
  const csvContent = 'data:text/csv;charset=utf-8,' +
    'Data,Funcionário,Função,Receita Diária,Salário Base,Bônus,Deduções,Valor Final,Status\n' +
    payments.value.map(p =>
      `${p.payment_date},${p.employee?.name},${EMPLOYEE_POSITIONS[p.employee?.position || 'garcom']},${p.daily_revenue},${p.base_salary},${p.bonus},${p.deductions},${p.final_amount},${PAYMENT_STATUS_LABELS[p.payment_status]}`
    ).join('\n')

  const link = document.createElement('a')
  link.setAttribute('href', encodeURI(csvContent))
  link.setAttribute('download', `pagamentos_${new Date().toISOString().split('T')[0]}.csv`)
  link.click()
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(value)
}

function formatDate(dateStr: string): string {
  if (!dateStr) return ''
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString('pt-BR')
}

// Lifecycle
onMounted(() => {
  refreshData()
})
</script>

<style scoped>
.employee-management-container {
  padding: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.management-header {
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
  margin-bottom: 2rem;
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

.btn-primary, .btn-secondary, .btn-success, .btn-export, .btn-edit {
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

.btn-success {
  background: linear-gradient(45deg, #10b981, #059669);
  color: white;
  box-shadow: 0 10px 25px rgba(16, 185, 129, 0.3);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.9);
  color: #374151;
  border: 1px solid #e5e7eb;
}

.btn-export {
  background: linear-gradient(45deg, #f59e0b, #d97706);
  color: white;
}

.btn-edit {
  background: linear-gradient(45deg, #8b5cf6, #7c3aed);
  color: white;
  padding: 0.75rem 1.25rem;
}

.quick-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 16px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

.stat-card.primary { border-left: 4px solid #3b82f6; }
.stat-card.success { border-left: 4px solid #10b981; }
.stat-card.warning { border-left: 4px solid #f59e0b; }
.stat-card.info { border-left: 4px solid #06b6d4; }

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

.tabs-container {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 1rem;
  margin-bottom: 2rem;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

.tabs-nav {
  display: flex;
  gap: 0.5rem;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.875rem 1.5rem;
  border: none;
  background: transparent;
  color: #64748b;
  font-weight: 600;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tab-button:hover {
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
}

.tab-button.active {
  background: linear-gradient(45deg, #3b82f6, #1d4ed8);
  color: white;
  box-shadow: 0 5px 15px rgba(59, 130, 246, 0.3);
}

.tab-content {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.search-container {
  position: relative;
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 300px;
}

.search-container svg {
  position: absolute;
  left: 1rem;
  color: #9ca3af;
}

.search-input {
  width: 100%;
  padding: 0.75rem 1rem 0.75rem 2.5rem;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  font-size: 0.95rem;
  background: rgba(255, 255, 255, 0.9);
}

.filters, .date-range, .actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.select-modern, .date-input {
  padding: 0.75rem 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.9);
  font-size: 0.95rem;
}

.employees-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}

.employee-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.employee-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
}

.employee-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.employee-photo {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  overflow: hidden;
  background: linear-gradient(45deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.employee-photo img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.employee-badges {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  align-items: flex-end;
}

.badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.badge.status.ativo { background: #dcfce7; color: #166534; }
.badge.status.inativo { background: #fee2e2; color: #991b1b; }
.badge.status.ferias { background: #fef3c7; color: #92400e; }
.badge.status.afastado { background: #e0e7ff; color: #3730a3; }
.badge.position { background: #dbeafe; color: #1e40af; }

.employee-info {
  margin-bottom: 1rem;
}

.employee-info h3 {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 0.5rem 0;
}

.employee-info p {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  color: #64748b;
  margin: 0.25rem 0;
}

.employee-stats {
  padding: 0.75rem 0;
  border-top: 1px solid rgba(0, 0, 0, 0.1);
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  margin-bottom: 1rem;
}

.employee-stats .stat {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.employee-stats .stat-label {
  font-size: 0.85rem;
  color: #64748b;
}

.employee-stats .stat-value {
  font-weight: 600;
  color: #1e293b;
}

.employee-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.btn-icon {
  padding: 0.5rem;
  border: none;
  border-radius: 8px;
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

.btn-icon.view {
  background: rgba(99, 102, 241, 0.1);
  color: #6366f1;
}

.btn-icon.bank {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.btn-icon.delete {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.btn-icon.success {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.btn-icon:hover {
  transform: scale(1.1);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  text-align: center;
  color: #64748b;
}

.empty-state svg {
  color: #cbd5e1;
  margin-bottom: 1rem;
}

.empty-state h3 {
  font-size: 1.5rem;
  color: #1e293b;
  margin: 0 0 0.5rem 0;
}

.payments-table-container {
  overflow-x: auto;
  margin: 2rem 0;
}

.payments-table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 12px;
  overflow: hidden;
}

.payments-table th {
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  font-size: 0.9rem;
}

.payments-table td {
  padding: 1rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.payment-row:hover {
  background: rgba(255, 255, 255, 0.5);
}

.employee-mini {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.mini-photo {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  overflow: hidden;
  background: linear-gradient(45deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.mini-photo img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.currency {
  font-weight: 600;
  font-family: 'Courier New', monospace;
}

.currency.bonus { color: #10b981; }
.currency.deduction { color: #ef4444; }
.currency.total { color: #3b82f6; font-weight: 700; }

.status-badge {
  padding: 0.375rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge.pendente { background: #fef3c7; color: #92400e; }
.status-badge.processando { background: #dbeafe; color: #1e40af; }
.status-badge.pago { background: #dcfce7; color: #166534; }
.status-badge.cancelado { background: #fee2e2; color: #991b1b; }

.actions-cell {
  display: flex;
  gap: 0.5rem;
}

.salary-configs-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.salary-config-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1.5rem;
}

.config-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.config-header h3 {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.type-badge {
  padding: 0.375rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.type-badge.fixed { background: #dbeafe; color: #1e40af; }
.type-badge.percentage { background: #dcfce7; color: #166534; }
.type-badge.mixed { background: #fef3c7; color: #92400e; }

.config-details {
  margin-bottom: 1rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.detail-item .label {
  font-size: 0.9rem;
  color: #64748b;
}

.detail-item .value {
  font-weight: 600;
  color: #1e293b;
}

.config-description {
  padding: 0.75rem;
  background: rgba(59, 130, 246, 0.05);
  border-left: 3px solid #3b82f6;
  border-radius: 8px;
  margin-bottom: 1rem;
}

.config-description p {
  margin: 0;
  font-size: 0.9rem;
  color: #475569;
}

.config-actions {
  display: flex;
  justify-content: flex-end;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 2rem;
}

.dashboard-card {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

.dashboard-card.full-width {
  grid-column: 1 / -1;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.card-header h3 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.25rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.chart-wrapper {
  height: 300px;
  position: relative;
}

.garcom-performance-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.garcom-performance-item {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 12px;
  transition: all 0.3s ease;
}

.garcom-performance-item:hover {
  transform: translateX(8px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.rank {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  font-weight: 700;
}

.garcom-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.garcom-info .photo {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  overflow: hidden;
  background: linear-gradient(45deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.garcom-info .photo img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.garcom-info .info h4 {
  font-size: 1.1rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 0.25rem 0;
}

.garcom-info .info p {
  font-size: 0.9rem;
  color: #64748b;
  margin: 0;
}

.garcom-stats {
  display: flex;
  gap: 2rem;
}

.garcom-stats .stat {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.garcom-stats .stat .label {
  font-size: 0.8rem;
  color: #64748b;
  margin-bottom: 0.25rem;
}

.garcom-stats .stat .value {
  font-size: 1.1rem;
  font-weight: 700;
  color: #1e293b;
}

.garcom-stats .stat .value.primary { color: #3b82f6; }
.garcom-stats .stat .value.success { color: #10b981; }

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .employee-management-container {
    padding: 1rem;
  }

  .header-main {
    flex-direction: column;
    align-items: flex-start;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
  }

  .quick-stats-grid {
    grid-template-columns: 1fr;
  }

  .tabs-nav {
    flex-direction: column;
  }

  .toolbar {
    flex-direction: column;
    align-items: stretch;
  }

  .employees-grid {
    grid-template-columns: 1fr;
  }

  .dashboard-grid {
    grid-template-columns: 1fr;
  }

  .garcom-performance-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .garcom-stats {
    width: 100%;
    justify-content: space-around;
  }
}
</style>
