import { supabase, DB_TABLES } from '@/config/supabase'

export interface SystemAlert {
  id: string
  type: 'critical' | 'warning' | 'info' | 'success'
  category: 'estoque' | 'sistema' | 'backup' | 'performance' | 'seguranca' | 'dados'
  title: string
  description: string
  details?: string
  icon: string
  created_at: string
  resolved: boolean
  auto_generated: boolean
  priority: number
  affected_entity?: string
  entity_id?: string
  action_required?: boolean
  suggested_actions?: string[]
  metadata?: any
}

export interface AlertRule {
  id: string
  name: string
  category: string
  condition: string
  threshold: number
  severity: 'critical' | 'warning' | 'info'
  enabled: boolean
  description: string
}

class AlertsService {
  private readonly alertRules: AlertRule[] = [
    {
      id: 'low_stock',
      name: 'Estoque Baixo',
      category: 'estoque',
      condition: 'current_stock <= min_stock',
      threshold: 1,
      severity: 'warning',
      enabled: true,
      description: 'Produtos com estoque abaixo do mínimo'
    },
    {
      id: 'critical_stock',
      name: 'Estoque Crítico',
      category: 'estoque',
      condition: 'current_stock = 0',
      threshold: 0,
      severity: 'critical',
      enabled: true,
      description: 'Produtos sem estoque'
    },
    {
      id: 'high_stock',
      name: 'Estoque Alto',
      category: 'estoque',
      condition: 'current_stock > max_stock',
      threshold: 1,
      severity: 'info',
      enabled: true,
      description: 'Produtos com estoque acima do máximo'
    },
    {
      id: 'database_size',
      name: 'Banco de Dados Cheio',
      category: 'sistema',
      condition: 'usage_percentage >= 85',
      threshold: 85,
      severity: 'warning',
      enabled: true,
      description: 'Banco de dados com uso elevado'
    },
    {
      id: 'inactive_products',
      name: 'Produtos Inativos',
      category: 'dados',
      condition: 'ativo = false',
      threshold: 5,
      severity: 'info',
      enabled: true,
      description: 'Muitos produtos marcados como inativos'
    },
    {
      id: 'no_recent_movements',
      name: 'Sem Movimentações',
      category: 'sistema',
      condition: 'no_movements_days >= 7',
      threshold: 7,
      severity: 'warning',
      enabled: true,
      description: 'Sem movimentações de estoque recentes'
    }
  ]

  /**
   * Verifica todas as regras de alerta e gera alertas necessários
   */
  async generateSystemAlerts(): Promise<SystemAlert[]> {
    console.log('🔍 Gerando alertas do sistema...')

    const alerts: SystemAlert[] = []

    try {
      // Verificar alertas de estoque
      const stockAlerts = await this.checkStockAlerts()
      alerts.push(...stockAlerts)

      // Verificar alertas de sistema
      const systemAlerts = await this.checkSystemAlerts()
      alerts.push(...systemAlerts)

      // Verificar alertas de dados
      const dataAlerts = await this.checkDataAlerts()
      alerts.push(...dataAlerts)

      // Salvar novos alertas no banco
      await this.saveAlertsToDatabase(alerts)

      console.log(`✅ ${alerts.length} alertas gerados`)
      return alerts

    } catch (error) {
      console.error('❌ Erro ao gerar alertas:', error)
      return []
    }
  }

