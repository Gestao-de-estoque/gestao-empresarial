import { supabase } from '@/config/supabase'

export async function initializePermissionsTables(): Promise<boolean> {
  try {
    console.log('Inicializando tabelas de permissões...')

    // Executar cada comando SQL individualmente para melhor controle de erros
    const sqlCommands = [
      // Criar tabela user_roles
      `
      CREATE TABLE IF NOT EXISTS user_roles (
          id VARCHAR(50) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          description TEXT,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      `,

      // Criar tabela permissions
      `
      CREATE TABLE IF NOT EXISTS permissions (
          id VARCHAR(50) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          description TEXT,
          category VARCHAR(100) NOT NULL DEFAULT 'sistema',
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      `,

      // Criar tabela role_permissions
      `
      CREATE TABLE IF NOT EXISTS role_permissions (
          role_id VARCHAR(50),
          permission_id VARCHAR(50),
          granted BOOLEAN NOT NULL DEFAULT FALSE,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (role_id, permission_id)
      );
      `
    ]

    // Executar comandos de criação de tabelas
    for (const sql of sqlCommands) {
      const { error } = await supabase.rpc('execute_sql', { sql_query: sql })
      if (error) {
        console.error('Erro ao executar SQL:', error)
        // Continuar tentando outros comandos mesmo se um falhar
      }
    }

    // Inserir dados padrão usando o service
    await insertDefaultData()

    console.log('Tabelas de permissões inicializadas com sucesso!')
    return true
  } catch (error) {
    console.error('Erro ao inicializar tabelas de permissões:', error)
    return false
  }
}

