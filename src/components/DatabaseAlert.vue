<template>
  <Teleport to="body">
    <Transition name="alert">
      <div v-if="showAlert" class="database-alert-overlay">
        <div class="database-alert" :class="alertType">
          <div class="alert-header">
            <div class="alert-icon">
              <component :is="getAlertIcon()" :size="24" />
            </div>
            <div class="alert-title">
              <h3>{{ getAlertTitle() }}</h3>
              <p>{{ alertMessage }}</p>
            </div>
            <button @click="dismissAlert" class="close-btn">
              <X :size="20" />
            </button>
          </div>

          <div class="alert-content">
            <div class="usage-bar">
              <div class="usage-info">
                <span>Espaço Utilizado</span>
                <span>{{ Math.round(usagePercentage) }}%</span>
              </div>
              <div class="progress-container">
                <div
                  class="progress-bar"
                  :class="getProgressClass()"
                  :style="{ width: `${Math.min(100, usagePercentage)}%` }"
                ></div>
              </div>
            </div>

            <div class="alert-actions">
              <button @click="viewDetails" class="btn-secondary">
                <BarChart3 :size="16" />
                Ver Detalhes
              </button>
              <button @click="viewRecommendations" class="btn-primary">
                <Lightbulb :size="16" />
                Ver Soluções
              </button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { X, AlertTriangle, AlertCircle, XCircle, BarChart3, Lightbulb } from 'lucide-vue-next'
// import { databaseStatsService } from '@/services/databaseStatsService'

interface Props {
  usagePercentage: number
  alertMessage: string
  alertType: 'warning' | 'critical'
  autoShow?: boolean
  persistAlerts?: boolean
}

interface Emits {
  (e: 'dismissed'): void
  (e: 'view-details'): void
  (e: 'view-recommendations'): void
}

const props = withDefaults(defineProps<Props>(), {
  autoShow: true,
  persistAlerts: false
})

const emit = defineEmits<Emits>()

// Estados reativos
const showAlert = ref(false)
const alertDismissed = ref(false)

// Computed
// const shouldShowAlert = computed(() => {
//   if (alertDismissed.value && !props.persistAlerts) return false
//   if (!props.autoShow) return showAlert.value
//
//   // Mostrar alerta automaticamente baseado na porcentagem
//   return props.usagePercentage >= 80
// })

// Funções
function getAlertIcon() {
  switch (props.alertType) {
    case 'critical': return XCircle
    case 'warning': return AlertTriangle
    default: return AlertCircle
  }
}

function getAlertTitle(): string {
  switch (props.alertType) {
    case 'critical': return '⚠️ Banco de Dados Crítico'
    case 'warning': return '🚨 Banco de Dados com Uso Elevado'
    default: return '📊 Alerta do Banco de Dados'
  }
}

function getProgressClass(): string {
  if (props.usagePercentage >= 95) return 'critical'
  if (props.usagePercentage >= 80) return 'warning'
  return 'normal'
}

function dismissAlert() {
  showAlert.value = false
  alertDismissed.value = true

  // Salvar no localStorage para não mostrar novamente
  if (!props.persistAlerts) {
    const dismissedAlerts = JSON.parse(localStorage.getItem('dismissedDatabaseAlerts') || '{}')
    const today = new Date().toDateString()
    dismissedAlerts[today] = true
    localStorage.setItem('dismissedDatabaseAlerts', JSON.stringify(dismissedAlerts))
  }

  emit('dismissed')
}

function viewDetails() {
  emit('view-details')
  dismissAlert()
}

function viewRecommendations() {
  emit('view-recommendations')
  dismissAlert()
}

function checkIfShouldShow(): boolean {
  if (!props.autoShow) return false

  // Não mostrar se já foi dispensado hoje (exceto alertas críticos)
  if (props.alertType !== 'critical' && !props.persistAlerts) {
    const dismissedAlerts = JSON.parse(localStorage.getItem('dismissedDatabaseAlerts') || '{}')
    const today = new Date().toDateString()
    if (dismissedAlerts[today]) return false
  }

  return props.usagePercentage >= 80
}

