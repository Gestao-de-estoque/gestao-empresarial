<template>
  <div class="documentation-view">
    <!-- Header -->
    <header class="docs-header">
      <div class="header-content">
        <div class="header-left">
          <div class="logo-section">
            <FileText :size="32" />
            <div class="title-group">
              <h1>GestaoZe System</h1>
              <p>Developer Documentation</p>
            </div>
          </div>
        </div>

        <div class="header-right">
          <div class="search-container">
            <Search :size="20" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Buscar na documentação..."
              class="search-input"
              @input="handleSearch"
            />
            <kbd v-if="!searchQuery" class="search-shortcut">Ctrl+K</kbd>
          </div>

          <div class="header-actions">
            <button @click="toggleTheme" class="theme-toggle" :title="isDarkMode ? 'Modo Claro' : 'Modo Escuro'">
              <component :is="isDarkMode ? Sun : Moon" :size="20" />
            </button>

            <button @click="showAPIPlayground = true" class="api-btn">
              <Terminal :size="20" />
              API Playground
            </button>
          </div>
        </div>
      </div>
    </header>

    <div class="docs-container">
      <!-- Sidebar Navigation -->
      <nav class="docs-sidebar" :class="{ collapsed: sidebarCollapsed }">
        <div class="sidebar-header">
          <button @click="sidebarCollapsed = !sidebarCollapsed" class="collapse-btn">
            <Menu :size="20" />
          </button>
          <span v-if="!sidebarCollapsed">Navegação</span>
        </div>

        <div class="sidebar-content" v-if="!sidebarCollapsed">
          <!-- Quick Navigation -->
          <div class="nav-section">
            <h3 class="nav-title">
              <Zap :size="16" />
              Início Rápido
            </h3>
            <ul class="nav-list">
              <li><a href="#getting-started" @click="scrollTo('getting-started')">Primeiros Passos</a></li>
              <li><a href="#installation" @click="scrollTo('installation')">Instalação</a></li>
              <li><a href="#authentication" @click="scrollTo('authentication')">Autenticação</a></li>
              <li><a href="#configuration" @click="scrollTo('configuration')">Configuração</a></li>
            </ul>
          </div>

          <!-- Routes & Features -->
          <div class="nav-section">
            <h3 class="nav-title">
              <Map :size="16" />
              Rotas & Funcionalidades
            </h3>
            <ul class="nav-list">
              <li><a href="#dashboard" @click="scrollTo('dashboard')">Dashboard</a></li>
              <li><a href="#inventory" @click="scrollTo('inventory')">Gestão de Estoque</a></li>
              <li><a href="#ai-assistant" @click="scrollTo('ai-assistant')">Assistente IA</a></li>
              <li><a href="#financial" @click="scrollTo('financial')">Financeiro</a></li>
              <li><a href="#menu-management" @click="scrollTo('menu-management')">Gestão de Menu</a></li>
              <li><a href="#reports" @click="scrollTo('reports')">Relatórios</a></li>
              <li><a href="#suppliers" @click="scrollTo('suppliers')">Fornecedores</a></li>
              <li><a href="#user-management" @click="scrollTo('user-management')">Usuários</a></li>
            </ul>
          </div>

          <!-- API Reference -->
          <div class="nav-section">
            <h3 class="nav-title">
              <Server :size="16" />
              API Reference
            </h3>
            <ul class="nav-list">
              <li><a href="#api-overview" @click="scrollTo('api-overview')">Visão Geral</a></li>
              <li><a href="#api-auth" @click="scrollTo('api-auth')">Autenticação</a></li>
              <li><a href="#api-products" @click="scrollTo('api-products')">Produtos</a></li>
              <li><a href="#api-movements" @click="scrollTo('api-movements')">Movimentações</a></li>
              <li><a href="#api-reports" @click="scrollTo('api-reports')">Relatórios</a></li>
              <li><a href="#api-users" @click="scrollTo('api-users')">Usuários</a></li>
            </ul>
          </div>

          <!-- Architecture -->
          <div class="nav-section">
            <h3 class="nav-title">
              <Layers :size="16" />
              Arquitetura
            </h3>
            <ul class="nav-list">
              <li><a href="#tech-stack" @click="scrollTo('tech-stack')">Stack Tecnológica</a></li>
              <li><a href="#database-schema" @click="scrollTo('database-schema')">Schema do Banco</a></li>
              <li><a href="#services" @click="scrollTo('services')">Serviços</a></li>
              <li><a href="#components" @click="scrollTo('components')">Componentes</a></li>
              <li><a href="#state-management" @click="scrollTo('state-management')">Gerenciamento Estado</a></li>
            </ul>
          </div>

          <!-- Development -->
          <div class="nav-section">
            <h3 class="nav-title">
              <Code :size="16" />
              Desenvolvimento
            </h3>
            <ul class="nav-list">
              <li><a href="#setup-dev" @click="scrollTo('setup-dev')">Setup Desenvolvimento</a></li>
              <li><a href="#coding-standards" @click="scrollTo('coding-standards')">Padrões de Código</a></li>
              <li><a href="#testing" @click="scrollTo('testing')">Testes</a></li>
              <li><a href="#deployment" @click="scrollTo('deployment')">Deploy</a></li>
              <li><a href="#troubleshooting" @click="scrollTo('troubleshooting')">Troubleshooting</a></li>
            </ul>
          </div>
        </div>
      </nav>

      <!-- Main Content -->
      <main class="docs-content">
        <DocSection id="getting-started">
          <DocHeader
            title="🚀 Primeiros Passos"
            description="Guia completo para começar a desenvolver com o GestaoZe System"
          />

          <DocBlock title="Visão Geral do Sistema">
            <p>
              O <strong>GestaoZe System</strong> é uma plataforma completa de gestão empresarial desenvolvida em Vue.js 3
              com TypeScript, focada em gestão de estoque, menu, financeiro e relatórios com integração de IA.
            </p>

            <div class="features-grid">
              <div class="feature-card">
                <Package :size="24" />
                <h4>Gestão de Estoque</h4>
                <p>Controle completo de produtos, categorias e movimentações</p>
              </div>
              <div class="feature-card">
                <Brain :size="24" />
                <h4>Assistente IA</h4>
                <p>Integração com Google Gemini para análises inteligentes</p>
              </div>
              <div class="feature-card">
                <DollarSign :size="24" />
                <h4>Módulo Financeiro</h4>
                <p>Controle de receitas, despesas e relatórios financeiros</p>
              </div>
              <div class="feature-card">
                <BarChart3 :size="24" />
                <h4>Relatórios Avançados</h4>
                <p>Dashboards interativos com Chart.js</p>
              </div>
            </div>
          </DocBlock>

          <DocBlock title="Arquitetura do Sistema">
            <CodeBlock language="mermaid" :code="architectureDiagram" />
          </DocBlock>
        </DocSection>

        <DocSection id="installation">
          <DocHeader
            title="⚙️ Instalação"
            description="Como configurar e executar o projeto"
          />

          <DocBlock title="Requisitos do Sistema">
            <ul class="requirements-list">
              <li><code>Node.js</code> >= 18.0.0</li>
              <li><code>npm</code> >= 8.0.0</li>
              <li><code>Vue CLI</code> >= 5.0.0</li>
              <li>Conta no <code>Supabase</code></li>
              <li>API Key do <code>Google Gemini</code></li>
            </ul>
          </DocBlock>

          <DocBlock title="Clonagem e Instalação">
            <CodeBlock language="bash" :code="installationSteps" />
          </DocBlock>

          <DocBlock title="Configuração das Variáveis de Ambiente">
            <CodeBlock language="bash" :code="envExample" />
          </DocBlock>
        </DocSection>

        <!-- Dashboard Section -->
        <DocSection id="dashboard">
          <DocHeader
            title="📊 Dashboard"
            description="Visão geral completa do sistema com métricas em tempo real"
            :badges="[{ text: 'Rota Principal', type: 'info' }]"
          />

          <DocBlock title="Funcionalidades do Dashboard" variant="info" :icon="BarChart3">
            <p>O dashboard é a página principal do sistema, fornecendo uma visão geral completa:</p>
            <ul>
              <li><strong>Estatísticas de Estoque:</strong> Produtos totais, baixo estoque, valor total</li>
              <li><strong>Movimentações Recentes:</strong> Últimas entradas e saídas do estoque</li>
              <li><strong>Gráficos Interativos:</strong> Visualizações com Chart.js</li>
              <li><strong>Monitoramento do Banco:</strong> Tamanho e utilização do Supabase</li>
              <li><strong>Alertas:</strong> Notificações de produtos com estoque baixo</li>
            </ul>
          </DocBlock>

          <DocBlock title="Componentes Utilizados">
            <div class="component-list">
              <div class="component-item">
                <code>StatCard.vue</code> - Cards de estatísticas
              </div>
              <div class="component-item">
                <code>ChartComponent.vue</code> - Gráficos Chart.js
              </div>
              <div class="component-item">
                <code>DatabaseStats.vue</code> - Monitoramento do banco
              </div>
              <div class="component-item">
                <code>RecentMovements.vue</code> - Movimentações recentes
              </div>
            </div>
          </DocBlock>

          <DocBlock title="API Endpoints" variant="code">
            <CodeBlock
              language="javascript"
              filename="dashboard-api.js"
              :code="dashboardApiCode"
            />
          </DocBlock>
        </DocSection>

        <!-- Inventory Section -->
        <DocSection id="inventory">
          <DocHeader
            title="📦 Gestão de Estoque"
            description="Sistema completo de controle de inventário e produtos"
            :badges="[{ text: 'CRUD Completo', type: 'success' }]"
          />

          <DocBlock title="Funcionalidades Principais" variant="success" :icon="Package">
            <ul>
              <li><strong>Cadastro de Produtos:</strong> Nome, descrição, preço, categoria</li>
              <li><strong>Controle de Estoque:</strong> Quantidades, mínimo, máximo</li>
              <li><strong>Categorias:</strong> Organização por categorias</li>
              <li><strong>Movimentações:</strong> Entradas e saídas com histórico</li>
              <li><strong>Relatórios:</strong> Exportação em PDF/Excel</li>
              <li><strong>Busca Avançada:</strong> Filtros múltiplos</li>
            </ul>
          </DocBlock>

          <DocBlock title="Estrutura da Tabela Produtos">
            <CodeBlock
              language="sql"
              filename="produtos.sql"
              :code="sqlProductsCode"
            />
          </DocBlock>

          <DocBlock title="API Endpoints" variant="code">
            <CodeBlock
              language="javascript"
              filename="inventory-api.js"
              :code="inventoryApiCode"
            />
          </DocBlock>
        </DocSection>

        <!-- AI Assistant Section -->
        <DocSection id="ai-assistant">
          <DocHeader
            title="🤖 Assistente IA"
            description="Integração com Google Gemini AI para análises inteligentes"
            :badges="[{ text: 'Gemini 2.0', type: 'info' }]"
          />

          <DocBlock title="Capacidades do Assistente IA" variant="info" :icon="Brain">
            <ul>
              <li><strong>Análise de Estoque:</strong> Insights sobre movimentações</li>
              <li><strong>Previsão de Demanda:</strong> Baseada em histórico</li>
              <li><strong>Recomendações:</strong> Sugestões de compra/reposição</li>
              <li><strong>Relatórios Inteligentes:</strong> Análise de dados automatizada</li>
              <li><strong>Chat Interativo:</strong> Perguntas sobre o negócio</li>
            </ul>
          </DocBlock>

          <DocBlock title="Configuração da API" variant="warning">
            <p>Para utilizar o assistente IA, configure as seguintes variáveis:</p>
            <CodeBlock
              language="bash"
              filename=".env"
              :code="aiConfigCode"
            />
          </DocBlock>

          <DocBlock title="Exemplo de Uso" variant="code">
            <CodeBlock
              language="javascript"
              filename="ai-service.js"
              :code="aiServiceCode"
            />
          </DocBlock>
        </DocSection>

        <!-- Financial Section -->
        <DocSection id="financial">
          <DocHeader
            title="💰 Módulo Financeiro"
            description="Controle completo de receitas, despesas e fluxo de caixa"
            :badges="[{ text: 'Novo Módulo', type: 'success' }]"
          />

          <DocBlock title="Funcionalidades Financeiras" variant="success" :icon="DollarSign">
            <ul>
              <li><strong>Receitas:</strong> Vendas, entrada de caixa</li>
              <li><strong>Despesas:</strong> Compras, custos operacionais</li>
              <li><strong>Fluxo de Caixa:</strong> Projeções e relatórios</li>
              <li><strong>Categorização:</strong> Organização por tipo</li>
              <li><strong>Relatórios:</strong> DRE, Balanço, Fluxo</li>
              <li><strong>Gráficos:</strong> Visualização de tendências</li>
            </ul>
          </DocBlock>

          <DocBlock title="Estrutura das Tabelas">
            <CodeBlock
              language="sql"
              filename="financial.sql"
              :code="financialSqlCode"
            />
          </DocBlock>
        </DocSection>

        <!-- API Reference Section -->
        <DocSection id="api-overview">
          <DocHeader
            title="🔌 API Reference"
            description="Documentação completa das APIs do sistema"
          />

          <DocBlock title="Autenticação" variant="warning" :icon="Shield">
            <p>Todas as APIs requerem autenticação via Supabase JWT Token:</p>
            <CodeBlock
              language="javascript"
              filename="auth-example.js"
              :code="authExampleCode"
            />
          </DocBlock>

          <DocBlock title="Endpoints Principais" variant="info">
            <div class="api-endpoints">
              <div class="endpoint-group">
                <h4>Produtos</h4>
                <div class="endpoint"><span class="method get">GET</span> /api/products</div>
                <div class="endpoint"><span class="method post">POST</span> /api/products</div>
                <div class="endpoint"><span class="method put">PUT</span> /api/products/:id</div>
                <div class="endpoint"><span class="method delete">DELETE</span> /api/products/:id</div>
              </div>

              <div class="endpoint-group">
                <h4>Movimentações</h4>
                <div class="endpoint"><span class="method get">GET</span> /api/movements</div>
                <div class="endpoint"><span class="method post">POST</span> /api/movements</div>
              </div>

              <div class="endpoint-group">
                <h4>Relatórios</h4>
                <div class="endpoint"><span class="method get">GET</span> /api/reports/inventory</div>
                <div class="endpoint"><span class="method get">GET</span> /api/reports/financial</div>
              </div>

              <div class="endpoint-group">
                <h4>Dashboard</h4>
                <div class="endpoint"><span class="method get">GET</span> /api/dashboard/stats</div>
                <div class="endpoint"><span class="method get">GET</span> /api/database/stats</div>
              </div>
            </div>
          </DocBlock>

          <DocBlock title="Códigos de Status HTTP">
            <div class="status-codes">
              <div class="status-item success">
                <span class="code">200</span>
                <span class="description">Sucesso - Operação realizada com sucesso</span>
              </div>
              <div class="status-item success">
                <span class="code">201</span>
                <span class="description">Criado - Recurso criado com sucesso</span>
              </div>
              <div class="status-item error">
                <span class="code">400</span>
                <span class="description">Bad Request - Dados inválidos</span>
              </div>
              <div class="status-item error">
                <span class="code">401</span>
                <span class="description">Unauthorized - Token inválido ou expirado</span>
              </div>
              <div class="status-item error">
                <span class="code">404</span>
                <span class="description">Not Found - Recurso não encontrado</span>
              </div>
              <div class="status-item error">
                <span class="code">500</span>
                <span class="description">Internal Server Error - Erro interno</span>
              </div>
            </div>
          </DocBlock>
        </DocSection>

        <!-- Tech Stack Section -->
        <DocSection id="tech-stack">
          <DocHeader
            title="🛠 Stack Tecnológica"
            description="Tecnologias e ferramentas utilizadas no projeto"
          />

          <DocBlock title="Frontend" variant="info" :icon="Globe">
            <div class="tech-grid">
              <div class="tech-item">
                <strong>Vue.js 3</strong>
                <p>Framework principal com Composition API</p>
              </div>
              <div class="tech-item">
                <strong>TypeScript</strong>
                <p>Tipagem estática e melhor DX</p>
              </div>
              <div class="tech-item">
                <strong>Vite</strong>
                <p>Build tool e dev server</p>
              </div>
              <div class="tech-item">
                <strong>Vue Router</strong>
                <p>Roteamento SPA</p>
              </div>
              <div class="tech-item">
                <strong>Pinia</strong>
                <p>Gerenciamento de estado</p>
              </div>
              <div class="tech-item">
                <strong>Chart.js</strong>
                <p>Gráficos e visualizações</p>
              </div>
            </div>
          </DocBlock>

          <DocBlock title="Backend & Database" variant="success" :icon="Database">
            <div class="tech-grid">
              <div class="tech-item">
                <strong>Supabase</strong>
                <p>Backend-as-a-Service completo</p>
              </div>
              <div class="tech-item">
                <strong>PostgreSQL</strong>
                <p>Banco de dados relacional</p>
              </div>
              <div class="tech-item">
                <strong>Row Level Security</strong>
                <p>Segurança nível de linha</p>
              </div>
              <div class="tech-item">
                <strong>Supabase Storage</strong>
                <p>Armazenamento de arquivos</p>
              </div>
              <div class="tech-item">
                <strong>Real-time</strong>
                <p>Atualizações em tempo real</p>
              </div>
            </div>
          </DocBlock>

          <DocBlock title="Integrações" variant="warning" :icon="Zap">
            <div class="tech-grid">
              <div class="tech-item">
                <strong>Google Gemini AI</strong>
                <p>Assistente inteligente</p>
              </div>
              <div class="tech-item">
                <strong>Lucide Icons</strong>
                <p>Ícones consistentes</p>
              </div>
              <div class="tech-item">
                <strong>Inter Font</strong>
                <p>Tipografia moderna</p>
              </div>
            </div>
          </DocBlock>
        </DocSection>

        <!-- Search Results -->
        <div v-if="searchQuery && searchResults.length > 0" class="search-results">
          <h2>Resultados da Busca</h2>
          <div class="results-list">
            <div v-for="result in searchResults" :key="result.id" class="search-result-item">
              <h3>{{ result.title }}</h3>
              <p>{{ result.excerpt }}</p>
              <button @click="scrollTo(result.id)" class="result-link">Ver seção</button>
            </div>
          </div>
        </div>
      </main>
    </div>

    <!-- API Playground Modal -->
    <APIPlayground v-if="showAPIPlayground" @close="showAPIPlayground = false" />

    <!-- Floating Action Button -->
    <div class="floating-actions">
      <button @click="scrollToTop" class="fab-btn" title="Voltar ao topo">
        <ArrowUp :size="20" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import {
  FileText, Search, Sun, Moon, Terminal, Menu, Zap, Map, Server, Layers, Code,
  Package, Brain, DollarSign, BarChart3, ArrowUp, Shield, Globe, Database
} from 'lucide-vue-next'

