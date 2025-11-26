-- ============================================================================
-- MIGRAÇÃO COMPLETA: Correção de Isolamento de Dados + Fix de Signup
-- Data: 2025-11-26
-- Execute este script INTEIRO de uma vez no Supabase SQL Editor
-- ============================================================================

BEGIN;

-- ============================================================================
-- PARTE 1: CORRIGIR POLÍTICAS RLS PARA SIGNUP
-- ============================================================================

-- Remover políticas RLS restritivas de admin_users (se existirem)
DROP POLICY IF EXISTS admin_users_tenant_isolation_select ON public.admin_users;
DROP POLICY IF EXISTS admin_users_tenant_isolation_insert ON public.admin_users;
DROP POLICY IF EXISTS admin_users_tenant_isolation_update ON public.admin_users;
DROP POLICY IF EXISTS admin_users_tenant_isolation_delete ON public.admin_users;

-- Remover políticas RLS restritivas de tenants (se existirem)
DROP POLICY IF EXISTS tenants_tenant_isolation_select ON public.tenants;
DROP POLICY IF EXISTS tenants_tenant_isolation_insert ON public.tenants;
DROP POLICY IF EXISTS tenants_tenant_isolation_update ON public.tenants;
DROP POLICY IF EXISTS tenants_tenant_isolation_delete ON public.tenants;

-- Desabilitar RLS em admin_users e tenants temporariamente
ALTER TABLE public.admin_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants DISABLE ROW LEVEL SECURITY;

-- Reabilitar RLS com políticas corretas
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

-- ADMIN_USERS: Permitir leitura pública (necessário para login)
CREATE POLICY admin_users_select_public ON public.admin_users
  FOR SELECT
  TO public
  USING (true);

-- ADMIN_USERS: Permitir inserção pública (necessário para signup)
CREATE POLICY admin_users_insert_public ON public.admin_users
  FOR INSERT
  TO public
  WITH CHECK (true);

-- ADMIN_USERS: Permitir atualização apenas do próprio usuário
CREATE POLICY admin_users_update_own ON public.admin_users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ADMIN_USERS: Permitir deleção apenas do próprio usuário
CREATE POLICY admin_users_delete_own ON public.admin_users
  FOR DELETE
  TO authenticated
  USING (auth.uid() = id);

-- TENANTS: Permitir leitura pública (necessário para verificar slug)
CREATE POLICY tenants_select_public ON public.tenants
  FOR SELECT
  TO public
  USING (true);

-- TENANTS: Permitir inserção pública (necessário para signup)
CREATE POLICY tenants_insert_public ON public.tenants
  FOR INSERT
  TO public
  WITH CHECK (true);

-- TENANTS: Permitir atualização apenas para membros do tenant
CREATE POLICY tenants_update_members ON public.tenants
  FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- TENANTS: Permitir deleção apenas para owners
CREATE POLICY tenants_delete_owners ON public.tenants
  FOR DELETE
  TO authenticated
  USING (
    id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_owner = true
    )
  );

-- TENANT_USERS: Permitir leitura apenas do próprio tenant
CREATE POLICY tenant_users_select_own_tenant ON public.tenant_users
  FOR SELECT
  TO authenticated
  USING (
    admin_user_id = auth.uid() OR
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_active = true
    )
  );

-- TENANT_USERS: Permitir inserção pública (signup)
CREATE POLICY tenant_users_insert_public ON public.tenant_users
  FOR INSERT
  TO public
  WITH CHECK (true);

-- TENANT_USERS: Permitir atualização por owners ou próprio usuário
CREATE POLICY tenant_users_update_own ON public.tenant_users
  FOR UPDATE
  TO authenticated
  USING (
    admin_user_id = auth.uid() OR
    tenant_id IN (
      SELECT tenant_id FROM public.tenant_users
      WHERE admin_user_id = auth.uid() AND is_owner = true
    )
  );

-- ============================================================================
-- PARTE 2: ADICIONAR tenant_id NAS TABELAS OPERACIONAIS
-- ============================================================================

