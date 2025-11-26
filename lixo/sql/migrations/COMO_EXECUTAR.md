# 🚀 Como Executar a Migração

## ⚡ Execução Rápida (1 arquivo só)

### Via Supabase Dashboard (Recomendado)

1. **Acesse**: https://supabase.com/dashboard/project/cxusoclwtixtjwghjlcj/sql/new

2. **Cole o conteúdo** do arquivo `migration_completa.sql`

3. **Execute** (botão "Run" ou Ctrl+Enter)

4. **Aguarde** a mensagem: `✓ Migração concluída com sucesso!`

5. **Verifique** executando `verificar_depois.sql`

---

## 📋 O que o script faz

### 1️⃣ Corrige Signup (IMEDIATO)
- Remove políticas RLS que bloqueavam criação de contas
- Permite leitura pública de `tenants` (para verificar slug)
- Permite criação de `admin_users` e `tenant_users`

### 2️⃣ Adiciona Isolamento (ESTRUTURA)
- Adiciona coluna `tenant_id` em 19 tabelas
- Cria índices para performance

### 3️⃣ Migra Dados (CORREÇÃO)
- Atribui `tenant_id` aos dados existentes
- Usa relações para identificar tenant correto

### 4️⃣ Ativa Segurança (POLÍTICAS)
- Cria 76 políticas RLS (4 por tabela)
- Garante isolamento total entre tenants

### 5️⃣ Automatiza (TRIGGERS)
- Cria triggers para auto-preencher `tenant_id`
- Novos registros já terão tenant correto

---

## ✅ Teste Imediato Após Execução

### 1. Teste de Signup
```
1. Acesse seu sistema
2. Tente criar uma nova conta
3. Deve funcionar agora! ✓
```

### 2. Teste de Isolamento
```sql
-- Execute no Supabase SQL Editor
SELECT * FROM public.produtos;
-- Deve retornar apenas produtos do seu tenant
```

### 3. Verificação Técnica
```
Execute: verificar_depois.sql
Todas as contagens de "orfaos" devem ser 0
```

---

## ⚠️ Se der erro

### Erro: "relation already exists"
**Solução**: Ignore, significa que já foi criado antes

### Erro: "permission denied"
**Solução**: Execute como usuário `postgres` no Supabase Dashboard

### Erro: "no tenant found"
**Solução**: Crie pelo menos 1 tenant antes:
```sql
INSERT INTO public.tenants (name, slug, email)
VALUES ('Minha Empresa', 'minha-empresa', 'contato@empresa.com');
```

---

## 🔍 Verificação Pós-Migração

Execute no SQL Editor:

```sql
-- 1. Nenhum órfão
SELECT COUNT(*) FROM public.produtos WHERE tenant_id IS NULL;
-- Deve retornar: 0

-- 2. RLS ativo
SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public';
-- Deve retornar: 76+ políticas

-- 3. Signup funciona
-- Tente criar uma conta no frontend
-- Deve funcionar ✓
```

---

## 📊 Resumo

| Item | Antes | Depois |
|------|-------|--------|
| Signup | ❌ Bloqueado | ✅ Funcionando |
| Isolamento | ❌ Inexistente | ✅ Total |
| Políticas RLS | 0 | 76+ |
| Segurança | 🔴 Crítica | ✅ Segura |

---

## 🆘 Suporte

Se algo não funcionar:

1. Execute `verificar_depois.sql`
2. Copie a saída e revise
3. Verifique se há registros órfãos
4. Teste signup novamente

---

**Tempo estimado**: 1-2 minutos
**Rollback**: Não necessário (script é seguro)
**Downtime**: Zero (sistema continua funcionando)

---

✅ **Pronto para executar!**
