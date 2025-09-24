import { supabase, DB_TABLES } from '@/config/supabase'
import { authService } from '@/services/authService'

export interface UserProfile {
  id: string
  name: string
  username: string
  email: string
  role: string
  avatar_url?: string
  preferences: {
    emailNotifications: boolean
    pushNotifications: boolean
    darkMode: boolean
    language: string
  }
  created_at: string
  updated_at: string
  last_login_at?: string
  login_count: number
}

export interface UserStats {
  loginCount: number
  daysActive: number
  actionsCount: number
  lastLogin: string
  accountAge: number
}

export interface SecurityStatus {
  strongPassword: boolean
  emailVerified: boolean
  recentActivity: boolean
}

class ProfileService {
  private getCurrentUser() {
    const user = authService.getCurrentUser()
    if (!user) {
      throw new Error('Usuário não autenticado')
    }
    return user
  }

  async loadUserProfile(): Promise<UserProfile> {
    try {
      const user = this.getCurrentUser()

      const { data, error } = await supabase
        .from(DB_TABLES.USERS)
        .select(`
          id,
          name,
          username,
          email,
          role,
          avatar_url,
          preferences,
          created_at,
          updated_at,
          last_login_at,
          login_count
        `)
        .eq('id', user.id)
        .single()

      if (error) {
        throw new Error(`Erro ao carregar perfil: ${error.message}`)
      }

      // Se não tem preferências salvas, usar padrões
      const defaultPreferences = {
        emailNotifications: true,
        pushNotifications: true,
        darkMode: false,
        language: 'pt-BR'
      }

      return {
        ...data,
        preferences: data.preferences || defaultPreferences,
        login_count: data.login_count || 0
      }
    } catch (error) {
      console.error('Erro ao carregar perfil:', error)
      throw error
    }
  }

  async updateUserProfile(profileData: Partial<UserProfile>): Promise<void> {
    try {
      const user = this.getCurrentUser()

      const { error } = await supabase
        .from(DB_TABLES.USERS)
        .update({
          name: profileData.name,
          username: profileData.username,
          email: profileData.email,
          role: profileData.role,
          preferences: profileData.preferences,
          updated_at: new Date().toISOString()
        })
        .eq('id', user.id)

      if (error) {
        throw new Error(`Erro ao atualizar perfil: ${error.message}`)
      }

      console.log('✅ Perfil atualizado com sucesso')
    } catch (error) {
      console.error('❌ Erro ao atualizar perfil:', error)
      throw error
    }
  }

  async updatePassword(currentPassword: string, newPassword: string): Promise<void> {
    try {
      const user = this.getCurrentUser()

      // Verificar senha atual
      const hashedCurrentPassword = await authService.hashPassword(currentPassword)

      const { data, error: verifyError } = await supabase
        .from(DB_TABLES.USERS)
        .select('password_hash, senha')
        .eq('id', user.id)
        .single()

      if (verifyError) {
        throw new Error('Erro ao verificar senha atual')
      }

      const storedHash = data.password_hash || data.senha
      if (!storedHash || storedHash !== hashedCurrentPassword) {
        throw new Error('Senha atual incorreta')
      }

      // Atualizar com nova senha
      const hashedNewPassword = await authService.hashPassword(newPassword)

      const { error: updateError } = await supabase
        .from(DB_TABLES.USERS)
        .update({
          password_hash: hashedNewPassword,
          senha: hashedNewPassword, // Compatibilidade
          updated_at: new Date().toISOString()
        })
        .eq('id', user.id)

      if (updateError) {
        throw new Error(`Erro ao atualizar senha: ${updateError.message}`)
      }

      console.log('✅ Senha atualizada com sucesso')
    } catch (error) {
      console.error('❌ Erro ao atualizar senha:', error)
      throw error
    }
  }