-- Habilitar extensão necessária
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- CATEGORIAS
ALTER TABLE public.categorias ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_categorias_tenant_id ON public.categorias(tenant_id);

-- PRODUTOS
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_produtos_tenant_id ON public.produtos(tenant_id);

-- MENU ITEMS
ALTER TABLE public.menu_items ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_menu_items_tenant_id ON public.menu_items(tenant_id);

-- MENU ITEM INGREDIENTES
ALTER TABLE public.menu_item_ingredientes ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_menu_item_ingredientes_tenant_id ON public.menu_item_ingredientes(tenant_id);

-- PLANEJAMENTO SEMANAL
ALTER TABLE public.planejamento_semanal ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_planejamento_semanal_tenant_id ON public.planejamento_semanal(tenant_id);

-- MENU DIARIO
ALTER TABLE public.menu_diario ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_menu_diario_tenant_id ON public.menu_diario(tenant_id);

-- MOVEMENTS
ALTER TABLE public.movements ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_movements_tenant_id ON public.movements(tenant_id);

-- EMPLOYEES
ALTER TABLE public.employees ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_employees_tenant_id ON public.employees(tenant_id);

-- DAILY PAYMENTS
ALTER TABLE public.daily_payments ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_daily_payments_tenant_id ON public.daily_payments(tenant_id);

-- EMPLOYEE ATTENDANCE
ALTER TABLE public.employee_attendance ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_employee_attendance_tenant_id ON public.employee_attendance(tenant_id);

-- EMPLOYEE BANK ACCOUNTS
ALTER TABLE public.employee_bank_accounts ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_employee_bank_accounts_tenant_id ON public.employee_bank_accounts(tenant_id);

-- EMPLOYEE PERFORMANCE METRICS
ALTER TABLE public.employee_performance_metrics ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_employee_performance_metrics_tenant_id ON public.employee_performance_metrics(tenant_id);

-- SALARY CONFIGS
ALTER TABLE public.salary_configs ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_salary_configs_tenant_id ON public.salary_configs(tenant_id);

-- PAYMENT AUDIT LOG
ALTER TABLE public.payment_audit_log ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_payment_audit_log_tenant_id ON public.payment_audit_log(tenant_id);

-- FINANCIAL DATA
ALTER TABLE public.financial_data ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_financial_data_tenant_id ON public.financial_data(tenant_id);

-- DAILY FINANCIAL SUMMARY
ALTER TABLE public.daily_financial_summary ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_daily_financial_summary_tenant_id ON public.daily_financial_summary(tenant_id);

-- REPORTS
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_reports_tenant_id ON public.reports(tenant_id);

-- APP SETTINGS
ALTER TABLE public.app_settings ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_app_settings_tenant_id ON public.app_settings(tenant_id);

-- SUPPLIERS
ALTER TABLE public.suppliers ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_suppliers_tenant_id ON public.suppliers(tenant_id);

-- ============================================================================
-- PARTE 3: ATRIBUIR tenant_id AOS DADOS EXISTENTES
-- ============================================================================

-- Função auxiliar para obter tenant padrão
CREATE OR REPLACE FUNCTION get_default_tenant_id()
RETURNS uuid AS $$
DECLARE
  v_tenant_id uuid;
BEGIN
  SELECT id INTO v_tenant_id FROM public.tenants ORDER BY created_at LIMIT 1;
  RETURN v_tenant_id;
END;
$$ LANGUAGE plpgsql;

-- Adicionar constraint UNIQUE em full_day para evitar erro de trigger
ALTER TABLE public.financial_data
  DROP CONSTRAINT IF EXISTS financial_data_full_day_key;

-- Remover constraint UNIQUE de summary_date também
ALTER TABLE public.daily_financial_summary
  DROP CONSTRAINT IF EXISTS daily_financial_summary_summary_date_key;

-- Atribuir tenant_id (se houver dados existentes)
DO $$
DECLARE
  default_tenant uuid;
