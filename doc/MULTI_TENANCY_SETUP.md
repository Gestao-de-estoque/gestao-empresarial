# Configuração de Multi-Tenancy - Isolamento de Dados

## 🎯 Problema

Atualmente, quando um usuário se registra e faz login, ele consegue ver dados de TODAS as empresas (tenants) ao invés de ver apenas os dados da sua própria empresa.

## ✅ Solução

Implementar **isolamento de dados por tenant (empresa)** através da coluna `tenant_id` em todas as tabelas relevantes + Row Level Security (RLS).

---

## 📋 Passo a Passo

### **Passo 1: Executar Script SQL de Migração**

Este script adiciona a coluna `tenant_id` em todas as tabelas que armazenam dados específicos de cada empresa.

```bash
# Abra o Supabase SQL Editor
# Execute o arquivo:
src/sql/add_multi_tenancy.sql
```

**O que esse script faz:**
- ✅ Adiciona coluna `tenant_id` em ~20 tabelas
- ✅ Cria índices para performance
- ✅ Configura Row Level Security (RLS)
- ✅ Cria triggers para auto-preencher `tenant_id`
- ✅ Cria função `set_current_tenant()` para configurar a sessão

### **Passo 2: Verificar a Instalação**

Após executar o script, verifique se foi bem-sucedido:

```sql
-- Verificar se tenant_id foi adicionado nas tabelas
SELECT
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name = 'tenant_id'
ORDER BY table_name;
```

**Você deve ver tenant_id em:**
- ✅ produtos
- ✅ categorias
- ✅ movements
- ✅ suppliers
- ✅ menu_items
- ✅ menu_item_ingredientes
- ✅ employees
- ✅ financial_data
- ✅ logs
- ✅ reports
- E outras...

---

## 🔐 Como Funciona o Isolamento

### **1. Durante o Registro**

Quando um novo usuário cria uma conta:

```typescript
// 1. Cria a empresa (tenant)
const tenant = await supabase.from('tenants').insert({
  name: 'Restaurante ABC',
  slug: 'restaurante-abc',
  ...
})

// 2. Cria o usuário e associa ao tenant
const user = await supabase.from('admin_users').insert({
  email: 'dono@restaurante.com',
  tenant_id: tenant.id,  // ← ASSOCIAÇÃO
  ...
})

// 3. Cria o relacionamento tenant-user
await supabase.from('tenant_users').insert({
  tenant_id: tenant.id,
  admin_user_id: user.id,
  role: 'owner'
})
```

### **2. Durante o Login**

Quando o usuário faz login, o sistema:

```typescript
// 1. Autentica o usuário
const user = await supabase.from('admin_users')
  .select('*, tenant_id')
  .eq('email', email)
  .single()

// 2. Configura o tenant_id na sessão
await supabase.rpc('set_current_tenant', {
  tenant_uuid: user.tenant_id
})

// 3. Salva no localStorage
localStorage.setItem('currentTenantId', user.tenant_id)
```

### **3. Durante as Consultas**

Graças ao RLS (Row Level Security), todas as consultas são automaticamente filtradas:

```sql
-- O usuário faz:
SELECT * FROM produtos;

-- Mas o RLS transforma em:
SELECT * FROM produtos
WHERE tenant_id = get_current_tenant_id();
```

**Isso significa:**
- ✅ O usuário só vê produtos da sua empresa
- ✅ Não precisa adicionar `WHERE tenant_id = ...` em cada query
- ✅ Isolamento automático e seguro
- ✅ Impossível acessar dados de outros tenants

---

## 📊 Tabelas Afetadas

### **Tabelas COM tenant_id** (dados isolados por empresa)

| Categoria | Tabelas |
|-----------|---------|
| **Produtos** | `produtos`, `categorias`, `movements`, `suppliers` |
| **Menu** | `menu_items`, `menu_item_ingredientes`, `menu_diario`, `planejamento_semanal` |
| **Funcionários** | `employees`, `daily_payments`, `employee_attendance`, `employee_performance_metrics`, `salary_configs` |
| **Financeiro** | `financial_data`, `daily_financial_summary` |
| **Sistema** | `logs`, `reports`, `app_settings`, `system_alerts` |
| **API** | `api_keys` |
| **Suporte** | `support_conversations` |

### **Tabelas SEM tenant_id** (dados globais)

| Tabela | Motivo |
|--------|--------|
| `tenants` | É a tabela de empresas |
| `admin_users` | Usuários podem estar em múltiplos tenants |
| `tenant_users` | Tabela de relacionamento |
| `subscription_plans` | Planos são globais |
| `banks` | Dados de referência |
| `faq_items` | FAQ do site público |
| `contact_messages` | Contatos do site |
| `leads` | Leads do site |
| `blog_posts` | Blog público |
| `testimonials` | Depoimentos globais |

---

## 🧪 Testes

### **Teste 1: Registrar Nova Empresa**

```bash
# 1. Acesse
http://localhost:5173/register

# 2. Preencha:
Empresa: Pizzaria Teste
Email: dono@pizzaria.com
Nome: João Silva
Senha: senha123456

# 3. Clique em "Criar conta"
```

