<template>
  <div class="ai-container">
    <!-- Header Principal -->
    <div class="ai-header">
      <div class="header-main">
        <div class="header-left">
          <div class="title-section">
            <h1 class="page-title">
              <Brain :size="32" />
              Inteligência Artificial Avançada
            </h1>
            <p class="page-subtitle">Insights poderosos e análises profissionais para maximizar seus resultados</p>
          </div>
        </div>
        <div class="header-actions">
          <div class="stat-card primary">
            <div class="stat-icon">
              <Zap :size="20" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ analysisCount }}</div>
              <div class="stat-label">Análises</div>
            </div>
          </div>
          <div class="stat-card success">
            <div class="stat-icon">
              <Clock :size="20" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatTime(lastUpdate) }}</div>
              <div class="stat-label">Última Análise</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="ai-content">
      <!-- Análises Inteligentes -->
      <section class="intelligent-analysis-section">
        <div class="section-header">
          <div class="section-title">
            <h2>
              <Sparkles :size="24" />
              Análises Inteligentes
            </h2>
            <p>Insights baseados em IA para otimizar sua operação</p>
          </div>
          <div class="section-actions">
            <button @click="runAllAnalysis" :disabled="isAnyLoading" class="btn-primary">
              <Zap :size="16" />
              Executar Todas
            </button>
          </div>
        </div>

        <div class="analysis-grid">
          <div
            class="analysis-card inventory"
            @click="runInventoryAnalysis"
            :class="{ 'loading': loading.inventory, 'completed': analyses.inventory }"
          >
            <div class="card-status">
              <div class="status-indicator"></div>
            </div>
            <div class="card-icon">
              <Package :size="28" />
            </div>
            <div class="card-content">
              <div class="card-title">
                <h3>Análise de Estoque</h3>
                <button :disabled="loading.inventory" class="run-btn">
                  <Loader2 v-if="loading.inventory" :size="18" class="animate-spin" />
                  <PlayCircle v-else :size="18" />
                </button>
              </div>
              <p>Avaliação completa do inventário com insights estratégicos</p>
              <div class="card-metrics">
                <div class="metric">
                  <AlertTriangle :size="14" />
                  <span>Produtos críticos</span>
                </div>
                <div class="metric">
                  <DollarSign :size="14" />
                  <span>Otimização de custos</span>
                </div>
                <div class="metric">
                  <TrendingUp :size="14" />
                  <span>Ações prioritárias</span>
                </div>
              </div>
            </div>
          </div>

          <div
            class="analysis-card purchase"
            @click="runPurchaseSuggestions"
            :class="{ 'loading': loading.purchase, 'completed': analyses.purchase }"
          >
            <div class="card-status">
              <div class="status-indicator"></div>
            </div>
            <div class="card-icon">
              <ShoppingCart :size="28" />
            </div>
            <div class="card-content">
              <div class="card-title">
                <h3>Sugestões de Compra</h3>
                <button :disabled="loading.purchase" class="run-btn">
                  <Loader2 v-if="loading.purchase" :size="18" class="animate-spin" />
                  <PlayCircle v-else :size="18" />
                </button>
              </div>
              <p>Recomendações inteligentes baseadas em padrões de consumo</p>
              <div class="card-metrics">
                <div class="metric">
                  <ListChecks :size="14" />
                  <span>Lista prioritária</span>
                </div>
                <div class="metric">
                  <Calendar :size="14" />
                  <span>Planejamento semanal</span>
                </div>
                <div class="metric">
                  <Target :size="14" />
                  <span>Oportunidades</span>
                </div>
              </div>
            </div>
          </div>

          <div
            class="analysis-card menu"
            @click="runMenuOptimization"
            :class="{ 'loading': loading.menu, 'completed': analyses.menu }"
          >
            <div class="card-status">
              <div class="status-indicator"></div>
            </div>
            <div class="card-icon">
              <ChefHat :size="28" />
            </div>
            <div class="card-content">
              <div class="card-title">
                <h3>Otimização do Cardápio</h3>
                <button :disabled="loading.menu" class="run-btn">
                  <Loader2 v-if="loading.menu" :size="18" class="animate-spin" />
                  <PlayCircle v-else :size="18" />
                </button>
              </div>
              <p>Análise profunda para maximizar lucros e reduzir desperdícios</p>
              <div class="card-metrics">
                <div class="metric">
                  <PieChart :size="14" />
                  <span>Pratos rentáveis</span>
                </div>
                <div class="metric">
                  <Recycle :size="14" />
                  <span>Aproveitamento</span>
                </div>
                <div class="metric">
                  <Lightbulb :size="14" />
                  <span>Recomendações</span>
                </div>
              </div>
            </div>
          </div>

          <div
            class="analysis-card financial"
            @click="runFinancialAnalysis"
            :class="{ 'loading': loading.financial, 'completed': analyses.financial }"
          >
            <div class="card-status">
              <div class="status-indicator"></div>
            </div>
            <div class="card-icon">
              <DollarSign :size="28" />
            </div>
            <div class="card-content">
              <div class="card-title">
                <h3>Análise Financeira</h3>
                <button :disabled="loading.financial" class="run-btn">
                  <Loader2 v-if="loading.financial" :size="18" class="animate-spin" />
                  <PlayCircle v-else :size="18" />
                </button>
              </div>
              <p>Insights sobre receitas, custos operacionais e otimização financeira</p>
              <div class="card-metrics">
                <div class="metric">
                  <TrendingUp :size="14" />
                  <span>Crescimento de receitas</span>
                </div>
                <div class="metric">
                  <Users :size="14" />
                  <span>Custos de pessoal</span>
                </div>
                <div class="metric">
                  <Target :size="14" />
                  <span>Eficiência operacional</span>
                </div>
              </div>
            </div>
          </div>

          <div
            class="analysis-card performance"
            @click="runPerformanceAnalysis"
            :class="{ 'loading': loading.performance, 'completed': analyses.performance }"
          >
            <div class="card-status">
              <div class="status-indicator"></div>
            </div>
            <div class="card-icon">
              <BarChart3 :size="28" />
            </div>
            <div class="card-content">
              <div class="card-title">
                <h3>Análise de Performance</h3>
                <button :disabled="loading.performance" class="run-btn">
                  <Loader2 v-if="loading.performance" :size="18" class="animate-spin" />
                  <PlayCircle v-else :size="18" />
                </button>
              </div>
              <p>Métricas detalhadas de desempenho operacional</p>
              <div class="card-metrics">
                <div class="metric">
                  <Activity :size="14" />
                  <span>KPIs principais</span>
                </div>
                <div class="metric">
                  <TrendingDown :size="14" />
                  <span>Pontos de melhoria</span>
                </div>
                <div class="metric">
                  <Star :size="14" />
                  <span>Benchmarks</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Analysis Results -->
      <section v-if="hasResults" class="results-section">
        <h2>
          <BarChart3 :size="24" />
          Resultados das Análises
        </h2>
        <div class="results-tabs">
          <button
            v-for="tab in availableTabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            :class="{ active: activeTab === tab.id }"
            class="tab-button"
          >
            <component :is="tab.icon" :size="16" />
            {{ tab.label }}
          </button>
        </div>

        <div class="result-content">
          <div v-if="activeTabData" class="analysis-result">
            <div class="result-header">
              <h3>{{ activeTabData.title }}</h3>
              <div class="result-actions">
                <button @click="exportAnalysis(activeTab)" class="export-btn">
                  <Download :size="16" />
                  Exportar
                </button>
                <button @click="shareAnalysis(activeTab)" class="share-btn">
                  <Share2 :size="16" />
                  Compartilhar
                </button>
              </div>
            </div>
            <div class="result-body" v-html="formatMarkdown(activeTabData.content)"></div>
          </div>
        </div>
      </section>

      <!-- AI Chat Assistant -->
      <section class="chat-section">
        <h2>
          <MessageCircle :size="24" />
          Assistente IA Personalizado
        </h2>

        <div class="chat-container">
          <div class="chat-messages" ref="chatMessagesRef">
            <!-- Welcome Message -->
            <div v-if="chatHistory.length === 0" class="welcome-message">
              <div class="welcome-avatar">
                <Bot :size="32" />
              </div>
              <div class="welcome-content">
                <h3>👋 Olá! Sou seu assistente de gestão inteligente</h3>
                <p>Estou aqui para ajudar você a otimizar seu restaurante. Posso responder perguntas sobre:</p>
                <div class="capabilities-grid">
                  <div class="capability-item">
                    <Package :size="20" />
                    <span>Gestão de Estoque</span>
                  </div>
                  <div class="capability-item">
                    <TrendingUp :size="20" />
                    <span>Análise de Vendas</span>
                  </div>
                  <div class="capability-item">
                    <Calculator :size="20" />
                    <span>Controle de Custos</span>
                  </div>
                  <div class="capability-item">
                    <ChefHat :size="20" />
                    <span>Otimização do Cardápio</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Chat Messages -->
            <div
              v-for="(message, index) in chatHistory"
              :key="index"
              class="chat-message"
              :class="{ 'user-message': message.type === 'user', 'ai-message': message.type === 'ai' }"
            >
              <div class="message-avatar">
                <User v-if="message.type === 'user'" :size="20" />
                <Bot v-else :size="20" />
              </div>
              <div class="message-content">
                <div class="message-text">
                  <div v-if="message.type === 'ai'" v-html="formatMarkdown(message.content)"></div>
                  <div v-else>{{ message.content }}</div>
                </div>
                <div class="message-meta">
                  <time>{{ formatTime(message.timestamp) }}</time>
                  <button v-if="message.type === 'ai'" @click="copyMessage(message.content)" class="copy-btn">
                    <Copy :size="12" />
                  </button>
                </div>
              </div>
            </div>

            <!-- Typing Indicator -->
            <div v-if="loading.chat" class="chat-message ai-message">
              <div class="message-avatar">
                <Bot :size="20" />
              </div>
              <div class="message-content">
                <div class="typing-indicator">
                  <span></span>
                  <span></span>
                  <span></span>
                </div>
                <div class="typing-text">O assistente está pensando...</div>
              </div>
            </div>
          </div>

          <!-- Quick Suggestions -->
          <div v-if="chatHistory.length === 0" class="quick-suggestions">
            <h4>💡 Perguntas Populares</h4>
            <div class="suggestions-grid">
              <button
                v-for="suggestion in quickSuggestions"
                :key="suggestion.text"
                @click="askQuickQuestion(suggestion.text)"
                :disabled="loading.chat"
                class="suggestion-chip"
              >
                <span class="suggestion-icon">{{ suggestion.icon }}</span>
                <span class="suggestion-text">{{ suggestion.text }}</span>
              </button>
            </div>
          </div>

          <!-- Chat Input -->
          <form @submit.prevent="sendMessage" class="chat-input-container">
            <div class="input-wrapper">
              <div class="input-area">
                <textarea
                  v-model="currentMessage"
                  ref="chatInputRef"
                  placeholder="Digite sua pergunta ou solicite uma análise..."
                  :disabled="loading.chat"
                  class="chat-input"
                  rows="1"
                  @keydown.enter.exact.prevent="sendMessage"
                  @input="adjustTextareaHeight"
                ></textarea>
                <div class="input-actions">
                  <button
                    type="button"
                    @click="clearChat"
                    class="clear-btn"
                    title="Limpar conversa"
                  >
                    <Trash2 :size="16" />
                  </button>
                  <button
                    type="submit"
                    :disabled="!currentMessage.trim() || loading.chat"
                    class="send-btn"
                  >
                    <Send :size="16" />
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </section>

      <!-- Error Toast -->
      <Transition name="toast">
        <div v-if="errorMessage" class="error-toast">
          <AlertCircle :size="20" />
          <span>{{ errorMessage }}</span>
          <button @click="errorMessage = ''" class="close-btn">
            <X :size="16" />
          </button>
        </div>
      </Transition>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { aiService } from '@/services/aiService'
