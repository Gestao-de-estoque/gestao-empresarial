-- ============================================================================
-- QUERIES ÚTEIS PARA DIAGNÓSTICO E MONITORAMENTO
-- Data: 2025-11-26
-- ============================================================================

-- ============================================================================
-- 1. VERIFICAÇÃO RÁPIDA DE ISOLAMENTO
-- ============================================================================

-- Ver quantos registros cada tenant possui em cada tabela
SELECT
  t.name as tenant_name,
  'categorias' as tabela,
  COUNT(c.id) as total_registros
FROM public.tenants t
LEFT JOIN public.categorias c ON t.id = c.tenant_id
GROUP BY t.name
UNION ALL
SELECT
  t.name,
  'produtos' as tabela,
  COUNT(p.id)
FROM public.tenants t
LEFT JOIN public.produtos p ON t.id = p.tenant_id
GROUP BY t.name
UNION ALL
SELECT
  t.name,
  'menu_items' as tabela,
  COUNT(mi.id)
FROM public.tenants t
LEFT JOIN public.menu_items mi ON t.id = mi.tenant_id
GROUP BY t.name
UNION ALL
SELECT
  t.name,
  'employees' as tabela,
  COUNT(e.id)
FROM public.tenants t
LEFT JOIN public.employees e ON t.id = e.tenant_id
GROUP BY t.name
ORDER BY tenant_name, tabela;

-- ============================================================================
-- 2. IDENTIFICAR REGISTROS ÓRFÃOS (sem tenant_id)
-- ============================================================================

-- Categorias órfãs
SELECT 'categorias' as tabela, id, nome, created_at
FROM public.categorias
WHERE tenant_id IS NULL;

-- Produtos órfãos
SELECT 'produtos' as tabela, id, nome, created_at
FROM public.produtos
WHERE tenant_id IS NULL;

-- Menu items órfãos
SELECT 'menu_items' as tabela, id, nome, created_at
FROM public.menu_items
WHERE tenant_id IS NULL;

-- Funcionários órfãos
SELECT 'employees' as tabela, id, name, email, created_at
FROM public.employees
WHERE tenant_id IS NULL;

-- Financial data órfão
SELECT 'financial_data' as tabela, id, full_day, amount, created_at
FROM public.financial_data
WHERE tenant_id IS NULL;

-- ============================================================================
-- 3. VERIFICAR INTEGRIDADE REFERENCIAL
-- ============================================================================

-- Verificar se produtos pertencem ao mesmo tenant que suas categorias
SELECT
  p.id as produto_id,
  p.nome as produto_nome,
  p.tenant_id as produto_tenant_id,
  c.id as categoria_id,
  c.nome as categoria_nome,
  c.tenant_id as categoria_tenant_id
FROM public.produtos p
JOIN public.categorias c ON p.categoria_id = c.id
WHERE p.tenant_id != c.tenant_id;
-- Não deve retornar nada

-- Verificar se menu_items pertencem ao mesmo tenant que seus produtos
SELECT
  mi.id as menu_item_id,
  mi.nome as menu_item_nome,
  mi.tenant_id as menu_item_tenant_id,
  p.id as produto_id,
  p.nome as produto_nome,
  p.tenant_id as produto_tenant_id
FROM public.menu_item_ingredientes mii
JOIN public.menu_items mi ON mii.menu_item_id = mi.id
JOIN public.produtos p ON mii.produto_id = p.id
WHERE mi.tenant_id != p.tenant_id;
-- Não deve retornar nada

-- Verificar se funcionários e seus pagamentos estão no mesmo tenant
SELECT
  e.id as employee_id,
  e.name as employee_name,
  e.tenant_id as employee_tenant_id,
  dp.id as payment_id,
  dp.final_amount,
  dp.tenant_id as payment_tenant_id
FROM public.daily_payments dp
JOIN public.employees e ON dp.employee_id = e.id
WHERE e.tenant_id != dp.tenant_id;
-- Não deve retornar nada