// Components
import DocSection from '@/components/docs/DocSection.vue'
import DocHeader from '@/components/docs/DocHeader.vue'
import DocBlock from '@/components/docs/DocBlock.vue'
import CodeBlock from '@/components/docs/CodeBlock.vue'
import APIPlayground from '@/components/docs/APIPlayground.vue'

// Estados reativos
const searchQuery = ref('')
const sidebarCollapsed = ref(false)
const isDarkMode = ref(false)
const showAPIPlayground = ref(false)
const searchResults = ref<any[]>([])

// Computed
const filteredSections = computed(() => {
  // Retornar seções filtradas baseado na busca
  return []
})

// Code examples
const architectureDiagram = `
graph TD
    A[Frontend Vue.js] --> B[Supabase Database]
    A --> C[Google Gemini AI]
    A --> D[Supabase Storage]
    B --> E[PostgreSQL]
    B --> F[Row Level Security]
    A --> G[Chart.js Visualizations]
`

const installationSteps = `# Clonar repositório
git clone https://github.com/your-repo/gestaozesystem-web.git
cd gestaozesystem-web

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas credenciais

# Executar em desenvolvimento
npm run dev

# Build para produção
npm run build`

const envExample = `# Supabase Configuration
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
VITE_SUPABASE_PROJECT_ID=your-project-id

# Google Gemini AI Configuration
VITE_GEMINI_API_KEY=your-gemini-api-key
VITE_GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent

# App Configuration
VITE_APP_NAME=GestaoZe System
VITE_APP_VERSION=1.0.0`

