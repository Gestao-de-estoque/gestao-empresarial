<template>
  <div class="ai-view">
    <!-- Header -->
    <header class="ai-header">
      <div class="header-content">
        <div class="header-info">
          <h1>
            <Brain :size="32" />
            Análise com Inteligência Artificial
          </h1>
          <p>Insights inteligentes e análises avançadas para otimizar sua gestão</p>
        </div>
        <div class="header-stats">
          <div class="stat-item">
            <Zap :size="20" />
            <span>{{ analysisCount }} análises realizadas</span>
          </div>
          <div class="stat-item">
            <Clock :size="20" />
            <span>Última atualização: {{ formatTime(lastUpdate) }}</span>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <div class="ai-content">
      <!-- Quick Analysis Cards -->
      <section class="quick-analysis-section">
        <h2>
          <Sparkles :size="24" />
          Análises Rápidas
        </h2>
        <div class="analysis-grid">
          <div class="analysis-card inventory" @click="runInventoryAnalysis">
            <div class="card-header">
              <div class="card-icon">
                <Package :size="32" />
              </div>
              <div class="card-actions">
                <button
                  :disabled="loading.inventory"
                  class="action-btn primary"
                >
                  <Loader2 v-if="loading.inventory" :size="16" class="animate-spin" />
                  <PlayCircle v-else :size="16" />
                </button>
              </div>
            </div>
            <div class="card-content">
              <h3>Análise de Estoque</h3>
              <p>Avaliação completa do inventário atual com recomendações estratégicas</p>
              <div class="card-features">
                <span>• Produtos críticos</span>
                <span>• Otimização de custos</span>
                <span>• Ações prioritárias</span>
              </div>
            </div>
          </div>

          <div class="analysis-card purchase" @click="runPurchaseSuggestions">
            <div class="card-header">
              <div class="card-icon">
                <ShoppingCart :size="32" />
              </div>
              <div class="card-actions">
                <button
                  :disabled="loading.purchase"
                  class="action-btn primary"
                >
                  <Loader2 v-if="loading.purchase" :size="16" class="animate-spin" />
                  <PlayCircle v-else :size="16" />
                </button>
              </div>
            </div>
            <div class="card-content">
              <h3>Sugestões de Compra</h3>
              <p>Recomendações inteligentes baseadas no consumo e tendências</p>
              <div class="card-features">
                <span>• Lista prioritária</span>
                <span>• Planejamento semanal</span>
                <span>• Otimização de custos</span>
              </div>
            </div>
          </div>

          <div class="analysis-card menu" @click="runMenuOptimization">
            <div class="card-header">
              <div class="card-icon">
                <ChefHat :size="32" />
              </div>
              <div class="card-actions">
                <button
                  :disabled="loading.menu"
                  class="action-btn primary"
                >
                  <Loader2 v-if="loading.menu" :size="16" class="animate-spin" />
                  <PlayCircle v-else :size="16" />
                </button>
              </div>
            </div>
            <div class="card-content">
              <h3>Otimização do Cardápio</h3>
              <p>Análise e sugestões para maximizar lucros e reduzir desperdícios</p>
              <div class="card-features">
                <span>• Pratos rentáveis</span>
                <span>• Aproveitamento de estoque</span>
                <span>• Combos sugeridos</span>
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
  Send, AlertCircle, X, Zap, Clock, TrendingUp, Calculator
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
  chat: false
})

const analyses = ref<Record<string, AnalysisResult>>({})
const chatHistory = ref<ChatMessage[]>([])
const currentMessage = ref('')
const activeTab = ref('inventory')
const errorMessage = ref('')
const analysisCount = ref(0)
const lastUpdate = ref(new Date())

// Quick suggestions
const quickSuggestions = [
  { icon: '📦', text: 'Quais produtos estão com estoque baixo?' },
  { icon: '💰', text: 'Como posso reduzir custos operacionais?' },
  { icon: '🎯', text: 'Qual a melhor estratégia de compras para esta semana?' },
  { icon: '📊', text: 'Analise o desempenho do meu estoque' },
  { icon: '🍽️', text: 'Sugestões para otimizar o cardápio atual' },
  { icon: '⚡', text: 'Quais ações urgentes devo tomar hoje?' }
]

// Computed
const hasResults = computed(() => Object.keys(analyses.value).length > 0)

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
.ai-view {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
}

.ai-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 2rem;
}

.header-info h1 {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin: 0 0 0.5rem 0;
  font-size: 2rem;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.header-info p {
  margin: 0;
  color: #666;
  font-size: 1.125rem;
  font-weight: 500;
}

.header-stats {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #667eea;
  font-weight: 600;
  font-size: 0.875rem;
}

.ai-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.quick-analysis-section h2,
.results-section h2,
.chat-section h2 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: white;
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 1.5rem 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.analysis-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.analysis-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
}

