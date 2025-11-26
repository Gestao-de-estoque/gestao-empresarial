-- ============================================================================
-- 🚨 CORREÇÃO URGENTE: Associar Usuários aos Tenants
-- Execute IMEDIATAMENTE no Supabase SQL Editor
-- ============================================================================

BEGIN;

-- ============================================================================
-- DIAGNÓSTICO: Ver o problema
-- ============================================================================

DO $$
DECLARE
  total_admin_users integer;
  total_tenant_users integer;
  users_without_tenant integer;
BEGIN
  SELECT COUNT(*) INTO total_admin_users FROM public.admin_users;
  SELECT COUNT(*) INTO total_tenant_users FROM public.tenant_users;

  SELECT COUNT(*) INTO users_without_tenant
  FROM public.admin_users au
  WHERE NOT EXISTS (
    SELECT 1 FROM public.tenant_users tu
    WHERE tu.admin_user_id = au.id
  );

  RAISE NOTICE '==============================================';
  RAISE NOTICE '🔍 DIAGNÓSTICO DO PROBLEMA';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Total de admin_users: %', total_admin_users;
  RAISE NOTICE 'Total de tenant_users: %', total_tenant_users;
  RAISE NOTICE 'Usuários SEM tenant: %', users_without_tenant;
  RAISE NOTICE '==============================================';

  IF users_without_tenant > 0 THEN
    RAISE NOTICE '⚠️ PROBLEMA: % usuários não estão associados a nenhum tenant!', users_without_tenant;
  END IF;
END $$;

-- ============================================================================
-- SOLUÇÃO 1: Associar TODOS os usuários órfãos ao primeiro tenant
-- ============================================================================

DO $$
DECLARE
  default_tenant uuid;
  admin_user_record RECORD;
  inserted_count integer := 0;
BEGIN
  -- Obter o primeiro tenant (mais antigo)
  SELECT id INTO default_tenant FROM public.tenants ORDER BY created_at LIMIT 1;

  IF default_tenant IS NULL THEN
    RAISE EXCEPTION 'ERRO CRÍTICO: Nenhum tenant encontrado! Crie um tenant primeiro.';
  END IF;

  RAISE NOTICE '📝 Associando usuários órfãos ao tenant: %', default_tenant;

  -- Para cada admin_user sem tenant_user, criar a associação
  FOR admin_user_record IN
    SELECT au.id, au.email, au.name
    FROM public.admin_users au
    WHERE NOT EXISTS (
      SELECT 1 FROM public.tenant_users tu
      WHERE tu.admin_user_id = au.id
    )
  LOOP
    -- Inserir na tabela tenant_users
    INSERT INTO public.tenant_users (
      tenant_id,
      admin_user_id,
      email,
      name,
      role,
      is_active,
      is_owner,
      joined_at,
      created_at,
      updated_at
    ) VALUES (
      default_tenant,
      admin_user_record.id,
      admin_user_record.email,
      COALESCE(admin_user_record.name, admin_user_record.email),
      'admin',
      true,
      true,  -- Primeiro usuário é owner
      NOW(),
      NOW(),
      NOW()
    );

    inserted_count := inserted_count + 1;
    RAISE NOTICE '  ✓ Usuário associado: % (ID: %)', admin_user_record.email, admin_user_record.id;
  END LOOP;

  RAISE NOTICE '✓ Total de usuários associados: %', inserted_count;
END $$;

-- ============================================================================
-- SOLUÇÃO 2: Permitir leitura de categorias para criar itens do menu
-- ============================================================================

-- Permitir leitura de categorias mesmo sem inserção
DROP POLICY IF EXISTS categorias_select_policy ON public.categorias;
CREATE POLICY categorias_select_policy ON public.categorias
  FOR SELECT
  TO authenticated
  USING (
    tenant_id = public.get_current_user_tenant_id()
    OR
    public.get_current_user_tenant_id() IS NOT NULL
  );

-- ============================================================================
-- SOLUÇÃO 3: Melhorar a função auto_set_tenant_id para dar erro mais claro
-- ============================================================================

CREATE OR REPLACE FUNCTION public.auto_set_tenant_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tenant_id uuid;
  v_user_id uuid;
  v_user_email text;
