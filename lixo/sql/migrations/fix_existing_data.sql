-- ============================================================================
-- SCRIPT: Correção de Dados Existentes - Atribuição de tenant_id
-- Data: 2025-11-26
-- Descrição: Atribui tenant_id aos dados existentes no banco
-- ============================================================================

-- ATENÇÃO: Este script deve ser executado APÓS fix_tenant_isolation.sql
-- e ANTES de descomentar as constraints NOT NULL

-- ============================================================================
-- PARTE 1: ANÁLISE DOS TENANTS EXISTENTES
-- ============================================================================

-- Verificar quantos tenants existem
DO $$
DECLARE
  tenant_count integer;
BEGIN
  SELECT COUNT(*) INTO tenant_count FROM public.tenants;
  RAISE NOTICE 'Total de tenants encontrados: %', tenant_count;
END $$;

-- Listar todos os tenants
DO $$
DECLARE
  tenant_record RECORD;
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'TENANTS EXISTENTES:';
  RAISE NOTICE '==============================================';

  FOR tenant_record IN
    SELECT id, name, slug, email, created_at
    FROM public.tenants
    ORDER BY created_at
  LOOP
    RAISE NOTICE 'ID: % | Nome: % | Slug: % | Email: % | Criado em: %',
      tenant_record.id,
      tenant_record.name,
      tenant_record.slug,
      tenant_record.email,
      tenant_record.created_at;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 2: ESTRATÉGIA DE MIGRAÇÃO
-- ============================================================================

-- ESTRATÉGIA:
-- 1. Se houver apenas 1 tenant: atribuir todos os dados a ele
-- 2. Se houver múltiplos tenants:
--    a) Tentar identificar o tenant correto através de relações (created_by, etc)
--    b) Se não for possível, atribuir ao tenant mais antigo
--    c) Logs para revisão manual

-- ============================================================================
-- PARTE 3: FUNÇÃO AUXILIAR PARA OBTER TENANT PADRÃO
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_default_tenant_id()
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_tenant_id uuid;
  v_tenant_count integer;
BEGIN
  SELECT COUNT(*) INTO v_tenant_count FROM public.tenants;

  IF v_tenant_count = 0 THEN
    RAISE EXCEPTION 'Nenhum tenant encontrado no sistema. Crie pelo menos um tenant antes de executar esta migração.';
  END IF;

  -- Retornar o tenant mais antigo (primeiro criado)
  SELECT id INTO v_tenant_id
  FROM public.tenants
  ORDER BY created_at ASC
  LIMIT 1;

  RETURN v_tenant_id;
END;
$$;

-- ============================================================================
-- PARTE 4: ATRIBUIR tenant_id PARA DADOS ÓRFÃOS
-- ============================================================================

-- CATEGORIAS
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  UPDATE public.categorias
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[CATEGORIAS] % registros atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- PRODUTOS
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  -- Tentar atribuir pelo created_by se existir relação com tenant_users
  UPDATE public.produtos p
  SET tenant_id = tu.tenant_id
  FROM public.tenant_users tu
  WHERE p.created_by = tu.admin_user_id
    AND p.tenant_id IS NULL
    AND tu.is_active = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[PRODUTOS] % registros atualizados via created_by', updated_count;

  -- Atribuir restante ao tenant padrão
  UPDATE public.produtos
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[PRODUTOS] % registros órfãos atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- MENU ITEMS
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  -- Tentar atribuir pelo criado_por
  UPDATE public.menu_items mi
  SET tenant_id = tu.tenant_id
  FROM public.tenant_users tu
  WHERE mi.criado_por = tu.admin_user_id
    AND mi.tenant_id IS NULL
    AND tu.is_active = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[MENU_ITEMS] % registros atualizados via criado_por', updated_count;

  -- Atribuir restante ao tenant padrão
  UPDATE public.menu_items
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[MENU_ITEMS] % registros órfãos atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- MENU ITEM INGREDIENTES (herda do menu_item)
DO $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE public.menu_item_ingredientes mii
  SET tenant_id = mi.tenant_id
  FROM public.menu_items mi
  WHERE mii.menu_item_id = mi.id
    AND mii.tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[MENU_ITEM_INGREDIENTES] % registros atualizados via menu_items', updated_count;
END $$;