import { productService } from '@/services/productService'
import {
  Brain, Sparkles, Package, ShoppingCart, ChefHat, PlayCircle, Loader2,
  BarChart3, Download, Share2, MessageCircle, Bot, User, Copy, Trash2,
  Send, AlertCircle, X, Zap, Clock, TrendingUp, Calculator, AlertTriangle,
  DollarSign, ListChecks, Calendar, Target, PieChart, Recycle, Lightbulb,
  Activity, TrendingDown, Star
} from 'lucide-vue-next'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'

interface ChatMessage {
  type: 'user' | 'ai'
  content: string
  timestamp: Date
}

interface AnalysisResult {
  id: string
  title: string
  content: string
  timestamp: Date
}

// Refs
const chatMessagesRef = ref<HTMLElement>()
const chatInputRef = ref<HTMLTextAreaElement>()

// State
const loading = ref({
  inventory: false,
  purchase: false,
  menu: false,
  performance: false,
  financial: false,
  chat: false
})

const analyses = ref<Record<string, AnalysisResult>>({})
const chatHistory = ref<ChatMessage[]>([])
const currentMessage = ref('')
const activeTab = ref('inventory')
const errorMessage = ref('')
const analysisCount = ref(0)
const lastUpdate = ref(new Date())

// Quick suggestions expandidas e profissionais
const quickSuggestions = [
  { icon: '📦', text: 'Quais produtos estão com estoque crítico e precisam de reposição imediata?' },
  { icon: '💰', text: 'Analise o ROI dos meus produtos e identifique oportunidades de melhoria' },
  { icon: '🎯', text: 'Crie um plano estratégico de compras baseado em previsão de demanda' },
  { icon: '📊', text: 'Gere um dashboard executivo com KPIs de performance do negócio' },
  { icon: '🍽️', text: 'Otimize meu cardápio para maximizar lucro e reduzir desperdícios' },
  { icon: '⚡', text: 'Liste ações prioritárias para otimizar a operação hoje mesmo' },
  { icon: '📈', text: 'Identifique tendências de consumo e padrões de compra dos clientes' },
  { icon: '🔍', text: 'Analise produtos com baixa rotatividade e sugira estratégias' },
  { icon: '⚖️', text: 'Compare custos vs preços de venda e otimize margens de lucro' },
  { icon: '🎨', text: 'Sugira combinações de produtos para aumentar ticket médio' },
  { icon: '📅', text: 'Crie um cronograma inteligente de compras para o próximo mês' },
  { icon: '💡', text: 'Identifique oportunidades de inovação no meu mix de produtos' }
]

