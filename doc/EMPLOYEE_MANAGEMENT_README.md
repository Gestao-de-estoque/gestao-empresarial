# Sistema de Gestão de Funcionários e Pagamentos

## 📋 Visão Geral

Sistema completo de gestão de funcionários com cálculo automático de salários, controle de pagamentos e dashboard analítico de alta performance.

## ✨ Funcionalidades Principais

### 1. Gestão de Funcionários
- **Cadastro Completo**: Nome, e-mail, telefone, foto, função e data de contratação
- **Funções Disponíveis**:
  - Garçom
  - Balconista
  - Barmen
  - Cozinheiro
  - Cozinheiro Chef
- **Status**: Ativo, Inativo, Férias, Afastado
- **Filtros Avançados**: Por função e status

### 2. Dados Bancários
- **Múltiplas Contas**: Cada funcionário pode ter várias contas bancárias
- **Bancos Suportados**:
  - Nubank
  - Neon
  - XP Investimentos
  - BTG Pactual
  - PicPay
  - Mercado Pago
  - Banco Inter
  - Banco do Brasil
  - Caixa Econômica
  - Itaú
  - Santander
  - Bradesco
- **Tipos de Conta**: Corrente, Poupança, Salário
- **PIX**: Cadastro de chaves PIX (CPF, e-mail, telefone, chave aleatória, QR Code)
- **Ícones de Banco**: Cada banco tem seu ícone e cor característica

### 3. Sistema de Pagamentos

#### Cálculo Automático de Salários
O sistema calcula automaticamente os salários baseado em 3 tipos de configuração:

**a) Fixo** (Ex: Cozinheiros)
- R$ 150,00 por dia fixo
- Não varia com o movimento

**b) Percentual** (Ex: Garçons)
- 10% do movimento diário
- Dividido automaticamente entre os garçons ativos
- Garantia mínima opcional

**c) Misto** (Ex: Balconista)
- Combina valor fixo + percentual
- Paga o maior valor entre os dois
- Garantia mínima de R$ 80,00

#### Recursos de Pagamento
- Processamento em lote
- Bônus e deduções
- Histórico completo
- Status: Pendente, Processando, Pago, Cancelado
- Métodos: PIX, Transferência, Dinheiro, Cheque
- Auditoria completa de alterações

### 4. Dashboard Analítico

#### Métricas em Tempo Real
- Funcionários ativos
- Pagamentos do mês
- Pagamentos pendentes
- Média diária de pagamentos

#### Gráficos de Performance
- **Performance de Garçons**: Ranking com total ganho, média diária e melhor dia
- **Pagamentos por Função**: Gráfico de barras comparativo
- **Tendência de Pagamentos**: Linha temporal mostrando evolução

#### Relatórios
- Análise mensal por função
- Exportação para CSV
- Filtros por período

### 5. Integração com Análise Financeira

O sistema se integra perfeitamente com a rota `/financial`:
- **Sincronização Automática**: Pagamentos são sincronizados com `financial_data`
- **Tabela `daily_financial_summary`**: Mantém resumo diário
- **Consistência de Dados**: Mesmos valores em ambas as rotas
- **Trigger Automático**: Atualiza `financial_data` quando resumo diário é criado

## 📊 Estrutura do Banco de Dados

### Tabelas Principais
1. **employees**: Cadastro de funcionários
2. **banks**: Lista de bancos suportados
3. **employee_bank_accounts**: Contas bancárias dos funcionários
4. **salary_configs**: Configurações de cálculo de salário por função
5. **daily_payments**: Registro de pagamentos diários
6. **daily_financial_summary**: Resumo financeiro diário (integrado com financial_data)
7. **employee_attendance**: Controle de presença
8. **employee_performance_metrics**: Métricas de performance
9. **payment_audit_log**: Log de auditoria

### Views para Relatórios
- `vw_active_employees_summary`: Resumo de funcionários ativos
- `vw_pending_payments`: Pagamentos pendentes
- `vw_monthly_payment_analysis`: Análise mensal de pagamentos
- `vw_garcom_performance`: Performance dos garçons

## 🚀 Como Usar

### 1. Configuração Inicial

**Execute o SQL**:
```bash
psql -U seu_usuario -d seu_banco < database.sql
```

Isso criará:
- Todas as tabelas necessárias
- Triggers automáticos
- Views de relatório
- Dados iniciais (bancos e configurações de salário)

### 2. Acessar o Sistema

Navegue para: `http://localhost:5173/employees`

Ou clique no card "Gestão de Funcionários" no dashboard principal.

### 3. Workflow Típico

**a) Cadastrar Funcionários**
1. Clique em "Adicionar Funcionário"
2. Preencha os dados
3. Selecione a função
4. Salve

**b) Adicionar Dados Bancários**
1. No card do funcionário, clique no ícone de cartão de crédito
2. Selecione o banco
3. Preencha agência, conta e chave PIX
4. Salve

**c) Processar Pagamentos**
1. Clique em "Processar Pagamentos"
2. Selecione a data
3. Informe a receita total do dia
4. O sistema calculará automaticamente para todos os funcionários ativos

