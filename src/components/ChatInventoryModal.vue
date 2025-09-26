<template>
  <Transition name="fade">
    <div v-if="open" class="chat-overlay" @click.self="close">
      <div class="chat-modal">
        <div class="chat-header">
          <div class="title">
            <MessageCircle :size="20" />
            <div class="text">
              <h3>Assistente IA do Estoque</h3>
              <small>Converse com a IA usando dados reais do seu inventário</small>
            </div>
          </div>
          <div class="actions">
            <button class="refresh" @click="refreshContext" :disabled="loadingContext">
              <RefreshCw :size="16" :class="{ spin: loadingContext }" />
            </button>
            <button class="close" @click="close">
              <X :size="18" />
            </button>
          </div>
        </div>

        <div class="chat-body">
          <div class="context-banner" v-if="contextLoaded">
            <div class="stats">
              <span class="badge">
                <Package :size="14" /> {{ contextSnapshot.totalProducts }} produtos
              </span>
              <span class="badge warning">
                <AlertTriangle :size="14" /> {{ contextSnapshot.lowStockCount }} baixo estoque
              </span>
              <span class="badge danger">
                <XCircle :size="14" /> {{ contextSnapshot.outOfStockCount }} sem estoque
              </span>
              <span class="badge success">
                <DollarSign :size="14" /> R$ {{ formatCurrency(contextSnapshot.totalValue) }} valor total
              </span>
            </div>
            <small>Última atualização: {{ lastUpdatedLabel }}</small>
          </div>

          <div class="messages" ref="messagesRef">
            <div v-if="messages.length === 0" class="welcome">
              <div class="avatar"><Bot :size="28" /></div>
              <div class="content">
                <h4>Olá! Posso ajudar com seu estoque.</h4>
                <p>Faça perguntas como:</p>
                <div class="chips">
                  <button class="chip" @click="useSuggestion('Quais itens estão abaixo do estoque mínimo?')">Quais itens abaixo do mínimo?</button>
                  <button class="chip" @click="useSuggestion('O que precisa ser reposto com urgência?')">O que repor com urgência?</button>
                  <button class="chip" @click="useSuggestion('Sugira uma lista de compras com quantidades ideais.')">Lista de compras ideal</button>
                  <button class="chip" @click="useSuggestion('Quais são os itens mais críticos para o restaurante?')">Itens mais críticos</button>
                </div>
              </div>
            </div>

            <div v-for="(m, idx) in messages" :key="idx" class="message" :class="m.type">
              <div class="avatar">
                <User v-if="m.type === 'user'" :size="18" />
                <Bot v-else :size="18" />
              </div>
              <div class="bubble">
                <div v-if="m.type==='ai'" v-html="formatMarkdown(m.content)"></div>
                <div v-else>{{ m.content }}</div>
                <div class="meta">{{ timeLabel(m.timestamp) }}</div>
              </div>
            </div>

            <div v-if="loadingAnswer" class="message ai loading">
              <div class="avatar"><Bot :size="18" /></div>
              <div class="bubble">
                <div class="typing">
                  <span></span><span></span><span></span>
                </div>
                <div class="meta">Aguarde, analisando seu estoque...</div>
              </div>
            </div>
          </div>
        </div>

        <div class="chat-footer">
          <form class="input-row" @submit.prevent="send">
            <textarea
              ref="inputRef"
              v-model="draft"
              :placeholder="contextLoaded ? 'Digite sua pergunta sobre o estoque...' : 'Carregando dados do estoque...'"
              :disabled="!contextLoaded || loadingAnswer"
              rows="1"
              @keydown.enter.exact.prevent="send"
            />
            <button class="send" :disabled="!draft.trim() || !contextLoaded || loadingAnswer">
              <Send :size="18" />
            </button>
          </form>
          <div v-if="errorMessage" class="error">
            <AlertCircle :size="16" /> {{ errorMessage }}
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { ref, watch, computed, nextTick, onMounted } from 'vue'
import { aiService } from '@/services/aiService'
import { productService } from '@/services/productService'
import {
  MessageCircle, X, RefreshCw, Package, AlertTriangle, XCircle, DollarSign,
  Bot, User, Send, AlertCircle
} from 'lucide-vue-next'

interface ChatMessage {
  type: 'user' | 'ai'
  content: string
  timestamp: Date
}

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{ (e: 'update:open', v: boolean): void }>()

const open = computed({
  get: () => props.open,
  set: (v: boolean) => emit('update:open', v)
})

const messages = ref<ChatMessage[]>([])
const draft = ref('')
const loadingAnswer = ref(false)
const loadingContext = ref(false)
const messagesRef = ref<HTMLElement>()
const inputRef = ref<HTMLTextAreaElement>()
const errorMessage = ref('')

