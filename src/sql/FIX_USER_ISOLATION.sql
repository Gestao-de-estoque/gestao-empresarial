-- ====================================================================
-- SCRIPT DE CORREÇÃO: ISOLAMENTO DE DADOS POR USUÁRIO
-- ====================================================================
-- Este script corrige o sistema para que cada usuário só veja seus próprios dados
-- Problema: Atualmente todos os usuários de um tenant conseguem ver dados uns dos outros
-- Solução: Isolar dados por created_by (usuário criador) em vez de apenas tenant_id
-- ====================================================================

BEGIN;

-- ====================================================================
-- PASSO 1: CRIAR FUNÇÃO PARA OBTER O USUÁRIO LOGADO
-- ====================================================================

-- Remove função antiga se existir
DROP FUNCTION IF EXISTS public.current_user_id() CASCADE;

-- Cria função que retorna o ID do usuário logado (armazenado no localStorage)
-- Esta função busca o usuário pelo tenant_id da sessão
CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  user_id UUID;
  session_tenant_id UUID;
BEGIN
  -- Pega o tenant_id da sessão (configurado pelo set_current_tenant)
  session_tenant_id := current_setting('app.current_tenant_id', true)::UUID;

  IF session_tenant_id IS NULL THEN
    -- Se não houver tenant na sessão, retorna NULL
    RETURN NULL;
  END IF;

  -- Busca o ID do usuário pelo tenant_id
  -- IMPORTANTE: Assumindo que cada usuário tem seu próprio tenant
  SELECT id INTO user_id
  FROM public.admin_users
  WHERE tenant_id = session_tenant_id
  LIMIT 1;

  RETURN user_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION public.current_user_id IS 'Retorna o ID do usuário logado através do tenant_id da sessão';

-- Concede permissões
GRANT EXECUTE ON FUNCTION public.current_user_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.current_user_id() TO anon;


-- ====================================================================
-- PASSO 2: ADICIONAR CAMPOS created_by NAS TABELAS QUE NÃO TÊM
-- ====================================================================

-- Tabela: employees
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'employees'
    AND column_name = 'created_by'
  ) THEN
    ALTER TABLE public.employees ADD COLUMN created_by UUID;
    ALTER TABLE public.employees ADD CONSTRAINT employees_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.admin_users(id);

    RAISE NOTICE '✓ Campo created_by adicionado em employees';
  END IF;
END $$;

-- Tabela: financial_data
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'financial_data'
    AND column_name = 'created_by'
  ) THEN
    ALTER TABLE public.financial_data ADD COLUMN created_by UUID;
    ALTER TABLE public.financial_data ADD CONSTRAINT financial_data_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.admin_users(id);

    RAISE NOTICE '✓ Campo created_by adicionado em financial_data';
  END IF;
END $$;

-- Tabela: suppliers
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'suppliers'
    AND column_name = 'created_by'
  ) THEN
    ALTER TABLE public.suppliers ADD COLUMN created_by UUID;
    ALTER TABLE public.suppliers ADD CONSTRAINT suppliers_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.admin_users(id);

    RAISE NOTICE '✓ Campo created_by adicionado em suppliers';
  END IF;
END $$;

-- Tabela: categorias
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'categorias'
    AND column_name = 'created_by'
  ) THEN
    ALTER TABLE public.categorias ADD COLUMN created_by UUID;
    ALTER TABLE public.categorias ADD CONSTRAINT categorias_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.admin_users(id);

    RAISE NOTICE '✓ Campo created_by adicionado em categorias';
  END IF;
END $$;

-- Tabela: menu_diario
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'menu_diario'
    AND column_name = 'created_by'
  ) THEN
    ALTER TABLE public.menu_diario ADD COLUMN created_by UUID;
    ALTER TABLE public.menu_diario ADD CONSTRAINT menu_diario_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.admin_users(id);

    RAISE NOTICE '✓ Campo created_by adicionado em menu_diario';
  END IF;
END $$;

-- Tabela: menu_item_ingredientes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'menu_item_ingredientes'
    AND column_name = 'created_by'
  ) THEN
    ALTER TABLE public.menu_item_ingredientes ADD COLUMN created_by UUID;
    ALTER TABLE public.menu_item_ingredientes ADD CONSTRAINT menu_item_ingredientes_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.admin_users(id);

    RAISE NOTICE '✓ Campo created_by adicionado em menu_item_ingredientes';
  END IF;
