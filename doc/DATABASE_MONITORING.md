# Monitoramento de Banco de Dados - Supabase 📊

## 📋 Sistema de Monitoramento Completo

Sistema avançado para monitorar o uso, tamanho e performance do banco de dados Supabase em tempo real.

### ✨ Funcionalidades Implementadas

- 🔍 **Monitoramento em Tempo Real**: Estatísticas atualizadas automaticamente
- 📈 **Visualização Detalhada**: Gráficos e métricas de uso do banco
- ⚠️ **Sistema de Alertas**: Notificações automáticas quando próximo do limite
- 🏷️ **Análise por Tabelas**: Detalhamento do uso de cada tabela
- 💡 **Recomendações Inteligentes**: Sugestões de otimização automáticas
- 📱 **Interface Responsiva**: Funciona perfeitamente em desktop e mobile

## 🛠️ Configuração Inicial

### 1. Executar Funções SQL
Execute o script `src/database/database_size_function.sql` no Supabase SQL Editor para criar as funções necessárias:

```sql
-- Executar no Supabase SQL Editor
CREATE OR REPLACE FUNCTION get_database_size() RETURNS bigint AS $$
  SELECT pg_database_size(current_database());
$$ LANGUAGE sql SECURITY DEFINER;

-- ... outras funções (ver arquivo completo)
```

### 2. Configurar Credenciais
As credenciais já estão configuradas no projeto:
- **Project ID**: cxusoclwtixtjwghjlcj
- **Plano**: Free (500MB banco + 1GB storage)

## 📊 Como Funciona

### 1. Coleta de Dados
O sistema coleta automaticamente:
- **Tamanho total do banco** (via função PostgreSQL)
- **Número de registros** por tabela
- **Uso do Supabase Storage** (arquivos/avatars)
- **Estatísticas de performance**

### 2. Cálculos Realizados
```typescript
// Exemplo dos cálculos
const usagePercentage = (usedSpace / maxDbSize) * 100
const availableSpace = maxDbSize - usedSpace
const estimatedSize = tableRecords * avgRecordSize
```

### 3. Sistema de Alertas

#### 🟢 Status Saudável (0-79%)
- Indicador verde
- Sem alertas
- Monitoramento silencioso

#### 🟡 Status de Atenção (80-94%)
- Indicador amarelo
- Alerta de aviso automático
- Recomendações de otimização

#### 🔴 Status Crítico (95-100%)
- Indicador vermelho pulsante
- Alerta crítico persistente
- Ações urgentes necessárias

## 🎯 Localização no Sistema

### Dashboard Principal (`/dashboard`)
O componente `DatabaseStats` está integrado na tela inicial mostrando:
- **Uso atual** vs limite do plano
- **Espaço disponível** restante
- **Total de registros** no banco
- **Arquivos no storage**

### Detalhes Expandidos
Clique em "Ver Detalhes das Tabelas" para ver:
- **Ranking das tabelas** por tamanho
- **Número de registros** por tabela
- **Estimativa de espaço** ocupado

## 📈 Métricas Monitoradas

### Banco de Dados
| Métrica | Descrição | Limite (Plano Free) |
|---------|-----------|-------------------|
| **Tamanho Total** | Espaço ocupado pelo PostgreSQL | 500 MB |
| **Registros** | Total de linhas em todas as tabelas | Sem limite |
| **Tabelas** | Breakdown por tabela individual | Monitorado |

### Supabase Storage
| Métrica | Descrição | Limite (Plano Free) |
|---------|-----------|-------------------|
| **Arquivos** | Número total de arquivos | Sem limite |
| **Tamanho Storage** | Espaço usado em arquivos | 1 GB |
| **Buckets** | Containers de arquivos | user-avatars |

## 🔧 Arquivos do Sistema

### Core Files
- `src/services/databaseStatsService.ts` - Lógica principal
- `src/components/DatabaseStats.vue` - Interface de monitoramento
- `src/components/DatabaseAlert.vue` - Sistema de alertas
- `src/database/database_size_function.sql` - Funções SQL