const dashboardApiCode = `// Estatísticas gerais
GET /api/dashboard/stats

// Movimentações recentes
GET /api/movements?limit=10&order=desc

// Status do banco de dados
GET /api/database/stats`

const sqlProductsCode = `CREATE TABLE produtos (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2),
    categoria_id BIGINT REFERENCES categorias(id),
    quantidade_estoque INTEGER DEFAULT 0,
    quantidade_minima INTEGER DEFAULT 0,
    codigo_barras VARCHAR(100),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);`

const inventoryApiCode = `// Listar produtos
GET /api/products?page=1&limit=20&category=1

// Criar produto
POST /api/products
{
  "nome": "Produto Exemplo",
  "descricao": "Descrição",
  "preco": 10.99,
  "categoria_id": 1,
  "quantidade_estoque": 100
}

// Atualizar produto
PUT /api/products/:id

// Deletar produto
DELETE /api/products/:id

// Movimentação de estoque
POST /api/movements
{
  "produto_id": 1,
  "tipo": "entrada",
  "quantidade": 50,
  "observacoes": "Compra"
}`

const aiConfigCode = `# Google Gemini AI Configuration
VITE_GEMINI_API_KEY=your-api-key
VITE_GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent`

const aiServiceCode = `import { aiService } from '@/services/aiService'

// Análise de vendas
const analysis = await aiService.analyzeData({
  type: 'sales',
  period: 'last-month',
  products: productData
})

// Chat com IA
const response = await aiService.chat({
  message: 'Qual produto tem maior rotatividade?',
  context: inventoryData
})`

