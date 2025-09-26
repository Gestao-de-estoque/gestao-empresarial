-- ==========================================
-- SCRIPT COMPLETO DE SETUP DO SISTEMA
-- Execute este script no Supabase SQL Editor
-- Inclui: Permissões + API Management
-- ==========================================

-- ==========================================
-- 1. SISTEMA DE PERMISSÕES
-- ==========================================

-- Criar tabela de cargos/roles
CREATE TABLE IF NOT EXISTS user_roles (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de permissões
CREATE TABLE IF NOT EXISTS permissions (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL DEFAULT 'sistema',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de relacionamento cargo-permissões
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id VARCHAR(50) REFERENCES user_roles(id) ON DELETE CASCADE,
    permission_id VARCHAR(50) REFERENCES permissions(id) ON DELETE CASCADE,
    granted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id)
);

-- ==========================================
-- 2. SISTEMA DE API MANAGEMENT
-- ==========================================

-- Criar tabela de chaves de API
CREATE TABLE IF NOT EXISTS api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    key VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP WITH TIME ZONE,
    request_count INTEGER DEFAULT 0,
    rate_limit INTEGER DEFAULT 1000,
    allowed_origins JSONB DEFAULT '[]'::jsonb,
    permissions JSONB DEFAULT '["read"]'::jsonb
);

-- Criar tabela de requisições da API
CREATE TABLE IF NOT EXISTS api_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    api_key_id UUID REFERENCES api_keys(id) ON DELETE CASCADE,
    method VARCHAR(10) NOT NULL,
    endpoint VARCHAR(500) NOT NULL,
    status_code INTEGER NOT NULL,
    response_time INTEGER DEFAULT 0,
    ip_address INET,
    user_agent TEXT,
    request_body JSONB,
    response_body JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de métricas da API
CREATE TABLE IF NOT EXISTS api_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    api_key_id UUID REFERENCES api_keys(id) ON DELETE CASCADE,
    date_hour TIMESTAMP WITH TIME ZONE NOT NULL,
    request_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    avg_response_time INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(api_key_id, date_hour)
);

-- ==========================================
-- 3. ÍNDICES PARA PERFORMANCE
-- ==========================================

-- Índices das permissões
CREATE INDEX IF NOT EXISTS idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission ON role_permissions(permission_id);

-- Índices da API
CREATE INDEX IF NOT EXISTS idx_api_keys_status ON api_keys(status);
CREATE INDEX IF NOT EXISTS idx_api_keys_key ON api_keys(key);
CREATE INDEX IF NOT EXISTS idx_api_requests_api_key_id ON api_requests(api_key_id);
CREATE INDEX IF NOT EXISTS idx_api_requests_created_at ON api_requests(created_at);
CREATE INDEX IF NOT EXISTS idx_api_requests_status_code ON api_requests(status_code);
CREATE INDEX IF NOT EXISTS idx_api_metrics_api_key_id ON api_metrics(api_key_id);
CREATE INDEX IF NOT EXISTS idx_api_metrics_date_hour ON api_metrics(date_hour);

-- ==========================================
-- 4. FUNÇÕES E TRIGGERS
-- ==========================================

