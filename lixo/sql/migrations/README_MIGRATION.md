# Migração: Correção de Isolamento de Dados por Tenant

## Problema Identificado

O sistema estava compartilhando dados entre todos os clientes (tenants). Quando um novo cliente se cadastrava, ele tinha acesso aos dados de outros clientes, incluindo:

- Categorias de produtos
- Produtos
- Itens de menu
- Funcionários
- Dados financeiros
- Relatórios
- E outras informações sensíveis

## Causa Raiz

As tabelas operacionais não possuíam a coluna `tenant_id` e nem políticas RLS (Row Level Security) configuradas, resultando em:

1. Ausência de isolamento de dados
2. Falta de controle de acesso baseado em tenant
3. Vulnerabilidade de segurança crítica

## Solução Implementada

### 1. Adição de `tenant_id` em 19 tabelas críticas

- `categorias`
- `produtos`
- `menu_items`
- `menu_item_ingredientes`
- `planejamento_semanal`
- `menu_diario`
- `movements`
- `employees`
- `daily_payments`
- `employee_attendance`
- `employee_bank_accounts`
- `employee_performance_metrics`
- `salary_configs`
- `payment_audit_log`
- `financial_data`
- `daily_financial_summary`
- `reports`
- `app_settings`
- `suppliers`

### 2. Políticas RLS (Row Level Security)

Para cada tabela, foram criadas 4 políticas:

- **SELECT**: Usuário só vê dados do seu tenant
- **INSERT**: Usuário só pode inserir dados no seu tenant
- **UPDATE**: Usuário só pode atualizar dados do seu tenant
- **DELETE**: Usuário só pode deletar dados do seu tenant

### 3. Triggers e Funções Auxiliares

- Função `get_user_tenant_id()`: Retorna o tenant_id do usuário autenticado
- Função `user_belongs_to_tenant()`: Valida se usuário pertence a um tenant
- Função `auto_set_tenant_id()`: Auto-preenche tenant_id em novos registros
- Triggers em todas as tabelas para auto-preenchimento

### 4. Índices de Performance

Criados índices em todas as colunas `tenant_id` para otimizar as consultas com RLS

## Como Executar a Migração

### Pré-requisitos

1. Backup completo do banco de dados
2. Supabase CLI instalado e configurado
3. Acesso ao projeto no Supabase
4. Pelo menos 1 tenant cadastrado no sistema

### Passo 1: Verificar Estado Atual

```bash
# Conectar ao banco de dados
supabase db remote start

# Verificar quantos tenants existem
psql -h <seu-host> -U postgres -d postgres -c "SELECT id, name, email, created_at FROM public.tenants ORDER BY created_at;"

# Verificar se há dados sem tenant_id (antes da migração)
psql -h <seu-host> -U postgres -d postgres -c "SELECT COUNT(*) FROM public.produtos;"
psql -h <seu-host> -U postgres -d postgres -c "SELECT COUNT(*) FROM public.employees;"
psql -h <seu-host> -U postgres -d postgres -c "SELECT COUNT(*) FROM public.categorias;"
```

### Passo 2: Executar Script de Migração Principal

```bash
# Aplicar as mudanças de esquema e políticas RLS
supabase db remote start
psql -h <seu-host> -U postgres -d postgres -f src/sql/migrations/fix_tenant_isolation.sql
```

Ou via Supabase Dashboard:

1. Acesse: Dashboard > SQL Editor
2. Cole o conteúdo de `fix_tenant_isolation.sql`
3. Execute o script

### Passo 3: Executar Script de Correção de Dados

```bash
# Atribuir tenant_id aos dados existentes
psql -h <seu-host> -U postgres -d postgres -f src/sql/migrations/fix_existing_data.sql
```

Ou via Supabase Dashboard:

1. Acesse: Dashboard > SQL Editor
2. Cole o conteúdo de `fix_existing_data.sql`
3. Execute o script
4. **IMPORTANTE**: Leia atentamente os logs de saída para verificar se todos os dados foram migrados

### Passo 4: Verificar Resultados

O script `fix_existing_data.sql` irá imprimir logs detalhados:

```
[CATEGORIAS] 10 registros atualizados com tenant_id: abc123...
[PRODUTOS] 5 registros atualizados via created_by
[PRODUTOS] 3 registros órfãos atualizados com tenant_id: abc123...
[EMPLOYEES] 8 registros atualizados com tenant_id: abc123...
...
```

Verificação final:

```sql
-- Verificar se ainda há registros sem tenant_id
SELECT COUNT(*) FROM public.produtos WHERE tenant_id IS NULL;
SELECT COUNT(*) FROM public.employees WHERE tenant_id IS NULL;
SELECT COUNT(*) FROM public.categorias WHERE tenant_id IS NULL;
-- Repita para todas as tabelas
```

### Passo 5: Ativar Constraints NOT NULL

Se a verificação do Passo 4 mostrar que **todos** os registros possuem `tenant_id`, edite o arquivo `fix_tenant_isolation.sql`:

1. Vá até a **PARTE 3**
2. Descomente todas as linhas `ALTER TABLE ... ALTER COLUMN tenant_id SET NOT NULL;`
3. Execute novamente apenas essa parte:

```sql
ALTER TABLE public.categorias ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.produtos ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.menu_items ALTER COLUMN tenant_id SET NOT NULL;
-- etc...
```

### Passo 6: Testes

Execute testes completos:

1. **Teste de Isolamento**:
   - Login com usuário do Tenant A
   - Verificar que só vê dados do Tenant A
   - Login com usuário do Tenant B
   - Verificar que só vê dados do Tenant B

2. **Teste de Inserção**:
   - Criar novo produto como Tenant A
   - Verificar que produto tem tenant_id correto
   - Verificar que Tenant B não vê esse produto

3. **Teste de Atualização**:
   - Tentar atualizar dado de outro tenant
   - Deve falhar com erro de RLS

4. **Teste de Deleção**:
   - Tentar deletar dado de outro tenant
   - Deve falhar com erro de RLS

## Estratégia de Migração de Dados

O script `fix_existing_data.sql` usa a seguinte estratégia:

1. **Se há apenas 1 tenant**: Todos os dados são atribuídos a ele
2. **Se há múltiplos tenants**:
   - Tenta identificar o tenant correto via relações existentes (`created_by`, `employee_id`, etc)
   - Se não for possível identificar, atribui ao tenant **mais antigo** (primeiro criado)

## Tabelas que Herdam tenant_id

Algumas tabelas herdam `tenant_id` de suas tabelas pai:

- `menu_item_ingredientes` herda de `menu_items`
- `menu_diario` herda de `planejamento_semanal`
- `daily_payments` herda de `employees`
- `employee_attendance` herda de `employees`
- `employee_bank_accounts` herda de `employees`
- `employee_performance_metrics` herda de `employees`
- `payment_audit_log` herda de `employees`
- `daily_financial_summary` tenta herdar de `financial_data`

## Rollback (Em caso de problemas)

Se algo der errado, você pode fazer rollback:

```bash
# Restaurar backup
pg_restore -h <seu-host> -U postgres -d postgres backup.dump

# Ou remover manualmente as mudanças
DROP POLICY IF EXISTS categorias_tenant_isolation_select ON public.categorias;
-- Repita para todas as políticas...

ALTER TABLE public.categorias DROP COLUMN IF EXISTS tenant_id;
-- Repita para todas as tabelas...
```

## Monitoramento Pós-Migração

Após a migração, monitore:

1. **Logs de erro**: Procure por erros de RLS
2. **Performance**: As consultas podem ficar um pouco mais lentas devido ao RLS
3. **Comportamento**: Usuários não devem ver dados de outros tenants

## Arquivos da Migração

- `fix_tenant_isolation.sql`: Script principal (adiciona colunas, índices, RLS, triggers)
- `fix_existing_data.sql`: Script de correção de dados existentes
- `README_MIGRATION.md`: Este documento

## Suporte

Se encontrar problemas durante a migração:

1. **Não execute o Passo 5** até resolver
2. Verifique os logs do `fix_existing_data.sql`
3. Execute queries manuais para investigar dados órfãos
4. Entre em contato com o time de desenvolvimento

## Checklist de Execução

- [ ] Backup completo do banco de dados realizado
- [ ] Pelo menos 1 tenant existe no sistema
- [ ] Script `fix_tenant_isolation.sql` executado com sucesso
- [ ] Script `fix_existing_data.sql` executado com sucesso
- [ ] Logs verificados - nenhum registro órfão
- [ ] Constraints NOT NULL adicionadas
- [ ] Testes de isolamento realizados
- [ ] Testes de CRUD realizados
- [ ] Usuários testaram e confirmaram isolamento
- [ ] Monitoramento configurado

---

**Data da Migração**: 2025-11-26
**Versão**: 1.0.0
**Status**: Pronto para produção