const financialSqlCode = `-- Transações financeiras
CREATE TABLE financial_transactions (
    id BIGSERIAL PRIMARY KEY,
    type VARCHAR(20) CHECK (type IN ('receita', 'despesa')),
    category VARCHAR(100),
    description TEXT,
    amount DECIMAL(15,2) NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Categorias financeiras
CREATE TABLE financial_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('receita', 'despesa')),
    color VARCHAR(7),
    created_at TIMESTAMP DEFAULT NOW()
);`

const authExampleCode = `// Headers obrigatórios
const headers = {
  'Authorization': 'Bearer YOUR_JWT_TOKEN',
  'Content-Type': 'application/json',
  'apikey': 'YOUR_SUPABASE_ANON_KEY'
}

// Exemplo de requisição
const response = await fetch('/api/products', {
  headers,
  method: 'GET'
})`

// Funções
function toggleTheme() {
  isDarkMode.value = !isDarkMode.value
  document.documentElement.classList.toggle('dark-theme', isDarkMode.value)
}

function scrollTo(elementId: string) {
  const element = document.getElementById(elementId)
  if (element) {
    element.scrollIntoView({ behavior: 'smooth' })
  }
}

function scrollToTop() {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function handleSearch() {
  if (!searchQuery.value.trim()) {
    searchResults.value = []
    return
  }

  // Implementar busca na documentação
  // Por enquanto, exemplo estático
  searchResults.value = [
    {
      id: 'getting-started',
      title: 'Primeiros Passos',
      excerpt: 'Guia completo para começar com o sistema...'
    }
  ]
}

// Keyboard shortcuts
function handleKeydown(event: KeyboardEvent) {
  if (event.ctrlKey && event.key === 'k') {
    event.preventDefault()
    const searchInput = document.querySelector('.search-input') as HTMLInputElement
    searchInput?.focus()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)

  // Detectar preferência de tema
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  isDarkMode.value = prefersDark

  if (isDarkMode.value) {
    document.documentElement.classList.add('dark-theme')
  }
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.documentation-view {
  min-height: 100vh;
  background: var(--docs-bg, #fafbfc);
  color: var(--docs-text, #1a202c);
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
}

/* Header */
.docs-header {
  background: var(--docs-header-bg, #ffffff);
  border-bottom: 1px solid var(--docs-border, #e2e8f0);
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo-section svg {
  color: var(--docs-primary, #667eea);
}

.title-group h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--docs-text, #1a202c);
}

.title-group p {
  margin: 0;
  font-size: 0.875rem;
  color: var(--docs-text-muted, #64748b);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.search-container {
  position: relative;
  display: flex;
  align-items: center;
}

.search-input {
  width: 320px;
  padding: 0.75rem 1rem 0.75rem 3rem;
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 12px;
  background: var(--docs-input-bg, #ffffff);
  color: var(--docs-text, #1a202c);
  font-size: 0.875rem;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: var(--docs-primary, #667eea);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.search-container svg {
  position: absolute;
  left: 1rem;
  color: var(--docs-text-muted, #64748b);
  pointer-events: none;
}

.search-shortcut {
  position: absolute;
  right: 1rem;
  background: var(--docs-kbd-bg, #f1f5f9);
  color: var(--docs-text-muted, #64748b);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-family: monospace;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.theme-toggle,
.api-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 10px;
  background: var(--docs-button-bg, #ffffff);
  color: var(--docs-text, #1a202c);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.theme-toggle:hover,
.api-btn:hover {
  border-color: var(--docs-primary, #667eea);
  background: var(--docs-primary, #667eea);
  color: white;
  transform: translateY(-2px);
}

/* Container */
.docs-container {
  max-width: 1400px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 0;
  min-height: calc(100vh - 80px);
}

/* Sidebar */
.docs-sidebar {
  background: var(--docs-sidebar-bg, #ffffff);
  border-right: 1px solid var(--docs-border, #e2e8f0);
  position: sticky;
  top: 80px;
  height: calc(100vh - 80px);
  overflow-y: auto;
  transition: all 0.3s ease;
}

.docs-sidebar.collapsed {
  grid-template-columns: 60px 1fr;
  width: 60px;
}

.sidebar-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  border-bottom: 1px solid var(--docs-border, #e2e8f0);
  font-weight: 600;
  color: var(--docs-text, #1a202c);
}

.collapse-btn {
  background: none;
  border: none;
  padding: 0.5rem;
  border-radius: 8px;
  cursor: pointer;
  color: var(--docs-text-muted, #64748b);
  transition: all 0.2s ease;
}

.collapse-btn:hover {
  background: var(--docs-hover, #f1f5f9);
  color: var(--docs-text, #1a202c);
}

.sidebar-content {
  padding: 1rem;
}

.nav-section {
  margin-bottom: 2rem;
}

.nav-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0 0 1rem 0;
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--docs-text, #1a202c);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.nav-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-list li {
  margin-bottom: 0.5rem;
}

.nav-list a {
  display: block;
  padding: 0.5rem 1rem;
  color: var(--docs-text-muted, #64748b);
  text-decoration: none;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.nav-list a:hover {
  background: var(--docs-hover, #f1f5f9);
  color: var(--docs-primary, #667eea);
  transform: translateX(4px);
}

/* Main Content */
.docs-content {
  padding: 2rem;
  max-width: 800px;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
  margin: 2rem 0;
}

.feature-card {
  padding: 1.5rem;
  background: var(--docs-card-bg, #ffffff);
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 16px;
  text-align: center;
  transition: all 0.3s ease;
}

.feature-card:hover {
  border-color: var(--docs-primary, #667eea);
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
}

.feature-card svg {
  color: var(--docs-primary, #667eea);
  margin-bottom: 1rem;
}

.feature-card h4 {
  margin: 0 0 0.5rem 0;
  color: var(--docs-text, #1a202c);
  font-weight: 600;
}

.feature-card p {
  margin: 0;
  color: var(--docs-text-muted, #64748b);
  font-size: 0.875rem;
  line-height: 1.5;
}

.requirements-list {
  list-style: none;
  padding: 0;
  margin: 1rem 0;
}

.requirements-list li {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  background: var(--docs-code-bg, #f8fafc);
  border-radius: 8px;
}

.requirements-list li:before {
  content: '✓';
  color: var(--docs-success, #10b981);
  font-weight: bold;
}

.requirements-list code {
  background: var(--docs-primary, #667eea);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Fira Code', monospace;
  font-size: 0.875rem;
}

/* Search Results */
.search-results {
  margin-top: 2rem;
  padding: 2rem;
  background: var(--docs-card-bg, #ffffff);
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 16px;
}

.results-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.search-result-item {
  padding: 1.5rem;
  background: var(--docs-hover, #f1f5f9);
  border-radius: 12px;
}

.search-result-item h3 {
  margin: 0 0 0.5rem 0;
  color: var(--docs-primary, #667eea);
}

.search-result-item p {
  margin: 0 0 1rem 0;
  color: var(--docs-text-muted, #64748b);
}

.result-link {
  background: var(--docs-primary, #667eea);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
}

.result-link:hover {
  background: var(--docs-primary-dark, #5a67d8);
  transform: translateY(-2px);
}

/* Floating Actions */
.floating-actions {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  z-index: 50;
}

.fab-btn {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: var(--docs-primary, #667eea);
  color: white;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
  transition: all 0.3s ease;
}

.fab-btn:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px rgba(102, 126, 234, 0.6);
}

/* Dark Theme */
:global(.dark-theme) {
  --docs-bg: #0f172a;
  --docs-text: #f1f5f9;
  --docs-text-muted: #94a3b8;
  --docs-header-bg: #1e293b;
  --docs-sidebar-bg: #1e293b;
  --docs-card-bg: #334155;
  --docs-input-bg: #334155;
  --docs-button-bg: #334155;
  --docs-border: #475569;
  --docs-hover: #475569;
  --docs-code-bg: #475569;
  --docs-kbd-bg: #475569;
}

/* Estilos específicos da documentação */
.component-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin: 1rem 0;
}

.component-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  background: var(--docs-hover, #f8fafc);
  border-radius: 8px;
  font-size: 0.875rem;
}

.component-item code {
  background: var(--docs-primary, #667eea);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Fira Code', monospace;
  font-size: 0.8rem;
  font-weight: 600;
}

.api-endpoints {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin: 1.5rem 0;
}

.endpoint-group h4 {
  margin: 0 0 1rem 0;
  color: var(--docs-text, #1a202c);
  font-weight: 600;
  font-size: 1.125rem;
}

.endpoint {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  background: var(--docs-hover, #f8fafc);
  border-radius: 8px;
  margin-bottom: 0.5rem;
  font-family: 'Fira Code', monospace;
  font-size: 0.875rem;
}

.method {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-weight: 700;
  font-size: 0.75rem;
  text-transform: uppercase;
  min-width: 60px;
  text-align: center;
}

.method.get { background: #10b981; color: white; }
.method.post { background: #3b82f6; color: white; }
.method.put { background: #f59e0b; color: white; }
.method.delete { background: #ef4444; color: white; }

.status-codes {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin: 1.5rem 0;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-radius: 8px;
  background: var(--docs-hover, #f8fafc);
}

.status-item.success {
  border-left: 4px solid #10b981;
  background: rgba(16, 185, 129, 0.05);
}

.status-item.error {
  border-left: 4px solid #ef4444;
  background: rgba(239, 68, 68, 0.05);
}

.status-item .code {
  font-family: 'Fira Code', monospace;
  font-weight: 700;
  font-size: 1rem;
  color: var(--docs-text, #1a202c);
  min-width: 50px;
}

.status-item .description {
  color: var(--docs-text-muted, #64748b);
  font-size: 0.875rem;
}

.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 1.5rem 0;
}

.tech-item {
  padding: 1.5rem;
  background: var(--docs-hover, #f8fafc);
  border-radius: 12px;
  text-align: center;
  transition: all 0.3s ease;
}

.tech-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.tech-item strong {
  display: block;
  color: var(--docs-primary, #667eea);
  font-size: 1.125rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.tech-item p {
  margin: 0;
  color: var(--docs-text-muted, #64748b);
  font-size: 0.875rem;
  line-height: 1.4;
}

/* Responsividade */
@media (max-width: 1024px) {
  .docs-container {
    grid-template-columns: 1fr;
  }

  .docs-sidebar {
    display: none;
  }

  .search-input {
    width: 240px;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .api-endpoints {
    grid-template-columns: 1fr;
  }

  .tech-grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }

  .header-right {
    width: 100%;
    justify-content: space-between;
  }

  .search-container {
    flex: 1;
    margin-right: 1rem;
  }

  .search-input {
    width: 100%;
  }

  .docs-content {
    padding: 1rem;
  }

  .tech-grid {
    grid-template-columns: 1fr;
  }

  .status-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .endpoint {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>