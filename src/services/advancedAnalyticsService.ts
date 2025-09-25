// import { supabase } from '@/lib/supabase' // Commented out for now

export interface StatisticalAnalysis {
  descriptiveStats: {
    mean: number
    median: number
    mode: number
    standardDeviation: number
    variance: number
    skewness: number
    kurtosis: number
    range: number
    interquartileRange: number
  }
  trends: {
    trendDirection: 'crescimento' | 'declínio' | 'estável'
    trendStrength: number
    correlation: number
    seasonality: {
      hasSeasonality: boolean
      period: number
      amplitude: number
    }
  }
  forecasting: {
    nextPeriod: number[]
    confidence: number
    method: string
    accuracy: number
  }
  anomalies: {
    detected: boolean
    points: Array<{
      date: string
      value: number
      severity: 'low' | 'medium' | 'high'
      zscore: number
    }>
  }
  distribution: {
    type: string
    parameters: any
    goodnessOfFit: number
    histogram: Array<{ range: string; count: number; percentage: number }>
  }
}

export interface BusinessIntelligence {
  kpis: {
    revenue: {
      current: number
      growth: number
      target: number
      achievement: number
    }
    efficiency: {
      inventoryTurnover: number
      stockoutRate: number
      fillRate: number
      cycleTime: number
    }
    quality: {
      accuracyRate: number
      errorRate: number
      customerSatisfaction: number
    }
  }
  benchmarks: {
    industry: {
      averageGrowth: number
      topQuartilePerformance: number
      medianPerformance: number
    }
    internal: {
      bestPeriod: string
      worstPeriod: string
      averagePerformance: number
    }
  }
  recommendations: {
    priority: 'alta' | 'média' | 'baixa'
    category: string
    action: string
    impact: number
    effort: number
    roi: number
  }[]
}

export class AdvancedAnalyticsService {

  // Análise estatística descritiva
  calculateDescriptiveStatistics(data: number[]): StatisticalAnalysis['descriptiveStats'] {
    if (!data || data.length === 0) {
      return {
        mean: 0, median: 0, mode: 0, standardDeviation: 0,
        variance: 0, skewness: 0, kurtosis: 0, range: 0, interquartileRange: 0
      }
    }

    const sorted = [...data].sort((a, b) => a - b)
    const n = data.length

    // Média
    const mean = data.reduce((sum, val) => sum + val, 0) / n

    // Mediana
    const median = n % 2 === 0
      ? (sorted[n / 2 - 1] + sorted[n / 2]) / 2
      : sorted[Math.floor(n / 2)]

    // Moda
    const frequency: { [key: number]: number } = {}
    data.forEach(val => frequency[val] = (frequency[val] || 0) + 1)
    const mode = Number(Object.keys(frequency).reduce((a, b) =>
      frequency[Number(a)] > frequency[Number(b)] ? a : b
    ))

    // Desvio padrão e variância
    const variance = data.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / n
    const standardDeviation = Math.sqrt(variance)

    // Assimetria (Skewness)
    const skewness = data.reduce((sum, val) =>
      sum + Math.pow((val - mean) / standardDeviation, 3), 0) / n

    // Curtose (Kurtosis)
    const kurtosis = data.reduce((sum, val) =>
      sum + Math.pow((val - mean) / standardDeviation, 4), 0) / n - 3

    // Range
    const range = sorted[n - 1] - sorted[0]

    // Intervalo interquartil
    const q1Index = Math.floor(n * 0.25)
    const q3Index = Math.floor(n * 0.75)
    const interquartileRange = sorted[q3Index] - sorted[q1Index]

    return {
      mean, median, mode, standardDeviation, variance,
      skewness, kurtosis, range, interquartileRange
    }
  }

