import { supabase, DB_TABLES } from '@/config/supabase'
import type { User } from '@/types/auth'

export class AuthService {
  private currentUser: User | null = null

  constructor() {
    // Inicializar usuário do localStorage ao criar o serviço
    this.loadUserFromStorage()
  }

  private loadUserFromStorage() {
    try {
      const userSession = localStorage.getItem('userSession')
      if (userSession) {
        this.currentUser = JSON.parse(userSession)
        console.log('✅ Usuário carregado do localStorage:', this.currentUser?.username)
      }
    } catch (error) {
      console.error('❌ Erro ao carregar usuário do localStorage:', error)
      localStorage.removeItem('userSession')
    }
  }

  async hashPassword(password: string): Promise<string> {
    let hash = 0
    const saltedPassword = password + 'gestaozesystem_salt_2025'

    for (let i = 0; i < saltedPassword.length; i++) {
      const char = saltedPassword.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash
    }

    return Math.abs(hash).toString(16)
  }

  async login(username: string, password: string) {
    try {
      const hashedPassword = await this.hashPassword(password)

      const { data, error } = await supabase
        .from(DB_TABLES.USERS)
        .select('*')
        .eq('username', username)
        .eq('is_active', true)
        .single()

      if (error || !data) {
        throw new Error('Usuário não encontrado')
      }

      const storedHash = data.password_hash || data.senha
      if (!storedHash || storedHash !== hashedPassword) {
        throw new Error('Senha incorreta')
      }

      const userSession: User = {
        id: data.id,
        username: data.username,
        email: data.email,
        name: data.name,
        role: data.role
      }

      localStorage.setItem('userSession', JSON.stringify(userSession))
      this.currentUser = userSession

      return { success: true, user: userSession }
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      }
    }
  }

  async logout() {
    localStorage.removeItem('userSession')
    this.currentUser = null
    return { success: true }
  }

  getCurrentUser(): User | null {
    // Se não tiver usuário em memória, tenta recarregar do localStorage
    if (!this.currentUser) {
      this.loadUserFromStorage()
    }
    return this.currentUser
  }

  isAuthenticated(): boolean {
    return this.getCurrentUser() !== null
  }
}

export const authService = new AuthService()