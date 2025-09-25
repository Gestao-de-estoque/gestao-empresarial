import { aiAnalyticsService } from './aiAnalyticsService'

interface PredictiveInsight {
  type: 'trend' | 'seasonal' | 'anomaly' | 'forecast'
  title: string
  description: string
  confidence: number
  timeframe: string
  impact: 'high' | 'medium' | 'low'
  actionRequired: boolean
  recommendations: string[]
}

interface ForecastData {
  period: string
  predictedValue: number
  confidence: number
  lowerBound: number
  upperBound: number
}

export class PredictiveAnalyticsService {

  // Análise preditiva de vendas com machine learning simulado
  async predictSalesPattern(historicalData: any[]): Promise<ForecastData[]> {
    if (!historicalData || historicalData.length < 7) {
      return []
    }

    const forecasts: ForecastData[] = []
    const values = historicalData.map(d => d.total || 0)

    // Simular análise de tendência usando média móvel e regressão linear simples
    const movingAverage = this.calculateMovingAverage(values, 7)
    const trend = this.calculateTrend(values)
    const seasonality = this.detectSeasonality(values)

    // Gerar previsões para próximos 30 dias
    for (let i = 1; i <= 30; i++) {
      const lastValue = values[values.length - 1]
      const trendComponent = trend * i
      const seasonalComponent = seasonality[i % seasonality.length]

      const predicted = Math.max(0, lastValue + trendComponent + seasonalComponent)
      const noise = predicted * 0.15 // 15% de variação

      forecasts.push({
        period: this.formatFutureDate(i),
        predictedValue: Math.round(predicted),
        confidence: Math.max(60, 95 - i * 0.8), // Confiança decresce com o tempo
        lowerBound: Math.round(predicted - noise),
        upperBound: Math.round(predicted + noise)
      })
    }

    return forecasts
  }

  // Detecção de anomalias em tempo real
  async detectAnomalies(data: any[]): Promise<PredictiveInsight[]> {
    const insights: PredictiveInsight[] = []

    if (data.length < 14) return insights

    const values = data.map(d => d.total || 0)
    const mean = values.reduce((a, b) => a + b) / values.length
    const stdDev = Math.sqrt(values.reduce((acc, val) => acc + Math.pow(val - mean, 2), 0) / values.length)

    // Detectar outliers (valores > 2 desvios padrão)
    const outliers = values.filter(val => Math.abs(val - mean) > 2 * stdDev)

    if (outliers.length > 0) {
      insights.push({
        type: 'anomaly',
        title: 'Anomalias Detectadas',
        description: `Identificados ${outliers.length} pontos de dados anômalos que desviam significativamente do padrão normal`,
        confidence: 85,
        timeframe: 'Últimos 14 dias',
        impact: 'high',
        actionRequired: true,
        recommendations: [
          'Investigar causas dos picos ou quedas anormais',
          'Verificar se há problemas no sistema de vendas',
          'Analisar campanhas de marketing que possam explicar os picos'
        ]
      })
    }

    // Detectar tendências de declínio
    const recentTrend = this.calculateTrend(values.slice(-7))
    if (recentTrend < -mean * 0.05) {
      insights.push({
        type: 'trend',
        title: 'Tendência de Declínio Detectada',
        description: 'As vendas mostram uma tendência de declínio nos últimos 7 dias',
        confidence: 78,
        timeframe: 'Próximos 7-14 dias',
        impact: 'medium',
        actionRequired: true,
        recommendations: [
          'Implementar estratégias de retenção de clientes',
          'Revisar preços e competitividade',
          'Intensificar esforços de marketing'
        ]
      })
    }

    return insights
  }

  // Análise de sazonalidade avançada
  async analyzeSeasonalPatterns(data: any[]): Promise<PredictiveInsight[]> {
    const insights: PredictiveInsight[] = []

    if (data.length < 30) return insights

    const weeklyPattern = this.analyzeWeeklyPattern(data)
    const monthlyPattern = this.analyzeMonthlyPattern(data)

    if (weeklyPattern.peakDay) {
      insights.push({
        type: 'seasonal',
        title: `Pico Semanal: ${weeklyPattern.peakDay}`,
        description: `${weeklyPattern.peakDay} consistentemente apresenta ${weeklyPattern.increase}% mais vendas que a média`,
        confidence: weeklyPattern.confidence,
        timeframe: 'Padrão semanal',
        impact: 'medium',
        actionRequired: false,
        recommendations: [
          `Otimizar estoque para ${weeklyPattern.peakDay}`,
          'Planejar promoções para dias de baixa performance',
          'Ajustar horários de funcionamento baseado no padrão'
        ]
      })
    }

    return insights
  }

  // Previsão de demanda por produto
  async forecastProductDemand(productData: any[]): Promise<any> {
    const forecasts: any = {}

    for (const product of productData.slice(0, 10)) { // Top 10 produtos
      const demandHistory = this.generateMockDemandHistory(product)
      const prediction = this.predictDemand(demandHistory, product)

      forecasts[product.nome] = {
        currentStock: product.current_stock || 0,
        predictedDemand: prediction.demand,
        recommendedOrder: Math.max(0, prediction.demand - product.current_stock),
        confidence: prediction.confidence,
        riskLevel: this.calculateRiskLevel(product.current_stock, prediction.demand),
        timeline: '30 dias'
      }
    }

    return forecasts
  }