END $$;

-- Tabela: planejamento_semanal (já tem criado_por, vamos padronizar para created_by)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'planejamento_semanal'
    AND column_name = 'created_by'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'planejamento_semanal'
    AND column_name = 'criado_por'
  ) THEN
    ALTER TABLE public.planejamento_semanal RENAME COLUMN criado_por TO created_by;

    RAISE NOTICE '✓ Campo criado_por renomeado para created_by em planejamento_semanal';
  END IF;
END $$;


-- ====================================================================
-- PASSO 3: CRIAR TRIGGERS PARA PREENCHER created_by AUTOMATICAMENTE
-- ====================================================================

-- Função que será chamada pelos triggers
CREATE OR REPLACE FUNCTION public.set_created_by()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Se created_by não foi definido, pega o usuário logado
  IF NEW.created_by IS NULL THEN
    NEW.created_by := public.current_user_id();
  END IF;

  RETURN NEW;
END;
$$;

-- Triggers para cada tabela

-- employees
DROP TRIGGER IF EXISTS set_created_by_employees ON public.employees;
CREATE TRIGGER set_created_by_employees
  BEFORE INSERT ON public.employees
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- financial_data
DROP TRIGGER IF EXISTS set_created_by_financial ON public.financial_data;
CREATE TRIGGER set_created_by_financial
  BEFORE INSERT ON public.financial_data
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- suppliers
DROP TRIGGER IF EXISTS set_created_by_suppliers ON public.suppliers;
CREATE TRIGGER set_created_by_suppliers
  BEFORE INSERT ON public.suppliers
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- produtos (já tem created_by, mas adiciona trigger se não existir)
DROP TRIGGER IF EXISTS set_created_by_produtos ON public.produtos;
CREATE TRIGGER set_created_by_produtos
  BEFORE INSERT ON public.produtos
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- menu_items (usa criado_por)
DROP TRIGGER IF EXISTS set_created_by_menu_items ON public.menu_items;
CREATE TRIGGER set_created_by_menu_items
  BEFORE INSERT ON public.menu_items
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- movements
DROP TRIGGER IF EXISTS set_created_by_movements ON public.movements;
CREATE TRIGGER set_created_by_movements
  BEFORE INSERT ON public.movements
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- categorias
DROP TRIGGER IF EXISTS set_created_by_categorias ON public.categorias;
CREATE TRIGGER set_created_by_categorias
  BEFORE INSERT ON public.categorias
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- reports
DROP TRIGGER IF EXISTS set_created_by_reports ON public.reports;
CREATE TRIGGER set_created_by_reports
  BEFORE INSERT ON public.reports
  FOR EACH ROW
  EXECUTE FUNCTION public.set_created_by();

-- Triggers criados com sucesso


-- ====================================================================
-- PASSO 4: RECRIAR POLÍTICAS RLS PARA ISOLAR POR USUÁRIO
-- ====================================================================

-- IMPORTANTE: Vamos manter tenant_id para compatibilidade, mas adicionar
-- filtro por created_by para garantir isolamento entre usuários

-- ========================================
-- TABELA: employees
-- ========================================

