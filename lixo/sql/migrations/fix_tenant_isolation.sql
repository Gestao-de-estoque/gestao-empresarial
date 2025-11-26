-- ============================================================================
-- MIGRAÇÃO: Correção de Isolamento de Dados por Tenant
-- Data: 2025-11-26
-- Descrição: Adiciona tenant_id e políticas RLS para garantir isolamento
-- ============================================================================

-- ============================================================================
-- PARTE 1: HABILITAR RLS E ADICIONAR COLUNAS tenant_id
-- ============================================================================

-- Habilitar extensão necessária para RLS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- TABELA: categorias
-- ============================================================================
ALTER TABLE public.categorias
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_categorias_tenant_id ON public.categorias(tenant_id);

-- Habilitar RLS
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;

-- Política para SELECT: usuário só vê categorias do seu tenant
CREATE POLICY categorias_tenant_isolation_select ON public.categorias
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- Política para INSERT: usuário só pode inserir no seu tenant
CREATE POLICY categorias_tenant_isolation_insert ON public.categorias
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- Política para UPDATE: usuário só pode atualizar do seu tenant
CREATE POLICY categorias_tenant_isolation_update ON public.categorias
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- Política para DELETE: usuário só pode deletar do seu tenant
CREATE POLICY categorias_tenant_isolation_delete ON public.categorias
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: produtos
-- ============================================================================
ALTER TABLE public.produtos
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_produtos_tenant_id ON public.produtos(tenant_id);

ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;

CREATE POLICY produtos_tenant_isolation_select ON public.produtos
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY produtos_tenant_isolation_insert ON public.produtos
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY produtos_tenant_isolation_update ON public.produtos
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY produtos_tenant_isolation_delete ON public.produtos
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: menu_items
-- ============================================================================
ALTER TABLE public.menu_items
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_menu_items_tenant_id ON public.menu_items(tenant_id);

ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY menu_items_tenant_isolation_select ON public.menu_items
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_items_tenant_isolation_insert ON public.menu_items
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_items_tenant_isolation_update ON public.menu_items
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_items_tenant_isolation_delete ON public.menu_items
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: menu_item_ingredientes
-- ============================================================================
ALTER TABLE public.menu_item_ingredientes
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_menu_item_ingredientes_tenant_id ON public.menu_item_ingredientes(tenant_id);

ALTER TABLE public.menu_item_ingredientes ENABLE ROW LEVEL SECURITY;

CREATE POLICY menu_item_ingredientes_tenant_isolation_select ON public.menu_item_ingredientes
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_item_ingredientes_tenant_isolation_insert ON public.menu_item_ingredientes
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_item_ingredientes_tenant_isolation_update ON public.menu_item_ingredientes
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_item_ingredientes_tenant_isolation_delete ON public.menu_item_ingredientes
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: planejamento_semanal
-- ============================================================================
ALTER TABLE public.planejamento_semanal
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_planejamento_semanal_tenant_id ON public.planejamento_semanal(tenant_id);

ALTER TABLE public.planejamento_semanal ENABLE ROW LEVEL SECURITY;

CREATE POLICY planejamento_semanal_tenant_isolation_select ON public.planejamento_semanal
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY planejamento_semanal_tenant_isolation_insert ON public.planejamento_semanal
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY planejamento_semanal_tenant_isolation_update ON public.planejamento_semanal
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY planejamento_semanal_tenant_isolation_delete ON public.planejamento_semanal
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: menu_diario
-- ============================================================================
ALTER TABLE public.menu_diario
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_menu_diario_tenant_id ON public.menu_diario(tenant_id);

ALTER TABLE public.menu_diario ENABLE ROW LEVEL SECURITY;

CREATE POLICY menu_diario_tenant_isolation_select ON public.menu_diario
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_diario_tenant_isolation_insert ON public.menu_diario
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_diario_tenant_isolation_update ON public.menu_diario
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY menu_diario_tenant_isolation_delete ON public.menu_diario
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: movements
-- ============================================================================
ALTER TABLE public.movements
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_movements_tenant_id ON public.movements(tenant_id);

ALTER TABLE public.movements ENABLE ROW LEVEL SECURITY;

CREATE POLICY movements_tenant_isolation_select ON public.movements
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY movements_tenant_isolation_insert ON public.movements
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY movements_tenant_isolation_update ON public.movements
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY movements_tenant_isolation_delete ON public.movements
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: employees
-- ============================================================================
ALTER TABLE public.employees
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_employees_tenant_id ON public.employees(tenant_id);

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

CREATE POLICY employees_tenant_isolation_select ON public.employees
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employees_tenant_isolation_insert ON public.employees
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employees_tenant_isolation_update ON public.employees
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employees_tenant_isolation_delete ON public.employees
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: daily_payments
-- ============================================================================
ALTER TABLE public.daily_payments
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_daily_payments_tenant_id ON public.daily_payments(tenant_id);

