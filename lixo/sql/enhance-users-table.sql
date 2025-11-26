-- Melhorar tabela de usuários para suporte completo ao perfil
-- Execute este SQL no Supabase SQL Editor

-- 1. Adicionar colunas necessárias para perfil
ALTER TABLE admin_users
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{"emailNotifications": true, "pushNotifications": true, "darkMode": false, "language": "pt-BR"}',
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS login_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 2. Comentários para documentação
COMMENT ON COLUMN admin_users.preferences IS 'Preferências do usuário em formato JSON';
COMMENT ON COLUMN admin_users.avatar_url IS 'URL do avatar do usuário';
COMMENT ON COLUMN admin_users.login_count IS 'Contador total de logins do usuário';
COMMENT ON COLUMN admin_users.last_login_at IS 'Timestamp do último login';
COMMENT ON COLUMN admin_users.updated_at IS 'Timestamp da última atualização do perfil';

-- 3. Criar trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_admin_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_admin_users_updated_at_trigger ON admin_users;
CREATE TRIGGER update_admin_users_updated_at_trigger
  BEFORE UPDATE ON admin_users
  FOR EACH ROW
  EXECUTE FUNCTION update_admin_users_updated_at();

-- 4. Criar bucket para avatars no Supabase Storage
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('user-avatars', 'user-avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 5. Políticas de acesso para o bucket de avatars
-- Remover políticas existentes primeiro
DROP POLICY IF EXISTS "Users can upload their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Public can view avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatars" ON storage.objects;

-- Permitir upload apenas para usuários autenticados
CREATE POLICY "Users can upload their own avatars"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'user-avatars');

-- Permitir visualização pública dos avatars
CREATE POLICY "Public can view avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'user-avatars');

-- Permitir que usuários deletem seus próprios avatars
CREATE POLICY "Users can delete their own avatars"
ON storage.objects FOR DELETE
USING (bucket_id = 'user-avatars');

-- 6. Atualizar usuários existentes com valores padrão
UPDATE admin_users
SET
  preferences = COALESCE(preferences, '{"emailNotifications": true, "pushNotifications": true, "darkMode": false, "language": "pt-BR"}'::jsonb),
  login_count = COALESCE(login_count, 0),
  updated_at = COALESCE(updated_at, created_at, NOW())
WHERE preferences IS NULL OR login_count IS NULL OR updated_at IS NULL;

-- 7. Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_admin_users_last_login ON admin_users(last_login_at);
CREATE INDEX IF NOT EXISTS idx_admin_users_updated_at ON admin_users(updated_at);

-- 8. Verificar estrutura final
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'admin_users'
  AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT 'Tabela admin_users melhorada com sucesso!' as resultado;