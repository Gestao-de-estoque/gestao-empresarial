-- Criação da tabela system_alerts para alertas do sistema
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

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_system_alerts_resolved ON public.system_alerts(resolved);
CREATE INDEX IF NOT EXISTS idx_system_alerts_category ON public.system_alerts(category);
CREATE INDEX IF NOT EXISTS idx_system_alerts_type ON public.system_alerts(type);
CREATE INDEX IF NOT EXISTS idx_system_alerts_created_at ON public.system_alerts(created_at);
CREATE INDEX IF NOT EXISTS idx_system_alerts_priority ON public.system_alerts(priority);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_system_alerts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
DROP TRIGGER IF EXISTS update_system_alerts_updated_at_trigger ON public.system_alerts;
CREATE TRIGGER update_system_alerts_updated_at_trigger
  BEFORE UPDATE ON public.system_alerts
  FOR EACH ROW
  EXECUTE FUNCTION update_system_alerts_updated_at();

-- Comentários para documentação
COMMENT ON TABLE public.system_alerts IS 'Tabela para armazenar alertas automáticos do sistema';
COMMENT ON COLUMN public.system_alerts.type IS 'Tipo do alerta: critical, warning, info, success';
COMMENT ON COLUMN public.system_alerts.category IS 'Categoria: estoque, sistema, backup, performance, seguranca, dados';
COMMENT ON COLUMN public.system_alerts.priority IS 'Prioridade: 1=baixa, 2=média, 3=alta';
COMMENT ON COLUMN public.system_alerts.auto_generated IS 'Se o alerta foi gerado automaticamente pelo sistema';
COMMENT ON COLUMN public.system_alerts.suggested_actions IS 'Array JSON com ações sugeridas para resolver o alerta';
COMMENT ON COLUMN public.system_alerts.metadata IS 'Metadados JSON com informações adicionais do alerta';