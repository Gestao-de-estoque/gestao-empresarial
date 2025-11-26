-- ============================================================================
-- 🧪 TESTE DE ISOLAMENTO ENTRE TENANTS
-- Execute APÓS o script de emergência para verificar o isolamento
-- ============================================================================

-- ============================================================================
-- TESTE 1: Verificar se RLS está ativo
-- ============================================================================

SELECT
  tablename,
  CASE
    WHEN rowsecurity THEN '✓ RLS ATIVO'
    ELSE '✗ RLS INATIVO'
  END as status,
  CASE
    WHEN rowsecurity THEN '🟢'
    ELSE '🔴'
  END as indicador
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'categorias', 'produtos', 'menu_items', 'movements',
    'employees', 'financial_data', 'reports'
  )
ORDER BY tablename;

-- ============================================================================
-- TESTE 2: Contar políticas RLS por tabela
-- ============================================================================

SELECT
  tablename,
  COUNT(*) as total_policies,
  string_agg(DISTINCT cmd::text, ', ' ORDER BY cmd::text) as operations,
  CASE
    WHEN COUNT(*) >= 4 THEN '✓ Completo'
    WHEN COUNT(*) > 0 THEN '⚠️ Parcial'
    ELSE '✗ Sem políticas'
  END as status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'categorias', 'produtos', 'menu_items', 'movements',
    'employees', 'financial_data', 'reports'
  )
GROUP BY tablename
ORDER BY tablename;

-- ============================================================================
-- TESTE 3: Verificar se há dados órfãos (SEM tenant_id)
-- ============================================================================

SELECT
  'categorias' as tabela,
  COUNT(*) as sem_tenant_id,
  CASE
    WHEN COUNT(*) = 0 THEN '✓ OK'
    ELSE '✗ PROBLEMA'
  END as status
FROM public.categorias WHERE tenant_id IS NULL
UNION ALL
SELECT 'produtos', COUNT(*), CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ PROBLEMA' END
FROM public.produtos WHERE tenant_id IS NULL
UNION ALL
SELECT 'menu_items', COUNT(*), CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ PROBLEMA' END
FROM public.menu_items WHERE tenant_id IS NULL
UNION ALL
SELECT 'employees', COUNT(*), CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ PROBLEMA' END
FROM public.employees WHERE tenant_id IS NULL
UNION ALL
SELECT 'movements', COUNT(*), CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ PROBLEMA' END
FROM public.movements WHERE tenant_id IS NULL;

-- ============================================================================
-- TESTE 4: Verificar distribuição de dados por tenant
-- ============================================================================

SELECT
  t.name as tenant,
  t.slug,
  (SELECT COUNT(*) FROM public.produtos WHERE tenant_id = t.id) as produtos,
  (SELECT COUNT(*) FROM public.categorias WHERE tenant_id = t.id) as categorias,
  (SELECT COUNT(*) FROM public.employees WHERE tenant_id = t.id) as funcionarios,
  (SELECT COUNT(*) FROM public.movements WHERE tenant_id = t.id) as movimentos
FROM public.tenants t
ORDER BY t.created_at;

-- ============================================================================
-- TESTE 5: Verificar se função get_current_user_tenant_id existe
-- ============================================================================

SELECT
  routine_name,
  routine_type,
  security_type,
  CASE
    WHEN routine_name = 'get_current_user_tenant_id' THEN '✓ Encontrada'
    ELSE '✗ Não encontrada'
  END as status
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%tenant%';

-- ============================================================================
-- TESTE 6: Verificar triggers de auto-preenchimento
-- ============================================================================

SELECT
  trigger_schema,
  trigger_name,
  event_object_table as tabela,
  action_timing,
  event_manipulation,
  '✓ Trigger ativo' as status
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE '%tenant%'
ORDER BY event_object_table;

-- ============================================================================
-- RESUMO DO TESTE
-- ============================================================================

DO $$
DECLARE
  total_tables_with_rls integer;
  total_policies integer;
  total_orphans integer;
  total_tenants integer;
BEGIN
  -- Contar tabelas com RLS
  SELECT COUNT(*) INTO total_tables_with_rls
  FROM pg_tables
  WHERE schemaname = 'public'
    AND rowsecurity = true
    AND tablename IN (
      'categorias', 'produtos', 'menu_items', 'movements',
      'employees', 'financial_data', 'reports', 'suppliers'
    );

  -- Contar políticas
  SELECT COUNT(*) INTO total_policies
  FROM pg_policies
  WHERE schemaname = 'public';

  -- Contar órfãos
  SELECT COUNT(*) INTO total_orphans
  FROM (
    SELECT id FROM public.produtos WHERE tenant_id IS NULL
    UNION ALL
    SELECT id FROM public.categorias WHERE tenant_id IS NULL
    UNION ALL
    SELECT id FROM public.employees WHERE tenant_id IS NULL
  ) sub;

  -- Contar tenants
  SELECT COUNT(*) INTO total_tenants FROM public.tenants;

  RAISE NOTICE '==============================================';
  RAISE NOTICE '📊 RESUMO DO TESTE DE ISOLAMENTO';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Total de tenants: %', total_tenants;
  RAISE NOTICE 'Tabelas com RLS ativo: % de 19', total_tables_with_rls;
  RAISE NOTICE 'Total de políticas RLS: %', total_policies;
  RAISE NOTICE 'Registros órfãos: %', total_orphans;
  RAISE NOTICE '==============================================';

  IF total_orphans = 0 AND total_policies >= 76 THEN
    RAISE NOTICE '✅ ISOLAMENTO CONFIGURADO CORRETAMENTE!';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 PRÓXIMO PASSO: Teste manual';
    RAISE NOTICE '  1. Faça login com dois usuários diferentes';
    RAISE NOTICE '  2. Crie dados com o primeiro usuário';
    RAISE NOTICE '  3. Verifique que o segundo usuário NÃO vê esses dados';
  ELSE
    RAISE WARNING '⚠️ PROBLEMAS DETECTADOS!';
    IF total_orphans > 0 THEN
      RAISE WARNING '  • % registros sem tenant_id', total_orphans;
    END IF;
    IF total_policies < 76 THEN
      RAISE WARNING '  • Poucas políticas RLS (esperado: 76+, atual: %)', total_policies;
    END IF;
    RAISE NOTICE '';
    RAISE NOTICE '🔧 AÇÃO NECESSÁRIA: Execute o script de emergência novamente';
  END IF;

  RAISE NOTICE '==============================================';
END $$;
