-- ====================================================================
-- SCRIPT DE TESTE: VALIDAÇÃO DO ISOLAMENTO DE DADOS
-- ====================================================================
-- Este script testa se o isolamento de dados está funcionando corretamente
-- Execute após rodar o FIX_USER_ISOLATION.sql
-- ====================================================================

-- ====================================================================
-- TESTE 1: Verificar se as funções foram criadas
-- ====================================================================

DO $$
DECLARE
  func_count INTEGER;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'TESTE 1: Verificando Funções';
  RAISE NOTICE '====================================';

  -- Verifica current_user_id
  SELECT COUNT(*) INTO func_count
  FROM pg_proc
  WHERE proname = 'current_user_id';

  IF func_count > 0 THEN
    RAISE NOTICE '✓ Função current_user_id() encontrada';
  ELSE
    RAISE WARNING '✗ Função current_user_id() NÃO encontrada!';
  END IF;

  -- Verifica set_created_by
  SELECT COUNT(*) INTO func_count
  FROM pg_proc
  WHERE proname = 'set_created_by';

  IF func_count > 0 THEN
    RAISE NOTICE '✓ Função set_created_by() encontrada';
  ELSE
    RAISE WARNING '✗ Função set_created_by() NÃO encontrada!';
  END IF;

  -- Verifica current_user_tenant_id
  SELECT COUNT(*) INTO func_count
  FROM pg_proc
  WHERE proname = 'current_user_tenant_id';

  IF func_count > 0 THEN
    RAISE NOTICE '✓ Função current_user_tenant_id() encontrada';
  ELSE
    RAISE WARNING '✗ Função current_user_tenant_id() NÃO encontrada!';
  END IF;
END $$;


-- ====================================================================
-- TESTE 2: Verificar se os campos created_by foram adicionados
-- ====================================================================

DO $$
DECLARE
  column_count INTEGER;
  total_columns INTEGER := 0;
  expected_columns INTEGER := 7;
  missing_table TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'TESTE 2: Verificando Campos created_by';
  RAISE NOTICE '====================================';

  -- Lista de tabelas que devem ter created_by
  FOR column_count IN
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name IN (
      'employees',
      'financial_data',
      'suppliers',
      'categorias',
      'menu_diario',
      'menu_item_ingredientes',
      'planejamento_semanal'
    )
    AND column_name = 'created_by'
  LOOP
    total_columns := total_columns + column_count;
  END LOOP;

  RAISE NOTICE 'Campos created_by encontrados: % de %', total_columns, expected_columns;

  IF total_columns = expected_columns THEN
    RAISE NOTICE '✓ Todos os campos created_by foram adicionados!';
  ELSE
    RAISE WARNING '✗ Alguns campos created_by estão faltando!';

    -- Lista quais tabelas não têm o campo
    RAISE NOTICE '';
    RAISE NOTICE 'Tabelas SEM created_by:';

    FOR missing_table IN
      SELECT table_name
      FROM (
        VALUES
          ('employees'),
          ('financial_data'),
          ('suppliers'),
          ('categorias'),
          ('menu_diario'),
          ('menu_item_ingredientes'),
          ('planejamento_semanal')
      ) AS t(table_name)
      WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND columns.table_name = t.table_name
        AND column_name = 'created_by'
      )
    LOOP
      RAISE NOTICE '  - %', missing_table;
    END LOOP;
  END IF;
END $$;


-- ====================================================================
-- TESTE 3: Verificar se os triggers foram criados
-- ====================================================================

DO $$
DECLARE
  trigger_count INTEGER;
  trigger_name TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'TESTE 3: Verificando Triggers';
  RAISE NOTICE '====================================';

  SELECT COUNT(*) INTO trigger_count
  FROM pg_trigger
  WHERE tgname LIKE 'set_created_by%';

  RAISE NOTICE 'Triggers set_created_by encontrados: %', trigger_count;

  IF trigger_count >= 7 THEN
    RAISE NOTICE '✓ Triggers criados com sucesso!';
  ELSE
    RAISE WARNING '✗ Alguns triggers estão faltando!';
  END IF;

  -- Lista os triggers criados
  RAISE NOTICE '';
  RAISE NOTICE 'Triggers criados:';

  FOR trigger_name IN
    SELECT tgname
    FROM pg_trigger
    WHERE tgname LIKE 'set_created_by%'
    ORDER BY tgname
  LOOP
    RAISE NOTICE '  ✓ %', trigger_name;
  END LOOP;
