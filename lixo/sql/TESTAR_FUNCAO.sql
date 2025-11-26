-- ============================================================================
-- 🧪 TESTAR: Função current_user_tenant_id() para o usuário logado
-- ============================================================================

-- Ver usuário atual e seu tenant
SELECT
  auth.uid() as meu_user_id,
  public.current_user_tenant_id() as meu_tenant_id,
  CASE
    WHEN public.current_user_tenant_id() IS NULL THEN '❌ SEM TENANT - PROBLEMA!'
    ELSE '✅ TENHO TENANT - OK'
  END as status;

-- Ver se existe associação na tabela tenant_users
SELECT
  tu.tenant_id,
  t.name as tenant_name,
  tu.admin_user_id,
  au.email as meu_email,
  tu.is_active,
  tu.role
FROM public.tenant_users tu
JOIN public.tenants t ON tu.tenant_id = t.id
JOIN public.admin_users au ON tu.admin_user_id = au.id
WHERE tu.admin_user_id = auth.uid();
