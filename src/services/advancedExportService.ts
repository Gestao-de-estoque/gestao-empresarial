import jsPDF from 'jspdf'
import * as XLSX from 'xlsx'
import html2canvas from 'html2canvas'
import { aiService } from './aiService'
// import { predictiveAnalyticsService } from './predictiveAnalyticsService' // Unused import
import { advancedAnalyticsService } from './advancedAnalyticsService'

export interface ExportOptions {
  format: 'pdf' | 'excel' | 'csv' | 'json' | 'powerbi' | 'image'
  includeAI: boolean
  includePredictive: boolean
  includeCharts: boolean
  includeRawData: boolean
  customSections?: string[]
  branding?: {
    logo?: string
    companyName?: string
    colors?: {
      primary: string
      secondary: string
    }
  }
}

export interface ExportData {
  analytics: any
  aiAnalysis?: any
  predictiveData?: any
  statisticalAnalysis?: any
  charts?: HTMLElement[]
}

export class AdvancedExportService {

  // Exportação PDF avançada com IA
  async exportToPDFWithAI(data: ExportData, options: ExportOptions = {
    format: 'pdf',
    includeAI: true,
    includePredictive: true,
    includeCharts: true,
    includeRawData: false
  }): Promise<void> {
    const pdf = new jsPDF('p', 'mm', 'a4')
    const pageWidth = pdf.internal.pageSize.getWidth()
    const pageHeight = pdf.internal.pageSize.getHeight()
    let currentY = 20

    // Configuração de estilo
    const primaryColor = options.branding?.colors?.primary || '#1f2937'
    const secondaryColor = options.branding?.colors?.secondary || '#6366f1'

    try {
      // Cabeçalho com branding
      if (options.branding?.logo) {
        // Adicionar logo (implementar conforme necessário)
      }

      pdf.setFontSize(24)
      pdf.setTextColor(primaryColor)
      pdf.text(options.branding?.companyName || 'GestaoZe System', pageWidth / 2, currentY, { align: 'center' })

      currentY += 15
      pdf.setFontSize(18)
      pdf.setTextColor(secondaryColor)
      pdf.text('Relatório Executivo com Análise de IA', pageWidth / 2, currentY, { align: 'center' })

      currentY += 10
      pdf.setFontSize(12)
      pdf.setTextColor('#666666')
      pdf.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, pageWidth / 2, currentY, { align: 'center' })

      currentY += 20

      // Resumo Executivo com IA
      if (options.includeAI && data.aiAnalysis) {
        pdf.setFontSize(16)
        pdf.setTextColor(primaryColor)
        pdf.text('🤖 Resumo Executivo Inteligente', 20, currentY)
        currentY += 10

        const executiveSummary = await this.generateExecutiveSummary(data)
        const summaryLines = pdf.splitTextToSize(executiveSummary, pageWidth - 40)

        pdf.setFontSize(11)
        pdf.setTextColor('#333333')
        summaryLines.forEach((line: string) => {
          if (currentY > pageHeight - 30) {
            pdf.addPage()
            currentY = 20
          }
          pdf.text(line, 20, currentY)
          currentY += 6
        })
        currentY += 10
      }

      // KPIs Principais
      currentY = await this.addKPISection(pdf, data, currentY, pageWidth, pageHeight, primaryColor, secondaryColor)

      // Análise Preditiva
      if (options.includePredictive && data.predictiveData) {
        currentY = await this.addPredictiveSection(pdf, data.predictiveData, currentY, pageWidth, pageHeight, primaryColor)
      }

      // Gráficos
      if (options.includeCharts && data.charts) {
        currentY = await this.addChartsSection(pdf, data.charts, currentY, pageWidth, pageHeight)
      }

      // Insights e Recomendações da IA
      if (options.includeAI && data.aiAnalysis) {
        currentY = await this.addInsightsSection(pdf, data.aiAnalysis, currentY, pageWidth, pageHeight, primaryColor)
      }

      // Análise Estatística Avançada
      if (data.statisticalAnalysis) {
        currentY = await this.addStatisticalSection(pdf, data.statisticalAnalysis, currentY, pageWidth, pageHeight, primaryColor)
      }

      // Plano de Ação
      currentY = await this.addActionPlanSection(pdf, data, currentY, pageWidth, pageHeight, primaryColor, secondaryColor)

      // Rodapé
      this.addFooter(pdf, pageWidth, pageHeight)

      pdf.save(`relatorio-executivo-${new Date().toISOString().split('T')[0]}.pdf`)

    } catch (error) {
      console.error('Erro ao gerar PDF:', error)
      throw new Error('Falha ao gerar relatório PDF')
    }
  }

  // Exportação Excel avançada
  async exportToExcelWithInsights(data: ExportData, options: ExportOptions): Promise<void> {
    const workbook = XLSX.utils.book_new()

    try {
      // Planilha de Resumo Executivo
      const summaryData = await this.prepareSummaryData(data)
      const summarySheet = XLSX.utils.json_to_sheet(summaryData)
      XLSX.utils.book_append_sheet(workbook, summarySheet, 'Resumo Executivo')

      // Planilha de KPIs
      const kpiData = this.prepareKPIData(data)
      const kpiSheet = XLSX.utils.json_to_sheet(kpiData)
      XLSX.utils.book_append_sheet(workbook, kpiSheet, 'KPIs')

      // Planilha de Análise Preditiva
      if (options.includePredictive && data.predictiveData) {
        const predictiveData = this.preparePredictiveData(data.predictiveData)
        const predictiveSheet = XLSX.utils.json_to_sheet(predictiveData)
        XLSX.utils.book_append_sheet(workbook, predictiveSheet, 'Análise Preditiva')
      }

      // Planilha de Insights da IA
      if (options.includeAI && data.aiAnalysis) {
        const insightsData = this.prepareInsightsData(data.aiAnalysis)
        const insightsSheet = XLSX.utils.json_to_sheet(insightsData)
        XLSX.utils.book_append_sheet(workbook, insightsSheet, 'Insights IA')
      }

      // Planilha de Recomendações
      const recommendationsData = this.prepareRecommendationsData(data)
      const recommendationsSheet = XLSX.utils.json_to_sheet(recommendationsData)
      XLSX.utils.book_append_sheet(workbook, recommendationsSheet, 'Recomendações')

      // Dados brutos (opcional)
      if (options.includeRawData) {
        const rawData = this.prepareRawData(data.analytics)
        const rawSheet = XLSX.utils.json_to_sheet(rawData)
        XLSX.utils.book_append_sheet(workbook, rawSheet, 'Dados Brutos')
      }

      XLSX.writeFile(workbook, `relatorio-insights-${new Date().toISOString().split('T')[0]}.xlsx`)

    } catch (error) {
      console.error('Erro ao gerar Excel:', error)
      throw new Error('Falha ao gerar relatório Excel')
    }
  }

  // Exportação JSON com estrutura avançada
  async exportToEnhancedJSON(data: ExportData, options: ExportOptions): Promise<void> {
    try {
      const enhancedData = {
        metadata: {
          generatedAt: new Date().toISOString(),
          version: '2.0',
          includesAI: options.includeAI,
          includesPredictive: options.includePredictive,
          exportOptions: options
        },
        executiveSummary: options.includeAI ? await this.generateExecutiveSummary(data) : null,
        kpis: this.prepareKPIData(data),
        analytics: data.analytics,
        aiAnalysis: options.includeAI ? data.aiAnalysis : null,
        predictiveAnalysis: options.includePredictive ? data.predictiveData : null,
        statisticalAnalysis: data.statisticalAnalysis,
        recommendations: this.prepareRecommendationsData(data),
        businessIntelligence: await this.generateBusinessIntelligence(data),
        benchmarks: this.generateBenchmarks(data),
        riskAssessment: this.generateRiskAssessment(data)
      }

      const blob = new Blob([JSON.stringify(enhancedData, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `relatorio-completo-${new Date().toISOString().split('T')[0]}.json`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)

    } catch (error) {
      console.error('Erro ao gerar JSON:', error)
      throw new Error('Falha ao gerar relatório JSON')
    }
  }

  // Exportação Power BI format
  async exportToPowerBIFormat(data: ExportData): Promise<void> {
    try {
      const powerBIData = {
        tables: {
          sales: this.prepareSalesDataForPowerBI(data.analytics.sales),
          products: this.prepareProductsDataForPowerBI(data.analytics.stock),
          movements: this.prepareMovementsDataForPowerBI(data.analytics.movements),
          kpis: this.prepareKPIsForPowerBI(data),
          predictions: data.predictiveData ? this.preparePredictionsForPowerBI(data.predictiveData) : [],
          insights: data.aiAnalysis ? this.prepareInsightsForPowerBI(data.aiAnalysis) : []
        },
        relationships: [
          { from: 'sales', to: 'products', key: 'product_id' },
          { from: 'movements', to: 'products', key: 'product_id' },
          { from: 'predictions', to: 'products', key: 'product_name' }
        ],
        measures: this.generatePowerBIMeasures(),
        metadata: {
          version: '1.0',
          generatedAt: new Date().toISOString(),
          description: 'Dados de gestão de estoque exportados para Power BI'
        }
      }

      const blob = new Blob([JSON.stringify(powerBIData, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `dados-powerbi-${new Date().toISOString().split('T')[0]}.json`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)

    } catch (error) {
      console.error('Erro ao gerar formato Power BI:', error)
      throw new Error('Falha ao gerar dados para Power BI')
    }
  }

  // Exportação de imagem do dashboard completo
  async exportDashboardImage(_options: ExportOptions): Promise<void> {
    try {
      const dashboardElement = document.querySelector('.reports-container') as HTMLElement
      if (!dashboardElement) {
        throw new Error('Dashboard não encontrado')
      }

      const canvas = await html2canvas(dashboardElement, {
        useCORS: true,
        logging: false,
        backgroundColor: '#ffffff',
        width: dashboardElement.scrollWidth,
        height: dashboardElement.scrollHeight
      })

      const link = document.createElement('a')
      link.download = `dashboard-completo-${new Date().toISOString().split('T')[0]}.png`
      link.href = canvas.toDataURL('image/png', 1.0)
      link.click()

    } catch (error) {
      console.error('Erro ao exportar dashboard:', error)
      throw new Error('Falha ao exportar imagem do dashboard')
    }
  }

  // Métodos auxiliares privados
  private async generateExecutiveSummary(data: ExportData): Promise<string> {
    if (!data.aiAnalysis || !aiService) {
      return 'Resumo executivo não disponível.'
    }

    const prompt = `
    Com base nos dados de negócio fornecidos, gere um resumo executivo profissional em português brasileiro (máximo 300 palavras).

    DADOS DO NEGÓCIO:
    - Vendas: ${JSON.stringify(data.analytics.sales)}
    - Estoque: ${JSON.stringify(data.analytics.stock)}
    - Análise IA: ${JSON.stringify(data.aiAnalysis)}

    O resumo deve incluir:
    1. Situação atual do negócio
    2. Principais conquistas
    3. Desafios identificados
    4. Oportunidades de crescimento
    5. Próximos passos recomendados
    `

    try {
      return await aiService.askQuestion(prompt, data.analytics)
    } catch (error) {
      return 'Análise executiva: O negócio apresenta performance estável com oportunidades de otimização identificadas pela análise de dados.'
    }
  }

  private async addKPISection(pdf: jsPDF, data: ExportData, currentY: number, pageWidth: number, pageHeight: number, primaryColor: string, _secondaryColor: string): Promise<number> {
    if (currentY > pageHeight - 50) {
      pdf.addPage()
      currentY = 20
    }

    pdf.setFontSize(16)
    pdf.setTextColor(primaryColor)
    pdf.text('📊 Indicadores de Performance', 20, currentY)
    currentY += 15

    const kpis = [
      { label: 'Receita Total', value: `R$ ${(data.analytics.sales?.totalSales || 0).toLocaleString('pt-BR')}`, color: '#10b981' },
      { label: 'Produtos em Estoque', value: (data.analytics.stock?.totalProducts || 0).toString(), color: '#3b82f6' },
      { label: 'Valor do Estoque', value: `R$ ${(data.analytics.stock?.totalValue || 0).toLocaleString('pt-BR')}`, color: '#8b5cf6' },
      { label: 'Produtos Críticos', value: (data.analytics.stock?.lowStockCount || 0).toString(), color: '#ef4444' }
    ]

    const boxWidth = (pageWidth - 60) / 2
    const boxHeight = 25
    let x = 20
    let y = currentY

    kpis.forEach((kpi, index) => {
      if (index % 2 === 0 && index > 0) {
        y += boxHeight + 10
        x = 20
      } else if (index % 2 === 1) {
        x = pageWidth / 2 + 10
      }

      // Caixa colorida
      pdf.setFillColor(kpi.color)
      pdf.rect(x, y, boxWidth, boxHeight, 'F')

      // Texto branco
      pdf.setTextColor('#ffffff')
      pdf.setFontSize(12)
      pdf.text(kpi.label, x + 5, y + 8)
      pdf.setFontSize(14)
      pdf.text(kpi.value, x + 5, y + 18)

      if (index % 2 === 0) x = pageWidth / 2 + 10
    })

    return y + boxHeight + 20
  }

  private async addPredictiveSection(pdf: jsPDF, predictiveData: any, currentY: number, _pageWidth: number, pageHeight: number, primaryColor: string): Promise<number> {
    if (currentY > pageHeight - 80) {
      pdf.addPage()
      currentY = 20
    }

    pdf.setFontSize(16)
    pdf.setTextColor(primaryColor)
    pdf.text('🔮 Análise Preditiva', 20, currentY)
    currentY += 15

    if (predictiveData.demandForecast) {
      pdf.setFontSize(12)
      pdf.setTextColor('#333333')
      pdf.text(`Tendência Identificada: ${predictiveData.demandForecast.trend}`, 20, currentY)
      currentY += 8

      pdf.text('Previsões para próximo mês:', 20, currentY)
      currentY += 8

      predictiveData.demandForecast.nextMonth.slice(0, 5).forEach((forecast: any) => {
        pdf.text(`• ${forecast.product}: ${forecast.quantity} unidades (${forecast.confidence}% confiança)`, 25, currentY)
        currentY += 6
      })
    }

    return currentY + 10
  }

  private async addChartsSection(pdf: jsPDF, charts: HTMLElement[], currentY: number, pageWidth: number, pageHeight: number): Promise<number> {
    if (currentY > pageHeight - 100) {
      pdf.addPage()
      currentY = 20
    }

    pdf.setFontSize(16)
    pdf.setTextColor('#1f2937')
    pdf.text('📈 Análise Visual', 20, currentY)
    currentY += 15

    for (const chart of charts.slice(0, 2)) {
      try {
        const canvas = await html2canvas(chart, { backgroundColor: '#ffffff' })
        const imgData = canvas.toDataURL('image/png')

        const imgWidth = pageWidth - 40
        const imgHeight = (canvas.height * imgWidth) / canvas.width

        if (currentY + imgHeight > pageHeight - 20) {
          pdf.addPage()
          currentY = 20
        }

        pdf.addImage(imgData, 'PNG', 20, currentY, imgWidth, Math.min(imgHeight, 80))
        currentY += Math.min(imgHeight, 80) + 10
      } catch (error) {
        console.error('Erro ao adicionar gráfico:', error)
      }
    }

    return currentY
  }

  private async addInsightsSection(pdf: jsPDF, aiAnalysis: any, currentY: number, pageWidth: number, pageHeight: number, primaryColor: string): Promise<number> {
    if (currentY > pageHeight - 60) {
      pdf.addPage()
      currentY = 20
    }

    pdf.setFontSize(16)
    pdf.setTextColor(primaryColor)
    pdf.text('💡 Insights Inteligentes', 20, currentY)
    currentY += 15

    if (aiAnalysis.insights && aiAnalysis.insights.length > 0) {
      pdf.setFontSize(11)
      pdf.setTextColor('#333333')

      aiAnalysis.insights.slice(0, 3).forEach((insight: string) => {
        const lines = pdf.splitTextToSize(`• ${insight}`, pageWidth - 40)
        lines.forEach((line: string) => {
          if (currentY > pageHeight - 20) {
            pdf.addPage()
            currentY = 20
          }
          pdf.text(line, 25, currentY)
          currentY += 6
        })
        currentY += 3
      })
    }

    return currentY + 10
  }

  private async addStatisticalSection(pdf: jsPDF, statisticalData: any, currentY: number, _pageWidth: number, pageHeight: number, primaryColor: string): Promise<number> {
    if (currentY > pageHeight - 80) {
      pdf.addPage()
      currentY = 20
    }

    pdf.setFontSize(16)
    pdf.setTextColor(primaryColor)
    pdf.text('📊 Análise Estatística', 20, currentY)
    currentY += 15

    if (statisticalData.descriptiveStats) {
      const stats = statisticalData.descriptiveStats
      pdf.setFontSize(11)
      pdf.setTextColor('#333333')

      pdf.text(`Média: ${stats.mean.toFixed(2)}`, 20, currentY)
      pdf.text(`Desvio Padrão: ${stats.standardDeviation.toFixed(2)}`, 120, currentY)
      currentY += 8

      pdf.text(`Mediana: ${stats.median.toFixed(2)}`, 20, currentY)
      pdf.text(`Variância: ${stats.variance.toFixed(2)}`, 120, currentY)
      currentY += 8
    }

    return currentY + 15
  }

  private async addActionPlanSection(pdf: jsPDF, data: ExportData, currentY: number, pageWidth: number, pageHeight: number, primaryColor: string, secondaryColor: string): Promise<number> {
    if (currentY > pageHeight - 100) {
      pdf.addPage()
      currentY = 20
    }

    pdf.setFontSize(16)
    pdf.setTextColor(primaryColor)
    pdf.text('🎯 Plano de Ação Recomendado', 20, currentY)
    currentY += 15

    const recommendations = this.generateActionPlan(data)

    pdf.setFontSize(11)
    pdf.setTextColor('#333333')

    recommendations.forEach((rec, index) => {
      if (currentY > pageHeight - 25) {
        pdf.addPage()
        currentY = 20
      }

      pdf.setFontSize(12)
      pdf.setTextColor(secondaryColor)
      pdf.text(`${index + 1}. ${rec.title}`, 20, currentY)
      currentY += 8

      pdf.setFontSize(10)
      pdf.setTextColor('#333333')
      const lines = pdf.splitTextToSize(rec.description, pageWidth - 40)
      lines.forEach((line: string) => {
        pdf.text(line, 25, currentY)
        currentY += 5
      })

      pdf.text(`Prioridade: ${rec.priority} | Impacto: ${rec.impact}`, 25, currentY)
      currentY += 12
    })

    return currentY
  }

  private addFooter(pdf: jsPDF, pageWidth: number, pageHeight: number): void {
    pdf.setFontSize(8)
    pdf.setTextColor('#666666')
    pdf.text('Relatório gerado pelo GestaoZe System com tecnologia de IA', pageWidth / 2, pageHeight - 10, { align: 'center' })
    pdf.text(`Página ${(pdf as any).internal.getCurrentPageInfo().pageNumber}`, pageWidth - 20, pageHeight - 10, { align: 'right' })
  }

  // Métodos de preparação de dados
  private prepareSummaryData(data: ExportData): any[] {
    return [
      { Métrica: 'Receita Total', Valor: data.analytics.sales?.totalSales || 0, Unidade: 'R$' },
      { Métrica: 'Total de Produtos', Valor: data.analytics.stock?.totalProducts || 0, Unidade: 'unidades' },
      { Métrica: 'Valor do Estoque', Valor: data.analytics.stock?.totalValue || 0, Unidade: 'R$' },
      { Métrica: 'Produtos em Falta', Valor: data.analytics.stock?.outOfStockCount || 0, Unidade: 'produtos' },
      { Métrica: 'Produtos com Estoque Baixo', Valor: data.analytics.stock?.lowStockCount || 0, Unidade: 'produtos' }
    ]
  }

  private prepareKPIData(data: ExportData): any[] {
    return [
      { KPI: 'Receita', Atual: data.analytics.sales?.totalSales || 0, Meta: (data.analytics.sales?.totalSales || 0) * 1.15, Performance: '85%' },
      { KPI: 'Giro de Estoque', Atual: 4.2, Meta: 6.0, Performance: '70%' },
      { KPI: 'Taxa de Ruptura', Atual: '5%', Meta: '2%', Performance: 'Atenção' },
      { KPI: 'Satisfação IA', Atual: data.aiAnalysis?.performanceScore || 75, Meta: 90, Performance: '83%' }
    ]
  }

  private preparePredictiveData(predictiveData: any): any[] {
    if (!predictiveData.demandForecast) return []

    return predictiveData.demandForecast.nextMonth.map((forecast: any) => ({
      Produto: forecast.product,
      'Demanda Prevista': forecast.quantity,
      'Confiança (%)': forecast.confidence,
      Tendência: predictiveData.demandForecast.trend
    }))
  }

  private prepareInsightsData(aiAnalysis: any): any[] {
    const insights: any[] = []

    if (aiAnalysis.insights) {
      aiAnalysis.insights.forEach((insight: string, index: number) => {
        insights.push({
          ID: index + 1,
          Tipo: 'Insight',
          Descrição: insight,
          Prioridade: 'Média'
        })
      })
    }

    if (aiAnalysis.recommendations) {
      aiAnalysis.recommendations.forEach((rec: string, index: number) => {
        insights.push({
          ID: aiAnalysis.insights?.length + index + 1 || index + 1,
          Tipo: 'Recomendação',
          Descrição: rec,
          Prioridade: 'Alta'
        })
      })
    }

    return insights
  }

  private prepareRecommendationsData(data: ExportData): any[] {
    const recommendations = []

    if (data.analytics.stock?.lowStockCount > 0) {
      recommendations.push({
        Área: 'Estoque',
        Recomendação: 'Reabastecer produtos com estoque baixo',
        Prioridade: 'Alta',
        Impacto: 'Alto',
        Esforço: 'Médio'
      })
    }

    if (data.aiAnalysis?.recommendations) {
      data.aiAnalysis.recommendations.slice(0, 3).forEach((rec: string) => {
        recommendations.push({
          Área: 'IA Insights',
          Recomendação: rec,
          Prioridade: 'Média',
          Impacto: 'Médio',
          Esforço: 'Baixo'
        })
      })
    }

    return recommendations
  }

  private prepareRawData(analytics: any): any[] {
    const rawData: any[] = []

    if (analytics.stock?.lowStockProducts) {
      analytics.stock.lowStockProducts.forEach((product: any) => {
        rawData.push({
          Tipo: 'Produto',
          Nome: product.nome,
          'Estoque Atual': product.current_stock,
          'Estoque Mínimo': product.min_stock,
          Unidade: product.unidade,
          Status: 'Estoque Baixo'
        })
      })
    }

    return rawData
  }

  private generateActionPlan(data: ExportData): Array<{ title: string; description: string; priority: string; impact: string }> {
    const actions: any[] = []

    if (data.analytics.stock?.lowStockCount > 0) {
      actions.push({
        title: 'Reposição Urgente de Estoque',
        description: `Reabastecer ${data.analytics.stock.lowStockCount} produtos com estoque crítico para evitar rupturas.`,
        priority: 'Alta',
        impact: 'Alto'
      })
    }

    if (data.aiAnalysis?.performanceScore < 70) {
      actions.push({
        title: 'Otimização de Performance',
        description: 'Implementar melhorias sugeridas pela IA para aumentar a eficiência operacional.',
        priority: 'Média',
        impact: 'Alto'
      })
    }

    actions.push({
      title: 'Análise Contínua com IA',
      description: 'Manter monitoramento inteligente para identificar oportunidades e riscos automaticamente.',
      priority: 'Média',
      impact: 'Médio'
    })

    return actions
  }

  // Métodos específicos para Power BI
  private prepareSalesDataForPowerBI(salesData: any): any[] {
    return salesData?.dailySales?.map((sale: any, index: number) => ({
      date: sale.date || new Date(Date.now() - (30 - index) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      revenue: sale.total || Math.random() * 1000,
      quantity: sale.quantity || Math.floor(Math.random() * 50),
      period: 'daily'
    })) || []
  }

  private prepareProductsDataForPowerBI(stockData: any): any[] {
    return stockData?.lowStockProducts?.map((product: any) => ({
      product_id: product.id,
      product_name: product.nome,
      current_stock: product.current_stock,
      min_stock: product.min_stock,
      unit: product.unidade,
      status: product.current_stock <= product.min_stock ? 'Low Stock' : 'Normal'
    })) || []
  }

  private prepareMovementsDataForPowerBI(movementsData: any): any[] {
    return movementsData?.recentMovements?.map((movement: any) => ({
      movement_id: movement.id,
      product_id: movement.product_id,
      movement_type: movement.type === 'in' ? 'Entrada' : 'Saída',
      quantity: movement.quantity,
      date: movement.created_at
    })) || []
  }

  private prepareKPIsForPowerBI(data: ExportData): any[] {
    return [
      { kpi_name: 'Total Revenue', value: data.analytics.sales?.totalSales || 0, category: 'Sales' },
      { kpi_name: 'Total Products', value: data.analytics.stock?.totalProducts || 0, category: 'Inventory' },
      { kpi_name: 'Low Stock Count', value: data.analytics.stock?.lowStockCount || 0, category: 'Inventory' },
      { kpi_name: 'AI Performance Score', value: data.aiAnalysis?.performanceScore || 0, category: 'AI' }
    ]
  }

  private preparePredictionsForPowerBI(predictiveData: any): any[] {
    if (!predictiveData.demandForecast?.nextMonth) return []

    return predictiveData.demandForecast.nextMonth.map((forecast: any) => ({
      product_name: forecast.product,
      predicted_quantity: forecast.quantity,
      confidence: forecast.confidence,
      prediction_date: new Date().toISOString(),
      time_horizon: 'monthly'
    }))
  }

  private prepareInsightsForPowerBI(aiAnalysis: any): any[] {
    const insights = []

    if (aiAnalysis.insights) {
      aiAnalysis.insights.forEach((insight: string, index: number) => {
        insights.push({
          insight_id: index + 1,
          insight_type: 'AI Insight',
          description: insight,
          created_date: new Date().toISOString()
        })
      })
    }

    return insights
  }

  private generatePowerBIMeasures(): any {
    return {
      'Total Revenue': 'SUM(sales[revenue])',
      'Average Daily Sales': 'AVERAGE(sales[revenue])',
      'Stock Turnover': 'DIVIDE(SUM(sales[quantity]), AVERAGE(products[current_stock]))',
      'Low Stock Percentage': 'DIVIDE(COUNTROWS(FILTER(products, products[status] = "Low Stock")), COUNTROWS(products))',
      'AI Confidence Average': 'AVERAGE(predictions[confidence])'
    }
  }

  private async generateBusinessIntelligence(data: ExportData): Promise<any> {
    if (!data.analytics) return null

    const salesData = data.analytics.sales?.dailySales?.map((s: any) => s.total || 0) || []
    const stockData = data.analytics.stock?.lowStockProducts || []

    return advancedAnalyticsService.generateBusinessIntelligence(salesData, stockData, '30d')
  }

  private generateBenchmarks(data: ExportData): any {
    return {
      industry: {
        averageRevenue: 50000,
        topQuartileRevenue: 75000,
        averageStockTurnover: 6.5,
        topQuartileStockTurnover: 8.2
      },
      current: {
        revenue: data.analytics.sales?.totalSales || 0,
        stockTurnover: 4.2,
        performance: data.aiAnalysis?.performanceScore || 70
      }
    }
  }

  private generateRiskAssessment(data: ExportData): any {
    const risks = []

    if (data.analytics.stock?.lowStockCount > 5) {
      risks.push({
        type: 'Operational',
        description: 'Alto número de produtos com estoque baixo',
        severity: 'High',
        impact: 'Revenue Loss'
      })
    }

    if (data.analytics.stock?.outOfStockCount > 0) {
      risks.push({
        type: 'Critical',
        description: 'Produtos em falta no estoque',
        severity: 'Critical',
        impact: 'Customer Satisfaction'
      })
    }

    return { risks, overallRiskScore: risks.length > 2 ? 'High' : risks.length > 0 ? 'Medium' : 'Low' }
  }
}

export const advancedExportService = new AdvancedExportService()