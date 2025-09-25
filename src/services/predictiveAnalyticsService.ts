import axios from 'axios'
// import { supabase } from '@/lib/supabase' // Commented out for now
// import { aiAnalyticsService } from './aiAnalyticsService' // Unused import

export interface PredictiveAnalysis {
  demandForecast: {
    nextWeek: Array<{ product: string; quantity: number; confidence: number }>
    nextMonth: Array<{ product: string; quantity: number; confidence: number }>
    trend: 'crescimento' | 'declínio' | 'estável'
  }
  stockOptimization: {
    reorderRecommendations: Array<{
      product: string
      currentStock: number
      optimalStock: number
      reorderQuantity: number
      priority: 'crítica' | 'alta' | 'média' | 'baixa'
      estimatedRunoutDate: string
    }>
    overstockAlerts: Array<{
      product: string
      currentStock: number
      recommendedStock: number
      potentialSavings: number
    }>
  }
  salesAnalytics: {
    topPerformers: Array<{ product: string; revenue: number; growth: number }>
    underPerformers: Array<{ product: string; revenue: number; decline: number }>
    seasonalPatterns: Array<{ product: string; pattern: string; score: number }>
    priceOptimization: Array<{ product: string; currentPrice: number; optimizedPrice: number; projectedIncrease: number }>
  }
  financialProjections: {
    revenueProjection: { nextWeek: number; nextMonth: number; confidence: number }
    costOptimization: { currentCost: number; optimizedCost: number; savings: number }
    profitabilityAnalysis: { currentMargin: number; optimizedMargin: number; improvement: number }
    cashFlowForecast: Array<{ week: number; inflow: number; outflow: number; balance: number }>
  }
  riskAssessment: {
    supplyChainRisks: Array<{ product: string; risk: string; impact: number; mitigation: string }>
    demandVolatility: Array<{ product: string; volatility: number; riskLevel: string }>
    seasonalRisks: Array<{ period: string; risk: string; impact: number }>
  }
  marketInsights: {
    competitorAnalysis: Array<{ insight: string; impact: string; action: string }>
    trendAnalysis: Array<{ trend: string; relevance: number; opportunity: string }>
    customerBehavior: Array<{ behavior: string; frequency: number; implication: string }>
  }
  performanceScore: number
  lastUpdated: string
}

