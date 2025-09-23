<template>
  <div class="inventory-container">
    <header class="page-header">
      <div class="header-content">
        <h1>Gestão de Estoque</h1>
        <button @click="showAddModal = true" class="btn-primary">
          📦 Adicionar Produto
        </button>
      </div>
    </header>

    <div class="filters-section">
      <div class="search-box">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar produtos..."
          class="search-input"
        />
      </div>
      <div class="filter-controls">
        <select v-model="selectedCategory" class="filter-select">
          <option value="">Todas as categorias</option>
          <option v-for="category in categories" :key="category.id" :value="category.id">
            {{ category.nome }}
          </option>
        </select>
        <select v-model="stockFilter" class="filter-select">
          <option value="">Todos os produtos</option>
          <option value="low">Estoque baixo</option>
          <option value="out">Sem estoque</option>
        </select>
      </div>
    </div>

    <div class="products-grid">
      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Carregando produtos...</p>
      </div>

      <div v-else-if="filteredProducts.length === 0" class="empty-state">
        <p>Nenhum produto encontrado</p>
      </div>

      <div v-else class="products-list">
        <div
          v-for="product in filteredProducts"
          :key="product.id"
          class="product-card"
          :class="{ 'low-stock': product.current_stock <= product.min_stock }"
        >
          <div class="product-header">
            <h3>{{ product.nome }}</h3>
            <div class="product-actions">
              <button @click="editProduct(product)" class="btn-edit">✏️</button>
              <button @click="viewProduct(product)" class="btn-view">👁️</button>
            </div>
          </div>

          <div class="product-info">
            <div class="info-row">
              <span class="label">Estoque:</span>
              <span class="value" :class="{ 'low': product.current_stock <= product.min_stock }">
                {{ product.current_stock }} {{ product.unidade }}
              </span>
            </div>
            <div class="info-row">
              <span class="label">Mínimo:</span>
              <span class="value">{{ product.min_stock }} {{ product.unidade }}</span>
            </div>
            <div class="info-row">
              <span class="label">Preço:</span>
              <span class="value">R$ {{ formatCurrency(product.preco) }}</span>
            </div>
          </div>

          <div class="product-footer">
            <div class="stock-bar">
              <div
                class="stock-progress"
                :style="{ width: getStockPercentage(product) + '%' }"
                :class="{ 'low': product.current_stock <= product.min_stock }"
              ></div>
            </div>
            <small class="updated-at">
              Atualizado em {{ formatDate(product.updated_at) }}
            </small>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de adicionar produto -->
    <div v-if="showAddModal" class="modal-overlay" @click="showAddModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ editingProduct ? 'Editar Produto' : 'Adicionar Produto' }}</h2>
          <button @click="closeModal" class="modal-close">×</button>
        </div>

        <form @submit.prevent="saveProduct" class="product-form">
          <div class="form-group">
            <label>Nome do Produto:</label>
            <input
              v-model="productForm.nome"
              type="text"
              required
              placeholder="Ex: Arroz Tipo 1"
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Preço (R$):</label>
              <input
                v-model.number="productForm.preco"
                type="number"
                step="0.01"
                min="0"
                required
                placeholder="0,00"
              />
            </div>
            <div class="form-group">
              <label>Custo (R$):</label>
              <input
                v-model.number="productForm.custo"
                type="number"
                step="0.01"
                min="0"
                placeholder="0,00"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Estoque Atual:</label>
              <input
                v-model.number="productForm.current_stock"
                type="number"
                min="0"
                required
                placeholder="0"
              />
            </div>
            <div class="form-group">
              <label>Estoque Mínimo:</label>
              <input
                v-model.number="productForm.min_stock"
                type="number"
                min="0"
                required
                placeholder="0"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Unidade:</label>
              <select v-model="productForm.unidade" required>
                <option value="unidade">Unidade</option>
                <option value="kg">Quilograma</option>
                <option value="g">Grama</option>
                <option value="l">Litro</option>
                <option value="ml">Mililitro</option>
                <option value="pacote">Pacote</option>
                <option value="caixa">Caixa</option>
              </select>
            </div>
            <div class="form-group">
              <label>Categoria:</label>
              <select v-model="productForm.categoria_id">
                <option value="">Selecione uma categoria</option>
                <option v-for="category in categories" :key="category.id" :value="category.id">
                  {{ category.nome }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>Descrição:</label>
            <textarea
              v-model="productForm.descricao"
              rows="3"
              placeholder="Descrição opcional do produto"
            ></textarea>
          </div>

          <div class="form-group">
            <label>Código de Barras:</label>
            <input
              v-model="productForm.codigo_barras"
              type="text"
              placeholder="Código de barras (opcional)"
            />
          </div>

          <div class="form-actions">
            <button type="button" @click="closeModal" class="btn-secondary">
              Cancelar
            </button>
            <button type="submit" :disabled="saving" class="btn-primary">
              {{ saving ? 'Salvando...' : (editingProduct ? 'Atualizar' : 'Adicionar') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase, DB_TABLES } from '@/config/supabase'
import { useAuthStore } from '@/stores/auth'
import type { Product } from '@/types/product'

const authStore = useAuthStore()

const products = ref<Product[]>([])
const categories = ref<any[]>([])
const loading = ref(false)
const saving = ref(false)
const searchQuery = ref('')
const selectedCategory = ref('')
const stockFilter = ref('')
const showAddModal = ref(false)
const editingProduct = ref<Product | null>(null)

const productForm = ref({
  nome: '',
  preco: 0,
  custo: 0,
  current_stock: 0,
  min_stock: 0,
  unidade: 'unidade',
  categoria_id: '',
  descricao: '',
  codigo_barras: ''
})

const filteredProducts = computed(() => {
  let filtered = products.value

  // Filtro por busca
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(product =>
      product.nome.toLowerCase().includes(query) ||
      product.descricao?.toLowerCase().includes(query) ||
      product.codigo_barras?.toLowerCase().includes(query)
    )
  }

  // Filtro por categoria
  if (selectedCategory.value) {
    filtered = filtered.filter(product => product.categoria_id === selectedCategory.value)
  }

  // Filtro por estoque
  if (stockFilter.value === 'low') {
    filtered = filtered.filter(product => product.current_stock <= product.min_stock && product.current_stock > 0)
  } else if (stockFilter.value === 'out') {
    filtered = filtered.filter(product => product.current_stock === 0)
  }

  return filtered
})

async function loadProducts() {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from(DB_TABLES.PRODUCTS)
      .select('*')
      .eq('ativo', true)
      .order('nome')

    if (error) throw error
    products.value = data || []
  } catch (error) {
    console.error('Erro ao carregar produtos:', error)
  } finally {
    loading.value = false
  }
}