// Computed
const hasResults = computed(() => Object.keys(analyses.value).length > 0)
const isAnyLoading = computed(() => Object.values(loading.value).some(Boolean))

const availableTabs = computed(() => {
  const tabs = []
  if (analyses.value.inventory) {
    tabs.push({ id: 'inventory', label: 'Estoque', icon: Package })
  }
  if (analyses.value.purchase) {
    tabs.push({ id: 'purchase', label: 'Compras', icon: ShoppingCart })
  }
  if (analyses.value.menu) {
    tabs.push({ id: 'menu', label: 'Cardápio', icon: ChefHat })
  }
  if (analyses.value.performance) {
    tabs.push({ id: 'performance', label: 'Performance', icon: BarChart3 })
  }
  return tabs
})

const activeTabData = computed(() => analyses.value[activeTab.value])

// Methods
async function runInventoryAnalysis() {
  if (loading.value.inventory) return

  loading.value.inventory = true
  errorMessage.value = ''

  try {
    const products = await productService.getProducts()
    const categories = await productService.getCategories()

    const inventoryData = {
      totalProducts: products.length,
      lowStockProducts: products.filter(p => p.current_stock <= p.min_stock),
      outOfStockProducts: products.filter(p => p.current_stock === 0),
      totalValue: products.reduce((acc, p) => acc + (p.preco * p.current_stock), 0),
      averageStockLevel: products.reduce((acc, p) => acc + p.current_stock, 0) / products.length,
      categories: categories,
      products: products.slice(0, 20) // Limit for API
    }

    const analysis = await aiService.analyzeInventory(inventoryData)

    analyses.value.inventory = {
      id: 'inventory',
      title: 'Análise de Estoque',
      content: analysis,
      timestamp: new Date()
    }

    analysisCount.value++
    lastUpdate.value = new Date()

    if (!hasResults.value) {
      activeTab.value = 'inventory'
    }
  } catch (error: any) {
    console.error('Erro na análise de estoque:', error)
    errorMessage.value = error.message || 'Erro ao realizar análise do estoque'
  } finally {
    loading.value.inventory = false
  }
}

