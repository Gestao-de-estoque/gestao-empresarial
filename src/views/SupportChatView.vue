<template>
  <div class="support-chat">
    <header class="chat-header">
      <div class="left">
        <MessageSquare :size="24" />
        <div class="header-info">
          <h1>Painel de Suporte</h1>
          <p>{{ conversations.length }} conversa{{ conversations.length !== 1 ? 's' : '' }} • {{ openConversations }} aberta{{ openConversations !== 1 ? 's' : '' }}</p>
        </div>
      </div>
      <div class="right">
        <button class="btn ghost" @click="refresh" :disabled="loading">
          <RefreshCw :size="16" :class="{ 'animate-spin': loading }" />
          Atualizar
        </button>
        <button class="btn" @click="startNewConversation">Nova conversa</button>
        <button class="btn danger" @click="logoutSupport">Sair</button>
      </div>
    </header>

    <div class="chat-body">
      <aside class="sidebar">
        <div class="sidebar-header">
          <div class="title">Conversas</div>
          <div class="filter-tabs">
            <button class="filter-btn" :class="{ active: filter === 'all' }" @click="filter = 'all'">Todas</button>
            <button class="filter-btn" :class="{ active: filter === 'open' }" @click="filter = 'open'">Abertas</button>
            <button class="filter-btn" :class="{ active: filter === 'closed' }" @click="filter = 'closed'">Fechadas</button>
          </div>
        </div>
        <div class="conv-list">
          <div v-if="filteredConversations.length === 0" class="no-conversations">
            <MessageSquare :size="32" />
            <p>Nenhuma conversa encontrada</p>
          </div>
          <button v-for="c in filteredConversations" :key="c.id" class="conv-item" :class="{ active: c.id === activeId, closed: c.status === 'closed' }" @click="openConversation(c.id)">
            <div class="conv-header">
              <div class="subject">{{ c.subject }}</div>
              <div class="status-badge" :class="c.status">{{ c.status === 'open' ? 'Aberta' : 'Fechada' }}</div>
            </div>
            <div class="last-message" v-if="c.last_message">{{ c.last_message }}</div>
            <div class="meta">
              <span>{{ formatDate(c.created_at) }}</span>
              <span v-if="c.last_message_at" class="last-time">• {{ formatTime(c.last_message_at) }}</span>
            </div>
          </button>
        </div>
      </aside>
      <main class="messages">
        <div v-if="!activeId" class="empty">
          <MessageSquare :size="40" />
          <p>Selecione uma conversa ou crie uma nova</p>
        </div>
        <div v-else class="chat-container">
          <div class="conversation-header" v-if="activeConversation">
            <div class="conv-info">
              <h3>{{ activeConversation.subject }}</h3>
              <div class="conv-meta">
                <span class="status-badge" :class="activeConversation.status">
                  {{ activeConversation.status === 'open' ? 'Conversa Aberta' : 'Conversa Fechada' }}
                </span>
                <span>Criada em {{ formatDateTime(activeConversation.created_at) }}</span>
              </div>
            </div>
            <div class="conv-actions">
              <button v-if="activeConversation.status === 'open'" class="btn warning" @click="closeConversation">
                <X :size="16" />
                Encerrar
              </button>
              <button class="btn danger" @click="deleteConversation">
                <Trash2 :size="16" />
                Excluir
              </button>
            </div>
          </div>

          <div class="thread" ref="threadRef">
            <div class="message" v-for="m in messages" :key="m.id" :class="m.sender_role">
              <div class="message-avatar">
                <div class="avatar" :class="m.sender_role">
                  {{ m.sender_role === 'admin' ? 'A' : 'S' }}
                </div>
              </div>
              <div class="message-content">
                <div class="message-header">
                  <span class="sender">{{ m.sender_role === 'admin' ? 'Administrador' : 'Suporte' }}</span>
                  <span class="time">{{ formatDateTime(m.created_at) }}</span>
                </div>
                <div class="bubble">
                  <div class="content">{{ m.content }}</div>
                </div>
              </div>
            </div>
          </div>

          <form v-if="activeId && activeConversation?.status === 'open'" class="composer" @submit.prevent="send">
            <input v-model="draft" type="text" placeholder="Digite sua resposta..." :disabled="sending" />
            <button type="submit" class="send-btn" :disabled="!draft.trim() || sending">
              <Send :size="16" />
              {{ sending ? 'Enviando...' : 'Enviar' }}
            </button>
          </form>
          <div v-else-if="activeId && activeConversation?.status === 'closed'" class="conversation-closed">
            <p>Esta conversa foi encerrada. Não é possível enviar novas mensagens.</p>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useSupportAuthStore } from '@/stores/supportAuth'
