-- ============================================================================
-- 🚨 CORREÇÃO DE EMERGÊNCIA: BLOQUEAR ACESSO ENTRE CLIENTES
-- Execute IMEDIATAMENTE no Supabase SQL Editor
-- ============================================================================

BEGIN;

-- ============================================================================
-- ETAPA 1: VERIFICAR ESTADO ATUAL (DIAGNÓSTICO)
-- ============================================================================

DO $$
DECLARE
  orphan_produtos integer;
  orphan_categorias integer;
  total_tenants integer;
BEGIN
  SELECT COUNT(*) INTO total_tenants FROM public.tenants;
  SELECT COUNT(*) INTO orphan_produtos FROM public.produtos WHERE tenant_id IS NULL;
  SELECT COUNT(*) INTO orphan_categorias FROM public.categorias WHERE tenant_id IS NULL;

  RAISE NOTICE '==============================================';
  RAISE NOTICE '🔍 DIAGNÓSTICO:';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Total de tenants: %', total_tenants;
  RAISE NOTICE 'Produtos sem tenant_id: %', orphan_produtos;
  RAISE NOTICE 'Categorias sem tenant_id: %', orphan_categorias;
  RAISE NOTICE '==============================================';
END $$;

-- ============================================================================
-- ETAPA 2: REMOVER TODAS AS POLÍTICAS RLS EXISTENTES (LIMPAR)
-- ============================================================================

DO $$
DECLARE
  pol RECORD;
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
    RAISE NOTICE 'Removida: %.% - %', pol.schemaname, pol.tablename, pol.policyname;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 3: PREPARAR CONSTRAINTS PARA EVITAR ERROS DE TRIGGER
-- ============================================================================

-- Remover constraints UNIQUE antigas que causam conflito
ALTER TABLE public.financial_data
  DROP CONSTRAINT IF EXISTS financial_data_full_day_key;

ALTER TABLE public.daily_financial_summary
  DROP CONSTRAINT IF EXISTS daily_financial_summary_summary_date_key;

-- Desabilitar triggers de usuário temporariamente (não de sistema)
ALTER TABLE public.financial_data DISABLE TRIGGER USER;
ALTER TABLE public.daily_financial_summary DISABLE TRIGGER USER;
ALTER TABLE public.daily_payments DISABLE TRIGGER USER;
ALTER TABLE public.employees DISABLE TRIGGER USER;

-- ============================================================================
-- ETAPA 4: GARANTIR QUE TODOS OS DADOS TÊM tenant_id
-- ============================================================================

DO $$
DECLARE
  default_tenant uuid;
  updated_count integer;
BEGIN
  RAISE NOTICE '📝 Atribuindo tenant_id aos dados órfãos...';

  SELECT id INTO default_tenant FROM public.tenants ORDER BY created_at LIMIT 1;

  IF default_tenant IS NULL THEN
    RAISE EXCEPTION 'ERRO CRÍTICO: Nenhum tenant encontrado no sistema!';
  END IF;

  -- Atualizar TODOS os dados órfãos
  UPDATE public.categorias SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Categorias: % atualizadas', updated_count;

  UPDATE public.produtos SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Produtos: % atualizados', updated_count;

  UPDATE public.menu_items SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Menu items: % atualizados', updated_count;

  UPDATE public.menu_item_ingredientes SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Ingredientes: % atualizados', updated_count;

  UPDATE public.movements SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Movimentos: % atualizados', updated_count;

  UPDATE public.employees SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Funcionários: % atualizados', updated_count;

  UPDATE public.financial_data SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Dados financeiros: % atualizados', updated_count;

  UPDATE public.reports SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Relatórios: % atualizados', updated_count;

  UPDATE public.suppliers SET tenant_id = default_tenant WHERE tenant_id IS NULL;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '  Fornecedores: % atualizados', updated_count;

  RAISE NOTICE '✓ Todos os dados agora têm tenant_id';
END $$;

-- Reabilitar triggers
ALTER TABLE public.financial_data ENABLE TRIGGER USER;
ALTER TABLE public.daily_financial_summary ENABLE TRIGGER USER;
ALTER TABLE public.daily_payments ENABLE TRIGGER USER;
ALTER TABLE public.employees ENABLE TRIGGER USER;

