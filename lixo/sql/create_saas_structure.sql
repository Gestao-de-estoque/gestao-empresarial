-- ==========================================
-- ESTRUTURA DE BANCO DE DADOS PARA SAAS MULTI-TENANT
-- Sistema de Gestão Empresarial - GestaoZe
-- ==========================================

-- ==========================================
-- 1. TABELA DE ORGANIZAÇÕES/EMPRESAS (TENANTS)
-- ==========================================

CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL, -- URL amigável (ex: empresa-abc)
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    cnpj VARCHAR(18), -- Para empresas brasileiras

    -- Endereço
    address_street TEXT,
    address_number VARCHAR(20),
    address_complement VARCHAR(100),
    address_neighborhood VARCHAR(100),
    address_city VARCHAR(100),
    address_state VARCHAR(2),
    address_zip_code VARCHAR(10),
    address_country VARCHAR(50) DEFAULT 'Brasil',

    -- Status e configurações
    status VARCHAR(20) DEFAULT 'trial' CHECK (status IN ('trial', 'active', 'suspended', 'cancelled')),
    subscription_plan_id UUID, -- Referência ao plano
    subscription_status VARCHAR(20) DEFAULT 'trialing' CHECK (subscription_status IN ('trialing', 'active', 'past_due', 'cancelled')),
    trial_ends_at TIMESTAMP WITH TIME ZONE,
    subscription_started_at TIMESTAMP WITH TIME ZONE,
    subscription_ends_at TIMESTAMP WITH TIME ZONE,

    -- Configurações personalizadas
    settings JSONB DEFAULT '{}'::jsonb,
    logo_url TEXT,
    primary_color VARCHAR(7) DEFAULT '#3b82f6',

    -- Limites e uso
    max_users INTEGER DEFAULT 5,
    current_users INTEGER DEFAULT 0,
    max_storage_mb INTEGER DEFAULT 1000, -- 1GB
    current_storage_mb NUMERIC(10,2) DEFAULT 0,

    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,

    CONSTRAINT tenants_name_not_empty CHECK (length(trim(name)) > 0),
    CONSTRAINT tenants_slug_lowercase CHECK (slug = lower(slug))
);

-- ==========================================
-- 2. PLANOS DE ASSINATURA
-- ==========================================

CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,

    -- Preços
    price_monthly NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    price_yearly NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'BRL',

    -- Features e limites
    max_users INTEGER NOT NULL DEFAULT 5,
    max_storage_mb INTEGER NOT NULL DEFAULT 1000,
    max_products INTEGER DEFAULT -1, -- -1 = ilimitado
    max_transactions_month INTEGER DEFAULT -1,

    -- Features booleanas
    features JSONB DEFAULT '{}'::jsonb,
    -- Exemplo: {"ai_analytics": true, "api_access": true, "priority_support": true}

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_popular BOOLEAN DEFAULT false,
    is_recommended BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,

    -- Trial
    trial_days INTEGER DEFAULT 14,

    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3. HISTÓRICO DE ASSINATURAS
-- ==========================================

CREATE TABLE IF NOT EXISTS subscription_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),

    -- Detalhes da assinatura
    billing_cycle VARCHAR(20) NOT NULL CHECK (billing_cycle IN ('monthly', 'yearly')),
    amount NUMERIC(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',

    -- Período
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ends_at TIMESTAMP WITH TIME ZONE,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,

    -- Pagamento
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    paid_at TIMESTAMP WITH TIME ZONE,

    -- Metadados
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 4. USUÁRIOS DO TENANT (Multi-tenant users)
-- ==========================================

CREATE TABLE IF NOT EXISTS tenant_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    admin_user_id UUID REFERENCES admin_users(id) ON DELETE CASCADE,

    -- Informações do usuário
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user', -- owner, admin, manager, user

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_owner BOOLEAN DEFAULT false, -- Apenas um owner por tenant

    -- Permissões específicas do tenant
    permissions JSONB DEFAULT '[]'::jsonb,

    -- Datas
    invited_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    joined_at TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT tenant_users_unique_email_per_tenant UNIQUE(tenant_id, email),
    CONSTRAINT tenant_users_email_lowercase CHECK (email = lower(email))
);