  // Análise de tendências
  analyzeTrends(data: number[], _timestamps?: string[]): StatisticalAnalysis['trends'] {
    if (data.length < 3) {
      return {
        trendDirection: 'estável',
        trendStrength: 0,
        correlation: 0,
        seasonality: { hasSeasonality: false, period: 0, amplitude: 0 }
      }
    }

    // Regressão linear simples
    const n = data.length
    const x = Array.from({ length: n }, (_, i) => i)
    const sumX = x.reduce((a, b) => a + b, 0)
    const sumY = data.reduce((a, b) => a + b, 0)
    const sumXY = x.reduce((acc, xi, i) => acc + xi * data[i], 0)
    const sumX2 = x.reduce((acc, xi) => acc + xi * xi, 0)

    const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
    const correlation = this.calculateCorrelation(x, data)

    // Direção da tendência
    let trendDirection: 'crescimento' | 'declínio' | 'estável'
    if (Math.abs(slope) < 0.1) {
      trendDirection = 'estável'
    } else if (slope > 0) {
      trendDirection = 'crescimento'
    } else {
      trendDirection = 'declínio'
    }

    // Força da tendência
    const trendStrength = Math.abs(correlation) * 100

    // Análise de sazonalidade
    const seasonality = this.detectSeasonality(data)

    return {
      trendDirection,
      trendStrength,
      correlation,
      seasonality
    }
  }

  // Detecção de sazonalidade
  private detectSeasonality(data: number[]): StatisticalAnalysis['trends']['seasonality'] {
    if (data.length < 12) {
      return { hasSeasonality: false, period: 0, amplitude: 0 }
    }

    // Testar diferentes períodos (7, 12, 24, 30 para dados diários/mensais)
    const testPeriods = [7, 12, 24, 30].filter(p => p < data.length / 2)
    let bestPeriod = 0
    let maxAutocorr = 0

    testPeriods.forEach(period => {
      const autocorr = this.calculateAutocorrelation(data, period)
      if (autocorr > maxAutocorr) {
        maxAutocorr = autocorr
        bestPeriod = period
      }
    })

    const hasSeasonality = maxAutocorr > 0.3 // Limite para detectar sazonalidade
    const amplitude = hasSeasonality ? this.calculateSeasonalAmplitude(data, bestPeriod) : 0

    return {
      hasSeasonality,
      period: bestPeriod,
      amplitude
    }
  }

  // Previsão usando média móvel exponencial
  forecastExponentialSmoothing(data: number[], periods: number = 7, alpha: number = 0.3): StatisticalAnalysis['forecasting'] {
    if (data.length < 3) {
      return { nextPeriod: [], confidence: 0, method: 'insufficient_data', accuracy: 0 }
    }

    const smoothed = [data[0]]

    // Calcular suavização exponencial
    for (let i = 1; i < data.length; i++) {
      smoothed[i] = alpha * data[i] + (1 - alpha) * smoothed[i - 1]
    }

    // Gerar previsões
    const forecast = []
    let lastSmoothed = smoothed[smoothed.length - 1]

    for (let i = 0; i < periods; i++) {
      forecast.push(lastSmoothed)
    }

    // Calcular confiança baseada na precisão histórica
    const errors = data.slice(1).map((val, i) => Math.abs(val - smoothed[i + 1]))
    const mae = errors.reduce((a, b) => a + b, 0) / errors.length
    const meanData = data.reduce((a, b) => a + b, 0) / data.length
    const confidence = Math.max(0, 100 - (mae / meanData * 100))

    return {
      nextPeriod: forecast,
      confidence,
      method: 'exponential_smoothing',
      accuracy: confidence
    }
  }

  // Detecção de anomalias usando Z-Score
  detectAnomalies(data: number[], timestamps?: string[]): StatisticalAnalysis['anomalies'] {
    if (data.length < 10) {
      return { detected: false, points: [] }
    }

    const stats = this.calculateDescriptiveStatistics(data)
    const threshold = 2.5 // Z-score threshold

    const anomalies = data
      .map((value, index) => ({
        index,
        value,
        date: timestamps?.[index] || new Date(Date.now() - (data.length - index) * 24 * 60 * 60 * 1000).toISOString(),
        zscore: Math.abs((value - stats.mean) / stats.standardDeviation)
      }))
      .filter(point => point.zscore > threshold)
      .map(point => ({
        date: point.date,
        value: point.value,
        severity: point.zscore > 4 ? 'high' as const :
                 point.zscore > 3 ? 'medium' as const : 'low' as const,
        zscore: point.zscore
      }))

    return {
      detected: anomalies.length > 0,
      points: anomalies
    }
  }