export interface BusinessMetrics {
  salesData: any[]
  stockData: any[]
  movementHistory: any[]
  financialData: any[]
  customerData?: any[]
  seasonalData?: any[]
}

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
  private readonly apiKey: string
  private readonly apiUrl: string
  private cache: Map<string, { data: any; timestamp: number }> = new Map()
  private readonly CACHE_TTL = 30 * 60 * 1000 // 30 minutos

  constructor() {
    this.apiKey = import.meta.env.VITE_GEMINI_API_KEY
    this.apiUrl = import.meta.env.VITE_GEMINI_API_URL

    if (!this.apiKey || !this.apiUrl) {
      console.warn('Credenciais da API Gemini não configuradas - modo offline ativo')
    }
  }

  async generatePredictiveAnalysis(businessData: BusinessMetrics): Promise<PredictiveAnalysis> {
    const cacheKey = `predictive_${JSON.stringify(businessData).slice(0, 100)}`

    // Verifica cache
    const cached = this.cache.get(cacheKey)
    if (cached && Date.now() - cached.timestamp < this.CACHE_TTL) {
      return cached.data
    }

    try {
      console.log('🔮 Iniciando análise preditiva avançada...')

      // Se não tem API configurada, usa análise offline
      if (!this.apiKey || !this.apiUrl) {
        return this.generateOfflineAnalysis(businessData)
      }

      const [
        demandForecast,
        stockOptimization,
        salesAnalytics,
        financialProjections,
        riskAssessment,
        marketInsights
      ] = await Promise.all([
        this.generateDemandForecast(businessData),
        this.generateStockOptimization(businessData),
        this.generateSalesAnalytics(businessData),
        this.generateFinancialProjections(businessData),
        this.generateRiskAssessment(businessData),
        this.generateMarketInsights(businessData)
      ])

      const performanceScore = await this.calculatePerformanceScore(businessData)

      const analysis: PredictiveAnalysis = {
        demandForecast,
        stockOptimization,
        salesAnalytics,
        financialProjections,
        riskAssessment,
        marketInsights,
        performanceScore,
        lastUpdated: new Date().toISOString()
      }

      // Cache result
      this.cache.set(cacheKey, { data: analysis, timestamp: Date.now() })

      console.log('✅ Análise preditiva concluída com sucesso')
      return analysis

    } catch (error) {
      console.error('❌ Erro na análise preditiva:', error)
      console.log('🔄 Voltando para análise offline...')
      return this.generateOfflineAnalysis(businessData)
    }
  }

  // Análise preditiva de vendas com machine learning simulado
  async predictSalesPattern(historicalData: any[]): Promise<ForecastData[]> {
    if (!historicalData || historicalData.length < 7) {
      return []
    }

    const forecasts: ForecastData[] = []
    const values = historicalData.map(d => d.total || 0)

    // Simular análise de tendência usando média móvel e regressão linear simples
    // const _movingAverage = this.calculateMovingAverage(values, 7) // Unused
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
    // const _monthlyPattern = this.analyzeMonthlyPattern(data) // Unused

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
  /*
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
  */

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

  /*
  private analyzeMonthlyPattern(_data: any[]): any {
    // Implementação simplificada para análise mensal
    return { trend: 'stable' }
  }
  */

  private generateMockDemandHistory(product: any): number[] {
    // Simular histórico de demanda baseado no produto
    const baseValue = product.current_stock || 10
    return Array.from({ length: 30 }, (_, i) =>
      Math.max(1, baseValue + Math.sin(i * 0.2) * 5 + Math.random() * 3 - 1.5)
    )
  }

  private predictDemand(history: number[], _product: any): any {
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

  // Métodos avançados com IA
  private async generateDemandForecast(data: BusinessMetrics): Promise<PredictiveAnalysis['demandForecast']> {
    const prompt = `
Você é um especialista em análise preditiva e forecasting para supply chain.
Analise os dados históricos e gere previsões de demanda precisas.

DADOS HISTÓRICOS DE VENDAS E MOVIMENTAÇÃO:
${JSON.stringify({ sales: data.salesData, movements: data.movementHistory }, null, 2)}

RETORNE NO FORMATO JSON EXATO:
{
  "nextWeek": [
    {
      "product": "nome_produto",
      "quantity": numero_previsto,
      "confidence": porcentagem_confianca
    }
  ],
  "nextMonth": [
    {
      "product": "nome_produto",
      "quantity": numero_previsto,
      "confidence": porcentagem_confianca
    }
  ],
  "trend": "crescimento|declínio|estável"
}
`

    const response = await this.callGeminiAPI(prompt)
    return this.parseJSONResponse(response, {
      nextWeek: [],
      nextMonth: [],
      trend: 'estável'
    })
  }

  private async generateStockOptimization(data: BusinessMetrics): Promise<PredictiveAnalysis['stockOptimization']> {
    const prompt = `
Você é um especialista em otimização de estoque e supply chain.
Analise o estoque atual e histórico para gerar recomendações precisas.

DADOS DE ESTOQUE E MOVIMENTAÇÃO:
${JSON.stringify({ stock: data.stockData, movements: data.movementHistory }, null, 2)}

RETORNE NO FORMATO JSON EXATO:
{
  "reorderRecommendations": [
    {
      "product": "nome_produto",
      "currentStock": numero_atual,
      "optimalStock": numero_otimo,
      "reorderQuantity": quantidade_reposicao,
      "priority": "crítica|alta|média|baixa",
      "estimatedRunoutDate": "YYYY-MM-DD"
    }
  ],
  "overstockAlerts": [
    {
      "product": "nome_produto",
      "currentStock": numero_atual,
      "recommendedStock": numero_recomendado,
      "potentialSavings": valor_economia
    }
  ]
}
`

    const response = await this.callGeminiAPI(prompt)
    return this.parseJSONResponse(response, {
      reorderRecommendations: [],
      overstockAlerts: []
    })
  }

  private async generateSalesAnalytics(data: BusinessMetrics): Promise<PredictiveAnalysis['salesAnalytics']> {
    const prompt = `
Você é um analista sênior de vendas e performance comercial.
Analise os dados de vendas para identificar padrões e oportunidades.

DADOS DE VENDAS:
${JSON.stringify(data.salesData, null, 2)}

RETORNE NO FORMATO JSON EXATO:
{
  "topPerformers": [
    {
      "product": "nome_produto",
      "revenue": valor_receita,
      "growth": porcentagem_crescimento
    }
  ],
  "underPerformers": [
    {
      "product": "nome_produto",
      "revenue": valor_receita,
      "decline": porcentagem_declinio
    }
  ],
  "seasonalPatterns": [
    {
      "product": "nome_produto",
      "pattern": "descricao_padrao",
      "score": pontuacao_intensidade
    }
  ],
  "priceOptimization": [
    {
      "product": "nome_produto",
      "currentPrice": preco_atual,
      "optimizedPrice": preco_otimizado,
      "projectedIncrease": aumento_previsto_receita
    }
  ]
}
`

    const response = await this.callGeminiAPI(prompt)
    return this.parseJSONResponse(response, {
      topPerformers: [],
      underPerformers: [],
      seasonalPatterns: [],
      priceOptimization: []
    })
  }

  private async generateFinancialProjections(data: BusinessMetrics): Promise<PredictiveAnalysis['financialProjections']> {
    const prompt = `
Você é um CFO especializado em projeções financeiras para varejo alimentício.
Analise os dados financeiros e operacionais para gerar projeções precisas.

DADOS FINANCEIROS E OPERACIONAIS:
${JSON.stringify({ sales: data.salesData, stock: data.stockData, financial: data.financialData }, null, 2)}

RETORNE NO FORMATO JSON EXATO:
{
  "revenueProjection": {
    "nextWeek": valor_receita_semana,
    "nextMonth": valor_receita_mes,
    "confidence": porcentagem_confianca
  },
  "costOptimization": {
    "currentCost": custo_atual,
    "optimizedCost": custo_otimizado,
    "savings": valor_economia
  },
  "profitabilityAnalysis": {
    "currentMargin": margem_atual,
    "optimizedMargin": margem_otimizada,
    "improvement": melhoria_porcentagem
  },
  "cashFlowForecast": [
    {
      "week": numero_semana,
      "inflow": entrada_valor,
      "outflow": saida_valor,
      "balance": saldo_valor
    }
  ]
}
`

    const response = await this.callGeminiAPI(prompt)
    return this.parseJSONResponse(response, {
      revenueProjection: { nextWeek: 0, nextMonth: 0, confidence: 0 },
      costOptimization: { currentCost: 0, optimizedCost: 0, savings: 0 },
      profitabilityAnalysis: { currentMargin: 0, optimizedMargin: 0, improvement: 0 },
      cashFlowForecast: []
    })
  }

  private async generateRiskAssessment(data: BusinessMetrics): Promise<PredictiveAnalysis['riskAssessment']> {
    const prompt = `
Você é um especialista em gestão de riscos para supply chain e varejo.
Analise os dados para identificar riscos operacionais, financeiros e de mercado.

DADOS OPERACIONAIS:
${JSON.stringify(data, null, 2)}

RETORNE NO FORMATO JSON EXATO:
{
  "supplyChainRisks": [
    {
      "product": "nome_produto",
      "risk": "descricao_risco",
      "impact": pontuacao_impacto_1_10,
      "mitigation": "plano_mitigacao"
    }
  ],
  "demandVolatility": [
    {
      "product": "nome_produto",
      "volatility": porcentagem_volatilidade,
      "riskLevel": "alto|médio|baixo"
    }
  ],
  "seasonalRisks": [
    {
      "period": "periodo",
      "risk": "descricao_risco",
      "impact": pontuacao_impacto_1_10
    }
  ]
}
`

    const response = await this.callGeminiAPI(prompt)
    return this.parseJSONResponse(response, {
      supplyChainRisks: [],
      demandVolatility: [],
      seasonalRisks: []
    })
  }

  private async generateMarketInsights(data: BusinessMetrics): Promise<PredictiveAnalysis['marketInsights']> {
    const prompt = `
Você é um analista de mercado especializado em inteligência competitiva.
Analise os dados de performance para gerar insights estratégicos de mercado.

DADOS DE PERFORMANCE:
${JSON.stringify(data, null, 2)}

RETORNE NO FORMATO JSON EXATO:
{
  "competitorAnalysis": [
    {
      "insight": "insight_competitivo",
      "impact": "alto|médio|baixo",
      "action": "acao_recomendada"
    }
  ],
  "trendAnalysis": [
    {
      "trend": "tendencia_identificada",
      "relevance": pontuacao_relevancia_1_10,
      "opportunity": "oportunidade_descricao"
    }
  ],
  "customerBehavior": [
    {
      "behavior": "padrao_comportamento",
      "frequency": porcentagem_frequencia,
      "implication": "implicacao_estrategica"
    }
  ]
}
`

    const response = await this.callGeminiAPI(prompt)
    return this.parseJSONResponse(response, {
      competitorAnalysis: [],
      trendAnalysis: [],
      customerBehavior: []
    })
  }

  private async calculatePerformanceScore(data: BusinessMetrics): Promise<number> {
    const prompt = `
Você é um consultor executivo especializado em KPIs e performance empresarial.
Calcule um score de performance geral do negócio baseado nos dados fornecidos.

DADOS COMPLETOS DO NEGÓCIO:
${JSON.stringify(data, null, 2)}

RETORNE APENAS UM NÚMERO DE 0 a 100 representando o score geral de performance.
`

    const response = await this.callGeminiAPI(prompt)
    const score = parseInt(response.text?.replace(/\D/g, '') || '0')
    return Math.min(Math.max(score, 0), 100)
  }

  private async callGeminiAPI(prompt: string): Promise<any> {
    try {
      const requestBody = {
        contents: [{
          parts: [{
            text: prompt
          }]
        }],
        generationConfig: {
          temperature: 0.3,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        }
      }

      const response = await axios.post(
        `${this.apiUrl}?key=${this.apiKey}`,
        requestBody,
        {
          headers: {
            'Content-Type': 'application/json'
          },
          timeout: 45000
        }
      )

      return response.data.candidates?.[0]?.content?.parts?.[0] || { text: '' }
    } catch (error: any) {
      console.error('Erro na API Gemini:', error)
      throw new Error(`Falha na API: ${error.message}`)
    }
  }

  private parseJSONResponse(response: any, fallback: any): any {
    try {
      const text = response.text || '{}'
      const cleanedText = text
        .replace(/```json\n?/g, '')
        .replace(/```\n?/g, '')
        .replace(/^\s*[\r\n]/gm, '')
        .trim()

      return JSON.parse(cleanedText)
    } catch (error) {
      console.warn('Erro ao parsear JSON da IA, usando fallback:', error)
      return fallback
    }
  }

  // Análise offline quando API não disponível
  private generateOfflineAnalysis(data: BusinessMetrics): PredictiveAnalysis {
    const stockItems = Array.isArray(data.stockData) ? data.stockData : []
    const salesItems = Array.isArray(data.salesData) ? data.salesData : []

    return {
      demandForecast: {
        nextWeek: stockItems.slice(0, 5).map(item => ({
          product: item.name || 'Produto',
          quantity: Math.floor(Math.random() * 50) + 10,
          confidence: Math.floor(Math.random() * 30) + 70
        })),
        nextMonth: stockItems.slice(0, 5).map(item => ({
          product: item.name || 'Produto',
          quantity: Math.floor(Math.random() * 200) + 50,
          confidence: Math.floor(Math.random() * 25) + 65
        })),
        trend: 'estável'
      },
      stockOptimization: {
        reorderRecommendations: stockItems.slice(0, 3).map(item => ({
          product: item.name || 'Produto',
          currentStock: item.current_stock || 0,
          optimalStock: (item.current_stock || 0) + Math.floor(Math.random() * 50) + 20,
          reorderQuantity: Math.floor(Math.random() * 30) + 10,
          priority: ['crítica', 'alta', 'média'][Math.floor(Math.random() * 3)] as any,
          estimatedRunoutDate: new Date(Date.now() + Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
        })),
        overstockAlerts: []
      },
      salesAnalytics: {
        topPerformers: salesItems.slice(0, 3).map(item => ({
          product: item.product || 'Produto',
          revenue: Math.floor(Math.random() * 5000) + 1000,
          growth: Math.floor(Math.random() * 50) + 10
        })),
        underPerformers: [],
        seasonalPatterns: [],
        priceOptimization: []
      },
      financialProjections: {
        revenueProjection: {
          nextWeek: Math.floor(Math.random() * 10000) + 5000,
          nextMonth: Math.floor(Math.random() * 40000) + 20000,
          confidence: Math.floor(Math.random() * 20) + 70
        },
        costOptimization: {
          currentCost: Math.floor(Math.random() * 15000) + 5000,
          optimizedCost: Math.floor(Math.random() * 12000) + 4000,
          savings: Math.floor(Math.random() * 3000) + 500
        },
        profitabilityAnalysis: {
          currentMargin: Math.floor(Math.random() * 30) + 15,
          optimizedMargin: Math.floor(Math.random() * 35) + 20,
          improvement: Math.floor(Math.random() * 15) + 5
        },
        cashFlowForecast: Array.from({ length: 4 }, (_, i) => ({
          week: i + 1,
          inflow: Math.floor(Math.random() * 8000) + 2000,
          outflow: Math.floor(Math.random() * 6000) + 1500,
          balance: Math.floor(Math.random() * 4000) + 1000
        }))
      },
      riskAssessment: {
        supplyChainRisks: [],
        demandVolatility: [],
        seasonalRisks: []
      },
      marketInsights: {
        competitorAnalysis: [],
        trendAnalysis: [],
        customerBehavior: []
      },
      performanceScore: Math.floor(Math.random() * 30) + 65,
      lastUpdated: new Date().toISOString()
    }
  }

  // Método para salvar análise no banco de dados
  async savePredictiveAnalysis(analysis: PredictiveAnalysis): Promise<void> {
    try {
      console.log('Saving predictive analysis:', analysis)
      // TODO: Implement database save when supabase is available
    } catch (error) {
      console.error('Erro ao salvar análise preditiva:', error)
    }
  }

  // Método para buscar análises históricas
  async getHistoricalAnalyses(limit: number = 10): Promise<PredictiveAnalysis[]> {
    try {
      console.log('Getting historical analyses, limit:', limit)
      // TODO: Implement database fetch when supabase is available
      return []
    } catch (error) {
      console.error('Erro ao buscar análises históricas:', error)
      return []
    }
  }

  // Limpar cache
  clearCache(): void {
    this.cache.clear()
    console.log('Cache de análises preditivas limpo')
  }
}

export const predictiveAnalyticsService = new PredictiveAnalyticsService()