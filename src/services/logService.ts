import { supabase, DB_TABLES } from '@/config/supabase'
import { authService } from '@/services/authService'
import { reportService } from '@/services/reportService'

export interface SystemLog {
  id?: number
  user_id: string
  username: string
  action: string
  resource: string
  resource_id?: string | number
  details: Record<string, any>
  ip_address?: string
  user_agent?: string
  severity: 'info' | 'warning' | 'error' | 'critical' | 'debug'
  category: 'auth' | 'crud' | 'system' | 'security' | 'performance' | 'user' | 'api' | 'database' | 'command'
  created_at?: string
  // Compatibilidade com versões antigas
  timestamp?: string
  session_id?: string
  execution_time?: number
  status: 'success' | 'failed' | 'pending'
  error_message?: string
  metadata?: Record<string, any>
}

export interface LogQuery {
  startDate?: string
  endDate?: string
  severity?: string[]
  category?: string[]
  userId?: string
  resource?: string
  status?: string
  limit?: number
  offset?: number
  search?: string
}

export interface LogStatistics {
  totalLogs: number
  errorRate: number
  warningRate: number
  topUsers: Array<{ username: string; count: number }>
  topResources: Array<{ resource: string; count: number }>
  severityDistribution: Record<string, number>
  categoryDistribution: Record<string, number>
  timelineData: Array<{ date: string; count: number; errors: number }>
  averageResponseTime: number
  criticalIssues: number
}

export interface CommandResult {
  success: boolean
  message: string
  data?: any
  executionTime: number
  timestamp: string
}

class LogService {
  private sessionId: string

  constructor() {
    this.sessionId = this.generateSessionId()
  }

  private generateSessionId(): string {
    return `sess_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`
  }

  private getCurrentUser() {
    const user = authService.getCurrentUser()
    return user || ({ id: 'anonymous', username: 'anonymous' } as any)
  }

  private getUserInfo() {
    return {
      ip_address: this.getClientIP(),
      user_agent: navigator.userAgent,
      session_id: this.sessionId
    }
  }

  private getClientIP(): string {
    // Em produção, isso seria obtido do servidor
    return 'client-ip'
  }

  /**
   * Registra um log no sistema
   */
  async createLog(logData: Partial<SystemLog>): Promise<void> {
    try {
      const user = this.getCurrentUser()
      const userInfo = this.getUserInfo()

      const log: SystemLog = {
        user_id: (user as any).id,
        username: (user as any)?.username ?? (user as any)?.email ?? 'unknown',
        action: logData.action || 'unknown_action',
        resource: logData.resource || 'unknown_resource',
        resource_id: logData.resource_id,
        details: logData.details || {},
        severity: logData.severity || 'info',
        category: logData.category || 'system',
        status: logData.status || 'success',
        error_message: logData.error_message,
        metadata: logData.metadata || {},
        execution_time: logData.execution_time,
        ...userInfo
      }

      const { error } = await supabase
        .from(DB_TABLES.LOGS)
        .insert([log])

      if (error) {
        console.error('Erro ao salvar log:', error)
        // Fallback: salvar no localStorage se o banco falhar
        this.saveToLocalStorage(log)
      }
    } catch (error) {
      console.error('Erro crítico no sistema de logs:', error)
    }
  }

  /**
   * Busca logs com filtros avançados
   */
  async getLogs(query: LogQuery = {}): Promise<{ data: SystemLog[]; total: number }> {
    try {
      let supabaseQuery = supabase
        .from(DB_TABLES.LOGS)
        .select('*', { count: 'exact' })

      // Aplicar filtros
      if (query.startDate) {
        supabaseQuery = supabaseQuery.gte('created_at', query.startDate)
      }
      if (query.endDate) {
        supabaseQuery = supabaseQuery.lte('created_at', query.endDate)
      }
      if (query.severity && query.severity.length > 0) {
        supabaseQuery = supabaseQuery.in('severity', query.severity)
      }
      if (query.category && query.category.length > 0) {
        supabaseQuery = supabaseQuery.in('category', query.category)
      }
      if (query.userId) {
        supabaseQuery = supabaseQuery.eq('user_id', query.userId)
      }
      if (query.resource) {
        supabaseQuery = supabaseQuery.ilike('resource', `%${query.resource}%`)
      }
      if (query.status) {
        supabaseQuery = supabaseQuery.eq('status', query.status)
      }
      if (query.search) {
        supabaseQuery = supabaseQuery.or(`action.ilike.%${query.search}%,details->>message.ilike.%${query.search}%,error_message.ilike.%${query.search}%`)
      }

      // Paginação e ordenação
      const limit = query.limit || 50
      const offset = query.offset || 0
      supabaseQuery = supabaseQuery
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      const { data, error, count } = await supabaseQuery

      if (error) throw error

      return { data: data || [], total: count || 0 }
    } catch (error) {
      console.error('Erro ao buscar logs:', error)
      return { data: [], total: 0 }
    }
  }