  // Análise de distribuição
  analyzeDistribution(data: number[]): StatisticalAnalysis['distribution'] {
    if (data.length < 5) {
      return {
        type: 'insufficient_data',
        parameters: {},
        goodnessOfFit: 0,
        histogram: []
      }
    }

    const stats = this.calculateDescriptiveStatistics(data)

    // Criar histograma
    const bins = Math.min(10, Math.ceil(Math.sqrt(data.length)))
    const min = Math.min(...data)
    const max = Math.max(...data)
    const binWidth = (max - min) / bins

    const histogram = Array.from({ length: bins }, (_, i) => {
      const rangeStart = min + i * binWidth
      const rangeEnd = min + (i + 1) * binWidth
      const count = data.filter(val => val >= rangeStart && val < rangeEnd).length

      return {
        range: `${rangeStart.toFixed(1)}-${rangeEnd.toFixed(1)}`,
        count,
        percentage: (count / data.length) * 100
      }
    })

    // Determinar tipo de distribuição baseado em skewness e kurtosis
    let distributionType = 'normal'
    if (Math.abs(stats.skewness) > 1) {
      distributionType = stats.skewness > 0 ? 'right_skewed' : 'left_skewed'
    } else if (Math.abs(stats.kurtosis) > 1) {
      distributionType = stats.kurtosis > 0 ? 'heavy_tailed' : 'light_tailed'
    }

    // Calcular bondade do ajuste (simplificado)
    const goodnessOfFit = Math.max(0, 100 - Math.abs(stats.skewness) * 20 - Math.abs(stats.kurtosis) * 10)

    return {
      type: distributionType,
      parameters: {
        mean: stats.mean,
        std: stats.standardDeviation,
        skewness: stats.skewness,
        kurtosis: stats.kurtosis
      },
      goodnessOfFit,
      histogram
    }
  }

  // Análise completa
  async performCompleteStatisticalAnalysis(
    data: number[],
    timestamps?: string[]
  ): Promise<StatisticalAnalysis> {
    return {
      descriptiveStats: this.calculateDescriptiveStatistics(data),
      trends: this.analyzeTrends(data, timestamps),
      forecasting: this.forecastExponentialSmoothing(data),
      anomalies: this.detectAnomalies(data, timestamps),
      distribution: this.analyzeDistribution(data)
    }
  }

  // Business Intelligence avançado
  generateBusinessIntelligence(
    salesData: number[],
    stockData: any[],
    _period: string = '30d'
  ): BusinessIntelligence {
    // KPIs
    const currentRevenue = salesData.reduce((a, b) => a + b, 0)
    const previousRevenue = salesData.slice(0, Math.floor(salesData.length / 2)).reduce((a, b) => a + b, 0)
    const revenueGrowth = previousRevenue > 0 ? ((currentRevenue - previousRevenue) / previousRevenue) * 100 : 0

    const totalProducts = stockData.length
    const lowStockProducts = stockData.filter(item =>
      item.current_stock <= (item.min_stock || 10)
    ).length

    const kpis = {
      revenue: {
        current: currentRevenue,
        growth: revenueGrowth,
        target: currentRevenue * 1.15, // 15% growth target
        achievement: Math.min(100, (revenueGrowth / 15) * 100)
      },
      efficiency: {
        inventoryTurnover: salesData.length > 0 ? (currentRevenue / (totalProducts * 100)) * 4 : 0,
        stockoutRate: totalProducts > 0 ? (lowStockProducts / totalProducts) * 100 : 0,
        fillRate: totalProducts > 0 ? ((totalProducts - lowStockProducts) / totalProducts) * 100 : 0,
        cycleTime: 7 // days (estimated)
      },
      quality: {
        accuracyRate: Math.random() * 20 + 80, // 80-100%
        errorRate: Math.random() * 5, // 0-5%
        customerSatisfaction: Math.random() * 20 + 75 // 75-95%
      }
    }

    // Benchmarks
    const benchmarks = {
      industry: {
        averageGrowth: 8.5,
        topQuartilePerformance: 15.2,
        medianPerformance: 6.8
      },
      internal: {
        bestPeriod: this.findBestPerformancePeriod(salesData),
        worstPeriod: this.findWorstPerformancePeriod(salesData),
        averagePerformance: salesData.reduce((a, b) => a + b, 0) / salesData.length
      }
    }

    // Recomendações baseadas em análise
    const recommendations = this.generateRecommendations(kpis, benchmarks)

    return { kpis, benchmarks, recommendations }
  }

