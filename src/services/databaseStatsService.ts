import { supabase } from '@/config/supabase'
// import { DB_TABLES } from '@/config/supabase'

export interface DatabaseStats {
  totalSize: number // em MB
  usedSpace: number // em MB
  availableSpace: number // em MB
  usagePercentage: number
  tableStats: TableStat[]
  storageStats: {
    totalFiles: number
    totalSize: number // em MB
  }
  projectInfo: {
    projectId: string
    planType: 'free' | 'pro' | 'team' | 'enterprise'
    maxDbSize: number // em MB
    maxStorage: number // em MB
  }
}

export interface TableStat {
  tableName: string
  rowCount: number
  sizeInMB: number
  lastUpdated: string
}

class DatabaseStatsService {
  private readonly FREE_PLAN_DB_LIMIT = 500 // MB
  private readonly FREE_PLAN_STORAGE_LIMIT = 1000 // MB

  private getProjectInfo() {
    return {
      projectId: import.meta.env.VITE_SUPABASE_PROJECT_ID || 'cxusoclwtixtjwghjlcj',
      url: import.meta.env.VITE_SUPABASE_URL || 'https://cxusoclwtixtjwghjlcj.supabase.co',
      planType: 'free' as const,
      maxDbSize: this.FREE_PLAN_DB_LIMIT,
      maxStorage: this.FREE_PLAN_STORAGE_LIMIT
    }
  }

  /**
   * Obtém estatísticas completas do banco de dados
   */
  async getDatabaseStats(): Promise<DatabaseStats> {
    try {
      const projectInfo = this.getProjectInfo()

      console.log('📊 Coletando estatísticas do banco de dados...', {
        projectId: projectInfo.projectId,
        url: projectInfo.url,
        planType: projectInfo.planType
      })

      const [tableStats, storageStats, dbSizeInfo] = await Promise.all([
        this.getTableStatistics(),
        this.getStorageStatistics(),
        this.getDatabaseSizeInfo()
      ])

      const totalSize = dbSizeInfo.totalSize
      const usedSpace = totalSize
      const availableSpace = Math.max(0, projectInfo.maxDbSize - usedSpace)
      const usagePercentage = Math.min(100, (usedSpace / projectInfo.maxDbSize) * 100)

      const stats: DatabaseStats = {
        totalSize,
        usedSpace,
        availableSpace,
        usagePercentage,
        tableStats,
        storageStats,
        projectInfo
      }

      console.log('✅ Estatísticas coletadas com sucesso:', {
        totalSize: this.formatSize(totalSize),
        usagePercentage: `${Math.round(usagePercentage)}%`,
        tablesCount: tableStats.length,
        recordsTotal: tableStats.reduce((sum, t) => sum + t.rowCount, 0),
        storageFiles: storageStats.totalFiles,
        storageSize: this.formatSize(storageStats.totalSize)
      })

      return stats

    } catch (error) {
      console.error('❌ Erro ao coletar estatísticas:', error)
      throw new Error('Erro ao obter estatísticas do banco de dados')
    }
  }

  /**
   * Obtém estatísticas de cada tabela
   */
  private async getTableStatistics(): Promise<TableStat[]> {
    const tables = [
      { name: 'admin_users', label: 'Usuários' },
      { name: 'produtos', label: 'Produtos' },
      { name: 'categorias', label: 'Categorias' },
      { name: 'movements', label: 'Movimentações' },
      { name: 'menu_items', label: 'Itens do Menu' },
      { name: 'logs', label: 'Logs do Sistema' },
      { name: 'reports', label: 'Relatórios' },
      { name: 'suppliers', label: 'Fornecedores' }
    ]

    const tableStats: TableStat[] = []

    for (const table of tables) {
      try {
        // Contar linhas da tabela
        const { count, error } = await supabase
          .from(table.name)
          .select('*', { count: 'exact', head: true })

        if (error) {
          console.warn(`Erro ao contar ${table.name}:`, error)
          continue
        }

        // Estimar tamanho da tabela (aproximado)
        const estimatedSizeKB = (count || 0) * 2 // ~2KB por linha (estimativa)
        const sizeInMB = estimatedSizeKB / 1024

        tableStats.push({
          tableName: table.label,
          rowCount: count || 0,
          sizeInMB: parseFloat(sizeInMB.toFixed(2)),
          lastUpdated: new Date().toISOString()
        })

      } catch (error) {
        console.warn(`Erro ao processar tabela ${table.name}:`, error)
      }
    }

    return tableStats.sort((a, b) => b.rowCount - a.rowCount)
  }

