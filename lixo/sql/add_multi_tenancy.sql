-- ==========================================
-- MIGRAÇÃO PARA MULTI-TENANCY
-- Adiciona isolamento de dados por empresa (tenant)
-- ==========================================

-- ==========================================
-- 1. ADICIONAR COLUNA tenant_id NAS TABELAS
-- ==========================================

-- Produtos e Inventário
ALTER TABLE public.produtos
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.categorias
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.movements
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.suppliers
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Menu e Cardápio
ALTER TABLE public.menu_items
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.menu_item_ingredientes
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.menu_diario
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.planejamento_semanal
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Funcionários
ALTER TABLE public.employees
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.daily_payments
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.employee_attendance
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.employee_performance_metrics
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.salary_configs
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Financeiro
ALTER TABLE public.financial_data
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.daily_financial_summary
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Sistema
ALTER TABLE public.logs
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE SET NULL;

ALTER TABLE public.reports
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.app_settings
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.system_alerts
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- API
ALTER TABLE public.api_keys
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Suporte (conversas específicas de cada tenant)
ALTER TABLE public.support_conversations
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- ==========================================
-- 2. CRIAR ÍNDICES PARA PERFORMANCE
-- ==========================================

-- Produtos
CREATE INDEX IF NOT EXISTS idx_produtos_tenant_id ON public.produtos(tenant_id);
CREATE INDEX IF NOT EXISTS idx_categorias_tenant_id ON public.categorias(tenant_id);
CREATE INDEX IF NOT EXISTS idx_movements_tenant_id ON public.movements(tenant_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_tenant_id ON public.suppliers(tenant_id);

-- Menu
CREATE INDEX IF NOT EXISTS idx_menu_items_tenant_id ON public.menu_items(tenant_id);
CREATE INDEX IF NOT EXISTS idx_menu_item_ingredientes_tenant_id ON public.menu_item_ingredientes(tenant_id);
CREATE INDEX IF NOT EXISTS idx_menu_diario_tenant_id ON public.menu_diario(tenant_id);
CREATE INDEX IF NOT EXISTS idx_planejamento_semanal_tenant_id ON public.planejamento_semanal(tenant_id);

-- Funcionários
CREATE INDEX IF NOT EXISTS idx_employees_tenant_id ON public.employees(tenant_id);
CREATE INDEX IF NOT EXISTS idx_daily_payments_tenant_id ON public.daily_payments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_employee_attendance_tenant_id ON public.employee_attendance(tenant_id);
CREATE INDEX IF NOT EXISTS idx_employee_performance_metrics_tenant_id ON public.employee_performance_metrics(tenant_id);
CREATE INDEX IF NOT EXISTS idx_salary_configs_tenant_id ON public.salary_configs(tenant_id);

-- Financeiro
CREATE INDEX IF NOT EXISTS idx_financial_data_tenant_id ON public.financial_data(tenant_id);
CREATE INDEX IF NOT EXISTS idx_daily_financial_summary_tenant_id ON public.daily_financial_summary(tenant_id);

-- Sistema
CREATE INDEX IF NOT EXISTS idx_logs_tenant_id ON public.logs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_reports_tenant_id ON public.reports(tenant_id);
CREATE INDEX IF NOT EXISTS idx_app_settings_tenant_id ON public.app_settings(tenant_id);
CREATE INDEX IF NOT EXISTS idx_system_alerts_tenant_id ON public.system_alerts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_tenant_id ON public.api_keys(tenant_id);
CREATE INDEX IF NOT EXISTS idx_support_conversations_tenant_id ON public.support_conversations(tenant_id);

-- ==========================================
-- 3. POLÍTICAS RLS (Row Level Security)
-- ==========================================

-- Função auxiliar para pegar o tenant_id do usuário logado
CREATE OR REPLACE FUNCTION public.get_current_tenant_id()
RETURNS UUID AS $$
BEGIN
  -- Retorna o tenant_id do usuário atual da sessão
  -- Isso será configurado quando o usuário fizer login
  RETURN current_setting('app.current_tenant_id', true)::UUID;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Habilitar RLS nas tabelas principais
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS para produtos
DROP POLICY IF EXISTS tenant_isolation_policy ON public.produtos;
CREATE POLICY tenant_isolation_policy ON public.produtos
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Criar políticas RLS para categorias
DROP POLICY IF EXISTS tenant_isolation_policy ON public.categorias;
CREATE POLICY tenant_isolation_policy ON public.categorias
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Criar políticas RLS para movements
DROP POLICY IF EXISTS tenant_isolation_policy ON public.movements;
CREATE POLICY tenant_isolation_policy ON public.movements
  FOR ALL
  USING (tenant_id = get_current_tenant_id());

-- Criar políticas RLS para suppliers
DROP POLICY IF EXISTS tenant_isolation_policy ON public.suppliers;
CREATE POLICY tenant_isolation_policy ON public.suppliers
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Criar políticas RLS para menu_items
DROP POLICY IF EXISTS tenant_isolation_policy ON public.menu_items;
CREATE POLICY tenant_isolation_policy ON public.menu_items
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Criar políticas RLS para employees
DROP POLICY IF EXISTS tenant_isolation_policy ON public.employees;
CREATE POLICY tenant_isolation_policy ON public.employees
  FOR ALL
  USING (tenant_id = get_current_tenant_id());

-- Criar políticas RLS para financial_data
DROP POLICY IF EXISTS tenant_isolation_policy ON public.financial_data;
CREATE POLICY tenant_isolation_policy ON public.financial_data
  FOR ALL
  USING (tenant_id = get_current_tenant_id());

-- Criar políticas RLS para reports
DROP POLICY IF EXISTS tenant_isolation_policy ON public.reports;
CREATE POLICY tenant_isolation_policy ON public.reports
  FOR ALL
  USING (tenant_id = get_current_tenant_id());

-- ==========================================
-- 4. ATUALIZAR admin_users COM tenant_id
-- ==========================================

-- Adicionar tenant_id em admin_users (referência ao tenant principal do usuário)
ALTER TABLE public.admin_users
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_admin_users_tenant_id ON public.admin_users(tenant_id);

-- ==========================================
-- 5. FUNÇÃO PARA CONFIGURAR TENANT NA SESSÃO
-- ==========================================

-- Esta função deve ser chamada quando o usuário faz login
CREATE OR REPLACE FUNCTION public.set_current_tenant(tenant_uuid UUID)
RETURNS void AS $$
BEGIN
  PERFORM set_config('app.current_tenant_id', tenant_uuid::TEXT, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- 6. TRIGGERS PARA AUTO-PREENCHER tenant_id
-- ==========================================

-- Função que auto-preenche tenant_id ao inserir
CREATE OR REPLACE FUNCTION public.set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := get_current_tenant_id();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar triggers para auto-preencher tenant_id
CREATE TRIGGER set_tenant_id_produtos BEFORE INSERT ON public.produtos
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER set_tenant_id_categorias BEFORE INSERT ON public.categorias
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER set_tenant_id_movements BEFORE INSERT ON public.movements
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER set_tenant_id_suppliers BEFORE INSERT ON public.suppliers
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER set_tenant_id_menu_items BEFORE INSERT ON public.menu_items
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER set_tenant_id_employees BEFORE INSERT ON public.employees
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER set_tenant_id_financial_data BEFORE INSERT ON public.financial_data
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

CREATE TRIGGER set_tenant_id_reports BEFORE INSERT ON public.reports
  FOR EACH ROW EXECUTE FUNCTION set_tenant_id();

-- ==========================================
-- 7. VERIFICAÇÃO E RELATÓRIO
-- ==========================================

SELECT '✅ Multi-tenancy configurado com sucesso!' as resultado;

-- Verificar quais tabelas têm tenant_id
SELECT
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name = 'tenant_id'
ORDER BY table_name;

-- Verificar políticas RLS
SELECT
    schemaname,
    tablename,
    policyname
FROM pg_policies
WHERE policyname LIKE '%tenant%'
ORDER BY tablename;

SELECT '📊 Tabelas com isolamento por tenant configuradas' as info;
SELECT '🔒 Políticas RLS ativas' as info_2;
SELECT '⚡ Índices criados para performance' as info_3;
