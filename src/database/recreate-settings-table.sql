-- Script para recriar a tabela app_settings (usar se houver problemas com RLS)

-- Primeiro, remover a tabela existente (CUIDADO: isso apaga todos os dados!)
-- Descomente a linha abaixo apenas se necessário
-- DROP TABLE IF EXISTS app_settings;

-- Recriar tabela sem RLS
CREATE TABLE IF NOT EXISTS app_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  section VARCHAR(50) NOT NULL,
  settings JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, section)
);

-- Comentários
COMMENT ON TABLE app_settings IS 'Configurações do aplicativo por usuário';
COMMENT ON COLUMN app_settings.user_id IS 'ID do usuário (referencia admin_users.id)';
COMMENT ON COLUMN app_settings.section IS 'Seção das configurações (general, inventory, etc)';
COMMENT ON COLUMN app_settings.settings IS 'Dados JSON das configurações da seção';

-- Índices
CREATE INDEX IF NOT EXISTS idx_app_settings_user_id ON app_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_app_settings_section ON app_settings(section);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_app_settings_updated_at ON app_settings;
CREATE TRIGGER update_app_settings_updated_at
  BEFORE UPDATE ON app_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Garantir que RLS está desabilitado
ALTER TABLE app_settings DISABLE ROW LEVEL SECURITY;

-- Limpar qualquer política RLS existente
DROP POLICY IF EXISTS "Users can only access their own settings" ON app_settings;
DROP POLICY IF EXISTS "Users can insert their own settings" ON app_settings;
DROP POLICY IF EXISTS "Users can update their own settings" ON app_settings;
DROP POLICY IF EXISTS "Users can delete their own settings" ON app_settings;

SELECT 'Tabela app_settings recriada sem RLS!' as resultado;