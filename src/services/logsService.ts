// import axios from 'axios' // Unused import

export interface LogEntry {
  id: number
  type: 'inventory' | 'sales' | 'users' | 'system' | 'reports' | 'suppliers'
  action: string
  details: any
  user_id?: string
  user_name?: string
  level: 'info' | 'warning' | 'error' | 'success'
  created_at: string
  updated_at?: string
}

export interface LogFilter {
  type?: string
  level?: string
  startDate?: string
  endDate?: string
  userId?: string
  page?: number
  limit?: number
}

export interface LogStats {
  totalLogs: number
  todayLogs: number
  errorLogs: number
  warningLogs: number
  successLogs: number
  infoLogs: number
  logsByType: Record<string, number>
  logsByLevel: Record<string, number>
}

class LogsService {
  // private _baseURL = '/api/logs' // Replace with your actual API base URL - unused
  private logs: LogEntry[] = []

  // Generate sample logs for demonstration
  private generateSampleLogs(): LogEntry[] {
    const now = new Date()
    const sampleLogs: LogEntry[] = []

    // Generate logs for the last 30 days
    for (let i = 0; i < 100; i++) {
      const randomDate = new Date(now.getTime() - Math.random() * 30 * 24 * 60 * 60 * 1000)
      const types = ['inventory', 'sales', 'users', 'system', 'reports', 'suppliers'] as const
      const levels = ['info', 'warning', 'error', 'success'] as const
      const actions = {
        inventory: ['Produto Adicionado', 'Produto Removido', 'Estoque Atualizado', 'Produto Editado', 'Alerta de Estoque Baixo'],
        sales: ['Venda Realizada', 'Venda Cancelada', 'Desconto Aplicado', 'Pagamento Recebido'],
        users: ['Login Realizado', 'Login Falhado', 'Usuário Criado', 'Senha Alterada', 'Logout'],
        system: ['Backup Realizado', 'Sistema Iniciado', 'Erro de Conexão', 'Atualização Instalada'],
        reports: ['Relatório Gerado', 'Relatório Exportado', 'Análise IA Executada'],
        suppliers: ['Fornecedor Adicionado', 'Pedido Criado', 'Fornecedor Atualizado']
      }

      const type = types[Math.floor(Math.random() * types.length)]
      const level = levels[Math.floor(Math.random() * levels.length)]
      const action = actions[type][Math.floor(Math.random() * actions[type].length)]

      let details = {}
      switch (type) {
        case 'inventory':
          details = {
            product: `Produto ${Math.floor(Math.random() * 100)}`,
            quantity: Math.floor(Math.random() * 50),
            value: Math.floor(Math.random() * 10000) / 100
          }
          break
        case 'sales':
          details = {
            orderId: `ORD-${Math.floor(Math.random() * 10000)}`,
            total: Math.floor(Math.random() * 100000) / 100,
            customer: `Cliente ${Math.floor(Math.random() * 100)}`
          }
          break
        case 'users':
          details = {
            email: `user${Math.floor(Math.random() * 100)}@test.com`,
            ip: `192.168.1.${Math.floor(Math.random() * 255)}`
          }
          break
        case 'system':
          details = {
            module: ['database', 'api', 'frontend', 'backup'][Math.floor(Math.random() * 4)],
            status: ['success', 'failed', 'in_progress'][Math.floor(Math.random() * 3)]
          }
          break
        case 'reports':
          details = {
            reportType: ['sales', 'inventory', 'financial'][Math.floor(Math.random() * 3)],
            format: ['pdf', 'excel', 'json'][Math.floor(Math.random() * 3)]
          }
          break
        case 'suppliers':
          details = {
            supplier: `Fornecedor ${Math.floor(Math.random() * 50)}`,
            amount: Math.floor(Math.random() * 50000) / 100
          }
          break
      }

      sampleLogs.push({
        id: i + 1,
        type,
        action,
        details,
        user_name: ['João Silva', 'Maria Santos', 'Pedro Costa', 'Ana Oliveira', 'Sistema'][Math.floor(Math.random() * 5)],
        level,
        created_at: randomDate.toISOString()
      })
    }

    return sampleLogs.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
  }

  async getLogs(filters: LogFilter = {}): Promise<{ logs: LogEntry[]; total: number }> {
    try {
      // TODO: Replace with actual API call
      // const response = await axios.get(this.baseURL, { params: filters })
      // return response.data

      // For now, use sample data
      if (this.logs.length === 0) {
        this.logs = this.generateSampleLogs()
      }

      let filteredLogs = [...this.logs]

      // Apply filters
      if (filters.type && filters.type !== 'all') {
        filteredLogs = filteredLogs.filter(log => log.type === filters.type)
      }

      if (filters.level && filters.level !== 'all') {
        filteredLogs = filteredLogs.filter(log => log.level === filters.level)
      }

      if (filters.startDate) {
        const startDate = new Date(filters.startDate)
        filteredLogs = filteredLogs.filter(log => new Date(log.created_at) >= startDate)
      }

      if (filters.endDate) {
        const endDate = new Date(filters.endDate)
        endDate.setHours(23, 59, 59, 999)
        filteredLogs = filteredLogs.filter(log => new Date(log.created_at) <= endDate)
      }

      if (filters.userId) {
        filteredLogs = filteredLogs.filter(log => log.user_id === filters.userId)
      }

      // Pagination
      const page = filters.page || 1
      const limit = filters.limit || 50
      const startIndex = (page - 1) * limit
      const endIndex = startIndex + limit

      return {
        logs: filteredLogs.slice(startIndex, endIndex),
        total: filteredLogs.length
      }
    } catch (error) {
      console.error('Erro ao carregar logs:', error)
      throw new Error('Falha ao carregar logs')
    }
  }

