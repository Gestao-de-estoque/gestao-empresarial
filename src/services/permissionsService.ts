import { supabase, DB_TABLES } from '@/config/supabase'

export interface UserRole {
  id: string
  name: string
  description: string
  created_at?: string
  updated_at?: string
}

export interface Permission {
  id: string
  name: string
  description: string
  category: string
  created_at?: string
}

export interface RolePermission {
  role_id: string
  permission_id: string
  granted: boolean
  created_at?: string
  updated_at?: string
}

export interface RolePermissionMatrix {
  [roleId: string]: {
    [permissionId: string]: boolean
  }
}

export const permissionsService = {
  // Buscar todos os cargos
  async getRoles(): Promise<UserRole[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.ROLES)
        .select('*')
        .order('name')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar cargos:', error)
      throw error
    }
  },

  // Buscar todas as permissões
  async getPermissions(): Promise<Permission[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PERMISSIONS)
        .select('*')
        .order('category, name')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar permissões:', error)
      throw error
    }
  },

  // Buscar matriz de permissões por cargo
  async getRolePermissions(): Promise<RolePermissionMatrix> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.ROLE_PERMISSIONS)
        .select('role_id, permission_id, granted')

      if (error) throw error

      const matrix: RolePermissionMatrix = {}

      data?.forEach((rp) => {
        if (!matrix[rp.role_id]) {
          matrix[rp.role_id] = {}
        }
        matrix[rp.role_id][rp.permission_id] = rp.granted
      })

      return matrix
    } catch (error) {
      console.error('Erro ao buscar permissões de cargos:', error)
      throw error
    }
  },

  // Atualizar permissão de um cargo
  async updateRolePermission(roleId: string, permissionId: string, granted: boolean): Promise<boolean> {
    try {
      const { error } = await supabase
        .from(DB_TABLES.ROLE_PERMISSIONS)
        .upsert({
          role_id: roleId,
          permission_id: permissionId,
          granted,
          updated_at: new Date().toISOString()
        })

      if (error) throw error
      return true
    } catch (error) {
      console.error('Erro ao atualizar permissão:', error)
      throw error
    }
  },

  // Salvar todas as permissões (operação em lote)
  async saveAllPermissions(matrix: RolePermissionMatrix): Promise<boolean> {
    try {
      const updates: any[] = []

      Object.keys(matrix).forEach(roleId => {
        Object.keys(matrix[roleId]).forEach(permissionId => {
          updates.push({
            role_id: roleId,
            permission_id: permissionId,
            granted: matrix[roleId][permissionId],
            updated_at: new Date().toISOString()
          })
        })
      })

      const { error } = await supabase
        .from(DB_TABLES.ROLE_PERMISSIONS)
        .upsert(updates)

      if (error) throw error
      return true
    } catch (error) {
      console.error('Erro ao salvar permissões:', error)
      throw error
    }
  },

  // Criar cargo
  async createRole(role: Omit<UserRole, 'id' | 'created_at' | 'updated_at'>): Promise<UserRole> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.ROLES)
        .insert({
          ...role,
          created_at: new Date().toISOString()
        })
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar cargo:', error)
      throw error
    }
  },

  // Criar permissão
  async createPermission(permission: Omit<Permission, 'id' | 'created_at'>): Promise<Permission> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PERMISSIONS)
        .insert({
          ...permission,
          created_at: new Date().toISOString()
        })
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar permissão:', error)
      throw error
    }
  },

  // Inicializar dados padrão (cargos e permissões)
  async initializeDefaultData(): Promise<boolean> {
    try {
      console.log('🚀 Iniciando inicialização do sistema de permissões...')

      // Verificar se já existem dados
      const { data: existingRoles, error: checkError } = await supabase
        .from(DB_TABLES.ROLES)
        .select('id')
        .limit(1)

      // Se há erro, pode ser que a tabela não existe
      if (checkError) {
        console.log('❌ Erro ao verificar dados existentes:', checkError.message)
        console.log('📋 Detalhes do erro:', checkError)

        // Se a tabela não existe, vamos tentar criar dados básicos forçando a criação
        if (checkError.message?.includes('Could not find') || checkError.message?.includes('does not exist')) {
          console.log('🔧 Tentando criar estrutura básica...')
          return await this.forceCreateBasicStructure()
        }

        throw new Error(`Erro ao acessar tabelas: ${checkError.message}`)
      } else if (existingRoles && existingRoles.length > 0) {
        console.log('✅ Dados de permissões já existem')
        return true
      }

      console.log('📊 Populando dados padrão...')

      // Criar cargos padrão
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
        .from(DB_TABLES.ROLES)
        .insert(defaultRoles.map(role => ({
          ...role,
          created_at: new Date().toISOString()
        })))

      if (rolesError) throw rolesError

      // Criar permissões padrão
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
        .from(DB_TABLES.PERMISSIONS)
        .insert(defaultPermissions.map(permission => ({
          ...permission,
          created_at: new Date().toISOString()
        })))

      if (permissionsError) throw permissionsError

      // Criar matriz de permissões padrão
      const defaultRolePermissions = [
        // Admin - todas as permissões
        ...defaultPermissions.map(p => ({
          role_id: 'admin',
          permission_id: p.id,
          granted: true,
          created_at: new Date().toISOString()
        })),
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
      ].map(rp => ({
        ...rp,
        created_at: new Date().toISOString()
      }))

      const { error: rolePermissionsError } = await supabase
        .from(DB_TABLES.ROLE_PERMISSIONS)
        .insert(defaultRolePermissions)

      if (rolePermissionsError) throw rolePermissionsError

      console.log('Dados padrão de permissões criados com sucesso')
      return true
    } catch (error) {
      console.error('Erro ao inicializar dados padrão:', error)
      throw error
    }
  },

  // Verificar se um usuário tem uma permissão específica
  async userHasPermission(userId: string, permissionId: string): Promise<boolean> {
    try {
      // Buscar o cargo do usuário
      const { data: user, error: userError } = await supabase
        .from(DB_TABLES.USERS)
        .select('role')
        .eq('id', userId)
        .single()

      if (userError) throw userError

      if (!user?.role) return false

      // Verificar se o cargo tem a permissão
      const { data: rolePermission, error: permissionError } = await supabase
        .from(DB_TABLES.ROLE_PERMISSIONS)
        .select('granted')
        .eq('role_id', user.role)
        .eq('permission_id', permissionId)
        .single()

      if (permissionError) return false

      return rolePermission?.granted || false
    } catch (error) {
      console.error('Erro ao verificar permissão:', error)
      return false
    }
  },

  // Método para forçar a criação da estrutura básica quando as tabelas não existem
  async forceCreateBasicStructure(): Promise<boolean> {
    try {
      console.log('💡 Tentando criar estrutura básica por inserção direta...')

      // Tentar criar um registro inicial em cada tabela para forçar a criação
      // Isso só funcionará se as tabelas existirem no Supabase

      // 1. Criar uma role de teste
      console.log('📝 Inserindo role de teste...')
      const { error: roleError } = await supabase
        .from(DB_TABLES.ROLES)
        .upsert({
          id: 'admin',
          name: 'Administrador',
          description: 'Acesso total ao sistema',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })

      if (roleError) {
        console.error('❌ Erro ao inserir role:', roleError.message)
        throw new Error(`As tabelas não existem no banco de dados. Por favor, execute o script SQL para criar as tabelas: ${roleError.message}`)
      }

      // 2. Criar uma permissão de teste
      console.log('📝 Inserindo permissão de teste...')
      const { error: permError } = await supabase
        .from(DB_TABLES.PERMISSIONS)
        .upsert({
          id: 'users_view',
          name: 'Ver Usuários',
          description: 'Visualizar lista de usuários',
          category: 'usuarios',
          created_at: new Date().toISOString()
        })

      if (permError) {
        console.error('❌ Erro ao inserir permissão:', permError.message)
        throw new Error(`Tabela de permissões não existe: ${permError.message}`)
      }

      // 3. Criar relacionamento de teste
      console.log('📝 Inserindo relacionamento de teste...')
      const { error: relError } = await supabase
        .from(DB_TABLES.ROLE_PERMISSIONS)
        .upsert({
          role_id: 'admin',
          permission_id: 'users_view',
          granted: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })

      if (relError) {
        console.error('❌ Erro ao inserir relacionamento:', relError.message)
        throw new Error(`Tabela de relacionamentos não existe: ${relError.message}`)
      }

      console.log('✅ Estrutura básica criada! Agora populando todos os dados...')

      // Agora chamar o método normal de inicialização
      return await this.populateAllDefaultData()

    } catch (error) {
      console.error('💥 Erro ao criar estrutura básica:', error)
      throw error
    }
  },

  // Método auxiliar para popular todos os dados padrão
  async populateAllDefaultData(): Promise<boolean> {
    try {
      console.log('📊 Populando todos os dados padrão...')

      // Criar cargos padrão
      const defaultRoles = [
        { id: 'admin', name: 'Administrador', description: 'Acesso total ao sistema' },
        { id: 'manager', name: 'Gerente', description: 'Acesso a relatórios e gestão' },
        { id: 'stock_controller', name: 'Controlador de Estoque', description: 'Gestão de produtos e estoque' },
        { id: 'user', name: 'Usuário', description: 'Acesso básico ao sistema' }
      ]

      const { error: rolesError } = await supabase
        .from(DB_TABLES.ROLES)
        .upsert(defaultRoles.map(role => ({
          ...role,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })))

      if (rolesError) {
        console.warn('⚠️ Aviso ao inserir roles:', rolesError.message)
      }

      // Criar permissões padrão
      const defaultPermissions = [
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

      const { error: permissionsError } = await supabase
        .from(DB_TABLES.PERMISSIONS)
        .upsert(defaultPermissions.map(permission => ({
          ...permission,
          created_at: new Date().toISOString()
        })))

      if (permissionsError) {
        console.warn('⚠️ Aviso ao inserir permissions:', permissionsError.message)
      }

      // Criar matriz de permissões padrão
      const defaultRolePermissions = [
        // Admin - todas as permissões
        ...defaultPermissions.map(p => ({
          role_id: 'admin',
          permission_id: p.id,
          granted: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })),
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
      ].map(rp => ({
        ...rp,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }))

      const { error: rolePermissionsError } = await supabase
        .from(DB_TABLES.ROLE_PERMISSIONS)
        .upsert(defaultRolePermissions)

      if (rolePermissionsError) {
        console.warn('⚠️ Aviso ao inserir role permissions:', rolePermissionsError.message)
      }

      console.log('✅ Todos os dados padrão foram inseridos com sucesso!')
      return true

    } catch (error) {
      console.error('❌ Erro ao popular dados:', error)
      throw error
    }
  }
}