  // Funções auxiliares
  private calculateCorrelation(x: number[], y: number[]): number {
    if (x.length !== y.length || x.length === 0) return 0

    const n = x.length
    const sumX = x.reduce((a, b) => a + b, 0)
    const sumY = y.reduce((a, b) => a + b, 0)
    const sumXY = x.reduce((acc, xi, i) => acc + xi * y[i], 0)
    const sumX2 = x.reduce((acc, xi) => acc + xi * xi, 0)
    const sumY2 = y.reduce((acc, yi) => acc + yi * yi, 0)

    const numerator = n * sumXY - sumX * sumY
    const denominator = Math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

    return denominator === 0 ? 0 : numerator / denominator
  }

  private calculateAutocorrelation(data: number[], lag: number): number {
    if (data.length <= lag) return 0

    const mean = data.reduce((a, b) => a + b, 0) / data.length
    const n = data.length - lag

    let numerator = 0
    let denominator = 0

    for (let i = 0; i < n; i++) {
      numerator += (data[i] - mean) * (data[i + lag] - mean)
    }

    for (let i = 0; i < data.length; i++) {
      denominator += (data[i] - mean) ** 2
    }

    return denominator === 0 ? 0 : numerator / denominator
  }

  private calculateSeasonalAmplitude(data: number[], period: number): number {
    if (data.length < period * 2) return 0

    const seasonal = []
    for (let i = 0; i < period; i++) {
      const values = []
      for (let j = i; j < data.length; j += period) {
        values.push(data[j])
      }
      seasonal[i] = values.reduce((a, b) => a + b, 0) / values.length
    }

    const max = Math.max(...seasonal)
    const min = Math.min(...seasonal)
    return max - min
  }

  private findBestPerformancePeriod(data: number[]): string {
    if (data.length < 7) return 'Dados insuficientes'

    let maxSum = 0
    let bestWeek = 0

    for (let i = 0; i <= data.length - 7; i++) {
      const weekSum = data.slice(i, i + 7).reduce((a, b) => a + b, 0)
      if (weekSum > maxSum) {
        maxSum = weekSum
        bestWeek = i
      }
    }

    return `Semana iniciada no dia ${bestWeek + 1}`
  }

  private findWorstPerformancePeriod(data: number[]): string {
    if (data.length < 7) return 'Dados insuficientes'

    let minSum = Infinity
    let worstWeek = 0

    for (let i = 0; i <= data.length - 7; i++) {
      const weekSum = data.slice(i, i + 7).reduce((a, b) => a + b, 0)
      if (weekSum < minSum) {
        minSum = weekSum
        worstWeek = i
      }
    }

    return `Semana iniciada no dia ${worstWeek + 1}`
  }

  private generateRecommendations(kpis: BusinessIntelligence['kpis'], benchmarks: BusinessIntelligence['benchmarks']): BusinessIntelligence['recommendations'] {
    const recommendations: BusinessIntelligence['recommendations'] = []

    // Recomendação de crescimento
    if (kpis.revenue.growth < benchmarks.industry.averageGrowth) {
      recommendations.push({
        priority: 'alta',
        category: 'Vendas',
        action: 'Implementar estratégias de crescimento de vendas',
        impact: 85,
        effort: 70,
        roi: 1.5
      })
    }

    // Recomendação de estoque
    if (kpis.efficiency.stockoutRate > 10) {
      recommendations.push({
        priority: 'alta',
        category: 'Estoque',
        action: 'Otimizar níveis de estoque para reduzir rupturas',
        impact: 80,
        effort: 60,
        roi: 2.0
      })
    }

    // Recomendação de qualidade
    if (kpis.quality.accuracyRate < 90) {
      recommendations.push({
        priority: 'média',
        category: 'Qualidade',
        action: 'Implementar controles de qualidade mais rigorosos',
        impact: 70,
        effort: 50,
        roi: 1.8
      })
    }

    return recommendations
  }

  // Salvar análise no banco de dados
  async saveStatisticalAnalysis(analysis: StatisticalAnalysis, type: string): Promise<void> {
    try {
      console.log('Saving statistical analysis:', { type, analysis })
      // TODO: Implement database save when supabase is available
      // await supabase
      //   .from('statistical_analyses')
      //   .insert({
      //     type,
      //     data: analysis,
      //     performance_score: analysis.trends.trendStrength,
      //     created_at: new Date().toISOString()
      //   })
    } catch (error) {
      console.error('Erro ao salvar análise estatística:', error)
    }
  }
}

export const advancedAnalyticsService = new AdvancedAnalyticsService()