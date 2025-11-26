# 🔒 Instruções para Corrigir Isolamento Multi-Tenant

## Problema Identificado

Quando um cliente cria uma nova conta, ele consegue ver os dados de outros clientes. Isso ocorre porque:
1. As colunas `tenant_id` podem não existir em algumas tabelas
2. As políticas RLS (Row Level Security) não estão ativas ou configuradas corretamente
3. O isolamento de dados entre tenants não está funcionando

## ✅ Solução Implementada

Criamos um script SQL completo que:
- ✅ Adiciona `tenant_id` em todas as tabelas necessárias
- ✅ Habilita Row Level Security (RLS) em todas as tabelas
- ✅ Cria políticas RLS para isolar dados por tenant
- ✅ Cria triggers automáticos para preencher `tenant_id`
- ✅ Cria índices para performance
- ✅ Cria funções auxiliares para gerenciar o tenant

---

## 📋 Passo 1: Acessar o Supabase Dashboard

1. Acesse: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto: **estevamsouzalaureth@hotmail.com's Project**
4. Na organização: **GestaoZe**

---

## 📋 Passo 2: Executar o Script SQL

### Opção A: Via SQL Editor (Recomendado)

1. No menu lateral, clique em **SQL Editor**
2. Clique em **+ New query**
3. Copie **TODO** o conteúdo do arquivo:
   ```
   src/sql/fix_multi_tenancy.sql
   ```
4. Cole no editor SQL
5. Clique em **Run** (ou pressione `Ctrl+Enter`)
6. Aguarde a execução completa (pode levar alguns segundos)
7. Verifique se não há erros na saída

### Opção B: Via CLI do Supabase (Avançado)

```bash
# Se você tiver o Supabase CLI instalado e conectado:
supabase db push --file src/sql/fix_multi_tenancy.sql
```

---

## 📋 Passo 3: Verificar a Execução

### 3.1 Verificar Funções Criadas

Execute no SQL Editor:

```sql
-- Verificar se as funções foram criadas
SELECT proname, prosrc
FROM pg_proc
WHERE proname IN ('get_current_tenant_id', 'set_current_tenant', 'auto_set_tenant_id');
```

**Resultado esperado:** Deve retornar 3 linhas com as funções.

### 3.2 Verificar Colunas tenant_id

Execute no SQL Editor:

```sql
-- Verificar se tenant_id existe nas principais tabelas
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE column_name = 'tenant_id'
  AND table_schema = 'public'
ORDER BY table_name;
```

**Resultado esperado:** Deve retornar muitas linhas, uma para cada tabela com tenant_id.

### 3.3 Verificar RLS Habilitado

Execute no SQL Editor:

```sql
-- Verificar se RLS está habilitado
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'categorias', 'employees', 'financial_data')
ORDER BY tablename;
```

**Resultado esperado:** Todas as tabelas devem ter `rls_enabled = true`.

### 3.4 Verificar Políticas RLS

Execute no SQL Editor:

```sql
-- Verificar políticas RLS criadas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND policyname = 'tenant_isolation_policy'
ORDER BY tablename;
```

**Resultado esperado:** Deve retornar muitas linhas, uma para cada tabela com política RLS.

---

## 📋 Passo 4: Testar o Isolamento

### Teste 1: Criar Dois Tenants de Teste

Execute no SQL Editor:

```sql
-- Criar tenant de teste 1
INSERT INTO tenants (name, slug, email, status)
VALUES ('Empresa Teste 1', 'empresa-teste-1', 'teste1@example.com', 'active')
RETURNING id;

-- Anotar o ID retornado (exemplo: 'abc-123-def')

-- Criar tenant de teste 2
INSERT INTO tenants (name, slug, email, status)
VALUES ('Empresa Teste 2', 'empresa-teste-2', 'teste2@example.com', 'active')
RETURNING id;

-- Anotar o ID retornado (exemplo: 'xyz-789-ghi')
```

### Teste 2: Criar Produtos para Cada Tenant

```sql
-- Definir tenant 1 como atual
SELECT set_current_tenant('<ID_DO_TENANT_1>');

-- Criar produto para tenant 1
INSERT INTO produtos (nome, preco, current_stock, min_stock)
VALUES ('Produto Tenant 1', 10.00, 100, 10);

-- Definir tenant 2 como atual
SELECT set_current_tenant('<ID_DO_TENANT_2>');

-- Criar produto para tenant 2
INSERT INTO produtos (nome, preco, current_stock, min_stock)
VALUES ('Produto Tenant 2', 20.00, 200, 20);
```

### Teste 3: Verificar Isolamento

```sql
-- Definir tenant 1 como atual
SELECT set_current_tenant('<ID_DO_TENANT_1>');

-- Buscar produtos (deve retornar APENAS o produto do tenant 1)
SELECT * FROM produtos;

-- Definir tenant 2 como atual
SELECT set_current_tenant('<ID_DO_TENANT_2>');

-- Buscar produtos (deve retornar APENAS o produto do tenant 2)
SELECT * FROM produtos;
```

