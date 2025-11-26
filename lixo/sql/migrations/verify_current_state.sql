-- ============================================================================
-- SCRIPT: Verificação do Estado Atual do Banco de Dados
-- Data: 2025-11-26
-- Descrição: Verifica o estado atual antes da migração
-- ============================================================================

\echo '=============================================='
\echo 'RELATÓRIO DE ESTADO ATUAL DO BANCO DE DADOS'
\echo '=============================================='
\echo ''

-- ============================================================================
-- 1. VERIFICAR TENANTS EXISTENTES
-- ============================================================================
\echo '1. TENANTS EXISTENTES:'
\echo '=============================================='
SELECT
  id,
  name,
  slug,
  email,
  status,
  created_at,
  current_users
FROM public.tenants
ORDER BY created_at;

\echo ''
\echo 'Total de tenants:'
SELECT COUNT(*) as total_tenants FROM public.tenants;

\echo ''
\echo '=============================================='
\echo '2. TENANT USERS (Usuários por Tenant):'
\echo '=============================================='
SELECT
  t.name as tenant_name,
  tu.email as user_email,
  tu.role,
  tu.is_active,
  tu.joined_at
FROM public.tenant_users tu
JOIN public.tenants t ON tu.tenant_id = t.id
ORDER BY t.name, tu.joined_at;

\echo ''
\echo 'Total de usuários por tenant:'
SELECT
  t.name as tenant_name,
  COUNT(tu.id) as total_users
FROM public.tenants t
LEFT JOIN public.tenant_users tu ON t.id = tu.tenant_id
GROUP BY t.name
ORDER BY t.name;

-- ============================================================================
-- 3. VERIFICAR SE COLUNAS tenant_id EXISTEM
-- ============================================================================
\echo ''
\echo '=============================================='
\echo '3. VERIFICAR EXISTÊNCIA DE COLUNAS tenant_id:'
\echo '=============================================='
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name = 'tenant_id'
ORDER BY table_name;

-- ============================================================================
-- 4. VERIFICAR DADOS SEM tenant_id (ÓRFÃOS)
-- ============================================================================
\echo ''
\echo '=============================================='
\echo '4. ANÁLISE DE DADOS ÓRFÃOS (sem tenant_id):'
\echo '=============================================='

\echo ''
\echo 'CATEGORIAS:'
SELECT
  'Total de registros' as tipo,
  COUNT(*) as quantidade
FROM public.categorias
UNION ALL
SELECT
  'Com tenant_id' as tipo,
  COUNT(*) as quantidade
FROM public.categorias
WHERE tenant_id IS NOT NULL
UNION ALL
SELECT
  'SEM tenant_id (ÓRFÃOS)' as tipo,
  COUNT(*) as quantidade
FROM public.categorias
WHERE tenant_id IS NULL;

\echo ''
\echo 'PRODUTOS:'
SELECT
  'Total de registros' as tipo,
  COUNT(*) as quantidade
FROM public.produtos
UNION ALL
SELECT
  'Com tenant_id' as tipo,
  COUNT(*) as quantidade
FROM public.produtos
WHERE tenant_id IS NOT NULL
UNION ALL
SELECT
  'SEM tenant_id (ÓRFÃOS)' as tipo,
  COUNT(*) as quantidade
FROM public.produtos
WHERE tenant_id IS NULL;

\echo ''
\echo 'MENU ITEMS:'
SELECT
  'Total de registros' as tipo,
  COUNT(*) as quantidade
FROM public.menu_items
UNION ALL
SELECT
  'Com tenant_id' as tipo,
  COUNT(*) as quantidade
FROM public.menu_items
WHERE tenant_id IS NOT NULL
UNION ALL
SELECT
  'SEM tenant_id (ÓRFÃOS)' as tipo,
  COUNT(*) as quantidade
FROM public.menu_items
WHERE tenant_id IS NULL;

