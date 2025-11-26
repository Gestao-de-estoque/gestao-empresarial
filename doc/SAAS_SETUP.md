# Setup do Sistema SaaS - GestaoZe

Este documento contém instruções completas para configurar o sistema SaaS multi-tenant do GestaoZe.

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Estrutura do Sistema](#estrutura-do-sistema)
3. [Instalação do Banco de Dados](#instalação-do-banco-de-dados)
4. [Configuração das Rotas](#configuração-das-rotas)
5. [Funcionalidades Implementadas](#funcionalidades-implementadas)
6. [Como Testar](#como-testar)

## 🎯 Visão Geral

O GestaoZe agora é um sistema SaaS completo com as seguintes características:

- **Multi-tenancy**: Cada empresa tem seu próprio espaço isolado
- **Sistema de Planos**: Básico, Profissional e Empresarial
- **Período de Teste**: 14 dias grátis em todos os planos
- **Landing Pages**: Home, Pricing, FAQ, Contact
- **Sistema de Registro**: Cadastro automático de empresas e usuários

## 🏗️ Estrutura do Sistema

### Novas Páginas Criadas

```
src/views/
├── HomeView.vue           # Landing page principal
├── PricingView.vue        # Página de preços
├── RegisterView.vue       # Cadastro de empresas
├── FAQView.vue            # Perguntas frequentes
└── ContactView.vue        # Formulário de contato
```

### Novas Tabelas do Banco de Dados

```sql
- tenants                   # Empresas (multi-tenant)
- subscription_plans        # Planos de assinatura
- subscription_history      # Histórico de assinaturas
- tenant_users             # Usuários por empresa
- tenant_invitations       # Convites de usuários
- leads                    # Leads/interessados
- contact_messages         # Mensagens de contato
- blog_posts              # Posts do blog
- faq_items               # Perguntas frequentes
- testimonials            # Depoimentos de clientes
```

### Serviços Implementados

```
src/services/
└── registrationService.ts  # Serviço de registro e gestão SaaS
```

## 💾 Instalação do Banco de Dados

### Passo 1: Acessar o Supabase SQL Editor

1. Faça login no [Supabase](https://supabase.com)
2. Selecione seu projeto
3. Navegue até **SQL Editor** no menu lateral

### Passo 2: Executar o Script de Setup

Execute o arquivo SQL localizado em:
```
src/sql/create_saas_structure.sql
```

**Como executar:**
1. Abra o arquivo `create_saas_structure.sql`
2. Copie todo o conteúdo
3. Cole no SQL Editor do Supabase
4. Clique em **Run** ou pressione `Ctrl+Enter`

### Passo 3: Verificar a Instalação

Após executar o script, você deverá ver:
- ✅ 10 novas tabelas criadas
- ✅ 3 planos de assinatura cadastrados
- ✅ 6 itens de FAQ cadastrados
- ✅ 3 depoimentos cadastrados
- ✅ Índices e triggers configurados

### Passo 4: Configurar Permissões (Opcional)

Se necessário, configure as permissões de Row Level Security (RLS) para as novas tabelas.

## 🛣️ Configuração das Rotas

As rotas já foram configuradas no arquivo `src/router/index.ts`.

### Rotas Públicas (SaaS)

- `/` - Landing page principal
- `/pricing` - Página de preços
- `/register` - Cadastro de empresas
- `/faq` - Perguntas frequentes
- `/contact` - Contato

### Rotas de Autenticação

- `/login` - Login de usuários

### Rotas do Dashboard (Autenticadas)

- `/dashboard` - Dashboard principal
- `/inventory` - Gestão de estoque
- `/financial` - Módulo financeiro
- E todas as outras rotas existentes...

## ✨ Funcionalidades Implementadas

### 1. Landing Page (Home)

**Localização**: `src/views/HomeView.vue`

**Recursos:**
- Design moderno e responsivo
- Seção Hero com CTA
- Grid de recursos (8 recursos principais)
- Depoimentos de clientes
- Estatísticas do sistema
- Footer completo com links

### 2. Página de Preços

**Localização**: `src/views/PricingView.vue`

**Recursos:**
- 3 planos de assinatura (Básico, Profissional, Empresarial)
- Toggle mensal/anual (20% desconto anual)
- Comparação detalhada de recursos
- FAQ de preços
- CTA para registro

**Planos:**

| Plano | Preço Mensal | Preço Anual | Usuários | Armazenamento |
|-------|--------------|-------------|----------|---------------|
| Básico | R$ 49,90 | R$ 479,00 | 5 | 1GB |
| Profissional | R$ 99,90 | R$ 959,00 | 20 | 5GB |
| Empresarial | R$ 199,90 | R$ 1.919,00 | Ilimitado | Ilimitado |

### 3. Página de Registro

**Localização**: `src/views/RegisterView.vue`

**Recursos:**
- Formulário em 2 colunas (info + form)
- Validação de dados
- Seleção de plano via query parameter
- Aceite de termos e condições
- Criação automática de:
  - Empresa (tenant)
  - Usuário owner
  - Relacionamento tenant-user
  - Histórico de assinatura

**Fluxo de Registro:**
```
1. Usuário preenche formulário
2. Sistema valida dados
3. Cria empresa (tenant) com slug único
4. Cria usuário administrador
5. Vincula usuário à empresa
6. Inicia período de teste (14 dias)
7. Registra histórico de assinatura
8. Redireciona para login
```

### 4. FAQ

**Localização**: `src/views/FAQView.vue`

**Recursos:**
- Busca de perguntas
- Filtro por categoria
- Accordion com animações
- 6 perguntas pré-cadastradas

**Categorias:**
- Geral
- Planos e Preços
- Pagamentos
- Segurança
- Migração
- Suporte

### 5. Contato

**Localização**: `src/views/ContactView.vue`

**Recursos:**
- Formulário completo
- Cards de informação de contato
- Validação de campos
- Armazenamento no banco de dados
- Mensagem de sucesso

## 🧪 Como Testar

### 1. Testar a Landing Page

```bash
# Iniciar o servidor de desenvolvimento
npm run dev

# Acessar
http://localhost:5173/
```

**O que verificar:**
- ✅ Hero section carrega corretamente
- ✅ Grid de recursos exibe 8 cards
- ✅ Depoimentos aparecem
- ✅ Links de navegação funcionam
- ✅ Responsividade (mobile/tablet/desktop)

### 2. Testar Página de Preços

```bash
# Acessar
http://localhost:5173/pricing
```

**O que verificar:**
- ✅ 3 planos exibidos corretamente
- ✅ Toggle mensal/anual funciona
- ✅ Cálculo de preços está correto
- ✅ Tabela de comparação funciona
- ✅ Links para registro funcionam

### 3. Testar Registro de Empresa

```bash
# Acessar diretamente
http://localhost:5173/register

# Ou via pricing com plano selecionado
http://localhost:5173/register?plan=profissional
```

**O que verificar:**
- ✅ Formulário valida campos obrigatórios
- ✅ Senhas devem coincidir
- ✅ Plano selecionado aparece
- ✅ Registro cria empresa no banco
- ✅ Usuário é criado e vinculado
- ✅ Redireciona para login após sucesso

**Dados de teste:**
```
Empresa: Restaurante Teste
Email: teste@restaurante.com
Telefone: (11) 99999-9999
CNPJ: 12.345.678/0001-90
Nome: João Silva
Senha: senha123456
```

### 4. Testar FAQ

```bash
# Acessar
http://localhost:5173/faq
```

**O que verificar:**
- ✅ Busca filtra perguntas
- ✅ Categorias filtram corretamente
- ✅ Accordion abre/fecha
- ✅ 6 perguntas carregam do banco

### 5. Testar Contato

```bash
# Acessar
http://localhost:5173/contact
```

**O que verificar:**
- ✅ Formulário valida campos
- ✅ Mensagem é salva no banco
- ✅ Sucesso exibe confirmação
- ✅ Formulário é limpo após envio

## 🔧 Configurações Adicionais

### Variáveis de Ambiente

Certifique-se de que as seguintes variáveis estão configuradas no `.env`:

```env
VITE_SUPABASE_URL=sua_url_do_supabase
VITE_SUPABASE_ANON_KEY=sua_chave_anonima
```

### Próximos Passos (Opcional)

1. **Implementar Blog:**
   - Criar `BlogView.vue`
   - Listar posts do banco de dados
   - Sistema de categorias e tags

2. **Implementar Pagamentos:**
   - Integração com Stripe/Mercado Pago
   - Webhook para atualizar status de assinatura
   - Gestão de faturas

3. **Dashboard Multi-tenant:**
   - Modificar dashboard para filtrar dados por tenant
   - Adicionar seletor de empresa (para usuários com múltiplas empresas)
   - Isolar dados por tenant_id

4. **Email Notifications:**
   - Welcome email após registro
   - Email de trial expirando
   - Notificações de pagamento

## 📚 Documentação Adicional

### Estrutura de Dados

#### Tenant (Empresa)
```typescript
interface Tenant {
  id: UUID
  name: string
  slug: string
  email: string
  phone?: string
  cnpj?: string
  status: 'trial' | 'active' | 'suspended' | 'cancelled'
  subscription_plan_id: UUID
  trial_ends_at: timestamp
  max_users: number
  current_users: number
  max_storage_mb: number
  current_storage_mb: number
  settings: JSON
  created_at: timestamp
}
```

#### Subscription Plan
```typescript
interface SubscriptionPlan {
  id: UUID
  name: string
  slug: string
  description: string
  price_monthly: number
  price_yearly: number
  max_users: number
  max_storage_mb: number
  features: JSON
  trial_days: number
  is_active: boolean
}
```

## 🆘 Solução de Problemas

### Erro: "Tabelas não encontradas"
**Solução**: Execute novamente o script SQL `create_saas_structure.sql`

### Erro: "Plano não encontrado"
**Solução**: Verifique se os planos foram inseridos no banco de dados. Execute:
```sql
SELECT * FROM subscription_plans;
```

### Erro ao criar empresa: "Slug já existe"
**Solução**: Tente usar um nome de empresa diferente ou adicione números/sufixos

### Registro não funciona
**Solução**:
1. Verifique as permissões do Supabase (RLS)
2. Abra o console do navegador para ver erros
3. Verifique se o serviço `registrationService` está importado

## 📝 Checklist de Implementação

- [x] Criar estrutura SQL do banco de dados
- [x] Criar Landing Page (Home)
- [x] Criar página de Preços
- [x] Criar página de Registro
- [x] Criar página de FAQ
- [x] Criar página de Contato
- [x] Configurar rotas
- [x] Implementar serviço de registro
- [x] Atualizar configuração do Supabase
- [ ] Implementar Blog (opcional)
- [ ] Integrar pagamentos (opcional)
- [ ] Implementar multi-tenancy no dashboard (próximo passo)
- [ ] Configurar emails transacionais (opcional)

## 🎉 Conclusão

O sistema SaaS está pronto para uso! Os usuários podem:

1. Visitar o site em `/`
2. Ver os planos em `/pricing`
3. Se registrar em `/register`
4. Fazer login em `/login`
5. Acessar o dashboard em `/dashboard`

Cada empresa terá seus próprios dados isolados e poderá gerenciar seus usuários, produtos, vendas e finanças de forma independente.

---

**Desenvolvido com 💜 por GestaoZe Team**

Para suporte: contato@gestaozе.com.br
