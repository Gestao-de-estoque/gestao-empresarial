-- ============================================================================
-- 🔧 CORRIGIR: Função current_user_tenant_id() e RLS em tenant_users
-- ============================================================================

BEGIN;

-- ============================================================================
-- PASSO 1: DESABILITAR RLS EM TABELAS DE AUTENTICAÇÃO
-- ============================================================================

-- CRÍTICO: tenant_users NÃO PODE TER RLS ou a função não funciona!
ALTER TABLE public.tenant_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users DISABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  RAISE NOTICE '✓ RLS desabilitado em tenant_users, tenants, admin_users';
END $$;

-- ============================================================================
-- PASSO 2: RECRIAR FUNÇÃO current_user_tenant_id() CORRETAMENTE
-- ============================================================================

DROP FUNCTION IF EXISTS public.current_user_tenant_id();

CREATE OR REPLACE FUNCTION public.current_user_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT tenant_id
  FROM public.tenant_users
  WHERE admin_user_id = auth.uid()
    AND is_active = true
  LIMIT 1;
$$;

COMMENT ON FUNCTION public.current_user_tenant_id IS 'Retorna tenant_id do usuário autenticado (SECURITY DEFINER bypassa RLS)';

DO $$ BEGIN
  RAISE NOTICE '✓ Função current_user_tenant_id() recriada';
END $$;

-- ============================================================================
-- PASSO 3: RECRIAR FUNÇÃO DO TRIGGER
-- ============================================================================

DROP FUNCTION IF EXISTS public.set_tenant_id_strict() CASCADE;

CREATE OR REPLACE FUNCTION public.set_tenant_id_strict()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tenant_id uuid;
BEGIN
  -- Se já tem tenant_id, validar
  IF NEW.tenant_id IS NOT NULL THEN
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

  -- Obter tenant_id do usuário
  SELECT tu.tenant_id INTO v_tenant_id
  FROM public.tenant_users tu
  WHERE tu.admin_user_id = auth.uid()
    AND tu.is_active = true
  LIMIT 1;

  -- Se não encontrou, dar erro
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não está associado a nenhum tenant. Faça logout e login novamente.';
  END IF;

  NEW.tenant_id := v_tenant_id;
  RETURN NEW;
END;
$$;

DO $$ BEGIN
  RAISE NOTICE '✓ Função set_tenant_id_strict() recriada';
END $$;

-- ============================================================================
-- PASSO 4: VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
  rls_tenant_users boolean;
  rls_tenants boolean;
  rls_admin_users boolean;
  function_exists boolean;
BEGIN
  -- Verificar RLS
  SELECT relrowsecurity INTO rls_tenant_users
  FROM pg_class
  WHERE relname = 'tenant_users' AND relnamespace = 'public'::regnamespace;

  SELECT relrowsecurity INTO rls_tenants
  FROM pg_class
  WHERE relname = 'tenants' AND relnamespace = 'public'::regnamespace;

  SELECT relrowsecurity INTO rls_admin_users
  FROM pg_class
  WHERE relname = 'admin_users' AND relnamespace = 'public'::regnamespace;

  -- Verificar função
  SELECT EXISTS (
    SELECT 1 FROM pg_proc
    WHERE proname = 'current_user_tenant_id'
  ) INTO function_exists;

  RAISE NOTICE '============================================';
  RAISE NOTICE '✅ FUNÇÃO E RLS CORRIGIDOS!';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'RLS em tenant_users: %', CASE WHEN rls_tenant_users THEN '❌ HABILITADO (ERRO!)' ELSE '✅ DESABILITADO (OK)' END;
  RAISE NOTICE 'RLS em tenants: %', CASE WHEN rls_tenants THEN '❌ HABILITADO (ERRO!)' ELSE '✅ DESABILITADO (OK)' END;
  RAISE NOTICE 'RLS em admin_users: %', CASE WHEN rls_admin_users THEN '❌ HABILITADO (ERRO!)' ELSE '✅ DESABILITADO (OK)' END;
  RAISE NOTICE 'Função existe: %', CASE WHEN function_exists THEN '✅ SIM' ELSE '❌ NÃO' END;
  RAISE NOTICE '============================================';
  RAISE NOTICE '';
  RAISE NOTICE '📝 TESTE AGORA:';
  RAISE NOTICE '  1. Limpe cache do navegador (Ctrl+Shift+R)';
  RAISE NOTICE '  2. OU abra janela anônima';
  RAISE NOTICE '  3. Faça LOGIN';
  RAISE NOTICE '  4. Tente adicionar fornecedor';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ Se ainda der erro:';
  RAISE NOTICE '  Execute VER_TODOS_USUARIOS.sql';
  RAISE NOTICE '  E me mostre os resultados';
  RAISE NOTICE '============================================';
END $$;

COMMIT;

-- ============================================================================
-- FIM - FUNÇÃO E RLS CORRIGIDOS
-- ============================================================================