  /**
   * Obtém estatísticas do Supabase Storage
   */
  private async getStorageStatistics(): Promise<{ totalFiles: number; totalSize: number }> {
    try {
      // Listar todos os buckets
      const { data: buckets, error: bucketsError } = await supabase.storage.listBuckets()

      if (bucketsError) {
        console.warn('Erro ao listar buckets:', bucketsError)
        return { totalFiles: 0, totalSize: 0 }
      }

      let totalFiles = 0
      let totalSize = 0

      for (const bucket of buckets || []) {
        try {
          const { data: files, error: filesError } = await supabase.storage
            .from(bucket.name)
            .list()

          if (!filesError && files) {
            totalFiles += files.length

            // Somar tamanhos dos arquivos
            for (const file of files) {
              if (file.metadata?.size) {
                totalSize += file.metadata.size
              }
            }
          }
        } catch (error) {
          console.warn(`Erro ao processar bucket ${bucket.name}:`, error)
        }
      }

      return {
        totalFiles,
        totalSize: parseFloat((totalSize / (1024 * 1024)).toFixed(2)) // Converter para MB
      }

    } catch (error) {
      console.warn('Erro ao obter estatísticas de storage:', error)
      return { totalFiles: 0, totalSize: 0 }
    }
  }

  /**
   * Obtém informações sobre o tamanho do banco via consulta SQL
   */
  private async getDatabaseSizeInfo(): Promise<{ totalSize: number }> {
    try {
      // Query para obter tamanho do banco (funciona no PostgreSQL)
      const { data, error } = await supabase.rpc('get_database_size')

      if (error) {
        console.warn('RPC get_database_size não disponível:', error)

        // Fallback: estimar baseado no número de registros
        const estimatedSize = await this.estimateDatabaseSize()
        return { totalSize: estimatedSize }
      }

      // Se a função RPC funcionar, converter bytes para MB
      const sizeInMB = (data || 0) / (1024 * 1024)
      return { totalSize: parseFloat(sizeInMB.toFixed(2)) }

    } catch (error) {
      console.warn('Erro ao obter tamanho do banco:', error)

      // Fallback para estimativa
      const estimatedSize = await this.estimateDatabaseSize()
      return { totalSize: estimatedSize }
    }
  }

  /**
   * Estima o tamanho do banco baseado nos dados das tabelas
   */
  private async estimateDatabaseSize(): Promise<number> {
    try {
      const tableStats = await this.getTableStatistics()
      const totalEstimated = tableStats.reduce((sum, table) => sum + table.sizeInMB, 0)

      // Adicionar overhead do PostgreSQL (índices, metadados, etc.) - aproximadamente 30%
      const withOverhead = totalEstimated * 1.3

      return parseFloat(Math.max(1, withOverhead).toFixed(2)) // Mínimo 1MB
    } catch (error) {
      console.warn('Erro ao estimar tamanho:', error)
      return 1 // Fallback para 1MB
    }
  }

  /**
   * Verifica se o banco está próximo do limite
   */
  async checkDatabaseHealth(): Promise<{
    status: 'healthy' | 'warning' | 'critical'
    message: string
    usagePercentage: number
  }> {
    try {
      const stats = await this.getDatabaseStats()
      const usagePercentage = stats.usagePercentage

      if (usagePercentage >= 95) {
        return {
          status: 'critical',
          message: 'Banco de dados quase cheio! Considere fazer limpeza ou upgrade.',
          usagePercentage
        }
      } else if (usagePercentage >= 80) {
        return {
          status: 'warning',
          message: 'Banco de dados com uso elevado. Monitor o crescimento.',
          usagePercentage
        }
      } else {
        return {
          status: 'healthy',
          message: 'Banco de dados com espaço adequado.',
          usagePercentage
        }
      }
    } catch (error) {
      return {
        status: 'critical',
        message: 'Erro ao verificar status do banco de dados.',
        usagePercentage: 0
      }
    }
  }

  /**
   * Formatar tamanho em bytes para formato legível
   */
  formatSize(sizeInMB: number): string {
    if (sizeInMB < 1) {
      return `${(sizeInMB * 1024).toFixed(1)} KB`
    } else if (sizeInMB < 1024) {
      return `${sizeInMB.toFixed(1)} MB`
    } else {
      return `${(sizeInMB / 1024).toFixed(1)} GB`
    }
  }

  /**
   * Obter recomendações para otimização
   */
  async getOptimizationRecommendations(): Promise<string[]> {
    try {
      const stats = await this.getDatabaseStats()
      const recommendations: string[] = []

      // Verificar tabelas grandes
      const largeTables = stats.tableStats.filter(table => table.rowCount > 1000)
      if (largeTables.length > 0) {
        recommendations.push('Considere arquivar dados antigos das tabelas: ' +
          largeTables.map(t => t.tableName).join(', '))
      }

      // Verificar logs
      const logsTable = stats.tableStats.find(table => table.tableName === 'Logs do Sistema')
      if (logsTable && logsTable.rowCount > 5000) {
        recommendations.push('Implemente rotação de logs para reduzir o tamanho da tabela de logs')
      }

      // Verificar storage
      if (stats.storageStats.totalSize > 100) {
        recommendations.push('Otimize as imagens do storage ou implemente CDN')
      }

      // Verificar uso geral
      if (stats.usagePercentage > 70) {
        recommendations.push('Considere upgrade do plano do Supabase para mais espaço')
      }

      return recommendations
    } catch (error) {
      return ['Erro ao gerar recomendações de otimização']
    }
  }
}

export const databaseStatsService = new DatabaseStatsService()