**Resultado esperado:**
- Quando o tenant 1 está ativo, só deve aparecer "Produto Tenant 1"
- Quando o tenant 2 está ativo, só deve aparecer "Produto Tenant 2"

### Teste 4: Limpar Dados de Teste

```sql
-- Limpar tenants de teste
DELETE FROM tenants WHERE slug IN ('empresa-teste-1', 'empresa-teste-2');
-- Isso deve deletar em cascata os produtos devido ao ON DELETE CASCADE
```

---

## 📋 Passo 5: Testar no Frontend

### Teste de Registro

1. Acesse: `http://localhost:5173/register`
2. Crie uma nova conta de teste:
   - Nome da empresa: "Empresa Teste Frontend 1"
   - Email: `teste-frontend-1@example.com`
   - Senha: `teste123456`
3. Faça login com as credenciais criadas
4. Crie alguns produtos, categorias, funcionários, etc.

### Teste de Isolamento

1. Em uma janela anônima/privada, acesse: `http://localhost:5173/register`
2. Crie outra conta de teste:
   - Nome da empresa: "Empresa Teste Frontend 2"
   - Email: `teste-frontend-2@example.com`
   - Senha: `teste123456`
3. Faça login com as credenciais da segunda conta
4. Crie alguns produtos, categorias, funcionários, etc.

### Verificar Isolamento

1. **Na primeira janela** (Empresa 1):
   - Acesse o dashboard
   - Verifique produtos, funcionários, etc.
   - **NÃO DEVE APARECER** nada da Empresa 2

2. **Na segunda janela** (Empresa 2):
   - Acesse o dashboard
   - Verifique produtos, funcionários, etc.
   - **NÃO DEVE APARECER** nada da Empresa 1

---

## ⚠️ Problemas Comuns e Soluções

### Problema 1: Erro ao executar script SQL

**Erro:** `column "tenant_id" already exists`

**Solução:** Isso é normal! O script usa `ADD COLUMN IF NOT EXISTS`, então pode ignorar esse aviso.

---

### Problema 2: RLS não está funcionando

**Verificar:**

```sql
-- Verificar se a função está sendo chamada corretamente
SELECT get_current_tenant_id();
```

Se retornar `NULL`, significa que o tenant_id não foi definido na sessão.

**Solução:** O authService precisa chamar `set_current_tenant` após o login. Verifique se o código em `src/services/authService.ts` linha 70 está correto.

---

### Problema 3: Dados antigos ainda visíveis

**Causa:** Dados criados ANTES do script SQL podem não ter `tenant_id` definido.

**Solução:** Execute para cada tabela:

```sql
-- Exemplo para tabela produtos
-- CUIDADO: Isso remove TODOS os produtos sem tenant_id
DELETE FROM produtos WHERE tenant_id IS NULL;

-- OU atribua a um tenant específico:
UPDATE produtos
SET tenant_id = '<ID_DO_TENANT>'
WHERE tenant_id IS NULL;
```

---

### Problema 4: Erro "permission denied for function set_current_tenant"

**Causa:** A função foi criada com `SECURITY DEFINER`, mas pode haver problema de permissões.

**Solução:** Execute:

```sql
-- Garantir permissões corretas
GRANT EXECUTE ON FUNCTION set_current_tenant(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_tenant_id() TO authenticated;
```

---

## 📊 Monitoramento Contínuo

### Verificar Tabelas sem RLS

```sql
-- Listar tabelas sem RLS habilitado
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND rowsecurity = false
ORDER BY tablename;
```

### Verificar Dados sem tenant_id

```sql
-- Exemplo para produtos
SELECT COUNT(*) as produtos_sem_tenant
FROM produtos
WHERE tenant_id IS NULL;
```

---

## 🎯 Checklist Final

- [ ] Script SQL executado sem erros críticos
- [ ] Funções `get_current_tenant_id` e `set_current_tenant` criadas
- [ ] Coluna `tenant_id` existe nas tabelas principais
- [ ] RLS habilitado em todas as tabelas
- [ ] Políticas RLS criadas (`tenant_isolation_policy`)
- [ ] Triggers de auto-preenchimento criados
- [ ] Teste de isolamento no SQL Editor passou
- [ ] Teste de isolamento no frontend passou
- [ ] Dados antigos sem tenant_id foram tratados

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs do Supabase Dashboard (aba Logs)
2. Verifique o console do browser (F12) para erros JavaScript
3. Execute as queries de verificação acima
4. Verifique se o `authService.ts` está chamando `set_current_tenant`

---

## 🔐 Segurança

**IMPORTANTE:**
- Este script é IDEMPOTENTE (pode ser executado múltiplas vezes sem problemas)
- RLS está configurado para permitir acesso apenas ao tenant atual
- Dados sem `tenant_id` são considerados "públicos" pela política `OR tenant_id IS NULL`
- Para maior segurança, remova dados sem tenant_id após a migração

---

Última atualização: 2025-01-26
