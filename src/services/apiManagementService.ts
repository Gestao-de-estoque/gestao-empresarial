import { supabase, DB_TABLES } from '@/config/supabase'

export interface APIKey {
  id: string
  name: string
  key: string
  description?: string
  status: 'active' | 'inactive'
  created_at: string
  updated_at: string
  last_used?: string
  request_count: number
  rate_limit: number
  allowed_origins?: string[]
  permissions: string[]
}

export interface APIRequest {
  id: string
  api_key_id: string
  method: string
  endpoint: string
  status_code: number
  response_time: number
  ip_address: string
  user_agent: string
  request_body?: any
  response_body?: any
  created_at: string
}

export interface APIMetrics {
  total_keys: number
  active_keys: number
  requests_per_hour: number
  average_response_time: number
  success_rate: number
  uptime_percentage: number
  last_24h_requests: number
  errors_count: number
}

export interface APIStats {
  totalKeys: number
  requests: number
  uptime: number
  errors: number
  avgResponseTime: number
}

export const apiManagementService = {
  // Buscar todas as chaves de API
  async getAPIKeys(): Promise<APIKey[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.API_KEYS)
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar chaves API:', error)
      throw error
    }
  },

  // Criar nova chave de API
  async createAPIKey(keyData: {
    name: string
    description?: string
    permissions?: string[]
    rate_limit?: number
    allowed_origins?: string[]
  }): Promise<APIKey> {
    try {
      // Gerar chave única
      const apiKey = this.generateAPIKey()

      const newKey = {
        id: crypto.randomUUID(),
        name: keyData.name,
        key: apiKey,
        description: keyData.description || '',
        status: 'active' as const,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        request_count: 0,
        rate_limit: keyData.rate_limit || 1000,
        allowed_origins: keyData.allowed_origins || [],
        permissions: keyData.permissions || ['read']
      }

      const { data, error } = await supabase
        .from(DB_TABLES.API_KEYS)
        .insert([newKey])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar chave API:', error)
      throw error
    }
  },

  // Atualizar chave de API
  async updateAPIKey(id: string, updates: Partial<APIKey>): Promise<APIKey> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.API_KEYS)
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao atualizar chave API:', error)
      throw error
    }
  },

  // Excluir chave de API
  async deleteAPIKey(id: string): Promise<boolean> {
    try {
      const { error } = await supabase
        .from(DB_TABLES.API_KEYS)
        .delete()
        .eq('id', id)

      if (error) throw error
      return true
    } catch (error) {
      console.error('Erro ao excluir chave API:', error)
      throw error
    }
  },

  // Registrar requisição da API
  async logAPIRequest(request: {
    api_key_id: string
    method: string
    endpoint: string
    status_code: number
    response_time: number
    ip_address: string
    user_agent?: string
    request_body?: any
    response_body?: any
  }): Promise<APIRequest> {
    try {
      const logEntry = {
        id: crypto.randomUUID(),
        ...request,
        created_at: new Date().toISOString()
      }

      const { data, error } = await supabase
        .from(DB_TABLES.API_REQUESTS)
        .insert([logEntry])
        .select()
        .single()

      if (error) throw error

      // Incrementar contador de requisições da chave
      await this.incrementKeyRequestCount(request.api_key_id)

      return data
    } catch (error) {
      console.error('Erro ao registrar requisição API:', error)
      throw error
    }
  },

  // Buscar logs de requisições
  async getAPILogs(limit = 50, apiKeyId?: string): Promise<APIRequest[]> {
    try {
      let query = supabase
        .from(DB_TABLES.API_REQUESTS)
        .select(`
          *,
          api_keys!api_key_id(name, key)
        `)
        .order('created_at', { ascending: false })
        .limit(limit)

      if (apiKeyId) {
        query = query.eq('api_key_id', apiKeyId)
      }

      const { data, error } = await query

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar logs API:', error)
      throw error
    }
  },

  // Buscar métricas da API
  async getAPIMetrics(): Promise<APIStats> {
    try {
      // Buscar estatísticas das chaves
      const { data: keys, error: keysError } = await supabase
        .from(DB_TABLES.API_KEYS)
        .select('*')

      if (keysError) throw keysError

      // Buscar requisições das últimas 24 horas
      const yesterday = new Date()
      yesterday.setDate(yesterday.getDate() - 1)

      const { data: recentRequests, error: requestsError } = await supabase
        .from(DB_TABLES.API_REQUESTS)
        .select('*')
        .gte('created_at', yesterday.toISOString())

      if (requestsError) throw requestsError

      // Calcular métricas
      const totalKeys = keys?.length || 0
      const activeKeys = keys?.filter(k => k.status === 'active').length || 0
      const last24hRequests = recentRequests?.length || 0
      const requestsPerHour = Math.round(last24hRequests / 24)

      // Calcular taxa de sucesso
      const successfulRequests = recentRequests?.filter(r => r.status_code >= 200 && r.status_code < 400).length || 0
      const successRate = last24hRequests > 0 ? (successfulRequests / last24hRequests) * 100 : 100

      // Simular uptime (em produção, isso viria de um sistema de monitoramento)
      const uptime = successRate > 95 ? 99.9 : successRate > 90 ? 99.5 : 98.0

      return {
        totalKeys,
        requests: requestsPerHour,
        uptime,
        errors: last24hRequests - successfulRequests,
        avgResponseTime: this.calculateAverageResponseTime(recentRequests || [])
      }
    } catch (error) {
      console.error('Erro ao buscar métricas API:', error)
      throw error
    }
  },

  // Incrementar contador de requisições
  async incrementKeyRequestCount(apiKeyId: string): Promise<void> {
    try {
      const { error } = await supabase.rpc('increment_api_key_requests', {
        key_id: apiKeyId
      })

      // Se a função não existir, fazer update manual
      if (error && error.message.includes('does not exist')) {
        const { error: updateError } = await supabase
          .from(DB_TABLES.API_KEYS)
          .update({
            request_count: supabase.raw('request_count + 1'),
            last_used: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('id', apiKeyId)

        if (updateError) throw updateError
      } else if (error) {
        throw error
      }
    } catch (error) {
      console.error('Erro ao incrementar contador:', error)
    }
  },

  // Validar chave de API
  async validateAPIKey(key: string): Promise<APIKey | null> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.API_KEYS)
        .select('*')
        .eq('key', key)
        .eq('status', 'active')
        .single()

      if (error || !data) return null
      return data
    } catch (error) {
      console.error('Erro ao validar chave API:', error)
      return null
    }
  },

  // Gerar nova chave de API
  generateAPIKey(): string {
    const prefix = 'gzs_' // GestãoZe System
    const timestamp = Date.now().toString(36)
    const random = Math.random().toString(36).substring(2, 15)
    const random2 = Math.random().toString(36).substring(2, 15)
    return `${prefix}${timestamp}${random}${random2}`
  },

  // Calcular tempo médio de resposta
  calculateAverageResponseTime(requests: APIRequest[]): number {
    if (requests.length === 0) return 0

    const totalResponseTime = requests.reduce((sum, req) => sum + (req.response_time || 0), 0)
    return Math.round(totalResponseTime / requests.length)
  },

  // Buscar chaves do arquivo .env
  getEnvironmentAPIKeys(): { name: string; key: string; description: string }[] {
    const envKeys = []

    // Supabase
    const supabaseUrl = (import.meta as any).env?.VITE_SUPABASE_URL
    const supabaseKey = (import.meta as any).env?.VITE_SUPABASE_ANON_KEY

    if (supabaseUrl && supabaseKey) {
      envKeys.push({
        name: 'Supabase Database',
        key: supabaseKey.substring(0, 20) + '...',
        description: 'Chave principal do banco de dados Supabase'
      })
    }

    // Gemini AI
    const geminiKey = (import.meta as any).env?.VITE_GEMINI_API_KEY
    if (geminiKey) {
      envKeys.push({
        name: 'Google Gemini AI',
        key: geminiKey.substring(0, 20) + '...',
        description: 'Integração com Google Gemini AI para funcionalidades inteligentes'
      })
    }

    return envKeys
  },

  // Inicializar dados padrão
  async initializeDefaultData(): Promise<boolean> {
    try {
      console.log('🚀 Inicializando sistema de API Management...')

      // Verificar se já existem chaves
      const { data: existingKeys, error: checkError } = await supabase
        .from(DB_TABLES.API_KEYS)
        .select('id')
        .limit(1)

      if (checkError && checkError.message?.includes('Could not find')) {
        console.log('📋 Tabelas não encontradas, tentando criar...')
        return await this.forceCreateAPIStructure()
      }

      if (existingKeys && existingKeys.length > 0) {
        console.log('✅ Sistema de API já está configurado')
        return true
      }

      // Criar chaves de exemplo baseadas no .env
      const envKeys = this.getEnvironmentAPIKeys()

      const defaultKeys = [
        {
          name: 'Integração Principal',
          description: 'Chave principal para integração com o sistema',
          permissions: ['read', 'write', 'admin'],
          rate_limit: 5000
        },
        {
          name: 'App Mobile',
          description: 'Chave para aplicativo mobile',
          permissions: ['read', 'write'],
          rate_limit: 1000
        },
        {
          name: 'Webhooks',
          description: 'Chave para receber webhooks externos',
          permissions: ['webhook'],
          rate_limit: 500
        }
      ]

      for (const keyData of defaultKeys) {
        await this.createAPIKey(keyData)
      }

      console.log('✅ Sistema de API inicializado com sucesso!')
      return true
    } catch (error) {
      console.error('❌ Erro ao inicializar sistema de API:', error)
      throw error
    }
  },

  // Forçar criação da estrutura básica
  async forceCreateAPIStructure(): Promise<boolean> {
    try {
      console.log('🔧 Criando estrutura básica do sistema de API...')

      // Criar uma chave de teste para forçar a criação da tabela
      const testKey = {
        id: crypto.randomUUID(),
        name: 'Chave de Teste',
        key: this.generateAPIKey(),
        description: 'Chave criada automaticamente para inicializar o sistema',
        status: 'active' as const,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        request_count: 0,
        rate_limit: 1000,
        allowed_origins: [],
        permissions: ['read']
      }

      const { error: keyError } = await supabase
        .from(DB_TABLES.API_KEYS)
        .insert([testKey])

      if (keyError) {
        throw new Error(`Tabela api_keys não existe: ${keyError.message}`)
      }

      console.log('✅ Estrutura básica criada com sucesso!')
      return await this.initializeDefaultData()
    } catch (error) {
      console.error('💥 Erro ao criar estrutura básica:', error)
      throw error
    }
  }
}