async function runPurchaseSuggestions() {
  if (loading.value.purchase) return

  loading.value.purchase = true
  errorMessage.value = ''

  try {
    const products = await productService.getProducts()
    const categories = await productService.getCategories()

    const inventoryData = {
      products: products.slice(0, 20), // Limit for API
      lowStockProducts: products.filter(p => p.current_stock <= p.min_stock),
      categories: categories,
      totalProducts: products.length
    }

    const suggestions = await aiService.generatePurchaseSuggestions(inventoryData)

    analyses.value.purchase = {
      id: 'purchase',
      title: 'Sugestões de Compra',
      content: suggestions,
      timestamp: new Date()
    }

    analysisCount.value++
    lastUpdate.value = new Date()
    activeTab.value = 'purchase'
  } catch (error: any) {
    console.error('Erro nas sugestões de compra:', error)
    errorMessage.value = error.message || 'Erro ao gerar sugestões de compra'
  } finally {
    loading.value.purchase = false
  }
}

async function runMenuOptimization() {
  if (loading.value.menu) return

  loading.value.menu = true
  errorMessage.value = ''

  try {
    const products = await productService.getProducts()
    const categories = await productService.getCategories()

    const menuData = {
      items: [], // Placeholder for menu items
      categories: categories
    }

    const inventoryData = {
      products: products.slice(0, 15), // Limit for API
      lowStockProducts: products.filter(p => p.current_stock <= p.min_stock)
    }

    const optimization = await aiService.suggestMenuOptimization(menuData, inventoryData)

    analyses.value.menu = {
      id: 'menu',
      title: 'Otimização do Cardápio',
      content: optimization,
      timestamp: new Date()
    }

    analysisCount.value++
    lastUpdate.value = new Date()
    activeTab.value = 'menu'
  } catch (error: any) {
    console.error('Erro na otimização do cardápio:', error)
    errorMessage.value = error.message || 'Erro ao otimizar cardápio'
  } finally {
    loading.value.menu = false
  }
}