### Integração
- `src/views/DashboardView.vue` - Tela principal atualizada
- `src/utils/imageUtils.ts` - Utilitários relacionados

## 🚀 Como Testar

### 1. Verificar Funcionamento Básico
```bash
npm run dev
# Acessar: http://localhost:5174/dashboard
```

### 2. Console do Navegador
Verifique os logs para debug:
```javascript
// Console exibe:
📊 Coletando estatísticas do banco de dados...
✅ Estatísticas carregadas: {
  totalSize: "15.2 MB",
  usage: "3%",
  status: "healthy"
}
```

### 3. Testar Alertas Manualmente
```javascript
// No console do navegador, simular uso alto:
const dbStats = document.querySelector('[data-db-stats]')
// Modificar os valores para testar alertas
```

## ⚡ Otimização e Performance

### Atualizações Automáticas
- **Intervalo**: 5 minutos
- **Cache**: Dados ficam em cache por 1 minuto
- **Background**: Não bloqueia a interface

### Estimativas Inteligentes
O sistema usa múltiplas estratégias para calcular tamanhos:

1. **Função PostgreSQL** (preferida)
2. **Contagem de registros** × tamanho médio
3. **Estimativa baseada** em padrões conhecidos

## 🎨 Interface e UX

### Design Responsivo
```css
/* Desktop */
.database-panel { grid-column: span 8; }

/* Mobile */
@media (max-width: 768px) {
  .database-panel { grid-column: span 12; }
}
```

### Estados Visuais
- **Loading**: Spinner animado
- **Error**: Botão de retry
- **Success**: Dados formatados
- **Alerts**: Modal overlay

## 📱 Responsividade

### Desktop (1024px+)
- Componente ocupa 8 colunas
- Todos os detalhes visíveis
- Gráficos em tamanho completo

### Tablet (768px-1024px)
- Layout adaptado
- Métricas em grid 2×2
- Navegação touch-friendly

### Mobile (<768px)
- Componente em tela cheia
- Métricas empilhadas
- Botões maiores para touch

## 🔍 Troubleshooting

### Problema: "Erro ao obter estatísticas"
**Solução**:
1. Verificar se as funções SQL foram executadas
2. Checar credenciais do Supabase
3. Verificar console para erros específicos

### Problema: "Tamanho sempre mostra 1MB"
**Solução**:
1. A função `get_database_size()` não foi criada
2. Execute o script SQL completo
3. Verifique permissões no Supabase

### Problema: "Alertas não aparecem"
**Solução**:
1. Verificar se `usagePercentage >= 80`
2. Checar localStorage para alertas dispensados
3. Testar com dados mockados

## 🎯 Próximos Passos

### Melhorias Futuras
- [ ] **Histórico de Uso**: Gráfico temporal
- [ ] **Backup Automático**: Quando próximo do limite
- [ ] **Webhooks**: Alertas via email/Slack
- [ ] **Previsão**: Machine learning para prever crescimento
- [ ] **Limpeza Automática**: Remover dados antigos

### Integrações
- [ ] **API Externa**: Monitoramento via API
- [ ] **Dashboard Admin**: Interface dedicada
- [ ] **Relatórios PDF**: Exportar estatísticas

---

## ✅ Status Final

### Tudo Funcionando! 🎉

✅ **Monitoramento em tempo real** - Dados atualizados a cada 5min
✅ **Sistema de alertas** - Warnings automáticos em 80%+ uso
✅ **Interface moderna** - Design responsivo e intuitivo
✅ **Performance otimizada** - Carregamento rápido e eficiente
✅ **Documentação completa** - Guias e troubleshooting

### Como Acessar
1. Execute: `npm run dev`
2. Acesse: http://localhost:5174/dashboard
3. Veja a seção "Banco de Dados" no dashboard
4. Clique em "Ver Detalhes" para informações completas

O sistema está pronto para monitorar o banco de dados Supabase em produção! 🚀