.analysis-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(31, 38, 135, 0.5);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.card-icon {
  width: 60px;
  height: 60px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.analysis-card.inventory .card-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.analysis-card.purchase .card-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.analysis-card.menu .card-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.action-btn {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  border: none;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn:hover:not(:disabled) {
  transform: scale(1.1);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.action-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.card-content h3 {
  margin: 0 0 0.75rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: #333;
}

.card-content p {
  margin: 0 0 1rem 0;
  color: #666;
  line-height: 1.5;
}

.card-features {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.card-features span {
  font-size: 0.875rem;
  color: #667eea;
  font-weight: 500;
}

.results-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
}

.results-section h2 {
  color: #333;
  text-shadow: none;
}

.results-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
  padding-bottom: 1rem;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: transparent;
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 12px;
  color: #667eea;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
}

.tab-button:hover {
  background: rgba(102, 126, 234, 0.1);
}

.tab-button.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
}

.result-content {
  max-height: 500px;
  overflow-y: auto;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.result-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: #333;
}

.result-actions {
  display: flex;
  gap: 0.75rem;
}

.export-btn,
.share-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: rgba(102, 126, 234, 0.1);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 8px;
  color: #667eea;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.875rem;
  font-weight: 600;
}

.export-btn:hover,
.share-btn:hover {
  background: rgba(102, 126, 234, 0.2);
}

.result-body {
  line-height: 1.6;
  color: #333;
}

.chat-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
}

.chat-section h2 {
  color: #333;
  text-shadow: none;
}

.chat-container {
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 16px;
  overflow: hidden;
  background: #f8fafc;
}

.chat-messages {
  height: 400px;
  overflow-y: auto;
  padding: 1.5rem;
}

.welcome-message {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  text-align: left;
}

.welcome-avatar {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.welcome-content h3 {
  margin: 0 0 1rem 0;
  color: #333;
  font-size: 1.125rem;
  font-weight: 700;
}

.welcome-content p {
  margin: 0 0 1.5rem 0;
  color: #666;
}

.capabilities-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 0.75rem;
}

.capability-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: white;
  border-radius: 8px;
  border: 1px solid rgba(102, 126, 234, 0.1);
  font-weight: 500;
  color: #333;
}

.chat-message {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.chat-message.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.user-message .message-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.ai-message .message-avatar {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.message-content {
  max-width: 75%;
  background: white;
  border-radius: 16px;
  padding: 1rem 1.25rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.user-message .message-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.message-text {
  line-height: 1.5;
}

.message-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 0.5rem;
  font-size: 0.75rem;
  opacity: 0.7;
}

.copy-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.copy-btn:hover {
  background: rgba(102, 126, 234, 0.1);
}

.typing-indicator {
  display: flex;
  gap: 0.25rem;
  margin-bottom: 0.5rem;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #667eea;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator span:nth-child(2) { animation-delay: -0.16s; }

@keyframes typing {
  0%, 80%, 100% {
    transform: scale(0);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

.typing-text {
  font-style: italic;
  color: #666;
  font-size: 0.875rem;
}

.quick-suggestions {
  padding: 1.5rem;
  border-top: 1px solid rgba(102, 126, 234, 0.1);
  background: white;
}

.quick-suggestions h4 {
  margin: 0 0 1rem 0;
  color: #333;
  font-size: 1rem;
  font-weight: 700;
}

.suggestions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 0.75rem;
}

.suggestion-chip {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  background: rgba(102, 126, 234, 0.05);
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;
  font-weight: 500;
  color: #333;
}

.suggestion-chip:hover:not(:disabled) {
  background: rgba(102, 126, 234, 0.1);
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.15);
}

.suggestion-chip:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.suggestion-icon {
  font-size: 1.25rem;
  flex-shrink: 0;
}

.chat-input-container {
  border-top: 1px solid rgba(102, 126, 234, 0.1);
  background: white;
  padding: 1rem;
}

.input-wrapper {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.input-area {
  display: flex;
  align-items: flex-end;
  gap: 0.75rem;
  background: rgba(102, 126, 234, 0.05);
  border: 2px solid rgba(102, 126, 234, 0.2);
  border-radius: 12px;
  padding: 0.75rem;
  transition: all 0.3s ease;
}

.input-area:focus-within {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.chat-input {
  flex: 1;
  border: none;
  background: none;
  outline: none;
  resize: none;
  font-size: 1rem;
  line-height: 1.5;
  color: #333;
  font-family: inherit;
  min-height: 20px;
  max-height: 100px;
}

.chat-input::placeholder {
  color: #94a3b8;
}

.input-actions {
  display: flex;
  gap: 0.5rem;
}

.clear-btn,
.send-btn {
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
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.clear-btn:hover {
  background: rgba(239, 68, 68, 0.2);
}

.send-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.error-toast {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  background: #ef4444;
  color: white;
  padding: 1rem 1.25rem;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(239, 68, 68, 0.3);
  display: flex;
  align-items: center;
  gap: 0.75rem;
  max-width: 400px;
  z-index: 1000;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(100%);
}

/* Markdown Styles */
.md-h1, .md-h2, .md-h3 {
  color: #333;
  margin: 1rem 0 0.5rem 0;
  font-weight: 700;
}

.md-h1 { font-size: 1.5rem; }
.md-h2 { font-size: 1.25rem; }
.md-h3 { font-size: 1.125rem; }

.md-bold {
  font-weight: 700;
  color: #667eea;
}

.md-ul {
  margin: 0.75rem 0;
  padding-left: 1.5rem;
}

.md-li {
  margin: 0.25rem 0;
  color: #555;
}

/* Responsividade */
@media (max-width: 768px) {
  .ai-view {
    padding: 1rem;
  }

  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
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
  .ai-view {
    padding: 0.5rem;
  }

  .ai-header,
  .results-section,
  .chat-section {
    padding: 1.5rem;
  }

  .analysis-card {
    padding: 1.5rem;
  }

  .header-info h1 {
    font-size: 1.5rem;
  }
}
</style>