import { supabase } from '@/config/supabase'

export interface SalesData {
  date: string
  total_sales: number
  orders_count: number
  average_order: number
}

export interface MovementData {
  id: string
  product_id: string
  type: string
  quantity: number
  total_cost: number
  created_at: string
  produto: {
    nome: string
    preco: number
  }
}

export interface MenuSalesData {
  id: string
  menu_item_id: string
  data_planejada: string
  quantidade_estimada: number
  receita_estimada: number
  status: string
  menu_item: {
    nome: string
    preco_venda: number
  }
}

class SalesService {

  /**
   * Busca dados de vendas dos últimos dias baseado em movimentações de produtos
   */
  async getSalesDataFromMovements(days: number = 7): Promise<SalesData[]> {
    try {
      const startDate = new Date()
      startDate.setDate(startDate.getDate() - days)

      const { data: movements, error } = await supabase
        .from('movements')
        .select(`
          id,
          type,
          quantity,
          total_cost,
          created_at,
          produtos!inner (
            nome,
            preco
          )
        `)
        .gte('created_at', startDate.toISOString())
        .eq('type', 'sale') // Filtrar apenas vendas
        .order('created_at', { ascending: true })

      if (error) {
        console.error('Erro ao buscar dados de movimentações:', error)
        // Retornar dados simulados se houver erro
        return this.generateMockSalesData(days)
      }

      // Agrupar dados por data
      const salesByDate = this.groupSalesByDate(movements as MovementData[])

      return salesByDate
    } catch (error) {
      console.error('Erro no serviço de vendas:', error)
      return this.generateMockSalesData(days)
    }
  }

  /**
   * Busca dados de vendas do menu diário
   */
  async getSalesDataFromMenu(days: number = 7): Promise<SalesData[]> {
    try {
      const startDate = new Date()
      startDate.setDate(startDate.getDate() - days)

      const { data: menuSales, error } = await supabase
        .from('menu_diario')
        .select(`
          id,
          data_planejada,
          quantidade_estimada,
          receita_estimada,
          status,
          menu_items!inner (
            nome,
            preco_venda
          )
        `)
        .gte('data_planejada', startDate.toISOString().split('T')[0])
        .in('status', ['pronto', 'preparando']) // Apenas itens vendidos/preparados
        .order('data_planejada', { ascending: true })

      if (error) {
        console.error('Erro ao buscar dados do menu:', error)
        return this.generateMockSalesData(days)
      }

      const salesByDate = this.groupMenuSalesByDate(menuSales as MenuSalesData[])

      return salesByDate
    } catch (error) {
      console.error('Erro no serviço de menu:', error)
      return this.generateMockSalesData(days)
    }
  }

  /**
   * Combina dados de vendas de múltiplas fontes
   */
  async getCombinedSalesData(days: number = 7): Promise<SalesData[]> {
    try {
      // Buscar dados de ambas as fontes
      const [movementSales, menuSales] = await Promise.all([
        this.getSalesDataFromMovements(days),
        this.getSalesDataFromMenu(days)
      ])

      // Combinar os dados por data
      const combinedData = this.combineSalesData(movementSales, menuSales, days)

      return combinedData
    } catch (error) {
      console.error('Erro ao combinar dados de vendas:', error)
      return this.generateMockSalesData(days)
    }
  }

  /**
   * Busca vendas por período específico
   */
  async getSalesByPeriod(period: '7d' | '30d' | '90d'): Promise<SalesData[]> {
    const days = {
      '7d': 7,
      '30d': 30,
      '90d': 90
    }[period]

    return await this.getCombinedSalesData(days)
  }

  /**
   * Busca estatísticas resumidas de vendas
   */
  async getSalesSummary() {
    try {
      const salesData = await this.getCombinedSalesData(7)

      const totalSales = salesData.reduce((acc, day) => acc + day.total_sales, 0)
      const totalOrders = salesData.reduce((acc, day) => acc + day.orders_count, 0)
      const averageOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0
      const dailyAverage = salesData.length > 0 ? totalSales / salesData.length : 0

      return {
        totalSales,
        totalOrders,
        averageOrderValue,
        dailyAverage,
        growth: this.calculateGrowth(salesData)
      }
    } catch (error) {
      console.error('Erro ao calcular resumo de vendas:', error)
      return {
        totalSales: 0,
        totalOrders: 0,
        averageOrderValue: 0,
        dailyAverage: 0,
        growth: 0
      }
    }
  }

