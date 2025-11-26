-- ============================================================================
-- VERIFICAÇÃO RÁPIDA PÓS-MIGRAÇÃO
-- Execute este script após migration_completa.sql
-- ============================================================================

-- 1. Verificar se há registros órfãos
SELECT
  'produtos' as tabela,
  COUNT(*) as orfaos
FROM public.produtos WHERE tenant_id IS NULL
UNION ALL
SELECT 'categorias', COUNT(*) FROM public.categorias WHERE tenant_id IS NULL
UNION ALL
SELECT 'employees', COUNT(*) FROM public.employees WHERE tenant_id IS NULL
UNION ALL
SELECT 'menu_items', COUNT(*) FROM public.menu_items WHERE tenant_id IS NULL;

-- 2. Verificar políticas RLS
SELECT
  tablename,
  COUNT(*) as total_policies
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('categorias', 'produtos', 'employees', 'tenants', 'admin_users')
GROUP BY tablename
ORDER BY tablename;

-- 3. Verificar se RLS está habilitado
SELECT
  tablename,
  CASE WHEN rowsecurity THEN '✓ Ativo' ELSE '✗ Inativo' END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('categorias', 'produtos', 'employees', 'tenants', 'admin_users')
ORDER BY tablename;

-- 4. Testar se consegue ler tenants (deve funcionar)
SELECT id, name, slug FROM public.tenants LIMIT 3;

-- 5. Contagem por tenant
SELECT
  t.name as tenant,
  (SELECT COUNT(*) FROM public.produtos WHERE tenant_id = t.id) as produtos,
  (SELECT COUNT(*) FROM public.categorias WHERE tenant_id = t.id) as categorias,
  (SELECT COUNT(*) FROM public.employees WHERE tenant_id = t.id) as funcionarios
FROM public.tenants t;