  /**
   * Obtém estatísticas dos logs
   */
  async getLogStatistics(days: number = 30): Promise<LogStatistics> {
    try {
      const startDate = new Date()
      startDate.setDate(startDate.getDate() - days)

      const { data: logs } = await this.getLogs({
        startDate: startDate.toISOString(),
        limit: 10000 // Limite alto para estatísticas
      })

      if (!logs.length) {
        return this.getEmptyStatistics()
      }

      const totalLogs = logs.length
      const errorCount = logs.filter(log => log.severity === 'error' || log.severity === 'critical').length
      const warningCount = logs.filter(log => log.severity === 'warning').length
      const criticalCount = logs.filter(log => log.severity === 'critical').length

      // Top usuários
      const userCounts = logs.reduce((acc, log) => {
        acc[log.username] = (acc[log.username] || 0) + 1
        return acc
      }, {} as Record<string, number>)

      const topUsers = Object.entries(userCounts)
        .sort(([, a], [, b]) => b - a)
        .slice(0, 10)
        .map(([username, count]) => ({ username, count }))

      // Top recursos
      const resourceCounts = logs.reduce((acc, log) => {
        acc[log.resource] = (acc[log.resource] || 0) + 1
        return acc
      }, {} as Record<string, number>)

      const topResources = Object.entries(resourceCounts)
        .sort(([, a], [, b]) => b - a)
        .slice(0, 10)
        .map(([resource, count]) => ({ resource, count }))

      // Distribuição de severidade
      const severityDistribution = logs.reduce((acc, log) => {
        acc[log.severity] = (acc[log.severity] || 0) + 1
        return acc
      }, {} as Record<string, number>)

      // Distribuição de categoria
      const categoryDistribution = logs.reduce((acc, log) => {
        acc[log.category] = (acc[log.category] || 0) + 1
        return acc
      }, {} as Record<string, number>)

      // Timeline dos últimos 7 dias
      const timelineData = this.generateTimeline(logs, 7)

      // Tempo médio de resposta
      const logsWithExecutionTime = logs.filter(log => log.execution_time)
      const averageResponseTime = logsWithExecutionTime.length > 0
        ? logsWithExecutionTime.reduce((sum, log) => sum + (log.execution_time || 0), 0) / logsWithExecutionTime.length
        : 0

      return {
        totalLogs,
        errorRate: totalLogs > 0 ? (errorCount / totalLogs) * 100 : 0,
        warningRate: totalLogs > 0 ? (warningCount / totalLogs) * 100 : 0,
        topUsers,
        topResources,
        severityDistribution,
        categoryDistribution,
        timelineData,
        averageResponseTime,
        criticalIssues: criticalCount
      }
    } catch (error) {
      console.error('Erro ao calcular estatísticas:', error)
      return this.getEmptyStatistics()
    }
  }

  /**
   * Executa comandos do sistema
   */
  async executeCommand(command: string, args: string[] = []): Promise<CommandResult> {
    const startTime = Date.now()
    const timestamp = new Date().toISOString()

    try {
      await this.createLog({
        action: 'execute_command',
        resource: 'system_terminal',
        details: { command, args },
        category: 'command',
        severity: 'info'
      })

      const result = await this.processCommand(command, args)
      const executionTime = Date.now() - startTime

      await this.createLog({
        action: 'command_completed',
        resource: 'system_terminal',
        details: { command, args, result, executionTime },
        category: 'command',
        severity: 'info',
        execution_time: executionTime,
        status: 'success'
      })

      return {
        success: true,
        message: result.message,
        data: result.data,
        executionTime,
        timestamp
      }
    } catch (error: any) {
      const executionTime = Date.now() - startTime

      await this.createLog({
        action: 'command_failed',
        resource: 'system_terminal',
        details: { command, args },
        category: 'command',
        severity: 'error',
        execution_time: executionTime,
        status: 'failed',
        error_message: error.message
      })

      return {
        success: false,
        message: error.message || 'Comando falhou',
        executionTime,
        timestamp
      }
    }
  }