**d) Marcar como Pago**
1. Na aba "Pagamentos"
2. Clique no ícone de check no pagamento pendente
3. Informe o método de pagamento
4. Confirme

### 4. Configurar Salários

Na aba "Configurações de Salário":
1. Clique em "Configurar" na função desejada
2. Ajuste:
   - Tipo de cálculo (Fixo, Percentual, Misto)
   - Valores e porcentagens
   - Garantia mínima
   - Limite máximo
3. Salve

## 🔧 Tecnologias Utilizadas

### Backend
- **Supabase**: Banco de dados PostgreSQL
- **TypeScript**: Tipagem forte e segurança

### Frontend
- **Vue 3**: Framework progressivo
- **TypeScript**: Tipagem de componentes
- **Chart.js**: Gráficos interativos
- **Lucide Icons**: Ícones modernos
- **CSS Modules**: Estilização scoped

### Arquitetura
- **Service Layer**: Lógica de negócio isolada (`employeeService.ts`)
- **Type Safety**: Tipos completos em `employee.ts`
- **Componentes Modulares**: Modais reutilizáveis
- **Responsivo**: Design mobile-first

## 📁 Estrutura de Arquivos

```
src/
├── views/
│   └── EmployeeManagementView.vue       # Página principal
├── components/
│   └── employee/
│       ├── EmployeeFormModal.vue        # Formulário de funcionário
│       ├── BankAccountModal.vue         # Dados bancários
│       ├── ProcessPaymentsModal.vue     # Processar pagamentos
│       ├── PaymentDetailsModal.vue      # Detalhes do pagamento
│       └── SalaryConfigModal.vue        # Configurar salários
├── services/
│   └── employeeService.ts               # Lógica de negócio
├── types/
│   └── employee.ts                      # Tipos TypeScript
└── config/
    └── supabase.ts                      # Configuração do banco

database.sql                              # Schema do banco de dados
```

## 💡 Exemplos de Cálculo

### Garçom (10% dividido)
```
Receita do dia: R$ 1.000,00
Garçons ativos: 2
Cálculo: (R$ 1.000,00 × 10%) ÷ 2 = R$ 50,00 por garçom
```

### Cozinheiro (Fixo)
```
Receita do dia: R$ 1.000,00
Salário fixo: R$ 150,00
Pagamento: R$ 150,00 (independente da receita)
```

### Balconista (Misto)
```
Receita do dia: R$ 500,00
Valor fixo: R$ 80,00
Percentual: 5% = R$ 25,00
Pagamento: R$ 80,00 (maior valor)
```

## 🎨 Interface

### Design Elegante
- **Gradient Background**: Roxo degradê moderno
- **Cards Glassmorphism**: Efeito de vidro fosco
- **Animações Suaves**: Hover e transições
- **Cores Semânticas**: Verde (sucesso), Vermelho (deduções), Azul (informação)
- **Responsivo**: Adaptável a todos os dispositivos

### Experiência do Usuário
- **Busca em Tempo Real**: Filtragem instantânea
- **Ações Contextuais**: Botões intuitivos em cada card
- **Feedback Visual**: Status coloridos e badges
- **Loading States**: Indicadores de carregamento
- **Validações**: Formulários com validação em tempo real

## 🔒 Segurança

- **Triggers Automáticos**: Updated_at sempre atualizado
- **Auditoria**: Log completo de alterações
- **Constraints**: Validações no banco de dados
- **Unique Keys**: Prevenção de duplicatas
- **Cascade Delete**: Remoção em cascata segura

## 📈 Performance

- **Índices Otimizados**: Consultas rápidas
- **Views Pré-Calculadas**: Relatórios instantâneos
- **Batch Operations**: Processamento em lote
- **Lazy Loading**: Carregamento sob demanda
- **Caching**: Dados em memória quando possível

## 🐛 Troubleshooting

### Pagamentos não aparecem
- Verifique se os funcionários estão com status "ativo"
- Confirme que a data está correta
- Veja os logs do console para erros

### Cálculo incorreto
- Revise as configurações de salário na aba correspondente
- Verifique se há múltiplos funcionários na mesma função (para garçons)
- Consulte a coluna `calculation_details` no banco

### Integração com Financial
- Execute: `SELECT * FROM daily_financial_summary WHERE synced_with_financial_data = false`
- Verifique o trigger: `trigger_sync_daily_financial_summary`

## 📝 Próximos Passos

Possíveis melhorias futuras:
- [ ] Upload de foto direto no formulário
- [ ] Relatórios em PDF
- [ ] Notificações de pagamento por e-mail/WhatsApp
- [ ] App mobile com React Native
- [ ] Integração com folha de pagamento
- [ ] Controle de ponto eletrônico
- [ ] Vale-transporte e benefícios
- [ ] Geração de contracheques

## 🤝 Suporte

Para dúvidas ou problemas:
1. Verifique este README
2. Consulte os comentários no código
3. Analise os logs do console
4. Verifique a documentação do Supabase

---

**Desenvolvido com ❤️ usando Vue 3, TypeScript e Supabase**