ALTER TABLE public.daily_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY daily_payments_tenant_isolation_select ON public.daily_payments
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY daily_payments_tenant_isolation_insert ON public.daily_payments
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY daily_payments_tenant_isolation_update ON public.daily_payments
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY daily_payments_tenant_isolation_delete ON public.daily_payments
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: employee_attendance
-- ============================================================================
ALTER TABLE public.employee_attendance
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_employee_attendance_tenant_id ON public.employee_attendance(tenant_id);

ALTER TABLE public.employee_attendance ENABLE ROW LEVEL SECURITY;

CREATE POLICY employee_attendance_tenant_isolation_select ON public.employee_attendance
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_attendance_tenant_isolation_insert ON public.employee_attendance
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_attendance_tenant_isolation_update ON public.employee_attendance
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_attendance_tenant_isolation_delete ON public.employee_attendance
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: employee_bank_accounts
-- ============================================================================
ALTER TABLE public.employee_bank_accounts
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_employee_bank_accounts_tenant_id ON public.employee_bank_accounts(tenant_id);

ALTER TABLE public.employee_bank_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY employee_bank_accounts_tenant_isolation_select ON public.employee_bank_accounts
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_bank_accounts_tenant_isolation_insert ON public.employee_bank_accounts
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_bank_accounts_tenant_isolation_update ON public.employee_bank_accounts
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_bank_accounts_tenant_isolation_delete ON public.employee_bank_accounts
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: employee_performance_metrics
-- ============================================================================
ALTER TABLE public.employee_performance_metrics
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_employee_performance_metrics_tenant_id ON public.employee_performance_metrics(tenant_id);

ALTER TABLE public.employee_performance_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY employee_performance_metrics_tenant_isolation_select ON public.employee_performance_metrics
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_performance_metrics_tenant_isolation_insert ON public.employee_performance_metrics
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_performance_metrics_tenant_isolation_update ON public.employee_performance_metrics
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY employee_performance_metrics_tenant_isolation_delete ON public.employee_performance_metrics
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: salary_configs
-- ============================================================================
ALTER TABLE public.salary_configs
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_salary_configs_tenant_id ON public.salary_configs(tenant_id);

ALTER TABLE public.salary_configs ENABLE ROW LEVEL SECURITY;

CREATE POLICY salary_configs_tenant_isolation_select ON public.salary_configs
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY salary_configs_tenant_isolation_insert ON public.salary_configs
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY salary_configs_tenant_isolation_update ON public.salary_configs
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY salary_configs_tenant_isolation_delete ON public.salary_configs
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: payment_audit_log
-- ============================================================================
ALTER TABLE public.payment_audit_log
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_payment_audit_log_tenant_id ON public.payment_audit_log(tenant_id);

ALTER TABLE public.payment_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY payment_audit_log_tenant_isolation_select ON public.payment_audit_log
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY payment_audit_log_tenant_isolation_insert ON public.payment_audit_log
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY payment_audit_log_tenant_isolation_update ON public.payment_audit_log
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY payment_audit_log_tenant_isolation_delete ON public.payment_audit_log
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: financial_data
-- ============================================================================
ALTER TABLE public.financial_data
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_financial_data_tenant_id ON public.financial_data(tenant_id);

ALTER TABLE public.financial_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY financial_data_tenant_isolation_select ON public.financial_data
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY financial_data_tenant_isolation_insert ON public.financial_data
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY financial_data_tenant_isolation_update ON public.financial_data
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY financial_data_tenant_isolation_delete ON public.financial_data
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: daily_financial_summary
-- ============================================================================
ALTER TABLE public.daily_financial_summary
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_daily_financial_summary_tenant_id ON public.daily_financial_summary(tenant_id);

ALTER TABLE public.daily_financial_summary ENABLE ROW LEVEL SECURITY;

CREATE POLICY daily_financial_summary_tenant_isolation_select ON public.daily_financial_summary
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY daily_financial_summary_tenant_isolation_insert ON public.daily_financial_summary
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY daily_financial_summary_tenant_isolation_update ON public.daily_financial_summary
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY daily_financial_summary_tenant_isolation_delete ON public.daily_financial_summary
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: reports
-- ============================================================================
ALTER TABLE public.reports
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_reports_tenant_id ON public.reports(tenant_id);

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY reports_tenant_isolation_select ON public.reports
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY reports_tenant_isolation_insert ON public.reports
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY reports_tenant_isolation_update ON public.reports
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY reports_tenant_isolation_delete ON public.reports
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: app_settings
-- ============================================================================
ALTER TABLE public.app_settings
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_app_settings_tenant_id ON public.app_settings(tenant_id);

ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY app_settings_tenant_isolation_select ON public.app_settings
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY app_settings_tenant_isolation_insert ON public.app_settings
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY app_settings_tenant_isolation_update ON public.app_settings
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY app_settings_tenant_isolation_delete ON public.app_settings
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- TABELA: suppliers (se for específico por tenant)
-- ============================================================================
ALTER TABLE public.suppliers
ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_suppliers_tenant_id ON public.suppliers(tenant_id);

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