END $$;


-- ====================================================================
-- TESTE 4: Verificar se as políticas RLS foram criadas
-- ====================================================================

DO $$
DECLARE
  policy_count INTEGER;
  table_name TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'TESTE 4: Verificando Políticas RLS';
  RAISE NOTICE '====================================';

  -- Verifica políticas para cada tabela crítica
  FOR table_name IN
    VALUES
      ('employees'),
      ('financial_data'),
      ('suppliers'),
      ('produtos'),
      ('menu_items'),
      ('movements')
  LOOP
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'public'
    AND tablename = table_name
    AND policyname LIKE '%_strict';

    IF policy_count >= 4 THEN
      RAISE NOTICE '✓ % - % políticas (SELECT, INSERT, UPDATE, DELETE)', table_name, policy_count;
    ELSE
      RAISE WARNING '✗ % - Apenas % políticas encontradas!', table_name, policy_count;
    END IF;
  END LOOP;
END $$;


-- ====================================================================
-- TESTE 5: Verificar se RLS está habilitado
-- ====================================================================

DO $$
DECLARE
  table_name TEXT;
  rls_enabled BOOLEAN;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'TESTE 5: Verificando RLS Habilitado';
  RAISE NOTICE '====================================';

  -- Verifica RLS para cada tabela crítica
  FOR table_name IN
    VALUES
      ('employees'),
      ('financial_data'),
      ('suppliers'),
      ('produtos'),
      ('menu_items'),
      ('movements'),
      ('categorias')
  LOOP
    SELECT rowsecurity INTO rls_enabled
    FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = table_name;

    IF rls_enabled THEN
      RAISE NOTICE '✓ % - RLS habilitado', table_name;
    ELSE
      RAISE WARNING '✗ % - RLS NÃO habilitado!', table_name;
    END IF;
  END LOOP;
END $$;


-- ====================================================================
-- TESTE 6: Testar as funções com dados reais
-- ====================================================================

DO $$
DECLARE
  user_id UUID;
  tenant_id UUID;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'TESTE 6: Testando Funções com Dados Reais';
  RAISE NOTICE '====================================';

  -- Testa current_user_tenant_id
  BEGIN
    tenant_id := public.current_user_tenant_id();

    IF tenant_id IS NULL THEN
      RAISE NOTICE '⚠ current_user_tenant_id() retornou NULL (normal se não estiver logado)';
    ELSE
      RAISE NOTICE '✓ current_user_tenant_id() = %', tenant_id;

      -- Testa current_user_id
      user_id := public.current_user_id();

      IF user_id IS NULL THEN
        RAISE NOTICE '⚠ current_user_id() retornou NULL';
      ELSE
        RAISE NOTICE '✓ current_user_id() = %', user_id;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING '✗ Erro ao testar funções: %', SQLERRM;
  END;
END $$;


-- ====================================================================
-- TESTE 7: Verificar estrutura das políticas
-- ====================================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'TESTE 7: Estrutura das Políticas RLS';
  RAISE NOTICE '====================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Políticas que filtram por created_by:';
END $$;

SELECT
  tablename,
  policyname,
  CASE
    WHEN cmd = 'r' THEN 'SELECT'
    WHEN cmd = 'a' THEN 'INSERT'
    WHEN cmd = 'w' THEN 'UPDATE'
    WHEN cmd = 'd' THEN 'DELETE'
    ELSE cmd
  END as comando,
  CASE
    WHEN qual LIKE '%created_by%' OR qual LIKE '%criado_por%' OR qual LIKE '%generated_by%' THEN '✓'
    ELSE '✗'
  END as usa_created_by
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN (
  'employees',
  'financial_data',
  'suppliers',
  'produtos',
  'menu_items',
  'movements'
)
AND policyname LIKE '%_strict'
ORDER BY tablename, policyname;


-- ====================================================================
-- RESUMO FINAL
-- ====================================================================