// Lifecycle
onMounted(() => {
  showAlert.value = checkIfShouldShow()

  // Auto-mostrar alertas críticos sempre
  if (props.alertType === 'critical' && props.usagePercentage >= 95) {
    showAlert.value = true
    alertDismissed.value = false
  }
})

// Watch para mudanças na porcentagem
import { watch } from 'vue'
watch(() => props.usagePercentage, (newValue) => {
  if (newValue >= 95 && props.alertType === 'critical') {
    showAlert.value = true
    alertDismissed.value = false
  } else if (newValue >= 80 && !alertDismissed.value) {
    showAlert.value = checkIfShouldShow()
  }
})

// Expor função para mostrar manualmente
defineExpose({
  show: () => {
    showAlert.value = true
    alertDismissed.value = false
  },
  hide: () => {
    showAlert.value = false
  }
})
</script>

<style scoped>
.database-alert-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(5px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.database-alert {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
  max-width: 500px;
  width: 100%;
  overflow: hidden;
  border-left: 5px solid;
}

.database-alert.warning {
  border-left-color: #f59e0b;
}

.database-alert.critical {
  border-left-color: #ef4444;
  animation: urgentPulse 2s infinite;
}

@keyframes urgentPulse {
  0%, 100% { box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3); }
  50% { box-shadow: 0 20px 50px rgba(239, 68, 68, 0.4), 0 0 0 2px rgba(239, 68, 68, 0.2); }
}

.alert-header {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1.5rem;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
}

.alert-icon {
  flex-shrink: 0;
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.database-alert.warning .alert-icon {
  background: rgba(245, 158, 11, 0.1);
  color: #f59e0b;
}

.database-alert.critical .alert-icon {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.alert-title {
  flex: 1;
}

.alert-title h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: #333;
}

.alert-title p {
  margin: 0;
  font-size: 0.875rem;
  color: #666;
  line-height: 1.4;
}

.close-btn {
  flex-shrink: 0;
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.close-btn:hover {
  background: rgba(0, 0, 0, 0.1);
  color: #333;
}

.alert-content {
  padding: 0 1.5rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.usage-bar {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.usage-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.875rem;
  font-weight: 600;
}

.usage-info span:first-child {
  color: #666;
}

.usage-info span:last-child {
  color: #333;
}

.progress-container {
  height: 8px;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.progress-bar.normal {
  background: linear-gradient(90deg, #10b981 0%, #059669 100%);
}

.progress-bar.warning {
  background: linear-gradient(90deg, #f59e0b 0%, #d97706 100%);
}

.progress-bar.critical {
  background: linear-gradient(90deg, #ef4444 0%, #dc2626 100%);
  animation: criticalPulse 1.5s infinite;
}

@keyframes criticalPulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.alert-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

.btn-primary, .btn-secondary {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  font-weight: 600;
  font-size: 0.875rem;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
  background: rgba(0, 0, 0, 0.05);
  color: #666;
  border: 1px solid rgba(0, 0, 0, 0.1);
}

.btn-secondary:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

/* Transições */
.alert-enter-active, .alert-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.alert-enter-from, .alert-leave-to {
  opacity: 0;
  transform: scale(0.9) translateY(-20px);
}

.alert-enter-active .database-alert, .alert-leave-active .database-alert {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.alert-enter-from .database-alert, .alert-leave-to .database-alert {
  transform: scale(0.9) translateY(-20px);
  opacity: 0;
}

/* Responsividade */
@media (max-width: 768px) {
  .database-alert-overlay {
    padding: 1rem;
  }

  .database-alert {
    max-width: none;
    width: 100%;
  }

  .alert-header {
    padding: 1rem;
  }

  .alert-content {
    padding: 0 1rem 1rem;
  }

  .alert-actions {
    flex-direction: column;
  }

  .btn-primary, .btn-secondary {
    width: 100%;
    justify-content: center;
  }
}
</style>