# Guia Completo: Correção de Isolamento de Dados

## Problema Identificado

Atualmente, quando múltiplos usuários são registrados no sistema, todos conseguem ver os dados uns dos outros. Este é um **problema crítico de segurança** que viola o princípio de isolamento de dados.

### Causas Raiz

1. **Políticas RLS filtram apenas por `tenant_id`**: Permite que todos os usuários do mesmo tenant vejam dados uns dos outros
2. **Campos `created_by` ausentes**: Algumas tabelas não identificam quem criou os registros
3. **Services não incluem `tenant_id`**: Causando erro "Usuário não está associado a nenhum tenant"
4. **UUIDs vazios**: Campos UUID sendo enviados como string vazia ("") em vez de `null`

---

## Solução Implementada

### 1. Script SQL de Correção (`src/sql/FIX_USER_ISOLATION.sql`)

Este script faz o seguinte:

✅ Cria função `current_user_id()` para obter o usuário logado
✅ Adiciona campos `created_by` nas tabelas que não têm
✅ Cria triggers para preencher `created_by` automaticamente
✅ Recria políticas RLS para filtrar por `created_by` (usuário criador)
✅ Habilita RLS em todas as tabelas

**Como executar:**

```bash
# Opção 1: Via Supabase SQL Editor
# 1. Acesse o Supabase Dashboard
# 2. Vá em "SQL Editor"
# 3. Cole o conteúdo do arquivo src/sql/FIX_USER_ISOLATION.sql
# 4. Clique em "Run"

# Opção 2: Via psql
psql "postgresql://usuario:senha@host:porta/database" < src/sql/FIX_USER_ISOLATION.sql
```

---

### 2. Helper de Validação (`src/utils/validation.ts`)

Criamos utilitários para:

- ✅ Validar UUIDs
- ✅ Normalizar UUIDs (converte strings vazias para `null`)
- ✅ Formatar erros do Supabase para mensagens amigáveis

**Exemplo de uso:**

```typescript
import { normalizeUUID, formatSupabaseError, requireValidUUID } from '@/utils/validation'

// Validar UUID obrigatório
requireValidUUID(productId, 'ID do produto') // Lança erro se inválido

// Normalizar UUID opcional
const categoryId = normalizeUUID(data.category_id) // Retorna null se vazio

// Formatar erro do Supabase
catch (error) {
  throw new Error(formatSupabaseError(error))
}
```

---

### 3. Atualização dos Services

#### Exemplo: productService.ts (JÁ ATUALIZADO)

```typescript
import { normalizeUUID, formatSupabaseError, requireValidUUID, validateAndNormalizeUUIDs } from '@/utils/validation'

async createProduct(productData: Partial<Product>): Promise<Product> {
  try {
    // Normaliza UUIDs antes de enviar (converte "" para null)
    const normalized = validateAndNormalizeUUIDs(productData, ['categoria_id'])

    const { data, error } = await supabase
      .from(DB_TABLES.PRODUCTS)
      .insert([{
        ...normalized,
        ativo: true
      }])
      .select()
      .single()

    if (error) {
      console.error('Erro ao criar produto:', error)
      throw new Error(formatSupabaseError(error))
    }
    return data
  } catch (error) {
    console.error('Erro ao criar produto:', error)
    throw error
  }
}
```

#### Services que PRECISAM ser atualizados:

**CRÍTICO - Atualizar IMEDIATAMENTE:**
- ✅ `productService.ts` - **JÁ CORRIGIDO**
- ⚠️ `menuService.ts` - Normalizar `categoria_id`, `planejamento_semanal_id`, `menu_item_id`
- ⚠️ `suppliersService.ts` - Adicionar formatação de erros
- ⚠️ `employeeService.ts` - Adicionar formatação de erros
- ⚠️ `financialService.ts` - Adicionar formatação de erros

**Padrão de atualização para TODOS os services:**

```typescript
// 1. Importar helpers
import { formatSupabaseError, validateAndNormalizeUUIDs, requireValidUUID } from '@/utils/validation'

// 2. No CREATE - normalizar UUIDs
async create(data: any) {
  const normalized = validateAndNormalizeUUIDs(data, ['campo_uuid_1', 'campo_uuid_2'])
  // ... resto do código
  if (error) throw new Error(formatSupabaseError(error))
}

// 3. No UPDATE - validar ID e normalizar UUIDs
async update(id: string, data: any) {
  requireValidUUID(id, 'ID do registro')
  const normalized = validateAndNormalizeUUIDs(data, ['campo_uuid_1', 'campo_uuid_2'])
  // ... resto do código
  if (error) throw new Error(formatSupabaseError(error))
}

// 4. No GET/DELETE - validar ID
async get(id: string) {
  requireValidUUID(id, 'ID do registro')
  // ... resto do código
  if (error) throw new Error(formatSupabaseError(error))
}
```

---

## Passo a Passo de Implementação

### Fase 1: Correção do Banco de Dados (URGENTE)

1. **Execute o script SQL:**
   ```bash
   # Via Supabase SQL Editor
   # Cole o conteúdo de: src/sql/FIX_USER_ISOLATION.sql
   ```

2. **Verifique se foi aplicado com sucesso:**
   ```sql
   -- Verifica se as funções foram criadas
   SELECT proname FROM pg_proc WHERE proname IN ('current_user_id', 'set_created_by');

   -- Verifica se as colunas foram adicionadas
   SELECT table_name, column_name
   FROM information_schema.columns
   WHERE table_schema = 'public'
   AND column_name = 'created_by'
   ORDER BY table_name;

   -- Verifica se os triggers foram criados
   SELECT tgname FROM pg_trigger WHERE tgname LIKE 'set_created_by%';
   ```

