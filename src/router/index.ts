import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import LoginView from '@/views/LoginView.vue'
import DashboardView from '@/views/DashboardView.vue'
import InventoryView from '@/views/InventoryView.vue'
import AIView from '@/views/AIView.vue'
import ProfileView from '@/views/ProfileView.vue'
import ReportsView from '@/views/ReportsView.vue'
import LogsView from '@/views/LogsView.vue'
import SuppliersView from '@/views/SuppliersView.vue'
import MenuView from '@/views/MenuView.vue'
import SettingsView from '@/views/SettingsView.vue'
import AboutView from '@/views/AboutView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/dashboard'
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView,
      meta: { requiresGuest: true }
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: DashboardView,
      meta: { requiresAuth: true }
    },
    {
      path: '/inventory',
      name: 'inventory',
      component: InventoryView,
      meta: { requiresAuth: true }
    },
    {
      path: '/ai',
      name: 'ai',
      component: AIView,
      meta: { requiresAuth: true }
    },
    {
      path: '/profile',
      name: 'profile',
      component: ProfileView,
      meta: { requiresAuth: true }
    },
    {
      path: '/reports',
      name: 'reports',
      component: ReportsView,
      meta: { requiresAuth: true }
    },
    {
      path: '/logs',
      name: 'logs',
      component: LogsView,
      meta: { requiresAuth: true }
    },
    {
      path: '/suppliers',
      name: 'suppliers',
      component: SuppliersView,
      meta: { requiresAuth: true }
    },
    {
      path: '/menu',
      name: 'menu',
      component: MenuView,
      meta: { requiresAuth: true }
    },
    {
      path: '/settings',
      name: 'settings',
      component: SettingsView,
      meta: { requiresAuth: true }
    },
    {
      path: '/about',
      name: 'about',
      component: AboutView,
      meta: { requiresAuth: true }
    }
  ]
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore()

  // Check stored session
  const stored = localStorage.getItem('userSession')
  if (stored && !authStore.user) {
    authStore.user = JSON.parse(stored)
  }

  const isAuthenticated = authStore.isAuthenticated

  if (to.meta.requiresAuth && !isAuthenticated) {
    return '/login'
  }

  if (to.meta.requiresGuest && isAuthenticated) {
    return '/dashboard'
  }
})

export default router