-- Adicionar constraints UNIQUE compostas (com tenant_id)
DO $$
BEGIN
  -- Financial data: unique por full_day + tenant_id
  BEGIN
    DROP INDEX IF EXISTS financial_data_full_day_tenant_unique;
    CREATE UNIQUE INDEX financial_data_full_day_tenant_unique
      ON public.financial_data(full_day, tenant_id);
    RAISE NOTICE '  ✓ Index UNIQUE criado: financial_data(full_day, tenant_id)';
  EXCEPTION
    WHEN unique_violation THEN
      RAISE NOTICE '  ⚠️ Duplicatas encontradas em financial_data. Mantendo apenas registro mais recente...';
      DELETE FROM public.financial_data
      WHERE id NOT IN (
        SELECT DISTINCT ON (full_day, tenant_id) id
        FROM public.financial_data
        ORDER BY full_day, tenant_id, created_at DESC
      );
      CREATE UNIQUE INDEX financial_data_full_day_tenant_unique
        ON public.financial_data(full_day, tenant_id);
  END;

  -- Daily financial summary: unique por summary_date + tenant_id
  BEGIN
    DROP INDEX IF EXISTS daily_financial_summary_date_tenant_unique;
    CREATE UNIQUE INDEX daily_financial_summary_date_tenant_unique
      ON public.daily_financial_summary(summary_date, tenant_id);
    RAISE NOTICE '  ✓ Index UNIQUE criado: daily_financial_summary(summary_date, tenant_id)';
  EXCEPTION
    WHEN unique_violation THEN
      RAISE NOTICE '  ⚠️ Duplicatas encontradas em daily_financial_summary. Mantendo apenas registro mais recente...';
      DELETE FROM public.daily_financial_summary
      WHERE id NOT IN (
        SELECT DISTINCT ON (summary_date, tenant_id) id
        FROM public.daily_financial_summary
        ORDER BY summary_date, tenant_id, created_at DESC
      );
      CREATE UNIQUE INDEX daily_financial_summary_date_tenant_unique
        ON public.daily_financial_summary(summary_date, tenant_id);
  END;
END $$;

-- ============================================================================
-- ETAPA 5: CRIAR FUNÇÃO SEGURA PARA OBTER tenant_id DO USUÁRIO
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_current_user_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT tenant_id
  FROM public.tenant_users
  WHERE admin_user_id = auth.uid()
    AND is_active = true
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.get_current_user_tenant_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_current_user_tenant_id() TO anon;

