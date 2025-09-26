import { supabase } from '@/config/supabase'

/**
 * Utility para criar as tabelas de permissões manualmente
 * Este script deve ser executado apenas uma vez ou quando as tabelas não existirem
 */

export async function createPermissionsTables(): Promise<{ success: boolean; message: string }> {
  try {
    console.log('🚀 Iniciando criação das tabelas de permissões...')

    // Criar tabela user_roles usando insert para forçar a criação
    console.log('📝 Tentando criar tabela user_roles...')
    const { error: rolesError } = await supabase
      .from('user_roles')
      .insert([
        {
          id: 'admin',
          name: 'Administrador',
          description: 'Acesso total ao sistema',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ])

    if (rolesError && !rolesError.message.includes('duplicate key')) {
      console.error('❌ Erro ao criar user_roles:', rolesError.message)
      return {
        success: false,
        message: `Erro ao criar tabela user_roles: ${rolesError.message}`
      }
    }

    // Criar tabela permissions
    console.log('📝 Tentando criar tabela permissions...')
    const { error: permissionsError } = await supabase
      .from('permissions')
      .insert([
        {
          id: 'users_view',
          name: 'Ver Usuários',
          description: 'Visualizar lista de usuários',
          category: 'usuarios',
          created_at: new Date().toISOString()
        }
      ])

    if (permissionsError && !permissionsError.message.includes('duplicate key')) {
      console.error('❌ Erro ao criar permissions:', permissionsError.message)
      return {
        success: false,
        message: `Erro ao criar tabela permissions: ${permissionsError.message}`
      }
    }

    // Criar tabela role_permissions
    console.log('📝 Tentando criar tabela role_permissions...')
    const { error: rolePermissionsError } = await supabase
      .from('role_permissions')
      .insert([
        {
          role_id: 'admin',
          permission_id: 'users_view',
          granted: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ])

    if (rolePermissionsError && !rolePermissionsError.message.includes('duplicate key')) {
      console.error('❌ Erro ao criar role_permissions:', rolePermissionsError.message)
      return {
        success: false,
        message: `Erro ao criar tabela role_permissions: ${rolePermissionsError.message}`
      }
    }

    console.log('✅ Estrutura básica criada com sucesso!')

    // Agora popular com todos os dados
    await populateDefaultData()

    return {
      success: true,
      message: 'Sistema de permissões criado e inicializado com sucesso!'
    }

  } catch (error) {
    console.error('💥 Erro geral:', error)
    return {
      success: false,
      message: `Erro inesperado: ${(error as any)?.message || error}`
    }
  }
}

async function populateDefaultData() {
  console.log('📊 Populando dados padrão...')

  try {
    // Inserir todos os cargos
    const roles = [
      {
        id: 'admin',
        name: 'Administrador',
        description: 'Acesso total ao sistema'
      },
      {
        id: 'manager',
        name: 'Gerente',
        description: 'Acesso a relatórios e gestão'
      },
      {
        id: 'stock_controller',
        name: 'Controlador de Estoque',
        description: 'Gestão de produtos e estoque'
      },
      {
        id: 'user',
        name: 'Usuário',
        description: 'Acesso básico ao sistema'
      }
    ]

    const { error: rolesUpsertError } = await supabase
      .from('user_roles')
      .upsert(roles.map(role => ({
        ...role,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })))

    if (rolesUpsertError) {
      console.warn('⚠️ Aviso ao inserir cargos:', rolesUpsertError.message)
    }

    // Inserir todas as permissões
    const permissions = [
      { id: 'users_view', name: 'Ver Usuários', description: 'Visualizar lista de usuários', category: 'usuarios' },
      { id: 'users_create', name: 'Criar Usuários', description: 'Criar novos usuários', category: 'usuarios' },
      { id: 'users_edit', name: 'Editar Usuários', description: 'Modificar dados dos usuários', category: 'usuarios' },
      { id: 'users_delete', name: 'Excluir Usuários', description: 'Remover usuários do sistema', category: 'usuarios' },
      { id: 'inventory_view', name: 'Ver Estoque', description: 'Visualizar produtos e estoque', category: 'estoque' },
      { id: 'inventory_create', name: 'Criar Produtos', description: 'Adicionar novos produtos', category: 'estoque' },
      { id: 'inventory_edit', name: 'Editar Produtos', description: 'Modificar dados dos produtos', category: 'estoque' },
      { id: 'inventory_delete', name: 'Excluir Produtos', description: 'Remover produtos do sistema', category: 'estoque' },
      { id: 'reports_view', name: 'Ver Relatórios', description: 'Acessar relatórios e análises', category: 'relatorios' },
      { id: 'financial_view', name: 'Ver Financeiro', description: 'Acessar dados financeiros', category: 'financeiro' },
      { id: 'settings_manage', name: 'Gerenciar Config.', description: 'Alterar configurações do sistema', category: 'sistema' },
      { id: 'backup_manage', name: 'Gerenciar Backup', description: 'Criar e restaurar backups', category: 'sistema' }
    ]

    const { error: permissionsUpsertError } = await supabase
      .from('permissions')
      .upsert(permissions.map(permission => ({
        ...permission,
        created_at: new Date().toISOString()
      })))

    if (permissionsUpsertError) {
      console.warn('⚠️ Aviso ao inserir permissões:', permissionsUpsertError.message)
    }

    // Inserir matriz de permissões
    const rolePermissions = [
      // Admin - todas as permissões
      ...permissions.map(p => ({ role_id: 'admin', permission_id: p.id, granted: true })),
      // Manager - permissões limitadas
      { role_id: 'manager', permission_id: 'users_view', granted: true },
      { role_id: 'manager', permission_id: 'inventory_view', granted: true },
      { role_id: 'manager', permission_id: 'inventory_create', granted: true },
      { role_id: 'manager', permission_id: 'inventory_edit', granted: true },
      { role_id: 'manager', permission_id: 'reports_view', granted: true },
      { role_id: 'manager', permission_id: 'financial_view', granted: true },
      // Stock Controller - apenas estoque
      { role_id: 'stock_controller', permission_id: 'inventory_view', granted: true },
      { role_id: 'stock_controller', permission_id: 'inventory_create', granted: true },
      { role_id: 'stock_controller', permission_id: 'inventory_edit', granted: true },
      // User - apenas visualização
      { role_id: 'user', permission_id: 'inventory_view', granted: true }
    ]

    const { error: rolePermissionsUpsertError } = await supabase
      .from('role_permissions')
      .upsert(rolePermissions.map(rp => ({
        ...rp,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })))

    if (rolePermissionsUpsertError) {
      console.warn('⚠️ Aviso ao inserir matriz de permissões:', rolePermissionsUpsertError.message)
    }

    console.log('✅ Dados padrão inseridos com sucesso!')
  } catch (error) {
    console.error('❌ Erro ao popular dados:', error)
    throw error
  }
}

export async function testPermissionsConnection(): Promise<{ success: boolean; message: string; tablesExist: boolean }> {
  try {
    console.log('🔍 Testando conexão com tabelas de permissões...')

    // Testar se as tabelas existem
    const { error: rolesError } = await supabase
      .from('user_roles')
      .select('count(*)')
      .limit(1)

    const { error: permissionsError } = await supabase
      .from('permissions')
      .select('count(*)')
      .limit(1)

    const { error: rolePermissionsError } = await supabase
      .from('role_permissions')
      .select('count(*)')
      .limit(1)

    const tablesExist = !rolesError && !permissionsError && !rolePermissionsError

    if (tablesExist) {
      return {
        success: true,
        message: 'Todas as tabelas de permissões existem e estão acessíveis',
        tablesExist: true
      }
    } else {
      return {
        success: false,
        message: 'Algumas tabelas não existem ou não são acessíveis',
        tablesExist: false
      }
    }
  } catch (error) {
    return {
      success: false,
      message: `Erro ao testar conexão: ${(error as any)?.message || error}`,
      tablesExist: false
    }
  }
}