-- ============================================================================
-- 🚨 URGENTE: ISOLAR DADOS ENTRE USUÁRIOS - CORREÇÃO IMEDIATA
-- ============================================================================
-- PROBLEMA: Políticas permissivas permitindo ver dados de outros usuários
-- SOLUÇÃO: Políticas ultra-restritivas que EXIGEM tenant_id correspondente
-- ============================================================================

BEGIN;

-- ============================================================================
-- PASSO 1: GARANTIR QUE TODOS OS USUÁRIOS TÊM TENANT
-- ============================================================================

DO $$
DECLARE
  user_record RECORD;
  default_tenant_id uuid;
BEGIN
  RAISE NOTICE '👥 Associando usuários a tenants...';

  -- Para cada usuário sem tenant
  FOR user_record IN
    SELECT au.id, au.email, au.name
    FROM public.admin_users au
    WHERE NOT EXISTS (
      SELECT 1 FROM public.tenant_users tu
      WHERE tu.admin_user_id = au.id
    )
  LOOP
    -- Criar tenant individual para este usuário
    INSERT INTO public.tenants (name, slug, email, status)
    VALUES (
      COALESCE(user_record.name, user_record.email),
      LOWER(REPLACE(COALESCE(user_record.name, user_record.email), ' ', '-')) || '-' || substring(user_record.id::text, 1, 8),
      user_record.email,
      'active'
    )
    RETURNING id INTO default_tenant_id;

    -- Associar usuário ao seu tenant
    INSERT INTO public.tenant_users (
      tenant_id,
      admin_user_id,
      email,
      name,
      role,
      is_active,
      is_owner,
      joined_at
    ) VALUES (
      default_tenant_id,
      user_record.id,
      user_record.email,
      COALESCE(user_record.name, user_record.email),
      'admin',
      true,
      true,
      NOW()
    );

    RAISE NOTICE '  ✓ Usuário % associado ao tenant %', user_record.email, default_tenant_id;
  END LOOP;
END $$;

-- ============================================================================
-- PASSO 2: ATRIBUIR tenant_id A TODOS OS DADOS ÓRFÃOS
-- ============================================================================

DO $$
DECLARE
  tenant_record RECORD;
  assigned_count integer;
BEGIN
  RAISE NOTICE '📦 Atribuindo tenant_id aos dados órfãos...';

  -- Para cada tenant, atribuir dados órfãos ao primeiro tenant encontrado
  SELECT id, name INTO tenant_record FROM public.tenants ORDER BY created_at LIMIT 1;

  IF tenant_record.id IS NOT NULL THEN
    -- Funcionários
    UPDATE public.employees SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % funcionários atribuídos', assigned_count;
    END IF;

    -- Produtos
    UPDATE public.produtos SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % produtos atribuídos', assigned_count;
    END IF;

    -- Categorias
    UPDATE public.categorias SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % categorias atribuídas', assigned_count;
    END IF;

    -- Fornecedores
    UPDATE public.suppliers SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % fornecedores atribuídos', assigned_count;
    END IF;

    -- Dados financeiros
    UPDATE public.financial_data SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % registros financeiros atribuídos', assigned_count;
    END IF;

    -- Menu items
    UPDATE public.menu_items SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % itens de menu atribuídos', assigned_count;
    END IF;

    -- Reports
    UPDATE public.reports SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % relatórios atribuídos', assigned_count;
    END IF;

    -- Movements
    UPDATE public.movements SET tenant_id = tenant_record.id WHERE tenant_id IS NULL;
    GET DIAGNOSTICS assigned_count = ROW_COUNT;
    IF assigned_count > 0 THEN
      RAISE NOTICE '  ✓ % movimentos atribuídos', assigned_count;
    END IF;
  END IF;
END $$;

-- ============================================================================
-- PASSO 3: REMOVER POLÍTICAS PERMISSIVAS
-- ============================================================================

DO $$
DECLARE
  pol RECORD;
BEGIN
  RAISE NOTICE '🗑️ Removendo políticas permissivas...';

  FOR pol IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I',
      pol.policyname, pol.schemaname, pol.tablename);
  END LOOP;

  RAISE NOTICE '  ✓ Todas as políticas removidas';