async function runFinancialAnalysis() {
  if (loading.value.financial) return

  loading.value.financial = true
  errorMessage.value = ''

  try {
    const result = await aiService.analyzeFinancialData()

    analyses.value.financial = {
      id: 'financial',
      title: 'Análise Financeira Completa',
      content: result,
      timestamp: new Date()
    }

    console.log('✅ Análise financeira concluída')

  } catch (error) {
    console.error('❌ Erro na análise financeira:', error)
    errorMessage.value = 'Erro ao executar análise financeira. Verifique a configuração da API.'
  } finally {
    loading.value.financial = false
  }
}

async function runPerformanceAnalysis() {
  if (loading.value.performance) return

  loading.value.performance = true
  errorMessage.value = ''

  try {
    const products = await productService.getProducts()
    const categories = await productService.getCategories()

    const performanceData = {
      totalProducts: products.length,
      activeProducts: products.filter(p => p.current_stock > 0).length,
      totalValue: products.reduce((acc, p) => acc + (p.preco * p.current_stock), 0),
      averageProductValue: products.reduce((acc, p) => acc + p.preco, 0) / products.length,
      categoriesCount: categories.length,
      stockTurnover: products.filter(p => p.current_stock <= p.min_stock).length / products.length,
      profitabilityIndex: products.reduce((acc, p) => acc + ((p.preco - (p.custo || 0)) * p.current_stock), 0),
      criticalProducts: products.filter(p => p.current_stock === 0).length,
      products: products.slice(0, 15) // Limit for API
    }

    const analysis = await aiService.analyzePerformance(performanceData)

    analyses.value.performance = {
      id: 'performance',
      title: 'Análise de Performance',
      content: analysis,
      timestamp: new Date()
    }

    analysisCount.value++
    lastUpdate.value = new Date()
    activeTab.value = 'performance'
  } catch (error: any) {
    console.error('Erro na análise de performance:', error)
    errorMessage.value = error.message || 'Erro ao analisar performance'
  } finally {
    loading.value.performance = false
  }
}

async function runAllAnalysis() {
  if (isAnyLoading.value) return

  // Run all analyses in sequence to avoid overwhelming the API
  await runInventoryAnalysis()
  await new Promise(resolve => setTimeout(resolve, 2000)) // 2s delay
  await runPurchaseSuggestions()
  await new Promise(resolve => setTimeout(resolve, 2000)) // 2s delay
  await runMenuOptimization()
  await new Promise(resolve => setTimeout(resolve, 2000)) // 2s delay
  await runFinancialAnalysis()
  await new Promise(resolve => setTimeout(resolve, 2000)) // 2s delay
  await runPerformanceAnalysis()
}

async function sendMessage() {
  if (!currentMessage.value.trim() || loading.value.chat) return

  const userMessage: ChatMessage = {
    type: 'user',
    content: currentMessage.value.trim(),
    timestamp: new Date()
  }

  chatHistory.value.push(userMessage)
  const question = currentMessage.value.trim()
  currentMessage.value = ''

  await scrollToBottom()

  loading.value.chat = true
  errorMessage.value = ''

  try {
    const products = await productService.getProducts()
    const categories = await productService.getCategories()

    const context = {
      totalProducts: products.length,
      lowStockProducts: products.filter(p => p.current_stock <= p.min_stock),
      categories: categories.slice(0, 10), // Limit context size
      lastAnalyses: Object.keys(analyses.value)
    }

    const response = await aiService.askQuestion(question, context)

    const aiMessage: ChatMessage = {
      type: 'ai',
      content: response,
      timestamp: new Date()
    }

    chatHistory.value.push(aiMessage)
    await scrollToBottom()
  } catch (error: any) {
    console.error('Erro no chat:', error)
    const errorMsg = error.message || 'Erro ao processar sua pergunta'
    errorMessage.value = errorMsg

    const errorChatMessage: ChatMessage = {
      type: 'ai',
      content: `❌ ${errorMsg}\n\nTente reformular sua pergunta ou verifique sua conexão com a internet.`,
      timestamp: new Date()
    }
    chatHistory.value.push(errorChatMessage)
  } finally {
    loading.value.chat = false
    await scrollToBottom()
  }
}

async function askQuickQuestion(question: string) {
  currentMessage.value = question
  await sendMessage()
}

function clearChat() {
  chatHistory.value = []
}

async function scrollToBottom() {
  await nextTick()
  if (chatMessagesRef.value) {
    chatMessagesRef.value.scrollTop = chatMessagesRef.value.scrollHeight
  }
}

function adjustTextareaHeight() {
  if (chatInputRef.value) {
    chatInputRef.value.style.height = 'auto'
    chatInputRef.value.style.height = Math.min(chatInputRef.value.scrollHeight, 120) + 'px'
  }
}