  async getLogStats(): Promise<LogStats> {
    try {
      // TODO: Replace with actual API call
      // const response = await axios.get(`${this.baseURL}/stats`)
      // return response.data

      // For now, calculate from sample data
      if (this.logs.length === 0) {
        this.logs = this.generateSampleLogs()
      }

      const today = new Date().toDateString()
      const todayLogs = this.logs.filter(log => new Date(log.created_at).toDateString() === today).length

      const logsByType = this.logs.reduce((acc, log) => {
        acc[log.type] = (acc[log.type] || 0) + 1
        return acc
      }, {} as Record<string, number>)

      const logsByLevel = this.logs.reduce((acc, log) => {
        acc[log.level] = (acc[log.level] || 0) + 1
        return acc
      }, {} as Record<string, number>)

      return {
        totalLogs: this.logs.length,
        todayLogs,
        errorLogs: logsByLevel.error || 0,
        warningLogs: logsByLevel.warning || 0,
        successLogs: logsByLevel.success || 0,
        infoLogs: logsByLevel.info || 0,
        logsByType,
        logsByLevel
      }
    } catch (error) {
      console.error('Erro ao carregar estatísticas dos logs:', error)
      throw new Error('Falha ao carregar estatísticas')
    }
  }

  async createLog(logData: Omit<LogEntry, 'id' | 'created_at'>): Promise<LogEntry> {
    try {
      // TODO: Replace with actual API call
      // const response = await axios.post(this.baseURL, logData)
      // return response.data

      // For now, add to sample data
      const newLog: LogEntry = {
        ...logData,
        id: this.logs.length + 1,
        created_at: new Date().toISOString()
      }

      this.logs.unshift(newLog)
      return newLog
    } catch (error) {
      console.error('Erro ao criar log:', error)
      throw new Error('Falha ao criar log')
    }
  }

  async exportLogs(filters: LogFilter = {}, format: 'csv' | 'json' | 'excel' = 'csv'): Promise<Blob> {
    try {
      const { logs } = await this.getLogs(filters)

      switch (format) {
        case 'csv': {
          const csvContent = [
            ['Data/Hora', 'Tipo', 'Ação', 'Usuário', 'Detalhes', 'Nível'],
            ...logs.map(log => [
              new Date(log.created_at).toLocaleString('pt-BR'),
              log.type,
              log.action,
              log.user_name || 'Sistema',
              typeof log.details === 'object' ? JSON.stringify(log.details) : log.details,
              log.level
            ])
          ].map(row => row.join(',')).join('\n')

          return new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
        }

        case 'json': {
          const jsonContent = JSON.stringify({
            exportDate: new Date().toISOString(),
            totalRecords: logs.length,
            filters,
            logs
          }, null, 2)

          return new Blob([jsonContent], { type: 'application/json;charset=utf-8;' })
        }

        case 'excel': {
          // For Excel format, we'll return CSV for now
          // In a real implementation, you'd use a library like xlsx
          const csvContent = [
            ['Data/Hora', 'Tipo', 'Ação', 'Usuário', 'Detalhes', 'Nível'],
            ...logs.map(log => [
              new Date(log.created_at).toLocaleString('pt-BR'),
              log.type,
              log.action,
              log.user_name || 'Sistema',
              typeof log.details === 'object' ? JSON.stringify(log.details) : log.details,
              log.level
            ])
          ].map(row => row.join(',')).join('\n')

          return new Blob([csvContent], { type: 'application/vnd.ms-excel;charset=utf-8;' })
        }

        default:
          throw new Error('Formato de exportação não suportado')
      }
    } catch (error) {
      console.error('Erro ao exportar logs:', error)
      throw new Error('Falha ao exportar logs')
    }
  }

  // Helper method to log actions from other parts of the application
  async logAction(
    type: LogEntry['type'],
    action: string,
    details: any,
    level: LogEntry['level'] = 'info',
    userName?: string
  ): Promise<void> {
    try {
      await this.createLog({
        type,
        action,
        details,
        level,
        user_name: userName || 'Sistema'
      })
    } catch (error) {
      console.error('Erro ao registrar ação:', error)
      // Don't throw here to avoid disrupting the main application flow
    }
  }

  // Convenience methods for common log types
  async logInventoryAction(action: string, productData: any, userName?: string) {
    return this.logAction('inventory', action, productData, 'info', userName)
  }

  async logSalesAction(action: string, salesData: any, userName?: string) {
    return this.logAction('sales', action, salesData, 'success', userName)
  }

  async logUserAction(action: string, userData: any, userName?: string) {
    return this.logAction('users', action, userData, 'info', userName)
  }

  async logSystemAction(action: string, systemData: any, level: LogEntry['level'] = 'info') {
    return this.logAction('system', action, systemData, level, 'Sistema')
  }

  async logError(action: string, errorData: any, userName?: string) {
    return this.logAction('system', action, errorData, 'error', userName)
  }
}

export const logsService = new LogsService()
export default logsService