import { supportChatService, type SupportConversation, type SupportMessage } from '@/services/supportChatService'
import { MessageSquare, RefreshCw, X, Trash2, Send } from 'lucide-vue-next'

const auth = useAuthStore()
const supportAuth = useSupportAuthStore()
supportAuth.restore()

const conversations = ref<SupportConversation[]>([])
const messages = ref<SupportMessage[]>([])
const activeId = ref<string>('')
const draft = ref('')
const loading = ref(false)
const sending = ref(false)
const filter = ref<'all' | 'open' | 'closed'>('all')
let unsubscribe: (() => void) | null = null

async function loadConversations() {
  loading.value = true
  try {
    const uid = supportAuth.user?.id || auth.user?.id
    if (!uid) return
    conversations.value = await supportChatService.listConversations(uid)
  } catch (error) {
    console.error('Erro ao carregar conversas:', error)
  } finally {
    loading.value = false
  }
}

async function refresh() {
  await loadConversations()
  if (activeId.value) {
    await openConversation(activeId.value)
  }
}

async function openConversation(id: string) {
  activeId.value = id
  messages.value = await supportChatService.getMessages(id)
  if (unsubscribe) unsubscribe()
  unsubscribe = supportChatService.onMessages(id, (msg) => {
    messages.value.push(msg)
    scrollToBottom()
  })
  scrollToBottom()
}

async function startNewConversation() {
  const subject = prompt('Assunto da conversa') || 'Suporte'
  const adminId = auth.user?.id
  const supportId = supportAuth.user?.id || auth.user?.id
  if (!adminId || !supportId) return
  const id = await supportChatService.createConversation(subject, adminId, supportId)
  await loadConversations()
  await openConversation(id)
}

async function send() {
  const content = draft.value.trim()
  if (!content || !activeId.value || sending.value) return

  sending.value = true
  try {
    const senderId = supportAuth.user?.id || auth.user?.id!
    const senderRole: 'admin' | 'support' = supportAuth.user ? 'support' : 'admin'
    await supportChatService.sendMessage(activeId.value, senderId, senderRole, content)
    draft.value = ''
    scrollToBottom()
  } catch (error) {
    console.error('Erro ao enviar mensagem:', error)
    alert('Erro ao enviar mensagem. Tente novamente.')
  } finally {
    sending.value = false
  }
}

function scrollToBottom() {
  setTimeout(() => {
    const thread = document.querySelector('.thread')
    if (thread) {
      thread.scrollTop = thread.scrollHeight
    }
  }, 100)
}

async function closeConversation() {
  if (!activeId.value) return
  if (!confirm('Deseja encerrar esta conversa?')) return

  try {
    await supportChatService.closeConversation(activeId.value)
    await loadConversations()
    // Atualiza a conversa ativa
    const updatedConv = conversations.value.find(c => c.id === activeId.value)
    if (updatedConv) {
      updatedConv.status = 'closed'
    }
  } catch (error) {
    console.error('Erro ao encerrar conversa:', error)
    alert('Erro ao encerrar conversa.')
  }
}

async function deleteConversation() {
  if (!activeId.value) return
  if (!confirm('Deseja excluir esta conversa permanentemente?')) return

  try {
    await supportChatService.deleteConversation(activeId.value)
    activeId.value = ''
    messages.value = []
    await loadConversations()
  } catch (error) {
    console.error('Erro ao excluir conversa:', error)
    alert('Erro ao excluir conversa.')
  }
}