-- PLANEJAMENTO SEMANAL
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  -- Tentar atribuir pelo criado_por
  UPDATE public.planejamento_semanal ps
  SET tenant_id = tu.tenant_id
  FROM public.tenant_users tu
  WHERE ps.criado_por = tu.admin_user_id
    AND ps.tenant_id IS NULL
    AND tu.is_active = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[PLANEJAMENTO_SEMANAL] % registros atualizados via criado_por', updated_count;

  -- Atribuir restante ao tenant padrão
  UPDATE public.planejamento_semanal
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[PLANEJAMENTO_SEMANAL] % registros órfãos atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- MENU DIARIO (herda do planejamento_semanal)
DO $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE public.menu_diario md
  SET tenant_id = ps.tenant_id
  FROM public.planejamento_semanal ps
  WHERE md.planejamento_semanal_id = ps.id
    AND md.tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[MENU_DIARIO] % registros atualizados via planejamento_semanal', updated_count;
END $$;

-- MOVEMENTS
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  -- Tentar atribuir pelo created_by
  UPDATE public.movements m
  SET tenant_id = tu.tenant_id
  FROM public.tenant_users tu
  WHERE m.created_by = tu.admin_user_id
    AND m.tenant_id IS NULL
    AND tu.is_active = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[MOVEMENTS] % registros atualizados via created_by', updated_count;

  -- Tentar atribuir pelo product_id
  UPDATE public.movements m
  SET tenant_id = p.tenant_id
  FROM public.produtos p
  WHERE m.product_id = p.id
    AND m.tenant_id IS NULL
    AND p.tenant_id IS NOT NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[MOVEMENTS] % registros atualizados via product_id', updated_count;

  -- Atribuir restante ao tenant padrão
  UPDATE public.movements
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[MOVEMENTS] % registros órfãos atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- EMPLOYEES
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  UPDATE public.employees
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[EMPLOYEES] % registros atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- DAILY PAYMENTS (herda do employee)
DO $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE public.daily_payments dp
  SET tenant_id = e.tenant_id
  FROM public.employees e
  WHERE dp.employee_id = e.id
    AND dp.tenant_id IS NULL
    AND e.tenant_id IS NOT NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[DAILY_PAYMENTS] % registros atualizados via employees', updated_count;
END $$;

-- EMPLOYEE ATTENDANCE (herda do employee)
DO $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE public.employee_attendance ea
  SET tenant_id = e.tenant_id
  FROM public.employees e
  WHERE ea.employee_id = e.id
    AND ea.tenant_id IS NULL
    AND e.tenant_id IS NOT NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[EMPLOYEE_ATTENDANCE] % registros atualizados via employees', updated_count;
END $$;

-- EMPLOYEE BANK ACCOUNTS (herda do employee)
DO $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE public.employee_bank_accounts eba
  SET tenant_id = e.tenant_id
  FROM public.employees e
  WHERE eba.employee_id = e.id
    AND eba.tenant_id IS NULL
    AND e.tenant_id IS NOT NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[EMPLOYEE_BANK_ACCOUNTS] % registros atualizados via employees', updated_count;
END $$;

-- EMPLOYEE PERFORMANCE METRICS (herda do employee)
DO $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE public.employee_performance_metrics epm
  SET tenant_id = e.tenant_id
  FROM public.employees e
  WHERE epm.employee_id = e.id
    AND epm.tenant_id IS NULL
    AND e.tenant_id IS NOT NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[EMPLOYEE_PERFORMANCE_METRICS] % registros atualizados via employees', updated_count;
END $$;

-- SALARY CONFIGS
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  UPDATE public.salary_configs
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[SALARY_CONFIGS] % registros atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- PAYMENT AUDIT LOG
DO $$
DECLARE
  updated_count integer;
BEGIN
  -- Tentar atribuir pelo employee_id
  UPDATE public.payment_audit_log pal
  SET tenant_id = e.tenant_id
  FROM public.employees e
  WHERE pal.employee_id = e.id
    AND pal.tenant_id IS NULL
    AND e.tenant_id IS NOT NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[PAYMENT_AUDIT_LOG] % registros atualizados via employees', updated_count;
END $$;

-- FINANCIAL DATA
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  UPDATE public.financial_data
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[FINANCIAL_DATA] % registros atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- DAILY FINANCIAL SUMMARY
DO $$
DECLARE
  updated_count integer;
BEGIN
  -- Tentar atribuir pelo financial_data_id
  UPDATE public.daily_financial_summary dfs
  SET tenant_id = fd.tenant_id
  FROM public.financial_data fd
  WHERE dfs.financial_data_id = fd.id
    AND dfs.tenant_id IS NULL
    AND fd.tenant_id IS NOT NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[DAILY_FINANCIAL_SUMMARY] % registros atualizados via financial_data', updated_count;

  -- Atribuir restante ao tenant padrão
  DECLARE
    default_tenant_id uuid;
  BEGIN
    default_tenant_id := public.get_default_tenant_id();

    UPDATE public.daily_financial_summary
    SET tenant_id = default_tenant_id
    WHERE tenant_id IS NULL;

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RAISE NOTICE '[DAILY_FINANCIAL_SUMMARY] % registros órfãos atualizados com tenant_id: %', updated_count, default_tenant_id;
  END;
