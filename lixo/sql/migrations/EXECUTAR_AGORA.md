# 🚨 CORREÇÃO DE EMERGÊNCIA - EXECUTE AGORA!

## ⚠️ PROBLEMA CRÍTICO

Usuários novos estão vendo e modificando dados de outros clientes!
- ✗ Cliente A deleta produto → afeta estoque do Cliente B
- ✗ Sem isolamento de dados entre tenants
- ✗ RISCO DE PERDA DE DADOS

---

## ✅ SOLUÇÃO (2 minutos)

### 🔴 PASSO 1: Execute o Script de Emergência

1. **Abra**: https://supabase.com/dashboard/project/cxusoclwtixtjwghjlcj/sql/new

2. **Cole TODO** o conteúdo de: `EMERGENCIA_corrigir_isolamento.sql`

3. **Execute** (Ctrl+Enter)

4. **Aguarde mensagens**:
   ```
   🔍 DIAGNÓSTICO:
   Total de tenants: X
   Produtos sem tenant_id: Y

   🗑️ Removendo políticas RLS antigas...
   📝 Atribuindo tenant_id aos dados órfãos...
   🔒 Criando políticas RLS restritivas...
   🔐 Forçando RLS para todos...
   ⚠️ Adicionando NOT NULL em tenant_id...
   🔄 Criando triggers...

   🎉 CORREÇÃO CONCLUÍDA!
   ```

### 🟢 PASSO 2: Verifique o Isolamento

1. **Cole** o conteúdo de: `TESTAR_isolamento.sql`

2. **Execute**

3. **Verifique** a saída:
   ```
   ✅ ISOLAMENTO CONFIGURADO CORRETAMENTE!
   Tabelas com RLS ativo: 19 de 19
   Total de políticas RLS: 76+
   Registros órfãos: 0
   ```

### 🧪 PASSO 3: Teste Manual

1. **Login com Tenant A** → Criar um produto "Teste A"
2. **Login com Tenant B** → Produto "Teste A" **NÃO deve aparecer**
3. **Tentar deletar produto do Tenant A** → **Deve falhar**

---

## 🔒 O Que o Script Faz

### 1. Remove Políticas Antigas
Remove todas as políticas RLS existentes que podem estar incorretas

### 2. Atribui tenant_id a TODOS os Dados
Garante que NENHUM dado fique sem tenant_id

### 3. Cria Políticas RESTRITIVAS
```sql
SELECT → Só vê dados do próprio tenant
INSERT → Só pode inserir no próprio tenant
UPDATE → Só pode atualizar dados do próprio tenant
DELETE → Só pode deletar dados do próprio tenant
```

### 4. Força RLS para TODOS
Mesmo usuários "owner" são afetados pelo RLS (segurança máxima)

### 5. Adiciona NOT NULL
Previne novos dados sem tenant_id

### 6. Cria Triggers
Auto-preenche tenant_id em novos registros

---

## ✅ Resultado Esperado

| Antes | Depois |
|-------|--------|
| ✗ Tenant A vê dados do B | ✓ Cada tenant vê apenas seus dados |
| ✗ Deletar afeta todos | ✓ DELETE só afeta próprio tenant |
| ✗ Sem isolamento | ✓ Isolamento total |
| ✗ Dados compartilhados | ✓ Dados separados por tenant |

---

## 🆘 Se Algo Der Errado

### Erro: "no tenant found"
**Solução**: Crie pelo menos 1 tenant:
```sql
INSERT INTO public.tenants (name, slug, email)
VALUES ('Empresa Teste', 'empresa-teste', 'teste@empresa.com');
```

### Erro: "permission denied"
**Solução**: Execute como usuário `postgres` no Supabase Dashboard

### Erro persiste
**Solução**: Entre em contato imediatamente

---

## ⏱️ Tempo de Execução

- **Script de emergência**: 30-60 segundos
- **Script de teste**: 5 segundos
- **Teste manual**: 2 minutos

**Total**: ~3 minutos

---

## 📋 Checklist

- [ ] Script `EMERGENCIA_corrigir_isolamento.sql` executado
- [ ] Mensagem "🎉 CORREÇÃO CONCLUÍDA!" apareceu
- [ ] Script `TESTAR_isolamento.sql` executado
- [ ] Resultado: "✅ ISOLAMENTO CONFIGURADO CORRETAMENTE!"
- [ ] Teste manual realizado
- [ ] Tenant A não vê dados do Tenant B
- [ ] Delete só afeta próprio tenant

---

## 🔴 EXECUTE IMEDIATAMENTE!

**Severidade**: 🔴 CRÍTICA
**Impacto**: Todos os clientes afetados
**Risco**: Perda/corrupção de dados
**Tempo para resolver**: 3 minutos

---

**Arquivos**:
- 🚨 `EMERGENCIA_corrigir_isolamento.sql` - Execute PRIMEIRO
- 🧪 `TESTAR_isolamento.sql` - Execute SEGUNDO
- 📖 `EXECUTAR_AGORA.md` - Este guia
