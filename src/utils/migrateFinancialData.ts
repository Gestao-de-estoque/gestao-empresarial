import { financialService } from '@/services/financialService'

// Dados de exemplo para migração (simulando o data.js)
const sampleData = [
  { fullDay: '26/09/2020', amount: 494.70, total: 5598.70 },
  { fullDay: '27/09/2020', amount: 266.62, total: 31948.78 },
  { fullDay: '29/09/2020', amount: 96.80, total: 1246.80 },
  { fullDay: '01/10/2020', amount: 209.60, total: 1997.60 },
  { fullDay: '02/10/2020', amount: 52.00, total: 686.00 },
  { fullDay: '03/10/2020', amount: 18.80, total: 295.80 },
  { fullDay: '04/10/2020', amount: 35.98, total: 495.83 },
  { fullDay: '07/10/2020', amount: 35.70, total: 397.70 },
  { fullDay: '09/10/2020', amount: 58.50, total: 643.50 },
  { fullDay: '10/10/2020', amount: 360.98, total: 3805.78 },
  { fullDay: '11/10/2020', amount: 1067.27, total: 13956.45 },
  { fullDay: '12/10/2020', amount: 678.13, total: 7636.23 },
  { fullDay: '13/10/2020', amount: 11.70, total: 178.70 },
  { fullDay: '17/10/2020', amount: 331.71, total: 3823.96 },
  { fullDay: '18/10/2020', amount: 553.14, total: 6414.54 },
  { fullDay: '19/10/2020', amount: 68.94, total: 758.34 },
  { fullDay: '20/10/2020', amount: 227.80, total: 2576.80 },
  { fullDay: '21/10/2020', amount: 29.90, total: 342.90 },
  { fullDay: '22/10/2020', amount: 22.40, total: 246.40 },
  { fullDay: '23/10/2020', amount: 61.85, total: 606.85 },
  { fullDay: '24/10/2020', amount: 335.85, total: 3824.65 },
  { fullDay: '25/10/2020', amount: 265.76, total: 3214.36 },
  { fullDay: '26/10/2020', amount: 83.97, total: 922.97 },
  { fullDay: '27/10/2020', amount: 68.10, total: 778.10 },
  { fullDay: '28/10/2020', amount: 301.08, total: 3337.86 },
  { fullDay: '29/10/2020', amount: 117.72, total: 1326.92 },
  { fullDay: '30/10/2020', amount: 82.30, total: 3492.30 },
  { fullDay: '31/10/2020', amount: 208.82, total: 2590.02 }
]

// Função para migrar dados do data.js para o Supabase
export async function migrateFinancialData() {
  try {
    let rawData = []

    // Tenta importar do arquivo data.js primeiro
    try {
      const dataModule = await import('../data/data.js') as any
      rawData = dataModule.default || dataModule.data || []
    } catch (importError) {
      console.log('Não foi possível importar data.js, usando dados de exemplo')
      rawData = sampleData
    }

    if (!rawData || !Array.isArray(rawData)) {
      console.log('Usando dados de exemplo para migração')
      rawData = sampleData
    }

    console.log(`Iniciando migração de ${rawData.length} registros...`)

    // Migra os dados usando o serviço
    await financialService.migrateDataFromJS(rawData)

    console.log('Migração concluída com sucesso!')
    return { success: true, count: rawData.length }

  } catch (error) {
    console.error('Erro durante a migração:', error)
    return { success: false, error: (error as Error).message }
  }
}

// Função auxiliar para validar dados antes da migração
export function validateFinancialData(data: any[]): boolean {
  if (!Array.isArray(data)) return false

  return data.every(item =>
    item &&
    typeof item.fullDay === 'string' &&
    typeof item.amount === 'number' &&
    typeof item.total === 'number' &&
    item.fullDay.match(/^\d{2}\/\d{2}\/\d{4}$/) // Valida formato DD/MM/YYYY
  )
}

// Função para executar a migração com validação
export async function executeMigration() {
  const startTime = Date.now()

  try {
    const result = await migrateFinancialData()
    const endTime = Date.now()
    const duration = endTime - startTime

    if (result.success) {
      console.log(`✅ Migração bem-sucedida!`)
      console.log(`📊 ${result.count} registros migrados`)
      console.log(`⏱️ Tempo decorrido: ${duration}ms`)
    } else {
      console.error(`❌ Erro na migração: ${result.error}`)
    }

    return result
  } catch (error) {
    console.error('❌ Erro crítico na migração:', error)
    return { success: false, error: (error as Error).message }
  }
}