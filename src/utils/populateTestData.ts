import { supabase, DB_TABLES } from '@/config/supabase'

export async function populateTestLogs() {
  try {
    const now = new Date()
    const testLogs = [
      {
        action: 'Sistema iniciado',
        category: 'sistema',
        severity: 'info',
        details: { message: 'Aplicação web inicializada com sucesso' },
        user_id: 'system',
        user_name: 'Sistema',
        user_email: 'system@gestaozesystem.com',
        created_at: new Date(now.getTime() - 60 * 60000).toISOString() // 1h atrás
      },
      {
        action: 'Usuário logado',
        category: 'autenticacao',
        severity: 'info',
        details: { message: 'Login realizado com sucesso' },
        user_id: 'user-001',
        user_name: 'Admin',
        user_email: 'admin@gestaozesystem.com',
        created_at: new Date(now.getTime() - 45 * 60000).toISOString() // 45min atrás
      },
      {
        action: 'Dashboard acessado',
        category: 'navegacao',
        severity: 'info',
        details: { page: '/dashboard', timestamp: new Date().toISOString() },
        user_id: 'user-001',
        user_name: 'Admin',
        user_email: 'admin@gestaozesystem.com',
        created_at: new Date(now.getTime() - 30 * 60000).toISOString() // 30min atrás
      },
      {
        action: 'Dados carregados',
        category: 'sistema',
        severity: 'info',
        details: { message: 'Dashboard carregado com sucesso' },
        user_id: 'system',
        user_name: 'Sistema',
        user_email: 'system@gestaozesystem.com',
        created_at: new Date(now.getTime() - 15 * 60000).toISOString() // 15min atrás
      },
      {
        action: 'Atividade recente verificada',
        category: 'operacao',
        severity: 'info',
        details: { message: 'Verificação de atividades recentes executada' },
        user_id: 'system',
        user_name: 'Sistema',
        user_email: 'system@gestaozesystem.com',
        created_at: new Date(now.getTime() - 5 * 60000).toISOString() // 5min atrás
      }
    ]

    const { data, error } = await supabase
      .from(DB_TABLES.LOGS)
      .insert(testLogs)
      .select()

    if (error) {
      console.error('Erro ao inserir logs de teste:', error)
      return { success: false, error }
    }

    console.log('Logs de teste inseridos com sucesso:', data?.length || 0)
    return { success: true, data }
  } catch (error) {
    console.error('Erro ao popular dados de teste:', error)
    return { success: false, error }
  }
}

export async function populateTestMovements() {
  try {
    // Primeiro, verificar se existem produtos para referenciar
    const { data: produtos } = await supabase
      .from(DB_TABLES.PRODUCTS)
      .select('id')
      .limit(1)

    if (!produtos || produtos.length === 0) {
      console.warn('Nenhum produto encontrado para criar movimentações de teste')
      return { success: false, error: 'No products found' }
    }

    const now = new Date()
    const productId = produtos[0].id

    const testMovements = [
      {
        product_id: productId,
        type: 'in',
        quantity: 50,
        created_at: new Date(now.getTime() - 120 * 60000).toISOString() // 2h atrás
      },
      {
        product_id: productId,
        type: 'out',
        quantity: 10,
        created_at: new Date(now.getTime() - 90 * 60000).toISOString() // 1.5h atrás
      },
      {
        product_id: productId,
        type: 'in',
        quantity: 25,
        created_at: new Date(now.getTime() - 60 * 60000).toISOString() // 1h atrás
      }
    ]

    const { data, error } = await supabase
      .from(DB_TABLES.MOVEMENTS)
      .insert(testMovements)
      .select()

    if (error) {
      console.error('Erro ao inserir movimentações de teste:', error)
      return { success: false, error }
    }

    console.log('Movimentações de teste inseridas com sucesso:', data?.length || 0)
    return { success: true, data }
  } catch (error) {
    console.error('Erro ao popular movimentações de teste:', error)
    return { success: false, error }
  }
}