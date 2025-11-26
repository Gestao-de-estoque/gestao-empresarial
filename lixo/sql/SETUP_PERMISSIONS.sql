-- ==========================================
-- SCRIPT DE CRIAÇÃO DAS TABELAS DE PERMISSÕES
-- Execute este script no Supabase SQL Editor
-- ==========================================

-- 1. Criar tabela de cargos/roles
CREATE TABLE IF NOT EXISTS user_roles (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Criar tabela de permissões
CREATE TABLE IF NOT EXISTS permissions (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL DEFAULT 'sistema',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Criar tabela de relacionamento cargo-permissões
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id VARCHAR(50) REFERENCES user_roles(id) ON DELETE CASCADE,
    permission_id VARCHAR(50) REFERENCES permissions(id) ON DELETE CASCADE,
    granted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id)
);

-- 4. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission ON role_permissions(permission_id);

-- 5. Inserir cargos padrão
INSERT INTO user_roles (id, name, description, created_at, updated_at) VALUES
    ('admin', 'Administrador', 'Acesso total ao sistema', NOW(), NOW()),
    ('manager', 'Gerente', 'Acesso a relatórios e gestão', NOW(), NOW()),
    ('stock_controller', 'Controlador de Estoque', 'Gestão de produtos e estoque', NOW(), NOW()),
    ('user', 'Usuário', 'Acesso básico ao sistema', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = NOW();

-- 6. Inserir permissões padrão
INSERT INTO permissions (id, name, description, category, created_at) VALUES
    ('users_view', 'Ver Usuários', 'Visualizar lista de usuários', 'usuarios', NOW()),
    ('users_create', 'Criar Usuários', 'Criar novos usuários', 'usuarios', NOW()),
    ('users_edit', 'Editar Usuários', 'Modificar dados dos usuários', 'usuarios', NOW()),
    ('users_delete', 'Excluir Usuários', 'Remover usuários do sistema', 'usuarios', NOW()),
    ('inventory_view', 'Ver Estoque', 'Visualizar produtos e estoque', 'estoque', NOW()),
    ('inventory_create', 'Criar Produtos', 'Adicionar novos produtos', 'estoque', NOW()),
    ('inventory_edit', 'Editar Produtos', 'Modificar dados dos produtos', 'estoque', NOW()),
    ('inventory_delete', 'Excluir Produtos', 'Remover produtos do sistema', 'estoque', NOW()),
    ('reports_view', 'Ver Relatórios', 'Acessar relatórios e análises', 'relatorios', NOW()),
    ('financial_view', 'Ver Financeiro', 'Acessar dados financeiros', 'financeiro', NOW()),
    ('settings_manage', 'Gerenciar Config.', 'Alterar configurações do sistema', 'sistema', NOW()),
    ('backup_manage', 'Gerenciar Backup', 'Criar e restaurar backups', 'sistema', NOW())
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category = EXCLUDED.category;

-- 7. Inserir matriz de permissões padrão
INSERT INTO role_permissions (role_id, permission_id, granted, created_at, updated_at) VALUES
    -- ADMIN - TODAS AS PERMISSÕES
    ('admin', 'users_view', true, NOW(), NOW()),
    ('admin', 'users_create', true, NOW(), NOW()),
    ('admin', 'users_edit', true, NOW(), NOW()),
    ('admin', 'users_delete', true, NOW(), NOW()),
    ('admin', 'inventory_view', true, NOW(), NOW()),
    ('admin', 'inventory_create', true, NOW(), NOW()),
    ('admin', 'inventory_edit', true, NOW(), NOW()),
    ('admin', 'inventory_delete', true, NOW(), NOW()),
    ('admin', 'reports_view', true, NOW(), NOW()),
    ('admin', 'financial_view', true, NOW(), NOW()),
    ('admin', 'settings_manage', true, NOW(), NOW()),
    ('admin', 'backup_manage', true, NOW(), NOW()),

    -- MANAGER - PERMISSÕES LIMITADAS
    ('manager', 'users_view', true, NOW(), NOW()),
    ('manager', 'users_create', false, NOW(), NOW()),
    ('manager', 'users_edit', false, NOW(), NOW()),
    ('manager', 'users_delete', false, NOW(), NOW()),
    ('manager', 'inventory_view', true, NOW(), NOW()),
    ('manager', 'inventory_create', true, NOW(), NOW()),
    ('manager', 'inventory_edit', true, NOW(), NOW()),
    ('manager', 'inventory_delete', false, NOW(), NOW()),
    ('manager', 'reports_view', true, NOW(), NOW()),
    ('manager', 'financial_view', true, NOW(), NOW()),
    ('manager', 'settings_manage', false, NOW(), NOW()),
    ('manager', 'backup_manage', false, NOW(), NOW()),

    -- STOCK CONTROLLER - APENAS ESTOQUE
    ('stock_controller', 'users_view', false, NOW(), NOW()),
    ('stock_controller', 'users_create', false, NOW(), NOW()),
    ('stock_controller', 'users_edit', false, NOW(), NOW()),
    ('stock_controller', 'users_delete', false, NOW(), NOW()),
    ('stock_controller', 'inventory_view', true, NOW(), NOW()),
    ('stock_controller', 'inventory_create', true, NOW(), NOW()),
    ('stock_controller', 'inventory_edit', true, NOW(), NOW()),
    ('stock_controller', 'inventory_delete', false, NOW(), NOW()),
    ('stock_controller', 'reports_view', false, NOW(), NOW()),
    ('stock_controller', 'financial_view', false, NOW(), NOW()),
    ('stock_controller', 'settings_manage', false, NOW(), NOW()),
    ('stock_controller', 'backup_manage', false, NOW(), NOW()),

    -- USER - APENAS VISUALIZAÇÃO
    ('user', 'users_view', false, NOW(), NOW()),
    ('user', 'users_create', false, NOW(), NOW()),
    ('user', 'users_edit', false, NOW(), NOW()),
    ('user', 'users_delete', false, NOW(), NOW()),
    ('user', 'inventory_view', true, NOW(), NOW()),
    ('user', 'inventory_create', false, NOW(), NOW()),
    ('user', 'inventory_edit', false, NOW(), NOW()),
    ('user', 'inventory_delete', false, NOW(), NOW()),
    ('user', 'reports_view', false, NOW(), NOW()),
    ('user', 'financial_view', false, NOW(), NOW()),
    ('user', 'settings_manage', false, NOW(), NOW()),
    ('user', 'backup_manage', false, NOW(), NOW())

ON CONFLICT (role_id, permission_id) DO UPDATE SET
    granted = EXCLUDED.granted,
    updated_at = NOW();

-- 8. Adicionar coluna role na tabela admin_users se não existir
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';

-- 9. Criar índice na coluna role da tabela admin_users
CREATE INDEX IF NOT EXISTS idx_admin_users_role ON admin_users(role);

-- 10. Configurar RLS (Row Level Security) - OPCIONAL
-- Descomente as linhas abaixo se quiser habilitar RLS

-- ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Allow all for authenticated users" ON user_roles FOR ALL USING (auth.role() = 'authenticated');
-- CREATE POLICY "Allow all for authenticated users" ON permissions FOR ALL USING (auth.role() = 'authenticated');
-- CREATE POLICY "Allow all for authenticated users" ON role_permissions FOR ALL USING (auth.role() = 'authenticated');

-- ==========================================
-- VERIFICAÇÃO - Execute para confirmar
-- ==========================================

-- Verificar se as tabelas foram criadas
SELECT 'Tabelas criadas:' as status;
SELECT schemaname, tablename FROM pg_tables WHERE tablename IN ('user_roles', 'permissions', 'role_permissions');

-- Verificar dados inseridos
SELECT 'Cargos criados:' as status;
SELECT id, name FROM user_roles ORDER BY id;

SELECT 'Permissões criadas:' as status;
SELECT id, name, category FROM permissions ORDER BY category, id;

SELECT 'Total de permissões por cargo:' as status;
SELECT
    r.name as cargo,
    COUNT(CASE WHEN rp.granted = true THEN 1 END) as permissoes_ativas,
    COUNT(*) as total_permissoes
FROM user_roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
GROUP BY r.id, r.name
ORDER BY r.id;

SELECT '✅ Setup completo! Acesse /permissions no seu app.' as resultado;