-- Tabela de cargos/roles
CREATE TABLE IF NOT EXISTS user_roles (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de permissões
CREATE TABLE IF NOT EXISTS permissions (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL DEFAULT 'sistema',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de relacionamento cargo-permissões
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id VARCHAR(50) REFERENCES user_roles(id) ON DELETE CASCADE,
    permission_id VARCHAR(50) REFERENCES permissions(id) ON DELETE CASCADE,
    granted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id)
);

-- Adicionar coluna role na tabela admin_users se não existir
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission ON role_permissions(permission_id);
CREATE INDEX IF NOT EXISTS idx_admin_users_role ON admin_users(role);

-- Inserir cargos padrão
INSERT INTO user_roles (id, name, description) VALUES
    ('admin', 'Administrador', 'Acesso total ao sistema'),
    ('manager', 'Gerente', 'Acesso a relatórios e gestão'),
    ('stock_controller', 'Controlador de Estoque', 'Gestão de produtos e estoque'),
    ('user', 'Usuário', 'Acesso básico ao sistema')
ON CONFLICT (id) DO NOTHING;

-- Inserir permissões padrão
INSERT INTO permissions (id, name, description, category) VALUES
    ('users_view', 'Ver Usuários', 'Visualizar lista de usuários', 'usuarios'),
    ('users_create', 'Criar Usuários', 'Criar novos usuários', 'usuarios'),
    ('users_edit', 'Editar Usuários', 'Modificar dados dos usuários', 'usuarios'),
    ('users_delete', 'Excluir Usuários', 'Remover usuários do sistema', 'usuarios'),
    ('inventory_view', 'Ver Estoque', 'Visualizar produtos e estoque', 'estoque'),
    ('inventory_create', 'Criar Produtos', 'Adicionar novos produtos', 'estoque'),
    ('inventory_edit', 'Editar Produtos', 'Modificar dados dos produtos', 'estoque'),
    ('inventory_delete', 'Excluir Produtos', 'Remover produtos do sistema', 'estoque'),
    ('reports_view', 'Ver Relatórios', 'Acessar relatórios e análises', 'relatorios'),
    ('financial_view', 'Ver Financeiro', 'Acessar dados financeiros', 'financeiro'),
    ('settings_manage', 'Gerenciar Config.', 'Alterar configurações do sistema', 'sistema'),
    ('backup_manage', 'Gerenciar Backup', 'Criar e restaurar backups', 'sistema')
ON CONFLICT (id) DO NOTHING;

-- Inserir permissões padrão por cargo
INSERT INTO role_permissions (role_id, permission_id, granted) VALUES
    -- Admin - todas as permissões
    ('admin', 'users_view', true),
    ('admin', 'users_create', true),
    ('admin', 'users_edit', true),
    ('admin', 'users_delete', true),
    ('admin', 'inventory_view', true),
    ('admin', 'inventory_create', true),
    ('admin', 'inventory_edit', true),
    ('admin', 'inventory_delete', true),
    ('admin', 'reports_view', true),
    ('admin', 'financial_view', true),
    ('admin', 'settings_manage', true),
    ('admin', 'backup_manage', true),

    -- Manager - permissões limitadas
    ('manager', 'users_view', true),
    ('manager', 'users_create', false),
    ('manager', 'users_edit', false),
    ('manager', 'users_delete', false),
    ('manager', 'inventory_view', true),
    ('manager', 'inventory_create', true),
    ('manager', 'inventory_edit', true),
    ('manager', 'inventory_delete', false),
    ('manager', 'reports_view', true),
    ('manager', 'financial_view', true),
    ('manager', 'settings_manage', false),
    ('manager', 'backup_manage', false),

    -- Stock Controller - apenas estoque
    ('stock_controller', 'users_view', false),
    ('stock_controller', 'users_create', false),
    ('stock_controller', 'users_edit', false),
    ('stock_controller', 'users_delete', false),
    ('stock_controller', 'inventory_view', true),
    ('stock_controller', 'inventory_create', true),
    ('stock_controller', 'inventory_edit', true),
    ('stock_controller', 'inventory_delete', false),
    ('stock_controller', 'reports_view', false),
    ('stock_controller', 'financial_view', false),
    ('stock_controller', 'settings_manage', false),
    ('stock_controller', 'backup_manage', false),

    -- User - apenas visualização
    ('user', 'users_view', false),
    ('user', 'users_create', false),
    ('user', 'users_edit', false),
    ('user', 'users_delete', false),
    ('user', 'inventory_view', true),
    ('user', 'inventory_create', false),
    ('user', 'inventory_edit', false),
    ('user', 'inventory_delete', false),
    ('user', 'reports_view', false),
    ('user', 'financial_view', false),
    ('user', 'settings_manage', false),
    ('user', 'backup_manage', false)
ON CONFLICT (role_id, permission_id) DO NOTHING;