function copyMessage(content: string) {
  navigator.clipboard.writeText(content.replace(/<[^>]*>/g, ''))
    .then(() => {
      // Could show a toast here
    })
    .catch(() => {
      // Fallback copy method
    })
}

function exportAnalysis(type: string) {
  const analysis = analyses.value[type]
  if (analysis) {
    const blob = new Blob([analysis.content], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `analise-${type}-${format(analysis.timestamp, 'yyyy-MM-dd')}.txt`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }
}

function shareAnalysis(type: string) {
  const analysis = analyses.value[type]
  if (analysis && navigator.share) {
    navigator.share({
      title: analysis.title,
      text: analysis.content.substring(0, 100) + '...',
      url: window.location.href
    })
  }
}

function formatMarkdown(text: string): string {
  return text
    // Headers
    .replace(/^### (.*$)/gm, '<h3 class="md-h3">$1</h3>')
    .replace(/^## (.*$)/gm, '<h2 class="md-h2">$1</h2>')
    .replace(/^# (.*$)/gm, '<h1 class="md-h1">$1</h1>')
    // Bold
    .replace(/\*\*(.*?)\*\*/g, '<strong class="md-bold">$1</strong>')
    // Lists
    .replace(/^\- (.*$)/gm, '<li class="md-li">$1</li>')
    .replace(/^(\d+)\. (.*$)/gm, '<li class="md-li">$2</li>')
    // Line breaks
    .replace(/\n\n/g, '<br><br>')
    .replace(/\n/g, '<br>')
    // Wrap lists
    .replace(/(<li class="md-li">.*<\/li>)/gs, '<ul class="md-ul">$1</ul>')
}

function formatTime(date: Date): string {
  return format(date, 'HH:mm', { locale: ptBR })
}

// Auto-clear error messages
watch(errorMessage, (newValue) => {
  if (newValue) {
    setTimeout(() => {
      errorMessage.value = ''
    }, 5000)
  }
})

onMounted(() => {
  // Run initial analysis after 1 second
  setTimeout(() => {
    runInventoryAnalysis()
  }, 1000)
})
</script>

<style scoped>
/* ===== AI VIEW - PROFESSIONAL STYLES ===== */

/* Container Principal */
.ai-container {
  width: 100vw;
  min-height: 100vh;
  background: var(--theme-background);
  overflow-x: hidden;
}

/* ===== HEADER PRINCIPAL ===== */
.ai-header {
  background: var(--theme-surface);
  border-bottom: 1px solid var(--theme-border);
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 10px var(--theme-shadow);
}

.header-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  max-width: none;
}

.header-left .title-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 28px;
  font-weight: 700;
  color: var(--theme-text-primary);
  margin: 0;
}

.page-subtitle {
  color: var(--theme-text-secondary);
  font-size: 14px;
  font-weight: 500;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 16px;
  align-items: center;
}

.stat-card {
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 12px;
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px var(--theme-shadow);
  min-width: 120px;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px var(--theme-shadow);
}

.stat-card.primary .stat-icon {
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
}

.stat-card.success .stat-icon {
  background: linear-gradient(135deg, var(--theme-accent-success), #059669);
}

.stat-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.stat-value {
  font-size: 18px;
  font-weight: 700;
  color: var(--theme-text-primary);
}

.stat-label {
  font-size: 12px;
  color: var(--theme-text-secondary);
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* ===== CONTEÚDO PRINCIPAL ===== */
.ai-content {
  padding: 32px;
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 32px;
}

/* ===== SEÇÃO DE ANÁLISES INTELIGENTES ===== */
.intelligent-analysis-section {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 32px;
  border: 1px solid var(--theme-border);
  box-shadow: 0 4px 12px var(--theme-shadow);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
}

.section-title h2 {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--theme-text-primary);
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 8px 0;
}

.section-title p {
  color: var(--theme-text-secondary);
  font-size: 14px;
  margin: 0;
}

.section-actions .btn-primary {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.section-actions .btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px var(--theme-shadow);
}

.section-actions .btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* ===== GRID DE ANÁLISES ===== */
.analysis-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.analysis-card {
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 16px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px var(--theme-shadow);
  position: relative;
  overflow: hidden;
}

.analysis-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px var(--theme-shadow);
}

.analysis-card.loading {
  opacity: 0.7;
  pointer-events: none;
}

.analysis-card.completed .card-status .status-indicator {
  background: var(--theme-accent-success);
}

.analysis-card.loading .card-status .status-indicator {
  background: var(--theme-accent-warning);
  animation: pulse 2s infinite;
}

.card-status {
  position: absolute;
  top: 16px;
  right: 16px;
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--theme-border);
  transition: all 0.3s ease;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.card-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  margin-bottom: 20px;
}

.analysis-card.inventory .card-icon {
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
}

.analysis-card.purchase .card-icon {
  background: linear-gradient(135deg, var(--theme-accent-warning), #d97706);
}

.analysis-card.menu .card-icon {
  background: linear-gradient(135deg, var(--theme-accent-success), #059669);
}

.analysis-card.financial .card-icon {
  background: linear-gradient(135deg, #10b981, #059669);
}

.analysis-card.performance .card-icon {
  background: linear-gradient(135deg, var(--theme-accent-info), #0ea5e9);
}

.card-content {
  flex: 1;
}

.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.card-title h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: var(--theme-text-primary);
}

.run-btn {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  border: none;
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.1);
  color: var(--theme-primary);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.run-btn:hover:not(:disabled) {
  background: var(--theme-primary);
  color: white;
  transform: scale(1.05);
}

.run-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.card-content p {
  margin: 0 0 16px 0;
  color: var(--theme-text-secondary);
  font-size: 14px;
  line-height: 1.5;
}

.card-metrics {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.metric {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: var(--theme-text-muted);
  font-weight: 500;
}

.metric svg {
  color: var(--theme-primary);
}

/* ===== SEÇÃO DE RESULTADOS ===== */
.results-section {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 32px;
  border: 1px solid var(--theme-border);
  box-shadow: 0 4px 12px var(--theme-shadow);
}

.results-section h2 {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--theme-text-primary);
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 24px 0;
}

.results-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  border-bottom: 1px solid var(--theme-border);
  padding-bottom: 16px;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: var(--theme-surface);
  border: 2px solid var(--theme-border);
  border-radius: 8px;
  color: var(--theme-text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  font-size: 14px;
}

.tab-button:hover {
  background: var(--theme-border);
}

.tab-button.active {
  background: var(--theme-primary);
  color: white;
  border-color: var(--theme-primary);
}

.result-content {
  max-height: 600px;
  overflow-y: auto;
  padding-right: 8px;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.result-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: var(--theme-text-primary);
}

.result-actions {
  display: flex;
  gap: 8px;
}

.export-btn, .share-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.1);
  border: 1px solid rgba(var(--theme-primary-rgb, 102, 126, 234), 0.3);
  border-radius: 8px;
  color: var(--theme-primary);
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  font-weight: 500;
}

.export-btn:hover, .share-btn:hover {
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.2);
}

.result-body {
  line-height: 1.6;
  color: var(--theme-text-primary);
}

/* ===== SEÇÃO DE CHAT ===== */
.chat-section {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 32px;
  border: 1px solid var(--theme-border);
  box-shadow: 0 4px 12px var(--theme-shadow);
}

.chat-section h2 {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--theme-text-primary);
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 24px 0;
}