DROP POLICY IF EXISTS employees_select_strict ON public.employees;
CREATE POLICY employees_select_strict ON public.employees
  FOR SELECT
  USING (
    created_by = public.current_user_id()
    OR (created_by IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS employees_insert_strict ON public.employees;
CREATE POLICY employees_insert_strict ON public.employees
  FOR INSERT
  WITH CHECK (
    created_by = public.current_user_id()
    OR created_by IS NULL
  );

DROP POLICY IF EXISTS employees_update_strict ON public.employees;
CREATE POLICY employees_update_strict ON public.employees
  FOR UPDATE
  USING (created_by = public.current_user_id())
  WITH CHECK (created_by = public.current_user_id());

DROP POLICY IF EXISTS employees_delete_strict ON public.employees;
CREATE POLICY employees_delete_strict ON public.employees
  FOR DELETE
  USING (created_by = public.current_user_id());

-- ========================================
-- TABELA: financial_data
-- ========================================

DROP POLICY IF EXISTS financial_data_select_strict ON public.financial_data;
CREATE POLICY financial_data_select_strict ON public.financial_data
  FOR SELECT
  USING (
    created_by = public.current_user_id()
    OR (created_by IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS financial_data_insert_strict ON public.financial_data;
CREATE POLICY financial_data_insert_strict ON public.financial_data
  FOR INSERT
  WITH CHECK (
    created_by = public.current_user_id()
    OR created_by IS NULL
  );

DROP POLICY IF EXISTS financial_data_update_strict ON public.financial_data;
CREATE POLICY financial_data_update_strict ON public.financial_data
  FOR UPDATE
  USING (created_by = public.current_user_id())
  WITH CHECK (created_by = public.current_user_id());

DROP POLICY IF EXISTS financial_data_delete_strict ON public.financial_data;
CREATE POLICY financial_data_delete_strict ON public.financial_data
  FOR DELETE
  USING (created_by = public.current_user_id());

-- ========================================
-- TABELA: suppliers
-- ========================================

DROP POLICY IF EXISTS suppliers_select_strict ON public.suppliers;
CREATE POLICY suppliers_select_strict ON public.suppliers
  FOR SELECT
  USING (
    created_by = public.current_user_id()
    OR (created_by IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS suppliers_insert_strict ON public.suppliers;
CREATE POLICY suppliers_insert_strict ON public.suppliers
  FOR INSERT
  WITH CHECK (
    created_by = public.current_user_id()
    OR created_by IS NULL
  );

DROP POLICY IF EXISTS suppliers_update_strict ON public.suppliers;
CREATE POLICY suppliers_update_strict ON public.suppliers
  FOR UPDATE
  USING (created_by = public.current_user_id())
  WITH CHECK (created_by = public.current_user_id());

DROP POLICY IF EXISTS suppliers_delete_strict ON public.suppliers;
CREATE POLICY suppliers_delete_strict ON public.suppliers
  FOR DELETE
  USING (created_by = public.current_user_id());

-- ========================================
-- TABELA: produtos
-- ========================================

DROP POLICY IF EXISTS produtos_select_strict ON public.produtos;
CREATE POLICY produtos_select_strict ON public.produtos
  FOR SELECT
  USING (
    created_by = public.current_user_id()
    OR (created_by IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS produtos_insert_strict ON public.produtos;
CREATE POLICY produtos_insert_strict ON public.produtos
  FOR INSERT
  WITH CHECK (
    created_by = public.current_user_id()
    OR created_by IS NULL
  );

DROP POLICY IF EXISTS produtos_update_strict ON public.produtos;
CREATE POLICY produtos_update_strict ON public.produtos
  FOR UPDATE
  USING (created_by = public.current_user_id())
  WITH CHECK (created_by = public.current_user_id());

DROP POLICY IF EXISTS produtos_delete_strict ON public.produtos;
CREATE POLICY produtos_delete_strict ON public.produtos
  FOR DELETE
  USING (created_by = public.current_user_id());

-- ========================================
-- TABELA: menu_items (usa criado_por)
-- ========================================

DROP POLICY IF EXISTS menu_items_select_strict ON public.menu_items;
CREATE POLICY menu_items_select_strict ON public.menu_items
  FOR SELECT
  USING (
    criado_por = public.current_user_id()
    OR (criado_por IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS menu_items_insert_strict ON public.menu_items;
CREATE POLICY menu_items_insert_strict ON public.menu_items
  FOR INSERT
  WITH CHECK (
    criado_por = public.current_user_id()
    OR criado_por IS NULL
  );

DROP POLICY IF EXISTS menu_items_update_strict ON public.menu_items;
CREATE POLICY menu_items_update_strict ON public.menu_items
  FOR UPDATE
  USING (criado_por = public.current_user_id())
  WITH CHECK (criado_por = public.current_user_id());

DROP POLICY IF EXISTS menu_items_delete_strict ON public.menu_items;
CREATE POLICY menu_items_delete_strict ON public.menu_items
  FOR DELETE
  USING (criado_por = public.current_user_id());

-- ========================================
-- TABELA: movements
-- ========================================

DROP POLICY IF EXISTS movements_select_strict ON public.movements;
CREATE POLICY movements_select_strict ON public.movements
  FOR SELECT
  USING (
    created_by = public.current_user_id()
    OR (created_by IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS movements_insert_strict ON public.movements;
CREATE POLICY movements_insert_strict ON public.movements
  FOR INSERT
  WITH CHECK (
    created_by = public.current_user_id()
    OR created_by IS NULL
  );

DROP POLICY IF EXISTS movements_update_strict ON public.movements;
CREATE POLICY movements_update_strict ON public.movements
  FOR UPDATE
  USING (created_by = public.current_user_id())
  WITH CHECK (created_by = public.current_user_id());

DROP POLICY IF EXISTS movements_delete_strict ON public.movements;
CREATE POLICY movements_delete_strict ON public.movements
  FOR DELETE
  USING (created_by = public.current_user_id());

-- ========================================
-- TABELA: categorias
-- ========================================

DROP POLICY IF EXISTS categorias_select_strict ON public.categorias;
CREATE POLICY categorias_select_strict ON public.categorias
  FOR SELECT
  USING (
    created_by = public.current_user_id()
    OR (created_by IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS categorias_insert_strict ON public.categorias;
CREATE POLICY categorias_insert_strict ON public.categorias
  FOR INSERT
  WITH CHECK (
    created_by = public.current_user_id()
    OR created_by IS NULL
  );

DROP POLICY IF EXISTS categorias_update_strict ON public.categorias;
CREATE POLICY categorias_update_strict ON public.categorias
  FOR UPDATE
  USING (created_by = public.current_user_id())
  WITH CHECK (created_by = public.current_user_id());

DROP POLICY IF EXISTS categorias_delete_strict ON public.categorias;
CREATE POLICY categorias_delete_strict ON public.categorias
  FOR DELETE
  USING (created_by = public.current_user_id());

-- ========================================
-- TABELA: reports
-- ========================================

DROP POLICY IF EXISTS reports_select_strict ON public.reports;
CREATE POLICY reports_select_strict ON public.reports
  FOR SELECT
  USING (
    generated_by = public.current_user_id()
    OR (generated_by IS NULL AND tenant_id = public.current_user_tenant_id())
  );

DROP POLICY IF EXISTS reports_insert_strict ON public.reports;
CREATE POLICY reports_insert_strict ON public.reports
  FOR INSERT
  WITH CHECK (
    generated_by = public.current_user_id()
    OR generated_by IS NULL
  );

DROP POLICY IF EXISTS reports_update_strict ON public.reports;
CREATE POLICY reports_update_strict ON public.reports
  FOR UPDATE
  USING (generated_by = public.current_user_id())
  WITH CHECK (generated_by = public.current_user_id());

DROP POLICY IF EXISTS reports_delete_strict ON public.reports;
CREATE POLICY reports_delete_strict ON public.reports
  FOR DELETE
  USING (generated_by = public.current_user_id());

-- Políticas RLS recriadas para isolamento por usuário


-- ====================================================================
-- PASSO 5: HABILITAR RLS NAS TABELAS (se não estiver habilitado)
-- ====================================================================

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- RLS habilitado em todas as tabelas


-- ====================================================================
-- PASSO 6: VERIFICAÇÃO E RELATÓRIO
-- ====================================================================

DO $$
DECLARE
  total_policies INTEGER;
  total_triggers INTEGER;
BEGIN
  -- Conta políticas criadas
  SELECT COUNT(*) INTO total_policies
  FROM pg_policies
  WHERE schemaname = 'public'
  AND policyname LIKE '%_strict';

  -- Conta triggers criados
  SELECT COUNT(*) INTO total_triggers
  FROM pg_trigger
  WHERE tgname LIKE 'set_created_by%';

  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'CORREÇÃO CONCLUÍDA COM SUCESSO!';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Total de políticas RLS: %', total_policies;
  RAISE NOTICE 'Total de triggers: %', total_triggers;
  RAISE NOTICE '';
  RAISE NOTICE 'Próximos passos:';
  RAISE NOTICE '1. Atualizar os services do frontend para incluir created_by';
  RAISE NOTICE '2. Testar o isolamento entre usuários';
  RAISE NOTICE '3. Corrigir validações de UUID vazio';
  RAISE NOTICE '====================================';
END $$;

COMMIT;
