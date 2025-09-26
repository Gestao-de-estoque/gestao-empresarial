<template>
  <div class="system-performance">
    <div class="performance-panel">
      <div class="panel-header">
        <h2>
          <MonitorSpeaker :size="20" />
          Performance do Sistema
        </h2>
        <div class="header-actions">
          <div class="device-info">
            <Smartphone v-if="metrics?.device.type === 'mobile'" :size="16" />
            <Tablet v-else-if="metrics?.device.type === 'tablet'" :size="16" />
            <Monitor v-else :size="16" />
            <span>{{ deviceLabel }}</span>
          </div>
          <button @click="runBenchmark" :disabled="isRunningBenchmark" class="benchmark-btn">
            <Zap :size="16" :class="{ 'animate-pulse': isRunningBenchmark }" />
            {{ isRunningBenchmark ? 'Testando...' : 'Benchmark' }}
          </button>
          <button @click="refreshMetrics" :disabled="isLoading" class="refresh-btn">
            <RefreshCw :size="16" :class="{ 'animate-spin': isLoading }" />
          </button>
        </div>
      </div>

      <div class="panel-content">
        <!-- Métricas Principais - Layout Horizontal -->
        <div class="metrics-horizontal">
          <!-- Indicadores Principais Horizontais -->
          <div class="horizontal-metrics">
            <!-- CPU -->
            <div class="metric-item cpu" :class="getCpuClass()">
              <div class="metric-icon">
                <Cpu :size="18" />
              </div>
              <div class="metric-content">
                <div class="metric-header">
                  <span class="metric-label">CPU</span>
                  <span class="metric-value">{{ metrics?.cpu.usage || 0 }}%</span>
                </div>
                <div class="metric-bar">
                  <div class="metric-fill" :style="{ width: `${metrics?.cpu.usage || 0}%` }"></div>
                </div>
                <div class="metric-details">{{ metrics?.cpu.cores || 4 }} núcleos</div>
              </div>
            </div>

            <!-- Memória -->
            <div class="metric-item memory" :class="getMemoryClass()">
              <div class="metric-icon">
                <MemoryStick :size="18" />
              </div>
              <div class="metric-content">
                <div class="metric-header">
                  <span class="metric-label">Memória</span>
                  <span class="metric-value">{{ metrics?.memory.percentage || 0 }}%</span>
                </div>
                <div class="metric-bar">
                  <div class="metric-fill" :style="{ width: `${metrics?.memory.percentage || 0}%` }"></div>
                </div>
                <div class="metric-details">{{ formatBytes(metrics?.memory.used || 0) }} / {{ formatBytes(metrics?.memory.total || 0) }}</div>
              </div>
            </div>

            <!-- Storage -->
            <div class="metric-item storage" :class="getStorageClass()">
              <div class="metric-icon">
                <HardDrive :size="18" />
              </div>
              <div class="metric-content">
                <div class="metric-header">
                  <span class="metric-label">Storage</span>
                  <span class="metric-value">{{ metrics?.storage.percentage || 0 }}%</span>
                </div>
                <div class="metric-bar">
                  <div class="metric-fill" :style="{ width: `${metrics?.storage.percentage || 0}%` }"></div>
                </div>
                <div class="metric-details">{{ metrics?.storage.used || 0 }}GB / {{ metrics?.storage.total || 0 }}GB</div>
              </div>
            </div>

            <!-- Rede -->
            <div class="metric-item network">
              <div class="metric-icon">
                <Wifi :size="18" />
              </div>
              <div class="metric-content">
                <div class="metric-header">
                  <span class="metric-label">Rede</span>
                  <span class="metric-value quality-badge" :class="metrics?.network.quality">
                    {{ getNetworkQualityLabel(metrics?.network.quality) }}
                  </span>
                </div>
                <div class="metric-bar">
                  <div class="metric-fill network-fill" :style="{ width: getNetworkWidth() + '%' }"></div>
                </div>
                <div class="metric-details">{{ metrics?.network.speed || 0 }} Mbps</div>
              </div>
            </div>

            <!-- Bateria (se disponível) -->
            <div v-if="metrics?.battery" class="metric-item battery">
              <div class="metric-icon">
                <Battery :size="18" />
              </div>
              <div class="metric-content">
                <div class="metric-header">
                  <span class="metric-label">Bateria</span>
                  <span class="metric-value">{{ metrics.battery.level }}%</span>
                </div>
                <div class="metric-bar">
                  <div class="metric-fill battery-fill" :style="{ width: `${metrics.battery.level}%` }" :class="getBatteryClass()"></div>
                </div>
                <div class="metric-details">{{ metrics.battery.charging ? 'Carregando' : 'Descarregando' }}</div>
              </div>
            </div>

            <!-- Benchmark Score (se disponível) -->
            <div v-if="benchmarkResult" class="metric-item benchmark">
              <div class="metric-icon">
                <Gauge :size="18" />
              </div>
              <div class="metric-content">
                <div class="metric-header">
                  <span class="metric-label">Score</span>
                  <span class="metric-value">{{ benchmarkResult.score }}</span>
                </div>
                <div class="metric-bar">
                  <div class="metric-fill benchmark-fill" :style="{ width: `${(benchmarkResult.score / 10000) * 100}%` }"></div>
                </div>
                <div class="metric-details">{{ getCategoryLabel(benchmarkResult.category) }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Ações Rápidas -->
        <div class="quick-actions">
          <button @click="showModal = true" class="action-btn secondary">
            <Info :size="14" />
            Detalhes do Dispositivo
          </button>
          <button @click="runBenchmark" :disabled="isRunningBenchmark" class="action-btn primary">
            <Zap :size="14" :class="{ 'animate-pulse': isRunningBenchmark }" />
            {{ isRunningBenchmark ? 'Executando...' : 'Benchmark' }}
          </button>
          <button @click="shareBenchmark" :disabled="!benchmarkResult" class="action-btn">
            <Share2 :size="14" />
            Compartilhar
          </button>
        </div>
      </div>
    </div>

    <!-- Modal para detalhes (quando necessário) -->
    <Teleport to="body" v-if="showModal">
      <div class="modal-overlay" @click="showModal = false">
        <div class="modal-content" @click.stop>
          <div class="modal-header">
            <h3>
              <component :is="getDeviceIcon()" :size="20" />
              Detalhes do Dispositivo
            </h3>
            <button @click="showModal = false" class="modal-close">
              <X :size="20" />
            </button>
          </div>

          <div class="modal-body">
            <!-- Informações do dispositivo em formato compacto -->
            <div class="device-info-grid">
              <div class="info-item">
                <span class="info-label">Dispositivo:</span>
                <span class="info-value">{{ getDeviceTitle() }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">OS:</span>
                <span class="info-value">{{ metrics?.device.os }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Navegador:</span>
                <span class="info-value">{{ metrics?.device.browser }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Resolução:</span>
                <span class="info-value">{{ deviceInfo?.screen.width }}x{{ deviceInfo?.screen.height }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Pixel Ratio:</span>
                <span class="info-value">{{ deviceInfo?.screen.pixelRatio }}x</span>
              </div>
              <div class="info-item">
                <span class="info-label">Touch:</span>
                <span class="info-value">{{ metrics?.device.isTouch ? 'Sim' : 'Não' }}</span>
              </div>
            </div>

            <!-- Benchmark se disponível -->
            <div v-if="benchmarkResult" class="benchmark-summary">
              <h4>Resultado do Benchmark</h4>
              <div class="benchmark-grid">
                <div class="benchmark-item">
                  <span class="benchmark-label">CPU:</span>
                  <span class="benchmark-value">{{ benchmarkResult.details.cpuScore }}</span>
                </div>
                <div class="benchmark-item">
                  <span class="benchmark-label">Memória:</span>
                  <span class="benchmark-value">{{ benchmarkResult.details.memoryScore }}</span>
                </div>
                <div class="benchmark-item">
                  <span class="benchmark-label">Render:</span>
                  <span class="benchmark-value">{{ benchmarkResult.details.renderScore }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import {
  MonitorSpeaker, Smartphone, Tablet, Monitor, Zap, RefreshCw,
  Cpu, MemoryStick, HardDrive, Wifi, Battery,
  Info, Gauge, X, Share2
} from 'lucide-vue-next'
import { systemMetricsService, type PerformanceMetrics, type DeviceInfo, type BenchmarkResult } from '@/services/systemMetricsService'

// Estados reativos
const metrics = ref<PerformanceMetrics | null>(null)
const deviceInfo = ref<DeviceInfo | null>(null)
const benchmarkResult = ref<BenchmarkResult | null>(null)
const isLoading = ref(false)
const isRunningBenchmark = ref(false)
const benchmarkProgress = ref(0)
const showModal = ref(false)
let monitoringInterval: NodeJS.Timeout | null = null

// Computed
const deviceLabel = computed(() => {
  if (!metrics.value) return 'Carregando...'
  return `${metrics.value.device.type} • ${metrics.value.device.os}`
})

// Métodos
function getCpuClass(): string {
  if (!metrics.value) return 'normal'
  const usage = metrics.value.cpu.usage
  if (usage >= 80) return 'critical'
  if (usage >= 60) return 'warning'
  return 'normal'
}

function getMemoryClass(): string {
  if (!metrics.value) return 'normal'
  const usage = metrics.value.memory.percentage
  if (usage >= 85) return 'critical'
  if (usage >= 70) return 'warning'
  return 'normal'
}

function getStorageClass(): string {
  if (!metrics.value) return 'normal'
  const usage = metrics.value.storage.percentage
  if (usage >= 90) return 'critical'
  if (usage >= 75) return 'warning'
  return 'normal'
}

function getBatteryClass(): string {
  if (!metrics.value?.battery) return 'normal'
  const level = metrics.value.battery.level
  if (level <= 20) return 'critical'
  if (level <= 50) return 'warning'
  return 'normal'
}

function getNetworkQualityLabel(quality?: string): string {
  const labels = {
    'excelente': 'Excelente',
    'boa': 'Boa',
    'regular': 'Regular',
    'ruim': 'Ruim'
  }
  return labels[quality as keyof typeof labels] || 'N/A'
}



function getDeviceIcon() {
  if (!metrics.value) return Monitor
  switch (metrics.value.device.type) {
    case 'mobile': return Smartphone
    case 'tablet': return Tablet
    default: return Monitor
  }
}

function getDeviceTitle(): string {
  if (!metrics.value) return 'Dispositivo'
  const type = metrics.value.device.type
  switch (type) {
    case 'mobile': return 'Smartphone'
    case 'tablet': return 'Tablet'
    default: return 'Desktop/Laptop'
  }
}

function getCategoryLabel(category: string): string {
  const labels = {
    'excelente': 'Excelente',
    'boa': 'Boa',
    'regular': 'Regular',
    'baixa': 'Baixa'
  }
  return labels[category as keyof typeof labels] || category
}

function getNetworkWidth(): number {
  if (!metrics.value?.network.speed) return 0
  // Normalizar velocidade para porcentagem (max 100 Mbps = 100%)
  return Math.min(100, (metrics.value.network.speed / 100) * 100)
}

function formatBytes(mb: number): string {
  if (mb >= 1024) {
    return `${(mb / 1024).toFixed(1)}GB`
  }
  return `${mb.toFixed(0)}MB`
}


async function refreshMetrics() {
  isLoading.value = true
  try {
    console.log('🔄 Atualizando métricas do sistema...')
    const [newMetrics, newDeviceInfo] = await Promise.all([
      systemMetricsService.getPerformanceMetrics(),
      Promise.resolve(systemMetricsService.getDeviceInfo())
    ])

    metrics.value = newMetrics
    deviceInfo.value = newDeviceInfo

    console.log('✅ Métricas atualizadas:', {
      cpu: `${newMetrics.cpu.usage}%`,
      memory: `${newMetrics.memory.percentage}%`,
      storage: `${newMetrics.storage.percentage}%`,
      device: newMetrics.device.type
    })
  } catch (error) {
    console.error('❌ Erro ao atualizar métricas:', error)
  } finally {
    isLoading.value = false
  }
}

async function runBenchmark() {
  isRunningBenchmark.value = true
  benchmarkProgress.value = 0

  try {
    console.log('🚀 Iniciando benchmark do sistema...')

    // Simular progresso do benchmark
    const progressInterval = setInterval(() => {
      if (benchmarkProgress.value < 90) {
        benchmarkProgress.value += Math.random() * 20
      }
    }, 500)

    const result = await systemMetricsService.runSystemBenchmark()

    clearInterval(progressInterval)
    benchmarkProgress.value = 100

    setTimeout(() => {
      benchmarkResult.value = result
      console.log('✅ Benchmark concluído:', result)
    }, 500)

  } catch (error) {
    console.error('❌ Erro no benchmark:', error)
  } finally {
    setTimeout(() => {
      isRunningBenchmark.value = false
      benchmarkProgress.value = 0
    }, 1000)
  }
}

function shareBenchmark() {
  if (!benchmarkResult.value) return
  const text = `Meu dispositivo obteve ${benchmarkResult.value.score} pontos no benchmark do GestãoZe System! Performance: ${getCategoryLabel(benchmarkResult.value.category)}`
  if (navigator.share) {
    navigator.share({
      title: 'Benchmark GestãoZe System',
      text,
      url: window.location.href
    })
  } else {
    navigator.clipboard.writeText(text)
  }
}

function startMonitoring() {
  monitoringInterval = systemMetricsService.startRealTimeMonitoring((newMetrics) => {
    metrics.value = newMetrics
  }, 3000) // Atualizar a cada 3 segundos
}

function stopMonitoring() {
  if (monitoringInterval) {
    systemMetricsService.stopRealTimeMonitoring(monitoringInterval)
    monitoringInterval = null
  }
}

// Lifecycle
onMounted(async () => {
  await refreshMetrics()
  startMonitoring()
})

onUnmounted(() => {
  stopMonitoring()
})
</script>

<style scoped>
.system-performance {
  width: 100%;
}

.performance-panel {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
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

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.device-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: rgba(248, 250, 252, 0.8);
  border-radius: 12px;
  font-size: 13px;
  font-weight: 500;
  color: var(--theme-text-secondary);
}

.benchmark-btn,
.refresh-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.benchmark-btn {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.benchmark-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.benchmark-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.refresh-btn {
  background: rgba(100, 116, 139, 0.1);
  color: #64748b;
  border: 1px solid rgba(100, 116, 139, 0.2);
}

.refresh-btn:hover:not(:disabled) {
  background: rgba(100, 116, 139, 0.15);
}

.panel-content {
  padding: 0 24px 24px;
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

/* Layout Horizontal Compacto */
.metrics-horizontal {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.horizontal-metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.metric-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
  border-radius: 12px;
  padding: 16px;
  border: 1px solid rgba(226, 232, 240, 0.8);
  transition: all 0.3s ease;
}

.metric-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.metric-item.warning {
  border-left: 3px solid #f59e0b;
}

.metric-item.critical {
  border-left: 3px solid #ef4444;
  animation: pulseGlow 2s infinite;
}

@keyframes pulseGlow {
  0%, 100% { box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); }
  50% { box-shadow: 0 4px 20px rgba(239, 68, 68, 0.3); }
}

.metric-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
  flex-shrink: 0;
}

.metric-content {
  flex: 1;
  min-width: 0;
}

.metric-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.metric-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.metric-value {
  font-size: 16px;
  font-weight: 700;
  color: var(--theme-text-primary);
}

.metric-bar {
  height: 6px;
  background: #f1f5f9;
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 6px;
}

.metric-fill {
  height: 100%;
  background: linear-gradient(90deg, #10b981, #059669);
  border-radius: 3px;
  transition: all 0.6s ease;
}

.metric-item.warning .metric-fill {
  background: linear-gradient(90deg, #f59e0b, #d97706);
}

.metric-item.critical .metric-fill {
  background: linear-gradient(90deg, #ef4444, #dc2626);
}

.network-fill {
  background: linear-gradient(90deg, #3b82f6, #1d4ed8) !important;
}

.battery-fill.normal {
  background: linear-gradient(90deg, #10b981, #059669) !important;
}

.battery-fill.warning {
  background: linear-gradient(90deg, #f59e0b, #d97706) !important;
}

.battery-fill.critical {
  background: linear-gradient(90deg, #ef4444, #dc2626) !important;
}

.benchmark-fill {
  background: linear-gradient(90deg, #8b5cf6, #7c3aed) !important;
}

.metric-details {
  font-size: 12px;
  color: var(--theme-text-secondary);
  font-weight: 500;
}

.quality-badge {
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.quality-badge.excelente {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.quality-badge.boa {
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
}

.quality-badge.regular {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.quality-badge.ruim {
  background: rgba(239, 68, 68, 0.1);
  color: #dc2626;
}

/* Ações Rápidas */
.quick-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid rgba(226, 232, 240, 0.5);
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn.primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.action-btn.primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.action-btn.secondary {
  background: rgba(100, 116, 139, 0.1);
  color: #64748b;
  border: 1px solid rgba(100, 116, 139, 0.2);
}

.action-btn.secondary:hover {
  background: rgba(100, 116, 139, 0.15);
  color: #475569;
}

.action-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 600px;
  max-height: 80vh;
  overflow: hidden;
  animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
  from {
    transform: scale(0.9) translateY(20px);
    opacity: 0;
  }
  to {
    transform: scale(1) translateY(0);
    opacity: 1;
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid rgba(226, 232, 240, 0.5);
}

.modal-header h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.modal-close {
  background: none;
  border: none;
  color: #64748b;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.modal-close:hover {
  background: rgba(100, 116, 139, 0.1);
  color: #475569;
}

.modal-body {
  padding: 20px;
  max-height: 60vh;
  overflow-y: auto;
}

.device-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  margin-bottom: 20px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid rgba(226, 232, 240, 0.3);
}

.info-label {
  font-size: 14px;
  color: var(--theme-text-secondary);
  font-weight: 500;
}

.info-value {
  font-size: 14px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.benchmark-summary {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid rgba(226, 232, 240, 0.5);
}

.benchmark-summary h4 {
  margin: 0 0 12px;
  font-size: 16px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.benchmark-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.benchmark-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: rgba(248, 250, 252, 0.8);
  border-radius: 8px;
}

.benchmark-label {
  font-size: 13px;
  color: var(--theme-text-secondary);
  font-weight: 500;
}

.benchmark-value {
  font-size: 14px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

/* Responsividade */
@media (max-width: 768px) {
  .horizontal-metrics {
    grid-template-columns: 1fr;
  }

  .metric-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .metric-icon {
    align-self: center;
  }

  .quick-actions {
    flex-direction: column;
  }

  .device-info-grid {
    grid-template-columns: 1fr;
  }

  .benchmark-grid {
    grid-template-columns: 1fr;
  }
}

/* Animações */
.animate-spin {
  animation: spin 1s linear infinite;
}

.animate-pulse {
  animation: pulse 2s infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
</style>
