<template>
  <div class="api-playground-overlay" @click="handleOverlayClick">
    <div class="api-playground" @click.stop>
      <header class="playground-header">
        <div class="header-left">
          <Terminal :size="24" />
          <div>
            <h2>API Playground</h2>
            <p>Teste as APIs do GestaoZe System</p>
          </div>
        </div>
        <button @click="$emit('close')" class="close-btn">
          <X :size="24" />
        </button>
      </header>

      <div class="playground-content">
        <!-- Endpoint Selector -->
        <div class="endpoint-section">
          <h3>Endpoints Disponíveis</h3>
          <div class="endpoints-grid">
            <div
              v-for="endpoint in availableEndpoints"
              :key="endpoint.id"
              class="endpoint-card"
              :class="{ active: selectedEndpoint?.id === endpoint.id }"
              @click="selectEndpoint(endpoint)"
            >
              <div class="endpoint-method" :class="endpoint.method.toLowerCase()">
                {{ endpoint.method }}
              </div>
              <div class="endpoint-info">
                <div class="endpoint-path">{{ endpoint.path }}</div>
                <div class="endpoint-description">{{ endpoint.description }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Request Configuration -->
        <div v-if="selectedEndpoint" class="request-section">
          <h3>Configuração da Requisição</h3>

          <div class="request-config">
            <!-- Method and URL -->
            <div class="url-section">
              <div class="method-badge" :class="selectedEndpoint.method.toLowerCase()">
                {{ selectedEndpoint.method }}
              </div>
              <input
                v-model="requestUrl"
                class="url-input"
                :placeholder="selectedEndpoint.path"
                readonly
              />
            </div>

            <!-- Headers -->
            <div class="config-group">
              <h4>Headers</h4>
              <div class="headers-list">
                <div v-for="(header, index) in requestHeaders" :key="index" class="header-item">
                  <input v-model="header.key" placeholder="Nome do header" class="header-input" />
                  <input v-model="header.value" placeholder="Valor" class="header-input" />
                  <button @click="removeHeader(index)" class="remove-btn">
                    <Trash2 :size="16" />
                  </button>
                </div>
                <button @click="addHeader" class="add-btn">
                  <Plus :size="16" />
                  Adicionar Header
                </button>
              </div>
            </div>

            <!-- Parameters -->
            <div v-if="selectedEndpoint.parameters?.length" class="config-group">
              <h4>Parâmetros</h4>
              <div class="params-list">
                <div v-for="param in selectedEndpoint.parameters" :key="param.name" class="param-item">
                  <label class="param-label">
                    {{ param.name }}
                    <span v-if="param.required" class="required">*</span>
                  </label>
                  <input
                    v-model="requestParams[param.name]"
                    :placeholder="param.description"
                    :type="param.type === 'number' ? 'number' : 'text'"
                    class="param-input"
                    :required="param.required"
                  />
                  <small class="param-description">{{ param.description }}</small>
                </div>
              </div>
            </div>

            <!-- Body (for POST/PUT) -->
            <div v-if="['POST', 'PUT', 'PATCH'].includes(selectedEndpoint.method)" class="config-group">
              <h4>Body</h4>
              <div class="body-section">
                <div class="body-type-tabs">
                  <button
                    @click="bodyType = 'json'"
                    class="tab-btn"
                    :class="{ active: bodyType === 'json' }"
                  >
                    JSON
                  </button>
                  <button
                    @click="bodyType = 'form'"
                    class="tab-btn"
                    :class="{ active: bodyType === 'form' }"
                  >
                    Form Data
                  </button>
                </div>

                <div v-if="bodyType === 'json'" class="json-editor">
                  <textarea
                    v-model="requestBody"
                    placeholder="{ ... }"
                    class="json-textarea"
                    rows="10"
                  ></textarea>
                  <button @click="formatJSON" class="format-btn">
                    <Code :size="16" />
                    Formatar JSON
                  </button>
                </div>

                <div v-if="bodyType === 'form'" class="form-data">
                  <div v-for="(field, index) in formData" :key="index" class="form-field">
                    <input v-model="field.key" placeholder="Nome do campo" class="field-input" />
                    <input v-model="field.value" placeholder="Valor" class="field-input" />
                    <button @click="removeFormField(index)" class="remove-btn">
                      <Trash2 :size="16" />
                    </button>
                  </div>
                  <button @click="addFormField" class="add-btn">
                    <Plus :size="16" />
                    Adicionar Campo
                  </button>
                </div>
              </div>
            </div>

            <!-- Send Request Button -->
            <div class="send-section">
              <button
                @click="sendRequest"
                class="send-btn"
                :disabled="isLoading"
                :class="{ loading: isLoading }"
              >
                <component :is="isLoading ? Loader2 : Send" :size="20" :class="{ spinning: isLoading }" />
                {{ isLoading ? 'Enviando...' : 'Enviar Requisição' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Response Section -->
        <div v-if="response" class="response-section">
          <h3>Resposta</h3>

          <div class="response-info">
            <div class="status-badge" :class="getStatusClass(response.status)">
              {{ response.status }} {{ response.statusText }}
            </div>
            <div class="response-time">
              <Clock :size="16" />
              {{ response.time }}ms
            </div>
          </div>

          <div class="response-tabs">
            <button
              @click="responseTab = 'body'"
              class="tab-btn"
              :class="{ active: responseTab === 'body' }"
            >
              Response Body
            </button>
            <button
              @click="responseTab = 'headers'"
              class="tab-btn"
              :class="{ active: responseTab === 'headers' }"
            >
              Headers
            </button>
          </div>

          <div class="response-content">
            <div v-if="responseTab === 'body'" class="response-body">
              <CodeBlock
                :code="formatResponseBody(response.data)"
                :language="getResponseLanguage(response.headers['content-type'])"
                filename="response.json"
              />
            </div>

            <div v-if="responseTab === 'headers'" class="response-headers">
              <div class="headers-table">
                <div v-for="(value, key) in response.headers" :key="key" class="header-row">
                  <span class="header-name">{{ key }}</span>
                  <span class="header-value">{{ value }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Error Section -->
        <div v-if="error" class="error-section">
          <div class="error-banner">
            <AlertCircle :size="20" />
            <span>{{ error.message }}</span>
          </div>

          <CodeBlock
            v-if="error.details"
            :code="JSON.stringify(error.details, null, 2)"
            language="json"
            filename="error-details.json"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Terminal, X, Plus, Trash2, Send, Loader2, Code, Clock, AlertCircle
} from 'lucide-vue-next'
import CodeBlock from './CodeBlock.vue'
import { supabase } from '@/config/supabase'

interface Endpoint {
  id: string
  method: string
  path: string
  description: string
  parameters?: Parameter[]
  example?: any
}

interface Parameter {
  name: string
  type: string
  required: boolean
  description: string
}

interface RequestHeader {
  key: string
  value: string
}

interface FormField {
  key: string
  value: string
}

const emit = defineEmits<{
  close: []
}>()

// Estados
const selectedEndpoint = ref<Endpoint | null>(null)
const requestUrl = ref('')
const requestHeaders = ref<RequestHeader[]>([
  { key: 'Content-Type', value: 'application/json' },
  { key: 'Authorization', value: 'Bearer YOUR_TOKEN' }
])
const requestParams = ref<Record<string, any>>({})
const requestBody = ref('')
const bodyType = ref<'json' | 'form'>('json')
const formData = ref<FormField[]>([{ key: '', value: '' }])
const response = ref<any>(null)
const error = ref<any>(null)
const isLoading = ref(false)
const responseTab = ref<'body' | 'headers'>('body')

// Endpoints disponíveis
const availableEndpoints = ref<Endpoint[]>([
  {
    id: 'get-products',
    method: 'GET',
    path: '/api/products',
    description: 'Listar todos os produtos',
    parameters: [
      { name: 'limit', type: 'number', required: false, description: 'Número máximo de produtos' },
      { name: 'category', type: 'string', required: false, description: 'Filtrar por categoria' }
    ]
  },
  {
    id: 'create-product',
    method: 'POST',
    path: '/api/products',
    description: 'Criar novo produto',
    example: {
      nome: 'Produto Exemplo',
      descricao: 'Descrição do produto',
      preco: 10.99,
      categoria_id: 1,
      quantidade_estoque: 100
    }
  },
  {
    id: 'get-movements',
    method: 'GET',
    path: '/api/movements',
    description: 'Listar movimentações de estoque',
    parameters: [
      { name: 'product_id', type: 'number', required: false, description: 'ID do produto' },
      { name: 'type', type: 'string', required: false, description: 'Tipo: entrada ou saida' }
    ]
  },
  {
    id: 'auth-login',
    method: 'POST',
    path: '/api/auth/login',
    description: 'Fazer login no sistema',
    example: {
      email: 'admin@exemplo.com',
      password: 'senha123'
    }
  },
  {
    id: 'get-dashboard-stats',
    method: 'GET',
    path: '/api/dashboard/stats',
    description: 'Obter estatísticas do dashboard'
  }
])

const baseUrl = computed(() => {
  return 'https://cxusoclwtixtjwghjlcj.supabase.co'
})

function selectEndpoint(endpoint: Endpoint) {
  selectedEndpoint.value = endpoint
  requestUrl.value = `${baseUrl.value}${endpoint.path}`

  // Reset form
  requestParams.value = {}
  if (endpoint.example) {
    requestBody.value = JSON.stringify(endpoint.example, null, 2)
  } else {
    requestBody.value = ''
  }

  response.value = null
  error.value = null
}

function addHeader() {
  requestHeaders.value.push({ key: '', value: '' })
}

function removeHeader(index: number) {
  requestHeaders.value.splice(index, 1)
}

function addFormField() {
  formData.value.push({ key: '', value: '' })
}

function removeFormField(index: number) {
  formData.value.splice(index, 1)
}

function formatJSON() {
  try {
    const parsed = JSON.parse(requestBody.value)
    requestBody.value = JSON.stringify(parsed, null, 2)
  } catch (err) {
    console.error('Invalid JSON:', err)
  }
}

async function sendRequest() {
  if (!selectedEndpoint.value) return

  isLoading.value = true
  response.value = null
  error.value = null

  const startTime = Date.now()

  try {
    // Construir headers
    const headers: Record<string, string> = {}
    requestHeaders.value.forEach(header => {
      if (header.key.trim() && header.value.trim()) {
        headers[header.key.trim()] = header.value.trim()
      }
    })

    // Construir URL com parâmetros
    let url = requestUrl.value
    const params = new URLSearchParams()
    Object.entries(requestParams.value).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== '') {
        params.append(key, String(value))
      }
    })
    if (params.toString()) {
      url += `?${params.toString()}`
    }

    // Construir body
    let body: any = undefined
    if (['POST', 'PUT', 'PATCH'].includes(selectedEndpoint.value.method)) {
      if (bodyType.value === 'json' && requestBody.value.trim()) {
        body = requestBody.value
      } else if (bodyType.value === 'form') {
        const formDataBody = new FormData()
        formData.value.forEach(field => {
          if (field.key.trim() && field.value.trim()) {
            formDataBody.append(field.key.trim(), field.value.trim())
          }
        })
        body = formDataBody
        delete headers['Content-Type'] // Let browser set it for FormData
      }
    }

    // Fazer requisição
    const fetchOptions: RequestInit = {
      method: selectedEndpoint.value.method,
      headers,
    }

    if (body) {
      fetchOptions.body = body
    }

    const fetchResponse = await fetch(url, fetchOptions)
    const responseData = await fetchResponse.text()

    let parsedData
    try {
      parsedData = JSON.parse(responseData)
    } catch {
      parsedData = responseData
    }

    const endTime = Date.now()

    response.value = {
      status: fetchResponse.status,
      statusText: fetchResponse.statusText,
      headers: Object.fromEntries(fetchResponse.headers.entries()),
      data: parsedData,
      time: endTime - startTime
    }

  } catch (err: any) {
    const endTime = Date.now()

    error.value = {
      message: err.message || 'Erro na requisição',
      details: err,
      time: endTime - startTime
    }
  }

  isLoading.value = false
}