\echo ''
\echo 'EMPLOYEES:'
SELECT
  'Total de registros' as tipo,
  COUNT(*) as quantidade
FROM public.employees
UNION ALL
SELECT
  'Com tenant_id' as tipo,
  COUNT(*) as quantidade
FROM public.employees
WHERE tenant_id IS NOT NULL
UNION ALL
SELECT
  'SEM tenant_id (ÓRFÃOS)' as tipo,
  COUNT(*) as quantidade
FROM public.employees
WHERE tenant_id IS NULL;

\echo ''
\echo 'FINANCIAL DATA:'
SELECT
  'Total de registros' as tipo,
  COUNT(*) as quantidade
FROM public.financial_data
UNION ALL
SELECT
  'Com tenant_id' as tipo,
  COUNT(*) as quantidade
FROM public.financial_data
WHERE tenant_id IS NOT NULL
UNION ALL
SELECT
  'SEM tenant_id (ÓRFÃOS)' as tipo,
  COUNT(*) as quantidade
FROM public.financial_data
WHERE tenant_id IS NULL;

\echo ''
\echo 'MOVEMENTS:'
SELECT
  'Total de registros' as tipo,
  COUNT(*) as quantidade
FROM public.movements
UNION ALL
SELECT
  'Com tenant_id' as tipo,
  COUNT(*) as quantidade
FROM public.movements
WHERE tenant_id IS NOT NULL
UNION ALL
SELECT
  'SEM tenant_id (ÓRFÃOS)' as tipo,
  COUNT(*) as quantidade
FROM public.movements
WHERE tenant_id IS NULL;

-- ============================================================================
-- 5. VERIFICAR POLÍTICAS RLS EXISTENTES
-- ============================================================================
\echo ''
\echo '=============================================='
\echo '5. POLÍTICAS RLS EXISTENTES:'
\echo '=============================================='
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'categorias',
    'produtos',
    'menu_items',
    'employees',
    'financial_data',
    'movements'
  )
ORDER BY tablename, policyname;

\echo ''
\echo 'Total de políticas RLS por tabela:'
SELECT
  tablename,
  COUNT(*) as total_policies
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- ============================================================================
-- 6. VERIFICAR TABELAS COM RLS HABILITADO
-- ============================================================================
\echo ''
\echo '=============================================='
\echo '6. TABELAS COM RLS HABILITADO:'
\echo '=============================================='
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
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
  )
ORDER BY tablename;

-- ============================================================================
-- 7. VERIFICAR ÍNDICES EM tenant_id
-- ============================================================================
\echo ''
\echo '=============================================='
\echo '7. ÍNDICES EM tenant_id:'
\echo '=============================================='
SELECT
  t.tablename,
  i.indexname,
  i.indexdef
FROM pg_indexes i
JOIN pg_tables t ON i.tablename = t.tablename
WHERE t.schemaname = 'public'
  AND i.indexdef LIKE '%tenant_id%'
ORDER BY t.tablename;

-- ============================================================================
-- 8. RESUMO EXECUTIVO
-- ============================================================================
\echo ''
\echo '=============================================='
\echo '8. RESUMO EXECUTIVO:'
\echo '=============================================='

\echo ''
\echo 'Total de Tenants:'
SELECT COUNT(*) as total FROM public.tenants;

\echo ''
\echo 'Tabelas com coluna tenant_id:'
SELECT COUNT(DISTINCT table_name) as total
FROM information_schema.columns
WHERE table_schema = 'public' AND column_name = 'tenant_id';

\echo ''
\echo 'Tabelas com RLS habilitado:'
SELECT COUNT(*) as total
FROM pg_tables
WHERE schemaname = 'public' AND rowsecurity = true;

\echo ''
\echo 'Total de políticas RLS:'
SELECT COUNT(*) as total
FROM pg_policies
WHERE schemaname = 'public';

\echo ''
\echo '=============================================='
\echo 'FIM DO RELATÓRIO'
\echo '=============================================='
