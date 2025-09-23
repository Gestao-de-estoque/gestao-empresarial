<template>
  <div class="notification-center">
    <!-- Trigger Button -->
    <button
      @click="togglePanel"
      class="notification-trigger"
      :class="{ active: isOpen, 'has-notifications': unreadCount > 0 }"
    >
      <Bell :size="20" />
      <span v-if="unreadCount > 0" class="notification-badge">
        {{ unreadCount > 99 ? '99+' : unreadCount }}
      </span>
    </button>

    <!-- Notification Panel -->
    <transition name="slide-down">
      <div v-if="isOpen" class="notification-panel">
        <!-- Header -->
        <div class="panel-header">
          <div class="header-info">
            <h3>
              <Bell :size="18" />
              Notificações
            </h3>
            <span v-if="unreadCount > 0" class="unread-count">
              {{ unreadCount }} não lidas
            </span>
          </div>
          <div class="header-actions">
            <button
              @click="markAllAsRead"
              class="action-btn"
              :disabled="unreadCount === 0"
              title="Marcar todas como lidas"
            >
              <CheckCheck :size="16" />
            </button>
            <button
              @click="toggleSettings"
              class="action-btn"
              title="Configurações"
            >
              <Settings :size="16" />
            </button>
            <button
              @click="closePanel"
              class="action-btn"
              title="Fechar"
            >
              <X :size="16" />
            </button>
          </div>
        </div>

        <!-- Settings Panel -->
        <transition name="slide-down">
          <div v-if="showSettings" class="settings-panel">
            <div class="setting-item">
              <div class="setting-info">
                <span>Notificações ativadas</span>
                <small>Receber notificações do sistema</small>
              </div>
              <label class="toggle-switch">
                <input type="checkbox" v-model="isEnabled" @change="toggleEnabled">
                <span class="slider"></span>
              </label>
            </div>
            <div class="setting-item">
              <div class="setting-info">
                <span>Sons de notificação</span>
                <small>Reproduzir sons para notificações</small>
              </div>
              <label class="toggle-switch">
                <input type="checkbox" v-model="soundEnabled" @change="toggleSound">
                <span class="slider"></span>
              </label>
            </div>
            <div class="setting-item">
              <button @click="requestBrowserPermission" class="permission-btn">
                <Shield :size="16" />
                Permitir notificações do navegador
              </button>
            </div>
            <div class="setting-item">
              <button @click="startDemo" class="demo-btn">
                <Play :size="16" />
                Demonstração de notificações
              </button>
            </div>
          </div>
        </transition>

        <!-- Filter Tabs -->
        <div class="filter-tabs">
          <button
            @click="selectedCategory = 'all'"
            :class="{ active: selectedCategory === 'all' }"
            class="filter-tab"
          >
            Todas ({{ notifications.length }})
          </button>
          <button
            v-for="(categoryNotifications, category) in notificationsByCategory"
            :key="category"
            @click="selectedCategory = category"
            :class="{ active: selectedCategory === category }"
            class="filter-tab"
          >
            {{ getCategoryLabel(category) }} ({{ categoryNotifications.length }})
          </button>
        </div>

        <!-- Notifications List -->
        <div class="notifications-list">
          <div v-if="filteredNotifications.length === 0" class="empty-state">
            <BellOff :size="48" />
            <h4>Nenhuma notificação</h4>
            <p v-if="selectedCategory === 'all'">
              Você está em dia! Não há notificações pendentes.
            </p>
            <p v-else>
              Não há notificações na categoria "{{ getCategoryLabel(selectedCategory) }}".
            </p>
          </div>

          <div v-else class="notification-items">
            <transition-group name="notification" tag="div">
              <div
                v-for="notification in filteredNotifications"
                :key="notification.id"
                class="notification-item"
                :class="{
                  unread: !notification.read,
                  [notification.type]: true,
                  persistent: notification.persistent
                }"
                @click="handleNotificationClick(notification)"
              >
                <div class="notification-icon">
                  <component
                    :is="getNotificationIcon(notification)"
                    :size="20"
                  />
                </div>

                <div class="notification-content">
                  <h4>{{ notification.title }}</h4>
                  <p>{{ notification.message }}</p>
                  <div class="notification-meta">
                    <time>{{ formatTimeAgo(notification.timestamp) }}</time>
                    <span class="category-tag">{{ getCategoryLabel(notification.category) }}</span>
                  </div>
                </div>

                <div class="notification-actions">
                  <button
                    v-if="notification.actionText && notification.actionRoute"
                    @click.stop="navigateToAction(notification)"
                    class="action-link"
                  >
                    {{ notification.actionText }}
                    <ExternalLink :size="12" />
                  </button>
                  <button
                    @click.stop="removeNotification(notification.id)"
                    class="remove-btn"
                    title="Remover notificação"
                  >
                    <X :size="14" />
                  </button>
                </div>
              </div>
            </transition-group>
          </div>
        </div>

        <!-- Footer Actions -->
        <div class="panel-footer" v-if="notifications.length > 0">
          <button @click="clearRead" class="footer-btn" :disabled="readNotifications.length === 0">
            <Trash2 :size="16" />
            Limpar lidas ({{ readNotifications.length }})
          </button>
          <button @click="clearAll" class="footer-btn danger">
            <Trash :size="16" />
            Limpar todas
          </button>
        </div>
      </div>
    </transition>

    <!-- Overlay -->
    <div
      v-if="isOpen"
      class="notification-overlay"
      @click="closePanel"
    ></div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  Bell, BellOff, X, Settings, CheckCheck, Shield, Play,
  ExternalLink, Trash2, Trash, AlertCircle, AlertTriangle,
  CheckCircle, Info, Package, PackageX, PackagePlus,
  Brain, Lightbulb
} from 'lucide-vue-next'
import { useNotificationsStore } from '@/stores/notifications'
import { formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const router = useRouter()
const notificationsStore = useNotificationsStore()

// Destructure store properties
const {
  notifications,
  unreadCount,
  notificationsByCategory,
  isEnabled,
  soundEnabled,
  markAllAsRead,
  removeNotification,
  markAsRead,
  clearAll,
  clearRead,
  toggleEnabled,
  toggleSound,
  requestPermission,
  startSimulation
} = notificationsStore

// Local state
const isOpen = ref(false)
const showSettings = ref(false)
const selectedCategory = ref<string>('all')

// Computed properties
const readNotifications = computed(() =>
  notifications.filter(n => n.read)
)

const filteredNotifications = computed(() => {
  if (selectedCategory.value === 'all') {
    return notifications
  }
  return notifications.filter(n => n.category === selectedCategory.value)
})

// Functions
function togglePanel() {
  isOpen.value = !isOpen.value
  showSettings.value = false
}

function closePanel() {
  isOpen.value = false
  showSettings.value = false
}

function toggleSettings() {
  showSettings.value = !showSettings.value
}

function handleNotificationClick(notification: any) {
  if (!notification.read) {
    markAsRead(notification.id)
  }

  if (notification.actionRoute) {
    router.push(notification.actionRoute)
    closePanel()
  }
}

function navigateToAction(notification: any) {
  if (notification.actionRoute) {
    router.push(notification.actionRoute)
    closePanel()
  }
}

function getNotificationIcon(notification: any) {
  // Use custom icon if provided
  if (notification.icon) {
    const iconMap: Record<string, any> = {
      AlertCircle,
      AlertTriangle,
      CheckCircle,
      Info,
      Package,
      PackageX,
      PackagePlus,
      Brain,
      Lightbulb,
      Shield
    }
    return iconMap[notification.icon] || Bell
  }

  // Default icons based on type
  switch (notification.type) {
    case 'success':
      return CheckCircle
    case 'error':
      return AlertCircle
    case 'warning':
      return AlertTriangle
    case 'info':
    default:
      return Info
  }
}

function getCategoryLabel(category: string) {
  const labels: Record<string, string> = {
    system: 'Sistema',
    stock: 'Estoque',
    sales: 'Vendas',
    security: 'Segurança',
    ai: 'IA'
  }
  return labels[category] || category
}

function formatTimeAgo(date: Date) {
  return formatDistanceToNow(date, { addSuffix: true, locale: ptBR })
}

async function requestBrowserPermission() {
  const granted = await requestPermission()
  if (granted) {
    notificationsStore.success(
      'Permissão Concedida',
      'Agora você receberá notificações do navegador'
    )
  } else {
    notificationsStore.warning(
      'Permissão Negada',
      'Não foi possível ativar as notificações do navegador'
    )
  }
}

function startDemo() {
  startSimulation()
  notificationsStore.info(
    'Demonstração Iniciada',
    'Você receberá algumas notificações de exemplo nos próximos segundos'
  )
  showSettings.value = false
}

// Close panel when clicking outside
function handleClickOutside(event: MouseEvent) {
  const target = event.target as HTMLElement
  if (!target.closest('.notification-center')) {
    closePanel()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.notification-center {
  position: relative;
}

.notification-trigger {
  position: relative;
  background: none;
  border: none;
  color: #667eea;
  cursor: pointer;
  padding: 0.75rem;
  border-radius: 12px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-trigger:hover {
  background: rgba(102, 126, 234, 0.1);
  transform: translateY(-1px);
}

.notification-trigger.active {
  background: rgba(102, 126, 234, 0.2);
  color: #5a67d8;
}

.notification-trigger.has-notifications {
  animation: pulse 2s infinite;
}

.notification-badge {
  position: absolute;
  top: 4px;
  right: 4px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  font-size: 0.625rem;
  font-weight: 700;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid white;
}

.notification-panel {
  position: absolute;
  top: 100%;
  right: 0;
  width: 400px;
  max-height: 600px;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 20px 50px rgba(31, 38, 135, 0.3);
  z-index: 1000;
  margin-top: 0.5rem;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 1.5rem 1rem;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.header-info h3 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0 0 0.25rem 0;
  font-size: 1.125rem;
  font-weight: 700;
  color: #333;
}

.unread-count {
  font-size: 0.75rem;
  color: #667eea;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.action-btn:hover:not(:disabled) {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.settings-panel {
  padding: 1rem 1.5rem;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
  background: rgba(102, 126, 234, 0.05);
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
}

.setting-item:not(:last-child) {
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.setting-info span {
  font-weight: 600;
  color: #333;
  display: block;
}

.setting-info small {
  color: #666;
  font-size: 0.75rem;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 26px;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: 0.4s;
  border-radius: 26px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 20px;
  width: 20px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: 0.4s;
  border-radius: 50%;
}

input:checked + .slider {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

input:checked + .slider:before {
  transform: translateX(24px);
}

.permission-btn, .demo-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.permission-btn:hover, .demo-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.filter-tabs {
  display: flex;
  gap: 0.5rem;
  padding: 1rem 1.5rem 0;
  overflow-x: auto;
}

.filter-tab {
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
  white-space: nowrap;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.filter-tab:hover {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.filter-tab.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
}

.notifications-list {
  flex: 1;
  overflow-y: auto;
  max-height: 400px;
  padding: 1rem 0;
}

.empty-state {
  text-align: center;
  padding: 3rem 2rem;
  color: #666;
}

.empty-state h4 {
  margin: 1rem 0 0.5rem 0;
  font-size: 1.125rem;
  font-weight: 600;
  color: #333;
}

.empty-state p {
  margin: 0;
  font-size: 0.875rem;
}

.notification-items {
  padding: 0 1.5rem;
}

.notification-item {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  border-radius: 12px;
  margin-bottom: 0.75rem;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid transparent;
  position: relative;
}

.notification-item:hover {
  background: rgba(102, 126, 234, 0.05);
  transform: translateY(-1px);
}

.notification-item.unread {
  background: rgba(102, 126, 234, 0.08);
  border-color: rgba(102, 126, 234, 0.2);
}

.notification-item.unread:before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 60%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 0 2px 2px 0;
}

.notification-item.persistent {
  border-left: 4px solid #f59e0b;
}

.notification-icon {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.notification-item.success .notification-icon {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.notification-item.error .notification-icon {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
}

.notification-item.warning .notification-icon {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.notification-item.info .notification-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-content h4 {
  margin: 0 0 0.25rem 0;
  font-size: 0.875rem;
  font-weight: 600;
  color: #333;
  line-height: 1.4;
}

.notification-content p {
  margin: 0 0 0.5rem 0;
  font-size: 0.75rem;
  color: #666;
  line-height: 1.4;
}

.notification-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.625rem;
  color: #888;
}

.category-tag {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.notification-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  align-items: flex-end;
}

.action-link {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  background: none;
  border: none;
  color: #667eea;
  cursor: pointer;
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.action-link:hover {
  background: rgba(102, 126, 234, 0.1);
}

.remove-btn {
  background: none;
  border: none;
  color: #888;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.remove-btn:hover {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.panel-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid rgba(102, 126, 234, 0.1);
  background: rgba(102, 126, 234, 0.05);
  display: flex;
  gap: 1rem;
}

.footer-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: white;
  border: 1px solid rgba(102, 126, 234, 0.3);
  color: #667eea;
  border-radius: 8px;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  flex: 1;
  justify-content: center;
}

.footer-btn:hover:not(:disabled) {
  background: rgba(102, 126, 234, 0.1);
  transform: translateY(-1px);
}

.footer-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.footer-btn.danger {
  border-color: rgba(239, 68, 68, 0.3);
  color: #ef4444;
}

.footer-btn.danger:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.1);
}

.notification-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 999;
}

/* Animations */
@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.slide-down-enter-from {
  opacity: 0;
  transform: translateY(-10px) scale(0.95);
}

.slide-down-leave-to {
  opacity: 0;
  transform: translateY(-10px) scale(0.95);
}

.notification-enter-active,
.notification-leave-active {
  transition: all 0.3s ease;
}

.notification-enter-from {
  opacity: 0;
  transform: translateX(30px);
}

.notification-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}

.notification-move {
  transition: transform 0.3s ease;
}

/* Responsividade */
@media (max-width: 768px) {
  .notification-panel {
    width: 350px;
    max-width: calc(100vw - 2rem);
  }
}

@media (max-width: 480px) {
  .notification-panel {
    width: 300px;
    right: -50px;
  }
}
</style>