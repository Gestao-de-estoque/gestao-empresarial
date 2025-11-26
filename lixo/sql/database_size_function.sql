-- Função para obter o tamanho do banco de dados
-- Execute este SQL no Supabase SQL Editor

-- 1. Criar função para obter tamanho total do banco
CREATE OR REPLACE FUNCTION get_database_size()
RETURNS bigint
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT pg_database_size(current_database());
$$;

-- 2. Criar função para obter estatísticas detalhadas das tabelas
CREATE OR REPLACE FUNCTION get_table_sizes()
RETURNS TABLE (
  table_name text,
  row_count bigint,
  total_size text,
  index_size text,
  toast_size text
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT
    schemaname||'.'||tablename AS table_name,
    n_tup_ins - n_tup_del AS row_count,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) AS index_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS toast_size
  FROM pg_stat_user_tables
  WHERE schemaname = 'public'
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
$$;

-- 3. Criar função para obter informações do plano
CREATE OR REPLACE FUNCTION get_project_info()
RETURNS json
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT json_build_object(
    'database_size', pg_database_size(current_database()),
    'database_size_pretty', pg_size_pretty(pg_database_size(current_database())),
    'max_connections', current_setting('max_connections')::int,
    'shared_buffers', current_setting('shared_buffers'),
    'effective_cache_size', current_setting('effective_cache_size'),
    'server_version', version()
  );
$$;

-- 4. Criar função para obter estatísticas de conexões
CREATE OR REPLACE FUNCTION get_connection_stats()
RETURNS json
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT json_build_object(
    'total_connections', COUNT(*),
    'active_connections', COUNT(*) FILTER (WHERE state = 'active'),
    'idle_connections', COUNT(*) FILTER (WHERE state = 'idle')
  )
  FROM pg_stat_activity
  WHERE datname = current_database();
$$;

-- 5. Comentários para documentação
COMMENT ON FUNCTION get_database_size() IS 'Retorna o tamanho total do banco de dados em bytes';
COMMENT ON FUNCTION get_table_sizes() IS 'Retorna estatísticas de tamanho para todas as tabelas do esquema public';
COMMENT ON FUNCTION get_project_info() IS 'Retorna informações gerais sobre o projeto/banco';
COMMENT ON FUNCTION get_connection_stats() IS 'Retorna estatísticas de conexões ativas';

-- 6. Conceder permissões apropriadas
GRANT EXECUTE ON FUNCTION get_database_size() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_table_sizes() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_project_info() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_connection_stats() TO authenticated, anon;