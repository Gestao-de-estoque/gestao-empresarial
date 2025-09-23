export interface Product {
  id: string
  nome: string
  categoria_id?: string
  preco: number
  custo?: number
  current_stock: number
  estoque_atual: number
  min_stock: number
  estoque_minimo: number
  max_stock?: number
  unidade: string
  descricao?: string
  codigo_barras?: string
  ativo: boolean
  created_by?: string
  created_at: string
  updated_at: string
}

export interface ProductFormData {
  nome: string
  preco: number
  custo: number
  current_stock: number
  min_stock: number
  unidade: string
  categoria_id: string
  descricao: string
  codigo_barras: string
}

export interface Category {
  id: string
  nome: string
  icone: string
  ativo: boolean
  created_at: string
  updated_at: string
}

export interface Movement {
  id: string
  product_id: string
  type: string
  quantity: number
  previous_stock?: number
  new_stock?: number
  unit_cost?: number
  total_cost?: number
  notes?: string
  supplier?: string
  invoice_number?: string
  created_by?: string
  created_at: string
}