END $$;

-- REPORTS
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  -- Tentar atribuir pelo generated_by
  UPDATE public.reports r
  SET tenant_id = tu.tenant_id
  FROM public.tenant_users tu
  WHERE r.generated_by = tu.admin_user_id
    AND r.tenant_id IS NULL
    AND tu.is_active = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[REPORTS] % registros atualizados via generated_by', updated_count;

  -- Atribuir restante ao tenant padrão
  UPDATE public.reports
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[REPORTS] % registros órfãos atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- APP SETTINGS
DO $$
DECLARE
  updated_count integer;
BEGIN
  -- Tentar atribuir pelo user_id
  UPDATE public.app_settings aps
  SET tenant_id = tu.tenant_id
  FROM public.tenant_users tu
  WHERE aps.user_id = tu.admin_user_id
    AND aps.tenant_id IS NULL
    AND tu.is_active = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[APP_SETTINGS] % registros atualizados via user_id', updated_count;

  -- Atribuir restante ao tenant padrão
  DECLARE
    default_tenant_id uuid;
  BEGIN
    default_tenant_id := public.get_default_tenant_id();

    UPDATE public.app_settings
    SET tenant_id = default_tenant_id
    WHERE tenant_id IS NULL;

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RAISE NOTICE '[APP_SETTINGS] % registros órfãos atualizados com tenant_id: %', updated_count, default_tenant_id;
  END;
END $$;

-- SUPPLIERS
DO $$
DECLARE
  updated_count integer;
  default_tenant_id uuid;
BEGIN
  default_tenant_id := public.get_default_tenant_id();

  UPDATE public.suppliers
  SET tenant_id = default_tenant_id
  WHERE tenant_id IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE '[SUPPLIERS] % registros atualizados com tenant_id: %', updated_count, default_tenant_id;
END $$;

-- ============================================================================
-- PARTE 5: VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  table_name text;
  null_count integer;
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'VERIFICAÇÃO FINAL - Registros sem tenant_id:';
  RAISE NOTICE '==============================================';

  FOR table_name IN
    SELECT unnest(ARRAY[
      'categorias',
      'produtos',
      'menu_items',
      'menu_item_ingredientes',
      'planejamento_semanal',
      'menu_diario',
      'movements',
      'employees',
      'daily_payments',
      'employee_attendance',
      'employee_bank_accounts',
      'employee_performance_metrics',
      'salary_configs',
      'payment_audit_log',
      'financial_data',
      'daily_financial_summary',
      'reports',
      'app_settings',
      'suppliers'
    ])
  LOOP
    EXECUTE format('SELECT COUNT(*) FROM public.%I WHERE tenant_id IS NULL', table_name)
    INTO null_count;

    IF null_count > 0 THEN
      RAISE WARNING '[%] ainda possui % registros sem tenant_id - REQUER ATENÇÃO!', table_name, null_count;
    ELSE
      RAISE NOTICE '[%] OK - todos os registros possuem tenant_id', table_name;
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- PARTE 6: CRIAR TABELA DE LOG DE MIGRAÇÃO
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.migration_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  migration_name text NOT NULL,
  executed_at timestamp with time zone DEFAULT now(),
  details jsonb,
  status text DEFAULT 'completed'
);

-- Registrar esta migração
INSERT INTO public.migration_log (migration_name, details, status)
VALUES (
  'fix_existing_data',
  jsonb_build_object(
    'description', 'Atribuição de tenant_id aos dados existentes',
    'date', '2025-11-26',
    'executed_by', 'migration_script'
  ),
  'completed'
);

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================

RAISE NOTICE '==============================================';
RAISE NOTICE 'MIGRAÇÃO CONCLUÍDA!';
RAISE NOTICE '==============================================';
RAISE NOTICE 'Próximos passos:';
RAISE NOTICE '1. Revisar os logs acima para garantir que todos os dados foram migrados';
RAISE NOTICE '2. Verificar se há registros sem tenant_id (warnings acima)';
RAISE NOTICE '3. Descomentar as constraints NOT NULL em fix_tenant_isolation.sql';
RAISE NOTICE '4. Testar todas as funcionalidades do sistema';
RAISE NOTICE '5. Monitorar logs de erro relacionados a RLS';
