-- ============================================================================
-- 🔥 CORRIGIR RECURSÃO INFINITA NAS POLÍTICAS RLS
-- ============================================================================
-- Erro: "infinite recursion detected in policy for relation tenant_users"
-- Causa: Políticas RLS fazendo SELECT em tenant_users que também tem RLS
-- Solução: Função SECURITY DEFINER que bypassa RLS
-- ============================================================================

BEGIN;

-- ============================================================================
-- PARTE 1: REMOVER TODAS AS POLÍTICAS RLS PROBLEMÁTICAS
-- ============================================================================

DO $$
DECLARE
  pol RECORD;
BEGIN
  RAISE NOTICE '🗑️ Removendo políticas RLS problemáticas...';

  -- Remover TODAS as políticas de TODAS as tabelas
  FOR pol IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I',
      pol.policyname, pol.schemaname, pol.tablename);
  END LOOP;

  RAISE NOTICE '✓ Todas as políticas removidas';
END $$;

-- ============================================================================
-- PARTE 2: DESABILITAR RLS EM tenant_users (evitar recursão)
-- ============================================================================

ALTER TABLE public.tenant_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users DISABLE ROW LEVEL SECURITY;

DO $$ BEGIN RAISE NOTICE '✓ RLS desabilitado em tabelas de autenticação'; END $$;

-- ============================================================================
-- PARTE 3: CRIAR FUNÇÃO SECURITY DEFINER (bypassa RLS)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.current_user_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT tenant_id
  FROM tenant_users
  WHERE admin_user_id = auth.uid()
    AND is_active = true
  LIMIT 1;
$$;

COMMENT ON FUNCTION public.current_user_tenant_id IS 'Retorna tenant_id do usuário (bypassa RLS)';

DO $$ BEGIN RAISE NOTICE '✓ Função SECURITY DEFINER criada'; END $$;