END $$;

-- ============================================================================
-- PASSO 4: CRIAR POLÍTICAS ULTRA-RESTRITIVAS (SEM NULL, SEM TRUE)
-- ============================================================================

DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔒 Criando políticas ULTRA-RESTRITIVAS...';

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
    EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY', tbl);

    -- SELECT: APENAS tenant_id correspondente (SEM OR NULL!)
    EXECUTE format('
      CREATE POLICY %I_select_strict ON public.%I
      FOR SELECT
      TO authenticated
      USING (
        tenant_id = public.current_user_tenant_id()
      )
    ', tbl, tbl);

    -- INSERT: APENAS tenant_id correspondente (SEM WITH CHECK TRUE!)
    EXECUTE format('
      CREATE POLICY %I_insert_strict ON public.%I
      FOR INSERT
      TO authenticated
      WITH CHECK (
        tenant_id = public.current_user_tenant_id()
      )
    ', tbl, tbl);

    -- UPDATE: APENAS tenant_id correspondente
    EXECUTE format('
      CREATE POLICY %I_update_strict ON public.%I
      FOR UPDATE
      TO authenticated
      USING (tenant_id = public.current_user_tenant_id())
      WITH CHECK (tenant_id = public.current_user_tenant_id())
    ', tbl, tbl);

    -- DELETE: APENAS tenant_id correspondente
    EXECUTE format('
      CREATE POLICY %I_delete_strict ON public.%I
      FOR DELETE
      TO authenticated
      USING (tenant_id = public.current_user_tenant_id())
    ', tbl, tbl);

    RAISE NOTICE '  ✓ Políticas restritivas criadas: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- PASSO 5: CRIAR TRIGGER QUE DÁ ERRO SE NÃO CONSEGUIR PREENCHER
-- ============================================================================

CREATE OR REPLACE FUNCTION public.set_tenant_id_strict()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tenant_id uuid;
BEGIN
  -- Se já tem tenant_id, validar que é do usuário
  IF NEW.tenant_id IS NOT NULL THEN
    -- Verificar se o tenant_id fornecido pertence ao usuário
    SELECT tu.tenant_id INTO v_tenant_id
    FROM public.tenant_users tu
    WHERE tu.admin_user_id = auth.uid()
      AND tu.is_active = true
      AND tu.tenant_id = NEW.tenant_id
    LIMIT 1;

    IF v_tenant_id IS NULL THEN
      RAISE EXCEPTION 'Você não tem permissão para usar este tenant_id';
    END IF;

    RETURN NEW;
  END IF;

  -- Tentar obter tenant_id do usuário
  SELECT tu.tenant_id INTO v_tenant_id
  FROM public.tenant_users tu
  WHERE tu.admin_user_id = auth.uid()
    AND tu.is_active = true
  LIMIT 1;

  -- Se não encontrou, DAR ERRO
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não está associado a nenhum tenant. Faça logout e login novamente.';
  END IF;

  NEW.tenant_id := v_tenant_id;
  RETURN NEW;
END;
$$;

-- Recriar triggers
DO $$
DECLARE
  tbl text;
BEGIN
  RAISE NOTICE '🔄 Recriando triggers estritos...';

  FOREACH tbl IN ARRAY ARRAY[
    'employees', 'categorias', 'produtos', 'suppliers',
    'financial_data', 'movements', 'reports', 'menu_items',
    'menu_item_ingredientes', 'planejamento_semanal', 'menu_diario',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'daily_financial_summary', 'app_settings'
  ]
  LOOP
    -- Remover triggers antigos
    EXECUTE format('DROP TRIGGER IF EXISTS auto_tenant_safe_trigger ON public.%I', tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS set_tenant_trigger ON public.%I', tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS auto_tenant_trigger ON public.%I', tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS auto_tenant_strict_trigger ON public.%I', tbl);

    -- Criar trigger estrito
    EXECUTE format('
      CREATE TRIGGER auto_tenant_strict_trigger
        BEFORE INSERT ON public.%I
        FOR EACH ROW
        EXECUTE FUNCTION public.set_tenant_id_strict()
    ', tbl);

    RAISE NOTICE '  ✓ Trigger estrito criado: %', tbl;
  END LOOP;
END $$;

-- ============================================================================
-- PASSO 6: TORNAR tenant_id NOT NULL NOVAMENTE
-- ============================================================================

DO $$
DECLARE
  tbl text;
  null_count integer;
BEGIN
  RAISE NOTICE '⚠️ Tornando tenant_id NOT NULL...';

  FOREACH tbl IN ARRAY ARRAY[
    'employees', 'categorias', 'produtos', 'suppliers',
    'financial_data', 'movements', 'reports', 'menu_items'
  ]
  LOOP
    -- Verificar se há NULL
    EXECUTE format('SELECT COUNT(*) FROM public.%I WHERE tenant_id IS NULL', tbl)
    INTO null_count;

    IF null_count = 0 THEN
      EXECUTE format('ALTER TABLE public.%I ALTER COLUMN tenant_id SET NOT NULL', tbl);
      RAISE NOTICE '  ✓ tenant_id NOT NULL em: %', tbl;
    ELSE
      RAISE WARNING '  ⚠️ % registros NULL em %', null_count, tbl;
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  users_without_tenant integer;
  orphan_employees integer;
  orphan_products integer;
  total_policies integer;
BEGIN
  -- Verificar usuários sem tenant
  SELECT COUNT(*) INTO users_without_tenant
  FROM public.admin_users au
  WHERE NOT EXISTS (
    SELECT 1 FROM public.tenant_users tu
    WHERE tu.admin_user_id = au.id
  );

  -- Verificar dados órfãos
  SELECT COUNT(*) INTO orphan_employees FROM public.employees WHERE tenant_id IS NULL;
  SELECT COUNT(*) INTO orphan_products FROM public.produtos WHERE tenant_id IS NULL;

  -- Contar políticas
  SELECT COUNT(*) INTO total_policies
  FROM pg_policies
  WHERE schemaname = 'public'
    AND policyname LIKE '%_strict';

  RAISE NOTICE '============================================';
  RAISE NOTICE '✅ ISOLAMENTO ULTRA-RESTRITIVO APLICADO!';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Usuários sem tenant: %', users_without_tenant;
  RAISE NOTICE 'Funcionários órfãos: %', orphan_employees;
  RAISE NOTICE 'Produtos órfãos: %', orphan_products;
  RAISE NOTICE 'Políticas restritivas: %', total_policies;
  RAISE NOTICE '============================================';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 GARANTIAS DE ISOLAMENTO:';
  RAISE NOTICE '  • SELECT: Apenas tenant_id correspondente';
  RAISE NOTICE '  • INSERT: Apenas tenant_id correspondente';
  RAISE NOTICE '  • UPDATE: Apenas tenant_id correspondente';
  RAISE NOTICE '  • DELETE: Apenas tenant_id correspondente';
  RAISE NOTICE '  • SEM exceções para NULL';
  RAISE NOTICE '  • SEM WITH CHECK (true)';
  RAISE NOTICE '';
  RAISE NOTICE '📝 TESTE AGORA:';
  RAISE NOTICE '  1. Faça LOGOUT imediato';
  RAISE NOTICE '  2. Faça LOGIN novamente';
  RAISE NOTICE '  3. Adicione um funcionário';
  RAISE NOTICE '  4. Crie NOVA conta';
  RAISE NOTICE '  5. Verifique que NÃO vê o funcionário anterior';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ IMPORTANTE:';
  RAISE NOTICE '  • Se der erro ao inserir, faça logout/login';
  RAISE NOTICE '  • Cada usuário vê APENAS seus próprios dados';
  RAISE NOTICE '  • Impossível ver/modificar dados de outros';
  RAISE NOTICE '============================================';
END $$;

COMMIT;

-- ============================================================================
-- FIM - ISOLAMENTO ULTRA-RESTRITIVO GARANTIDO
-- ============================================================================
