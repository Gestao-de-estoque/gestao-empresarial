-- ============================================================================
-- 🚨 DESATIVAR VALIDAÇÃO DE TENANT (TEMPORÁRIO)
-- Execute para voltar o sistema a funcionar
-- ============================================================================

BEGIN;

-- ============================================================================
-- ETAPA 1: REMOVER TODOS OS TRIGGERS DE tenant_id
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🗑️ Removendo triggers de validação de tenant_id...';

  FOREACH tbl IN ARRAY ARRAY[
    'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
    'planejamento_semanal', 'menu_diario', 'movements', 'employees',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'financial_data', 'daily_financial_summary', 'reports',
    'app_settings', 'suppliers'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_auto_set_tenant_id ON public.%I', tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS set_tenant_id ON public.%I', tbl);
    RAISE NOTICE '  ✓ Triggers removidos de: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 2: TORNAR tenant_id NULLABLE (permitir NULL temporariamente)
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '⚠️ Tornando tenant_id NULLABLE...';

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
      EXECUTE format('ALTER TABLE public.%I ALTER COLUMN tenant_id DROP NOT NULL', tbl);
      RAISE NOTICE '  ✓ tenant_id NULLABLE em: %', tbl;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '  ⚠️ Já era NULLABLE em: %', tbl;
    END;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 3: REMOVER POLÍTICAS RLS RESTRITIVAS
-- ============================================================================

DO $$
DECLARE
  pol RECORD;
BEGIN
  RAISE NOTICE '🔓 Desabilitando RLS restritivo...';

  -- Remover todas as políticas que verificam tenant_id
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
    RAISE NOTICE '  ✓ Política removida: %.%', pol.tablename, pol.policyname;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 4: DESABILITAR RLS TEMPORARIAMENTE
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔓 Desabilitando RLS temporariamente...';

  FOREACH tbl IN ARRAY ARRAY[
    'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
    'planejamento_semanal', 'menu_diario', 'movements', 'employees',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'financial_data', 'daily_financial_summary', 'reports',
    'app_settings', 'suppliers'
  ]
  LOOP
    EXECUTE format('ALTER TABLE public.%I DISABLE ROW LEVEL SECURITY', tbl);
    RAISE NOTICE '  ✓ RLS desabilitado em: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- ETAPA 5: OBTER tenant_id PADRÃO PARA CORREÇÃO FUTURA
-- ============================================================================

DO $$
DECLARE
  default_tenant uuid;
  tenant_name text;
BEGIN
  SELECT id, name INTO default_tenant, tenant_name
  FROM public.tenants
  ORDER BY created_at
  LIMIT 1;

  IF default_tenant IS NULL THEN
    RAISE NOTICE '⚠️ ATENÇÃO: Nenhum tenant encontrado!';
    RAISE NOTICE 'Crie um tenant com:';
    RAISE NOTICE 'INSERT INTO public.tenants (name, slug, email) VALUES (''Minha Empresa'', ''minha-empresa'', ''contato@empresa.com'');';
  ELSE
    RAISE NOTICE '📝 Tenant padrão: % (ID: %)', tenant_name, default_tenant;
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ IMPORTANTE: Depois de usar o sistema, execute:';
    RAISE NOTICE 'UPDATE public.categorias SET tenant_id = ''%'' WHERE tenant_id IS NULL;', default_tenant;
    RAISE NOTICE 'UPDATE public.produtos SET tenant_id = ''%'' WHERE tenant_id IS NULL;', default_tenant;
    RAISE NOTICE 'UPDATE public.employees SET tenant_id = ''%'' WHERE tenant_id IS NULL;', default_tenant;
    RAISE NOTICE '(E assim por diante para todas as tabelas)';
  END IF;
END $$;

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  rls_count integer;
  trigger_count integer;
  policy_count integer;
BEGIN
  -- Contar tabelas com RLS ainda ativo
  SELECT COUNT(*) INTO rls_count
  FROM pg_tables
  WHERE schemaname = 'public'
    AND rowsecurity = true
    AND tablename IN (
      'categorias', 'produtos', 'menu_items', 'employees',
      'financial_data', 'suppliers'
    );

  -- Contar triggers de tenant
  SELECT COUNT(*) INTO trigger_count
  FROM information_schema.triggers
  WHERE trigger_schema = 'public'
    AND trigger_name LIKE '%tenant%';

  -- Contar políticas RLS
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'public'
    AND tablename IN ('categorias', 'produtos', 'employees');

  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ VALIDAÇÕES DESATIVADAS!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Tabelas com RLS ativo: %', rls_count;
  RAISE NOTICE 'Triggers de tenant: %', trigger_count;
  RAISE NOTICE 'Políticas RLS: %', policy_count;
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 SISTEMA LIBERADO!';
  RAISE NOTICE '';
  RAISE NOTICE '✓ Agora você pode:';
  RAISE NOTICE '  • Adicionar registros financeiros';
  RAISE NOTICE '  • Criar itens no cardápio';
  RAISE NOTICE '  • Adicionar fornecedores';
  RAISE NOTICE '  • Cadastrar funcionários';
  RAISE NOTICE '  • Ver todas as categorias';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ ATENÇÃO:';
  RAISE NOTICE '  • O isolamento de dados FOI DESATIVADO';
  RAISE NOTICE '  • TODOS os usuários veem TODOS os dados';
  RAISE NOTICE '  • Use apenas para desenvolvimento/testes';
  RAISE NOTICE '  • Não use em produção!';
  RAISE NOTICE '';
  RAISE NOTICE '📝 Próximos passos:';
  RAISE NOTICE '  1. Use o sistema normalmente';
  RAISE NOTICE '  2. Depois, atribua tenant_id aos dados criados';
  RAISE NOTICE '  3. Reative o isolamento quando resolver o problema de auth';
  RAISE NOTICE '==============================================';
END $$;

COMMIT;

-- ============================================================================
-- 🚨 FIM - SISTEMA LIBERADO (SEM ISOLAMENTO)
-- ============================================================================

-- NOTA IMPORTANTE:
-- Este script REMOVE TEMPORARIAMENTE o isolamento de dados.
-- Use apenas para desenvolvimento ou até resolver o problema de autenticação.
-- Para reativar o isolamento, você precisará executar novamente os scripts
-- de migração com as correções apropriadas.
