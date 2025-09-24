// SERVIÇO ALTERNATIVO DE CONFIGURAÇÕES
// Use este serviço caso haja problemas persistentes com RLS

import { supabase, DB_TABLES } from '@/config/supabase'
import { authService } from '@/services/authService'

// Salvar configurações na própria tabela de usuários (coluna extra)
export class AlternativeSettingsService {

  private getCurrentUser() {
    const user = authService.getCurrentUser()
    if (!user) {
      throw new Error('Usuário não autenticado')
    }
    return user
  }

  async saveSettingsInUserTable(settings: any): Promise<void> {
    try {
      const user = this.getCurrentUser()

      // Salvar configurações como JSONB na tabela admin_users
      const { error } = await supabase
        .from(DB_TABLES.USERS)
        .update({ app_settings: settings })
        .eq('id', user.id)

      if (error) {
        throw new Error(`Erro ao salvar configurações: ${error.message}`)
      }

      console.log('✅ Configurações salvas na tabela de usuários')
    } catch (error) {
      console.error('❌ Erro ao salvar configurações alternativas:', error)
      throw error
    }
  }

  async loadSettingsFromUserTable(): Promise<any> {
    try {
      const user = this.getCurrentUser()

      const { data, error } = await supabase
        .from(DB_TABLES.USERS)
        .select('app_settings')
        .eq('id', user.id)
        .single()

      if (error) {
        throw new Error(`Erro ao carregar configurações: ${error.message}`)
      }

      return data?.app_settings || {}
    } catch (error) {
      console.error('❌ Erro ao carregar configurações alternativas:', error)
      throw error
    }
  }

  async saveToLocalStorage(settings: any): Promise<void> {
    try {
      const user = this.getCurrentUser()
      const key = `app_settings_${user.id}`
      localStorage.setItem(key, JSON.stringify(settings))
      console.log('✅ Configurações salvas no localStorage')
    } catch (error) {
      console.error('❌ Erro ao salvar no localStorage:', error)
      throw error
    }
  }

  async loadFromLocalStorage(): Promise<any> {
    try {
      const user = this.getCurrentUser()
      const key = `app_settings_${user.id}`
      const saved = localStorage.getItem(key)

      if (saved) {
        return JSON.parse(saved)
      }

      return {}
    } catch (error) {
      console.error('❌ Erro ao carregar do localStorage:', error)
      return {}
    }
  }

  // Método que tenta múltiplas estratégias
  async hybridSave(settings: any): Promise<void> {
    const user = this.getCurrentUser()
    console.log(`💾 Salvando configurações para usuário: ${user.username}`)

    const results = []

    // Estratégia 1: Tentar tabela app_settings
    try {
      const { error } = await supabase
        .from('app_settings')
        .upsert({
          user_id: user.id,
          section: 'all',
          settings
        }, { onConflict: 'user_id,section' })

      if (!error) {
        results.push('✅ Salvo na tabela app_settings')
      } else {
        results.push(`❌ Erro na app_settings: ${error.message}`)
      }
    } catch (error: any) {
      results.push(`❌ Erro na app_settings: ${error.message}`)
    }

    // Estratégia 2: Salvar na tabela de usuários
    try {
      await this.saveSettingsInUserTable(settings)
      results.push('✅ Salvo na tabela admin_users')
    } catch (error: any) {
      results.push(`❌ Erro na admin_users: ${error.message}`)
    }

    // Estratégia 3: localStorage (sempre funciona)
    try {
      await this.saveToLocalStorage(settings)
      results.push('✅ Salvo no localStorage')
    } catch (error: any) {
      results.push(`❌ Erro no localStorage: ${error.message}`)
    }

    console.log('📊 Resultados do salvamento híbrido:', results)

    // Se pelo menos uma estratégia funcionou, considerar sucesso
    const successCount = results.filter(r => r.includes('✅')).length
    if (successCount === 0) {
      throw new Error('Todas as estratégias de salvamento falharam')
    }
  }

  async hybridLoad(): Promise<any> {
    const user = this.getCurrentUser()
    console.log(`📖 Carregando configurações para usuário: ${user.username}`)

    // Estratégia 1: Tentar tabela app_settings
    try {
      const { data, error } = await supabase
        .from('app_settings')
        .select('settings')
        .eq('user_id', user.id)
        .eq('section', 'all')
        .single()

      if (!error && data?.settings) {
        console.log('✅ Configurações carregadas da app_settings')
        return data.settings
      }
    } catch (error) {
      console.log('⚠️ app_settings não disponível, tentando próxima estratégia')
    }

    // Estratégia 2: Carregar da tabela de usuários
    try {
      const settings = await this.loadSettingsFromUserTable()
      if (Object.keys(settings).length > 0) {
        console.log('✅ Configurações carregadas da admin_users')
        return settings
      }
    } catch (error) {
      console.log('⚠️ admin_users não disponível, tentando próxima estratégia')
    }

    // Estratégia 3: localStorage
    try {
      const settings = await this.loadFromLocalStorage()
      if (Object.keys(settings).length > 0) {
        console.log('✅ Configurações carregadas do localStorage')
        return settings
      }
    } catch (error) {
      console.log('⚠️ localStorage não disponível')
    }

    console.log('📝 Nenhuma configuração encontrada, usando padrões')
    return {}
  }
}

export const alternativeSettingsService = new AlternativeSettingsService()