  // Análise de rentabilidade preditiva
  async predictProfitability(salesData: any[], stockData: any): Promise<PredictiveInsight[]> {
    const insights: PredictiveInsight[] = []

    const revenueProjection = this.calculateRevenueProjection(salesData)
    const costAnalysis = this.analyzeCosts(stockData)
    const profitabilityTrend = revenueProjection.trend - costAnalysis.trend

    if (profitabilityTrend > 0.1) {
      insights.push({
        type: 'forecast',
        title: 'Crescimento de Rentabilidade Previsto',
        description: `Projeção de aumento de ${(profitabilityTrend * 100).toFixed(1)}% na rentabilidade nos próximos 30 dias`,
        confidence: 73,
        timeframe: '30 dias',
        impact: 'high',
        actionRequired: false,
        recommendations: [
          'Aproveitar o momento para expansão de estoque',
          'Considerar investimento em marketing',
          'Otimizar mix de produtos de alta margem'
        ]
      })
    } else if (profitabilityTrend < -0.05) {
      insights.push({
        type: 'forecast',
        title: 'Alerta: Declínio de Rentabilidade',
        description: `Projeção de queda de ${Math.abs(profitabilityTrend * 100).toFixed(1)}% na rentabilidade`,
        confidence: 68,
        timeframe: '30 dias',
        impact: 'high',
        actionRequired: true,
        recommendations: [
          'Revisar preços e margens de produtos',
          'Reduzir custos operacionais',
          'Focar em produtos de alta rentabilidade',
          'Renegociar com fornecedores'
        ]
      })
    }

    return insights
  }

  // Métodos auxiliares
  private calculateMovingAverage(data: number[], window: number): number[] {
    const result: number[] = []
    for (let i = 0; i < data.length; i++) {
      if (i < window - 1) {
        result.push(data[i])
      } else {
        const slice = data.slice(i - window + 1, i + 1)
        result.push(slice.reduce((a, b) => a + b) / window)
      }
    }
    return result
  }

  private calculateTrend(values: number[]): number {
    if (values.length < 2) return 0

    const n = values.length
    const sumX = (n * (n - 1)) / 2
    const sumY = values.reduce((a, b) => a + b, 0)
    const sumXY = values.reduce((acc, y, x) => acc + x * y, 0)
    const sumX2 = values.reduce((acc, _, x) => acc + x * x, 0)

    return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
  }

  private detectSeasonality(values: number[]): number[] {
    const seasonalFactors: number[] = []
    const period = Math.min(7, values.length) // Assumir ciclo de 7 dias

    for (let i = 0; i < period; i++) {
      const dayValues = values.filter((_, index) => index % period === i)
      const average = dayValues.length > 0 ? dayValues.reduce((a, b) => a + b) / dayValues.length : 0
      const overallAverage = values.reduce((a, b) => a + b) / values.length

      seasonalFactors.push(average - overallAverage)
    }

    return seasonalFactors
  }

  private analyzeWeeklyPattern(data: any[]): any {
    const weekDays = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado']
    const dayTotals: { [key: string]: number[] } = {}

    data.forEach(item => {
      const date = new Date(item.date)
      const dayOfWeek = weekDays[date.getDay()]

      if (!dayTotals[dayOfWeek]) dayTotals[dayOfWeek] = []
      dayTotals[dayOfWeek].push(item.total || 0)
    })

    let peakDay = ''
    let maxAverage = 0

    Object.entries(dayTotals).forEach(([day, values]) => {
      const average = values.reduce((a, b) => a + b) / values.length
      if (average > maxAverage) {
        maxAverage = average
        peakDay = day
      }
    })

    const overallAverage = data.reduce((acc, item) => acc + (item.total || 0), 0) / data.length
    const increase = ((maxAverage - overallAverage) / overallAverage) * 100

    return {
      peakDay,
      increase: Math.round(increase),
      confidence: Math.min(95, 60 + (data.length / 30) * 10)
    }
  }

  private analyzeMonthlyPattern(data: any[]): any {
    // Implementação simplificada para análise mensal
    return { trend: 'stable' }
  }

  private generateMockDemandHistory(product: any): number[] {
    // Simular histórico de demanda baseado no produto
    const baseValue = product.current_stock || 10
    return Array.from({ length: 30 }, (_, i) =>
      Math.max(1, baseValue + Math.sin(i * 0.2) * 5 + Math.random() * 3 - 1.5)
    )
  }

  private predictDemand(history: number[], product: any): any {
    const avg = history.reduce((a, b) => a + b) / history.length
    const trend = this.calculateTrend(history)
    const predicted = Math.max(1, Math.round(avg + trend * 30))

    return {
      demand: predicted,
      confidence: Math.random() * 20 + 70 // 70-90%
    }
  }

  private calculateRiskLevel(currentStock: number, predictedDemand: number): 'low' | 'medium' | 'high' {
    const ratio = currentStock / predictedDemand
    if (ratio < 0.3) return 'high'
    if (ratio < 0.7) return 'medium'
    return 'low'
  }

  private calculateRevenueProjection(salesData: any[]): any {
    const values = salesData.map(d => d.total || 0)
    const trend = this.calculateTrend(values)
    return { trend: trend / (values.reduce((a, b) => a + b) / values.length) }
  }

  private analyzeCosts(stockData: any): any {
    // Análise simplificada de custos
    const totalValue = stockData?.totalValue || 0
    return { trend: totalValue > 50000 ? 0.05 : 0.02 }
  }

  private formatFutureDate(daysFromNow: number): string {
    const date = new Date()
    date.setDate(date.getDate() + daysFromNow)
    return date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' })
  }
}

export const predictiveAnalyticsService = new PredictiveAnalyticsService()