BEGIN
  IF NEW.tenant_id IS NULL THEN
    -- Obter o user_id autenticado
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
      RAISE EXCEPTION 'ERRO: Usuário não autenticado. Por favor, faça login novamente.';
    END IF;

    -- Tentar obter o tenant_id
    SELECT tenant_id INTO v_tenant_id
    FROM public.tenant_users
    WHERE admin_user_id = v_user_id AND is_active = true
    LIMIT 1;

    IF v_tenant_id IS NULL THEN
      -- Obter email do usuário para ajudar no debug
      SELECT email INTO v_user_email FROM public.admin_users WHERE id = v_user_id;

      RAISE EXCEPTION 'ERRO CRÍTICO: Usuário "%" (ID: %) não está associado a nenhum tenant. Entre em contato com o suporte.',
        COALESCE(v_user_email, 'desconhecido'), v_user_id;
    END IF;

    NEW.tenant_id := v_tenant_id;
  END IF;

  RETURN NEW;
END;
$$;

-- ============================================================================
-- SOLUÇÃO 4: Criar função helper para associar usuário a tenant
-- ============================================================================

CREATE OR REPLACE FUNCTION public.associate_user_to_tenant(
  p_admin_user_id uuid,
  p_tenant_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verificar se já existe associação
  IF EXISTS (
    SELECT 1 FROM public.tenant_users
    WHERE admin_user_id = p_admin_user_id
  ) THEN
    RAISE NOTICE 'Usuário já está associado a um tenant';
    RETURN;
  END IF;

  -- Criar associação
  INSERT INTO public.tenant_users (
    tenant_id,
    admin_user_id,
    email,
    name,
    role,
    is_active,
    is_owner,
    joined_at
  )
  SELECT
    p_tenant_id,
    au.id,
    au.email,
    COALESCE(au.name, au.email),
    'admin',
    true,
    false,
    NOW()
  FROM public.admin_users au
  WHERE au.id = p_admin_user_id;

  RAISE NOTICE 'Usuário associado ao tenant com sucesso';
END;
$$;

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  users_without_tenant integer;
  total_associations integer;
BEGIN
  -- Contar usuários sem tenant
  SELECT COUNT(*) INTO users_without_tenant
  FROM public.admin_users au
  WHERE NOT EXISTS (
    SELECT 1 FROM public.tenant_users tu
    WHERE tu.admin_user_id = au.id
  );

  -- Contar associações
  SELECT COUNT(*) INTO total_associations FROM public.tenant_users;

  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ CORREÇÃO CONCLUÍDA!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Usuários sem tenant: %', users_without_tenant;
  RAISE NOTICE 'Total de associações: %', total_associations;
  RAISE NOTICE '==============================================';

  IF users_without_tenant = 0 THEN
    RAISE NOTICE '🎉 SUCESSO: Todos os usuários estão associados a tenants!';
    RAISE NOTICE '';
    RAISE NOTICE '✓ Agora você pode:';
    RAISE NOTICE '  • Adicionar registros financeiros';
    RAISE NOTICE '  • Criar itens no cardápio';
    RAISE NOTICE '  • Adicionar fornecedores';
    RAISE NOTICE '  • Cadastrar funcionários';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ IMPORTANTE: Faça logout e login novamente!';
  ELSE
    RAISE WARNING '⚠️ Ainda existem % usuários sem tenant!', users_without_tenant;
    RAISE NOTICE 'Execute este script novamente ou use:';
    RAISE NOTICE 'SELECT public.associate_user_to_tenant(''user_id'', ''tenant_id'');';
  END IF;

  RAISE NOTICE '==============================================';
END $$;

COMMIT;

-- ============================================================================
-- 🚨 FIM DA CORREÇÃO
-- ============================================================================

-- INSTRUÇÕES APÓS EXECUÇÃO:
-- 1. FAÇA LOGOUT do sistema
-- 2. FAÇA LOGIN novamente
-- 3. Teste criar registros financeiros, fornecedores, etc.
-- 4. Se ainda der erro, execute: SELECT * FROM public.tenant_users WHERE admin_user_id = auth.uid();