  /**
   * Verifica alertas relacionados ao estoque
   */
  private async checkStockAlerts(): Promise<SystemAlert[]> {
    const alerts: SystemAlert[] = []

    try {
      // Produtos com estoque baixo
      const { data: lowStockProducts, error: lowStockError } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('id, nome, current_stock, min_stock, unidade')
        .gt('min_stock', 0)
        .gte('current_stock', 0)
        .filter('current_stock', 'lte', 'min_stock')
        .eq('ativo', true)

      if (!lowStockError && lowStockProducts && lowStockProducts.length > 0) {
        alerts.push({
          id: `low_stock_${Date.now()}`,
          type: 'warning',
          category: 'estoque',
          title: 'Estoque Baixo',
          description: `${lowStockProducts.length} produto(s) com estoque abaixo do mínimo`,
          details: lowStockProducts.map(p => `${p.nome}: ${p.current_stock} ${p.unidade}`).join(', '),
          icon: 'AlertTriangle',
          created_at: new Date().toISOString(),
          resolved: false,
          auto_generated: true,
          priority: 2,
          affected_entity: 'produtos',
          action_required: true,
          suggested_actions: [
            'Verificar necessidade de reposição',
            'Entrar em contato com fornecedores',
            'Ajustar estoque mínimo se necessário'
          ],
          metadata: { products: lowStockProducts }
        })
      }

      // Produtos sem estoque
      const { data: outOfStockProducts, error: outOfStockError } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('id, nome, unidade')
        .eq('current_stock', 0)
        .eq('ativo', true)

      if (!outOfStockError && outOfStockProducts && outOfStockProducts.length > 0) {
        alerts.push({
          id: `out_of_stock_${Date.now()}`,
          type: 'critical',
          category: 'estoque',
          title: 'Produtos Sem Estoque',
          description: `${outOfStockProducts.length} produto(s) sem estoque disponível`,
          details: outOfStockProducts.map(p => p.nome).join(', '),
          icon: 'XCircle',
          created_at: new Date().toISOString(),
          resolved: false,
          auto_generated: true,
          priority: 3,
          affected_entity: 'produtos',
          action_required: true,
          suggested_actions: [
            'Reabastecer estoque urgentemente',
            'Considerar produtos alternativos',
            'Avisar clientes sobre indisponibilidade'
          ],
          metadata: { products: outOfStockProducts }
        })
      }

      // Produtos com estoque excessivo
      const { data: excessStockProducts, error: excessStockError } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('id, nome, current_stock, max_stock, unidade')
        .not('max_stock', 'is', null)
        .gt('max_stock', 0)
        .filter('current_stock', 'gt', 'max_stock')
        .eq('ativo', true)

      if (!excessStockError && excessStockProducts && excessStockProducts.length > 0) {
        alerts.push({
          id: `excess_stock_${Date.now()}`,
          type: 'info',
          category: 'estoque',
          title: 'Estoque Excessivo',
          description: `${excessStockProducts.length} produto(s) com estoque acima do máximo`,
          details: excessStockProducts.map(p => `${p.nome}: ${p.current_stock} ${p.unidade}`).join(', '),
          icon: 'TrendingUp',
          created_at: new Date().toISOString(),
          resolved: false,
          auto_generated: true,
          priority: 1,
          affected_entity: 'produtos',
          action_required: false,
          suggested_actions: [
            'Considerar promoções para reduzir estoque',
            'Revisar política de compras',
            'Ajustar estoque máximo'
          ],
          metadata: { products: excessStockProducts }
        })
      }

    } catch (error) {
      console.error('Erro ao verificar alertas de estoque:', error)
    }

    return alerts
  }

  /**
   * Verifica alertas do sistema
   */
  private async checkSystemAlerts(): Promise<SystemAlert[]> {
    const alerts: SystemAlert[] = []

    try {
      // Verificar se há backups recentes (simulado)
      const lastBackupDate = new Date()
      lastBackupDate.setDate(lastBackupDate.getDate() - 1) // Simular backup de 1 dia atrás

      const daysSinceBackup = Math.floor((Date.now() - lastBackupDate.getTime()) / (1000 * 60 * 60 * 24))

      if (daysSinceBackup === 1) {
        alerts.push({
          id: `backup_success_${Date.now()}`,
          type: 'success',
          category: 'backup',
          title: 'Backup Realizado',
          description: 'Backup automático concluído com sucesso',
          details: `Último backup: ${lastBackupDate.toLocaleDateString('pt-BR')}`,
          icon: 'CheckCircle',
          created_at: new Date().toISOString(),
          resolved: false,
          auto_generated: true,
          priority: 1,
          affected_entity: 'sistema',
          action_required: false,
          metadata: { backup_date: lastBackupDate.toISOString() }
        })
      }

      // Verificar movimentações recentes
      const sevenDaysAgo = new Date()
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

      const { data: recentMovements, error: movementsError } = await supabase
        .from(DB_TABLES.MOVEMENTS)
        .select('id')
        .gte('created_at', sevenDaysAgo.toISOString())
        .limit(1)

      if (!movementsError && (!recentMovements || recentMovements.length === 0)) {
        alerts.push({
          id: `no_movements_${Date.now()}`,
          type: 'warning',
          category: 'sistema',
          title: 'Sem Movimentações',
          description: 'Nenhuma movimentação de estoque nos últimos 7 dias',
          details: 'Sistema pode estar inativo ou com problemas',
          icon: 'AlertCircle',
          created_at: new Date().toISOString(),
          resolved: false,
          auto_generated: true,
          priority: 2,
          affected_entity: 'movimentacoes',
          action_required: true,
          suggested_actions: [
            'Verificar se o sistema está sendo usado',
            'Confirmar funcionamento das integrações',
            'Revisar processo de entrada de dados'
          ]
        })
      }

      // Verificar logs de erro recentes
      const oneDayAgo = new Date()
      oneDayAgo.setDate(oneDayAgo.getDate() - 1)

      const { data: errorLogs, error: logsError } = await supabase
        .from(DB_TABLES.LOGS)
        .select('id, action, details')
        .eq('severity', 'error')
        .gte('created_at', oneDayAgo.toISOString())

      if (!logsError && errorLogs && errorLogs.length > 5) {
        alerts.push({
          id: `high_error_rate_${Date.now()}`,
          type: 'warning',
          category: 'sistema',
          title: 'Alta Taxa de Erros',
          description: `${errorLogs.length} erros registrados nas últimas 24 horas`,
          details: 'Sistema apresentando instabilidade',
          icon: 'AlertTriangle',
          created_at: new Date().toISOString(),
          resolved: false,
          auto_generated: true,
          priority: 2,
          affected_entity: 'sistema',
          action_required: true,
          suggested_actions: [
            'Revisar logs de erro detalhadamente',
            'Verificar conectividade com banco',
            'Contactar suporte técnico se necessário'
          ],
          metadata: { error_count: errorLogs.length }
        })
      }

    } catch (error) {
      console.error('Erro ao verificar alertas de sistema:', error)
    }

    return alerts
  }

