import axios from 'axios'

interface AIAnalysisResult {
  insights: string[]
  predictions: string[]
  recommendations: string[]
  trends: string[]
  alerts: string[]
  executiveSummary: string
  performanceScore: number
  futureProjections: {
    sales: number
    demand: string[]
    risks: string[]
  }
}

export class AIAnalyticsService {
  private readonly apiKey: string
  private readonly apiUrl: string

  constructor() {
    this.apiKey = import.meta.env.VITE_GEMINI_API_KEY
    this.apiUrl = import.meta.env.VITE_GEMINI_API_URL
  }

  async analyzeBusinessData(analyticsData: any): Promise<AIAnalysisResult> {
    const prompt = this.generateAnalysisPrompt(analyticsData)

    try {
      const response = await this.callGeminiAPI(prompt)
      return this.parseAIResponse(response)
    } catch (error) {
      console.error('Erro na análise de IA:', error)
      throw new Error('Falha ao gerar análise com IA')
    }
  }

  async generateExecutiveSummary(analyticsData: any): Promise<string> {
    const prompt = `
    Com base nos dados de gestão de estoque fornecidos, gere um resumo executivo profissional em português brasileiro.

    DADOS DO NEGÓCIO:
    - Total de Vendas: R$ ${this.formatCurrency(analyticsData.sales?.totalSales || 0)}
    - Total de Produtos: ${analyticsData.stock?.totalProducts || 0}
    - Produtos em Falta: ${analyticsData.stock?.outOfStockCount || 0}
    - Valor do Estoque: R$ ${this.formatCurrency(analyticsData.stock?.totalValue || 0)}
    - Produtos com Estoque Baixo: ${analyticsData.stock?.lowStockCount || 0}
    - Total de Movimentações: ${analyticsData.movements?.totalMovements || 0}

    DIRETRIZES:
    1. Seja conciso e objetivo (máximo 200 palavras)
    2. Destaque pontos principais de desempenho
    3. Identifique oportunidades de melhoria
    4. Use linguagem profissional executiva
    5. Forneça uma avaliação geral do negócio

    Formate a resposta como um parágrafo profissional.
    `

    try {
      const response = await this.callGeminiAPI(prompt)
      return response.text || 'Resumo não disponível'
    } catch (error) {
      console.error('Erro ao gerar resumo executivo:', error)
      return 'Não foi possível gerar o resumo executivo no momento.'
    }
  }

  async predictSalesTrends(salesData: any[]): Promise<any> {
    const prompt = `
    Analise os dados de vendas históricos e gere previsões para os próximos 30 dias.

    DADOS DE VENDAS:
    ${JSON.stringify(salesData, null, 2)}

    ANÁLISE SOLICITADA:
    1. Identifique tendências de crescimento ou declínio
    2. Preveja vendas para os próximos 30 dias
    3. Identifique padrões sazonais
    4. Sugira estratégias de otimização
    5. Alerte sobre possíveis riscos

    Retorne no formato JSON:
    {
      "trend": "crescimento|estável|declínio",
      "predictedSales": número_estimado,
      "confidence": porcentagem,
      "seasonalPatterns": ["padrão1", "padrão2"],
      "recommendations": ["recomendação1", "recomendação2"],
      "risks": ["risco1", "risco2"]
    }
    `

    try {
      const response = await this.callGeminiAPI(prompt)
      return JSON.parse(response.text || '{}')
    } catch (error) {
      console.error('Erro na previsão de vendas:', error)
      return null
    }
  }

  async analyzeInventoryOptimization(stockData: any): Promise<any> {
    const prompt = `
    Analise os dados de estoque e forneça recomendações de otimização.

    DADOS DO ESTOQUE:
    ${JSON.stringify(stockData, null, 2)}

    ANÁLISE SOLICITADA:
    1. Identifique produtos com giro inadequado
    2. Sugira níveis ótimos de estoque
    3. Alerte sobre produtos com risco de ruptura
    4. Recomende ações de reposição
    5. Calcule eficiência do estoque

    Retorne no formato JSON:
    {
      "efficiency": porcentagem,
      "overstockedItems": ["produto1", "produto2"],
      "understockedItems": ["produto1", "produto2"],
      "reorderRecommendations": [
        {
          "product": "nome_produto",
          "currentStock": número,
          "recommendedOrder": número,
          "priority": "alta|média|baixa"
        }
      ],
      "costOptimization": "valor_economizado_estimado"
    }
    `

    try {
      const response = await this.callGeminiAPI(prompt)
      return JSON.parse(response.text || '{}')
    } catch (error) {
      console.error('Erro na otimização de estoque:', error)
      return null
    }
  }

