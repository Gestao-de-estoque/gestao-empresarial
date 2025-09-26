<template>
  <div class="inventory-container">
    <!-- Header Principal -->
    <header class="inventory-header">
      <div class="header-main">
        <div class="header-left">
          <div class="title-section">
            <h1 class="page-title">
              <Package :size="28" />
              Gestão de Estoque
            </h1>
            <p class="page-subtitle">Controle completo do seu inventário</p>
          </div>
        </div>

        <div class="header-right">
          <div class="header-actions">
            <button @click="showAddModal = true" class="btn-primary">
              <Plus :size="18" />
              Adicionar Produto
            </button>
            <button @click="loadProducts" class="btn-secondary" :disabled="loading">
              <RefreshCw :size="18" :class="{ 'animate-spin': loading }" />
              Atualizar
            </button>
            <button @click="showChat = true" class="btn-secondary">
              <MessageCircle :size="18" />
              Chat IA
            </button>
          </div>
        </div>
      </div>

      <!-- Estatísticas Rápidas -->
      <div class="quick-stats">
        <div class="stat-card primary">
          <div class="stat-icon">
            <Package :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ products.length }}</div>
            <div class="stat-label">Total de Produtos</div>
          </div>
        </div>

        <div class="stat-card warning">
          <div class="stat-icon">
            <AlertTriangle :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ lowStockCount }}</div>
            <div class="stat-label">Estoque Baixo</div>
          </div>
        </div>

        <div class="stat-card danger">
          <div class="stat-icon">
            <XCircle :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ outOfStockCount }}</div>
            <div class="stat-label">Sem Estoque</div>
          </div>
        </div>

        <div class="stat-card success">
          <div class="stat-icon">
            <DollarSign :size="24" />
          </div>
          <div class="stat-content">
            <div class="stat-value">R$ {{ formatCurrency(totalValue) }}</div>
            <div class="stat-label">Valor Total</div>
          </div>
        </div>
      </div>
    </header>

    <!-- Filtros Avançados -->
    <section class="filters-section">
      <div class="filters-header">
        <h3>
          <Filter :size="20" />
          Filtros e Busca
        </h3>
      </div>

      <div class="filters-grid">
        <!-- Busca Principal -->
        <div class="search-container">
          <div class="search-input-wrapper">
            <Search :size="20" class="search-icon" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Buscar produtos por nome, descrição ou código..."
              class="search-input"
            />
            <button v-if="searchQuery" @click="searchQuery = ''" class="clear-search">
              <X :size="16" />
            </button>
          </div>
        </div>

        <!-- Filtros -->
        <div class="filter-controls">
          <div class="filter-group">
            <label>
              <Tag :size="16" />
              Categoria
            </label>
            <select v-model="selectedCategory" class="filter-select">
              <option value="">Todas as categorias</option>
              <option v-for="category in categories" :key="category.id" :value="category.id">
                {{ category.nome }}
              </option>
            </select>
          </div>

          <div class="filter-group">
            <label>
              <BarChart3 :size="16" />
              Status do Estoque
            </label>
            <select v-model="stockFilter" class="filter-select">
              <option value="">Todos os produtos</option>
              <option value="normal">Estoque normal</option>
              <option value="low">Estoque baixo</option>
              <option value="out">Sem estoque</option>
            </select>
          </div>

          <div class="filter-group">
            <label>
              <SortAsc :size="16" />
              Ordenar por
            </label>
            <select v-model="sortBy" class="filter-select">
              <option value="nome">Nome</option>
              <option value="estoque">Estoque</option>
              <option value="preco">Preço</option>
              <option value="updated_at">Última atualização</option>
            </select>
          </div>

          <div class="filter-group">
            <label>
              <Eye :size="16" />
              Visualização
            </label>
            <div class="view-toggle">
              <button
                @click="viewMode = 'grid'"
                :class="{ active: viewMode === 'grid' }"
                class="view-btn"
              >
                <Grid :size="16" />
              </button>
              <button
                @click="viewMode = 'list'"
                :class="{ active: viewMode === 'list' }"
                class="view-btn"
              >
                <List :size="16" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Lista de Produtos -->
    <main class="products-section">
        <div class="section-header">
          <div class="results-info">
          <span class="results-count">
            {{ filteredProducts.length }} produto{{ filteredProducts.length !== 1 ? 's' : '' }} encontrado{{ filteredProducts.length !== 1 ? 's' : '' }}
          </span>
          <div class="filter-badges" v-if="activeFiltersCount > 0">
            <span class="filter-badge" v-if="searchQuery">
              Busca: "{{ searchQuery }}"
              <button @click="searchQuery = ''" class="remove-filter">
                <X :size="12" />
              </button>
            </span>
            <span class="filter-badge" v-if="selectedCategory">
              Categoria
              <button @click="selectedCategory = ''" class="remove-filter">
                <X :size="12" />
              </button>
            </span>
            <span class="filter-badge" v-if="stockFilter">
              {{ stockFilter === 'low' ? 'Estoque Baixo' : stockFilter === 'out' ? 'Sem Estoque' : 'Estoque Normal' }}
              <button @click="stockFilter = ''" class="remove-filter">
                <X :size="12" />
              </button>
            </span>
          </div>
          <div class="section-actions">
            <label class="select-all">
              <input type="checkbox" v-model="allSelected"> Selecionar todos
            </label>
            <button class="btn-danger" :disabled="selectedIds.length===0" @click="deleteProducts(selectedIds)">
              Remover Selecionados ({{ selectedIds.length }})
            </button>
          </div>
        </div>
        <div class="section-actions">
          <button class="tool-btn" @click="clearAllFilters" :disabled="activeFiltersCount === 0">Limpar filtros</button>
          <button class="tool-btn" @click="toggleCompactMode" :class="{ active: compactMode }">Modo compacto</button>
          <button class="tool-btn" @click="exportCSV" :disabled="filteredProducts.length === 0">Exportar CSV</button>
          <button class="tool-btn" @click="exportExcel" :disabled="filteredProducts.length === 0">Exportar Excel</button>
          <button class="btn-primary" @click="exportInventoryPDF" :disabled="filteredProducts.length === 0">Gerar Relatório (PDF)</button>
          <div class="page-size">
            <label>Itens:</label>
            <select v-model.number="pageSize" class="filter-select small">
              <option :value="12">12</option>
              <option :value="24">24</option>
              <option :value="48">48</option>
            </select>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading-state">
        <div class="loader">
          <Loader2 :size="32" class="animate-spin" />
          <p>Carregando produtos...</p>
        </div>
      </div>

      <div v-else-if="filteredProducts.length === 0" class="empty-state">
        <div class="empty-content">
          <Package :size="64" />
          <h3>Nenhum produto encontrado</h3>
          <p v-if="activeFiltersCount > 0">
            Tente ajustar os filtros ou limpar a busca
          </p>
          <p v-else>
            Comece adicionando seu primeiro produto ao estoque
          </p>
          <button @click="showAddModal = true" class="btn-primary">
            <Plus :size="18" />
            Adicionar Primeiro Produto
          </button>
        </div>
      </div>

      <div v-else class="products-container">
        <!-- Grid View -->
        <div v-if="viewMode === 'grid'" class="products-grid" :class="{ compact: compactMode }">
          <div
            v-for="product in paginatedProducts"
            :key="product.id"
            class="product-card"
            :class="getCardClasses(product)"
          >
            <div class="card-header">
              <input type="checkbox" v-model="selectedIds" :value="product.id" />
              <div class="product-image">
                <Package :size="24" />
              </div>
              <span class="status-chip" :class="getStockClass(product)">{{ getStockStatus(product) }}</span>
              <div class="product-actions">
                <button @click="editProduct(product)" class="action-btn edit" title="Editar">
                  <Edit2 :size="16" />
                </button>
                <button @click="viewProduct(product)" class="action-btn view" title="Visualizar">
                  <Eye :size="16" />
                </button>
                <button @click="duplicateProduct(product)" class="action-btn duplicate" title="Duplicar">
                  <Copy :size="16" />
                </button>
                <button @click="deleteProducts([product.id])" class="action-btn duplicate" title="Remover">
                  <Trash2 :size="16" />
                </button>
              </div>
            </div>

            <div class="card-content">
              <h3 class="product-name">{{ product.nome }}</h3>
              <p class="product-category" v-if="getProductCategory(product)">
                {{ getProductCategory(product) }}
              </p>

              <div class="product-stats">
                <div class="stat-item">
                  <span class="stat-label">Estoque</span>
                  <span class="stat-value" :class="{ 'critical': product.current_stock <= product.min_stock, 'zero': product.current_stock === 0 }">
                    {{ product.current_stock }} {{ product.unidade }}
                  </span>
                </div>

                <div class="stat-item">
                  <span class="stat-label">Preço</span>
                  <span class="stat-value price">R$ {{ formatCurrency(product.preco) }}</span>
                </div>

                <div class="stat-item">
                  <span class="stat-label">Valor Total</span>
                  <span class="stat-value total">R$ {{ formatCurrency(product.preco * product.current_stock) }}</span>
                </div>
              </div>

              <div class="stock-indicator">
                <div class="stock-bar">
                  <div
                    class="stock-fill"
                    :style="{ width: getStockPercentage(product) + '%' }"
                    :class="getStockClass(product)"
                  ></div>
                </div>
                <div class="stock-text">
                  <span>{{ getStockStatus(product) }}</span>
                  <span class="stock-ratio">{{ product.current_stock }}/{{ product.min_stock * 2 }}</span>
                </div>
              </div>
            </div>

            <div class="card-footer">
              <span class="last-updated">
                <Clock :size="12" />
                {{ formatDate(product.updated_at) }}
              </span>
              <div class="quick-actions">
                <button @click="quickEdit(product, 'add')" class="quick-btn add" title="Adicionar ao estoque">
                  <Plus :size="14" />
                </button>
                <button @click="quickEdit(product, 'remove')" class="quick-btn remove" title="Remover do estoque">
                  <Minus :size="14" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- List View -->
        <div v-else class="products-list" :class="{ compact: compactMode }">
          <div class="list-header sticky">
            <div class="list-col name"><input type="checkbox" v-model="allSelected" /> Produto</div>
            <div class="list-col category">Categoria</div>
            <div class="list-col stock">Estoque</div>
            <div class="list-col price">Preço</div>
            <div class="list-col total">Total</div>
            <div class="list-col status">Status</div>
            <div class="list-col actions">Ações</div>
          </div>

          <div
            v-for="product in paginatedProducts"
            :key="product.id"
            class="list-row"
            :class="getRowClasses(product)"
          >
            <div class="list-col name">
              <input type="checkbox" v-model="selectedIds" :value="product.id" />
              <div class="product-info">
                <div class="product-icon">
                  <Package :size="20" />
                </div>
                <div class="product-details">
                  <span class="product-name">{{ product.nome }}</span>
                  <span class="product-code" v-if="product.codigo_barras">
                    {{ product.codigo_barras }}
                  </span>
                </div>
              </div>
            </div>

            <div class="list-col category">
              <span class="category-badge">
                {{ getProductCategory(product) || 'Sem categoria' }}
              </span>
            </div>

            <div class="list-col stock">
              <div class="stock-info">
                <span class="stock-amount" :class="{ 'critical': product.current_stock <= product.min_stock }">
                  {{ product.current_stock }} {{ product.unidade }}
                </span>
                <div class="mini-stock-bar">
                  <div
                    class="mini-fill"
                    :style="{ width: getStockPercentage(product) + '%' }"
                    :class="getStockClass(product)"
                  ></div>
                </div>
              </div>
            </div>

            <div class="list-col price">
              R$ {{ formatCurrency(product.preco) }}
            </div>

            <div class="list-col total">
              R$ {{ formatCurrency(product.preco * product.current_stock) }}
            </div>

            <div class="list-col status">
              <span class="status-badge" :class="getStockClass(product)">
                {{ getStockStatus(product) }}
              </span>
            </div>

            <div class="list-col actions">
              <div class="action-buttons">
                <button @click="editProduct(product)" class="action-btn edit" title="Editar">
                  <Edit2 :size="14" />
                </button>
                <button @click="viewProduct(product)" class="action-btn view" title="Visualizar">
                  <Eye :size="14" />
                </button>
                <button @click="quickEdit(product, 'add')" class="action-btn add" title="Adicionar">
                  <Plus :size="14" />
                </button>
                <button @click="deleteProducts([product.id])" class="action-btn delete" title="Remover">
                  <Trash2 :size="14" />
                </button>
              </div>
            </div>
          </div>
        </div>
        <div class="pagination-bar" v-if="totalPages > 1">
          <button class="page-btn" :disabled="currentPage === 1" @click="currentPage--">Anterior</button>
          <span class="page-info">Página {{ currentPage }} de {{ totalPages }}</span>
          <button class="page-btn" :disabled="currentPage === totalPages" @click="currentPage++">Próxima</button>
          <span class="page-count">Exibindo {{ paginatedProducts.length }} de {{ filteredProducts.length }}</span>
        </div>
      </div>
    </main>

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

    <!-- Modal de visualização de produto -->
    <div v-if="showViewModal" class="modal-overlay" @click="showViewModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>Detalhes do Produto</h2>
          <button @click="showViewModal = false" class="modal-close">×</button>
        </div>
        <div class="product-view" v-if="selectedProduct">
          <div class="view-grid">
            <div class="view-row"><span class="label">Nome:</span><span class="value">{{ selectedProduct.nome }}</span></div>
            <div class="view-row"><span class="label">Categoria:</span><span class="value">{{ getProductCategory(selectedProduct) }}</span></div>
            <div class="view-row"><span class="label">Estoque:</span><span class="value">{{ selectedProduct.current_stock }} {{ selectedProduct.unidade }}</span></div>
            <div class="view-row"><span class="label">Mínimo:</span><span class="value">{{ selectedProduct.min_stock }}</span></div>
            <div class="view-row"><span class="label">Preço:</span><span class="value">R$ {{ formatCurrency(selectedProduct.preco) }}</span></div>
            <div class="view-row" v-if="selectedProduct.codigo_barras"><span class="label">Código:</span><span class="value">{{ selectedProduct.codigo_barras }}</span></div>
            <div class="view-row" v-if="selectedProduct.descricao"><span class="label">Descrição:</span><span class="value">{{ selectedProduct.descricao }}</span></div>
            <div class="view-row"><span class="label">Atualizado:</span><span class="value">{{ formatDate(selectedProduct.updated_at) }}</span></div>
          </div>
        </div>
      </div>
    </div>
    <!-- Charts Overview -->
    <section class="inventory-charts">
      <div class="chart-card">
        <h3>Distribuição por Categoria</h3>
        <div class="chart-wrapper">
          <Doughnut :data="categoryChartData" :options="{ responsive: true, maintainAspectRatio: false }" />
        </div>
      </div>
      <div class="chart-card">
        <h3>Status de Estoque</h3>
        <div class="chart-wrapper">
          <Bar :data="statusChartData" :options="{ responsive: true, maintainAspectRatio: false, plugins:{legend:{display:false}} }" />
        </div>
      </div>
    </section>

    <!-- Chat IA Modal -->
    <ChatInventoryModal v-model:open="showChat" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase, DB_TABLES } from '@/config/supabase'