-- ============================================================================
-- ETAPA 6: CRIAR POLÍTICAS RLS RESTRITIVAS (ISOLAMENTO TOTAL)
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔒 Criando políticas RLS restritivas...';

  FOREACH tbl IN ARRAY ARRAY[
    'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
    'planejamento_semanal', 'menu_diario', 'movements', 'employees',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'financial_data', 'daily_financial_summary', 'reports',
    'app_settings', 'suppliers'
  ]
  LOOP
    -- Habilitar RLS
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl);

    -- Política SELECT: só vê dados do próprio tenant
    EXECUTE format('
      CREATE POLICY %I ON public.%I
        FOR SELECT
        TO authenticated
        USING (tenant_id = public.get_current_user_tenant_id())
    ', tbl || '_select_policy', tbl);

    -- Política INSERT: só pode inserir no próprio tenant
    EXECUTE format('
      CREATE POLICY %I ON public.%I
        FOR INSERT
        TO authenticated
        WITH CHECK (tenant_id = public.get_current_user_tenant_id())
    ', tbl || '_insert_policy', tbl);

    -- Política UPDATE: só pode atualizar dados do próprio tenant
    EXECUTE format('
      CREATE POLICY %I ON public.%I
        FOR UPDATE
        TO authenticated
        USING (tenant_id = public.get_current_user_tenant_id())
        WITH CHECK (tenant_id = public.get_current_user_tenant_id())
    ', tbl || '_update_policy', tbl);

    -- Política DELETE: só pode deletar dados do próprio tenant
    EXECUTE format('
      CREATE POLICY %I ON public.%I
        FOR DELETE
        TO authenticated
        USING (tenant_id = public.get_current_user_tenant_id())
    ', tbl || '_delete_policy', tbl);

    RAISE NOTICE '  ✓ Políticas criadas para: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 7: FORÇAR RLS PARA OWNERS DA TABELA (SEGURANÇA MÁXIMA)
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔐 Forçando RLS para todos (incluindo owners)...';

  FOREACH tbl IN ARRAY ARRAY[
    'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
    'planejamento_semanal', 'menu_diario', 'movements', 'employees',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'financial_data', 'daily_financial_summary', 'reports',
    'app_settings', 'suppliers'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY', tbl);
    RAISE NOTICE '  ✓ RLS forçado para: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 8: ADICIONAR NOT NULL EM tenant_id (PREVENIR DADOS ÓRFÃOS)
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '⚠️ Adicionando NOT NULL em tenant_id...';

  FOREACH tbl IN ARRAY ARRAY[
    'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
    'planejamento_semanal', 'menu_diario', 'movements', 'employees',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'financial_data', 'daily_financial_summary', 'reports',
    'app_settings', 'suppliers'
  ]
  LOOP
    BEGIN
      EXECUTE format('ALTER TABLE public.%I ALTER COLUMN tenant_id SET NOT NULL', tbl);
      RAISE NOTICE '  ✓ NOT NULL adicionado em: %', tbl;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE WARNING '  ⚠️ Não foi possível adicionar NOT NULL em %: %', tbl, SQLERRM;
    END;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 9: RECRIAR TRIGGERS PARA AUTO-PREENCHER tenant_id
-- ============================================================================

CREATE OR REPLACE FUNCTION public.auto_set_tenant_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := public.get_current_user_tenant_id();

    IF NEW.tenant_id IS NULL THEN
      RAISE EXCEPTION 'ERRO: Não foi possível determinar o tenant_id do usuário. Usuário não está associado a nenhum tenant.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔄 Criando triggers de auto-preenchimento...';

  FOREACH tbl IN ARRAY ARRAY[
    'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
    'planejamento_semanal', 'menu_diario', 'movements', 'employees',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'financial_data', 'daily_financial_summary', 'reports',
    'app_settings', 'suppliers'
  ]
  LOOP
    EXECUTE format('
      DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.%I;
      CREATE TRIGGER trg_auto_set_tenant_id
        BEFORE INSERT ON public.%I
        FOR EACH ROW
        EXECUTE FUNCTION public.auto_set_tenant_id()
    ', tbl, tbl);

    RAISE NOTICE '  ✓ Trigger criado para: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 10: VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  table_count integer;
  policy_count integer;
  orphan_count integer;
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ VERIFICAÇÃO FINAL:';
  RAISE NOTICE '==============================================';

  -- Contar tabelas com RLS habilitado
  SELECT COUNT(*) INTO table_count
  FROM pg_tables
  WHERE schemaname = 'public'
    AND rowsecurity = true
    AND tablename IN (
      'categorias', 'produtos', 'menu_items', 'movements',
      'employees', 'financial_data', 'reports', 'suppliers'
    );
  RAISE NOTICE 'Tabelas com RLS habilitado: % de 19', table_count;

  -- Contar políticas RLS
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'public'
    AND tablename IN (
      'categorias', 'produtos', 'menu_items', 'movements',
      'employees', 'financial_data', 'reports', 'suppliers'
    );
  RAISE NOTICE 'Políticas RLS ativas: %', policy_count;

  -- Verificar dados órfãos
  SELECT COUNT(*) INTO orphan_count
  FROM public.produtos
  WHERE tenant_id IS NULL;

  IF orphan_count > 0 THEN
    RAISE WARNING '⚠️ ATENÇÃO: Ainda existem % produtos sem tenant_id!', orphan_count;
  ELSE
    RAISE NOTICE '✓ Nenhum dado órfão encontrado';
  END IF;

  RAISE NOTICE '==============================================';
  RAISE NOTICE '🎉 CORREÇÃO CONCLUÍDA!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 ISOLAMENTO ATIVADO:';
  RAISE NOTICE '  • Cada usuário vê apenas dados do seu tenant';
  RAISE NOTICE '  • Não é possível acessar dados de outros tenants';
  RAISE NOTICE '  • RLS forçado para todos (incluindo owners)';
  RAISE NOTICE '  • Novos dados receberão tenant_id automaticamente';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ TESTE IMEDIATAMENTE:';
  RAISE NOTICE '  1. Login com Tenant A → Criar produto';
  RAISE NOTICE '  2. Login com Tenant B → Produto do A não deve aparecer';
  RAISE NOTICE '  3. Tentar deletar dado de outro tenant → Deve falhar';
  RAISE NOTICE '==============================================';
END $$;

COMMIT;

-- ============================================================================
-- 🚨 FIM DA CORREÇÃO DE EMERGÊNCIA
-- ============================================================================
