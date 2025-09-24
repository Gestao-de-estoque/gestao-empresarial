-- CORREÇÃO RÁPIDA: Desabilitar RLS e corrigir foreign key na tabela app_settings
-- Execute este script no Supabase SQL Editor para corrigir os erros

-- 1. Desabilitar RLS
ALTER TABLE app_settings DISABLE ROW LEVEL SECURITY;

-- 2. Remover todas as políticas RLS
DROP POLICY IF EXISTS "Users can only access their own settings" ON app_settings;
DROP POLICY IF EXISTS "Users can insert their own settings" ON app_settings;
DROP POLICY IF EXISTS "Users can update their own settings" ON app_settings;
DROP POLICY IF EXISTS "Users can delete their own settings" ON app_settings;

-- 3. CORRIGIR FOREIGN KEY: Remover referência ao auth.users
-- Primeiro, verificar se a constraint existe
SELECT conname
FROM pg_constraint
WHERE conrelid = 'app_settings'::regclass
AND contype = 'f';

-- Remover a foreign key constraint que referencia auth.users
ALTER TABLE app_settings
DROP CONSTRAINT IF EXISTS app_settings_user_id_fkey;

-- 4. Verificar se a correção funcionou
SELECT
  tablename,
  rowsecurity,
  (SELECT count(*) FROM pg_policies WHERE tablename = 'app_settings') as policy_count,
  (SELECT count(*) FROM pg_constraint WHERE conrelid = 'app_settings'::regclass AND contype = 'f') as fk_count
FROM pg_tables
WHERE tablename = 'app_settings';

-- 5. Testar inserção básica (opcional)
-- INSERT INTO app_settings (user_id, section, settings)
-- VALUES (gen_random_uuid(), 'test', '{"test": true}');

-- 6. Limpar teste (descomente se executou o teste acima)
-- DELETE FROM app_settings WHERE section = 'test';

SELECT 'RLS desabilitado e foreign key removida com sucesso!' as status;