function formatDate(s: string) {
  return new Date(s).toLocaleDateString('pt-BR')
}
function formatTime(s: string) {
  const d = new Date(s); return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
}
function formatDateTime(s: string) {
  const d = new Date(s)
  return d.toLocaleDateString('pt-BR') + ' às ' + d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
}

onMounted(() => {
  loadConversations()
})

onBeforeUnmount(() => { if (unsubscribe) unsubscribe() })

// Computed properties
const filteredConversations = computed(() => {
  if (filter.value === 'all') return conversations.value
  return conversations.value.filter(c => c.status === filter.value)
})

const openConversations = computed(() => {
  return conversations.value.filter(c => c.status === 'open').length
})

const activeConversation = computed(() => {
  return conversations.value.find(c => c.id === activeId.value)
})

function logoutSupport() {
  if (supportAuth.user) {
    supportAuth.signOut()
  }
  // Volta para o dashboard
  window.location.href = '/dashboard'
}

</script>

<style scoped>
.support-chat { height: 100vh; display: flex; flex-direction: column; background: var(--theme-background); }

/* Header melhorado */
.chat-header {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color:#fff;
  border-bottom: 1px solid var(--theme-border);
  display:flex;
  justify-content:space-between;
  align-items:center;
  padding: 16px 20px;
  box-shadow: 0 8px 32px rgba(0,0,0,.15);
}
.chat-header .left { display:flex; align-items:center; gap:12px; }
.chat-header .header-info h1 { font-size: 20px; margin: 0; font-weight: 800; letter-spacing: .2px }
.chat-header .header-info p { margin: 0; font-size: 13px; opacity: 0.9; font-weight: 500; }
.chat-header .right { display: flex; gap: 8px; }
.chat-header .btn {
  padding: 8px 12px;
  border-radius: 8px;
  border:1px solid rgba(255,255,255,.35);
  background: rgba(255,255,255,.12);
  color:#fff;
  cursor:pointer;
  backdrop-filter: blur(6px);
  transition: all .2s ease;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 600;
}
.chat-header .btn:hover { background: rgba(255,255,255,.22) }
.chat-header .btn.ghost { background: transparent; border-color: rgba(255,255,255,.25) }
.chat-header .btn.danger { background: rgba(239,68,68,.2); border-color: rgba(239,68,68,.5) }
.chat-header .btn.warning { background: rgba(245,158,11,.2); border-color: rgba(245,158,11,.5) }
.chat-header .btn:disabled { opacity: 0.6; cursor: not-allowed; }

.animate-spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.chat-body { flex:1; display:grid; grid-template-columns: 340px 1fr; }

/* Sidebar melhorada */
.sidebar {
  border-right: 1px solid var(--theme-border);
  background: var(--theme-surface);
  display:flex;
  flex-direction:column;
}
.sidebar-header {
  padding: 16px;
  border-bottom:1px solid var(--theme-border);
  background: linear-gradient(135deg, rgba(102,126,234,.08), rgba(118,75,162,.06));
}
.sidebar-header .title {
  font-weight: 800;
  font-size: 16px;
  margin-bottom: 12px;
  color: var(--theme-text-primary);
}
.filter-tabs {
  display: flex;
  gap: 4px;
  background: var(--theme-background);
  border-radius: 8px;
  padding: 4px;
}
.filter-btn {
  flex: 1;
  padding: 6px 8px;
  border: none;
  background: transparent;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all .2s;
  color: var(--theme-text-secondary);
}
.filter-btn.active {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.conv-list { padding: 12px; overflow:auto; flex: 1; }
.no-conversations {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: var(--theme-text-secondary);
  padding: 20px;
  text-align: center;
}
.conv-item {
  width:100%;
  text-align:left;
  background: var(--theme-background);
  border:1px solid var(--theme-border);
  border-radius:12px;
  padding:12px;
  margin-bottom:8px;
  cursor:pointer;
  transition: all .2s ease;
}
.conv-item:hover {
  border-color: rgba(102,126,234,.3);
  box-shadow: 0 4px 12px rgba(102,126,234,.1);
}
.conv-item.active {
  border-color: var(--theme-primary);
  background: rgba(102,126,234,.06);
  box-shadow: 0 4px 16px rgba(102,126,234,.15);
}
.conv-item.closed { opacity: 0.7; }
.conv-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 6px;
}
.conv-item .subject {
  font-weight:700;
  font-size: 14px;
  color: var(--theme-text-primary);
}
.status-badge {
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
}
.status-badge.open {
  background: rgba(34,197,94,.1);
  color: rgb(22,163,74);
}
.status-badge.closed {
  background: rgba(107,114,128,.1);
  color: rgb(75,85,99);
}
.last-message {
  font-size: 12px;
  color: var(--theme-text-secondary);
  margin-bottom: 4px;
  line-height: 1.3;
}
.conv-item .meta {
  font-size: 11px;
  color: var(--theme-text-secondary);
  display: flex;
  gap: 4px;
}
.last-time { opacity: 0.7; }