-- ==========================================
-- 5. CONVITES DE USUÁRIOS
-- ==========================================

CREATE TABLE IF NOT EXISTS tenant_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

    -- Dados do convite
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    invited_by UUID REFERENCES admin_users(id),

    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
    token VARCHAR(255) UNIQUE NOT NULL,

    -- Datas
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    accepted_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT tenant_invitations_email_lowercase CHECK (email = lower(email))
);

-- ==========================================
-- 6. LEADS E CONTATOS
-- ==========================================

CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Informações de contato
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    company VARCHAR(255),

    -- Origem
    source VARCHAR(50), -- website, landing_page, referral, etc.
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),

    -- Mensagem/interesse
    message TEXT,
    interested_in VARCHAR(50), -- pricing, demo, contact, etc.

    -- Status
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'converted', 'lost')),

    -- Follow-up
    contacted_at TIMESTAMP WITH TIME ZONE,
    converted_to_tenant_id UUID REFERENCES tenants(id),

    -- Metadados
    metadata JSONB DEFAULT '{}'::jsonb,
    ip_address INET,
    user_agent TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 7. POSTS DE BLOG
-- ==========================================

CREATE TABLE IF NOT EXISTS blog_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Conteúdo
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    excerpt TEXT,
    content TEXT NOT NULL,
    featured_image_url TEXT,

    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT[],

    -- Categorização
    category VARCHAR(100),
    tags TEXT[],

    -- Autor
    author_id UUID REFERENCES admin_users(id),
    author_name VARCHAR(255),

    -- Status
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    is_featured BOOLEAN DEFAULT false,

    -- Estatísticas
    views_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,

    -- Datas
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 8. FAQ (Perguntas Frequentes)
-- ==========================================

CREATE TABLE IF NOT EXISTS faq_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Conteúdo
    question TEXT NOT NULL,
    answer TEXT NOT NULL,

    -- Categorização
    category VARCHAR(100) NOT NULL,

    -- Ordenação e status
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,

    -- Estatísticas
    views_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 9. MENSAGENS DE CONTATO
-- ==========================================

CREATE TABLE IF NOT EXISTS contact_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Remetente
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    company VARCHAR(255),

    -- Mensagem
    subject VARCHAR(255),
    message TEXT NOT NULL,

    -- Status
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'read', 'replied', 'archived')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),

    -- Resposta
    replied_at TIMESTAMP WITH TIME ZONE,
    replied_by UUID REFERENCES admin_users(id),
    reply_message TEXT,

    -- Metadados
    ip_address INET,
    user_agent TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 10. TESTEMUNHOS/DEPOIMENTOS
-- ==========================================

CREATE TABLE IF NOT EXISTS testimonials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Autor
    author_name VARCHAR(255) NOT NULL,
    author_role VARCHAR(255),
    author_company VARCHAR(255),
    author_avatar_url TEXT,

    -- Conteúdo
    content TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),

    -- Status
    is_featured BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,

    -- Metadados
    tenant_id UUID REFERENCES tenants(id), -- Se for de um cliente real

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 11. ÍNDICES PARA PERFORMANCE
-- ==========================================

-- Tenants
CREATE INDEX IF NOT EXISTS idx_tenants_slug ON tenants(slug);
CREATE INDEX IF NOT EXISTS idx_tenants_status ON tenants(status);
CREATE INDEX IF NOT EXISTS idx_tenants_subscription_plan ON tenants(subscription_plan_id);
CREATE INDEX IF NOT EXISTS idx_tenants_created_at ON tenants(created_at DESC);

-- Subscription plans
CREATE INDEX IF NOT EXISTS idx_subscription_plans_slug ON subscription_plans(slug);
CREATE INDEX IF NOT EXISTS idx_subscription_plans_active ON subscription_plans(is_active);