DO $$
DECLARE
  func_ok BOOLEAN;
  campos_ok BOOLEAN;
  triggers_ok BOOLEAN;
  policies_ok BOOLEAN;
  rls_ok BOOLEAN;
  func_count INTEGER;
  campos_count INTEGER;
  trigger_count INTEGER;
  policy_count INTEGER;
  rls_count INTEGER;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE 'RESUMO FINAL - VALIDAÇÃO DO ISOLAMENTO DE DADOS';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';

  -- Verifica funções
  SELECT COUNT(*) INTO func_count
  FROM pg_proc
  WHERE proname IN ('current_user_id', 'set_created_by', 'current_user_tenant_id');
  func_ok := func_count >= 3;

  -- Verifica campos
  SELECT COUNT(*) INTO campos_count
  FROM information_schema.columns
  WHERE table_schema = 'public'
  AND table_name IN (
    'employees', 'financial_data', 'suppliers',
    'categorias', 'menu_diario', 'menu_item_ingredientes', 'planejamento_semanal'
  )
  AND column_name = 'created_by';
  campos_ok := campos_count >= 7;

  -- Verifica triggers
  SELECT COUNT(*) INTO trigger_count
  FROM pg_trigger
  WHERE tgname LIKE 'set_created_by%';
  triggers_ok := trigger_count >= 7;

  -- Verifica políticas
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'public'
  AND policyname LIKE '%_strict';
  policies_ok := policy_count >= 24; -- 6 tabelas x 4 operações

  -- Verifica RLS
  SELECT COUNT(*) INTO rls_count
  FROM pg_tables
  WHERE schemaname = 'public'
  AND tablename IN ('employees', 'financial_data', 'suppliers', 'produtos', 'menu_items', 'movements', 'categorias')
  AND rowsecurity = true;
  rls_ok := rls_count >= 7;

  -- Mostra resumo
  IF func_ok THEN
    RAISE NOTICE '✓ Funções: % de 3', func_count;
  ELSE
    RAISE WARNING '✗ Funções: % de 3 - INCOMPLETO!', func_count;
  END IF;

  IF campos_ok THEN
    RAISE NOTICE '✓ Campos created_by: % de 7', campos_count;
  ELSE
    RAISE WARNING '✗ Campos created_by: % de 7 - INCOMPLETO!', campos_count;
  END IF;

  IF triggers_ok THEN
    RAISE NOTICE '✓ Triggers: % (mínimo 7)', trigger_count;
  ELSE
    RAISE WARNING '✗ Triggers: % - INCOMPLETO!', trigger_count;
  END IF;

  IF policies_ok THEN
    RAISE NOTICE '✓ Políticas RLS: % (mínimo 24)', policy_count;
  ELSE
    RAISE WARNING '✗ Políticas RLS: % - INCOMPLETO!', policy_count;
  END IF;

  IF rls_ok THEN
    RAISE NOTICE '✓ RLS Habilitado: % de 7 tabelas', rls_count;
  ELSE
    RAISE WARNING '✗ RLS Habilitado: % de 7 - INCOMPLETO!', rls_count;
  END IF;

  RAISE NOTICE '';

  IF func_ok AND campos_ok AND triggers_ok AND policies_ok AND rls_ok THEN
    RAISE NOTICE '====================================================================';
    RAISE NOTICE '✓✓✓ PARABÉNS! TODAS AS CORREÇÕES FORAM APLICADAS COM SUCESSO! ✓✓✓';
    RAISE NOTICE '====================================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Próximos passos:';
    RAISE NOTICE '1. Teste o sistema com 2 usuários diferentes';
    RAISE NOTICE '2. Verifique que cada um vê apenas seus próprios dados';
    RAISE NOTICE '3. Atualize os services do frontend (veja GUIA_CORRECAO_ISOLAMENTO.md)';
    RAISE NOTICE '';
  ELSE
    RAISE WARNING '====================================================================';
    RAISE WARNING '✗✗✗ ATENÇÃO! ALGUMAS CORREÇÕES NÃO FORAM APLICADAS! ✗✗✗';
    RAISE WARNING '====================================================================';
    RAISE WARNING '';
    RAISE WARNING 'Execute novamente o script: src/sql/FIX_USER_ISOLATION.sql';
    RAISE WARNING '';
  END IF;
END $$;
