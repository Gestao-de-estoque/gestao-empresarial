-- ============================================================================
-- 🚨 REMOVER COMPLETAMENTE VALIDAÇÕES DE TENANT
-- Execute para FORÇAR o sistema a funcionar
-- ============================================================================

BEGIN;

-- ============================================================================
-- PASSO 1: DROPAR FUNÇÃO auto_set_tenant_id COMPLETAMENTE
-- ============================================================================

DROP FUNCTION IF EXISTS public.auto_set_tenant_id() CASCADE;
DROP FUNCTION IF EXISTS public.get_current_user_tenant_id() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_tenant_id() CASCADE;

DO $$ BEGIN RAISE NOTICE '✓ Funções de tenant removidas'; END $$;

-- ============================================================================
-- PASSO 2: REMOVER TODOS OS TRIGGERS (FORÇA BRUTA)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.categorias CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.produtos CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.menu_items CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.menu_item_ingredientes CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.planejamento_semanal CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.menu_diario CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.movements CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.employees CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.daily_payments CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.employee_attendance CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.employee_bank_accounts CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.employee_performance_metrics CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.salary_configs CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.payment_audit_log CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.financial_data CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.daily_financial_summary CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.reports CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.app_settings CASCADE;
DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.suppliers CASCADE;

DROP TRIGGER IF EXISTS set_tenant_id ON public.categorias CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.produtos CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.menu_items CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.menu_item_ingredientes CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.planejamento_semanal CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.menu_diario CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.movements CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.employees CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.daily_payments CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.employee_attendance CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.employee_bank_accounts CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.employee_performance_metrics CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.salary_configs CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.payment_audit_log CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.financial_data CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.daily_financial_summary CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.reports CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.app_settings CASCADE;
DROP TRIGGER IF EXISTS set_tenant_id ON public.suppliers CASCADE;

DO $$ BEGIN RAISE NOTICE '✓ Todos os triggers removidos'; END $$;

-- ============================================================================
-- PASSO 3: DESABILITAR RLS EM TODAS AS TABELAS
-- ============================================================================

ALTER TABLE public.categorias DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_item_ingredientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.planejamento_semanal DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_diario DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_attendance DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_bank_accounts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_performance_metrics DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.salary_configs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_audit_log DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_data DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_financial_summary DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers DISABLE ROW LEVEL SECURITY;

DO $$ BEGIN RAISE NOTICE '✓ RLS desabilitado em todas as tabelas'; END $$;

-- ============================================================================
-- PASSO 4: REMOVER TODAS AS POLÍTICAS RLS
-- ============================================================================

DROP POLICY IF EXISTS categorias_select_policy ON public.categorias;
DROP POLICY IF EXISTS categorias_insert_policy ON public.categorias;
DROP POLICY IF EXISTS categorias_update_policy ON public.categorias;
DROP POLICY IF EXISTS categorias_delete_policy ON public.categorias;

DROP POLICY IF EXISTS produtos_select_policy ON public.produtos;
DROP POLICY IF EXISTS produtos_insert_policy ON public.produtos;
DROP POLICY IF EXISTS produtos_update_policy ON public.produtos;
DROP POLICY IF EXISTS produtos_delete_policy ON public.produtos;

DROP POLICY IF EXISTS menu_items_select_policy ON public.menu_items;
DROP POLICY IF EXISTS menu_items_insert_policy ON public.menu_items;
DROP POLICY IF EXISTS menu_items_update_policy ON public.menu_items;
DROP POLICY IF EXISTS menu_items_delete_policy ON public.menu_items;

DROP POLICY IF EXISTS employees_select_policy ON public.employees;
DROP POLICY IF EXISTS employees_insert_policy ON public.employees;
DROP POLICY IF EXISTS employees_update_policy ON public.employees;
DROP POLICY IF EXISTS employees_delete_policy ON public.employees;

DROP POLICY IF EXISTS financial_data_select_policy ON public.financial_data;
DROP POLICY IF EXISTS financial_data_insert_policy ON public.financial_data;
DROP POLICY IF EXISTS financial_data_update_policy ON public.financial_data;
DROP POLICY IF EXISTS financial_data_delete_policy ON public.financial_data;