const contextSnapshot = ref({
  totalProducts: 0,
  totalValue: 0,
  lowStockCount: 0,
  outOfStockCount: 0,
  categories: [] as any[],
  products: [] as any[]
})
const contextLoaded = ref(false)
const lastUpdated = ref<Date | null>(null)

const lastUpdatedLabel = computed(() => lastUpdated.value ? timeLabel(lastUpdated.value) : '—')

watch(open, async (v) => {
  if (v) {
    await ensureContext()
    await nextTick()
    inputRef.value?.focus()
  }
})

onMounted(async () => {
  if (open.value) await ensureContext()
})

function close() {
  open.value = false
}

async function ensureContext() {
  if (contextLoaded.value) return
  await refreshContext()
}

async function refreshContext() {
  try {
    loadingContext.value = true
    errorMessage.value = ''

    const [products, categories] = await Promise.all([
      productService.getProducts(),
      productService.getCategories()
    ])

    const totalValue = products.reduce((acc, p: any) => acc + (Number(p.preco) * Number(p.current_stock || p.estoque_atual || 0)), 0)
    const lowStock = products.filter((p: any) => Number(p.current_stock ?? p.estoque_atual) > 0 && Number(p.current_stock ?? p.estoque_atual) <= Number(p.min_stock ?? p.estoque_minimo))
    const outOfStock = products.filter((p: any) => Number(p.current_stock ?? p.estoque_atual) === 0)

    // Minify product data sent to LLM to essentials
    const simplified = products.map((p: any) => ({
      id: p.id,
      nome: p.nome,
      categoria_id: p.categoria_id,
      preco: Number(p.preco),
      current_stock: Number(p.current_stock ?? p.estoque_atual ?? 0),
      min_stock: Number(p.min_stock ?? p.estoque_minimo ?? 0),
      unidade: p.unidade,
      descricao: p.descricao || undefined,
      codigo_barras: p.codigo_barras || undefined
    }))

    contextSnapshot.value = {
      totalProducts: products.length,
      totalValue,
      lowStockCount: lowStock.length,
      outOfStockCount: outOfStock.length,
      categories,
      products: simplified
    }
    contextLoaded.value = true
    lastUpdated.value = new Date()
  } catch (e: any) {
    console.error('Erro ao carregar contexto do estoque', e)
    errorMessage.value = e?.message || 'Erro ao carregar dados do estoque.'
  } finally {
    loadingContext.value = false
  }
}

function useSuggestion(text: string) {
  draft.value = text
  nextTick(() => inputRef.value?.focus())
}

function timeLabel(d: Date) {
  return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value)
}