-- ============================================================================
-- 4. ESTATÍSTICAS POR TENANT
-- ============================================================================

-- Resumo completo por tenant
SELECT
  t.name as tenant,
  t.email,
  t.status,
  t.created_at,
  (SELECT COUNT(*) FROM public.tenant_users WHERE tenant_id = t.id) as users,
  (SELECT COUNT(*) FROM public.categorias WHERE tenant_id = t.id) as categorias,
  (SELECT COUNT(*) FROM public.produtos WHERE tenant_id = t.id) as produtos,
  (SELECT COUNT(*) FROM public.menu_items WHERE tenant_id = t.id) as menu_items,
  (SELECT COUNT(*) FROM public.employees WHERE tenant_id = t.id) as funcionarios,
  (SELECT COUNT(*) FROM public.financial_data WHERE tenant_id = t.id) as registros_financeiros
FROM public.tenants t
ORDER BY t.created_at;

-- ============================================================================
-- 5. VERIFICAR POLÍTICAS RLS ATIVAS
-- ============================================================================

-- Listar todas as políticas RLS ativas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd as operacao,
  CASE
    WHEN cmd = 'SELECT' THEN 'Leitura'
    WHEN cmd = 'INSERT' THEN 'Criação'
    WHEN cmd = 'UPDATE' THEN 'Atualização'
    WHEN cmd = 'DELETE' THEN 'Exclusão'
    ELSE cmd
  END as tipo_operacao
FROM pg_policies
WHERE schemaname = 'public'
  AND policyname LIKE '%tenant_isolation%'
ORDER BY tablename, cmd;

-- Verificar quais tabelas têm RLS habilitado
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_habilitado,
  CASE
    WHEN rowsecurity THEN '✓ Ativo'
    ELSE '✗ Inativo'
  END as status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'categorias', 'produtos', 'menu_items', 'menu_item_ingredientes',
    'planejamento_semanal', 'menu_diario', 'movements', 'employees',
    'daily_payments', 'employee_attendance', 'employee_bank_accounts',
    'employee_performance_metrics', 'salary_configs', 'payment_audit_log',
    'financial_data', 'daily_financial_summary', 'reports',
    'app_settings', 'suppliers'
  )
ORDER BY tablename;

-- ============================================================================
-- 6. TESTE DE ACESSO (Simular usuário específico)
-- ============================================================================

-- Substitua 'SEU_USER_ID' pelo ID do admin_user que deseja testar
-- Substitua 'SEU_TENANT_ID' pelo ID do tenant que o usuário pertence

-- Ver o que o usuário consegue acessar
DO $$
DECLARE
  test_user_id uuid := 'SEU_USER_ID';  -- Substitua aqui
  test_tenant_id uuid := 'SEU_TENANT_ID';  -- Substitua aqui
BEGIN
  -- Simular autenticação
  PERFORM set_config('request.jwt.claims', json_build_object('sub', test_user_id)::text, true);

  -- Testar produtos
  RAISE NOTICE 'Produtos que o usuário vê:';
  FOR rec IN
    SELECT id, nome, tenant_id
    FROM public.produtos
    WHERE tenant_id = test_tenant_id
    LIMIT 5
  LOOP
    RAISE NOTICE '  - ID: %, Nome: %, Tenant: %', rec.id, rec.nome, rec.tenant_id;
  END LOOP;

  -- Testar categorias
  RAISE NOTICE 'Categorias que o usuário vê:';
  FOR rec IN
    SELECT id, nome, tenant_id
    FROM public.categorias
    WHERE tenant_id = test_tenant_id
    LIMIT 5
  LOOP
    RAISE NOTICE '  - ID: %, Nome: %, Tenant: %', rec.id, rec.nome, rec.tenant_id;
  END LOOP;
END $$;

-- ============================================================================
-- 7. AUDITORIA DE ACESSOS
-- ============================================================================