.chat-container {
  border: 2px solid var(--theme-border);
  border-radius: 16px;
  overflow: hidden;
  background: var(--theme-background-solid);
}

.chat-messages {
  height: 400px;
  overflow-y: auto;
  padding: 24px;
  background: var(--theme-surface);
}

.welcome-message {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  text-align: left;
}

.welcome-avatar {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.welcome-content h3 {
  margin: 0 0 16px 0;
  color: var(--theme-text-primary);
  font-size: 18px;
  font-weight: 700;
}

.welcome-content p {
  margin: 0 0 20px 0;
  color: var(--theme-text-secondary);
  line-height: 1.5;
}

.capabilities-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 12px;
}

.capability-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: var(--theme-surface);
  border-radius: 8px;
  border: 1px solid var(--theme-border);
  font-weight: 500;
  color: var(--theme-text-primary);
  font-size: 14px;
}

.chat-message {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 20px;
}

.chat-message.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.user-message .message-avatar {
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
}

.ai-message .message-avatar {
  background: linear-gradient(135deg, var(--theme-accent-success), #059669);
}

.message-content {
  max-width: 75%;
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 2px 8px var(--theme-shadow);
  border: 1px solid var(--theme-border);
}

.user-message .message-content {
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
  color: white;
}

.message-text {
  line-height: 1.5;
  font-size: 14px;
}

.message-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
  font-size: 12px;
  opacity: 0.7;
}

.copy-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.copy-btn:hover {
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.1);
}

.typing-indicator {
  display: flex;
  gap: 4px;
  margin-bottom: 8px;
}

.typing-indicator span {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--theme-primary);
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator span:nth-child(2) { animation-delay: -0.16s; }

@keyframes typing {
  0%, 80%, 100% { transform: scale(0); opacity: 0.5; }
  40% { transform: scale(1); opacity: 1; }
}

.typing-text {
  font-style: italic;
  color: var(--theme-text-secondary);
  font-size: 14px;
}

.quick-suggestions {
  padding: 24px;
  border-top: 1px solid var(--theme-border);
  background: var(--theme-surface);
}

