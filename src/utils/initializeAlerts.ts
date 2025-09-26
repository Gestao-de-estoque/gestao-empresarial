import { supabase } from '@/config/supabase'

/**
 * Inicializa a tabela de alertas e estruturas necessárias
 */
export async function initializeAlertsTable() {
  console.log('🔧 Inicializando estrutura de alertas...')

  try {
    // Verificar se a tabela já existe
    const { data: existingTable, error: checkError } = await supabase
      .from('system_alerts')
      .select('id')
      .limit(1)

    if (!checkError) {
      console.log('✅ Tabela system_alerts já existe')
      return true
    }

    // Se chegou aqui, a tabela não existe ou há erro de acesso
    console.log('📋 Criando tabela system_alerts...')

    // Como não podemos executar DDL diretamente via supabase-js,
    // vamos criar um alerta de teste para verificar se a tabela existe
    // e dar instruções para o usuário

    console.log(`
🔧 AÇÃO NECESSÁRIA: Criar tabela no Supabase

Para criar a tabela de alertas, execute o seguinte SQL no painel do Supabase:

1. Acesse: https://app.supabase.com/
2. Vá para SQL Editor
3. Execute o SQL do arquivo: src/sql/create_alerts_table.sql

Ou copie e cole este SQL:

CREATE TABLE IF NOT EXISTS public.system_alerts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  type character varying NOT NULL CHECK (type IN ('critical', 'warning', 'info', 'success')),
  category character varying NOT NULL,
  title character varying NOT NULL,
  description text NOT NULL,
  details text,
  icon character varying NOT NULL,
  resolved boolean NOT NULL DEFAULT false,
  resolved_at timestamp with time zone,
  auto_generated boolean NOT NULL DEFAULT true,
  priority integer NOT NULL DEFAULT 1,
  affected_entity character varying,
  entity_id character varying,
  action_required boolean DEFAULT false,
  suggested_actions jsonb,
  metadata jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT system_alerts_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_system_alerts_resolved ON public.system_alerts(resolved);
CREATE INDEX IF NOT EXISTS idx_system_alerts_category ON public.system_alerts(category);
CREATE INDEX IF NOT EXISTS idx_system_alerts_type ON public.system_alerts(type);
CREATE INDEX IF NOT EXISTS idx_system_alerts_created_at ON public.system_alerts(created_at);
CREATE INDEX IF NOT EXISTS idx_system_alerts_priority ON public.system_alerts(priority);
    `)

    return false

  } catch (error) {
    console.error('❌ Erro ao verificar tabela de alertas:', error)
    return false
  }
}

/**
 * Testa se o sistema de alertas está funcionando
 */
export async function testAlertsSystem() {
  console.log('🧪 Testando sistema de alertas...')

  try {
    // Tentar inserir um alerta de teste
    const testAlert = {
      id: crypto.randomUUID(),
      type: 'info',
      category: 'sistema',
      title: 'Teste do Sistema',
      description: 'Alerta de teste para verificar funcionamento',
      icon: 'Info',
      resolved: false,
      auto_generated: true,
      priority: 1,
      created_at: new Date().toISOString()
    }

    const { data, error } = await supabase
      .from('system_alerts')
      .insert([testAlert])
      .select()

    if (error) {
      console.error('❌ Erro no teste de alertas:', error)

      if (error.code === '42P01') {
        console.log('📋 Tabela system_alerts não existe. Execute o SQL de criação primeiro.')
        await initializeAlertsTable()
      }

      return false
    }

    console.log('✅ Sistema de alertas funcionando!')

    // Remover alerta de teste
    await supabase
      .from('system_alerts')
      .delete()
      .eq('id', testAlert.id)

    return true

  } catch (error) {
    console.error('❌ Erro no teste:', error)
    return false
  }
}

/**
 * Verifica se as políticas RLS estão configuradas
 */
export async function checkRLSPolicies() {
  console.log('🔒 Verificando políticas RLS...')

  try {
    // Tentar fazer uma consulta simples
    const { data, error } = await supabase
      .from('system_alerts')
      .select('id')
      .limit(1)

    if (error && error.code === '42501') {
      console.log(`
🔒 CONFIGURAÇÃO RLS NECESSÁRIA:

As políticas RLS (Row Level Security) podem estar bloqueando o acesso.
Execute no SQL Editor do Supabase:

-- Desabilitar RLS temporariamente (apenas para desenvolvimento)
ALTER TABLE public.system_alerts DISABLE ROW LEVEL SECURITY;

-- OU criar políticas adequadas:
ALTER TABLE public.system_alerts ENABLE ROW LEVEL SECURITY;

-- Política para permitir todas as operações (ajustar conforme necessário)
CREATE POLICY "Permitir acesso aos alertas" ON public.system_alerts
FOR ALL USING (true);
      `)
      return false
    }

    console.log('✅ Políticas RLS configuradas adequadamente')
    return true

  } catch (error) {
    console.error('❌ Erro ao verificar RLS:', error)
    return false
  }
}