CREATE POLICY suppliers_tenant_isolation_select ON public.suppliers
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY suppliers_tenant_isolation_insert ON public.suppliers
  FOR INSERT
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY suppliers_tenant_isolation_update ON public.suppliers
  FOR UPDATE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY suppliers_tenant_isolation_delete ON public.suppliers
  FOR DELETE
  USING (
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- ============================================================================
-- PARTE 2: ATUALIZAR CONSTRAINT UNIQUE CONSIDERANDO tenant_id
-- ============================================================================

-- Remover constraint unique antiga de salary_configs.position e criar nova com tenant_id
ALTER TABLE public.salary_configs DROP CONSTRAINT IF EXISTS salary_configs_position_key;
CREATE UNIQUE INDEX IF NOT EXISTS salary_configs_position_tenant_unique
  ON public.salary_configs(position, tenant_id);

-- Remover constraint unique antiga de categorias.nome e criar nova com tenant_id
ALTER TABLE public.categorias DROP CONSTRAINT IF EXISTS categorias_nome_key;
CREATE UNIQUE INDEX IF NOT EXISTS categorias_nome_tenant_unique
  ON public.categorias(nome, tenant_id);

-- ============================================================================
-- PARTE 3: ADICIONAR CONSTRAINTS NOT NULL (após migração de dados)
-- ============================================================================

-- NOTA: Estas constraints devem ser adicionadas APÓS a migração de dados existentes
-- Descomente estas linhas após executar o script de correção de dados:

-- ALTER TABLE public.categorias ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.produtos ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.menu_items ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.menu_item_ingredientes ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.planejamento_semanal ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.menu_diario ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.movements ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.employees ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.daily_payments ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.employee_attendance ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.employee_bank_accounts ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.employee_performance_metrics ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.salary_configs ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.payment_audit_log ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.financial_data ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.daily_financial_summary ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.reports ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.app_settings ALTER COLUMN tenant_id SET NOT NULL;
-- ALTER TABLE public.suppliers ALTER COLUMN tenant_id SET NOT NULL;

-- ============================================================================
-- PARTE 4: FUNÇÕES AUXILIARES PARA OBTER tenant_id DO USUÁRIO ATUAL
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tenant_id uuid;
BEGIN
  SELECT tenant_id INTO v_tenant_id
  FROM public.tenant_users
  WHERE admin_user_id = auth.uid()
    AND is_active = true
  LIMIT 1;

  RETURN v_tenant_id;
END;
$$;

-- Função para validar se o usuário pertence a um tenant
CREATE OR REPLACE FUNCTION public.user_belongs_to_tenant(p_tenant_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.tenant_users
    WHERE admin_user_id = auth.uid()
      AND tenant_id = p_tenant_id
      AND is_active = true
  );
END;
$$;

-- ============================================================================
-- PARTE 5: TRIGGERS PARA AUTO-PREENCHER tenant_id
-- ============================================================================

-- Função genérica para auto-preencher tenant_id
CREATE OR REPLACE FUNCTION public.auto_set_tenant_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := public.get_user_tenant_id();
  END IF;
  RETURN NEW;
END;
$$;

-- Criar triggers para todas as tabelas
CREATE TRIGGER set_tenant_id_on_categorias
  BEFORE INSERT ON public.categorias
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_produtos
  BEFORE INSERT ON public.produtos
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_menu_items
  BEFORE INSERT ON public.menu_items
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_menu_item_ingredientes
  BEFORE INSERT ON public.menu_item_ingredientes
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_planejamento_semanal
  BEFORE INSERT ON public.planejamento_semanal
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_menu_diario
  BEFORE INSERT ON public.menu_diario
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_movements
  BEFORE INSERT ON public.movements
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_employees
  BEFORE INSERT ON public.employees
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_daily_payments
  BEFORE INSERT ON public.daily_payments
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_employee_attendance
  BEFORE INSERT ON public.employee_attendance
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_employee_bank_accounts
  BEFORE INSERT ON public.employee_bank_accounts
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_employee_performance_metrics
  BEFORE INSERT ON public.employee_performance_metrics
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_salary_configs
  BEFORE INSERT ON public.salary_configs
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_payment_audit_log
  BEFORE INSERT ON public.payment_audit_log
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_financial_data
  BEFORE INSERT ON public.financial_data
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_daily_financial_summary
  BEFORE INSERT ON public.daily_financial_summary
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_reports
  BEFORE INSERT ON public.reports
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_app_settings
  BEFORE INSERT ON public.app_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

CREATE TRIGGER set_tenant_id_on_suppliers
  BEFORE INSERT ON public.suppliers
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_set_tenant_id();

-- ============================================================================
-- FIM DA MIGRAÇÃO
-- ============================================================================

-- Após executar esta migração:
-- 1. Execute o script fix_existing_data.sql para corrigir dados existentes
-- 2. Descomente as constraints NOT NULL na PARTE 3
-- 3. Teste todas as funcionalidades do sistema
-- 4. Monitore os logs para garantir que RLS está funcionando corretamente