import { useAuthStore } from '@/stores/auth'
import type { Product } from '@/types/product'
import { Doughnut, Bar } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'
import jsPDF from 'jspdf'
import 'jspdf-autotable'

ChartJS.register(CategoryScale, LinearScale, BarElement, ArcElement, Title, Tooltip, Legend)

// Icons
import {
  Package, Plus, RefreshCw, AlertTriangle, XCircle, DollarSign, Filter, Search,
  X, Tag, BarChart3, SortAsc, Eye, Grid, List, Loader2, Edit2, Copy, Clock,
  Minus
} from 'lucide-vue-next'
import * as XLSX from 'xlsx'
import ChatInventoryModal from '@/components/ChatInventoryModal.vue'
import { MessageCircle } from 'lucide-vue-next'

const authStore = useAuthStore()

const products = ref<Product[]>([])
const categories = ref<any[]>([])
const loading = ref(false)
const saving = ref(false)
const searchQuery = ref('')
const selectedCategory = ref('')
const stockFilter = ref('')
const sortBy = ref('nome')
const viewMode = ref<'grid' | 'list'>('grid')
const showAddModal = ref(false)
const editingProduct = ref<Product | null>(null)
const selectedIds = ref<string[]>([])
const compactMode = ref(false)
const pageSize = ref(12)
const currentPage = ref(1)
const showChat = ref(false)

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