### Fase 2: Atualização dos Services (CRÍTICO)

#### menuService.ts

```typescript
// Adicionar no topo
import { formatSupabaseError, validateAndNormalizeUUIDs, requireValidUUID } from '@/utils/validation'

// Atualizar createMenuItem
async createMenuItem(itemData: CreateMenuItemData): Promise<MenuItem | null> {
  try {
    // Normalizar UUIDs
    const normalized = validateAndNormalizeUUIDs(itemData, ['categoria_id'])

    const { data, error } = await supabase
      .from('menu_items')
      .insert([{
        ...normalized,
        // ... resto dos campos
      }])
      .select()
      .single()

    if (error) {
      console.error('Erro ao criar item do menu:', error)
      throw new Error(formatSupabaseError(error))
    }

    return data
  } catch (error) {
    console.error('Erro ao criar item do menu:', error)
    throw error
  }
}

// Repetir para updateMenuItem, deleteMenuItem, etc.
```

#### suppliersService.ts

```typescript
// Adicionar no topo
import { formatSupabaseError, validateAndNormalizeUUIDs, requireValidUUID } from '@/utils/validation'

// Atualizar createSupplier
async createSupplier(supplierData: CreateSupplierData): Promise<Supplier | null> {
  try {
    const { data, error } = await supabase
      .from('suppliers')
      .insert([{
        ...supplierData,
        status: supplierData.status || 'active',
        products_count: 0
      }])
      .select()
      .single()

    if (error) {
      console.error('Erro ao criar fornecedor:', error)
      throw new Error(formatSupabaseError(error))
    }

    return data
  } catch (error) {
    console.error('Erro ao criar fornecedor:', error)
    throw error
  }
}

// Repetir para update, delete, etc.
```

#### employeeService.ts

```typescript
// Adicionar formatSupabaseError em todos os catches
if (error) {
  console.error('Erro:', error)
  throw new Error(formatSupabaseError(error))
}
```

#### financialService.ts

```typescript
// Adicionar formatSupabaseError em todos os catches
if (error) {
  console.error('Erro:', error)
  throw new Error(formatSupabaseError(error))
}
```

### Fase 3: Testes

1. **Teste de Isolamento:**
   ```sql
   -- Logue com Usuário 1
   -- Crie alguns registros (produtos, funcionários, etc)

   -- Logue com Usuário 2
   -- Tente visualizar os dados
   -- DEVE retornar vazio

   -- Crie novos registros com Usuário 2
   -- DEVE ver apenas seus próprios dados
   ```

2. **Teste de UUIDs:**
   ```typescript
   // Tente criar produto sem categoria
   await productService.createProduct({
     nome: 'Teste',
     categoria_id: '' // Deve ser convertido para null
   })
   // DEVE funcionar sem erro
   ```

3. **Teste de Erros:**
   ```typescript
   // Tente criar com UUID inválido
   await productService.getProductById('invalid-uuid')
   // DEVE retornar mensagem amigável
   ```

---

## Mensagens de Erro Corrigidas

### Antes:
```
❌ "invalid input syntax for type uuid: \"\""
❌ "Usuário não está associado a nenhum tenant"
❌ "new row violates row-level security policy"
```

### Depois:
```
✅ "Formato de identificador inválido. Verifique os dados e tente novamente."
✅ "Você não tem permissão para acessar este recurso."
✅ "Usuário não está associado a nenhuma empresa. Entre em contato com o suporte."
```

---

## Checklist de Implementação

### Banco de Dados
- [ ] Executar `src/sql/FIX_USER_ISOLATION.sql`
- [ ] Verificar que função `current_user_id()` foi criada
- [ ] Verificar que campos `created_by` foram adicionados
- [ ] Verificar que triggers foram criados
- [ ] Verificar que políticas RLS foram atualizadas

### Frontend
- [ ] Atualizar `menuService.ts` com validações
- [ ] Atualizar `suppliersService.ts` com tratamento de erros
- [ ] Atualizar `employeeService.ts` com tratamento de erros
- [ ] Atualizar `financialService.ts` com tratamento de erros

### Testes
- [ ] Testar isolamento: Usuário 1 não vê dados do Usuário 2
- [ ] Testar criação de registros sem erros
- [ ] Testar mensagens de erro amigáveis
- [ ] Testar UUIDs vazios são convertidos para null

---

## Perguntas Frequentes

**Q: Por que alguns registros antigos não aparecem mais?**
A: Registros criados antes da correção não têm `created_by` preenchido. Eles só aparecem se o `tenant_id` estiver correto.

**Solução temporária:**
```sql
-- Atribuir registros órfãos ao primeiro usuário do tenant
UPDATE employees SET created_by = (
  SELECT id FROM admin_users WHERE tenant_id = employees.tenant_id LIMIT 1
)
WHERE created_by IS NULL;

-- Repetir para outras tabelas
```

**Q: Como saber qual usuário está logado?**
A: O sistema armazena o `tenant_id` na sessão via `set_current_tenant()`. A função `current_user_id()` usa isso para buscar o ID do usuário.

**Q: E se eu quiser compartilhar dados entre usuários?**
A: Você precisaria criar uma tabela de compartilhamento ou modificar as políticas RLS para incluir uma lógica de permissões mais complexa.

---

## Suporte

Se encontrar problemas:

1. Verifique os logs do Supabase
2. Confirme que o `tenant_id` está sendo configurado no login
3. Teste as funções SQL manualmente:
   ```sql
   SELECT current_user_id();
   SELECT current_user_tenant_id();
   ```

4. Verifique se RLS está ativado:
   ```sql
   SELECT tablename, rowsecurity
   FROM pg_tables
   WHERE schemaname = 'public';
   ```