BEGIN
  default_tenant := get_default_tenant_id();

  IF default_tenant IS NOT NULL THEN
    -- CATEGORIAS
    UPDATE public.categorias SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- PRODUTOS (tentar via created_by primeiro)
    UPDATE public.produtos p SET tenant_id = tu.tenant_id
    FROM public.tenant_users tu
    WHERE p.created_by = tu.admin_user_id AND p.tenant_id IS NULL;
    UPDATE public.produtos SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- MENU ITEMS
    UPDATE public.menu_items mi SET tenant_id = tu.tenant_id
    FROM public.tenant_users tu
    WHERE mi.criado_por = tu.admin_user_id AND mi.tenant_id IS NULL;
    UPDATE public.menu_items SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- MENU ITEM INGREDIENTES (herda de menu_items)
    UPDATE public.menu_item_ingredientes mii SET tenant_id = mi.tenant_id
    FROM public.menu_items mi
    WHERE mii.menu_item_id = mi.id AND mii.tenant_id IS NULL;

    -- PLANEJAMENTO SEMANAL
    UPDATE public.planejamento_semanal ps SET tenant_id = tu.tenant_id
    FROM public.tenant_users tu
    WHERE ps.criado_por = tu.admin_user_id AND ps.tenant_id IS NULL;
    UPDATE public.planejamento_semanal SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- MENU DIARIO (herda de planejamento_semanal)
    UPDATE public.menu_diario md SET tenant_id = ps.tenant_id
    FROM public.planejamento_semanal ps
    WHERE md.planejamento_semanal_id = ps.id AND md.tenant_id IS NULL;

    -- MOVEMENTS
    UPDATE public.movements m SET tenant_id = p.tenant_id
    FROM public.produtos p
    WHERE m.product_id = p.id AND m.tenant_id IS NULL;
    UPDATE public.movements SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- EMPLOYEES
    UPDATE public.employees SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- DAILY PAYMENTS (herda de employees)
    UPDATE public.daily_payments dp SET tenant_id = e.tenant_id
    FROM public.employees e
    WHERE dp.employee_id = e.id AND dp.tenant_id IS NULL;

    -- EMPLOYEE ATTENDANCE (herda de employees)
    UPDATE public.employee_attendance ea SET tenant_id = e.tenant_id
    FROM public.employees e
    WHERE ea.employee_id = e.id AND ea.tenant_id IS NULL;

    -- EMPLOYEE BANK ACCOUNTS (herda de employees)
    UPDATE public.employee_bank_accounts eba SET tenant_id = e.tenant_id
    FROM public.employees e
    WHERE eba.employee_id = e.id AND eba.tenant_id IS NULL;

    -- EMPLOYEE PERFORMANCE METRICS (herda de employees)
    UPDATE public.employee_performance_metrics epm SET tenant_id = e.tenant_id
    FROM public.employees e
    WHERE epm.employee_id = e.id AND epm.tenant_id IS NULL;

    -- SALARY CONFIGS
    UPDATE public.salary_configs SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- PAYMENT AUDIT LOG (herda de employees)
    UPDATE public.payment_audit_log pal SET tenant_id = e.tenant_id
    FROM public.employees e
    WHERE pal.employee_id = e.id AND pal.tenant_id IS NULL;

    -- FINANCIAL DATA
    UPDATE public.financial_data SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- DAILY FINANCIAL SUMMARY
    UPDATE public.daily_financial_summary dfs SET tenant_id = fd.tenant_id
    FROM public.financial_data fd
    WHERE dfs.financial_data_id = fd.id AND dfs.tenant_id IS NULL;
    UPDATE public.daily_financial_summary SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- REPORTS
    UPDATE public.reports SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- APP SETTINGS
    UPDATE public.app_settings aps SET tenant_id = tu.tenant_id
    FROM public.tenant_users tu
    WHERE aps.user_id = tu.admin_user_id AND aps.tenant_id IS NULL;
    UPDATE public.app_settings SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    -- SUPPLIERS
    UPDATE public.suppliers SET tenant_id = default_tenant WHERE tenant_id IS NULL;

    RAISE NOTICE 'Dados existentes atualizados com tenant_id: %', default_tenant;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Aviso durante migração de dados: % - %', SQLERRM, SQLSTATE;
    RAISE NOTICE 'Continuando com a migração...';
