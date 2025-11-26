-- Tabelas para Chat de Suporte

create table if not exists public.support_conversations (
  id uuid primary key default gen_random_uuid(),
  subject text not null,
  status text not null default 'open' check (status in ('open','closed')),
  created_at timestamp with time zone default now()
);

create table if not exists public.support_participants (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.support_conversations(id) on delete cascade,
  user_id uuid not null,
  role text not null check (role in ('admin','support')),
  created_at timestamp with time zone default now()
);

create table if not exists public.support_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.support_conversations(id) on delete cascade,
  sender_id uuid not null,
  sender_role text not null check (sender_role in ('admin','support')),
  content text not null,
  created_at timestamp with time zone default now()
);

-- Índices para performance
create index if not exists idx_support_participants_conv on public.support_participants(conversation_id);
create index if not exists idx_support_messages_conv on public.support_messages(conversation_id);

-- Recomendações de políticas (RLS) a definir conforme seu modelo de usuários
-- Exemplo (adapte): permitir que participantes vejam suas conversas
-- alter table public.support_conversations enable row level security;
-- create policy "Allow participants" on public.support_conversations for select using (
--   exists(select 1 from public.support_participants sp where sp.conversation_id = id and sp.user_id = auth.uid())
-- );