async function loadCategories() {
  try {
    const { data, error } = await supabase
      .from(DB_TABLES.CATEGORIES)
      .select('*')
      .eq('ativo', true)
      .order('nome')

    if (error) throw error
    categories.value = data || []
  } catch (error) {
    console.error('Erro ao carregar categorias:', error)
  }
}

async function saveProduct() {
  saving.value = true
  try {
    const productData = {
      ...productForm.value,
      estoque_atual: productForm.value.current_stock,
      estoque_minimo: productForm.value.min_stock,
      ativo: true,
      created_by: authStore.user?.id,
      updated_at: new Date().toISOString()
    }

    if (editingProduct.value) {
      const { error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .update(productData)
        .eq('id', editingProduct.value.id)

      if (error) throw error
    } else {
      const { error } = await supabase
        .from(DB_TABLES.PRODUCTS)
        .insert([{
          ...productData,
          created_at: new Date().toISOString()
        }])

      if (error) throw error
    }

    await loadProducts()
    closeModal()
  } catch (error) {
    console.error('Erro ao salvar produto:', error)
    alert('Erro ao salvar produto')
  } finally {
    saving.value = false
  }
}

function editProduct(product: Product) {
  editingProduct.value = product
  productForm.value = {
    nome: product.nome,
    preco: product.preco,
    custo: product.custo || 0,
    current_stock: product.current_stock,
    min_stock: product.min_stock,
    unidade: product.unidade,
    categoria_id: product.categoria_id || '',
    descricao: product.descricao || '',
    codigo_barras: product.codigo_barras || ''
  }
  showAddModal.value = true
}

function viewProduct(product: Product) {
  alert(`Detalhes do produto: ${product.nome}\nEstoque: ${product.current_stock} ${product.unidade}\nPreço: R$ ${formatCurrency(product.preco)}`)
}

function closeModal() {
  showAddModal.value = false
  editingProduct.value = null
  productForm.value = {
    nome: '',
    preco: 0,
    custo: 0,
    current_stock: 0,
    min_stock: 0,
    unidade: 'unidade',
    categoria_id: '',
    descricao: '',
    codigo_barras: ''
  }
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString('pt-BR')
}

function getStockPercentage(product: Product): number {
  if (product.min_stock === 0) return 100
  return Math.min((product.current_stock / (product.min_stock * 2)) * 100, 100)
}

onMounted(() => {
  loadProducts()
  loadCategories()
})
</script>

<style scoped>
.inventory-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 30px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-content h1 {
  color: #2d3748;
  margin: 0;
}

.btn-primary {
  background: #667eea;
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: background 0.3s;
}

.btn-primary:hover:not(:disabled) {
  background: #5a67d8;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.filters-section {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.search-box {
  flex: 1;
  min-width: 300px;
}

.search-input {
  width: 100%;
  padding: 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 16px;
}

.search-input:focus {
  outline: none;
  border-color: #667eea;
}

.filter-controls {
  display: flex;
  gap: 12px;
}

.filter-select {
  padding: 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: white;
  cursor: pointer;
}

.products-grid {
  min-height: 400px;
}

.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 300px;
  color: #666;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e2e8f0;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.products-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.product-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 20px;
  transition: all 0.3s;
}