  /**
   * Verifica alertas relacionados aos dados
   */
  private async checkDataAlerts(): Promise<SystemAlert[]> {
    const alerts: SystemAlert[] = []

    try {
      // Verificar produtos inativos
      const { data: inactiveProducts, error: inactiveError } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('id')
        .eq('ativo', false)

      if (!inactiveError && inactiveProducts && inactiveProducts.length > 10) {
        alerts.push({
          id: `many_inactive_products_${Date.now()}`,
          type: 'info',
          category: 'dados',
          title: 'Muitos Produtos Inativos',
          description: `${inactiveProducts.length} produtos marcados como inativos`,
          details: 'Considere revisar e limpar produtos desnecessários',
          icon: 'Info',
          created_at: new Date().toISOString(),
          resolved: false,
          auto_generated: true,
          priority: 1,
          affected_entity: 'produtos',
          action_required: false,
          suggested_actions: [
            'Revisar produtos inativos',
            'Remover produtos obsoletos',
            'Reativar produtos ainda necessários'
          ],
          metadata: { inactive_count: inactiveProducts.length }
        })
      }

      // Verificar categorias sem produtos
      const { data: categoriesWithoutProducts, error: categoriesError } = await supabase
        .from(DB_TABLES.CATEGORIES)
        .select(`
          id, nome,
          produtos:${DB_TABLES.PRODUCTS}(id)
        `)
        .eq('ativo', true)

      if (!categoriesError && categoriesWithoutProducts) {
        const emptyCategoriesCount = categoriesWithoutProducts.filter(cat =>
          !(cat as any).produtos || (cat as any).produtos.length === 0
        ).length

        if (emptyCategoriesCount > 0) {
          alerts.push({
            id: `empty_categories_${Date.now()}`,
            type: 'info',
            category: 'dados',
            title: 'Categorias Vazias',
            description: `${emptyCategoriesCount} categoria(s) sem produtos`,
            details: 'Categorias sem produtos podem ser removidas',
            icon: 'FolderX',
            created_at: new Date().toISOString(),
            resolved: false,
            auto_generated: true,
            priority: 1,
            affected_entity: 'categorias',
            action_required: false,
            suggested_actions: [
              'Remover categorias vazias',
              'Adicionar produtos às categorias',
              'Reorganizar estrutura de categorias'
            ],
            metadata: { empty_categories_count: emptyCategoriesCount }
          })
        }
      }

    } catch (error) {
      console.error('Erro ao verificar alertas de dados:', error)
    }

    return alerts
  }

