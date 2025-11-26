-- ============================================================================
-- CORREÇÃO COMPLETA DO ISOLAMENTO MULTI-TENANT
-- ============================================================================
-- Este script corrige o problema de isolamento de dados entre tenants
-- Organização: GestaoZe
-- Projeto: estevamsouzalaureth@hotmail.com's Project
-- ============================================================================

-- 1. CRIAR FUNÇÕES AUXILIARES
-- ============================================================================

-- Função para obter o tenant_id atual da sessão
CREATE OR REPLACE FUNCTION get_current_tenant_id()
RETURNS UUID AS $$
BEGIN
  RETURN current_setting('app.current_tenant_id', true)::UUID;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para definir o tenant_id na sessão
CREATE OR REPLACE FUNCTION set_current_tenant(tenant_uuid UUID)
RETURNS VOID AS $$
BEGIN
  PERFORM set_config('app.current_tenant_id', tenant_uuid::TEXT, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. ADICIONAR COLUNA TENANT_ID EM TODAS AS TABELAS
-- ============================================================================

-- Tabelas de Autenticação
ALTER TABLE public.admin_users
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Tabelas de Estoque e Produtos
ALTER TABLE public.produtos
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.categorias
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.movements
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.suppliers
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Tabelas de Cardápio
ALTER TABLE public.menu_items
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.menu_item_ingredientes
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.menu_diario
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.planejamento_semanal
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Tabelas Financeiras
ALTER TABLE public.financial_data
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.daily_financial_summary
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Tabelas de Funcionários
ALTER TABLE public.employees
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.employee_bank_accounts
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.salary_configs
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.daily_payments
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.employee_attendance
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.employee_performance_metrics
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.payment_audit_log
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Tabelas de Sistema
ALTER TABLE public.logs
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.reports
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.app_settings
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.system_alerts
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Tabelas de API
ALTER TABLE public.api_keys
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.api_requests
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.api_metrics
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Tabelas de Suporte
ALTER TABLE public.support_conversations
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE public.support_messages
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE;

-- 3. CRIAR ÍNDICES PARA PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_admin_users_tenant_id ON public.admin_users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_produtos_tenant_id ON public.produtos(tenant_id);
CREATE INDEX IF NOT EXISTS idx_categorias_tenant_id ON public.categorias(tenant_id);
CREATE INDEX IF NOT EXISTS idx_movements_tenant_id ON public.movements(tenant_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_tenant_id ON public.suppliers(tenant_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_tenant_id ON public.menu_items(tenant_id);
CREATE INDEX IF NOT EXISTS idx_menu_item_ingredientes_tenant_id ON public.menu_item_ingredientes(tenant_id);
CREATE INDEX IF NOT EXISTS idx_menu_diario_tenant_id ON public.menu_diario(tenant_id);
CREATE INDEX IF NOT EXISTS idx_planejamento_semanal_tenant_id ON public.planejamento_semanal(tenant_id);
CREATE INDEX IF NOT EXISTS idx_financial_data_tenant_id ON public.financial_data(tenant_id);
CREATE INDEX IF NOT EXISTS idx_daily_financial_summary_tenant_id ON public.daily_financial_summary(tenant_id);
CREATE INDEX IF NOT EXISTS idx_employees_tenant_id ON public.employees(tenant_id);
CREATE INDEX IF NOT EXISTS idx_employee_bank_accounts_tenant_id ON public.employee_bank_accounts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_salary_configs_tenant_id ON public.salary_configs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_daily_payments_tenant_id ON public.daily_payments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_employee_attendance_tenant_id ON public.employee_attendance(tenant_id);
CREATE INDEX IF NOT EXISTS idx_employee_performance_metrics_tenant_id ON public.employee_performance_metrics(tenant_id);
CREATE INDEX IF NOT EXISTS idx_payment_audit_log_tenant_id ON public.payment_audit_log(tenant_id);
CREATE INDEX IF NOT EXISTS idx_logs_tenant_id ON public.logs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_reports_tenant_id ON public.reports(tenant_id);
CREATE INDEX IF NOT EXISTS idx_app_settings_tenant_id ON public.app_settings(tenant_id);
CREATE INDEX IF NOT EXISTS idx_system_alerts_tenant_id ON public.system_alerts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_tenant_id ON public.api_keys(tenant_id);
CREATE INDEX IF NOT EXISTS idx_api_requests_tenant_id ON public.api_requests(tenant_id);
CREATE INDEX IF NOT EXISTS idx_api_metrics_tenant_id ON public.api_metrics(tenant_id);
CREATE INDEX IF NOT EXISTS idx_support_conversations_tenant_id ON public.support_conversations(tenant_id);
CREATE INDEX IF NOT EXISTS idx_support_messages_tenant_id ON public.support_messages(tenant_id);

-- 4. HABILITAR ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_item_ingredientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_diario ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.planejamento_semanal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_financial_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salary_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_performance_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- 5. REMOVER POLÍTICAS EXISTENTES (SE HOUVER)
-- ============================================================================

DROP POLICY IF EXISTS tenant_isolation_policy ON public.admin_users;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.produtos;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.categorias;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.movements;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.suppliers;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.menu_items;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.menu_item_ingredientes;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.menu_diario;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.planejamento_semanal;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.financial_data;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.daily_financial_summary;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.employees;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.employee_bank_accounts;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.salary_configs;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.daily_payments;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.employee_attendance;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.employee_performance_metrics;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.payment_audit_log;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.logs;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.reports;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.app_settings;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.system_alerts;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.api_keys;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.api_requests;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.api_metrics;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.support_conversations;
DROP POLICY IF EXISTS tenant_isolation_policy ON public.support_messages;

-- 6. CRIAR POLÍTICAS RLS PARA ISOLAMENTO POR TENANT
-- ============================================================================

-- Política para admin_users
CREATE POLICY tenant_isolation_policy ON public.admin_users
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para produtos
CREATE POLICY tenant_isolation_policy ON public.produtos
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para categorias
CREATE POLICY tenant_isolation_policy ON public.categorias
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para movements
CREATE POLICY tenant_isolation_policy ON public.movements
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para suppliers
CREATE POLICY tenant_isolation_policy ON public.suppliers
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para menu_items
CREATE POLICY tenant_isolation_policy ON public.menu_items
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para menu_item_ingredientes
CREATE POLICY tenant_isolation_policy ON public.menu_item_ingredientes
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para menu_diario
CREATE POLICY tenant_isolation_policy ON public.menu_diario
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para planejamento_semanal
CREATE POLICY tenant_isolation_policy ON public.planejamento_semanal
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para financial_data
CREATE POLICY tenant_isolation_policy ON public.financial_data
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para daily_financial_summary
CREATE POLICY tenant_isolation_policy ON public.daily_financial_summary
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para employees
CREATE POLICY tenant_isolation_policy ON public.employees
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para employee_bank_accounts
CREATE POLICY tenant_isolation_policy ON public.employee_bank_accounts
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para salary_configs
CREATE POLICY tenant_isolation_policy ON public.salary_configs
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para daily_payments
CREATE POLICY tenant_isolation_policy ON public.daily_payments
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para employee_attendance
CREATE POLICY tenant_isolation_policy ON public.employee_attendance
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para employee_performance_metrics
CREATE POLICY tenant_isolation_policy ON public.employee_performance_metrics
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para payment_audit_log
CREATE POLICY tenant_isolation_policy ON public.payment_audit_log
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para logs
CREATE POLICY tenant_isolation_policy ON public.logs
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para reports
CREATE POLICY tenant_isolation_policy ON public.reports
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para app_settings
CREATE POLICY tenant_isolation_policy ON public.app_settings
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para system_alerts
CREATE POLICY tenant_isolation_policy ON public.system_alerts
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para api_keys
CREATE POLICY tenant_isolation_policy ON public.api_keys
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para api_requests
CREATE POLICY tenant_isolation_policy ON public.api_requests
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para api_metrics
CREATE POLICY tenant_isolation_policy ON public.api_metrics
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para support_conversations
CREATE POLICY tenant_isolation_policy ON public.support_conversations
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- Política para support_messages
CREATE POLICY tenant_isolation_policy ON public.support_messages
  FOR ALL
  USING (tenant_id = get_current_tenant_id() OR tenant_id IS NULL);

-- 7. CRIAR TRIGGERS PARA AUTO-POPULAR TENANT_ID
-- ============================================================================

-- Função genérica para preencher tenant_id automaticamente
CREATE OR REPLACE FUNCTION auto_set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := get_current_tenant_id();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar triggers em todas as tabelas
DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.produtos;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.produtos
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.categorias;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.categorias
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.movements;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.movements
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.suppliers;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.suppliers
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.menu_items;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.menu_items
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.menu_item_ingredientes;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.menu_item_ingredientes
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.menu_diario;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.menu_diario
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.planejamento_semanal;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.planejamento_semanal
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.financial_data;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.financial_data
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.daily_financial_summary;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.daily_financial_summary
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.employees;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.employees
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.employee_bank_accounts;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.employee_bank_accounts
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.salary_configs;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.salary_configs
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.daily_payments;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.daily_payments
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.employee_attendance;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.employee_attendance
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.employee_performance_metrics;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.employee_performance_metrics
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.payment_audit_log;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.payment_audit_log
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.logs;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.logs
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.reports;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.reports
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.app_settings;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.app_settings
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.system_alerts;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.system_alerts
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.api_keys;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.api_keys
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.api_requests;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.api_requests
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.api_metrics;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.api_metrics
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.support_conversations;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.support_conversations
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.support_messages;
CREATE TRIGGER set_tenant_id_trigger
  BEFORE INSERT ON public.support_messages
  FOR EACH ROW EXECUTE FUNCTION auto_set_tenant_id();

-- ============================================================================
-- SCRIPT CONCLUÍDO
-- ============================================================================
-- Próximos passos:
-- 1. Execute este script no SQL Editor do Supabase Dashboard
-- 2. Verifique se o authService.ts está configurando o tenant_id no login
-- 3. Verifique se o registrationService.ts está associando o tenant_id ao criar usuários
-- 4. Teste criando uma nova conta e verificando o isolamento de dados
-- ============================================================================