/* Messages area melhorada */
.messages {
  position:relative;
  display:flex;
  flex-direction:column;
  background: radial-gradient(ellipse at 20% 10%, rgba(102,126,234,.04), transparent 60%), var(--theme-background);
}
.empty {
  margin:auto;
  text-align:center;
  color: var(--theme-text-secondary);
  display:flex;
  flex-direction:column;
  gap:12px;
  align-items:center;
}

.chat-container {
  display: flex;
  flex-direction: column;
  height: 100%;
}
.conversation-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--theme-border);
  background: var(--theme-surface);
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.conv-info h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 700;
  color: var(--theme-text-primary);
}
.conv-meta {
  display: flex;
  gap: 12px;
  align-items: center;
  font-size: 13px;
  color: var(--theme-text-secondary);
}
.conv-actions {
  display: flex;
  gap: 8px;
}

.thread {
  flex:1;
  padding: 20px;
  overflow:auto;
  display:flex;
  flex-direction:column;
  gap:16px;
}
.message {
  display:flex;
  gap: 12px;
  align-items: flex-start;
}
.message.admin {
  flex-direction: row-reverse;
}
.message-avatar .avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  color: white;
}
.avatar.admin {
  background: linear-gradient(135deg, #667eea, #764ba2);
}
.avatar.support {
  background: linear-gradient(135deg, #10b981, #059669);
}
.message-content {
  flex: 1;
  max-width: 70%;
}
.message-header {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 4px;
}
.message.admin .message-header {
  justify-content: flex-end;
}
.sender {
  font-weight: 600;
  font-size: 12px;
  color: var(--theme-text-secondary);
}
.message-header .time {
  font-size: 11px;
  color: var(--theme-text-secondary);
  opacity: 0.7;
}
.bubble {
  background: var(--theme-surface);
  border:1px solid var(--theme-border);
  border-radius: 16px;
  padding: 12px 16px;
  box-shadow: 0 2px 8px rgba(0,0,0,.04);
}
.admin .bubble {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  border: none;
}
.content {
  white-space: pre-wrap;
  line-height: 1.4;
}

.composer {
  border-top: 1px solid var(--theme-border);
  padding: 16px;
  display:flex;
  gap:12px;
  background: var(--theme-surface);
}
.composer input {
  flex:1;
  padding: 12px 16px;
  border-radius: 12px;
  border:1px solid var(--theme-border);
  background: var(--theme-background);
  font-size: 14px;
}
.composer .send-btn {
  padding: 12px 20px;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color:#fff;
  border: none;
  cursor:pointer;
  box-shadow: 0 4px 16px rgba(102,126,234,.3);
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 600;
  transition: all .2s;
}
.composer .send-btn:hover {
  box-shadow: 0 6px 20px rgba(102,126,234,.4);
  transform: translateY(-1px);
}
.composer .send-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.conversation-closed {
  padding: 16px;
  background: rgba(107,114,128,.1);
  border-top: 1px solid var(--theme-border);
  text-align: center;
  color: var(--theme-text-secondary);
  font-style: italic;
}
</style>