-- ============================================================================
-- 🔍 DIAGNÓSTICO: Verificar associação de usuários com tenants
-- ============================================================================

-- Ver todos os usuários
SELECT
  au.id,
  au.email,
  au.name,
  au.created_at
FROM public.admin_users au
ORDER BY au.created_at DESC;

-- Ver todos os tenants
SELECT
  t.id,
  t.name,
  t.slug,
  t.email,
  t.status,
  t.created_at
FROM public.tenants t
ORDER BY t.created_at DESC;

-- Ver associações tenant_users
SELECT
  tu.id,
  tu.tenant_id,
  t.name as tenant_name,
  tu.admin_user_id,
  au.email as user_email,
  tu.is_active,
  tu.is_owner,
  tu.role
FROM public.tenant_users tu
JOIN public.tenants t ON tu.tenant_id = t.id
JOIN public.admin_users au ON tu.admin_user_id = au.id
ORDER BY tu.created_at DESC;

-- Ver usuários SEM tenant
SELECT
  au.id,
  au.email,
  au.name,
  'SEM TENANT!' as status
FROM public.admin_users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.tenant_users tu
  WHERE tu.admin_user_id = au.id
);

-- Testar função current_user_tenant_id() para o usuário atual
SELECT
  auth.uid() as current_user_id,
  public.current_user_tenant_id() as current_tenant_id,
  CASE
    WHEN public.current_user_tenant_id() IS NULL THEN '❌ SEM TENANT!'
    ELSE '✅ TEM TENANT'
  END as status;

-- Ver dados com tenant_id NULL
SELECT 'employees' as tabela, COUNT(*) as registros_null
FROM public.employees WHERE tenant_id IS NULL
UNION ALL
SELECT 'produtos', COUNT(*) FROM public.produtos WHERE tenant_id IS NULL
UNION ALL
SELECT 'categorias', COUNT(*) FROM public.categorias WHERE tenant_id IS NULL
UNION ALL
SELECT 'suppliers', COUNT(*) FROM public.suppliers WHERE tenant_id IS NULL;