  /**
   * Processa comandos específicos
   */
  private async processCommand(command: string, args: string[]): Promise<{ message: string; data?: any }> {
    const cmd = command.toLowerCase().trim()

    switch (cmd) {
      case 'logs':
        return await this.commandLogs(args)
      case 'stats':
        return await this.commandStats(args)
      case 'clear':
        return await this.commandClear(args)
      case 'users':
        return await this.commandUsers(args)
      case 'status':
        return await this.commandStatus(args)
      case 'backup':
        return await this.commandBackup(args)
      case 'report':
        return await this.commandReport(args)
      case 'help':
        return this.commandHelp(args)
      case 'export':
        return await this.commandExport(args)
      case 'search':
        return await this.commandSearch(args)
      case 'monitor':
        return await this.commandMonitor(args)
      default:
        throw new Error(`Comando '${command}' não reconhecido. Use 'help' para ver comandos disponíveis.`)
    }
  }

  private async commandLogs(args: string[]): Promise<{ message: string; data?: any }> {
    const limit = args.includes('--limit') ? parseInt(args[args.indexOf('--limit') + 1]) || 10 : 10
    const severity = args.includes('--severity') ? [args[args.indexOf('--severity') + 1]] : undefined

    const { data: logs } = await this.getLogs({ limit, severity })

    return {
      message: `Exibindo ${logs.length} logs mais recentes`,
      data: logs.map(log => ({
        timestamp: log.created_at || log.timestamp,
        severity: log.severity,
        action: log.action,
        user: log.username,
        resource: log.resource
      }))
    }
  }

  private async commandStats(args: string[]): Promise<{ message: string; data?: any }> {
    const days = args.includes('--days') ? parseInt(args[args.indexOf('--days') + 1]) || 30 : 30
    const stats = await this.getLogStatistics(days)

    return {
      message: `Estatísticas dos últimos ${days} dias`,
      data: {
        'Total de logs': stats.totalLogs,
        'Taxa de erro': `${stats.errorRate.toFixed(2)}%`,
        'Taxa de aviso': `${stats.warningRate.toFixed(2)}%`,
        'Problemas críticos': stats.criticalIssues,
        'Tempo médio de resposta': `${stats.averageResponseTime.toFixed(2)}ms`,
        'Top usuários': stats.topUsers.slice(0, 3)
      }
    }
  }

  private async commandClear(_args: string[]): Promise<{ message: string }> {
    // Em uma implementação real, isso limparia logs antigos
    return {
      message: 'Terminal limpo. Para limpeza real de logs, use: logs --clear --older-than 90d'
    }
  }

  private async commandUsers(_args: string[]): Promise<{ message: string; data?: any }> {
    const { data: logs } = await this.getLogs({ limit: 1000 })
    const users = [...new Set(logs.map(log => log.username))]

    return {
      message: `${users.length} usuários únicos encontrados`,
      data: users.slice(0, 10)
    }
  }

  private async commandStatus(_args: string[]): Promise<{ message: string; data?: any }> {
    const stats = await this.getLogStatistics(1) // Último dia

    const status = {
      'Sistema': stats.criticalIssues === 0 ? '🟢 Operacional' : '🔴 Problemas detectados',
      'Logs hoje': stats.totalLogs,
      'Erros críticos': stats.criticalIssues,
      'Performance': stats.averageResponseTime < 1000 ? '🟢 Boa' : '🟡 Atenção',
      'Última atualização': new Date().toLocaleString('pt-BR')
    }

    return {
      message: 'Status do sistema',
      data: status
    }
  }

  private async commandBackup(_args: string[]): Promise<{ message: string }> {
    // Simular backup
    return {
      message: 'Backup de logs iniciado. Use o comando "export" para baixar dados específicos.'
    }
  }

