interface DeviceInfo {
  platform: string
  userAgent: string
  hardwareConcurrency: number
  deviceMemory?: number
  connection?: {
    effectiveType: string
    downlink: number
    rtt: number
    saveData: boolean
  }
  screen: {
    width: number
    height: number
    colorDepth: number
    pixelRatio: number
  }
  gpu?: {
    vendor: string
    renderer: string
  }
}

interface PerformanceMetrics {
  cpu: {
    usage: number
    cores: number
    model: string
  }
  memory: {
    used: number
    total: number
    available: number
    percentage: number
  }
  storage: {
    used: number
    total: number
    available: number
    percentage: number
  }
  network: {
    type: string
    speed: number
    latency: number
    quality: 'excelente' | 'boa' | 'regular' | 'ruim'
  }
  battery?: {
    level: number
    charging: boolean
    chargingTime?: number
    dischargingTime?: number
  }
  device: {
    type: 'desktop' | 'mobile' | 'tablet'
    os: string
    browser: string
    isMobile: boolean
    isTouch: boolean
  }
  thermal?: {
    state: 'nominal' | 'fair' | 'serious' | 'critical'
  }
}

interface BenchmarkResult {
  score: number
  category: 'excelente' | 'boa' | 'regular' | 'baixa'
  details: {
    cpuScore: number
    memoryScore: number
    renderScore: number
  }
}

class SystemMetricsService {
  private performanceObserver?: PerformanceObserver
  private cpuBenchmarkCache?: number
  private lastCpuUsage = 0
  private cpuSamples: number[] = []

  /**
   * Obtém informações detalhadas do dispositivo
   */
  getDeviceInfo(): DeviceInfo {
    const canvas = document.createElement('canvas')
    const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl')

    let gpu = undefined
    if (gl) {
      const debugInfo = gl.getExtension('WEBGL_debug_renderer_info')
      if (debugInfo) {
        gpu = {
          vendor: gl.getParameter(debugInfo.UNMASKED_VENDOR_WEBGL),
          renderer: gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL)
        }
      }
    }

    const connection = (navigator as any).connection || (navigator as any).mozConnection || (navigator as any).webkitConnection