.product-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.product-card.low-stock {
  border-color: #f56565;
  background: #fed7d7;
}

.product-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.product-header h3 {
  margin: 0;
  color: #2d3748;
  flex: 1;
}

.product-actions {
  display: flex;
  gap: 8px;
}

.btn-edit, .btn-view {
  background: transparent;
  border: 1px solid #e2e8f0;
  padding: 6px 8px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-edit:hover {
  background: #667eea;
  color: white;
}

.btn-view:hover {
  background: #48bb78;
  color: white;
}

.product-info {
  margin-bottom: 16px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.info-row .label {
  color: #666;
  font-weight: 500;
}

.info-row .value {
  color: #2d3748;
  font-weight: 600;
}

.info-row .value.low {
  color: #e53e3e;
}

.product-footer {
  margin-top: 16px;
}

.stock-bar {
  width: 100%;
  height: 6px;
  background: #e2e8f0;
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 8px;
}

.stock-progress {
  height: 100%;
  background: #48bb78;
  transition: width 0.3s;
}

.stock-progress.low {
  background: #f56565;
}

.updated-at {
  color: #666;
  font-size: 12px;
}

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;
}

.modal-header h2 {
  margin: 0;
  color: #2d3748;
}

.modal-close {
  background: transparent;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  color: #333;
}

.product-form {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  color: #2d3748;
  font-weight: 500;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 10px;
  border: 2px solid #e2e8f0;
  border-radius: 6px;
  font-size: 16px;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #667eea;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
}

.btn-secondary {
  background: #f7fafc;
  color: #2d3748;
  border: 2px solid #e2e8f0;
  padding: 12px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-secondary:hover {
  background: #e2e8f0;
}

@media (max-width: 768px) {
  .inventory-container {
    padding: 16px;
  }

  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }

  .filters-section {
    flex-direction: column;
  }

  .filter-controls {
    flex-direction: column;
  }

  .products-list {
    grid-template-columns: 1fr;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column;
  }
}
</style>