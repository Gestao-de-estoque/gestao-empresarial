import { supabase, DB_TABLES } from '@/config/supabase'

export interface FinancialRecord {
  id?: number
  full_day: string // Data no formato DD/MM/YYYY
  amount: number // Valor do garçom (10%)
  total: number // Valor total do dia
  created_at?: string
  updated_at?: string
}

export interface FinancialSummary {
  totalRevenue: number
  totalWaiterSalary: number
  averageDailyRevenue: number
  averageWaiterSalary: number
  bestDay: FinancialRecord | null
  worstDay: FinancialRecord | null
  monthlyData: Array<{
    month: string
    revenue: number
    waiterSalary: number
  }>
  yearlyData: Array<{
    year: string
    revenue: number
    waiterSalary: number
  }>
}

class FinancialService {
  async getAllFinancialData(): Promise<FinancialRecord[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.FINANCIAL)
        .select('*')
        .order('full_day', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar dados financeiros:', error)
      throw error
    }
  }

  async getFinancialDataByDateRange(startDate: string, endDate: string): Promise<FinancialRecord[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.FINANCIAL)
        .select('*')
        .gte('created_at', startDate)
        .lte('created_at', endDate)
        .order('full_day', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar dados financeiros por período:', error)
      throw error
    }
  }

  async addFinancialRecord(record: Omit<FinancialRecord, 'id' | 'created_at' | 'updated_at'>): Promise<FinancialRecord> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.FINANCIAL)
        .insert([record])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao adicionar registro financeiro:', error)
      throw error
    }
  }

  async updateFinancialRecord(id: number, record: Partial<FinancialRecord>): Promise<FinancialRecord> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.FINANCIAL)
        .update({ ...record, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao atualizar registro financeiro:', error)
      throw error
    }
  }

  async deleteFinancialRecord(id: number): Promise<void> {
    try {
      const { error } = await supabase
        .from(DB_TABLES.FINANCIAL)
        .delete()
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Erro ao deletar registro financeiro:', error)
      throw error
    }
  }

  async getFinancialSummary(): Promise<FinancialSummary> {
    try {
      const data = await this.getAllFinancialData()

      if (!data.length) {
        return {
          totalRevenue: 0,
          totalWaiterSalary: 0,
          averageDailyRevenue: 0,
          averageWaiterSalary: 0,
          bestDay: null,
          worstDay: null,
          monthlyData: [],
          yearlyData: []
        }
      }

      const totalRevenue = data.reduce((sum, record) => sum + record.total, 0)
      const totalWaiterSalary = data.reduce((sum, record) => sum + record.amount, 0)
      const averageDailyRevenue = totalRevenue / data.length
      const averageWaiterSalary = totalWaiterSalary / data.length

      // Melhor e pior dia
      const bestDay = data.reduce((prev, current) =>
        current.total > prev.total ? current : prev
      )
      const worstDay = data.reduce((prev, current) =>
        current.total < prev.total ? current : prev
      )

      // Dados mensais
      const monthlyMap = new Map<string, { revenue: number; waiterSalary: number }>()
      data.forEach(record => {
        const [, month, year] = record.full_day.split('/')
        const monthKey = `${month}/${year}`

        if (!monthlyMap.has(monthKey)) {
          monthlyMap.set(monthKey, { revenue: 0, waiterSalary: 0 })
        }

        const monthData = monthlyMap.get(monthKey)!
        monthData.revenue += record.total
        monthData.waiterSalary += record.amount
      })

      const monthlyData = Array.from(monthlyMap.entries()).map(([month, data]) => ({
        month,
        revenue: data.revenue,
        waiterSalary: data.waiterSalary
      }))

      // Dados anuais
      const yearlyMap = new Map<string, { revenue: number; waiterSalary: number }>()
      data.forEach(record => {
        const [, , year] = record.full_day.split('/')

        if (!yearlyMap.has(year)) {
          yearlyMap.set(year, { revenue: 0, waiterSalary: 0 })
        }

        const yearData = yearlyMap.get(year)!
        yearData.revenue += record.total
        yearData.waiterSalary += record.amount
      })

      const yearlyData = Array.from(yearlyMap.entries()).map(([year, data]) => ({
        year,
        revenue: data.revenue,
        waiterSalary: data.waiterSalary
      }))

      return {
        totalRevenue,
        totalWaiterSalary,
        averageDailyRevenue,
        averageWaiterSalary,
        bestDay,
        worstDay,
        monthlyData,
        yearlyData
      }
    } catch (error) {
      console.error('Erro ao calcular resumo financeiro:', error)
      throw error
    }
  }

  async migrateDataFromJS(jsonData: Array<{ fullDay: string; amount: number; total: number }>): Promise<void> {
    try {
      // Primeiro, limpa a tabela existente
      await supabase.from(DB_TABLES.FINANCIAL).delete().neq('id', 0)

      // Converte os dados para o formato do banco
      const formattedData = jsonData.map(item => ({
        full_day: item.fullDay,
        amount: item.amount,
        total: item.total
      }))

      // Insere os dados em lotes para melhor performance
      const batchSize = 100
      for (let i = 0; i < formattedData.length; i += batchSize) {
        const batch = formattedData.slice(i, i + batchSize)
        const { error } = await supabase
          .from(DB_TABLES.FINANCIAL)
          .insert(batch)

        if (error) throw error
      }

      console.log(`Migração concluída: ${formattedData.length} registros inseridos`)
    } catch (error) {
      console.error('Erro na migração dos dados:', error)
      throw error
    }
  }

  // Análises específicas para IA
  async getFinancialAnalyticsData(): Promise<{
    dailyTrends: FinancialRecord[]
    monthlyAverages: Array<{ month: string; avgRevenue: number; avgWaiterSalary: number }>
    seasonalPatterns: Array<{ season: string; totalRevenue: number; avgDays: number }>
    performanceMetrics: {
      growth: number
      consistency: number
      efficiency: number
    }
  }> {
    try {
      const data = await this.getAllFinancialData()

      // Tendências diárias (últimos 30 registros)
      const dailyTrends = data.slice(-30)

      // Médias mensais
      const monthlyMap = new Map<string, { total: number; count: number; waiterTotal: number }>()
      data.forEach(record => {
        const [, month, year] = record.full_day.split('/')
        const monthKey = `${month}/${year}`

        if (!monthlyMap.has(monthKey)) {
          monthlyMap.set(monthKey, { total: 0, count: 0, waiterTotal: 0 })
        }

        const monthData = monthlyMap.get(monthKey)!
        monthData.total += record.total
        monthData.waiterTotal += record.amount
        monthData.count += 1
      })

      const monthlyAverages = Array.from(monthlyMap.entries()).map(([month, data]) => ({
        month,
        avgRevenue: data.total / data.count,
        avgWaiterSalary: data.waiterTotal / data.count
      }))

      // Padrões sazonais (simplificado por trimestre)
      const seasonalMap = new Map<string, { total: number; count: number }>()
      data.forEach(record => {
        const [, month] = record.full_day.split('/')
        const monthNum = parseInt(month)
        let season = ''

        if (monthNum >= 3 && monthNum <= 5) season = 'Q1'
        else if (monthNum >= 6 && monthNum <= 8) season = 'Q2'
        else if (monthNum >= 9 && monthNum <= 11) season = 'Q3'
        else season = 'Q4'

        if (!seasonalMap.has(season)) {
          seasonalMap.set(season, { total: 0, count: 0 })
        }

        const seasonData = seasonalMap.get(season)!
        seasonData.total += record.total
        seasonData.count += 1
      })

      const seasonalPatterns = Array.from(seasonalMap.entries()).map(([season, data]) => ({
        season,
        totalRevenue: data.total,
        avgDays: data.count
      }))

      // Métricas de performance
      const revenues = data.map(d => d.total)
      const avgRevenue = revenues.reduce((a, b) => a + b, 0) / revenues.length
      const growth = revenues.length > 1 ?
        ((revenues[revenues.length - 1] - revenues[0]) / revenues[0]) * 100 : 0

      // Consistência (baseada no desvio padrão)
      const variance = revenues.reduce((sum, revenue) =>
        sum + Math.pow(revenue - avgRevenue, 2), 0) / revenues.length
      const standardDeviation = Math.sqrt(variance)
      const consistency = Math.max(0, 100 - (standardDeviation / avgRevenue) * 100)

      // Eficiência (relação entre receita total e salário do garçom)
      const totalRevenue = revenues.reduce((a, b) => a + b, 0)
      const totalWaiterSalary = data.reduce((sum, record) => sum + record.amount, 0)
      const efficiency = totalWaiterSalary > 0 ? (totalRevenue / totalWaiterSalary) * 10 : 0

      return {
        dailyTrends,
        monthlyAverages,
        seasonalPatterns,
        performanceMetrics: {
          growth: Math.round(growth * 100) / 100,
          consistency: Math.round(consistency * 100) / 100,
          efficiency: Math.round(efficiency * 100) / 100
        }
      }
    } catch (error) {
      console.error('Erro ao obter dados de análise financeira:', error)
      throw error
    }
  }
}

export const financialService = new FinancialService()