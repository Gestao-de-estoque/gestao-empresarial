import axios from 'axios'

interface GeminiResponse {
  candidates: Array<{
    content: {
      parts: Array<{
        text: string
      }>
    }
  }>
}

export class AIService {
  private apiKey: string
  private apiUrl: string

  constructor() {
    this.apiKey = import.meta.env.VITE_GEMINI_API_KEY
    this.apiUrl = import.meta.env.VITE_GEMINI_API_URL

    if (!this.apiKey) {
      console.error('API key do Google Gemini não configurada')
    }
    if (!this.apiUrl) {
      console.error('URL da API do Google Gemini não configurada')
    }
  }

  private async makeGeminiRequest(prompt: string): Promise<string> {
    if (!this.apiKey || !this.apiUrl) {
      throw new Error('Configuração da API do Google Gemini não encontrada. Verifique as variáveis de ambiente.')
    }

    try {
      console.log('🤖 Enviando solicitação para Google Gemini...')

      const response = await axios.post(
        `${this.apiUrl}?key=${this.apiKey}`,
        {
          contents: [
            {
              parts: [
                {
                  text: prompt
                }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 8192,
          },
          safetySettings: [
            {
              category: 'HARM_CATEGORY_HARASSMENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              category: 'HARM_CATEGORY_HATE_SPEECH',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        },
        {
          headers: {
            'Content-Type': 'application/json'
          },
          timeout: 30000 // 30 seconds timeout
        }
      )

      console.log('✅ Resposta recebida do Google Gemini')

      const geminiResponse: GeminiResponse = response.data

      if (!geminiResponse.candidates || geminiResponse.candidates.length === 0) {
        throw new Error('Nenhuma resposta válida foi gerada pela IA')
      }

      const aiText = geminiResponse.candidates[0]?.content?.parts[0]?.text
      if (!aiText) {
        throw new Error('Resposta da IA está vazia ou inválida')
      }

      return aiText
    } catch (error: any) {
      console.error('❌ Erro ao processar com IA:', error)

      if (error.response) {
        // Error from API
        const status = error.response.status
        const data = error.response.data

        console.error('Status:', status)
        console.error('Data:', data)

        if (status === 403) {
          throw new Error('🔒 Acesso negado à API. Verifique se a chave da API está correta e tem as permissões necessárias.')
        } else if (status === 429) {
          throw new Error('⏱️ Limite de uso da API excedido. Tente novamente em alguns minutos.')
        } else if (status === 400) {
          throw new Error('📝 Solicitação inválida. Os dados enviados podem estar mal formatados.')
        } else if (status >= 500) {
          throw new Error('🔧 Erro interno do servidor da IA. Tente novamente em alguns minutos.')
        } else {
          throw new Error(`❌ Erro da API (${status}): ${data?.error?.message || 'Erro desconhecido'}`)
        }
      } else if (error.code === 'ECONNABORTED') {
        throw new Error('⏰ Tempo limite excedido. A análise está demorando muito para ser concluída.')
      } else if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
        throw new Error('🌐 Não foi possível conectar com o serviço de IA. Verifique sua conexão com a internet.')
      } else {
        throw new Error('🤖 Erro inesperado ao processar com IA. Tente novamente.')
      }
    }
  }

  async analyzeInventory(inventoryData: any): Promise<string> {
    const prompt = `
Você é um especialista em gestão de estoque para restaurantes. Analise os dados de estoque fornecidos e forneça insights valiosos.

Dados do estoque:
${JSON.stringify(inventoryData, null, 2)}

Por favor, forneça uma análise detalhada incluindo:

1. **Situação Geral do Estoque**
   - Produtos com estoque crítico (abaixo do mínimo)
   - Produtos com sobra de estoque
   - Valor total do estoque

2. **Recomendações de Compra**
   - Quais produtos devem ser comprados urgentemente
   - Quantidades sugeridas
   - Priorização por categoria

3. **Análise de Custos**
   - Produtos com melhor custo-benefício
   - Sugestões para otimização de custos
   - Alertas sobre produtos com preço desproporcional

4. **Planejamento Estratégico**
   - Tendências observadas no estoque
   - Sugestões para melhorar a gestão
   - Alertas importantes

5. **Ações Imediatas**
   - Lista de ações prioritárias para hoje
   - Produtos que precisam de atenção especial

Formate a resposta de forma clara e organizada, usando markdown para melhor visualização.
`

    return await this.makeGeminiRequest(prompt)
  }

  async suggestMenuOptimization(menuData: any, inventoryData: any): Promise<string> {
    const prompt = `
Você é um consultor especialista em otimização de cardápios para restaurantes. Analise o cardápio atual e o estoque disponível para fornecer sugestões de otimização.

Dados do cardápio:
${JSON.stringify(menuData, null, 2)}

Dados do estoque:
${JSON.stringify(inventoryData, null, 2)}

Por favor, forneça recomendações sobre:

1. **Otimização do Cardápio**
   - Pratos que devem ser promovidos (baseado no estoque)
   - Pratos que devem ser temporariamente removidos
   - Sugestões de novos pratos com ingredientes disponíveis

2. **Gestão de Ingredientes**
   - Como aproveitar melhor os ingredientes em estoque
   - Sugestões para reduzir desperdício
   - Combinações eficientes de ingredientes

3. **Estratégia de Vendas**
   - Quais pratos têm melhor margem de lucro
   - Sugestões de combos e promoções
   - Análise de custo vs preço de venda

4. **Planejamento Semanal**
   - Cardápio sugerido para os próximos dias
   - Considerações sazonais
   - Balanceamento nutricional

Formate a resposta de forma clara e prática para implementação imediata.
`

    return await this.makeGeminiRequest(prompt)
  }

  async generatePurchaseSuggestions(inventoryData: any, salesHistory?: any): Promise<string> {
    const prompt = `
Você é um especialista em gestão de compras para restaurantes. Com base nos dados de estoque ${salesHistory ? 'e histórico de vendas' : ''}, gere sugestões inteligentes de compras.

Dados do estoque atual:
${JSON.stringify(inventoryData, null, 2)}

${salesHistory ? `Histórico de vendas:
${JSON.stringify(salesHistory, null, 2)}` : ''}

Por favor, forneça:

1. **Lista de Compras Prioritárias**
   - Produtos críticos que devem ser comprados HOJE
   - Quantidades sugeridas baseadas no consumo
   - Fornecedores recomendados (se aplicável)

2. **Planejamento de Compras Semanal**
   - Cronograma de compras para a semana
   - Produtos que podem esperar alguns dias
   - Considerações de prazo de validade

3. **Otimização de Custos**
   - Sugestões para compras em volume
   - Produtos que podem ser substituídos por alternativas mais baratas
   - Oportunidades de economia

4. **Análise Preditiva**
   - Previsão de necessidades futuras
   - Produtos que podem ter alta demanda
   - Alertas sobre possíveis faltas

5. **Recomendações Estratégicas**
   - Diversificação de fornecedores
   - Produtos sazonais a considerar
   - Tendências do mercado

Organize as informações de forma prática e acionável.
`

    return await this.makeGeminiRequest(prompt)
  }

  async askQuestion(question: string, context?: any): Promise<string> {
    const prompt = `
Você é um assistente especializado em gestão de restaurantes e estoque. Responda à pergunta do usuário de forma clara e útil.

${context ? `Contexto relevante:
${JSON.stringify(context, null, 2)}` : ''}

Pergunta do usuário: ${question}

Por favor, forneça uma resposta detalhada e prática, considerando o contexto da gestão de restaurantes.
`

    return await this.makeGeminiRequest(prompt)
  }
}

export const aiService = new AIService()