// Computed properties
const lowStockCount = computed(() =>
  products.value.filter(p => p.current_stock <= p.min_stock && p.current_stock > 0).length
)

const outOfStockCount = computed(() =>
  products.value.filter(p => p.current_stock === 0).length
)

const totalValue = computed(() =>
  products.value.reduce((acc, p) => acc + (p.preco * p.current_stock), 0)
)

const activeFiltersCount = computed(() => {
  let count = 0
  if (searchQuery.value) count++
  if (selectedCategory.value) count++
  if (stockFilter.value) count++
  return count
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
  } else if (stockFilter.value === 'normal') {
    filtered = filtered.filter(product => product.current_stock > product.min_stock)
  }

  return filtered
})

const allSelected = computed({
  get: () => filteredProducts.value.length > 0 && selectedIds.value.length === filteredProducts.value.length,
  set: (val: boolean) => {
    if (val) selectedIds.value = filteredProducts.value.map(p => p.id)
    else selectedIds.value = []
  }
})

const sortedProducts = computed(() => {
  const sorted = [...filteredProducts.value]

  switch (sortBy.value) {
    case 'nome':
      return sorted.sort((a, b) => a.nome.localeCompare(b.nome))
    case 'estoque':
      return sorted.sort((a, b) => b.current_stock - a.current_stock)
    case 'preco':
      return sorted.sort((a, b) => b.preco - a.preco)
    case 'updated_at':
      return sorted.sort((a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime())
    default:
      return sorted
  }
})

// Paginação e utilitários
const totalPages = computed(() => Math.max(1, Math.ceil(filteredProducts.value.length / pageSize.value)))

const paginatedProducts = computed(() => {
  if (currentPage.value > totalPages.value) currentPage.value = totalPages.value
  const start = (currentPage.value - 1) * pageSize.value
  return sortedProducts.value.slice(start, start + pageSize.value)
})

function clearAllFilters() {
  searchQuery.value = ''
  selectedCategory.value = ''
  stockFilter.value = ''
  sortBy.value = 'nome'
}

function toggleCompactMode() {
  compactMode.value = !compactMode.value
}

function exportCSV() {
  const rows = [[
    'Nome','Categoria','Estoque','Mínimo','Unidade','Preço','Total','Status'
  ]]
  filteredProducts.value.forEach(p => {
    rows.push([
      p.nome,
      categories.value.find(c => c.id === p.categoria_id)?.nome || '',
      p.current_stock,
      p.min_stock,
      p.unidade,
      p.preco,
      (p.preco * p.current_stock).toFixed(2),
      getStockStatus(p)
    ] as any)
  })
  const csv = rows.map(r => r.join(',')).join('\n')
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `estoque-${new Date().toISOString().split('T')[0]}.csv`
  link.click()
  URL.revokeObjectURL(url)
}

function exportExcel() {
  const rows = filteredProducts.value.map(p => ({
    Nome: p.nome,
    Categoria: categories.value.find(c => c.id === p.categoria_id)?.nome || '',
    Estoque: p.current_stock,
    Minimo: p.min_stock,
    Unidade: p.unidade,
    Preco: p.preco,
    Total: Number((p.preco * p.current_stock).toFixed(2)),
    Status: getStockStatus(p)
  }))
  const ws = XLSX.utils.json_to_sheet(rows)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Estoque')
  XLSX.writeFile(wb, `estoque-${new Date().toISOString().split('T')[0]}.xlsx`)
}

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
    computeCharts()
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
    computeCharts()
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

async function deleteProducts(ids: string[]) {
  if (!ids.length) return
  if (!confirm(`Remover ${ids.length} produto(s)? Essa ação não pode ser desfeita.`)) return
  try {
    await supabase.from(DB_TABLES.PRODUCTS).delete().in('id', ids)
    await loadProducts()
    selectedIds.value = []
  } catch (error) {
    console.error('Erro ao remover produtos:', error)
    alert('Erro ao remover produtos')
  }
}

async function exportInventoryPDF() {
  try {
    const pdf = new jsPDF('p', 'mm', 'a4')
    let y = 16
    pdf.setFont('helvetica', 'bold')
    pdf.setFontSize(16)
    pdf.text('Relatório de Estoque', 14, y)
    y += 8
    pdf.setFontSize(10)
    pdf.setFont('helvetica', 'normal')
    pdf.text(`Gerado em: ${new Date().toLocaleString('pt-BR')}`, 14, y)
    y += 6
    pdf.text(`Total de itens filtrados: ${filteredProducts.value.length}`, 14, y)
    y += 10

    const head = [['Produto', 'Categoria', 'Estoque', 'Mínimo', 'Unidade', 'Preço', 'Total']]
    const body = filteredProducts.value.map(p => [
      p.nome,
      getProductCategory(p) || '—',
      String(p.current_stock),
      String(p.min_stock),
      p.unidade,
      `R$ ${formatCurrency(p.preco)}`,
      `R$ ${formatCurrency(p.preco * p.current_stock)}`
    ])

    ;(pdf as any).autoTable({
      head,
      body,
      startY: y,
      styles: { fontSize: 9 },
      headStyles: { fillColor: [102, 126, 234] },
      margin: { left: 14, right: 14 }
    })

    pdf.save(`relatorio-estoque-${new Date().toISOString().slice(0,10)}.pdf`)
  } catch (error) {
    console.error('Erro ao gerar PDF:', error)
    alert('Falha ao gerar relatório PDF')
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
  selectedProduct.value = product
  showViewModal.value = true
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

// New helper functions
function getProductCategory(product: Product): string {
  const category = categories.value.find(c => c.id === product.categoria_id)
  return category?.nome || 'Sem categoria'
}

function getStockStatus(product: Product): string {
  if (product.current_stock === 0) return 'Sem estoque'
  if (product.current_stock <= product.min_stock) return 'Estoque baixo'
  return 'Normal'
}

function getStockClass(product: Product): string {
  if (product.current_stock === 0) return 'critical'
  if (product.current_stock <= product.min_stock) return 'warning'
  return 'normal'
}

function getCardClasses(product: Product) {
  return {
    'low-stock': product.current_stock <= product.min_stock && product.current_stock > 0,
    'out-of-stock': product.current_stock === 0,
    'normal-stock': product.current_stock > product.min_stock
  }
}

function getRowClasses(product: Product) {
  return {
    'critical': product.current_stock === 0,
    'warning': product.current_stock <= product.min_stock && product.current_stock > 0,
    'normal': product.current_stock > product.min_stock
  }
}

function duplicateProduct(product: Product) {
  editingProduct.value = null
  productForm.value = {
    nome: `${product.nome} (Cópia)`,
    preco: product.preco,
    custo: product.custo || 0,
    current_stock: 0,
    min_stock: product.min_stock,
    unidade: product.unidade,
    categoria_id: product.categoria_id || '',
    descricao: product.descricao || '',
    codigo_barras: ''
  }
  showAddModal.value = true
}

function quickEdit(product: Product, action: 'add' | 'remove') {
  // Esta função seria expandida para permitir edição rápida de estoque
  const amount = prompt(`${action === 'add' ? 'Adicionar' : 'Remover'} quantos itens?`)
  if (!amount || isNaN(Number(amount))) return

  const newStock = action === 'add'
    ? product.current_stock + Number(amount)
    : Math.max(0, product.current_stock - Number(amount))

  // Aqui você faria uma chamada para atualizar o estoque
  updateProductStock(product.id, newStock)
}

async function updateProductStock(productId: string, newStock: number) {
  try {
    const { error } = await supabase
      .from(DB_TABLES.PRODUCTS)
      .update({
        current_stock: newStock,
        updated_at: new Date().toISOString()
      })
      .eq('id', productId)

    if (error) throw error
    await loadProducts()
  } catch (error) {
    console.error('Erro ao atualizar estoque:', error)
    alert('Erro ao atualizar estoque')
  }
}

onMounted(() => {
  loadProducts()
  loadCategories()
  computeCharts()
})

// Charts
const categoryChartData = ref<any>({ labels: [], datasets: [] })
const statusChartData = ref<any>({ labels: [], datasets: [] })

function computeCharts() {
  // Distribuição por categoria
  const counts: Record<string, number> = {}
  products.value.forEach(p => {
    const cat = categories.value.find((c:any) => c.id === p.categoria_id)?.nome || 'Sem categoria'
    counts[cat] = (counts[cat] || 0) + 1
  })
  categoryChartData.value = {
    labels: Object.keys(counts),
    datasets: [{ data: Object.values(counts), backgroundColor: ['#667eea','#10b981','#f59e0b','#ef4444','#8b5cf6','#06b6d4','#22c55e'] }]
  }

  // Estoque crítico x normal
  let crit = 0, low = 0, ok = 0
  products.value.forEach(p => {
    if (p.current_stock === 0) crit++
    else if (p.current_stock <= p.min_stock) low++
    else ok++
  })
  statusChartData.value = {
    labels: ['Sem estoque','Baixo','Normal'],
    datasets: [{
      label: 'Produtos',
      data: [crit, low, ok],
      backgroundColor: ['#ef4444','#f59e0b','#10b981']
    }]
  }
}

const selectedProduct = ref<Product | null>(null)
const showViewModal = ref(false)
</script>

<style scoped>
/* ===== INVENTORY VIEW - PROFESSIONAL STYLES ===== */

/* Container Principal */
.inventory-container {
  width: 100vw;
  min-height: 100vh;
  background: var(--theme-background-solid);
  overflow-x: hidden;
}

/* ===== HEADER PRINCIPAL ===== */
.inventory-header {
  background: var(--theme-surface);
  border-bottom: 1px solid var(--theme-border);
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 10px var(--theme-shadow);
}

.header-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  max-width: none;
}

.header-left .title-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 28px;
  font-weight: 700;
  color: var(--theme-text-primary);
  margin: 0;
}

.page-subtitle {
  color: var(--theme-text-secondary);
  font-size: 14px;
  font-weight: 500;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

/* Estatísticas Rápidas */
.quick-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  padding: 24px 32px;
  background: var(--theme-surface);
  border-bottom: 1px solid var(--theme-border);
}

.stat-card {
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 16px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px var(--theme-shadow);
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px var(--theme-shadow);
}

.stat-card.primary .stat-icon { background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary)); }
.stat-card.warning .stat-icon { background: linear-gradient(135deg, var(--theme-accent-warning), #d97706); }
.stat-card.danger .stat-icon { background: linear-gradient(135deg, var(--theme-accent-error), #dc2626); }
.stat-card.success .stat-icon { background: linear-gradient(135deg, var(--theme-accent-success), #059669); }

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 800;
  color: var(--theme-text-primary);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: var(--theme-text-secondary);
  font-weight: 500;
}

/* ===== FILTROS ===== */
.filters-section {
  background: var(--theme-surface);
  border-bottom: 1px solid var(--theme-border);
  padding: 24px 32px;
}

.filters-header h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--theme-text-primary);
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 20px 0;
}

.filters-grid {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Busca */
.search-container {
  flex: 1;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 16px;
  color: var(--theme-text-muted);
  z-index: 1;
}

.search-input {
  width: 100%;
  padding: 14px 16px 14px 48px;
  background: var(--theme-surface);
  border: 2px solid var(--theme-border);
  border-radius: 12px;
  font-size: 16px;
  color: var(--theme-text-primary);
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: var(--theme-primary);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.clear-search {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  color: var(--theme-text-muted);
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.clear-search:hover {
  background: var(--theme-border);
  color: var(--theme-text-primary);
}

/* Controles de Filtro */
.filter-controls {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.filter-select {
  padding: 10px 12px;
  background: var(--theme-surface);
  border: 2px solid var(--theme-border);
  border-radius: 8px;
  color: var(--theme-text-primary);
  font-size: 14px;
  transition: all 0.3s ease;
}

.filter-select:focus {
  outline: none;
  border-color: var(--theme-primary);
}

.view-toggle {
  display: flex;
  border: 2px solid var(--theme-border);
  border-radius: 8px;
  overflow: hidden;
}

.view-btn {
  flex: 1;
  padding: 8px 12px;
  background: var(--theme-surface);
  border: none;
  color: var(--theme-text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.view-btn:hover {
  background: var(--theme-border);
}

.view-btn.active {
  background: var(--theme-primary);
  color: white;
}

/* ===== SEÇÃO DE PRODUTOS ===== */
.products-section {
  padding: 32px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.results-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.results-count {
  font-size: 16px;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.filter-badges {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.section-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.tool-btn {
  padding: 8px 12px;
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 8px;
  color: var(--theme-text-secondary);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.tool-btn:hover { background: var(--theme-border); }
.tool-btn.active { background: var(--theme-primary); color: #fff; border-color: var(--theme-primary); }
.tool-btn:disabled { opacity: 0.6; cursor: not-allowed; }

.page-size { display: flex; align-items: center; gap: 6px; }
.filter-select.small { padding: 6px 8px; font-size: 12px; }

.filter-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  background: var(--theme-primary);
  color: white;
  padding: 4px 8px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 500;
}

.remove-filter {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 2px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.remove-filter:hover {
  background: rgba(255, 255, 255, 0.2);
}

/* Estados de Loading e Vazio */
.loading-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.loader {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  color: var(--theme-text-secondary);
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.empty-content {
  text-align: center;
  color: var(--theme-text-secondary);
}

.empty-content h3 {
  color: var(--theme-text-primary);
  font-size: 24px;
  font-weight: 600;
  margin: 16px 0 8px;
}

.empty-content p {
  margin: 8px 0 24px;
  font-size: 16px;
}

/* ===== GRID VIEW ===== */
.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}
.products-grid.compact .product-card { max-height: 220px; }
.products-grid.compact .card-content { padding: 10px 12px; }
.products-grid.compact .product-name { font-size: 14px; }

.product-card {
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px var(--theme-shadow);
  max-height: 280px;
}

.product-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px var(--theme-shadow);
}

.product-card.low-stock {
  border-left: 3px solid var(--theme-accent-warning);
}

.product-card.out-of-stock {
  border-left: 3px solid var(--theme-accent-error);
}

.product-card.normal-stock {
  border-left: 3px solid var(--theme-accent-success);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px 0;
}
.status-chip {
  font-size: 11px;
  font-weight: 700;
  padding: 4px 8px;
  border-radius: 999px;
}
.status-chip.normal { background: #ecfdf5; color: #065f46; }
.status-chip.warning { background: #fff7ed; color: #b45309; }
.status-chip.critical { background: #fee2e2; color: #991b1b; }

.product-image {
  width: 32px;
  height: 32px;
  background: var(--theme-border);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--theme-text-secondary);
  font-size: 14px;
}

.product-actions {
  display: flex;
  gap: 2px;
}

.action-btn {
  width: 28px;
  height: 28px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  font-size: 12px;
}

.action-btn.edit {
  background: rgba(102, 126, 234, 0.1);
  color: var(--theme-primary);
}

.action-btn.edit:hover {
  background: var(--theme-primary);
  color: white;
}

.action-btn.view {
  background: rgba(16, 185, 129, 0.1);
  color: var(--theme-accent-success);
}

.action-btn.view:hover {
  background: var(--theme-accent-success);
  color: white;
}

.action-btn.duplicate {
  background: rgba(245, 158, 11, 0.1);
  color: var(--theme-accent-warning);
}

.action-btn.duplicate:hover {
  background: var(--theme-accent-warning);
  color: white;
}

.card-content {
  padding: 12px 16px;
}

.product-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--theme-text-primary);
  margin: 0 0 4px;
  line-height: 1.2;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.product-category {
  font-size: 12px;
  color: var(--theme-text-secondary);
  margin: 0 0 12px;
}

.product-stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
  margin-bottom: 12px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.stat-label {
  font-size: 10px;
  color: var(--theme-text-muted);
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.stat-value {
  font-size: 14px;
  font-weight: 600;
  color: var(--theme-text-primary);
  line-height: 1.1;
}

.stat-value.critical {
  color: var(--theme-accent-error);
}

.stat-value.zero {
  color: var(--theme-accent-error);
}

.stat-value.price {
  color: var(--theme-accent-success);
}

.stat-value.total {
  color: var(--theme-primary);
}

.stock-indicator {
  margin-top: 10px;
}

.stock-bar {
  width: 100%;
  height: 6px;
  background: var(--theme-border);
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 6px;
}

.stock-fill {
  height: 100%;
  transition: all 0.3s ease;
  border-radius: 3px;
}

.stock-fill.normal {
  background: var(--theme-accent-success);
}

.stock-fill.warning {
  background: var(--theme-accent-warning);
}

.stock-fill.critical {
  background: var(--theme-accent-error);
}

.stock-text {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 10px;
  color: var(--theme-text-secondary);
  font-weight: 500;
}

.stock-ratio {
  color: var(--theme-text-muted);
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 16px 14px;
}

.last-updated {
  display: flex;
  align-items: center;
  gap: 3px;
  font-size: 10px;
  color: var(--theme-text-muted);
}

.quick-actions {
  display: flex;
  gap: 2px;
}

.quick-btn {
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  font-size: 11px;
}

.quick-btn.add {
  background: rgba(16, 185, 129, 0.1);
  color: var(--theme-accent-success);
}

.quick-btn.add:hover {
  background: var(--theme-accent-success);
  color: white;
}

.quick-btn.remove {
  background: rgba(239, 68, 68, 0.1);
  color: var(--theme-accent-error);
}

.quick-btn.remove:hover {
  background: var(--theme-accent-error);
  color: white;
}

/* ===== LIST VIEW ===== */
.products-list {
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 8px;
  overflow: hidden;
}
.products-list.compact .list-row { padding: 10px 14px; }
.products-list.compact .list-col { font-size: 12px; }
.products-list .sticky { position: sticky; top: 80px; background: var(--theme-surface); z-index: 5; }

.list-header {
  display: grid;
  grid-template-columns: 2.5fr 1fr 1fr 1fr 1fr 1fr 1fr;
  gap: 12px;
  padding: 12px 16px;
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.05);
  font-weight: 600;
  color: var(--theme-text-primary);
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  border-bottom: 1px solid var(--theme-border);
}

.list-row {
  display: grid;
  grid-template-columns: 2.5fr 1fr 1fr 1fr 1fr 1fr 1fr;
  gap: 12px;
  padding: 12px 16px;
  border-bottom: 1px solid var(--theme-border);
  transition: all 0.2s ease;
  min-height: 60px;
  align-items: center;
}
.list-row:nth-child(odd) { background: rgba(0,0,0,0.01); }

.list-row:hover {
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.02);
}

.list-row:last-child {
  border-bottom: none;
}

.list-row.critical {
  border-left: 3px solid var(--theme-accent-error);
}

.list-row.warning {
  border-left: 3px solid var(--theme-accent-warning);
}

.list-row.normal {
  border-left: 3px solid var(--theme-accent-success);
}

.list-col {
  display: flex;
  align-items: center;
  font-size: 13px;
  color: var(--theme-text-primary);
  overflow: hidden;
}

.list-col.name .product-info {
  display: flex;
  align-items: center;
  gap: 10px;
  overflow: hidden;
  width: 100%;
}

.product-icon {
  width: 28px;
  height: 28px;
  background: var(--theme-border);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--theme-text-secondary);
  flex-shrink: 0;
  font-size: 12px;
}

.product-details {
  display: flex;
  flex-direction: column;
  gap: 1px;
  overflow: hidden;
  flex: 1;
}

.product-name {
  font-weight: 600;
  color: var(--theme-text-primary);
  font-size: 13px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.3;
}

.product-code {
  font-size: 11px;
  color: var(--theme-text-muted);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.category-badge {
  background: rgba(var(--theme-primary-rgb, 102, 126, 234), 0.1);
  color: var(--theme-text-secondary);
  padding: 2px 6px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.stock-info {
  display: flex;
  flex-direction: column;
  gap: 3px;
  align-items: flex-start;
}

.stock-amount {
  font-weight: 600;
  font-size: 13px;
}

.stock-amount.critical {
  color: var(--theme-accent-error);
}

.stock-amount.warning {
  color: var(--theme-accent-warning);
}

.stock-amount.normal {
  color: var(--theme-accent-success);
}

.mini-stock-bar {
  width: 50px;
  height: 3px;
  background: var(--theme-border);
  border-radius: 2px;
  overflow: hidden;
}

.mini-fill {
  height: 100%;
  transition: all 0.3s ease;
}

.mini-fill.normal {
  background: var(--theme-accent-success);
}

.mini-fill.warning {
  background: var(--theme-accent-warning);
}

.mini-fill.critical {
  background: var(--theme-accent-error);
}

.status-badge {
  padding: 3px 6px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 500;
  white-space: nowrap;
}

.status-badge.normal {
  background: rgba(16, 185, 129, 0.1);
  color: var(--theme-accent-success);
}

.status-badge.warning {
  background: rgba(245, 158, 11, 0.1);
  color: var(--theme-accent-warning);
}

.status-badge.critical {
  background: rgba(239, 68, 68, 0.1);
  color: var(--theme-accent-error);
}

.action-buttons {
  display: flex;
  gap: 2px;
  justify-content: flex-end;
}

.action-buttons .action-btn {
  width: 24px;
  height: 24px;
  font-size: 11px;
}

/* ===== BOTÕES ===== */
.btn-primary, .btn-secondary {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 14px;
  transition: all 0.3s ease;
  cursor: pointer;
  border: none;
}

.btn-primary {
  background: linear-gradient(135deg, var(--theme-primary), var(--theme-secondary));
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px var(--theme-shadow);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn-secondary {
  background: var(--theme-surface);
  color: var(--theme-text-primary);
  border: 2px solid var(--theme-border);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--theme-border);
  border-color: var(--theme-primary);
}

/* ===== MODAL ===== */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: var(--theme-surface);
  border-radius: 16px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px var(--theme-shadow);
  animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid var(--theme-border);
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: var(--theme-text-primary);
}

.modal-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--theme-text-muted);
  padding: 4px;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.modal-close:hover {
  background: var(--theme-border);
  color: var(--theme-text-primary);
}

.product-form {
  padding: 24px;
}

.form-group {
  margin-bottom: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: var(--theme-text-primary);
  font-weight: 600;
  font-size: 14px;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 12px 16px;
  background: var(--theme-surface);
  border: 2px solid var(--theme-border);
  border-radius: 8px;
  font-size: 16px;
  color: var(--theme-text-primary);
  transition: all 0.3s ease;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--theme-primary);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
  font-family: inherit;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid var(--theme-border);
}

/* Pagination */
.pagination-bar {
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: flex-end;
  padding: 14px 0 0;
}
.page-btn {
  padding: 8px 10px;
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 8px;
  cursor: pointer;
}
.page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.page-info { color: var(--theme-text-secondary); font-size: 13px; }
.page-count { color: var(--theme-text-muted); font-size: 12px; }

.product-view .view-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.product-view .view-row { display: flex; gap: 8px; align-items: center; }
.product-view .label { width: 110px; color: var(--theme-text-muted); font-size: 12px; }
.product-view .value { font-weight: 600; }

/* ===== RESPONSIVIDADE ===== */
@media (max-width: 1400px) {
  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }
}

@media (max-width: 1200px) {
  .header-main {
    padding: 20px 24px;
  }

  .quick-stats {
    padding: 20px 24px;
    grid-template-columns: repeat(2, 1fr);
  }

  .filters-section {
    padding: 20px 24px;
  }

  .products-section {
    padding: 24px;
  }

  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 14px;
  }

  .list-header,
  .list-row {
    grid-template-columns: 2fr 0.8fr 0.8fr 0.8fr 0.8fr 1fr 0.8fr;
    gap: 8px;
    padding: 10px 14px;
  }
}

@media (max-width: 968px) {
  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 12px;
  }

  .list-header,
  .list-row {
    grid-template-columns: 2fr 1fr 1fr 1fr 1fr;
    gap: 6px;
    font-size: 12px;
  }

  .list-header span:nth-child(n+6),
  .list-row > div:nth-child(n+6) {
    display: none;
  }
}

@media (max-width: 768px) {
  .header-main {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
    padding: 20px;
  }

  .header-actions {
    justify-content: center;
  }

  .quick-stats {
    grid-template-columns: 1fr;
    padding: 20px;
    gap: 16px;
  }

  .filters-section {
    padding: 20px;
  }

  .filter-controls {
    grid-template-columns: 1fr;
  }

  .products-section {
    padding: 20px;
  }

  .products-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .product-card {
    max-height: none;
  }

  /* Lista em mobile - layout vertical */
  .products-list {
    border-radius: 6px;
  }

  .list-header {
    display: none;
  }

  .list-row {
    display: block;
    padding: 16px;
    border-radius: 8px;
    margin-bottom: 8px;
    background: var(--theme-surface);
    border: 1px solid var(--theme-border);
  }

  .list-col {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 6px 0;
    border-bottom: 1px solid rgba(var(--theme-border-rgb, 226, 232, 240), 0.5);
    font-size: 13px;
  }

  .list-col:last-child {
    border-bottom: none;
    padding-bottom: 0;
  }

  .list-col:before {
    content: attr(data-label);
    font-weight: 600;
    color: var(--theme-text-secondary);
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    min-width: 80px;
  }

  .list-col.name:before {
    content: "Produto";
  }

  .list-col.category:before {
    content: "Categoria";
  }

  .list-col.stock:before {
    content: "Estoque";
  }

  .list-col.price:before {
    content: "Preço";
  }

  .list-col.total:before {
    content: "Total";
  }

  .list-col.status:before {
    content: "Status";
  }

  .list-col.actions:before {
    content: "Ações";
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column;
  }
}

@media (max-width: 480px) {
  .header-main {
    padding: 16px;
  }

  .quick-stats,
  .filters-section,
  .products-section {
    padding: 16px;
  }

  .products-grid {
    gap: 10px;
  }

  .product-card {
    border-radius: 8px;
  }

  .card-header,
  .card-content,
  .card-footer {
    padding-left: 12px;
    padding-right: 12px;
  }

  .list-row {
    padding: 12px;
    margin-bottom: 6px;
  }
}

/* Inventory charts overview */
.inventory-charts { display:grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; padding: 0 32px 32px }
.inventory-charts .chart-card { background: var(--theme-surface); border:1px solid var(--theme-border); border-radius: 16px; padding: 16px; box-shadow: 0 4px 20px var(--theme-shadow) }
.inventory-charts .chart-card h3 { margin: 0 0 10px 0; color: var(--theme-text-primary) }
.inventory-charts .chart-wrapper { height: 240px }
</style>
