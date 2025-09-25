-- Script para adicionar funcionalidade de avatar para administradores
-- Execute este script no Supabase SQL Editor

-- 1. Adicionar coluna avatar_url na tabela admin_users se não existir
ALTER TABLE public.admin_users
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 2. Adicionar outras colunas necessárias para o perfil se não existirem
ALTER TABLE public.admin_users
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{"emailNotifications": true, "pushNotifications": true, "darkMode": false, "language": "pt-BR"}';

ALTER TABLE public.admin_users
ADD COLUMN IF NOT EXISTS login_count INTEGER DEFAULT 0;

ALTER TABLE public.admin_users
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP WITH TIME ZONE;

-- 3. Criar bucket para armazenamento de avatars no Supabase Storage
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'user-avatars',
    'user-avatars',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 4. Criar políticas de segurança para o bucket de avatars (somente se não existirem)

-- Verificar e criar política de upload
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Users can upload their own avatars'
    ) THEN
        CREATE POLICY "Users can upload their own avatars" ON storage.objects
        FOR INSERT TO authenticated
        WITH CHECK (bucket_id = 'user-avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

-- Verificar e criar política de visualização
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Anyone can view avatars'
    ) THEN
        CREATE POLICY "Anyone can view avatars" ON storage.objects
        FOR SELECT TO public
        USING (bucket_id = 'user-avatars');
    END IF;
END $$;

-- Verificar e criar política de atualização
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Users can update their own avatars'
    ) THEN
        CREATE POLICY "Users can update their own avatars" ON storage.objects
        FOR UPDATE TO authenticated
        USING (bucket_id = 'user-avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

-- Verificar e criar política de remoção
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Users can delete their own avatars'
    ) THEN
        CREATE POLICY "Users can delete their own avatars" ON storage.objects
        FOR DELETE TO authenticated
        USING (bucket_id = 'user-avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

-- 5. Comentário informativo
COMMENT ON COLUMN public.admin_users.avatar_url IS 'URL do avatar do usuário armazenado no Supabase Storage';