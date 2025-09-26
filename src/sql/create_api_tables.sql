-- ==========================================
-- SCRIPT DE CRIAÇÃO DAS TABELAS DE API MANAGEMENT
-- Execute este script no Supabase SQL Editor
-- ==========================================

-- 1. Criar tabela de chaves de API
CREATE TABLE IF NOT EXISTS api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    key VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP WITH TIME ZONE,
    request_count INTEGER DEFAULT 0,
    rate_limit INTEGER DEFAULT 1000,
    allowed_origins JSONB DEFAULT '[]'::jsonb,
    permissions JSONB DEFAULT '["read"]'::jsonb
);

-- 2. Criar tabela de requisições da API
CREATE TABLE IF NOT EXISTS api_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    api_key_id UUID REFERENCES api_keys(id) ON DELETE CASCADE,
    method VARCHAR(10) NOT NULL,
    endpoint VARCHAR(500) NOT NULL,
    status_code INTEGER NOT NULL,
    response_time INTEGER DEFAULT 0, -- em millisegundos
    ip_address INET,
    user_agent TEXT,
    request_body JSONB,
    response_body JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Criar tabela de métricas da API (agregadas por hora/dia)
CREATE TABLE IF NOT EXISTS api_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    api_key_id UUID REFERENCES api_keys(id) ON DELETE CASCADE,
    date_hour TIMESTAMP WITH TIME ZONE NOT NULL, -- truncado por hora
    request_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    avg_response_time INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(api_key_id, date_hour)
);

-- 4. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_api_keys_status ON api_keys(status);
CREATE INDEX IF NOT EXISTS idx_api_keys_key ON api_keys(key);
CREATE INDEX IF NOT EXISTS idx_api_requests_api_key_id ON api_requests(api_key_id);
CREATE INDEX IF NOT EXISTS idx_api_requests_created_at ON api_requests(created_at);
CREATE INDEX IF NOT EXISTS idx_api_requests_status_code ON api_requests(status_code);
CREATE INDEX IF NOT EXISTS idx_api_metrics_api_key_id ON api_metrics(api_key_id);
CREATE INDEX IF NOT EXISTS idx_api_metrics_date_hour ON api_metrics(date_hour);