**Resultado esperado:**
- ✅ Empresa criada na tabela `tenants`
- ✅ Usuário criado com `tenant_id` preenchido
- ✅ Relacionamento criado em `tenant_users`

### **Teste 2: Login e Isolamento**

```bash
# 1. Faça login com a conta criada
Email: dono@pizzaria.com
Senha: senha123456

# 2. Vá para /dashboard
# 3. Vá para /inventory (produtos)
```

**Resultado esperado:**
- ✅ Dashboard vazio (sem dados de outros tenants)
- ✅ Inventário vazio (ou apenas produtos deste tenant)
- ✅ Ao criar um produto, ele terá `tenant_id` automaticamente

### **Teste 3: Criar Produto**

```bash
# 1. Estando logado, vá para /inventory
# 2. Clique em "Novo Produto"
# 3. Preencha e salve

# 4. Verifique no banco:
SELECT id, nome, tenant_id FROM produtos;
```

**Resultado esperado:**
- ✅ Produto criado com `tenant_id` do usuário logado
- ✅ Apenas este usuário vê esse produto
- ✅ Outros tenants NÃO veem esse produto

### **Teste 4: Múltiplos Tenants**

```bash
# 1. Abra uma janela anônima
# 2. Registre OUTRA empresa:
Empresa: Lanchonete XYZ
Email: dono@lanchonete.com

# 3. Faça login e crie produtos

# 4. Volte para a primeira conta
```

**Resultado esperado:**
- ✅ Cada tenant vê apenas seus próprios dados
- ✅ Total isolamento entre empresas
- ✅ Produtos, funcionários, vendas separados

---

## 🔧 Troubleshooting

### **Problema: "RLS impedindo acesso"**

**Sintoma:** Nenhum dado aparece após login

**Solução:**
```sql
-- Verificar se o tenant foi configurado
SELECT current_setting('app.current_tenant_id', true);

-- Se retornar vazio, o login não configurou corretamente
-- Verifique se a função set_current_tenant existe:
SELECT * FROM pg_proc WHERE proname = 'set_current_tenant';
```

### **Problema: "Dados de outros tenants ainda aparecem"**

**Sintoma:** Usuário vê dados de todas as empresas

**Solução:**
```sql
-- 1. Verificar se RLS está habilitado
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'employees', 'financial_data');

-- 2. Se rowsecurity = false, habilitar:
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_data ENABLE ROW LEVEL SECURITY;

-- 3. Verificar políticas
SELECT * FROM pg_policies WHERE tablename = 'produtos';
```

### **Problema: "Erro ao inserir dados"**

**Sintoma:** Erro "tenant_id cannot be null"

**Solução:**
```sql
-- Verificar se os triggers existem
SELECT
    trigger_name,
    event_object_table
FROM information_schema.triggers
WHERE trigger_name LIKE '%tenant%';

-- Se não existirem, execute novamente add_multi_tenancy.sql
```

---

## 📈 Migração de Dados Existentes

Se você já tem dados no banco antes de implementar multi-tenancy:

### **Opção 1: Atribuir a um Tenant Específico**

```sql
-- Criar um tenant "padrão" para dados existentes
INSERT INTO tenants (name, slug, email, status)
VALUES ('Empresa Principal', 'empresa-principal', 'admin@empresa.com', 'active')
RETURNING id;

-- Atualizar todos os dados existentes
UPDATE produtos SET tenant_id = '[UUID_DO_TENANT]' WHERE tenant_id IS NULL;
UPDATE employees SET tenant_id = '[UUID_DO_TENANT]' WHERE tenant_id IS NULL;
UPDATE financial_data SET tenant_id = '[UUID_DO_TENANT]' WHERE tenant_id IS NULL;
-- etc...
```

### **Opção 2: Limpar Dados de Teste**

```sql
-- ⚠️ CUIDADO: Isso apaga TODOS os dados!
TRUNCATE TABLE produtos CASCADE;
TRUNCATE TABLE employees CASCADE;
TRUNCATE TABLE financial_data CASCADE;
-- etc...

-- Agora todos os novos dados terão tenant_id automaticamente
```

---

## 📚 Referências

- **Row Level Security (RLS):** https://supabase.com/docs/guides/auth/row-level-security
- **Multi-tenancy Patterns:** https://supabase.com/docs/guides/auth/managing-user-data#using-row-level-security

---

## ✅ Checklist de Implementação

- [ ] Executar `add_multi_tenancy.sql` no Supabase
- [ ] Verificar que `tenant_id` foi adicionado nas tabelas
- [ ] Verificar que RLS está habilitado
- [ ] Verificar que políticas foram criadas
- [ ] Atualizar `admin_users` com `tenant_id`
- [ ] Código do `authService` atualizado
- [ ] Código do `registrationService` atualizado
- [ ] Testar registro de nova empresa
- [ ] Testar login e isolamento
- [ ] Testar criação de dados
- [ ] Testar com múltiplos tenants

---

**🎉 Após completar todos os passos, cada empresa terá seus dados completamente isolados e seguros!**