-- Ver logs de ações recentes por tenant
SELECT
  l.action,
  l.entity_type,
  l.username,
  l.created_at,
  au.email as user_email,
  tu.tenant_id
FROM public.logs l
LEFT JOIN public.admin_users au ON l.user_id = au.id
LEFT JOIN public.tenant_users tu ON au.id = tu.admin_user_id
WHERE l.created_at >= NOW() - INTERVAL '7 days'
ORDER BY l.created_at DESC
LIMIT 50;

-- ============================================================================
-- 8. PERFORMANCE - Verificar uso de índices
-- ============================================================================

-- Ver se índices em tenant_id estão sendo usados
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as vezes_usado,
  idx_tup_read as tuplas_lidas,
  idx_tup_fetch as tuplas_buscadas
FROM pg_stat_user_indexes
WHERE indexname LIKE '%tenant_id%'
ORDER BY idx_scan DESC;

-- ============================================================================
-- 9. LIMPEZA - Remover dados órfãos (USE COM CUIDADO!)
-- ============================================================================

-- ATENÇÃO: Estas queries DELETAM dados!
-- Só execute se tiver certeza de que os dados órfãos devem ser removidos
-- FAÇA BACKUP ANTES!

/*
-- Deletar categorias órfãs
DELETE FROM public.categorias WHERE tenant_id IS NULL;

-- Deletar produtos órfãos
DELETE FROM public.produtos WHERE tenant_id IS NULL;

-- Deletar menu items órfãos
DELETE FROM public.menu_items WHERE tenant_id IS NULL;

-- Deletar funcionários órfãos
DELETE FROM public.employees WHERE tenant_id IS NULL;
*/

-- ============================================================================
-- 10. ATRIBUIR TENANT MANUALMENTE (se necessário)
-- ============================================================================

-- Se houver registros órfãos, você pode atribuí-los manualmente a um tenant:

/*
-- Exemplo: Atribuir todos os produtos órfãos ao primeiro tenant
UPDATE public.produtos
SET tenant_id = (SELECT id FROM public.tenants ORDER BY created_at LIMIT 1)
WHERE tenant_id IS NULL;

-- Exemplo: Atribuir categoria específica a um tenant específico
UPDATE public.categorias
SET tenant_id = 'uuid-do-tenant-aqui'
WHERE id = 'uuid-da-categoria-aqui';
*/

-- ============================================================================
-- 11. RELATÓRIO DE SAÚDE DO SISTEMA
-- ============================================================================

SELECT
  'Total de Tenants' as metrica,
  COUNT(*)::text as valor
FROM public.tenants
UNION ALL
SELECT
  'Tenants Ativos',
  COUNT(*)::text
FROM public.tenants
WHERE status = 'active'
UNION ALL
SELECT
  'Total de Usuários',
  COUNT(*)::text
FROM public.tenant_users
UNION ALL
SELECT
  'Tabelas com RLS',
  COUNT(DISTINCT tablename)::text
FROM pg_tables
WHERE schemaname = 'public' AND rowsecurity = true
UNION ALL
SELECT
  'Políticas RLS Ativas',
  COUNT(*)::text
FROM pg_policies
WHERE schemaname = 'public'
UNION ALL
SELECT
  'Produtos Órfãos',
  COUNT(*)::text
FROM public.produtos
WHERE tenant_id IS NULL
UNION ALL
SELECT
  'Categorias Órfãs',
  COUNT(*)::text
FROM public.categorias
WHERE tenant_id IS NULL
UNION ALL
SELECT
  'Funcionários Órfãos',
  COUNT(*)::text
FROM public.employees
WHERE tenant_id IS NULL;

-- ============================================================================
-- FIM DAS QUERIES ÚTEIS
-- ============================================================================

-- Para executar estas queries:
-- 1. Via psql: psql -h <host> -U postgres -d postgres -f queries_uteis.sql
-- 2. Via Supabase Dashboard: Cole no SQL Editor e execute
-- 3. Via aplicação: Use sua biblioteca PostgreSQL favorita
