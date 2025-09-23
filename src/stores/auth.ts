import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '@/services/authService'
import type { User, LoginCredentials } from '@/types/auth'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const loading = ref(false)

  const isAuthenticated = computed(() => !!user.value)

  async function login(credentials: LoginCredentials) {
    loading.value = true
    try {
      const result = await authService.login(credentials.username, credentials.password)
      if (result.success && result.user) {
        user.value = result.user
      }
      return result
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    await authService.logout()
    user.value = null
  }

  return {
    user,
    loading,
    isAuthenticated,
    login,
    logout
  }
})