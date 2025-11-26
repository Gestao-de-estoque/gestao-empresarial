**Objetivo geral**
Corrigir a estrutura de permissões do sistema para garantir que cada usuário só possa acessar, visualizar, editar e excluir os dados que ele mesmo criou. Atualmente, quando vários usuários são registrados, todos conseguem ver os dados uns dos outros. Esse problema ocorre em todas as rotas do sistema e também nas políticas do Supabase.

---

## O que deve ser feito

### 1. Revisar toda a estrutura do banco (arquivo `src/sql/scheme.sql`)
- Verificar como estão os campos responsáveis por identificar o dono dos registros (ex.: `created_by`, `owner_id`, etc.).
- Caso existam tabelas que ainda não possuem um campo que identifique o usuário criador, isso deve ser padronizado.
- Garantir que todos os dados relacionados a:
  - funcionários (`/employees`)
  - produtos do menu (`/menu`)
  - registros financeiros (`/financial`)
  - produtos do estoque (`/inventory`)
  - fornecedores (`/suppliers`)
  
  tenham claramente um proprietário (usuário criador).

---

### 2. Atualizar o backend para sempre incluir o usuário logado como criador dos registros
- Toda vez que um registro for criado, o sistema deve automaticamente associar o ID do usuário logado ao campo de propriedade (ex.: `created_by`).
- Essa regra deve valer para todas as rotas mencionadas acima.

---

### 3. Restringir o acesso aos dados usando políticas (arquivo `politicas.json`)
- Revisar todas as políticas criadas no Supabase.
- Ajustar as políticas para que:
  - O usuário só consiga “SELECT” registros criados por ele mesmo.
  - O usuário só consiga “INSERT” registros cujo proprietário seja ele mesmo.
  - O usuário só consiga “UPDATE” registros criados por ele mesmo.
  - O usuário só consiga “DELETE” registros criados por ele mesmo.
- Nenhum usuário deve ver, consultar, editar ou excluir dados de outros usuários em nenhuma das tabelas.

---

### 4. Corrigir os erros nas rotas
#### **Erro nas rotas `/inventory` e `/menu`**
- Os erros "invalid input syntax for type uuid: \"\"" mostram que o sistema está enviando campos de UUID vazios.
- O backend deve validar esses campos e nunca enviar strings vazias.
- Caso o campo não seja preenchido, deve ser enviado como `null` ou não enviado.

#### **Erro nas rotas `/financial`, `/employees` e `/suppliers`**
- O erro “Usuário não está associado a nenhum tenant” indica que:
  - O sistema depende de um tenant
  - O usuário não está sendo associado automaticamente
  - Ou as políticas exigem tenant mesmo quando não deveria
- Corrigir a definição do tenant ou desativar essa obrigatoriedade se não for necessária.

---

### 5. Padronizar mensagens de erro em todas as rotas
- `/inventory`
- `/financial`
- `/employees`
- `/suppliers`
- `/menu`

Garantir que os erros exibidos ao usuário:
- tenham texto claro
- expliquem exatamente onde está o problema
- não exponham mensagens internas do banco
- sigam um padrão único no backend

---

### 6. Resumo das regras essenciais
- Cada usuário criado na rota `/register` deve ter acesso somente aos próprios dados.
- O dashboard deve exibir apenas dados criados pelo usuário logado.
- As politicas de acesso do Supabase devem impedir completamente o acesso cruzado entre usuários.
- Todas as tabelas e rotas precisam seguir esse comportamento de forma consistente.

---

## Problemas que precisam ser resolvidos imediatamente
1. Cada usuário consegue ver dados de outros usuários.
2. As políticas atuais do Supabase não implementam isolamento de dados corretamente.
3. Os inserts estão enviando valores inválidos para campos UUID.
4. O sistema exibe erro de tenant inexistente para alguns usuários.
5. Mensagens de erro inconsistentes nas rotas.

---

## Entrega esperada
- Revisão e correção da estrutura completa do banco.
- Revisão e correção de todas as políticas de acesso.
- Correção das rotas e validações para evitar erros 400, P0001 e 22P02.
- Garantir isolamento total dos dados entre usuários.
- Garantir que o sistema não permita que um usuário visualize, edite ou exclua dados de outro usuário.