DROP POLICY IF EXISTS suppliers_select_policy ON public.suppliers;
DROP POLICY IF EXISTS suppliers_insert_policy ON public.suppliers;
DROP POLICY IF EXISTS suppliers_update_policy ON public.suppliers;
DROP POLICY IF EXISTS suppliers_delete_policy ON public.suppliers;

DROP POLICY IF EXISTS movements_select_policy ON public.movements;
DROP POLICY IF EXISTS movements_insert_policy ON public.movements;
DROP POLICY IF EXISTS movements_update_policy ON public.movements;
DROP POLICY IF EXISTS movements_delete_policy ON public.movements;

DROP POLICY IF EXISTS reports_select_policy ON public.reports;
DROP POLICY IF EXISTS reports_insert_policy ON public.reports;
DROP POLICY IF EXISTS reports_update_policy ON public.reports;
DROP POLICY IF EXISTS reports_delete_policy ON public.reports;

DO $$ BEGIN RAISE NOTICE '✓ Todas as políticas RLS removidas'; END $$;

-- ============================================================================
-- PASSO 5: TORNAR tenant_id NULLABLE
-- ============================================================================

ALTER TABLE public.categorias ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.produtos ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.menu_items ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.menu_item_ingredientes ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.planejamento_semanal ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.menu_diario ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.movements ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.employees ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.daily_payments ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.employee_attendance ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.employee_bank_accounts ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.employee_performance_metrics ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.salary_configs ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.payment_audit_log ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.financial_data ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.daily_financial_summary ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.reports ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.app_settings ALTER COLUMN tenant_id DROP NOT NULL;
ALTER TABLE public.suppliers ALTER COLUMN tenant_id DROP NOT NULL;

DO $$ BEGIN RAISE NOTICE '✓ tenant_id agora é NULLABLE em todas as tabelas'; END $$;

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  trigger_count integer;
  function_count integer;
  rls_count integer;
BEGIN
  -- Contar triggers restantes
  SELECT COUNT(*) INTO trigger_count
  FROM information_schema.triggers
  WHERE trigger_schema = 'public'
    AND (trigger_name LIKE '%tenant%' OR trigger_name LIKE '%set_tenant%');

  -- Contar funções restantes
  SELECT COUNT(*) INTO function_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE n.nspname = 'public'
    AND p.proname LIKE '%tenant%';

  -- Contar tabelas com RLS ativo
  SELECT COUNT(*) INTO rls_count
  FROM pg_tables
  WHERE schemaname = 'public'
    AND rowsecurity = true
    AND tablename IN (
      'categorias', 'produtos', 'employees', 'suppliers',
      'financial_data', 'menu_items', 'movements'
    );

  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ LIMPEZA COMPLETA REALIZADA!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Triggers restantes: %', trigger_count;
  RAISE NOTICE 'Funções de tenant restantes: %', function_count;
  RAISE NOTICE 'Tabelas com RLS ativo: %', rls_count;
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 SISTEMA 100%% LIBERADO!';
  RAISE NOTICE '';
  RAISE NOTICE '✓ PODE USAR TODAS AS ROTAS:';
  RAISE NOTICE '  • /financial - Adicionar registros financeiros';
  RAISE NOTICE '  • /menu - Criar itens do cardápio';
  RAISE NOTICE '  • /suppliers - Adicionar fornecedores';
  RAISE NOTICE '  • /employees - Cadastrar funcionários';
  RAISE NOTICE '  • /products - Gerenciar produtos';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ ATENÇÃO:';
  RAISE NOTICE '  • SEM isolamento de dados';
  RAISE NOTICE '  • Todos veem tudo';
  RAISE NOTICE '  • Apenas para desenvolvimento';
  RAISE NOTICE '';
  RAISE NOTICE '📝 NÃO PRECISA:';
  RAISE NOTICE '  • Fazer logout/login';
  RAISE NOTICE '  • Atualizar página';
  RAISE NOTICE '  • Configurar nada';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 PODE USAR AGORA MESMO!';
  RAISE NOTICE '==============================================';
END $$;

COMMIT;

-- ============================================================================
-- FIM - TUDO REMOVIDO E LIBERADO
-- ============================================================================
