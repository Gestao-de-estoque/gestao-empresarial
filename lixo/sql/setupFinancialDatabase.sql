-- Criação da tabela financial_data no Supabase
-- Execute este SQL no editor do Supabase para criar a estrutura necessária

CREATE TABLE IF NOT EXISTS financial_data (
    id BIGSERIAL PRIMARY KEY,
    full_day VARCHAR(10) NOT NULL, -- Data no formato DD/MM/YYYY
    amount DECIMAL(10,2) NOT NULL, -- Valor do garçom (10%)
    total DECIMAL(10,2) NOT NULL,  -- Valor total do dia
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_financial_data_full_day ON financial_data(full_day);
CREATE INDEX IF NOT EXISTS idx_financial_data_created_at ON financial_data(created_at);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_financial_data_updated_at
    BEFORE UPDATE ON financial_data
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security) - opcional, dependendo das suas necessidades de segurança
-- ALTER TABLE financial_data ENABLE ROW LEVEL SECURITY;

-- Política de acesso (ajuste conforme necessário)
-- CREATE POLICY "Enable read access for authenticated users" ON financial_data
--     FOR SELECT USING (auth.role() = 'authenticated');

-- CREATE POLICY "Enable write access for authenticated users" ON financial_data
--     FOR ALL USING (auth.role() = 'authenticated');

-- Comentários na tabela
COMMENT ON TABLE financial_data IS 'Tabela para armazenar dados financeiros diários do restaurante';
COMMENT ON COLUMN financial_data.full_day IS 'Data do registro no formato DD/MM/YYYY';
COMMENT ON COLUMN financial_data.amount IS 'Valor do salário do garçom (10% da receita total)';
COMMENT ON COLUMN financial_data.total IS 'Receita total do dia';
COMMENT ON COLUMN financial_data.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN financial_data.updated_at IS 'Data da última atualização do registro';