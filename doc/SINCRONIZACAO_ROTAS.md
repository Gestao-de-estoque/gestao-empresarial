# 🔄 Sincronização Automática entre Financial e Employees

## 📋 Problema Resolvido

Agora quando você adiciona dados financeiros em `/financial`, **automaticamente** os pagamentos são calculados e aparecem em `/employees`!

## 🚀 Como Ativar

### Opção 1: Via Supabase SQL Editor (Recomendado)

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **SQL Editor**
4. Copie e cole o conteúdo do arquivo: `src/sql/sync_financial_employees.sql`
5. Clique em **RUN**

### Opção 2: Via psql

```bash
psql -U seu_usuario -d seu_banco -f src/sql/sync_financial_employees.sql
```

## ✨ Como Funciona

### 🔵 Fluxo: Financial → Employees

Quando você adiciona um registro em `/financial`:

```
1. Você adiciona: Data: 01/01/2025, Receita: R$ 1.000,00
2. Sistema calcula automaticamente para cada funcionário ativo:
   - Garçons: 10% ÷ número de garçons
   - Cozinheiros: R$ 150,00 fixo
   - Balconistas: 5% ou mínimo R$ 80,00
3. Cria pagamentos em `daily_payments`
4. Atualiza `daily_financial_summary`
```

### 🟢 Fluxo: Employees → Financial

Quando você processa pagamentos em `/employees`:

```
1. Sistema calcula pagamentos de todos funcionários
2. Soma o total de salários de garçons (10%)
3. Atualiza ou cria registro em `financial_data`
4. Mantém sincronização bidirecional
```

## 📊 Exemplo Prático

### Cenário 1: Adicionando em Financial

**Você faz:**
```
Rota: /financial
Ação: Adicionar Registro
Data: 15/01/2025
Receita Total: R$ 2.000,00
Salário Garçom: R$ 200,00 (10%)
```

**Sistema faz automaticamente:**
```
Rota: /employees → Tab Pagamentos

✅ João (Garçom) - R$ 100,00 (200 ÷ 2 garçons)
✅ Maria (Garçom) - R$ 100,00 (200 ÷ 2 garçons)
✅ Carlos (Cozinheiro) - R$ 150,00 (fixo)
✅ Ana (Balconista) - R$ 100,00 (5% = 100 > 80 mínimo)

Status: Pendente
```

### Cenário 2: Adicionando em Employees

**Você faz:**
```
Rota: /employees
Ação: Processar Pagamentos
Data: 16/01/2025
Receita do Dia: R$ 1.500,00
```

**Sistema faz automaticamente:**
```
Rota: /financial

✅ Novo registro criado:
   Data: 16/01/2025
   Receita Total: R$ 1.500,00
   Salário Garçom: R$ 150,00 (10%)
```

## 🔧 Detalhes Técnicos

### Triggers Criados

1. **`trigger_sync_summary_to_financial`**
   - Tabela: `daily_financial_summary`
   - Ação: Sincroniza para `financial_data`

2. **`trigger_sync_financial_to_payments`**
   - Tabela: `financial_data`
   - Ação: Calcula e cria pagamentos automaticamente

### Tabelas Envolvidas

```
financial_data (Rota /financial)
    ↓ ↑
daily_financial_summary (Resumo)
    ↓ ↑
daily_payments (Rota /employees)
    ↓
employees (Funcionários ativos)
    ↓
salary_configs (Regras de cálculo)
```

## 🧪 Testando a Sincronização

### Teste 1: Financial → Employees

```sql
-- 1. Adicione um registro financeiro
INSERT INTO financial_data (full_day, amount, total)
VALUES ('20/01/2025', 150.00, 1500.00);

-- 2. Verifique os pagamentos criados
SELECT e.name, e.position, dp.base_salary, dp.final_amount, dp.payment_status
FROM daily_payments dp
JOIN employees e ON dp.employee_id = e.id
WHERE dp.payment_date = '2025-01-20';

-- 3. Verifique o resumo
SELECT * FROM daily_financial_summary WHERE summary_date = '2025-01-20';
```