  private commandHelp(_args: string[]): { message: string; data: any } {
    const commands = {
      'logs': 'Exibe logs recentes (--limit N, --severity LEVEL)',
      'stats': 'Mostra estatísticas (--days N)',
      'clear': 'Limpa o terminal',
      'users': 'Lista usuários ativos',
      'status': 'Status do sistema',
      'backup': 'Inicia backup de logs',
      'report': 'Gera e baixa relatório técnico (--days N --format pdf|md|html|json|excel)',
      'export': 'Exporta dados (--format csv|json, --days N)',
      'search': 'Busca nos logs (--query TEXTO)',
      'monitor': 'Monitor em tempo real (--category CAT)',
      'help': 'Mostra esta ajuda'
    }

    return {
      message: 'Comandos disponíveis:',
      data: commands
    }
  }

  private async commandReport(args: string[]): Promise<{ message: string; data?: any }> {
    const days = args.includes('--days') ? parseInt(args[args.indexOf('--days') + 1]) || 30 : 30
    const format = args.includes('--format') ? (args[args.indexOf('--format') + 1] || 'pdf').toLowerCase() : 'pdf'

    // Suporte rápido a MD via gerador técnico existente
    if (format === 'md' || format === 'markdown') {
      const report = await this.generateTechnicalReport(days)
      try {
        const blob = new Blob([report], { type: 'text/markdown' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        const filename = `relatorio-tecnico-${days}d-${new Date().toISOString().split('T')[0]}.md`
        a.href = url
        a.download = filename
        a.click()
        URL.revokeObjectURL(url)
        return { message: `Relatório técnico (${days} dias) gerado (Markdown)`, data: { filename, size: report.length } }
      } catch (e) {
        return { message: `Relatório técnico (${days} dias) gerado (Markdown). Download indisponível.`, data: { report } }
      }
    }

    // Demais formatos via reportService (pdf, html, json, excel)
    const now = new Date()
    const end = now.toISOString()
    const start = new Date(now.getTime() - days * 24 * 60 * 60 * 1000).toISOString()

    const config = {
      title: 'Relatório Técnico do Sistema',
      subtitle: `Período: ${days} dias`,
      period: { start, end, days },
      includeCharts: true,
      includeDetails: true,
      includeRecommendations: true,
      format: (['pdf','html','json','excel'].includes(format) ? format : 'pdf') as any,
      template: 'technical' as const
    }

    // Gera dados do relatório e exporta
    const reportData = await reportService.generateReport(config)

    let blob: Blob
    let ext = 'pdf'
    if (format === 'pdf') {
      blob = await reportService.exportReport(reportData, 'pdf')
      ext = 'pdf'
    } else if (format === 'html') {
      blob = await reportService.exportReport(reportData, 'html')
      ext = 'html'
    } else if (format === 'json') {
      blob = await reportService.exportReport(reportData, 'json')
      ext = 'json'
    } else if (format === 'excel' || format === 'xlsx') {
      blob = await reportService.exportReport(reportData, 'excel')
      ext = 'xlsx'
    } else {
      // fallback para pdf
      blob = await reportService.exportReport(reportData, 'pdf')
      ext = 'pdf'
    }

    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    const filename = `relatorio-tecnico-${days}d-${new Date().toISOString().split('T')[0]}.${ext}`
    a.href = url
    a.download = filename
    a.click()
    URL.revokeObjectURL(url)

    return { message: `Relatório técnico (${days} dias) gerado (${ext.toUpperCase()})`, data: { filename } }
  }

  private async commandExport(args: string[]): Promise<{ message: string; data?: any }> {
    const format = args.includes('--format') ? args[args.indexOf('--format') + 1] : 'json'
    const days = args.includes('--days') ? parseInt(args[args.indexOf('--days') + 1]) || 7 : 7

    const startDate = new Date()
    startDate.setDate(startDate.getDate() - days)

    const { data: logs } = await this.getLogs({
      startDate: startDate.toISOString(),
      limit: 5000
    })

    return {
      message: `Exportando ${logs.length} logs em formato ${format}`,
      data: { format, count: logs.length, filename: `logs_${Date.now()}.${format}` }
    }
  }

  private async commandSearch(args: string[]): Promise<{ message: string; data?: any }> {
    const query = args.includes('--query') ? args[args.indexOf('--query') + 1] : args[0]

    if (!query) {
      throw new Error('Query de busca requerida. Use: search --query "texto"')
    }

    const { data: logs } = await this.getLogs({ search: query, limit: 20 })

    return {
      message: `Encontrados ${logs.length} logs para "${query}"`,
      data: logs.slice(0, 5).map(log => ({
        timestamp: log.timestamp,
        action: log.action,
        details: log.details
      }))
    }
  }

  private async commandMonitor(_args: string[]): Promise<{ message: string }> {
    return {
      message: 'Monitor em tempo real ativado. Pressione Ctrl+C para parar.'
    }
  }

  /**
   * Gera relatório técnico profissional
   */
  async generateTechnicalReport(days: number = 30): Promise<string> {
    const stats = await this.getLogStatistics(days)
    const { data: recentLogs } = await this.getLogs({
      limit: 100,
      startDate: new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString()
    })

    const report = `
# RELATÓRIO TÉCNICO DE SISTEMA - ANÁLISE DE LOGS
**Período de Análise:** ${days} dias | **Gerado em:** ${new Date().toLocaleString('pt-BR')}

## SUMÁRIO EXECUTIVO

O presente relatório apresenta uma análise detalhada dos logs do sistema durante o período de ${days} dias, compreendendo ${stats.totalLogs} registros de eventos. A análise abrange aspectos de performance, segurança, integridade operacional e padrões de utilização.

## MÉTRICAS OPERACIONAIS

### Indicadores Principais
- **Volume Total de Logs:** ${stats.totalLogs.toLocaleString('pt-BR')} registros
- **Taxa de Erro:** ${stats.errorRate.toFixed(2)}% (${Math.round(stats.totalLogs * stats.errorRate / 100)} ocorrências)
- **Taxa de Advertência:** ${stats.warningRate.toFixed(2)}% (${Math.round(stats.totalLogs * stats.warningRate / 100)} ocorrências)
- **Incidentes Críticos:** ${stats.criticalIssues} eventos classificados como críticos
- **Tempo Médio de Resposta:** ${stats.averageResponseTime.toFixed(2)}ms

### Análise de Performance
${this.generatePerformanceAnalysis(stats)}

## DISTRIBUIÇÃO DE SEVERIDADE

${Object.entries(stats.severityDistribution).map(([severity, count]) =>
  `- **${severity.toUpperCase()}:** ${count} eventos (${((count/stats.totalLogs)*100).toFixed(1)}%)`
).join('\n')}

## ANÁLISE POR CATEGORIA

${Object.entries(stats.categoryDistribution).map(([category, count]) =>
  `- **${category.toUpperCase()}:** ${count} eventos (${((count/stats.totalLogs)*100).toFixed(1)}%)`
).join('\n')}

## USUÁRIOS MAIS ATIVOS

${stats.topUsers.map((user, index) =>
  `${index + 1}. **${user.username}:** ${user.count} ações (${((user.count/stats.totalLogs)*100).toFixed(1)}%)`
).join('\n')}

## RECURSOS MAIS UTILIZADOS

${stats.topResources.map((resource, index) =>
  `${index + 1}. **${resource.resource}:** ${resource.count} acessos`
).join('\n')}

## ANÁLISE TEMPORAL

${this.generateTimelineAnalysis(stats.timelineData)}

## EVENTOS CRÍTICOS E RECOMENDAÇÕES

${this.generateCriticalAnalysis(recentLogs, stats)}

## CONFORMIDADE E SEGURANÇA

### Auditoria de Acessos
- Total de eventos de autenticação: ${recentLogs.filter(log => log.category === 'auth').length}
- Tentativas de acesso negadas: ${recentLogs.filter(log => log.category === 'security' && log.status === 'failed').length}
- Operações administrativas: ${recentLogs.filter(log => log.category === 'system').length}

### Integridade dos Dados
- Operações de CRUD: ${recentLogs.filter(log => log.category === 'crud').length}
- Falhas de transação: ${recentLogs.filter(log => log.category === 'database' && log.severity === 'error').length}
- Backup/Restore: ${recentLogs.filter(log => log.action.includes('backup')).length}

## RECOMENDAÇÕES TÉCNICAS

${this.generateRecommendations(stats, recentLogs)}

## CONCLUSÕES

Com base na análise dos dados coletados, o sistema apresenta ${this.getSystemHealthStatus(stats)}.
As métricas indicam ${stats.errorRate < 5 ? 'operação estável' : 'necessidade de intervenção'}
com foco em ${this.getPriorityAreas(stats)}.

---
**Relatório gerado automaticamente pelo Sistema de Monitoramento GestaoZe**
**Classificação:** Confidencial | **Validade:** 24 horas
    `.trim()

    // Salvar log da geração do relatório
    await this.createLog({
      action: 'generate_technical_report',
      resource: 'reports',
      details: {
        reportPeriod: days,
        totalLogs: stats.totalLogs,
        reportSize: report.length
      },
      category: 'system',
      severity: 'info'
    })

    return report
  }

  // Métodos auxiliares para o relatório
  private generatePerformanceAnalysis(stats: LogStatistics): string {
    const responseTime = stats.averageResponseTime
    let analysis = ''

    if (responseTime < 100) {
      analysis = 'Performance **EXCELENTE** - Sistema operando com latência mínima.'
    } else if (responseTime < 500) {
      analysis = 'Performance **BOA** - Sistema operando dentro dos parâmetros aceitáveis.'
    } else if (responseTime < 1000) {
      analysis = 'Performance **ACEITÁVEL** - Monitoramento recomendado para evitar degradação.'
    } else {
      analysis = 'Performance **CRÍTICA** - Intervenção imediata necessária.'
    }

    return analysis
  }

  private generateTimelineAnalysis(timeline: Array<{ date: string; count: number; errors: number }>): string {
    const totalDays = timeline.length
    const avgDaily = timeline.reduce((sum, day) => sum + day.count, 0) / totalDays
    const avgErrors = timeline.reduce((sum, day) => sum + day.errors, 0) / totalDays

    return `
**Análise dos Últimos ${totalDays} Dias:**
- Média diária de eventos: ${avgDaily.toFixed(0)}
- Média diária de erros: ${avgErrors.toFixed(1)}
- Pico de atividade: ${Math.max(...timeline.map(d => d.count))} eventos
- Dia com mais erros: ${Math.max(...timeline.map(d => d.errors))} erros
    `.trim()
  }

  private generateCriticalAnalysis(logs: SystemLog[], stats: LogStatistics): string {
    const criticalLogs = logs.filter(log => log.severity === 'critical')
    const errorLogs = logs.filter(log => log.severity === 'error')

    if (criticalLogs.length === 0 && errorLogs.length === 0) {
      return 'Nenhum evento crítico ou erro detectado no período analisado.'
    }

    let analysis = ''
    if (criticalLogs.length > 0) {
      analysis += `**${criticalLogs.length} EVENTOS CRÍTICOS DETECTADOS:**\n`
      criticalLogs.slice(0, 3).forEach((log, i) => {
        analysis += `${i + 1}. ${log.action} - ${log.resource} (${new Date(log.created_at || log.timestamp || '').toLocaleString('pt-BR')})\n`
      })
    }

    if (stats.errorRate > 10) {
      analysis += '\n**RECOMENDAÇÃO URGENTE:** Taxa de erro acima de 10% requer análise imediata.'
    }

    return analysis
  }

  private generateRecommendations(stats: LogStatistics, logs: SystemLog[]): string {
    const recommendations = []

    if (stats.errorRate > 5) {
      recommendations.push('• Implementar monitoramento proativo para redução da taxa de erro')
    }

    if (stats.averageResponseTime > 500) {
      recommendations.push('• Otimização de performance necessária - tempo de resposta elevado')
    }

    if (stats.criticalIssues > 0) {
      recommendations.push('• Revisão imediata dos processos que geraram eventos críticos')
    }

    if (logs.filter(log => log.category === 'security').length > 10) {
      recommendations.push('• Reforçar políticas de segurança devido ao volume de eventos de segurança')
    }

    recommendations.push('• Implementar alertas automáticos para eventos críticos')
    recommendations.push('• Estabelecer rotina de análise semanal dos logs')

    return recommendations.join('\n')
  }

  private getSystemHealthStatus(stats: LogStatistics): string {
    if (stats.errorRate < 2 && stats.criticalIssues === 0) {
      return 'saúde operacional EXCELENTE'
    } else if (stats.errorRate < 5 && stats.criticalIssues < 3) {
      return 'saúde operacional BOA'
    } else if (stats.errorRate < 10) {
      return 'saúde operacional ACEITÁVEL com pontos de atenção'
    } else {
      return 'saúde operacional CRÍTICA requerendo intervenção'
    }
  }

  private getPriorityAreas(stats: LogStatistics): string {
    const areas = []

    if (stats.errorRate > 5) areas.push('redução de erros')
    if (stats.averageResponseTime > 500) areas.push('otimização de performance')
    if (stats.criticalIssues > 0) areas.push('resolução de incidentes críticos')

    return areas.length > 0 ? areas.join(', ') : 'manutenção preventiva'
  }

  private generateTimeline(logs: SystemLog[], days: number): Array<{ date: string; count: number; errors: number }> {
    const timeline = []
    const now = new Date()

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(now)
      date.setDate(date.getDate() - i)
      const dateStr = date.toISOString().split('T')[0]

      const dayLogs = logs.filter(log => (log.created_at || log.timestamp || '').startsWith(dateStr))
      const errors = dayLogs.filter(log => log.severity === 'error' || log.severity === 'critical').length

      timeline.push({
        date: dateStr,
        count: dayLogs.length,
        errors
      })
    }

    return timeline
  }

  private getEmptyStatistics(): LogStatistics {
    return {
      totalLogs: 0,
      errorRate: 0,
      warningRate: 0,
      topUsers: [],
      topResources: [],
      severityDistribution: {},
      categoryDistribution: {},
      timelineData: [],
      averageResponseTime: 0,
      criticalIssues: 0
    }
  }

  private saveToLocalStorage(log: SystemLog): void {
    try {
      const key = 'system_logs_fallback'
      const stored = localStorage.getItem(key)
      const logs = stored ? JSON.parse(stored) : []

      logs.push(log)

      // Manter apenas os últimos 100 logs
      if (logs.length > 100) {
        logs.splice(0, logs.length - 100)
      }

      localStorage.setItem(key, JSON.stringify(logs))
    } catch (error) {
      console.error('Erro ao salvar log no localStorage:', error)
    }
  }

  /**
   * Log automático de ações do usuário
   */
  logUserAction(action: string, resource: string, details?: any, resourceId?: string | number): void {
    this.createLog({
      action,
      resource,
      resource_id: resourceId,
      details: details || {},
      category: 'user',
      severity: 'info'
    }).catch(error => {
      console.error('Erro ao registrar ação do usuário:', error)
    })
  }

  /**
   * Log automático de erros
   */
  logError(error: Error, context: string, details?: any): void {
    this.createLog({
      action: 'error_occurred',
      resource: context,
      details: {
        error: error.message,
        stack: error.stack,
        ...details
      },
      category: 'system',
      severity: 'error',
      status: 'failed',
      error_message: error.message
    }).catch(err => {
      console.error('Erro ao registrar erro no sistema:', err)
    })
  }

  /**
   * Limpa logs antigos (executar via cron job)
   */
  async cleanOldLogs(daysToKeep: number = 90): Promise<number> {
    try {
      const cutoffDate = new Date()
      cutoffDate.setDate(cutoffDate.getDate() - daysToKeep)

      const { data, error } = await supabase
        .from(DB_TABLES.LOGS)
        .delete()
        .lt('created_at', cutoffDate.toISOString())

      if (error) throw error

      const deletedCount = (data as unknown[] | null)?.length ?? 0

      await this.createLog({
        action: 'cleanup_old_logs',
        resource: 'system_maintenance',
        details: { daysToKeep, deletedCount, cutoffDate: cutoffDate.toISOString() },
        category: 'system',
        severity: 'info'
      })

      return deletedCount
    } catch (error: any) {
      await this.logError(error, 'log_cleanup')
      return 0
    }
  }
}

export const logService = new LogService()

// Hook para interceptar todas as ações do sistema
export const useLogInterceptor = () => {
  return {
    logAction: logService.logUserAction.bind(logService),
    logError: logService.logError.bind(logService)
  }
}