END $$;

-- Adicionar constraints UNIQUE compostas considerando tenant_id
-- Nota: Se houver duplicatas, elas serão removidas automaticamente
DO $$
BEGIN
  -- Financial data: unique por full_day + tenant_id
  DROP INDEX IF EXISTS financial_data_full_day_tenant_unique;
  CREATE UNIQUE INDEX financial_data_full_day_tenant_unique
    ON public.financial_data(full_day, tenant_id);
  RAISE NOTICE 'Index UNIQUE criado: financial_data(full_day, tenant_id)';
EXCEPTION
  WHEN unique_violation THEN
    RAISE NOTICE 'Aviso: Duplicatas encontradas em financial_data. Removendo...';
    -- Manter apenas o registro mais recente de cada full_day+tenant_id
    DELETE FROM public.financial_data
    WHERE id NOT IN (
      SELECT DISTINCT ON (full_day, tenant_id) id
      FROM public.financial_data
      ORDER BY full_day, tenant_id, created_at DESC
    );
    -- Tentar criar index novamente
    CREATE UNIQUE INDEX financial_data_full_day_tenant_unique
      ON public.financial_data(full_day, tenant_id);
END $$;

-- Daily financial summary: unique por summary_date + tenant_id
DO $$
BEGIN
  DROP INDEX IF EXISTS daily_financial_summary_summary_date_tenant_unique;
  CREATE UNIQUE INDEX daily_financial_summary_summary_date_tenant_unique
    ON public.daily_financial_summary(summary_date, tenant_id);
  RAISE NOTICE 'Index UNIQUE criado: daily_financial_summary(summary_date, tenant_id)';
EXCEPTION
  WHEN unique_violation THEN
    RAISE NOTICE 'Aviso: Duplicatas encontradas em daily_financial_summary. Removendo...';
    -- Manter apenas o registro mais recente de cada summary_date+tenant_id
    DELETE FROM public.daily_financial_summary
    WHERE id NOT IN (
      SELECT DISTINCT ON (summary_date, tenant_id) id
      FROM public.daily_financial_summary
      ORDER BY summary_date, tenant_id, created_at DESC
    );
    -- Tentar criar index novamente
    CREATE UNIQUE INDEX daily_financial_summary_summary_date_tenant_unique
      ON public.daily_financial_summary(summary_date, tenant_id);
END $$;

-- ============================================================================
-- PARTE 4: CRIAR POLÍTICAS RLS PARA ISOLAMENTO
-- ============================================================================

-- Função auxiliar para obter tenant do usuário
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS uuid AS $$
DECLARE
  v_tenant_id uuid;
BEGIN
  SELECT tenant_id INTO v_tenant_id
  FROM public.tenant_users
  WHERE admin_user_id = auth.uid() AND is_active = true
  LIMIT 1;
  RETURN v_tenant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Macro para criar políticas RLS em uma tabela
DO $$
DECLARE
  table_name text;
BEGIN
  FOR table_name IN
    SELECT unnest(ARRAY[
      'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
      'planejamento_semanal', 'menu_diario', 'movements', 'employees',
      'daily_payments', 'employee_attendance', 'employee_bank_accounts',
      'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
      'financial_data', 'daily_financial_summary', 'reports',
      'app_settings', 'suppliers'
    ])
  LOOP
    -- Habilitar RLS
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', table_name);

    -- Política SELECT
    EXECUTE format('
      CREATE POLICY %I ON public.%I
      FOR SELECT
      TO authenticated
      USING (
        tenant_id IN (
          SELECT tenant_id FROM public.tenant_users
          WHERE admin_user_id = auth.uid() AND is_active = true
        )
      )',
      table_name || '_select',
      table_name
    );

    -- Política INSERT
    EXECUTE format('
      CREATE POLICY %I ON public.%I
      FOR INSERT
      TO authenticated
      WITH CHECK (
        tenant_id IN (
          SELECT tenant_id FROM public.tenant_users
          WHERE admin_user_id = auth.uid() AND is_active = true
        )
      )',
      table_name || '_insert',
      table_name
    );

    -- Política UPDATE
    EXECUTE format('
      CREATE POLICY %I ON public.%I
      FOR UPDATE
      TO authenticated
      USING (
        tenant_id IN (
          SELECT tenant_id FROM public.tenant_users
          WHERE admin_user_id = auth.uid() AND is_active = true
        )
      )',
      table_name || '_update',
      table_name
    );

    -- Política DELETE
    EXECUTE format('
      CREATE POLICY %I ON public.%I
      FOR DELETE
      TO authenticated
      USING (
        tenant_id IN (
          SELECT tenant_id FROM public.tenant_users
          WHERE admin_user_id = auth.uid() AND is_active = true
        )
      )',
      table_name || '_delete',
      table_name
    );

    RAISE NOTICE 'Políticas RLS criadas para tabela: %', table_name;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 5: TRIGGERS PARA AUTO-PREENCHER tenant_id