### Teste 2: Employees → Financial

```sql
-- 1. Processe pagamentos (via interface /employees)
-- Ou manualmente:
-- (Sistema calcula automaticamente via trigger)

-- 2. Verifique a sincronização
SELECT full_day, amount, total
FROM financial_data
WHERE full_day = '20/01/2025';
```

## 📈 Regras de Cálculo

### Garçom (Percentual Dividido)
```
Total: R$ 1.000,00
Garçons Ativos: 2
Cálculo: (1000 × 10%) ÷ 2 = R$ 50,00 cada
```

### Cozinheiro (Fixo)
```
Total: Qualquer valor
Salário: R$ 150,00 (sempre)
```

### Balconista (Misto com Mínimo)
```
Total: R$ 1.000,00
Cálculo: MAX(1000 × 5%, R$ 80,00)
Resultado: MAX(R$ 50,00, R$ 80,00) = R$ 80,00
```

### Cozinheiro Chef (Fixo Premium)
```
Total: Qualquer valor
Salário: R$ 250,00 (sempre)
```

## 🐛 Troubleshooting

### Os pagamentos não aparecem?

**Verifique:**
1. ✅ Existem funcionários ativos?
   ```sql
   SELECT * FROM employees WHERE status = 'ativo';
   ```

2. ✅ As configurações de salário existem?
   ```sql
   SELECT * FROM salary_configs;
   ```

3. ✅ Os triggers estão ativos?
   ```sql
   SELECT trigger_name, event_object_table, action_statement
   FROM information_schema.triggers
   WHERE trigger_name LIKE '%sync%';
   ```

### Dados não sincronizam?

**Solução:**
```sql
-- Re-execute o script de sincronização
\i src/sql/sync_financial_employees.sql

-- Ou copie e cole no Supabase SQL Editor
```

### Valores incorretos?

**Verifique as configurações:**
```sql
SELECT position, calculation_type, fixed_daily_amount,
       percentage_rate, min_daily_guarantee
FROM salary_configs;
```

## 🔄 Sincronização Retroativa

Se você já tem dados antigos em `financial_data` e quer sincronizar:

```sql
-- Descomente o bloco no final do arquivo sync_financial_employees.sql
-- Ou execute manualmente:

DO $$
DECLARE
    financial_record RECORD;
BEGIN
    FOR financial_record IN
        SELECT * FROM financial_data ORDER BY created_at
    LOOP
        -- Força o trigger
        UPDATE financial_data
        SET updated_at = CURRENT_TIMESTAMP
        WHERE id = financial_record.id;
    END LOOP;
END $$;
```

## 📝 Logs e Auditoria

Todos os pagamentos criados automaticamente têm em `calculation_details`:

```json
{
  "employee_name": "João Silva",
  "position": "garcom",
  "calculation_type": "percentage",
  "daily_revenue": 1000.00,
  "garcom_count": 2,
  "auto_calculated": true,
  "source": "financial_data",
  "synced_at": "2025-01-15T10:30:00Z"
}
```

Isso ajuda a identificar pagamentos automáticos vs manuais.

## ✅ Checklist de Implementação

- [ ] Executar `src/sql/colaboradores.sql` (tabelas)
- [ ] Executar `src/sql/sync_financial_employees.sql` (triggers)
- [ ] Cadastrar ao menos 1 funcionário ativo
- [ ] Verificar `salary_configs` tem dados
- [ ] Testar adicionando em `/financial`
- [ ] Verificar pagamentos em `/employees`
- [ ] Testar processamento em `/employees`
- [ ] Verificar sincronização em `/financial`

## 🎉 Pronto!

Agora seu sistema está 100% sincronizado!

Adicione dados em qualquer rota e veja a mágica acontecer! ✨

---

**Dúvidas?** Verifique os logs no console ou consulte a tabela `payment_audit_log` para auditoria completa.