  async getUserStats(): Promise<UserStats> {
    try {
      const user = this.getCurrentUser()

      // Buscar dados básicos do usuário
      const { data: userData, error: userError } = await supabase
        .from(DB_TABLES.USERS)
        .select('created_at, last_login_at, login_count')
        .eq('id', user.id)
        .single()

      if (userError) {
        throw new Error(`Erro ao buscar dados do usuário: ${userError.message}`)
      }

      // Calcular estatísticas
      const createdDate = new Date(userData.created_at)
      const now = new Date()
      const accountAge = Math.floor((now.getTime() - createdDate.getTime()) / (1000 * 60 * 60 * 24))

      // Buscar contagem de ações (movimentações, logs, etc.)
      let actionsCount = 0

      try {
        // Contar movimentações
        const { data: movements } = await supabase
          .from(DB_TABLES.MOVEMENTS)
          .select('id', { count: 'exact', head: true })
          .eq('user_id', user.id)

        // Contar logs
        const { data: logs } = await supabase
          .from(DB_TABLES.LOGS)
          .select('id', { count: 'exact', head: true })
          .eq('user_id', user.id)

        actionsCount = (movements?.length || 0) + (logs?.length || 0)
      } catch (error) {
        console.warn('Erro ao contar ações:', error)
      }

      return {
        loginCount: userData.login_count || 0,
        daysActive: accountAge,
        actionsCount,
        lastLogin: userData.last_login_at || userData.created_at,
        accountAge
      }
    } catch (error) {
      console.error('Erro ao buscar estatísticas:', error)
      // Retornar dados padrão em caso de erro
      return {
        loginCount: 0,
        daysActive: 0,
        actionsCount: 0,
        lastLogin: new Date().toISOString(),
        accountAge: 0
      }
    }
  }

  async getSecurityStatus(): Promise<SecurityStatus> {
    try {
      const user = this.getCurrentUser()

      const { data, error } = await supabase
        .from(DB_TABLES.USERS)
        .select('password_hash, senha, email, last_login_at')
        .eq('id', user.id)
        .single()

      if (error) {
        console.warn('Erro ao buscar status de segurança:', error)
        return { strongPassword: false, emailVerified: false, recentActivity: false }
      }

      // Verificar senha forte (simplificado)
      const hasPassword = !!(data.password_hash || data.senha)

      // Verificar email
      const hasEmail = !!data.email && data.email.includes('@')

      // Verificar atividade recente (últimos 30 dias)
      const lastLogin = data.last_login_at ? new Date(data.last_login_at) : new Date()
      const daysSinceLogin = (new Date().getTime() - lastLogin.getTime()) / (1000 * 60 * 60 * 24)
      const recentActivity = daysSinceLogin <= 30

      return {
        strongPassword: hasPassword,
        emailVerified: hasEmail,
        recentActivity
      }
    } catch (error) {
      console.error('Erro ao verificar status de segurança:', error)
      return { strongPassword: false, emailVerified: false, recentActivity: false }
    }
  }

  async updateLoginCount(): Promise<void> {
    try {
      const user = this.getCurrentUser()

      const { error } = await supabase
        .from(DB_TABLES.USERS)
        .update({
          login_count: supabase.sql`COALESCE(login_count, 0) + 1`,
          last_login_at: new Date().toISOString()
        })
        .eq('id', user.id)

      if (error) {
        console.warn('Erro ao atualizar contador de login:', error)
      }
    } catch (error) {
      console.warn('Erro ao atualizar login:', error)
    }
  }

  async uploadAvatar(file: File): Promise<string> {
    try {
      const user = this.getCurrentUser()
      const fileExt = file.name.split('.').pop()
      const fileName = `${user.id}_${Date.now()}.${fileExt}`
      const filePath = `avatars/${fileName}`

      // Upload para Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('user-avatars')
        .upload(filePath, file)

      if (uploadError) {
        throw new Error(`Erro no upload: ${uploadError.message}`)
      }

      // Obter URL pública
      const { data: { publicUrl } } = supabase.storage
        .from('user-avatars')
        .getPublicUrl(filePath)

      // Atualizar perfil com nova URL do avatar
      const { error: updateError } = await supabase
        .from(DB_TABLES.USERS)
        .update({ avatar_url: publicUrl })
        .eq('id', user.id)

      if (updateError) {
        throw new Error(`Erro ao salvar avatar: ${updateError.message}`)
      }

      return publicUrl
    } catch (error) {
      console.error('❌ Erro no upload do avatar:', error)
      throw error
    }
  }

  async ensureUserColumns(): Promise<void> {
    // Esta função não pode ser executada diretamente via JS
    // O SQL deve ser executado manualmente no Supabase
    console.log(`
🔧 Execute este SQL no Supabase para adicionar colunas necessárias:

ALTER TABLE ${DB_TABLES.USERS}
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS login_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP WITH TIME ZONE;

-- Criar bucket para avatars se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('user-avatars', 'user-avatars', true)
ON CONFLICT (id) DO NOTHING;
    `)
  }
}

export const profileService = new ProfileService()