-- Tenant users
CREATE INDEX IF NOT EXISTS idx_tenant_users_tenant ON tenant_users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_users_email ON tenant_users(email);
CREATE INDEX IF NOT EXISTS idx_tenant_users_admin_user ON tenant_users(admin_user_id);

-- Leads
CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads(created_at DESC);

-- Blog
CREATE INDEX IF NOT EXISTS idx_blog_posts_slug ON blog_posts(slug);
CREATE INDEX IF NOT EXISTS idx_blog_posts_status ON blog_posts(status);
CREATE INDEX IF NOT EXISTS idx_blog_posts_published ON blog_posts(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_blog_posts_category ON blog_posts(category);

-- FAQ
CREATE INDEX IF NOT EXISTS idx_faq_category ON faq_items(category);
CREATE INDEX IF NOT EXISTS idx_faq_active ON faq_items(is_active);

-- Contact messages
CREATE INDEX IF NOT EXISTS idx_contact_messages_status ON contact_messages(status);
CREATE INDEX IF NOT EXISTS idx_contact_messages_created_at ON contact_messages(created_at DESC);

-- ==========================================
-- 12. TRIGGERS PARA UPDATED_AT
-- ==========================================

-- Trigger para tenants
CREATE TRIGGER update_tenants_updated_at
    BEFORE UPDATE ON tenants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para subscription_plans
CREATE TRIGGER update_subscription_plans_updated_at
    BEFORE UPDATE ON subscription_plans
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para tenant_users
CREATE TRIGGER update_tenant_users_updated_at
    BEFORE UPDATE ON tenant_users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para leads
CREATE TRIGGER update_leads_updated_at
    BEFORE UPDATE ON leads
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para blog_posts
CREATE TRIGGER update_blog_posts_updated_at
    BEFORE UPDATE ON blog_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para faq_items
CREATE TRIGGER update_faq_items_updated_at
    BEFORE UPDATE ON faq_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para contact_messages
CREATE TRIGGER update_contact_messages_updated_at
    BEFORE UPDATE ON contact_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para testimonials
CREATE TRIGGER update_testimonials_updated_at
    BEFORE UPDATE ON testimonials
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- 13. DADOS INICIAIS - PLANOS DE ASSINATURA
-- ==========================================

INSERT INTO subscription_plans (name, slug, description, price_monthly, price_yearly, max_users, max_storage_mb, features, is_popular, is_recommended, display_order, trial_days) VALUES
    (
        'Básico',
        'basico',
        'Perfeito para pequenos negócios que estão começando',
        49.90,
        479.00, -- ~20% desconto anual
        5,
        1000,
        '{"dashboard": true, "inventory": true, "basic_reports": true, "email_support": true, "api_access": false, "ai_analytics": false, "priority_support": false, "custom_branding": false}'::jsonb,
        false,
        false,
        1,
        14
    ),
    (
        'Profissional',
        'profissional',
        'Para empresas em crescimento que precisam de mais recursos',
        99.90,
        959.00, -- ~20% desconto anual
        20,
        5000,
        '{"dashboard": true, "inventory": true, "basic_reports": true, "advanced_reports": true, "financial_module": true, "employee_management": true, "email_support": true, "api_access": true, "ai_analytics": true, "priority_support": false, "custom_branding": false}'::jsonb,
        true,
        true,
        2,
        14
    ),
    (
        'Empresarial',
        'empresarial',
        'Solução completa para grandes empresas',
        199.90,
        1919.00, -- ~20% desconto anual
        -1, -- ilimitado
        -1, -- ilimitado
        '{"dashboard": true, "inventory": true, "basic_reports": true, "advanced_reports": true, "financial_module": true, "employee_management": true, "email_support": true, "phone_support": true, "api_access": true, "ai_analytics": true, "priority_support": true, "custom_branding": true, "dedicated_support": true, "custom_integrations": true}'::jsonb,
        false,
        false,
        3,
        30
    )
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    price_monthly = EXCLUDED.price_monthly,
    price_yearly = EXCLUDED.price_yearly,
    max_users = EXCLUDED.max_users,
    max_storage_mb = EXCLUDED.max_storage_mb,
    features = EXCLUDED.features,
    updated_at = CURRENT_TIMESTAMP;

-- ==========================================
-- 14. DADOS INICIAIS - FAQ
-- ==========================================

INSERT INTO faq_items (question, answer, category, display_order, is_active) VALUES
    (
        'Como funciona o período de teste gratuito?',
        'Oferecemos 14 dias de teste gratuito em todos os planos. Durante este período, você terá acesso completo a todas as funcionalidades do plano escolhido, sem precisar cadastrar cartão de crédito. Ao final do período, você pode optar por assinar ou não o serviço.',
        'Geral',
        1,
        true
    ),
    (
        'Posso mudar de plano a qualquer momento?',
        'Sim! Você pode fazer upgrade ou downgrade do seu plano a qualquer momento. No caso de upgrade, a diferença será calculada proporcionalmente. No downgrade, o valor será creditado para o próximo ciclo de cobrança.',
        'Planos e Preços',
        2,
        true
    ),
    (
        'Quais formas de pagamento são aceitas?',
        'Aceitamos cartões de crédito (Visa, Mastercard, Amex), boleto bancário e PIX. Também oferecemos desconto de 20% para pagamentos anuais.',
        'Pagamentos',
        3,
        true
    ),
    (
        'Os meus dados estão seguros?',
        'Sim! Utilizamos criptografia de ponta a ponta (SSL/TLS) e seguimos as melhores práticas de segurança. Somos compliance com LGPD e realizamos backups automáticos diários dos seus dados.',
        'Segurança',
        4,
        true
    ),
    (
        'Posso importar dados do meu sistema atual?',
        'Sim! Oferecemos ferramentas de importação para os principais formatos (CSV, Excel). Nossa equipe de suporte também pode auxiliar na migração de dados de outros sistemas.',
        'Migração',
        5,
        true
    ),
    (
        'Existe suporte técnico disponível?',
        'Sim! Todos os planos incluem suporte por email. Os planos Profissional e Empresarial também incluem suporte prioritário e, no caso do plano Empresarial, suporte por telefone e gerente de conta dedicado.',
        'Suporte',
        6,
        true
    )
ON CONFLICT DO NOTHING;

-- ==========================================
-- 15. DADOS INICIAIS - TESTEMUNHOS
-- ==========================================

INSERT INTO testimonials (author_name, author_role, author_company, content, rating, is_featured, is_approved, display_order) VALUES
    (
        'Maria Silva',
        'Proprietária',
        'Restaurante Sabor Caseiro',
        'O GestaoZe transformou completamente a gestão do meu restaurante. Agora consigo acompanhar vendas, estoque e finanças em tempo real. A ferramenta de IA me ajuda a prever demandas e evitar desperdícios. Recomendo muito!',
        5,
        true,
        true,
        1
    ),
    (
        'João Santos',
        'Gerente',
        'Padaria do Bairro',
        'Implementamos o sistema há 6 meses e já vimos uma redução de 30% nos custos com estoque. A interface é muito intuitiva e o suporte é excelente. Vale cada centavo!',
        5,
        true,
        true,
        2
    ),
    (
        'Ana Costa',
        'Diretora Financeira',
        'Rede FastFood Premium',
        'Gerenciamos 5 unidades com o GestaoZe. A visão consolidada e os relatórios detalhados nos permitem tomar decisões estratégicas com muito mais segurança. A equipe ama a facilidade de uso!',
        5,
        true,
        true,
        3
    )
ON CONFLICT DO NOTHING;

-- ==========================================
-- FIM DO SCRIPT
-- ==========================================

SELECT '✅ Estrutura SaaS criada com sucesso!' as resultado;
SELECT 'Total de tabelas criadas: 10' as info_1;
SELECT 'Planos de assinatura: 3 (Básico, Profissional, Empresarial)' as info_2;
SELECT 'FAQ items: 6' as info_3;
SELECT 'Testemunhos: 3' as info_4;
