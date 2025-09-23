# GestaoZe System - Sistema Web de Gestão de Estoque

[![Vue.js](https://img.shields.io/badge/Vue.js-3.x-4FC08D.svg)](https://vuejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue.svg)](https://www.typescriptlang.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![Google Gemini](https://img.shields.io/badge/Google%20Gemini-AI-orange.svg)](https://ai.google.dev/)

Sistema web completo de gestão de estoque desenvolvido em Vue.js 3 com TypeScript, baseado na estrutura do app mobile existente.

## 🚀 Instalação e Execução

### Opção 1: Usando o Script de Setup (Recomendado)

```bash
# Execute o script de setup automatizado
node setup-sistema-web-simple.js

# Entre no diretório do projeto
cd gestaozesystem-web

# Execute o sistema
npm run dev
```

### Opção 2: Instalação Manual

```bash
# Clone o projeto
git clone [url-do-repositorio]
cd gestaozesystem-web

# Instale as dependências
npm install

# Configure as variáveis de ambiente
cp .env.example .env

# Execute o projeto
npm run dev
```

## 🌐 Acesso ao Sistema

- **URL Local:** http://localhost:5173
- **URL de Rede:** http://172.16.0.46:5173

### 🔐 Credenciais de Demonstração

- **Usuário:** rebecaluize@gmail.com
- **Senha:** Restpedacinhodoceu@2025

## ✨ Funcionalidades Implementadas

### 🏠 Dashboard
- ✅ Visão geral do sistema
- ✅ Estatísticas em tempo real
- ✅ Navegação rápida
- ✅ Indicadores de estoque baixo

### 📦 Gestão de Estoque
- ✅ Lista completa de produtos
- ✅ Filtros por categoria e estoque
- ✅ Busca inteligente
- ✅ Adicionar/editar produtos
- ✅ Controle de estoque mínimo
- ✅ Indicadores visuais de status

### 🤖 Análise com IA (Google Gemini)
- ✅ Análise automática do estoque
- ✅ Sugestões inteligentes de compra
- ✅ Chat interativo com assistente IA
- ✅ Perguntas rápidas personalizadas
- ✅ Insights estratégicos

### 🔐 Sistema de Autenticação
- ✅ Login seguro com Supabase
- ✅ Gerenciamento de sessão
- ✅ Proteção de rotas
- ✅ Hash de senhas

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Vue.js 3** - Framework progressivo
- **TypeScript** - Tipagem estática
- **Vue Router** - Roteamento SPA
- **Pinia** - Gerenciamento de estado
- **Vite** - Build tool moderno

### Backend & Serviços
- **Supabase** - Backend as a Service
- **PostgreSQL** - Banco de dados
- **Google Gemini AI** - Inteligência artificial
- **Axios** - Cliente HTTP

### Estilização
- **CSS3** - Estilos customizados
- **CSS Grid & Flexbox** - Layout responsivo
- **CSS Animations** - Micro-interações

## 📊 Estrutura do Banco de Dados

O sistema utiliza as seguintes tabelas principais:

- `admin_users` - Usuários do sistema
- `produtos` - Catálogo de produtos
- `categorias` - Categorias de produtos
- `movements` - Movimentações de estoque
- `logs` - Sistema de auditoria
- `suppliers` - Fornecedores
- `menu_items` - Itens do cardápio
- `reports` - Relatórios gerados

## 🗂️ Estrutura do Projeto

```
src/
├── components/          # Componentes reutilizáveis
│   ├── common/         # Componentes genéricos
│   ├── forms/          # Formulários
│   └── layout/         # Layout e navegação
├── views/              # Páginas do sistema
│   ├── auth/           # Autenticação
│   ├── dashboard/      # Dashboard principal
│   ├── inventory/      # Gestão de estoque
│   └── ai/             # Análise com IA
├── services/           # Serviços de API
│   ├── authService.ts  # Autenticação
│   ├── productService.ts # Produtos
│   └── aiService.ts    # Integração IA
├── stores/             # Estado global (Pinia)
│   └── auth.ts         # Store de autenticação
├── types/              # Tipos TypeScript
│   ├── auth.ts         # Tipos de autenticação
│   └── product.ts      # Tipos de produtos
├── config/             # Configurações
│   └── supabase.ts     # Config Supabase
└── router/             # Configuração de rotas
    └── index.ts        # Rotas principais
```

## 🔧 Scripts Disponíveis

```bash
# Desenvolvimento
npm run dev           # Inicia servidor de desenvolvimento

# Build de Produção
npm run build         # Gera build otimizado
npm run preview       # Visualiza build de produção

# Verificação de Código
npm run type-check    # Verifica tipos TypeScript
```

## 🌍 Configuração de Ambiente

### Variáveis de Ambiente (.env)

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://cxusoclwtixtjwghjlcj.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Google Gemini AI Configuration
VITE_GEMINI_API_KEY=AIzaSyD-Ie2bmSXQwDU5wTX3zDDhAoC0sq7ur88
VITE_GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent

# App Configuration
VITE_APP_NAME=GestaoZe System
VITE_APP_VERSION=1.0.0
```

## 🔐 Configuração do Supabase

### Tabelas Principais

```sql
-- Usuários do sistema
CREATE TABLE admin_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username varchar UNIQUE NOT NULL,
  email varchar UNIQUE NOT NULL,
  password_hash varchar NOT NULL,
  name varchar,
  role varchar DEFAULT 'admin',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Produtos
CREATE TABLE produtos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome varchar NOT NULL,
  categoria_id uuid REFERENCES categorias(id),
  preco numeric NOT NULL DEFAULT 0,
  custo numeric DEFAULT 0,
  current_stock integer DEFAULT 0,
  min_stock integer DEFAULT 0,
  unidade varchar DEFAULT 'unidade',
  descricao text,
  codigo_barras varchar,
  ativo boolean DEFAULT true,
  created_by uuid REFERENCES admin_users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

## 🤖 Integração com Google Gemini AI

### Funcionalidades de IA

1. **Análise de Estoque**
   - Identificação de produtos críticos
   - Análise de custos e preços
   - Recomendações estratégicas

2. **Sugestões de Compra**
   - Lista inteligente de compras
   - Otimização de custos
   - Planejamento semanal

3. **Chat Interativo**
   - Assistente 24/7
   - Respostas contextuais
   - Perguntas pré-definidas

### Exemplo de Uso da IA

```typescript
import { aiService } from '@/services/aiService'

// Análise de estoque
const analysis = await aiService.analyzeInventory(inventoryData)

// Sugestões de compra
const suggestions = await aiService.generatePurchaseSuggestions(inventoryData)

// Chat com IA
const response = await aiService.askQuestion("Como posso reduzir custos?")
```

## 📱 Responsividade

O sistema é totalmente responsivo e funciona em:

- 💻 **Desktop** (1200px+)
- 📱 **Tablet** (768px - 1199px)
- 📱 **Mobile** (até 767px)

## 🎨 Funcionalidades Visuais

### Design System
- **Cores Primárias:** #667eea, #764ba2, #f093fb
- **Gradientes:** Linear gradients suaves
- **Tipografia:** Inter font family
- **Icones:** Emojis nativos para melhor compatibilidade

### Componentes Interativos
- ✨ Animações suaves
- 🎭 Estados de loading
- 🎯 Feedback visual
- 📊 Barras de progresso
- 🔄 Transições fluidas

## 🔧 Desenvolvimento

### Executar em Desenvolvimento

```bash
# Instalar dependências
npm install

# Executar servidor de desenvolvimento
npm run dev

# O sistema estará disponível em http://localhost:5173
```

### Build para Produção

```bash
# Gerar build otimizado
npm run build

# O build será gerado na pasta 'dist'
```

## 🐛 Solução de Problemas

### Problemas Comuns

1. **Erro de autenticação no Supabase**
   - Verifique as credenciais no arquivo `.env`
   - Confirme se o usuário existe na tabela `admin_users`

2. **IA não responde**
   - Verifique a chave da API do Google Gemini
   - Confirme se há conexão com a internet

3. **Produtos não carregam**
   - Verifique a conexão com o Supabase
   - Confirme se existem produtos na tabela `produtos`

### Logs de Debug

```bash
# Para ver logs detalhados
npm run dev -- --debug
```

## 🚀 Deploy

### Vercel (Recomendado)

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

### Netlify

```bash
# Build
npm run build

# Deploy pasta dist/ no Netlify
```

## 📋 Checklist de Funcionalidades

### ✅ Implementado
- [x] Sistema de autenticação
- [x] Dashboard principal
- [x] Gestão completa de estoque
- [x] Integração com IA Google Gemini
- [x] Interface responsiva
- [x] Sistema de busca e filtros
- [x] Indicadores visuais de estoque

### 🔄 Futuras Implementações
- [ ] Gestão de fornecedores
- [ ] Sistema de cardápio digital
- [ ] Relatórios avançados
- [ ] Sistema de notificações
- [ ] Integração com impressoras
- [ ] App mobile PWA

## 🤝 Contribuição

Este é um projeto proprietário. Para contribuições ou melhorias, entre em contato com a equipe de desenvolvimento.

## 📞 Suporte

Para suporte técnico ou dúvidas:

- **Email:** suporte@gestaozesystem.com
- **Documentação:** [Link para docs]
- **Issues:** [Link para issues do GitHub]

## 📄 Licença

Este projeto é proprietário da empresa. Todos os direitos reservados.

---

## 🎯 Resumo Técnico

**GestaoZe System** é uma solução completa de gestão de estoque para restaurantes, desenvolvida com tecnologias modernas e integração de IA. O sistema oferece:

- **Interface intuitiva** e responsiva
- **Análise inteligente** com Google Gemini AI
- **Integração robusta** com Supabase
- **Arquitetura escalável** em Vue.js 3 + TypeScript
- **Compatibilidade total** com o app mobile existente

Ideal para restaurantes que buscam otimizar sua gestão de estoque com tecnologia de ponta e insights baseados em inteligência artificial.

---

*Desenvolvido com ❤️ para o futuro da gestão gastronômica*