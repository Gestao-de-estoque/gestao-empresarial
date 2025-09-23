import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface Notification {
  id: string
  title: string
  message: string
  type: 'info' | 'success' | 'warning' | 'error'
  category: 'system' | 'stock' | 'sales' | 'security' | 'ai'
  timestamp: Date
  read: boolean
  persistent?: boolean
  actionText?: string
  actionRoute?: string
  icon?: string
}

export const useNotificationsStore = defineStore('notifications', () => {
  const notifications = ref<Notification[]>([])
  const isEnabled = ref(true)
  const soundEnabled = ref(true)

  // Computed properties
  const unreadCount = computed(() =>
    notifications.value.filter(n => !n.read).length
  )

  const recentNotifications = computed(() =>
    notifications.value
      .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
      .slice(0, 5)
  )

  const notificationsByCategory = computed(() => {
    const categories: Record<string, Notification[]> = {}
    notifications.value.forEach(notification => {
      if (!categories[notification.category]) {
        categories[notification.category] = []
      }
      categories[notification.category].push(notification)
    })
    return categories
  })

  // Actions
  function addNotification(notification: Omit<Notification, 'id' | 'timestamp' | 'read'>) {
    const newNotification: Notification = {
      id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
      timestamp: new Date(),
      read: false,
      ...notification
    }

    notifications.value.unshift(newNotification)

    // Play sound if enabled
    if (soundEnabled.value && isEnabled.value) {
      playNotificationSound(notification.type)
    }

    // Show browser notification if permission granted
    if (isEnabled.value && 'Notification' in window && Notification.permission === 'granted') {
      showBrowserNotification(newNotification)
    }

    // Auto-remove non-persistent notifications after 5 seconds
    if (!notification.persistent) {
      setTimeout(() => {
        removeNotification(newNotification.id)
      }, 5000)
    }

    return newNotification.id
  }

  function removeNotification(id: string) {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index > -1) {
      notifications.value.splice(index, 1)
    }
  }

  function markAsRead(id: string) {
    const notification = notifications.value.find(n => n.id === id)
    if (notification) {
      notification.read = true
    }
  }

  function markAllAsRead() {
    notifications.value.forEach(notification => {
      notification.read = true
    })
  }

  function clearAll() {
    notifications.value = []
  }

  function clearRead() {
    notifications.value = notifications.value.filter(n => !n.read)
  }

  // Notification helpers
  function success(title: string, message: string, options?: Partial<Notification>) {
    return addNotification({
      title,
      message,
      type: 'success',
      category: 'system',
      icon: 'CheckCircle',
      ...options
    })
  }

  function error(title: string, message: string, options?: Partial<Notification>) {
    return addNotification({
      title,
      message,
      type: 'error',
      category: 'system',
      icon: 'AlertCircle',
      persistent: true,
      ...options
    })
  }

  function warning(title: string, message: string, options?: Partial<Notification>) {
    return addNotification({
      title,
      message,
      type: 'warning',
      category: 'system',
      icon: 'AlertTriangle',
      ...options
    })
  }

  function info(title: string, message: string, options?: Partial<Notification>) {
    return addNotification({
      title,
      message,
      type: 'info',
      category: 'system',
      icon: 'Info',
      ...options
    })
  }

  // Stock-specific notifications
  function lowStock(productName: string, currentStock: number, minStock: number) {
    return addNotification({
      title: 'Estoque Baixo',
      message: `${productName} está com estoque baixo (${currentStock}/${minStock})`,
      type: 'warning',
      category: 'stock',
      icon: 'Package',
      persistent: true,
      actionText: 'Ver Produto',
      actionRoute: '/inventory'
    })
  }

  function outOfStock(productName: string) {
    return addNotification({
      title: 'Produto Esgotado',
      message: `${productName} está sem estoque`,
      type: 'error',
      category: 'stock',
      icon: 'PackageX',
      persistent: true,
      actionText: 'Reabastecer',
      actionRoute: '/inventory'
    })
  }

  function stockReplenished(productName: string, quantity: number) {
    return addNotification({
      title: 'Estoque Reabastecido',
      message: `${productName} foi reabastecido com ${quantity} unidades`,
      type: 'success',
      category: 'stock',
      icon: 'PackagePlus'
    })
  }

  // AI notifications
  function aiAnalysisReady(analysisType: string) {
    return addNotification({
      title: 'Análise IA Concluída',
      message: `Sua análise de ${analysisType} está pronta`,
      type: 'info',
      category: 'ai',
      icon: 'Brain',
      actionText: 'Ver Análise',
      actionRoute: '/ai'
    })
  }

  function aiRecommendation(title: string, message: string) {
    return addNotification({
      title: `Recomendação IA: ${title}`,
      message,
      type: 'info',
      category: 'ai',
      icon: 'Lightbulb',
      persistent: true,
      actionText: 'Ver Detalhes',
      actionRoute: '/ai'
    })
  }

  // Security notifications
  function securityAlert(title: string, message: string) {
    return addNotification({
      title: `Alerta de Segurança: ${title}`,
      message,
      type: 'error',
      category: 'security',
      icon: 'Shield',
      persistent: true
    })
  }

  // Browser notification support
  async function requestPermission() {
    if ('Notification' in window) {
      const permission = await Notification.requestPermission()
      return permission === 'granted'
    }
    return false
  }

  function showBrowserNotification(notification: Notification) {
    if ('Notification' in window && Notification.permission === 'granted') {
      const browserNotification = new Notification(notification.title, {
        body: notification.message,
        icon: '/favicon.ico',
        badge: '/favicon.ico',
        tag: notification.id,
        requireInteraction: notification.persistent
      })

      browserNotification.onclick = () => {
        window.focus()
        markAsRead(notification.id)
        browserNotification.close()
      }

      // Auto close after 5 seconds if not persistent
      if (!notification.persistent) {
        setTimeout(() => {
          browserNotification.close()
        }, 5000)
      }
    }
  }

  function playNotificationSound(type: Notification['type']) {
    try {
      const audio = new Audio()

      switch (type) {
        case 'success':
          audio.src = 'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+j2xHkpBSl+zPLaizsIHGu18qCkTQ0PUarg7q9lGgU'
          break
        case 'warning':
          audio.src = 'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+j2xHkpBSl+zPLaizsIHGu18qCkTQ0PUarr7q9lGgU'
          break
        case 'error':
          audio.src = 'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+j2xHkpBSl+zPLaizsIHGu18qCkTQ0PUarj7q9lGgU'
          break
        default:
          audio.src = 'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+j2xHkpBSl+zPLaizsIHGu18qCkTQ0PUarh7q9lGgU'
      }

      audio.volume = 0.3
      audio.play().catch(() => {
        // Ignore audio play errors (browser restrictions)
      })
    } catch (error) {
      // Ignore audio errors
    }
  }

  // Settings
  function toggleEnabled() {
    isEnabled.value = !isEnabled.value
  }

  function toggleSound() {
    soundEnabled.value = !soundEnabled.value
  }

  // Simulate real-time notifications for demo
  function startSimulation() {
    const notifications = [
      {
        title: 'Estoque Baixo',
        message: 'Açúcar está com estoque baixo (3/10 unidades)',
        type: 'warning' as const,
        category: 'stock' as const
      },
      {
        title: 'Análise IA Concluída',
        message: 'Sua análise semanal de vendas está pronta',
        type: 'info' as const,
        category: 'ai' as const
      },
      {
        title: 'Produto Adicionado',
        message: 'Novo produto "Café Premium" foi adicionado ao catálogo',
        type: 'success' as const,
        category: 'system' as const
      },
      {
        title: 'Recomendação IA',
        message: 'Considere comprar mais farinha de trigo baseado no consumo atual',
        type: 'info' as const,
        category: 'ai' as const
      }
    ]

    let index = 0
    const interval = setInterval(() => {
      if (index >= notifications.length) {
        clearInterval(interval)
        return
      }

      addNotification(notifications[index])
      index++
    }, 3000)
  }

  return {
    // State
    notifications,
    isEnabled,
    soundEnabled,

    // Computed
    unreadCount,
    recentNotifications,
    notificationsByCategory,

    // Actions
    addNotification,
    removeNotification,
    markAsRead,
    markAllAsRead,
    clearAll,
    clearRead,

    // Helpers
    success,
    error,
    warning,
    info,
    lowStock,
    outOfStock,
    stockReplenished,
    aiAnalysisReady,
    aiRecommendation,
    securityAlert,

    // Browser support
    requestPermission,

    // Settings
    toggleEnabled,
    toggleSound,

    // Demo
    startSimulation
  }
})