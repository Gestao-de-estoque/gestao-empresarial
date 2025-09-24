import { supabase, DB_TABLES } from '@/config/supabase'
import { authService } from '@/services/authService'

export interface AppSettings {
  general: {
    companyName: string
    cnpj: string
    phone: string
    address: string
    currency: string
    timezone: string
    autoBackup: boolean
    notifications: boolean
  }
  inventory: {
    lowStockThreshold: number
    expirationDays: number
    autoReorder: boolean
    trackBatches: boolean
    requireNotes: boolean
    autoCalculateCost: boolean
  }
  notifications: {
    email: string
    lowStock: boolean
    outOfStock: boolean
    expiringProducts: boolean
    systemUpdates: boolean
    dailyReportTime: string
    weeklyReportDay: string
  }
  security: {
    sessionTimeout: number
    maxLoginAttempts: number
    requireStrongPassword: boolean
    logUserActivity: boolean
    backupFrequency: string
    backupRetention: number
  }
  interface: {
    theme: string
    primaryColor: string
    density: string
    showWelcome: boolean
    showMetrics: boolean
    showRecentActivity: boolean
  }
  advanced: {
    apiKey: string
    enableApi: boolean
    enableWebhooks: boolean
    cacheTtl: number
    queryLimit: number
    enableDebugMode: boolean
  }
}

export interface SettingsRow {
  id?: string
  user_id: string
  section: string
  settings: Record<string, any>
  created_at?: string
  updated_at?: string
}

class SettingsService {
  private getCurrentUser() {
    // Primeiro tenta pegar do authService
    const currentUser = authService.getCurrentUser()
    if (currentUser) {
      return currentUser
    }

    // Se não encontrar, tenta do localStorage
    const userSession = localStorage.getItem('userSession')
    if (userSession) {
      try {
        const user = JSON.parse(userSession)
        return user
      } catch (error) {
        console.error('Erro ao parse do userSession:', error)
      }
    }

    throw new Error('Usuário não autenticado. Faça login primeiro.')
  }

  async loadSettings(): Promise<AppSettings> {
    try {
      const user = this.getCurrentUser()

      const { data, error } = await supabase
        .from(DB_TABLES.SETTINGS)
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

      if (error) {
        console.error('Erro ao carregar configurações:', error)
        return this.getDefaultSettings()
      }

      if (!data || data.length === 0) {
        console.log('Nenhuma configuração encontrada, usando padrões')
        return this.getDefaultSettings()
      }

      // Reconstrói as configurações a partir das linhas do banco
      const settings = this.getDefaultSettings()

      data.forEach((row: SettingsRow) => {
        if (settings[row.section as keyof AppSettings]) {
          Object.assign(settings[row.section as keyof AppSettings], row.settings)
        }
      })

      return settings
    } catch (error) {
      console.error('Erro ao carregar configurações:', error)
      return this.getDefaultSettings()
    }
  }

  async saveSettings(settings: AppSettings): Promise<void> {
    try {
      const user = this.getCurrentUser()

      // Primeiro, remove todas as configurações existentes do usuário
      const { error: deleteError } = await supabase
        .from(DB_TABLES.SETTINGS)
        .delete()
        .eq('user_id', user.id)

      if (deleteError) {
        console.error('Erro ao limpar configurações antigas:', deleteError)
      }

      // Prepara os dados para inserção
      const settingsRows: Omit<SettingsRow, 'id' | 'created_at' | 'updated_at'>[] = []

      Object.entries(settings).forEach(([section, sectionSettings]) => {
        settingsRows.push({
          user_id: user.id,
          section,
          settings: sectionSettings
        })
      })

      // Insere as novas configurações
      const { error: insertError } = await supabase
        .from(DB_TABLES.SETTINGS)
        .insert(settingsRows)

      if (insertError) {
        throw new Error(`Erro ao salvar configurações: ${insertError.message}`)
      }

      console.log('✅ Configurações salvas com sucesso no banco de dados')
    } catch (error) {
      console.error('❌ Erro ao salvar configurações:', error)
      throw error
    }
  }

