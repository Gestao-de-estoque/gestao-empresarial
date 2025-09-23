import { supabase, DB_TABLES } from '@/config/supabase'
import type { Product } from '@/types/product'

export class ProductService {
  async getProducts(): Promise<Product[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('*')
        .eq('ativo', true)
        .order('nome')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar produtos:', error)
      throw error
    }
  }

  async getProductById(id: string): Promise<Product | null> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('*')
        .eq('id', id)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao buscar produto:', error)
      throw error
    }
  }

  async createProduct(productData: Partial<Product>): Promise<Product> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .insert([{
          ...productData,
          ativo: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar produto:', error)
      throw error
    }
  }

  async updateProduct(id: string, productData: Partial<Product>): Promise<Product> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .update({
          ...productData,
          updated_at: new Date().toISOString()
        })
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao atualizar produto:', error)
      throw error
    }
  }

  async deleteProduct(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .update({ ativo: false, updated_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Erro ao excluir produto:', error)
      throw error
    }
  }

  async getLowStockProducts(threshold?: number): Promise<Product[]> {
    try {
      let query = supabase
        .from(DB_TABLES.PRODUCTS)
        .select('*')
        .eq('ativo', true)

      if (threshold !== undefined) {
        query = query.lte('current_stock', threshold)
      } else {
        // Use o estoque mínimo definido para cada produto
        query = query.or('current_stock.lte.min_stock')
      }

      const { data, error } = await query.order('current_stock', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar produtos com estoque baixo:', error)
      throw error
    }
  }

  async getProductsByCategory(categoryId: string): Promise<Product[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('*')
        .eq('categoria_id', categoryId)
        .eq('ativo', true)
        .order('nome')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar produtos por categoria:', error)
      throw error
    }
  }

  async searchProducts(query: string): Promise<Product[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .select('*')
        .eq('ativo', true)
        .or(`nome.ilike.%${query}%,descricao.ilike.%${query}%,codigo_barras.ilike.%${query}%`)
        .order('nome')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao pesquisar produtos:', error)
      throw error
    }
  }

  async getCategories(): Promise<any[]> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.CATEGORIES)
        .select('*')
        .eq('ativo', true)
        .order('nome')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar categorias:', error)
      throw error
    }
  }

  async createCategory(categoryData: { nome: string; icone?: string }): Promise<any> {
    try {
      const { data, error } = await supabase
        .from(DB_TABLES.CATEGORIES)
        .insert([{
          ...categoryData,
          ativo: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar categoria:', error)
      throw error
    }
  }
}

export const productService = new ProductService()