.quick-suggestions h4 {
  margin: 0 0 16px 0;
  color: var(--theme-text-primary);
  font-size: 16px;
  font-weight: 700;
}

.suggestions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 12px;
}

.suggestion-chip {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.05);
  border: 1px solid rgba(var(--theme-primary-rgb, 102, 126, 234), 0.2);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;
  font-weight: 500;
  color: var(--theme-text-primary);
  font-size: 14px;
}

.suggestion-chip:hover:not(:disabled) {
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.1);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px var(--theme-shadow);
}

.suggestion-chip:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.suggestion-icon {
  font-size: 18px;
  flex-shrink: 0;
}

.chat-input-container {
  border-top: 1px solid var(--theme-border);
  background: var(--theme-surface);
  padding: 20px;
}

.input-area {
  display: flex;
  align-items: flex-end;
  gap: 12px;
  background: var(--theme-background-solid);
  border: 2px solid var(--theme-border);
  border-radius: 12px;
  padding: 12px;
  transition: all 0.3s ease;
}

.input-area:focus-within {
  border-color: var(--theme-primary);
  box-shadow: 0 0 0 3px rgba(var(--theme-primary-rgb, 102, 126, 234), 0.1);
}

.chat-input {
  flex: 1;
  border: none;
  background: none;
  outline: none;
  resize: none;
  font-size: 16px;
  line-height: 1.5;
  color: var(--theme-text-primary);
  font-family: inherit;
  min-height: 20px;
  max-height: 120px;
}

.chat-input::placeholder {
  color: var(--theme-text-muted);
}

.input-actions {
  display: flex;
  gap: 8px;
}

.clear-btn, .send-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.clear-btn {
  background: rgba(var(--theme-accent-error-rgb, 239, 68, 68), 0.1);
  color: var(--theme-accent-error);
}

.clear-btn:hover {
  background: rgba(var(--theme-accent-error-rgb, 239, 68, 68), 0.2);
}

.send-btn {
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
  color: white;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 4px 12px var(--theme-shadow);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ===== TOAST DE ERRO ===== */
.error-toast {
  position: fixed;
  bottom: 32px;
  right: 32px;
  background: var(--theme-accent-error);
  color: white;
  padding: 16px 20px;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(var(--theme-accent-error-rgb, 239, 68, 68), 0.3);
  display: flex;
  align-items: center;
  gap: 12px;
  max-width: 400px;
  z-index: 1000;
  font-weight: 500;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

/* ===== ANIMAÇÕES ===== */
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.toast-enter-active, .toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from { opacity: 0; transform: translateX(100%); }
.toast-leave-to { opacity: 0; transform: translateX(100%); }

/* ===== MARKDOWN STYLES ===== */
.md-h1, .md-h2, .md-h3 {
  color: var(--theme-text-primary);
  margin: 1rem 0 0.5rem 0;
  font-weight: 700;
}

.md-h1 { font-size: 1.5rem; }
.md-h2 { font-size: 1.25rem; }
.md-h3 { font-size: 1.125rem; }

.md-bold {
  font-weight: 700;
  color: var(--theme-primary);
}

.md-ul {
  margin: 0.75rem 0;
  padding-left: 1.5rem;
}

.md-li {
  margin: 0.25rem 0;
  color: var(--theme-text-primary);
}

/* ===== RESPONSIVIDADE ===== */
@media (max-width: 1200px) {
  .header-main {
    padding: 20px 24px;
  }

  .ai-content {
    padding: 24px;
  }

  .analysis-grid {
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  }
}

@media (max-width: 768px) {
  .header-main {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
    padding: 20px;
  }

  .header-actions {
    justify-content: center;
  }

  .ai-content {
    padding: 20px;
    gap: 24px;
  }

  .intelligent-analysis-section,
  .results-section,
  .chat-section {
    padding: 24px;
  }

  .section-header {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }

  .analysis-grid {
    grid-template-columns: 1fr;
  }

  .results-tabs {
    flex-wrap: wrap;
  }

  .chat-messages {
    height: 300px;
  }

  .message-content {
    max-width: 90%;
  }

  .suggestions-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .header-main {
    padding: 16px;
  }

  .ai-content {
    padding: 16px;
    gap: 20px;
  }

  .intelligent-analysis-section,
  .results-section,
  .chat-section {
    padding: 20px;
  }

  .page-title {
    font-size: 24px;
  }

  .stat-card {
    min-width: 100px;
    padding: 12px;
  }

  .stat-value {
    font-size: 16px;
  }

  .analysis-card {
    padding: 20px;
  }

  .chat-messages {
    padding: 16px;
  }

  .chat-input-container {
    padding: 16px;
  }
}
</style>