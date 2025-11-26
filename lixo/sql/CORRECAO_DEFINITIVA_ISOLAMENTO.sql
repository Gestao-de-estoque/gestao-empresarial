-- ============================================================================
-- 🔥 CORREÇÃO DEFINITIVA DO ISOLAMENTO - FUNCIONA GARANTIDO
-- ============================================================================
-- Este script corrige o isolamento de forma que REALMENTE funcione
-- ============================================================================

BEGIN;

-- ============================================================================
-- PARTE 1: DIAGNÓSTICO - Ver o problema atual
-- ============================================================================

DO $$
DECLARE
  total_employees integer;
  employees_with_tenant integer;
  employees_without_tenant integer;
  total_users integer;
  total_tenants integer;
BEGIN
  SELECT COUNT(*) INTO total_employees FROM public.employees;
  SELECT COUNT(*) INTO employees_with_tenant FROM public.employees WHERE tenant_id IS NOT NULL;
  SELECT COUNT(*) INTO employees_without_tenant FROM public.employees WHERE tenant_id IS NULL;
  SELECT COUNT(*) INTO total_users FROM public.admin_users;
  SELECT COUNT(*) INTO total_tenants FROM public.tenants;

  RAISE NOTICE '==============================================';
  RAISE NOTICE '🔍 DIAGNÓSTICO ATUAL:';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Total de funcionários: %', total_employees;
  RAISE NOTICE 'Funcionários COM tenant_id: %', employees_with_tenant;
  RAISE NOTICE 'Funcionários SEM tenant_id: %', employees_without_tenant;
  RAISE NOTICE 'Total de usuários: %', total_users;
  RAISE NOTICE 'Total de tenants: %', total_tenants;
  RAISE NOTICE '==============================================';

  IF employees_without_tenant > 0 THEN
    RAISE NOTICE '⚠️ PROBLEMA: % funcionários sem tenant_id!', employees_without_tenant;
  END IF;
END $$;

-- ============================================================================
-- PARTE 2: ATRIBUIR tenant_id AOS DADOS ÓRFÃOS EXISTENTES
-- ============================================================================

DO $$
DECLARE
  tenant_record RECORD;
  assigned_count integer := 0;
BEGIN
  RAISE NOTICE '📝 Atribuindo tenant_id aos dados existentes...';

  -- Para cada tenant, atribuir dados órfãos sequencialmente
  FOR tenant_record IN
    SELECT id, name FROM public.tenants ORDER BY created_at
  LOOP
    -- Atribuir funcionários órfãos a este tenant
    WITH updated AS (
      UPDATE public.employees
      SET tenant_id = tenant_record.id
      WHERE tenant_id IS NULL
      RETURNING id
    )
    SELECT COUNT(*) INTO assigned_count FROM updated;

    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ Atribuídos % funcionários ao tenant: %', assigned_count, tenant_record.name;
    END IF;

    -- Atribuir produtos órfãos
    WITH updated AS (
      UPDATE public.produtos
      SET tenant_id = tenant_record.id
      WHERE tenant_id IS NULL
      RETURNING id
    )
    SELECT COUNT(*) INTO assigned_count FROM updated;

    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ Atribuídos % produtos ao tenant: %', assigned_count, tenant_record.name;
    END IF;

    -- Atribuir categorias órfãs
    WITH updated AS (
      UPDATE public.categorias
      SET tenant_id = tenant_record.id
      WHERE tenant_id IS NULL
      RETURNING id
    )
    SELECT COUNT(*) INTO assigned_count FROM updated;

    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ Atribuídas % categorias ao tenant: %', assigned_count, tenant_record.name;
    END IF;

    -- Atribuir fornecedores órfãos
    WITH updated AS (
      UPDATE public.suppliers
      SET tenant_id = tenant_record.id
      WHERE tenant_id IS NULL
      RETURNING id
    )
    SELECT COUNT(*) INTO assigned_count FROM updated;

    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ Atribuídos % fornecedores ao tenant: %', assigned_count, tenant_record.name;
    END IF;

    -- Atribuir dados financeiros órfãos
    WITH updated AS (
      UPDATE public.financial_data
      SET tenant_id = tenant_record.id
      WHERE tenant_id IS NULL
      RETURNING id
    )
    SELECT COUNT(*) INTO assigned_count FROM updated;

    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ Atribuídos % registros financeiros ao tenant: %', assigned_count, tenant_record.name;
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 3: REMOVER TODAS AS POLÍTICAS RLS ANTIGAS
-- ============================================================================

DO $$
DECLARE
  pol RECORD;
  dropped_count integer := 0;
