# 🔄 Setup Rápido - Sincronização Financial ↔️ Employees

## ⚡ Problema que Resolve

Agora quando você adiciona dados em `/financial`, **automaticamente** os pagamentos aparecem em `/employees`!

## 🚀 Como Ativar (3 minutos)

### 1️⃣ Execute o SQL Principal (se ainda não fez)

**Via Supabase:**
1. Acesse https://supabase.com/dashboard
2. Vá em **SQL Editor** → **New Query**
3. Copie todo o conteúdo de: `src/sql/colaboradores.sql`
4. **RUN**

### 2️⃣ Ative a Sincronização

**Via Supabase:**
1. **SQL Editor** → **New Query**
2. Copie todo o conteúdo de: `src/sql/sync_financial_employees.sql`
3. **RUN**

### 3️⃣ Teste!

1. Vá em `/financial`
2. Adicione um registro (ex: Data: hoje, Receita: R$ 1.000)
3. Vá em `/employees` → Tab "Pagamentos"
4. 🎉 **Pagamentos criados automaticamente!**

## ✨ O que Acontece Automaticamente

```
VOCÊ FAZ:
/financial → Adiciona R$ 1.000 de receita

SISTEMA FAZ:
/employees → Calcula e cria:
  ✅ Garçons: 10% dividido entre eles
  ✅ Cozinheiros: R$ 150 fixo cada
  ✅ Balconistas: 5% ou mínimo R$ 80
  ✅ Status: Pendente (pronto para marcar como pago)
```

## 🐛 Se Não Funcionar

### Checklist Rápido:

```sql
-- 1. Tem funcionários ativos?
SELECT name, position, status FROM employees WHERE status = 'ativo';

-- 2. Configurações existem?
SELECT * FROM salary_configs;

-- 3. Triggers ativos?
SELECT trigger_name FROM information_schema.triggers
WHERE trigger_name LIKE '%sync%';
```

Se algum falhar, re-execute os passos 1 e 2.

## 📖 Documentação Completa

- **Setup Detalhado:** `SINCRONIZACAO_ROTAS.md`
- **Funcionalidades:** `doc/EMPLOYEE_MANAGEMENT_README.md`
- **SQL Completo:** `src/sql/colaboradores.sql`

## ✅ Pronto!

Agora é só usar! Adicione dados em `/financial` e veja a mágica! ✨
