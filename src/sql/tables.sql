-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admin_users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email character varying NOT NULL UNIQUE,
  username character varying UNIQUE,
  password_hash character varying NOT NULL,
  senha character varying,
  name character varying,
  nome character varying,
  role character varying DEFAULT 'admin'::character varying,
  cargo character varying,
  is_active boolean DEFAULT true,
  ativo boolean DEFAULT true,
  last_login timestamp with time zone,
  ultimo_acesso timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  preferences jsonb DEFAULT '{"darkMode": false, "language": "pt-BR", "pushNotifications": true, "emailNotifications": true}'::jsonb,
  avatar_url text,
  login_count integer DEFAULT 0,
  last_login_at timestamp with time zone,
  CONSTRAINT admin_users_pkey PRIMARY KEY (id)
);
CREATE TABLE public.api_keys (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  key character varying NOT NULL UNIQUE,
  description text,
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])),
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  last_used timestamp with time zone,
  request_count integer DEFAULT 0,
  rate_limit integer DEFAULT 1000,
  allowed_origins jsonb DEFAULT '[]'::jsonb,
  permissions jsonb DEFAULT '["read"]'::jsonb,
  CONSTRAINT api_keys_pkey PRIMARY KEY (id)
);
CREATE TABLE public.api_metrics (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  api_key_id uuid,
  date_hour timestamp with time zone NOT NULL,
  request_count integer DEFAULT 0,
  error_count integer DEFAULT 0,
  avg_response_time integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT api_metrics_pkey PRIMARY KEY (id),
  CONSTRAINT api_metrics_api_key_id_fkey FOREIGN KEY (api_key_id) REFERENCES public.api_keys(id)
);
CREATE TABLE public.api_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  api_key_id uuid,
  method character varying NOT NULL,
  endpoint character varying NOT NULL,
  status_code integer NOT NULL,
  response_time integer DEFAULT 0,
  ip_address inet,
  user_agent text,
  request_body jsonb,
  response_body jsonb,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT api_requests_pkey PRIMARY KEY (id),
  CONSTRAINT api_requests_api_key_id_fkey FOREIGN KEY (api_key_id) REFERENCES public.api_keys(id)
);
CREATE TABLE public.app_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  section character varying NOT NULL,
  settings jsonb NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT app_settings_pkey PRIMARY KEY (id)
);
CREATE TABLE public.bd_ativo (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  num bigint,
  CONSTRAINT bd_ativo_pkey PRIMARY KEY (id)
);
CREATE TABLE public.categorias (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome character varying NOT NULL UNIQUE,
  icone character varying DEFAULT '📦'::character varying,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categorias_pkey PRIMARY KEY (id)
);
CREATE TABLE public.financial_data (
  id bigint NOT NULL DEFAULT nextval('financial_data_id_seq'::regclass),
  full_day character varying NOT NULL,
  amount numeric NOT NULL,
  total numeric NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT financial_data_pkey PRIMARY KEY (id)
);
CREATE TABLE public.logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  action character varying NOT NULL,
  entity_type character varying,
  entity_id uuid,
  description text,
  ip_address inet,
  user_agent text,
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  username text NOT NULL DEFAULT 'system'::text,
  resource text NOT NULL DEFAULT 'system'::text,
  resource_id text,
  details jsonb DEFAULT '{}'::jsonb,
  severity text NOT NULL DEFAULT 'info'::text,
  category text NOT NULL DEFAULT 'system'::text,
  session_id text,
  execution_time integer,
  status text DEFAULT 'success'::text,
  error_message text,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT logs_pkey PRIMARY KEY (id),
  CONSTRAINT logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.admin_users(id)
);
CREATE TABLE public.menu_diario (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  planejamento_semanal_id uuid NOT NULL,
  menu_item_id uuid NOT NULL,
  data_planejada date NOT NULL,
  periodo_refeicao character varying NOT NULL DEFAULT 'almoco'::character varying CHECK (periodo_refeicao::text = ANY (ARRAY['cafe_manha'::character varying::text, 'almoco'::character varying::text, 'jantar'::character varying::text])),
  quantidade_estimada integer NOT NULL DEFAULT 1,
  receita_estimada numeric DEFAULT 0,
  status character varying DEFAULT 'planejado'::character varying CHECK (status::text = ANY (ARRAY['planejado'::character varying::text, 'preparando'::character varying::text, 'pronto'::character varying::text, 'cancelado'::character varying::text])),
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menu_diario_pkey PRIMARY KEY (id),
  CONSTRAINT menu_diario_planejamento_semanal_id_fkey FOREIGN KEY (planejamento_semanal_id) REFERENCES public.planejamento_semanal(id),
  CONSTRAINT menu_diario_menu_item_id_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id)
);
CREATE TABLE public.menu_item_ingredientes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  menu_item_id uuid NOT NULL,
  produto_id uuid NOT NULL,
  quantidade numeric NOT NULL CHECK (quantidade > 0::numeric),
  unidade character varying NOT NULL DEFAULT 'unidade'::character varying,
  opcional boolean DEFAULT false,
  observacoes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menu_item_ingredientes_pkey PRIMARY KEY (id),
  CONSTRAINT menu_item_ingredientes_menu_item_id_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id),
  CONSTRAINT menu_item_ingredientes_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id)
);
CREATE TABLE public.menu_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome character varying NOT NULL,
  descricao text,
  categoria_id uuid,
  preco_venda numeric NOT NULL,
  custo_ingredientes numeric NOT NULL DEFAULT 0,
  tempo_preparo integer NOT NULL DEFAULT 0,
  dificuldade character varying DEFAULT 'medium'::character varying CHECK (dificuldade::text = ANY (ARRAY['easy'::character varying::text, 'medium'::character varying::text, 'hard'::character varying::text])),
  porcoes integer DEFAULT 1,
  score_popularidade integer DEFAULT 0 CHECK (score_popularidade >= 0 AND score_popularidade <= 100),
  disponivel boolean DEFAULT true,
  destaque boolean DEFAULT false,
  calorias integer,
  proteina_g numeric,
  carboidratos_g numeric,
  gordura_g numeric,
  tags ARRAY,
  criado_por uuid,
  ativo boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menu_items_pkey PRIMARY KEY (id),
  CONSTRAINT menu_items_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id),
  CONSTRAINT menu_items_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.admin_users(id)
);
CREATE TABLE public.movements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL,
  type character varying NOT NULL,
  quantity integer NOT NULL,
  previous_stock integer,
  new_stock integer,
  unit_cost numeric,
  total_cost numeric,
  notes text,
  supplier character varying,
  invoice_number character varying,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT movements_pkey PRIMARY KEY (id),
  CONSTRAINT movements_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.produtos(id),
  CONSTRAINT movements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admin_users(id)
);
CREATE TABLE public.permissions (
  id character varying NOT NULL,
  name character varying NOT NULL,
  description text,
  category character varying NOT NULL DEFAULT 'sistema'::character varying,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT permissions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.planejamento_semanal (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  data_inicio date NOT NULL,
  data_fim date NOT NULL,
  status character varying DEFAULT 'ativo'::character varying CHECK (status::text = ANY (ARRAY['rascunho'::character varying::text, 'planejado'::character varying::text, 'ativo'::character varying::text, 'concluido'::character varying::text])),
  observacoes text,
  receita_estimada numeric DEFAULT 0,
  criado_por uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT planejamento_semanal_pkey PRIMARY KEY (id),
  CONSTRAINT planejamento_semanal_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.admin_users(id)
);
CREATE TABLE public.produtos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome character varying NOT NULL,
  categoria_id uuid,
  preco numeric NOT NULL DEFAULT 0,
  custo numeric DEFAULT 0,
  current_stock integer DEFAULT 0,
  estoque_atual integer DEFAULT 0,
  min_stock integer DEFAULT 0,
  estoque_minimo integer DEFAULT 0,
  max_stock integer,
  unidade character varying DEFAULT 'unidade'::character varying,
  descricao text,
  codigo_barras character varying,
  ativo boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT produtos_pkey PRIMARY KEY (id),
  CONSTRAINT produtos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id),
  CONSTRAINT produtos_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admin_users(id)
);
CREATE TABLE public.reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title character varying NOT NULL,
  type character varying,
  filters jsonb,
  data jsonb,
  generated_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reports_pkey PRIMARY KEY (id),
  CONSTRAINT reports_generated_by_fkey FOREIGN KEY (generated_by) REFERENCES public.admin_users(id)
);
CREATE TABLE public.role_permissions (
  role_id character varying NOT NULL,
  permission_id character varying NOT NULL,
  granted boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id),
  CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.user_roles(id),
  CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id)
);
CREATE TABLE public.suppliers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  contact character varying,
  phone character varying,
  email character varying,
  address text,
  category character varying,
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])),
  last_order timestamp with time zone,
  products_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT suppliers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.support_conversations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  subject text NOT NULL,
  status text NOT NULL DEFAULT 'open'::text CHECK (status = ANY (ARRAY['open'::text, 'closed'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_conversations_pkey PRIMARY KEY (id)
);
CREATE TABLE public.support_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL,
  sender_id uuid NOT NULL,
  sender_role text NOT NULL CHECK (sender_role = ANY (ARRAY['admin'::text, 'support'::text])),
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_messages_pkey PRIMARY KEY (id),
  CONSTRAINT support_messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.support_conversations(id)
);
CREATE TABLE public.support_participants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['admin'::text, 'support'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_participants_pkey PRIMARY KEY (id),
  CONSTRAINT support_participants_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.support_conversations(id)
);
CREATE TABLE public.user_roles (
  id character varying NOT NULL,
  name character varying NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT user_roles_pkey PRIMARY KEY (id)
);