  /**
   * Agrupa movimentações por data
   */
  private groupSalesByDate(movements: MovementData[]): SalesData[] {
    const salesByDate: { [key: string]: SalesData } = {}

    movements.forEach(movement => {
      const date = movement.created_at.split('T')[0]

      if (!salesByDate[date]) {
        salesByDate[date] = {
          date,
          total_sales: 0,
          orders_count: 0,
          average_order: 0
        }
      }

      salesByDate[date].total_sales += movement.total_cost || (movement.quantity * movement.produto.preco)
      salesByDate[date].orders_count += 1
    })

    // Calcular média por pedido
    Object.values(salesByDate).forEach(dayData => {
      dayData.average_order = dayData.orders_count > 0 ? dayData.total_sales / dayData.orders_count : 0
    })

    return Object.values(salesByDate).sort((a, b) => a.date.localeCompare(b.date))
  }

  /**
   * Agrupa vendas do menu por data
   */
  private groupMenuSalesByDate(menuSales: MenuSalesData[]): SalesData[] {
    const salesByDate: { [key: string]: SalesData } = {}

    menuSales.forEach(sale => {
      const date = sale.data_planejada

      if (!salesByDate[date]) {
        salesByDate[date] = {
          date,
          total_sales: 0,
          orders_count: 0,
          average_order: 0
        }
      }

      salesByDate[date].total_sales += sale.receita_estimada || (sale.quantidade_estimada * sale.menu_item.preco_venda)
      salesByDate[date].orders_count += sale.quantidade_estimada
    })

    // Calcular média por pedido
    Object.values(salesByDate).forEach(dayData => {
      dayData.average_order = dayData.orders_count > 0 ? dayData.total_sales / dayData.orders_count : 0
    })

    return Object.values(salesByDate).sort((a, b) => a.date.localeCompare(b.date))
  }

  /**
   * Combina dados de vendas de múltiplas fontes
   */
  private combineSalesData(movementSales: SalesData[], menuSales: SalesData[], days: number): SalesData[] {
    const combinedData: { [key: string]: SalesData } = {}

    // Criar entradas para todos os dias do período
    for (let i = days - 1; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      const dateStr = date.toISOString().split('T')[0]

      combinedData[dateStr] = {
        date: dateStr,
        total_sales: 0,
        orders_count: 0,
        average_order: 0
      }
    }

    // Adicionar dados de movimentações
    movementSales.forEach(dayData => {
      if (combinedData[dayData.date]) {
        combinedData[dayData.date].total_sales += dayData.total_sales
        combinedData[dayData.date].orders_count += dayData.orders_count
      }
    })

    // Adicionar dados do menu
    menuSales.forEach(dayData => {
      if (combinedData[dayData.date]) {
        combinedData[dayData.date].total_sales += dayData.total_sales
        combinedData[dayData.date].orders_count += dayData.orders_count
      }
    })

    // Calcular média por pedido
    Object.values(combinedData).forEach(dayData => {
      dayData.average_order = dayData.orders_count > 0 ? dayData.total_sales / dayData.orders_count : 0
    })

    return Object.values(combinedData).sort((a, b) => a.date.localeCompare(b.date))
  }

  /**
   * Calcula crescimento das vendas
   */
  private calculateGrowth(salesData: SalesData[]): number {
    if (salesData.length < 2) return 0

    const firstHalf = salesData.slice(0, Math.floor(salesData.length / 2))
    const secondHalf = salesData.slice(Math.floor(salesData.length / 2))

    const firstHalfTotal = firstHalf.reduce((acc, day) => acc + day.total_sales, 0)
    const secondHalfTotal = secondHalf.reduce((acc, day) => acc + day.total_sales, 0)

    if (firstHalfTotal === 0) return secondHalfTotal > 0 ? 100 : 0

    return ((secondHalfTotal - firstHalfTotal) / firstHalfTotal) * 100
  }

  /**
   * Gera dados simulados quando não há dados reais disponíveis
   */
  private generateMockSalesData(days: number): SalesData[] {
    const mockData: SalesData[] = []

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      const dateStr = date.toISOString().split('T')[0]

      const baseSales = 500 + Math.random() * 1000
      const ordersCount = 10 + Math.floor(Math.random() * 30)

      mockData.push({
        date: dateStr,
        total_sales: Math.round(baseSales * 100) / 100,
        orders_count: ordersCount,
        average_order: Math.round((baseSales / ordersCount) * 100) / 100
      })
    }

    return mockData
  }
}

export const salesService = new SalesService()