  async saveSection(section: keyof AppSettings, sectionSettings: any): Promise<void> {
    try {
      const user = this.getCurrentUser()

      // Atualiza ou insere apenas uma seção específica
      const { error: upsertError } = await supabase
        .from(DB_TABLES.SETTINGS)
        .upsert({
          user_id: user.id,
          section,
          settings: sectionSettings
        }, {
          onConflict: 'user_id,section'
        })

      if (upsertError) {
        throw new Error(`Erro ao salvar seção ${section}: ${upsertError.message}`)
      }

      console.log(`✅ Seção ${section} salva com sucesso`)
    } catch (error) {
      console.error(`❌ Erro ao salvar seção ${section}:`, error)
      throw error
    }
  }

  private getDefaultSettings(): AppSettings {
    return {
      general: {
        companyName: 'Pedacinho do Céu',
        cnpj: '',
        phone: '',
        address: '',
        currency: 'BRL',
        timezone: 'America/Sao_Paulo',
        autoBackup: true,
        notifications: true
      },
      inventory: {
        lowStockThreshold: 20,
        expirationDays: 30,
        autoReorder: false,
        trackBatches: false,
        requireNotes: false,
        autoCalculateCost: true
      },
      notifications: {
        email: '',
        lowStock: true,
        outOfStock: true,
        expiringProducts: true,
        systemUpdates: false,
        dailyReportTime: '08:00',
        weeklyReportDay: 'monday'
      },
      security: {
        sessionTimeout: 60,
        maxLoginAttempts: 3,
        requireStrongPassword: true,
        logUserActivity: true,
        backupFrequency: 'daily',
        backupRetention: 30
      },
      interface: {
        theme: 'light',
        primaryColor: 'blue',
        density: 'normal',
        showWelcome: true,
        showMetrics: true,
        showRecentActivity: true
      },
      advanced: {
        apiKey: this.generateApiKey(),
        enableApi: false,
        enableWebhooks: false,
        cacheTtl: 3600,
        queryLimit: 100,
        enableDebugMode: false
      }
    }
  }

  private generateApiKey(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    let result = 'sk_live_'
    for (let i = 0; i < 20; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    return result
  }

  async createSettingsTable(): Promise<void> {
    console.log('🔧 Verificando se a tabela de configurações existe...')

    // Esta função é para documentação - a tabela deve ser criada via SQL no Supabase
    const createTableSQL = `
      CREATE TABLE IF NOT EXISTS app_settings (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
        section VARCHAR(50) NOT NULL,
        settings JSONB NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(user_id, section)
      );

      -- Índices para performance
      CREATE INDEX IF NOT EXISTS idx_app_settings_user_id ON app_settings(user_id);
      CREATE INDEX IF NOT EXISTS idx_app_settings_section ON app_settings(section);

      -- Trigger para atualizar updated_at automaticamente
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
      END;
      $$ language 'plpgsql';

      DROP TRIGGER IF EXISTS update_app_settings_updated_at ON app_settings;
      CREATE TRIGGER update_app_settings_updated_at
        BEFORE UPDATE ON app_settings
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

      -- RLS (Row Level Security) para segurança
      ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

      DROP POLICY IF EXISTS "Users can only access their own settings" ON app_settings;
      CREATE POLICY "Users can only access their own settings" ON app_settings
        FOR ALL USING (auth.uid() = user_id);
    `

    console.log('📋 SQL para criar tabela de configurações:')
    console.log(createTableSQL)
  }

  async testConnection(): Promise<boolean> {
    try {
      const { error } = await supabase
        .from(DB_TABLES.SETTINGS)
        .select('*', { count: 'exact', head: true })
        .limit(1)

      return !error
    } catch (error) {
      console.error('Erro ao testar conexão com tabela de configurações:', error)
      return false
    }
  }
}

export const settingsService = new SettingsService()