function getStatusClass(status: number) {
  if (status >= 200 && status < 300) return 'success'
  if (status >= 400 && status < 500) return 'client-error'
  if (status >= 500) return 'server-error'
  return 'info'
}

function formatResponseBody(data: any): string {
  if (typeof data === 'string') return data
  return JSON.stringify(data, null, 2)
}

function getResponseLanguage(contentType: string): string {
  if (contentType?.includes('json')) return 'json'
  if (contentType?.includes('html')) return 'html'
  if (contentType?.includes('xml')) return 'xml'
  return 'text'
}

function handleOverlayClick() {
  emit('close')
}

onMounted(() => {
  // Select first endpoint by default
  if (availableEndpoints.value.length > 0) {
    selectEndpoint(availableEndpoints.value[0])
  }
})
</script>

<style scoped>
.api-playground-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 2rem;
}

.api-playground {
  background: var(--docs-card-bg, #ffffff);
  border-radius: 20px;
  width: 100%;
  max-width: 1200px;
  max-height: 90vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
}

.playground-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem 2rem;
  background: var(--docs-primary, #667eea);
  color: white;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-left h2 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
}

.header-left p {
  margin: 0;
  opacity: 0.9;
  font-size: 0.875rem;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 10px;
  padding: 0.5rem;
  color: white;
  cursor: pointer;
  transition: all 0.2s ease;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.playground-content {
  flex: 1;
  overflow-y: auto;
  padding: 2rem;
}

.endpoint-section h3,
.request-section h3,
.response-section h3 {
  margin: 0 0 1.5rem 0;
  color: var(--docs-text, #1a202c);
  font-size: 1.25rem;
  font-weight: 700;
}

.endpoints-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.endpoint-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.endpoint-card:hover,
.endpoint-card.active {
  border-color: var(--docs-primary, #667eea);
  background: rgba(102, 126, 234, 0.05);
}

.endpoint-method {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.endpoint-method.get { background: #10b981; color: white; }
.endpoint-method.post { background: #3b82f6; color: white; }
.endpoint-method.put { background: #f59e0b; color: white; }
.endpoint-method.delete { background: #ef4444; color: white; }

.endpoint-info {
  flex: 1;
}

.endpoint-path {
  font-family: 'Fira Code', monospace;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.endpoint-description {
  font-size: 0.875rem;
  color: var(--docs-text-muted, #64748b);
}

.request-section {
  margin: 2rem 0;
}

.request-config {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.url-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.method-badge {
  padding: 0.75rem 1rem;
  border-radius: 8px;
  font-weight: 700;
  text-transform: uppercase;
  font-size: 0.875rem;
  min-width: 80px;
  text-align: center;
}

.url-input {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 8px;
  background: var(--docs-input-bg, #ffffff);
  color: var(--docs-text, #1a202c);
  font-family: 'Fira Code', monospace;
  font-size: 0.875rem;
}

.config-group {
  background: var(--docs-hover, #f8fafc);
  border-radius: 12px;
  padding: 1.5rem;
}

.config-group h4 {
  margin: 0 0 1rem 0;
  color: var(--docs-text, #1a202c);
  font-weight: 600;
}

.header-item,
.param-item,
.form-field {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.header-input,
.param-input,
.field-input {
  flex: 1;
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--docs-border, #e2e8f0);
  border-radius: 6px;
  background: var(--docs-input-bg, #ffffff);
  color: var(--docs-text, #1a202c);
  font-size: 0.875rem;
}

.param-label {
  font-weight: 600;
  min-width: 120px;
  color: var(--docs-text, #1a202c);
}

.required {
  color: var(--docs-error, #ef4444);
}

.param-description {
  color: var(--docs-text-muted, #64748b);
  font-size: 0.75rem;
  margin-top: 0.25rem;
}

.add-btn,
.remove-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s ease;
}

.add-btn {
  background: var(--docs-primary, #667eea);
  color: white;
}

.add-btn:hover {
  background: var(--docs-primary-dark, #5a67d8);
}

.remove-btn {
  background: var(--docs-error, #ef4444);
  color: white;
  padding: 0.5rem;
  min-width: auto;
}

.remove-btn:hover {
  background: #dc2626;
}

.body-type-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.tab-btn {
  padding: 0.5rem 1rem;
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 8px;
  background: var(--docs-button-bg, #ffffff);
  color: var(--docs-text-muted, #64748b);
  cursor: pointer;
  transition: all 0.2s ease;
}

.tab-btn.active,
.tab-btn:hover {
  border-color: var(--docs-primary, #667eea);
  background: var(--docs-primary, #667eea);
  color: white;
}

.json-textarea {
  width: 100%;
  padding: 1rem;
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 8px;
  background: var(--docs-code-bg, #f8fafc);
  color: var(--docs-text, #1a202c);
  font-family: 'Fira Code', monospace;
  font-size: 0.875rem;
  line-height: 1.5;
  resize: vertical;
}

.format-btn {
  margin-top: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border: 1px solid var(--docs-border, #e2e8f0);
  border-radius: 6px;
  background: var(--docs-button-bg, #ffffff);
  color: var(--docs-text-muted, #64748b);
  cursor: pointer;
  font-size: 0.875rem;
}

.send-section {
  text-align: center;
  padding-top: 1rem;
}

.send-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 2rem;
  background: var(--docs-primary, #667eea);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 200px;
  justify-content: center;
}

.send-btn:hover:not(:disabled) {
  background: var(--docs-primary-dark, #5a67d8);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.send-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.spinning {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.response-section {
  margin-top: 2rem;
  border-top: 2px solid var(--docs-border, #e2e8f0);
  padding-top: 2rem;
}

.response-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.status-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.875rem;
}

.status-badge.success { background: rgba(16, 185, 129, 0.1); color: #10b981; }
.status-badge.client-error { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
.status-badge.server-error { background: rgba(239, 68, 68, 0.1); color: #ef4444; }
.status-badge.info { background: rgba(59, 130, 246, 0.1); color: #3b82f6; }

.response-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--docs-text-muted, #64748b);
  font-size: 0.875rem;
}

.response-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.headers-table {
  background: var(--docs-code-bg, #f8fafc);
  border-radius: 8px;
  padding: 1rem;
}

.header-row {
  display: flex;
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--docs-border, #e2e8f0);
}

.header-row:last-child {
  border-bottom: none;
}

.header-name {
  font-weight: 600;
  min-width: 200px;
  color: var(--docs-text, #1a202c);
}

.header-value {
  font-family: 'Fira Code', monospace;
  font-size: 0.875rem;
  color: var(--docs-text-muted, #64748b);
}

.error-section {
  margin-top: 2rem;
}

.error-banner {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border-radius: 12px;
  margin-bottom: 1rem;
  font-weight: 600;
}

/* Responsividade */
@media (max-width: 768px) {
  .api-playground-overlay {
    padding: 1rem;
  }

  .playground-content {
    padding: 1rem;
  }

  .endpoints-grid {
    grid-template-columns: 1fr;
  }

  .url-section {
    flex-direction: column;
    align-items: stretch;
  }

  .header-item,
  .param-item,
  .form-field {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>