-- 5. Criar função para incrementar contador de requisições
CREATE OR REPLACE FUNCTION increment_api_key_requests(key_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE api_keys
    SET
        request_count = request_count + 1,
        last_used = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = key_id;
END;
$$ LANGUAGE plpgsql;

-- 6. Criar função para agregação de métricas por hora
CREATE OR REPLACE FUNCTION aggregate_api_metrics()
RETURNS void AS $$
DECLARE
    current_hour TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Obter a hora atual truncada
    current_hour := date_trunc('hour', CURRENT_TIMESTAMP);

    -- Agregar métricas para a hora atual
    INSERT INTO api_metrics (api_key_id, date_hour, request_count, error_count, avg_response_time)
    SELECT
        api_key_id,
        current_hour,
        COUNT(*) as request_count,
        COUNT(*) FILTER (WHERE status_code >= 400) as error_count,
        AVG(response_time)::INTEGER as avg_response_time
    FROM api_requests
    WHERE created_at >= current_hour
        AND created_at < current_hour + INTERVAL '1 hour'
    GROUP BY api_key_id
    ON CONFLICT (api_key_id, date_hour)
    DO UPDATE SET
        request_count = EXCLUDED.request_count,
        error_count = EXCLUDED.error_count,
        avg_response_time = EXCLUDED.avg_response_time;
END;
$$ LANGUAGE plpgsql;

-- 7. Criar trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_api_keys_updated_at
    BEFORE UPDATE ON api_keys
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 8. Inserir dados de exemplo
INSERT INTO api_keys (name, key, description, status, request_count, rate_limit, permissions) VALUES
    ('Integração Principal', 'gzs_' || extract(epoch from now())::bigint::text || '_main_integration_key', 'Chave principal para integração com o sistema', 'active', 1247, 5000, '["read", "write", "admin"]'::jsonb),
    ('App Mobile', 'gzs_' || (extract(epoch from now())::bigint + 1)::text || '_mobile_app_key', 'Chave para aplicativo mobile iOS e Android', 'active', 892, 1000, '["read", "write"]'::jsonb),
    ('Webhooks', 'gzs_' || (extract(epoch from now())::bigint + 2)::text || '_webhook_handler_key', 'Chave para receber webhooks de pagamentos', 'active', 156, 500, '["webhook"]'::jsonb),
    ('Dashboard Analytics', 'gzs_' || (extract(epoch from now())::bigint + 3)::text || '_analytics_dashboard', 'Chave para dashboard de analytics', 'inactive', 45, 200, '["read"]'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- 9. Inserir logs de exemplo das últimas 24 horas
DO $$
DECLARE
    key_record RECORD;
    log_timestamp TIMESTAMP WITH TIME ZONE;
    i INTEGER;
    methods TEXT[] := ARRAY['GET', 'POST', 'PUT', 'DELETE'];
    endpoints TEXT[] := ARRAY['/api/v1/products', '/api/v1/orders', '/api/v1/inventory', '/api/v1/users', '/api/v1/reports', '/api/v1/auth'];
    status_codes INTEGER[] := ARRAY[200, 201, 400, 401, 404, 500];
BEGIN
    -- Para cada chave ativa, criar logs de exemplo
    FOR key_record IN SELECT id FROM api_keys WHERE status = 'active' LOOP
        FOR i IN 1..20 LOOP
            log_timestamp := CURRENT_TIMESTAMP - (random() * INTERVAL '24 hours');

            INSERT INTO api_requests (
                api_key_id,
                method,
                endpoint,
                status_code,
                response_time,
                ip_address,
                user_agent,
                created_at
            ) VALUES (
                key_record.id,
                methods[ceil(random() * array_length(methods, 1))],
                endpoints[ceil(random() * array_length(endpoints, 1))],
                status_codes[ceil(random() * array_length(status_codes, 1))],
                (random() * 500 + 50)::INTEGER, -- response time entre 50-550ms
                ('192.168.1.' || ceil(random() * 254)::text)::INET,
                'GestaoZe-Client/1.0',
                log_timestamp
            );
        END LOOP;
    END LOOP;
END;
$$;

-- 10. Atualizar contadores das chaves baseado nos logs
UPDATE api_keys
SET request_count = (
    SELECT COALESCE(COUNT(*), 0)
    FROM api_requests
    WHERE api_requests.api_key_id = api_keys.id
);

-- 11. Configurar RLS (Row Level Security) - OPCIONAL
-- ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE api_requests ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE api_metrics ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Allow all for authenticated users" ON api_keys FOR ALL USING (auth.role() = 'authenticated');
-- CREATE POLICY "Allow all for authenticated users" ON api_requests FOR ALL USING (auth.role() = 'authenticated');
-- CREATE POLICY "Allow all for authenticated users" ON api_metrics FOR ALL USING (auth.role() = 'authenticated');

-- ==========================================
-- VERIFICAÇÃO - Execute para confirmar
-- ==========================================

-- Verificar se as tabelas foram criadas
SELECT 'Tabelas API criadas:' as status;
SELECT schemaname, tablename FROM pg_tables WHERE tablename IN ('api_keys', 'api_requests', 'api_metrics');

-- Verificar dados inseridos
SELECT 'Chaves API criadas:' as status;
SELECT name, status, request_count, rate_limit FROM api_keys ORDER BY created_at;

SELECT 'Total de logs por método:' as status;
SELECT method, COUNT(*) as total FROM api_requests GROUP BY method ORDER BY total DESC;

SELECT 'Requests nas últimas 24h:' as status;
SELECT COUNT(*) as total_requests FROM api_requests WHERE created_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours';

SELECT '✅ API Management Setup completo! Acesse /api no seu app.' as resultado;