  async generateMarketInsights(salesData: any, period: string): Promise<string[]> {
    const prompt = `
    Com base nos dados de vendas do período de ${period}, forneça insights de mercado profissionais.

    DADOS DE VENDAS:
    ${JSON.stringify(salesData, null, 2)}

    INSIGHTS SOLICITADOS:
    1. Análise de performance de categorias
    2. Identificação de produtos estrela
    3. Oportunidades de cross-selling
    4. Análise de sazonalidade
    5. Benchmarks de mercado

    Retorne uma lista de 5-7 insights objetivos e acionáveis.
    `

    try {
      const response = await this.callGeminiAPI(prompt)
      return response.text?.split('\n').filter((line: string) => line.trim()) || []
    } catch (error) {
      console.error('Erro ao gerar insights de mercado:', error)
      return ['Insights de mercado não disponíveis no momento']
    }
  }

  private generateAnalysisPrompt(data: any): string {
    return `
    Você é um analista sênior de business intelligence especializado em gestão de estoque e vendas.
    Analise os dados fornecidos e gere insights estratégicos profissionais.

    DADOS PARA ANÁLISE:
    ${JSON.stringify(data, null, 2)}

    ANÁLISE COMPLETA SOLICITADA:

    1. INSIGHTS ESTRATÉGICOS:
       - Análise de performance geral
       - Identificação de tendências
       - Pontos fortes e fracos
       - Oportunidades de crescimento

    2. PREVISÕES:
       - Projeções de vendas
       - Demanda futura
       - Tendências de mercado
       - Sazonalidade

    3. RECOMENDAÇÕES ACIONÁVEIS:
       - Otimização de estoque
       - Estratégias de vendas
       - Redução de custos
       - Melhoria operacional

    4. ALERTAS E RISCOS:
       - Produtos críticos
       - Riscos financeiros
       - Oportunidades perdidas
       - Ações urgentes

    5. SCORE DE PERFORMANCE:
       - Avaliação geral (0-100)
       - Principais métricas
       - Comparativo setorial

    Retorne no formato JSON:
    {
      "insights": ["insight1", "insight2", ...],
      "predictions": ["previsão1", "previsão2", ...],
      "recommendations": ["recomendação1", "recomendação2", ...],
      "alerts": ["alerta1", "alerta2", ...],
      "performanceScore": número,
      "executiveSummary": "resumo_executivo_conciso",
      "futureProjections": {
        "sales": número_estimado,
        "demand": ["item1", "item2"],
        "risks": ["risco1", "risco2"]
      }
    }
    `
  }

  private async callGeminiAPI(prompt: string): Promise<any> {
    const requestBody = {
      contents: [{
        parts: [{
          text: prompt
        }]
      }]
    }

    const response = await axios.post(
      `${this.apiUrl}?key=${this.apiKey}`,
      requestBody,
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    )

    return response.data.candidates?.[0]?.content?.parts?.[0] || { text: '' }
  }

  private parseAIResponse(response: any): AIAnalysisResult {
    try {
      const parsed = JSON.parse(response.text || '{}')
      return {
        insights: parsed.insights || [],
        predictions: parsed.predictions || [],
        recommendations: parsed.recommendations || [],
        trends: parsed.trends || [],
        alerts: parsed.alerts || [],
        executiveSummary: parsed.executiveSummary || '',
        performanceScore: parsed.performanceScore || 0,
        futureProjections: parsed.futureProjections || {
          sales: 0,
          demand: [],
          risks: []
        }
      }
    } catch (error) {
      console.error('Erro ao parsear resposta da IA:', error)
      return {
        insights: ['Análise não disponível no momento'],
        predictions: [],
        recommendations: [],
        trends: [],
        alerts: [],
        executiveSummary: 'Resumo não disponível',
        performanceScore: 0,
        futureProjections: {
          sales: 0,
          demand: [],
          risks: []
        }
      }
    }
  }

  private formatCurrency(value: number): string {
    return new Intl.NumberFormat('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(value)
  }
}

export const aiAnalyticsService = new AIAnalyticsService()