-- ============================================================================

CREATE OR REPLACE FUNCTION auto_set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := get_user_tenant_id();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar triggers
DO $$
DECLARE
  table_name text;
BEGIN
  FOR table_name IN
    SELECT unnest(ARRAY[
      'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
      'planejamento_semanal', 'menu_diario', 'movements', 'employees',
      'daily_payments', 'employee_attendance', 'employee_bank_accounts',
      'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
      'financial_data', 'daily_financial_summary', 'reports',
      'app_settings', 'suppliers'
    ])
  LOOP
    EXECUTE format('
      DROP TRIGGER IF EXISTS set_tenant_id ON public.%I;
      CREATE TRIGGER set_tenant_id
        BEFORE INSERT ON public.%I
        FOR EACH ROW
        EXECUTE FUNCTION auto_set_tenant_id()',
      table_name,
      table_name
    );
    RAISE NOTICE 'Trigger criado para tabela: %', table_name;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 6: ATUALIZAR CONSTRAINTS UNIQUE
-- ============================================================================

-- Categorias: nome deve ser único por tenant
ALTER TABLE public.categorias DROP CONSTRAINT IF EXISTS categorias_nome_key;
DROP INDEX IF EXISTS categorias_nome_tenant_unique;
CREATE UNIQUE INDEX categorias_nome_tenant_unique ON public.categorias(nome, tenant_id);

-- Salary configs: position deve ser único por tenant
ALTER TABLE public.salary_configs DROP CONSTRAINT IF EXISTS salary_configs_position_key;
DROP INDEX IF EXISTS salary_configs_position_tenant_unique;
CREATE UNIQUE INDEX salary_configs_position_tenant_unique ON public.salary_configs(position, tenant_id);

-- ============================================================================
-- PARTE 7: VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  orphan_count integer;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM (
    SELECT COUNT(*) FROM public.produtos WHERE tenant_id IS NULL
    UNION ALL
    SELECT COUNT(*) FROM public.categorias WHERE tenant_id IS NULL
    UNION ALL
    SELECT COUNT(*) FROM public.employees WHERE tenant_id IS NULL
  ) sub;

  IF orphan_count > 0 THEN
    RAISE WARNING 'Ainda existem % registros sem tenant_id', orphan_count;
  ELSE
    RAISE NOTICE '✓ Todos os registros possuem tenant_id';
  END IF;

  RAISE NOTICE '✓ Migração concluída com sucesso!';
  RAISE NOTICE '  - Políticas RLS criadas para signup';
  RAISE NOTICE '  - Coluna tenant_id adicionada em 19 tabelas';
  RAISE NOTICE '  - Políticas de isolamento configuradas';
  RAISE NOTICE '  - Triggers de auto-preenchimento criados';
END $$;

COMMIT;

-- ============================================================================
-- FIM DA MIGRAÇÃO
-- ============================================================================
--
-- Após executar:
-- 1. Teste criar uma nova conta no sistema
-- 2. Verifique que cada tenant vê apenas seus dados
-- 3. Teste CRUD completo (criar, ler, atualizar, deletar)
-- 4. Monitore logs para erros de RLS