-- Função para incrementar contador de requisições da API
CREATE OR REPLACE FUNCTION increment_api_key_requests(key_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE api_keys
    SET
        request_count = request_count + 1,
        last_used = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = key_id;
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para user_roles
CREATE TRIGGER update_user_roles_updated_at
    BEFORE UPDATE ON user_roles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para role_permissions
CREATE TRIGGER update_role_permissions_updated_at
    BEFORE UPDATE ON role_permissions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para api_keys
CREATE TRIGGER update_api_keys_updated_at
    BEFORE UPDATE ON api_keys
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- 5. DADOS PADRÃO - PERMISSÕES
-- ==========================================

-- Inserir cargos padrão
INSERT INTO user_roles (id, name, description, created_at, updated_at) VALUES
    ('admin', 'Administrador', 'Acesso total ao sistema', NOW(), NOW()),
    ('manager', 'Gerente', 'Acesso a relatórios e gestão', NOW(), NOW()),
    ('stock_controller', 'Controlador de Estoque', 'Gestão de produtos e estoque', NOW(), NOW()),
    ('user', 'Usuário', 'Acesso básico ao sistema', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Inserir permissões padrão
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

-- Inserir matriz de permissões padrão
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
    ('manager', 'inventory_view', true, NOW(), NOW()),
    ('manager', 'inventory_create', true, NOW(), NOW()),
    ('manager', 'inventory_edit', true, NOW(), NOW()),
    ('manager', 'reports_view', true, NOW(), NOW()),
    ('manager', 'financial_view', true, NOW(), NOW()),

    -- STOCK CONTROLLER - APENAS ESTOQUE
    ('stock_controller', 'inventory_view', true, NOW(), NOW()),
    ('stock_controller', 'inventory_create', true, NOW(), NOW()),
    ('stock_controller', 'inventory_edit', true, NOW(), NOW()),

    -- USER - APENAS VISUALIZAÇÃO
    ('user', 'inventory_view', true, NOW(), NOW())

ON CONFLICT (role_id, permission_id) DO UPDATE SET
    granted = EXCLUDED.granted,
    updated_at = NOW();

-- ==========================================
-- 6. DADOS PADRÃO - API MANAGEMENT
-- ==========================================

-- Inserir chaves de API de exemplo
INSERT INTO api_keys (name, key, description, status, request_count, rate_limit, permissions) VALUES
    ('Integração Principal', 'gzs_' || extract(epoch from now())::bigint::text || '_main_integration', 'Chave principal para integração com o sistema', 'active', 0, 5000, '["read", "write", "admin"]'::jsonb),
    ('App Mobile', 'gzs_' || (extract(epoch from now())::bigint + 1)::text || '_mobile_app', 'Chave para aplicativo mobile iOS e Android', 'active', 0, 1000, '["read", "write"]'::jsonb),
    ('Webhooks', 'gzs_' || (extract(epoch from now())::bigint + 2)::text || '_webhook_handler', 'Chave para receber webhooks de pagamentos', 'active', 0, 500, '["webhook"]'::jsonb),
    ('Dashboard Analytics', 'gzs_' || (extract(epoch from now())::bigint + 3)::text || '_analytics', 'Chave para dashboard de analytics', 'inactive', 0, 200, '["read"]'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- Inserir logs de exemplo das últimas 24 horas
DO $$
DECLARE
    key_record RECORD;
    log_timestamp TIMESTAMP WITH TIME ZONE;
    i INTEGER;
    methods TEXT[] := ARRAY['GET', 'POST', 'PUT', 'DELETE'];
    endpoints TEXT[] := ARRAY['/api/v1/products', '/api/v1/orders', '/api/v1/inventory', '/api/v1/users', '/api/v1/reports', '/api/v1/auth', '/api/v1/dashboard', '/api/v1/categories'];
    status_codes INTEGER[] := ARRAY[200, 201, 200, 200, 400, 401, 404, 500, 200];
BEGIN
    -- Para cada chave ativa, criar logs de exemplo
    FOR key_record IN SELECT id FROM api_keys WHERE status = 'active' LOOP
        FOR i IN 1..15 LOOP
            log_timestamp := CURRENT_TIMESTAMP - (random() * INTERVAL '24 hours');

            INSERT INTO api_requests (
                api_key_id,
                method,
                endpoint,
                status_code,
                response_time,
                ip_address,
                user_agent,
                created_at
            ) VALUES (
                key_record.id,
                methods[ceil(random() * array_length(methods, 1))],
                endpoints[ceil(random() * array_length(endpoints, 1))],
                status_codes[ceil(random() * array_length(status_codes, 1))],
                (random() * 500 + 50)::INTEGER,
                ('192.168.1.' || ceil(random() * 254)::text)::INET,
                'GestaoZe-System/1.0 (Compatible)',
                log_timestamp
            );
        END LOOP;
    END LOOP;
END;
$$;

-- Atualizar contadores das chaves baseado nos logs
UPDATE api_keys
SET request_count = (
    SELECT COALESCE(COUNT(*), 0)
    FROM api_requests
    WHERE api_requests.api_key_id = api_keys.id
);

-- Adicionar coluna role na tabela admin_users se não existir
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';

-- Criar índice na coluna role da tabela admin_users
CREATE INDEX IF NOT EXISTS idx_admin_users_role ON admin_users(role);

-- ==========================================
-- 7. VERIFICAÇÃO FINAL
-- ==========================================

-- Verificar se as tabelas foram criadas
SELECT 'TABELAS CRIADAS:' as status;
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename IN ('user_roles', 'permissions', 'role_permissions', 'api_keys', 'api_requests', 'api_metrics')
ORDER BY tablename;

-- Verificar dados das permissões
SELECT 'CARGOS CRIADOS:' as status;
SELECT id, name, description FROM user_roles ORDER BY id;

SELECT 'PERMISSÕES CRIADAS:' as status;
SELECT category, COUNT(*) as total FROM permissions GROUP BY category ORDER BY category;

SELECT 'MATRIZ DE PERMISSÕES:' as status;
SELECT
    r.name as cargo,
    COUNT(CASE WHEN rp.granted = true THEN 1 END) as permissoes_ativas,
    COUNT(*) as total_permissoes
FROM user_roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
GROUP BY r.id, r.name
ORDER BY r.id;

-- Verificar dados da API
SELECT 'CHAVES API CRIADAS:' as status;
SELECT name, status, request_count, rate_limit FROM api_keys ORDER BY created_at;

SELECT 'LOGS DA API:' as status;
SELECT method, COUNT(*) as total FROM api_requests GROUP BY method ORDER BY total DESC;

SELECT 'REQUESTS NAS ÚLTIMAS 24H:' as status;
SELECT COUNT(*) as total_requests
FROM api_requests
WHERE created_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours';

SELECT '🎉 SETUP COMPLETO!' as resultado;
SELECT '✅ Sistema de Permissões: /permissions' as acesso_1;
SELECT '✅ Sistema de API: /api' as acesso_2;
SELECT '📚 Documentação: /doc' as acesso_3;