    return {
      platform: this.detectPlatform(),
      userAgent: navigator.userAgent,
      hardwareConcurrency: navigator.hardwareConcurrency || 4,
      deviceMemory: (navigator as any).deviceMemory,
      connection: connection ? {
        effectiveType: connection.effectiveType || 'unknown',
        downlink: connection.downlink || 0,
        rtt: connection.rtt || 0,
        saveData: connection.saveData || false
      } : undefined,
      screen: {
        width: screen.width,
        height: screen.height,
        colorDepth: screen.colorDepth,
        pixelRatio: window.devicePixelRatio || 1
      },
      gpu
    }
  }

  /**
   * Detecta a plataforma/OS do usuário
   */
  private detectPlatform(): string {
    const ua = navigator.userAgent.toLowerCase()
    const platform = navigator.platform.toLowerCase()

    if (platform.includes('mac') || ua.includes('macintosh')) {
      return 'macOS'
    } else if (platform.includes('win') || ua.includes('windows')) {
      return 'Windows'
    } else if (platform.includes('linux') || ua.includes('linux')) {
      return 'Linux'
    } else if (ua.includes('android')) {
      return 'Android'
    } else if (ua.includes('iphone') || ua.includes('ipad')) {
      return 'iOS'
    } else {
      return 'Desconhecido'
    }
  }

  /**
   * Detecta o tipo de dispositivo
   */
  private detectDeviceType(): 'desktop' | 'mobile' | 'tablet' {
    const ua = navigator.userAgent.toLowerCase()
    const isMobile = /android|iphone|ipad|ipod|blackberry|windows phone/i.test(ua)
    const isTablet = /ipad|android(?!.*mobile)|tablet/i.test(ua)

    if (isTablet) return 'tablet'
    if (isMobile) return 'mobile'
    return 'desktop'
  }

  /**
   * Detecta o navegador
   */
  private detectBrowser(): string {
    const ua = navigator.userAgent

    if (ua.includes('Firefox')) return 'Firefox'
    if (ua.includes('SamsungBrowser')) return 'Samsung Internet'
    if (ua.includes('Opera') || ua.includes('OPR')) return 'Opera'
    if (ua.includes('Trident') || ua.includes('MSIE')) return 'Internet Explorer'
    if (ua.includes('Edge')) return 'Microsoft Edge'
    if (ua.includes('Chrome')) return 'Chrome'
    if (ua.includes('Safari')) return 'Safari'

    return 'Desconhecido'
  }

  /**
   * Estima o uso da CPU através de benchmarks
   */
  private async estimateCpuUsage(): Promise<number> {
    if (this.cpuSamples.length > 10) {
      this.cpuSamples.shift()
    }

    const startTime = performance.now()

    // Benchmark simples para medir performance da CPU
    let iterations = 100000
    let sum = 0
    for (let i = 0; i < iterations; i++) {
      sum += Math.sqrt(i) * Math.sin(i) + Math.cos(i)
    }

    const endTime = performance.now()
    const executionTime = endTime - startTime

    // Normalizar o tempo para uma porcentagem (valores maiores = CPU mais ocupada)
    const baselineTime = 10 // ms (tempo base para comparação)
    const cpuUsage = Math.min(100, Math.max(0, (executionTime / baselineTime) * 20))

    this.cpuSamples.push(cpuUsage)

    // Retornar média das últimas amostras
    const avgUsage = this.cpuSamples.reduce((a, b) => a + b, 0) / this.cpuSamples.length
    return Math.round(avgUsage)
  }

  /**
   * Estima o uso de memória
   */
  private estimateMemoryUsage(): { used: number; total: number; available: number; percentage: number } {
    const performance = (window as any).performance

    if (performance && performance.memory) {
      const used = performance.memory.usedJSHeapSize / (1024 * 1024) // MB
      const total = performance.memory.totalJSHeapSize / (1024 * 1024) // MB
      const limit = performance.memory.jsHeapSizeLimit / (1024 * 1024) // MB

      const available = limit - used
      const percentage = (used / limit) * 100

      return {
        used: Math.round(used),
        total: Math.round(limit),
        available: Math.round(available),
        percentage: Math.round(percentage)
      }
    }

    // Fallback se não tiver acesso à API de memória
    const deviceMemory = (navigator as any).deviceMemory || 4 // GB
    const estimatedUsed = deviceMemory * 0.6 // Estimar 60% de uso
    const totalMB = deviceMemory * 1024

    return {
      used: Math.round(estimatedUsed * 1024),
      total: totalMB,
      available: Math.round((deviceMemory - estimatedUsed) * 1024),
      percentage: 60
    }
  }

  /**
   * Estima o uso de storage
   */
  private async estimateStorageUsage(): Promise<{ used: number; total: number; available: number; percentage: number }> {
    try {
      if ('storage' in navigator && 'estimate' in navigator.storage) {
        const estimate = await navigator.storage.estimate()
        const quota = estimate.quota || 0
        const usage = estimate.usage || 0

        const quotaGB = quota / (1024 * 1024 * 1024)
        const usageGB = usage / (1024 * 1024 * 1024)
        const availableGB = quotaGB - usageGB
        const percentage = quota > 0 ? (usage / quota) * 100 : 0

        return {
          used: Math.round(usageGB * 1000) / 1000,
          total: Math.round(quotaGB * 1000) / 1000,
          available: Math.round(availableGB * 1000) / 1000,
          percentage: Math.round(percentage)
        }
      }
    } catch (error) {
      console.warn('Erro ao obter informações de storage:', error)
    }

    // Fallback
    return {
      used: 2.5,
      total: 10,
      available: 7.5,
      percentage: 25
    }
  }

  /**
   * Obtém informações da bateria (se disponível)
   */
  private async getBatteryInfo(): Promise<PerformanceMetrics['battery']> {
    try {
      if ('getBattery' in navigator) {
        const battery = await (navigator as any).getBattery()
        return {
          level: Math.round(battery.level * 100),
          charging: battery.charging,
          chargingTime: battery.chargingTime !== Infinity ? battery.chargingTime : undefined,
          dischargingTime: battery.dischargingTime !== Infinity ? battery.dischargingTime : undefined
        }
      }
    } catch (error) {
      console.warn('Erro ao obter informações da bateria:', error)
    }
    return undefined
  }

  /**
   * Avalia a qualidade da rede
   */
  private evaluateNetworkQuality(downlink: number, rtt: number): 'excelente' | 'boa' | 'regular' | 'ruim' {
    if (downlink >= 10 && rtt <= 100) return 'excelente'
    if (downlink >= 5 && rtt <= 200) return 'boa'
    if (downlink >= 1 && rtt <= 500) return 'regular'
    return 'ruim'
  }

  /**
   * Obtém estado térmico (experimental)
   */
  private getThermalState(): 'nominal' | 'fair' | 'serious' | 'critical' {
    // Esta é uma API experimental e pode não estar disponível
    try {
      if ('deviceThermal' in navigator) {
        const thermal = (navigator as any).deviceThermal
        return thermal.state || 'nominal'
      }
    } catch (error) {
      console.warn('Informações térmicas não disponíveis:', error)
    }
    return 'nominal'
  }

  /**
   * Executa benchmark simples da CPU
   */
  private async runCpuBenchmark(): Promise<number> {
    if (this.cpuBenchmarkCache) {
      return this.cpuBenchmarkCache
    }

    const startTime = performance.now()

    // Benchmark mais intensivo para score da CPU
    let result = 0
    const iterations = 1000000

    for (let i = 0; i < iterations; i++) {
      result += Math.sqrt(i) * Math.sin(i / 1000) + Math.cos(i / 1000)
    }

    const endTime = performance.now()
    const executionTime = endTime - startTime

    // Calcular score (menor tempo = maior score)
    const score = Math.max(0, 10000 - executionTime)
    this.cpuBenchmarkCache = Math.round(score)

    // Cache por 5 minutos
    setTimeout(() => {
      this.cpuBenchmarkCache = undefined
    }, 5 * 60 * 1000)

    return this.cpuBenchmarkCache
  }

  /**
   * Executa benchmark de renderização
   */
  private runRenderBenchmark(): number {
    const canvas = document.createElement('canvas')
    canvas.width = 300
    canvas.height = 300
    const ctx = canvas.getContext('2d')

    if (!ctx) return 0

    const startTime = performance.now()

    // Benchmark de renderização 2D
    for (let i = 0; i < 1000; i++) {
      ctx.beginPath()
      ctx.arc(Math.random() * 300, Math.random() * 300, Math.random() * 20, 0, 2 * Math.PI)
      ctx.fillStyle = `hsl(${Math.random() * 360}, 70%, 50%)`
      ctx.fill()
    }

    const endTime = performance.now()
    const executionTime = endTime - startTime

    // Calcular score de renderização
    return Math.max(0, 1000 - executionTime)
  }

  /**
   * Obtém métricas completas do sistema
   */
  async getPerformanceMetrics(): Promise<PerformanceMetrics> {
    const deviceInfo = this.getDeviceInfo()
    const cpuUsage = await this.estimateCpuUsage()
    const memoryInfo = this.estimateMemoryUsage()
    const storageInfo = await this.estimateStorageUsage()
    const batteryInfo = await this.getBatteryInfo()

    // Informações de rede
    const connection = deviceInfo.connection
    const networkType = connection?.effectiveType || 'unknown'
    const networkSpeed = connection?.downlink || 0
    const networkLatency = connection?.rtt || 0
    const networkQuality = this.evaluateNetworkQuality(networkSpeed, networkLatency)

    return {
      cpu: {
        usage: cpuUsage,
        cores: deviceInfo.hardwareConcurrency,
        model: this.getCpuModel()
      },
      memory: memoryInfo,
      storage: storageInfo,
      network: {
        type: networkType,
        speed: networkSpeed,
        latency: networkLatency,
        quality: networkQuality
      },
      battery: batteryInfo,
      device: {
        type: this.detectDeviceType(),
        os: deviceInfo.platform,
        browser: this.detectBrowser(),
        isMobile: /android|iphone|ipad|ipod|blackberry|windows phone/i.test(navigator.userAgent),
        isTouch: 'ontouchstart' in window
      },
      thermal: {
        state: this.getThermalState()
      }
    }
  }

  /**
   * Executa benchmark completo do sistema
   */
  async runSystemBenchmark(): Promise<BenchmarkResult> {
    console.log('🚀 Executando benchmark do sistema...')

    const [cpuScore, memoryScore, renderScore] = await Promise.all([
      this.runCpuBenchmark(),
      this.runMemoryBenchmark(),
      this.runRenderBenchmark()
    ])

    const totalScore = (cpuScore + memoryScore + renderScore) / 3
    const category = this.categorizeScore(totalScore)

    console.log('✅ Benchmark concluído:', {
      totalScore: Math.round(totalScore),
      category,
      details: { cpuScore, memoryScore, renderScore }
    })

    return {
      score: Math.round(totalScore),
      category,
      details: {
        cpuScore: Math.round(cpuScore),
        memoryScore: Math.round(memoryScore),
        renderScore: Math.round(renderScore)
      }
    }
  }

  /**
   * Benchmark de memória
   */
  private runMemoryBenchmark(): number {
    const startTime = performance.now()

    // Teste de alocação e manipulação de memória
    const arrays: number[][] = []

    try {
      for (let i = 0; i < 100; i++) {
        const arr = new Array(10000).fill(0).map(() => Math.random())
        arrays.push(arr)

        // Operações com array
        arr.sort()
        arr.reverse()
        arr.filter(x => x > 0.5)
      }
    } catch (error) {
      console.warn('Erro no benchmark de memória:', error)
      return 0
    }

    const endTime = performance.now()
    const executionTime = endTime - startTime

    // Calcular score
    return Math.max(0, 5000 - executionTime)
  }

  /**
   * Categoriza o score do benchmark
   */
  private categorizeScore(score: number): 'excelente' | 'boa' | 'regular' | 'baixa' {
    if (score >= 8000) return 'excelente'
    if (score >= 6000) return 'boa'
    if (score >= 4000) return 'regular'
    return 'baixa'
  }

  /**
   * Obtém modelo da CPU (estimativa)
   */
  private getCpuModel(): string {
    const ua = navigator.userAgent
    const cores = navigator.hardwareConcurrency || 4

    if (ua.includes('Mac')) {
      if (cores >= 8) return 'Apple M-Series (High-end)'
      if (cores >= 4) return 'Apple M-Series / Intel'
      return 'Apple A-Series'
    }

    if (ua.includes('Windows')) {
      if (cores >= 16) return 'Intel/AMD High-end'
      if (cores >= 8) return 'Intel/AMD Mid-range'
      if (cores >= 4) return 'Intel/AMD Entry-level'
      return 'Dual-core'
    }

    if (ua.includes('Android')) {
      if (cores >= 8) return 'Snapdragon/Exynos Flagship'
      if (cores >= 6) return 'Snapdragon/Exynos Mid-range'
      return 'Entry-level Mobile'
    }

    return `${cores}-core Processor`
  }

  /**
   * Monitora métricas em tempo real
   */
  startRealTimeMonitoring(callback: (metrics: PerformanceMetrics) => void, interval = 5000) {
    const monitor = async () => {
      try {
        const metrics = await this.getPerformanceMetrics()
        callback(metrics)
      } catch (error) {
        console.error('Erro no monitoramento em tempo real:', error)
      }
    }

    // Primeira execução imediata
    monitor()

    // Execuções subsequentes
    return setInterval(monitor, interval)
  }

  /**
   * Para o monitoramento em tempo real
   */
  stopRealTimeMonitoring(intervalId: NodeJS.Timeout) {
    clearInterval(intervalId)
  }

  /**
   * Obtém resumo do sistema
   */
  async getSystemSummary(): Promise<{
    deviceType: string
    os: string
    browser: string
    performance: string
    memory: string
    storage: string
    network: string
  }> {
    const metrics = await this.getPerformanceMetrics()
    const benchmark = await this.runSystemBenchmark()

    return {
      deviceType: `${metrics.device.type} (${metrics.device.os})`,
      os: metrics.device.os,
      browser: metrics.device.browser,
      performance: `${benchmark.category} (${benchmark.score} pts)`,
      memory: `${metrics.memory.used}MB / ${metrics.memory.total}MB (${metrics.memory.percentage}%)`,
      storage: `${metrics.storage.used}GB / ${metrics.storage.total}GB (${metrics.storage.percentage}%)`,
      network: `${metrics.network.type} (${metrics.network.quality})`
    }
  }
}

export const systemMetricsService = new SystemMetricsService()
export type { PerformanceMetrics, DeviceInfo, BenchmarkResult }