-- ============================================================================
-- PARTE 4: CRIAR POLÍTICAS RLS SIMPLES (sem recursão)
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔒 Criando políticas RLS simples...';

  FOREACH tbl IN ARRAY ARRAY[
    'employees', 'categorias', 'produtos', 'suppliers',
    'financial_data', 'movements', 'reports', 'menu_items',
    'menu_item_ingredientes', 'planejamento_semanal', 'menu_diario',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'daily_financial_summary', 'app_settings'
  ]
  LOOP
    -- Habilitar RLS
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl);

    -- SELECT: Usa função SECURITY DEFINER (não causa recursão)
    EXECUTE format('
      CREATE POLICY %I_select ON public.%I
      FOR SELECT
      USING (
        tenant_id = public.current_user_tenant_id()
        OR tenant_id IS NULL
      )
    ', tbl, tbl);

    -- INSERT: Usa função SECURITY DEFINER
    EXECUTE format('
      CREATE POLICY %I_insert ON public.%I
      FOR INSERT
      WITH CHECK (
        tenant_id = public.current_user_tenant_id()
        OR tenant_id IS NULL
      )
    ', tbl, tbl);

    -- UPDATE: Usa função SECURITY DEFINER
    EXECUTE format('
      CREATE POLICY %I_update ON public.%I
      FOR UPDATE
      USING (tenant_id = public.current_user_tenant_id())
      WITH CHECK (tenant_id = public.current_user_tenant_id())
    ', tbl, tbl);

    -- DELETE: Usa função SECURITY DEFINER
    EXECUTE format('
      CREATE POLICY %I_delete ON public.%I
      FOR DELETE
      USING (tenant_id = public.current_user_tenant_id())
    ', tbl, tbl);

    RAISE NOTICE '  ✓ Políticas criadas para: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 5: RECRIAR TRIGGER CORRETO
-- ============================================================================

-- Remover triggers antigos
DO $$
DECLARE
  tbl text;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'employees', 'categorias', 'produtos', 'suppliers',
    'financial_data', 'movements', 'reports', 'menu_items',
    'menu_item_ingredientes', 'planejamento_semanal', 'menu_diario',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'daily_financial_summary', 'app_settings'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS set_tenant_id_trigger ON public.%I', tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS set_tenant_trigger ON public.%I', tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.%I', tbl);
  END LOOP;
END $$;

-- Criar função do trigger (também SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.auto_tenant_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := public.current_user_tenant_id();
  END IF;
  RETURN NEW;
END;
$$;

-- Criar triggers
DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔄 Criando triggers...';

  FOREACH tbl IN ARRAY ARRAY[
    'employees', 'categorias', 'produtos', 'suppliers',
    'financial_data', 'movements', 'reports', 'menu_items',
    'menu_item_ingredientes', 'planejamento_semanal', 'menu_diario',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'daily_financial_summary', 'app_settings'
  ]
  LOOP
    EXECUTE format('
      CREATE TRIGGER auto_tenant_trigger
        BEFORE INSERT ON public.%I
        FOR EACH ROW
        EXECUTE FUNCTION public.auto_tenant_id()
    ', tbl);
  END LOOP;

  RAISE NOTICE '✓ Triggers criados';
END $$;

-- ============================================================================
-- PARTE 6: GARANTIR QUE CATEGORIAS SÃO VISÍVEIS
-- ============================================================================

-- Política especial para categorias (permite ver mesmo sem tenant para dropdown)
DROP POLICY IF EXISTS categorias_select ON public.categorias;
CREATE POLICY categorias_select ON public.categorias
  FOR SELECT
  USING (
    tenant_id = public.current_user_tenant_id()
    OR tenant_id IS NULL
    OR public.current_user_tenant_id() IS NOT NULL
  );

DO $$ BEGIN RAISE NOTICE '✓ Política especial de categorias criada'; END $$;

-- ============================================================================
-- PARTE 7: VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  policy_count integer;
  function_exists boolean;
  orphan_employees integer;
  orphan_products integer;
BEGIN
  -- Verificar se função existe
  SELECT EXISTS (
    SELECT 1 FROM pg_proc
    WHERE proname = 'current_user_tenant_id'
  ) INTO function_exists;

  -- Contar políticas
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'public'
    AND tablename IN ('employees', 'produtos', 'categorias', 'suppliers');

  -- Verificar órfãos
  SELECT COUNT(*) INTO orphan_employees FROM public.employees WHERE tenant_id IS NULL;
  SELECT COUNT(*) INTO orphan_products FROM public.produtos WHERE tenant_id IS NULL;

  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ CORREÇÃO DE RECURSÃO CONCLUÍDA!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Função SECURITY DEFINER: %', CASE WHEN function_exists THEN 'OK' ELSE 'ERRO' END;
  RAISE NOTICE 'Políticas RLS criadas: %', policy_count;
  RAISE NOTICE 'Funcionários órfãos: %', orphan_employees;
  RAISE NOTICE 'Produtos órfãos: %', orphan_products;
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE '✓ SOLUÇÕES APLICADAS:';
  RAISE NOTICE '  • Função SECURITY DEFINER bypassa RLS';
  RAISE NOTICE '  • RLS desabilitado em tenant_users';
  RAISE NOTICE '  • Políticas simples sem recursão';
  RAISE NOTICE '  • Categorias visíveis em dropdowns';
  RAISE NOTICE '';
  RAISE NOTICE '📝 TESTE AGORA:';
  RAISE NOTICE '  1. Adicionar funcionário em /employees';
  RAISE NOTICE '  2. Adicionar fornecedor em /suppliers';
  RAISE NOTICE '  3. Adicionar item em /menu (categorias devem aparecer)';
  RAISE NOTICE '  4. Adicionar produto em /inventory';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ NÃO PRECISA fazer logout/login';
  RAISE NOTICE '  Apenas atualize a página (F5)';
  RAISE NOTICE '==============================================';
END $$;

COMMIT;

-- ============================================================================
-- FIM - RECURSÃO CORRIGIDA COM SECURITY DEFINER
-- ============================================================================