function formatMarkdown(text: string): string {
  return text
    .replace(/^### (.*$)/gm, '<h3>$1</h3>')
    .replace(/^## (.*$)/gm, '<h2>$1</h2>')
    .replace(/^# (.*$)/gm, '<h1>$1</h1>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/^\- (.*$)/gm, '<li>$1</li>')
    .replace(/^(\d+)\. (.*$)/gm, '<li>$2</li>')
    .replace(/\n\n/g, '<br><br>')
    .replace(/\n/g, '<br>')
    .replace(/(<li>.*<\/li>)/gs, '<ul>$1</ul>')
}

async function send() {
  const text = draft.value.trim()
  if (!text || loadingAnswer.value) return

  messages.value.push({ type: 'user', content: text, timestamp: new Date() })
  draft.value = ''
  await nextTick()
  scrollToEnd()

  loadingAnswer.value = true
  errorMessage.value = ''

  try {
    const context = {
      policy: 'Responda apenas com base nos dados fornecidos. Se algo não estiver presente nos dados, informe claramente que a informação não está disponível. Sempre traga quantidades, unidades, e prioridades quando aplicável.',
      data_fonte: 'Supabase – tabela produtos',
      snapshot: contextSnapshot.value
    }

    const answer = await aiService.askQuestion(text, context)
    messages.value.push({ type: 'ai', content: answer, timestamp: new Date() })
    await nextTick()
    scrollToEnd()
  } catch (e: any) {
    console.error('Erro no chat IA', e)
    errorMessage.value = e?.message || 'Não foi possível obter resposta da IA.'
  } finally {
    loadingAnswer.value = false
  }
}

function scrollToEnd() {
  const el = messagesRef.value
  if (!el) return
  el.scrollTop = el.scrollHeight
}
</script>

<style scoped>
.fade-enter-active,.fade-leave-active { transition: opacity .15s ease; }
.fade-enter-from,.fade-leave-to { opacity: 0; }

.chat-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.4);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.chat-modal {
  width: min(900px, 92vw);
  height: min(720px, 88vh);
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 16px;
  box-shadow: 0 20px 60px var(--theme-shadow);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  border-bottom: 1px solid var(--theme-border);
  background: linear-gradient(180deg, var(--theme-surface), rgba(0,0,0,0));
}
.chat-header .title { display: flex; gap: 10px; align-items: center; }
.chat-header .title h3 { margin: 0; font-weight: 700; }
.chat-header .title small { color: var(--theme-text-secondary); }
.chat-header .actions { display: flex; gap: 8px; }
.chat-header button { border: none; background: transparent; color: var(--theme-text-secondary); cursor: pointer; }
.chat-header button.refresh { padding: 6px; border-radius: 8px; }
.chat-header button.close { padding: 6px; border-radius: 8px; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { from { transform: rotate(0) } to { transform: rotate(360deg) } }

.chat-body { padding: 12px; display: flex; flex-direction: column; gap: 12px; height: 100%; }
.context-banner { border: 1px solid var(--theme-border); background: var(--theme-background); border-radius: 12px; padding: 10px 12px; display:flex; align-items: center; justify-content: space-between; }
.context-banner .stats { display:flex; gap: 8px; flex-wrap: wrap; }
.badge { display:inline-flex; gap:6px; align-items:center; padding:6px 10px; border-radius:999px; background: var(--theme-surface); border: 1px solid var(--theme-border); font-size: 12px; }
.badge.warning{ background:#fff7ed; color:#b45309; border-color:#fed7aa; }
.badge.danger{ background:#fee2e2; color:#991b1b; border-color:#fecaca; }
.badge.success{ background:#ecfdf5; color:#065f46; border-color:#a7f3d0; }

.messages { flex: 1; overflow: auto; padding: 6px 2px; }
.welcome { display:flex; gap:12px; align-items:flex-start; color: var(--theme-text-secondary); }
.welcome .avatar { width: 36px; height: 36px; border-radius: 10px; display:flex; align-items:center; justify-content:center; background: var(--theme-background); border:1px solid var(--theme-border); }
.welcome h4 { margin: 0 0 4px; color: var(--theme-text-primary); }
.chips { display:flex; gap:8px; flex-wrap: wrap; margin-top: 8px; }
.chip { border: 1px solid var(--theme-border); background: var(--theme-surface); color: var(--theme-text-primary); border-radius: 999px; padding: 6px 10px; cursor: pointer; font-size: 12px; }
.chip:hover { background: var(--theme-background); }

.message { display:flex; gap:10px; margin: 10px 0; }
.message .avatar { width: 28px; height: 28px; border-radius: 8px; display:flex; align-items:center; justify-content:center; background: var(--theme-background); border:1px solid var(--theme-border); }
.message .bubble { max-width: 75%; padding: 10px 12px; border-radius: 12px; border: 1px solid var(--theme-border); background: var(--theme-surface); box-shadow: 0 2px 8px var(--theme-shadow); }
.message.user { flex-direction: row-reverse; }
.message.user .bubble { background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary)); color: white; border-color: transparent; }
.message .meta { margin-top: 6px; font-size: 11px; color: var(--theme-text-secondary); }

.typing { display: inline-flex; gap: 4px; }
.typing span { width: 6px; height: 6px; background: var(--theme-text-secondary); border-radius: 999px; display:inline-block; animation: blink 1.2s infinite ease-in-out; opacity: .6 }
.typing span:nth-child(2){ animation-delay: .2s }
.typing span:nth-child(3){ animation-delay: .4s }
@keyframes blink { 0%, 80%, 100% { opacity: .2 } 40% { opacity: 1 } }

.chat-footer { border-top: 1px solid var(--theme-border); padding: 10px 12px; background: var(--theme-surface); }
.input-row { display:flex; gap: 8px; align-items: flex-end; }
.input-row textarea { flex: 1; resize: none; max-height: 140px; min-height: 44px; padding: 10px 12px; border-radius: 12px; border: 1px solid var(--theme-border); background: var(--theme-background); color: var(--theme-text-primary); }
.input-row .send { border: none; background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary)); color: white; padding: 10px 14px; border-radius: 12px; cursor: pointer; display:flex; align-items:center; gap:6px; }
.input-row .send:disabled { opacity: .6; cursor: not-allowed; }
.error { color: #991b1b; background: #fee2e2; border: 1px solid #fecaca; padding: 8px 10px; border-radius: 10px; margin-top: 8px; display:flex; align-items:center; gap:8px; }
</style>

