-- ============================================================================
-- 👥 VER TODOS OS USUÁRIOS E SUAS ASSOCIAÇÕES COM TENANTS
-- ============================================================================

-- Ver TODOS os usuários
SELECT
  'USUÁRIOS:' as tipo,
  au.id,
  au.email,
  au.name,
  au.created_at::text
FROM public.admin_users au
ORDER BY au.created_at DESC;

-- Ver TODOS os tenants
SELECT
  'TENANTS:' as tipo,
  t.id,
  t.name as nome,
  t.slug,
  t.email,
  t.status,
  t.created_at::text
FROM public.tenants t
ORDER BY t.created_at DESC;

-- Ver TODAS as associações tenant_users
SELECT
  'ASSOCIAÇÕES:' as tipo,
  tu.id,
  au.email as usuario_email,
  t.name as tenant_name,
  tu.is_active,
  tu.is_owner,
  tu.role,
  tu.created_at::text
FROM public.tenant_users tu
LEFT JOIN public.tenants t ON tu.tenant_id = t.id
LEFT JOIN public.admin_users au ON tu.admin_user_id = au.id
ORDER BY tu.created_at DESC;

-- Ver usuários SEM associação com tenant
SELECT
  'USUÁRIOS SEM TENANT:' as tipo,
  au.id,
  au.email,
  au.name,
  '⚠️ PROBLEMA!' as status
FROM public.admin_users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.tenant_users tu
  WHERE tu.admin_user_id = au.id
)
ORDER BY au.created_at DESC;

-- Contar totais
SELECT
  'RESUMO:' as tipo,
  (SELECT COUNT(*) FROM public.admin_users) as total_usuarios,
  (SELECT COUNT(*) FROM public.tenants) as total_tenants,
  (SELECT COUNT(*) FROM public.tenant_users) as total_associacoes,
  (SELECT COUNT(*) FROM public.admin_users au WHERE NOT EXISTS (
    SELECT 1 FROM public.tenant_users tu WHERE tu.admin_user_id = au.id
  )) as usuarios_sem_tenant;