async function insertDefaultData() {
  try {
    // Inserir cargos padrão
    const defaultRoles = [
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

    const { error: rolesError } = await supabase
      .from('user_roles')
      .upsert(defaultRoles.map(role => ({
        ...role,
        created_at: new Date().toISOString()
      })))

    if (rolesError) {
      console.error('Erro ao inserir cargos:', rolesError)
    }

    // Inserir permissões padrão
    const defaultPermissions = [
      {
        id: 'users_view',
        name: 'Ver Usuários',
        description: 'Visualizar lista de usuários',
        category: 'usuarios'
      },
      {
        id: 'users_create',
        name: 'Criar Usuários',
        description: 'Criar novos usuários',
        category: 'usuarios'
      },
      {
        id: 'users_edit',
        name: 'Editar Usuários',
        description: 'Modificar dados dos usuários',
        category: 'usuarios'
      },
      {
        id: 'users_delete',
        name: 'Excluir Usuários',
        description: 'Remover usuários do sistema',
        category: 'usuarios'
      },
      {
        id: 'inventory_view',
        name: 'Ver Estoque',
        description: 'Visualizar produtos e estoque',
        category: 'estoque'
      },
      {
        id: 'inventory_create',
        name: 'Criar Produtos',
        description: 'Adicionar novos produtos',
        category: 'estoque'
      },
      {
        id: 'inventory_edit',
        name: 'Editar Produtos',
        description: 'Modificar dados dos produtos',
        category: 'estoque'
      },
      {
        id: 'inventory_delete',
        name: 'Excluir Produtos',
        description: 'Remover produtos do sistema',
        category: 'estoque'
      },
      {
        id: 'reports_view',
        name: 'Ver Relatórios',
        description: 'Acessar relatórios e análises',
        category: 'relatorios'
      },
      {
        id: 'financial_view',
        name: 'Ver Financeiro',
        description: 'Acessar dados financeiros',
        category: 'financeiro'
      },
      {
        id: 'settings_manage',
        name: 'Gerenciar Config.',
        description: 'Alterar configurações do sistema',
        category: 'sistema'
      },
      {
        id: 'backup_manage',
        name: 'Gerenciar Backup',
        description: 'Criar e restaurar backups',
        category: 'sistema'
      }
    ]

    const { error: permissionsError } = await supabase
      .from('permissions')
      .upsert(defaultPermissions.map(permission => ({
        ...permission,
        created_at: new Date().toISOString()
      })))

    if (permissionsError) {
      console.error('Erro ao inserir permissões:', permissionsError)
    }

    // Inserir matriz de permissões padrão
    const defaultRolePermissions = [
      // Admin - todas as permissões
      ...defaultPermissions.map(p => ({
        role_id: 'admin',
        permission_id: p.id,
        granted: true
      })),
      // Manager - permissões limitadas
      { role_id: 'manager', permission_id: 'users_view', granted: true },
      { role_id: 'manager', permission_id: 'users_create', granted: false },
      { role_id: 'manager', permission_id: 'users_edit', granted: false },
      { role_id: 'manager', permission_id: 'users_delete', granted: false },
      { role_id: 'manager', permission_id: 'inventory_view', granted: true },
      { role_id: 'manager', permission_id: 'inventory_create', granted: true },
      { role_id: 'manager', permission_id: 'inventory_edit', granted: true },
      { role_id: 'manager', permission_id: 'inventory_delete', granted: false },
      { role_id: 'manager', permission_id: 'reports_view', granted: true },
      { role_id: 'manager', permission_id: 'financial_view', granted: true },
      { role_id: 'manager', permission_id: 'settings_manage', granted: false },
      { role_id: 'manager', permission_id: 'backup_manage', granted: false },
      // Stock Controller - apenas estoque
      { role_id: 'stock_controller', permission_id: 'users_view', granted: false },
      { role_id: 'stock_controller', permission_id: 'users_create', granted: false },
      { role_id: 'stock_controller', permission_id: 'users_edit', granted: false },
      { role_id: 'stock_controller', permission_id: 'users_delete', granted: false },
      { role_id: 'stock_controller', permission_id: 'inventory_view', granted: true },
      { role_id: 'stock_controller', permission_id: 'inventory_create', granted: true },
      { role_id: 'stock_controller', permission_id: 'inventory_edit', granted: true },
      { role_id: 'stock_controller', permission_id: 'inventory_delete', granted: false },
      { role_id: 'stock_controller', permission_id: 'reports_view', granted: false },
      { role_id: 'stock_controller', permission_id: 'financial_view', granted: false },
      { role_id: 'stock_controller', permission_id: 'settings_manage', granted: false },
      { role_id: 'stock_controller', permission_id: 'backup_manage', granted: false },
      // User - apenas visualização
      { role_id: 'user', permission_id: 'users_view', granted: false },
      { role_id: 'user', permission_id: 'users_create', granted: false },
      { role_id: 'user', permission_id: 'users_edit', granted: false },
      { role_id: 'user', permission_id: 'users_delete', granted: false },
      { role_id: 'user', permission_id: 'inventory_view', granted: true },
      { role_id: 'user', permission_id: 'inventory_create', granted: false },
      { role_id: 'user', permission_id: 'inventory_edit', granted: false },
      { role_id: 'user', permission_id: 'inventory_delete', granted: false },
      { role_id: 'user', permission_id: 'reports_view', granted: false },
      { role_id: 'user', permission_id: 'financial_view', granted: false },
      { role_id: 'user', permission_id: 'settings_manage', granted: false },
      { role_id: 'user', permission_id: 'backup_manage', granted: false }
    ]

    const { error: rolePermissionsError } = await supabase
      .from('role_permissions')
      .upsert(defaultRolePermissions.map(rp => ({
        ...rp,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })))

    if (rolePermissionsError) {
      console.error('Erro ao inserir permissões de cargos:', rolePermissionsError)
    }

    console.log('Dados padrão inseridos com sucesso!')
  } catch (error) {
    console.error('Erro ao inserir dados padrão:', error)
  }
}

// Função simplificada que não depende de SQL customizado
export async function initializePermissionsData(): Promise<boolean> {
  try {
    console.log('Inicializando dados de permissões...')
    await insertDefaultData()
    return true
  } catch (error) {
    console.error('Erro ao inicializar dados de permissões:', error)
    return false
  }
}