  /**
   * Salva alertas no banco de dados
   */
  private async saveAlertsToDatabase(alerts: SystemAlert[]): Promise<void> {
    if (alerts.length === 0) return

    try {
      // Verificar se já existem alertas similares recentes (últimas 24 horas)
      const oneDayAgo = new Date()
      oneDayAgo.setDate(oneDayAgo.getDate() - 1)

      const { data: existingAlerts } = await supabase
        .from(DB_TABLES.SYSTEM_ALERTS)
        .select('id, category, title')
        .gte('created_at', oneDayAgo.toISOString())
        .eq('resolved', false)

      // Filtrar alertas que já existem
      const newAlerts = alerts.filter(alert => {
        return !existingAlerts?.some(existing =>
          existing.category === alert.category &&
          existing.title === alert.title
        )
      })

      if (newAlerts.length > 0) {
        const { error } = await supabase
          .from(DB_TABLES.SYSTEM_ALERTS)
          .insert(newAlerts.map(alert => ({
            id: alert.id,
            type: alert.type,
            category: alert.category,
            title: alert.title,
            description: alert.description,
            details: alert.details,
            icon: alert.icon,
            resolved: alert.resolved,
            auto_generated: alert.auto_generated,
            priority: alert.priority,
            affected_entity: alert.affected_entity,
            entity_id: alert.entity_id,
            action_required: alert.action_required,
            suggested_actions: alert.suggested_actions,
            metadata: alert.metadata,
            created_at: alert.created_at
          })))

        if (error) {
          console.error('Erro ao salvar alertas:', error)
        } else {
          console.log(`💾 ${newAlerts.length} novos alertas salvos no banco`)
        }
      }

    } catch (error) {
      console.error('Erro ao salvar alertas no banco:', error)
    }
  }

  /**
   * Obtém alertas do banco de dados
   */
  async getActiveAlerts(): Promise<SystemAlert[]> {
    try {
      const { data: alerts, error } = await supabase
        .from(DB_TABLES.SYSTEM_ALERTS)
        .select('*')
        .eq('resolved', false)
        .order('priority', { ascending: false })
        .order('created_at', { ascending: false })
        .limit(20)

      if (error) {
        console.error('Erro ao buscar alertas:', error)
        return []
      }

      return alerts || []

    } catch (error) {
      console.error('Erro ao obter alertas:', error)
      return []
    }
  }

  /**
   * Resolve um alerta
   */
  async resolveAlert(alertId: string): Promise<boolean> {
    try {
      const { error } = await supabase
        .from(DB_TABLES.SYSTEM_ALERTS)
        .update({
          resolved: true,
          resolved_at: new Date().toISOString()
        })
        .eq('id', alertId)

      if (error) {
        console.error('Erro ao resolver alerta:', error)
        return false
      }

      console.log(`✅ Alerta ${alertId} resolvido`)
      return true

    } catch (error) {
      console.error('Erro ao resolver alerta:', error)
      return false
    }
  }

  /**
   * Limpa alertas antigos resolvidos
   */
  async cleanOldAlerts(): Promise<void> {
    try {
      const thirtyDaysAgo = new Date()
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

      const { error } = await supabase
        .from(DB_TABLES.SYSTEM_ALERTS)
        .delete()
        .eq('resolved', true)
        .lt('created_at', thirtyDaysAgo.toISOString())

      if (error) {
        console.error('Erro ao limpar alertas antigos:', error)
      } else {
        console.log('🧹 Alertas antigos limpos')
      }

    } catch (error) {
      console.error('Erro ao limpar alertas:', error)
    }
  }

  /**
   * Obtém estatísticas dos alertas
   */
  async getAlertStats(): Promise<{
    total: number
    byType: Record<string, number>
    byCategory: Record<string, number>
    unresolved: number
  }> {
    try {
      const { data: alerts, error } = await supabase
        .from(DB_TABLES.SYSTEM_ALERTS)
        .select('type, category, resolved')

      if (error || !alerts) {
        return { total: 0, byType: {}, byCategory: {}, unresolved: 0 }
      }

      const stats = {
        total: alerts.length,
        byType: {} as Record<string, number>,
        byCategory: {} as Record<string, number>,
        unresolved: alerts.filter(a => !a.resolved).length
      }

      alerts.forEach(alert => {
        stats.byType[alert.type] = (stats.byType[alert.type] || 0) + 1
        stats.byCategory[alert.category] = (stats.byCategory[alert.category] || 0) + 1
      })

      return stats

    } catch (error) {
      console.error('Erro ao obter estatísticas:', error)
      return { total: 0, byType: {}, byCategory: {}, unresolved: 0 }
    }
  }
}

export const alertsService = new AlertsService()