import { supabase, DB_TABLES } from '@/config/supabase'

/**
 * Popula dados de teste para gerar alertas
 */
export async function populateTestData() {
  console.log('🚀 Populando dados de teste para alertas...')

  try {
    // 1. Criar algumas categorias se não existirem
    const { data: existingCategories } = await supabase
      .from(DB_TABLES.CATEGORIES)
      .select('id')
      .limit(1)

    let categoryId: string

    if (!existingCategories || existingCategories.length === 0) {
      console.log('📁 Criando categorias de teste...')

      const { data: newCategories, error: categoryError } = await supabase
        .from(DB_TABLES.CATEGORIES)
        .insert([
          { nome: 'Bebidas', icone: '🥤', ativo: true },
          { nome: 'Lanches', icone: '🍔', ativo: true },
          { nome: 'Sobremesas', icone: '🍰', ativo: true },
          { nome: 'Categoria Vazia', icone: '📦', ativo: true }
        ])
        .select('id')

      if (categoryError) {
        console.error('Erro ao criar categorias:', categoryError)
        return
      }

      categoryId = newCategories[0].id
    } else {
      // Usar categoria existente
      const { data: categories } = await supabase
        .from(DB_TABLES.CATEGORIES)
        .select('id')
        .limit(1)

      categoryId = categories![0].id
    }

    // 2. Criar produtos para gerar alertas de estoque
    console.log('📦 Criando produtos de teste...')

    const testProducts = [
      {
        nome: 'Coca-Cola 350ml',
        categoria_id: categoryId,
        preco: 4.50,
        custo: 2.00,
        current_stock: 0, // SEM ESTOQUE - vai gerar alerta crítico
        min_stock: 10,
        max_stock: 100,
        unidade: 'unidade',
        ativo: true
      },
      {
        nome: 'Água 500ml',
        categoria_id: categoryId,
        preco: 2.00,
        custo: 1.00,
        current_stock: 5, // ESTOQUE BAIXO - vai gerar alerta warning
        min_stock: 20,
        max_stock: 200,
        unidade: 'unidade',
        ativo: true
      },
      {
        nome: 'Suco de Laranja',
        categoria_id: categoryId,
        preco: 6.00,
        custo: 3.50,
        current_stock: 150, // ESTOQUE ALTO - vai gerar alerta info
        min_stock: 10,
        max_stock: 100,
        unidade: 'unidade',
        ativo: true
      },
      {
        nome: 'Produto Inativo',
        categoria_id: categoryId,
        preco: 10.00,
        custo: 5.00,
        current_stock: 50,
        min_stock: 10,
        max_stock: 100,
        unidade: 'unidade',
        ativo: false // PRODUTO INATIVO
      }
    ]

    // Verificar se produtos já existem
    const { data: existingProducts } = await supabase
      .from(DB_TABLES.PRODUCTS)
      .select('nome')
      .in('nome', testProducts.map(p => p.nome))

    const existingProductNames = existingProducts?.map(p => p.nome) || []
    const newProducts = testProducts.filter(p => !existingProductNames.includes(p.nome))

    if (newProducts.length > 0) {
      const { error: productError } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .insert(newProducts)

      if (productError) {
        console.error('Erro ao criar produtos:', productError)
        return
      }

      console.log(`✅ ${newProducts.length} produtos de teste criados`)
    } else {
      console.log('📦 Produtos de teste já existem')
    }

    // 3. Criar alguns produtos inativos para alerta de dados
    console.log('💤 Criando produtos inativos...')

    const inactiveProducts = []
    for (let i = 1; i <= 12; i++) {
      inactiveProducts.push({
        nome: `Produto Inativo ${i}`,
        categoria_id: categoryId,
        preco: 10.00,
        custo: 5.00,
        current_stock: 0,
        min_stock: 5,
        unidade: 'unidade',
        ativo: false
      })
    }

    // Verificar produtos inativos existentes
    const { data: existingInactive } = await supabase
      .from(DB_TABLES.PRODUCTS)
      .select('nome')
      .in('nome', inactiveProducts.map(p => p.nome))

    const existingInactiveNames = existingInactive?.map(p => p.nome) || []
    const newInactiveProducts = inactiveProducts.filter(p => !existingInactiveNames.includes(p.nome))

    if (newInactiveProducts.length > 0) {
      const { error: inactiveError } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .insert(newInactiveProducts)

      if (inactiveError) {
        console.error('Erro ao criar produtos inativos:', inactiveError)
      } else {
        console.log(`✅ ${newInactiveProducts.length} produtos inativos criados`)
      }
    }

    // 4. Criar alguns logs de erro para teste
    console.log('📝 Criando logs de erro de teste...')

    const errorLogs = []
    for (let i = 1; i <= 8; i++) {
      errorLogs.push({
        action: `erro_teste_${i}`,
        username: 'sistema_teste',
        resource: 'teste',
        details: { error: `Erro de teste ${i} para demonstração` },
        severity: 'error',
        category: 'sistema',
        created_at: new Date().toISOString()
      })
    }

    const { error: logsError } = await supabase
      .from(DB_TABLES.LOGS)
      .insert(errorLogs)

    if (logsError) {
      console.error('Erro ao criar logs:', logsError)
    } else {
      console.log(`✅ ${errorLogs.length} logs de erro criados`)
    }

    console.log('🎉 Dados de teste populados com sucesso!')
    console.log('Agora você pode testar os alertas:')
    console.log('- Produtos sem estoque (crítico)')
    console.log('- Produtos com estoque baixo (warning)')
    console.log('- Produtos com estoque alto (info)')
    console.log('- Muitos produtos inativos (info)')
    console.log('- Alta taxa de erros (warning)')

  } catch (error) {
    console.error('❌ Erro ao popular dados de teste:', error)
  }
}

/**
 * Limpa dados de teste
 */
export async function cleanTestData() {
  console.log('🧹 Limpando dados de teste...')

  try {
    // Remover produtos de teste
    await supabase
      .from(DB_TABLES.PRODUCTS)
      .delete()
      .like('nome', '%Produto Inativo%')

    await supabase
      .from(DB_TABLES.PRODUCTS)
      .delete()
      .in('nome', ['Coca-Cola 350ml', 'Água 500ml', 'Suco de Laranja', 'Produto Inativo'])

    // Remover logs de teste
    await supabase
      .from(DB_TABLES.LOGS)
      .delete()
      .like('action', 'erro_teste_%')

    // Limpar alertas antigos
    await supabase
      .from(DB_TABLES.SYSTEM_ALERTS)
      .delete()
      .eq('auto_generated', true)

    console.log('✅ Dados de teste removidos')

  } catch (error) {
    console.error('❌ Erro ao limpar dados de teste:', error)
  }
}