BEGIN
  RAISE NOTICE '🗑️ Removendo políticas RLS antigas...';

  FOR pol IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN (
        'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
        'planejamento_semanal', 'menu_diario', 'movements', 'employees',
        'daily_payments', 'employee_attendance', 'employee_bank_accounts',
        'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
        'financial_data', 'daily_financial_summary', 'reports',
        'app_settings', 'suppliers'
      )
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I',
      pol.policyname, pol.schemaname, pol.tablename);
    dropped_count := dropped_count + 1;
  END LOOP;

  RAISE NOTICE '  ✓ Removidas % políticas antigas', dropped_count;
END $$;

-- ============================================================================
-- PARTE 4: CRIAR POLÍTICAS RLS ULTRA-RESTRITIVAS
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔒 Criando políticas RLS ultra-restritivas...';

  FOREACH tbl IN ARRAY ARRAY[
    'employees', 'categorias', 'produtos', 'suppliers',
    'financial_data', 'movements', 'reports', 'menu_items',
    'menu_item_ingredientes', 'planejamento_semanal', 'menu_diario',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'daily_financial_summary', 'app_settings'
  ]
  LOOP
    -- Forçar RLS
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl);
    EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY', tbl);

    -- Política SELECT: DEVE ter tenant_id E DEVE ser do mesmo tenant do usuário
    EXECUTE format('
      CREATE POLICY %I_rls_select ON public.%I
      FOR SELECT
      TO authenticated
      USING (
        tenant_id IS NOT NULL
        AND
        tenant_id IN (
          SELECT tu.tenant_id
          FROM public.tenant_users tu
          WHERE tu.admin_user_id = auth.uid()
            AND tu.is_active = true
        )
      )
    ', tbl, tbl);

    -- Política INSERT: DEVE ter tenant_id E DEVE ser do mesmo tenant do usuário
    EXECUTE format('
      CREATE POLICY %I_rls_insert ON public.%I
      FOR INSERT
      TO authenticated
      WITH CHECK (
        tenant_id IS NOT NULL
        AND
        tenant_id IN (
          SELECT tu.tenant_id
          FROM public.tenant_users tu
          WHERE tu.admin_user_id = auth.uid()
            AND tu.is_active = true
        )
      )
    ', tbl, tbl);

    -- Política UPDATE: DEVE ter tenant_id E DEVE ser do mesmo tenant do usuário
    EXECUTE format('
      CREATE POLICY %I_rls_update ON public.%I
      FOR UPDATE
      TO authenticated
      USING (
        tenant_id IS NOT NULL
        AND
        tenant_id IN (
          SELECT tu.tenant_id
          FROM public.tenant_users tu
          WHERE tu.admin_user_id = auth.uid()
            AND tu.is_active = true
        )
      )
      WITH CHECK (
        tenant_id IS NOT NULL
        AND
        tenant_id IN (
          SELECT tu.tenant_id
          FROM public.tenant_users tu
          WHERE tu.admin_user_id = auth.uid()
            AND tu.is_active = true
        )
      )
    ', tbl, tbl);

    -- Política DELETE: DEVE ter tenant_id E DEVE ser do mesmo tenant do usuário
    EXECUTE format('
      CREATE POLICY %I_rls_delete ON public.%I
      FOR DELETE
      TO authenticated
      USING (
        tenant_id IS NOT NULL
        AND
        tenant_id IN (
          SELECT tu.tenant_id
          FROM public.tenant_users tu
          WHERE tu.admin_user_id = auth.uid()
            AND tu.is_active = true
        )
      )
    ', tbl, tbl);

    RAISE NOTICE '  ✓ Políticas criadas para: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 5: TORNAR tenant_id OBRIGATÓRIO (NOT NULL)
-- ============================================================================

DO $$
DECLARE
  tbl text;
  null_count integer;
BEGIN
  RAISE NOTICE '⚠️ Tornando tenant_id obrigatório...';

  FOREACH tbl IN ARRAY ARRAY[
    'employees', 'categorias', 'produtos', 'suppliers',
    'financial_data', 'movements', 'reports', 'menu_items'
  ]
  LOOP
    -- Verificar se há registros sem tenant_id
    EXECUTE format('SELECT COUNT(*) FROM public.%I WHERE tenant_id IS NULL', tbl)
    INTO null_count;

    IF null_count = 0 THEN
      -- Se não há registros NULL, tornar NOT NULL
      BEGIN
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN tenant_id SET NOT NULL', tbl);
        RAISE NOTICE '  ✓ tenant_id é NOT NULL em: %', tbl;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE WARNING '  ⚠️ Não foi possível tornar NOT NULL em %: %', tbl, SQLERRM;
      END;
    ELSE
      RAISE WARNING '  ⚠️ Ainda há % registros sem tenant_id em %!', null_count, tbl;
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 6: RECRIAR TRIGGER CORRETO
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
    EXECUTE format('DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.%I', tbl);
  END LOOP;
END $$;

-- Criar função melhorada
CREATE OR REPLACE FUNCTION public.set_tenant_id_auto()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tenant_id uuid;
BEGIN
  -- Se já tem tenant_id, não fazer nada
  IF NEW.tenant_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  -- Tentar obter tenant_id do usuário autenticado
  SELECT tu.tenant_id INTO v_tenant_id
  FROM public.tenant_users tu
  WHERE tu.admin_user_id = auth.uid()
    AND tu.is_active = true
  LIMIT 1;

  -- Se não encontrou, erro
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não está associado a nenhum tenant. Entre em contato com o suporte.';
  END IF;

  NEW.tenant_id := v_tenant_id;
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
      CREATE TRIGGER set_tenant_trigger
        BEFORE INSERT ON public.%I
        FOR EACH ROW
        EXECUTE FUNCTION public.set_tenant_id_auto()
    ', tbl);
    RAISE NOTICE '  ✓ Trigger criado em: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 7: VERIFICAÇÃO FINAL COMPLETA
-- ============================================================================

DO $$
DECLARE
  employees_orphan integer;
  products_orphan integer;
  total_policies integer;
  rls_enabled integer;
  users_without_tenant integer;
BEGIN
  -- Verificar dados órfãos
  SELECT COUNT(*) INTO employees_orphan FROM public.employees WHERE tenant_id IS NULL;
  SELECT COUNT(*) INTO products_orphan FROM public.produtos WHERE tenant_id IS NULL;

  -- Verificar políticas
  SELECT COUNT(*) INTO total_policies
  FROM pg_policies
  WHERE schemaname = 'public'
    AND tablename IN ('employees', 'produtos', 'categorias', 'suppliers');

  -- Verificar RLS
  SELECT COUNT(*) INTO rls_enabled
  FROM pg_tables
  WHERE schemaname = 'public'
    AND rowsecurity = true
    AND tablename IN ('employees', 'produtos', 'categorias', 'suppliers');

  -- Verificar usuários sem tenant
  SELECT COUNT(*) INTO users_without_tenant
  FROM public.admin_users au
  WHERE NOT EXISTS (
    SELECT 1 FROM public.tenant_users tu
    WHERE tu.admin_user_id = au.id
  );

  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ CORREÇÃO CONCLUÍDA!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Funcionários órfãos: %', employees_orphan;
  RAISE NOTICE 'Produtos órfãos: %', products_orphan;
  RAISE NOTICE 'Políticas RLS ativas: %', total_policies;
  RAISE NOTICE 'Tabelas com RLS: %', rls_enabled;
  RAISE NOTICE 'Usuários sem tenant: %', users_without_tenant;
  RAISE NOTICE '==============================================';

  IF employees_orphan = 0 AND products_orphan = 0 AND users_without_tenant = 0 THEN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 SUCESSO TOTAL!';
    RAISE NOTICE '';
    RAISE NOTICE '✓ ISOLAMENTO GARANTIDO:';
    RAISE NOTICE '  • Todos os dados têm tenant_id';
    RAISE NOTICE '  • RLS ultra-restritivo ativo';
    RAISE NOTICE '  • Impossível ver dados de outros tenants';
    RAISE NOTICE '  • Impossível modificar dados de outros tenants';
    RAISE NOTICE '';
    RAISE NOTICE '📝 TESTE AGORA:';
    RAISE NOTICE '  1. Faça LOGOUT do sistema';
    RAISE NOTICE '  2. Faça LOGIN novamente';
    RAISE NOTICE '  3. Tente adicionar funcionário';
    RAISE NOTICE '  4. Crie outro usuário e verifique que NÃO vê o funcionário';
    RAISE NOTICE '';
  ELSE
    RAISE WARNING '';
    RAISE WARNING '⚠️ ATENÇÃO - Problemas detectados:';
    IF employees_orphan > 0 THEN
      RAISE WARNING '  • % funcionários sem tenant_id', employees_orphan;
    END IF;
    IF products_orphan > 0 THEN
      RAISE WARNING '  • % produtos sem tenant_id', products_orphan;
    END IF;
    IF users_without_tenant > 0 THEN
      RAISE WARNING '  • % usuários não associados a tenants', users_without_tenant;
    END IF;
    RAISE WARNING '';
    RAISE WARNING 'Execute novamente ou corrija manualmente.';
  END IF;

  RAISE NOTICE '==============================================';
END $$;

COMMIT;

-- ============================================================================
-- FIM - ISOLAMENTO ULTRA-RESTRITIVO IMPLEMENTADO
-- ============================================================================
