<template>
  <div class="permissions-view">
    <HamburgerMenu :show="true" />

    <div class="permissions-container">
      <div class="permissions-header">
        <div class="header-content">
          <h1 class="page-title">
            <Shield :size="28" />
            Controle de Permissões
          </h1>
          <p class="page-subtitle">Gerencie permissões e níveis de acesso por cargo</p>
        </div>
        <div class="header-actions">
          <button @click="loadData" :disabled="loading" class="btn-secondary">
            <RefreshCw :size="16" :class="{ 'animate-spin': loading }" />
            Recarregar
          </button>
        </div>
      </div>

      <!-- Estado de Loading -->
      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Carregando permissões...</p>
      </div>

      <!-- Estado de Erro -->
      <div v-if="error && !loading" class="error-state">
        <div class="error-icon">⚠️</div>
        <h3>Sistema de Permissões não Configurado</h3>
        <p>{{ error }}</p>

        <!-- Informações de diagnóstico -->
        <div class="diagnostic-info">
          <h4>📋 Diagnóstico:</h4>
          <p>O sistema de permissões precisa ser inicializado. Isso acontece quando:</p>
          <ul>
            <li>As tabelas <code>user_roles</code>, <code>permissions</code> ou <code>role_permissions</code> não existem</li>
            <li>O banco de dados não tem os dados iniciais necessários</li>
            <li>Há um problema de conectividade com o Supabase</li>
          </ul>

          <h4>🛠️ Soluções:</h4>
          <ol>
            <li><strong>Opção 1:</strong> Clique em "Inicializar Sistema" para tentar criar os dados automaticamente</li>
            <li><strong>Opção 2:</strong> Execute o script SQL no Supabase Dashboard (veja console para detalhes)</li>
          </ol>
        </div>

        <div class="error-actions">
          <button @click="loadData" class="btn-secondary">🔄 Tentar Novamente</button>
          <button @click="initializeData" class="btn-primary" :disabled="initializing">
            <RefreshCw v-if="initializing" :size="16" class="animate-spin" />
            {{ initializing ? 'Inicializando...' : '🚀 Inicializar Sistema' }}
          </button>
        </div>

        <!-- Script SQL para referência -->
        <details class="sql-script">
          <summary>📜 Script SQL Manual (caso necessário)</summary>
          <pre><code>-- Execute este script no Supabase SQL Editor se a inicialização automática falhar

CREATE TABLE IF NOT EXISTS user_roles (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS permissions (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL DEFAULT 'sistema',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id VARCHAR(50) REFERENCES user_roles(id) ON DELETE CASCADE,
    permission_id VARCHAR(50) REFERENCES permissions(id) ON DELETE CASCADE,
    granted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id)
);</code></pre>
        </details>
      </div>

      <!-- Matriz de Permissões -->
      <div v-if="!loading && !error" class="permissions-matrix">
        <div class="matrix-header">
          <div class="role-column"></div>
          <div v-for="permission in permissions" :key="permission.id" class="permission-header">
            <div class="permission-name">{{ permission.name }}</div>
            <div class="permission-description">{{ permission.description }}</div>
          </div>
        </div>

        <div v-for="role in roles" :key="role.id" class="matrix-row">
          <div class="role-info">
            <div class="role-name">{{ role.name }}</div>
            <div class="role-description">{{ role.description }}</div>
          </div>
          <div
            v-for="permission in permissions"
            :key="`${role.id}-${permission.id}`"
            class="permission-cell"
          >
            <input
              :id="`${role.id}-${permission.id}`"
              v-model="rolePermissions[role.id][permission.id]"
              type="checkbox"
              class="permission-checkbox"
              @change="updatePermission(role.id, permission.id)"
            />
            <label :for="`${role.id}-${permission.id}`" class="checkbox-label">
              <Check v-if="rolePermissions[role.id][permission.id]" :size="16" />
            </label>
          </div>
        </div>
      </div>

      <!-- Resumo por Cargo -->
      <div v-if="!loading && !error" class="roles-summary">
        <h2>Resumo de Permissões por Cargo</h2>
        <div class="summary-grid">
          <div v-for="role in roles" :key="role.id" class="role-summary-card">
            <h3>{{ role.name }}</h3>
            <div class="permissions-list">
              <div
                v-for="permission in getActivePermissions(role.id)"
                :key="permission.id"
                class="permission-badge"
              >
                {{ permission.name }}
              </div>
            </div>
            <div class="summary-stats">
              <span>{{ getActivePermissions(role.id).length }} de {{ permissions.length }} permissões</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Botão Salvar -->
      <div v-if="!loading && !error" class="actions">
        <button @click="savePermissions" :disabled="saving" class="btn-primary">
          <RefreshCw v-if="saving" :size="20" class="animate-spin" />
          <Save v-else :size="20" />
          {{ saving ? 'Salvando...' : 'Salvar Permissões' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import HamburgerMenu from '@/components/HamburgerMenu.vue'
import { Shield, Save, Check, RefreshCw } from 'lucide-vue-next'
import { permissionsService, type UserRole, type Permission, type RolePermissionMatrix } from '@/services/permissionsService'

const roles = ref<UserRole[]>([])
const permissions = ref<Permission[]>([])
const rolePermissions = reactive<RolePermissionMatrix>({})
const loading = ref(false)
const saving = ref(false)
const initializing = ref(false)
const error = ref('')

onMounted(async () => {
  await loadData()
})

async function loadData() {
  try {
    loading.value = true
    error.value = ''

    // Carregar dados do banco
    const [rolesData, permissionsData, matrixData] = await Promise.all([
      permissionsService.getRoles(),
      permissionsService.getPermissions(),
      permissionsService.getRolePermissions()
    ])

    roles.value = rolesData
    permissions.value = permissionsData

    // Inicializar matriz reativa
    Object.keys(rolePermissions).forEach(key => delete rolePermissions[key])
    rolesData.forEach(role => {
      rolePermissions[role.id] = {}
      permissionsData.forEach(permission => {
        rolePermissions[role.id][permission.id] = matrixData[role.id]?.[permission.id] || false
      })
    })

    console.log('Dados carregados:', { roles: rolesData.length, permissions: permissionsData.length })
  } catch (err) {
    console.error('Erro ao carregar dados:', err)
    error.value = 'Erro ao carregar dados do banco. Tentando inicializar dados padrão...'

    // Tentar inicializar dados padrão
    try {
      await permissionsService.initializeDefaultData()
      await loadData() // Recarregar após inicializar
    } catch (initError) {
      console.error('Erro ao inicializar dados padrão:', initError)
      error.value = 'Erro ao inicializar sistema de permissões'
    }
  } finally {
    loading.value = false
  }
}

async function updatePermission(roleId: string, permissionId: string) {
  try {
    const granted = rolePermissions[roleId][permissionId]
    await permissionsService.updateRolePermission(roleId, permissionId, granted)
    console.log(`Updated ${roleId} - ${permissionId}:`, granted)
  } catch (err) {
    console.error('Erro ao atualizar permissão:', err)
    // Reverter mudança em caso de erro
    rolePermissions[roleId][permissionId] = !rolePermissions[roleId][permissionId]
    alert('Erro ao atualizar permissão. Tente novamente.')
  }
}

function getActivePermissions(roleId: string) {
  return permissions.value.filter(permission =>
    rolePermissions[roleId]?.[permission.id]
  )
}

async function savePermissions() {
  try {
    saving.value = true
    await permissionsService.saveAllPermissions(rolePermissions)
    alert('Permissões salvas com sucesso!')
    console.log('Permissões salvas:', rolePermissions)
  } catch (err) {
    console.error('Erro ao salvar permissões:', err)
    alert('Erro ao salvar permissões. Tente novamente.')
  } finally {
    saving.value = false
  }
}

async function initializeData() {
  try {
    initializing.value = true
    error.value = ''

    console.log('🚀 Iniciando processo de inicialização...')
    console.log('📋 Verificando estado das tabelas...')

    const success = await permissionsService.initializeDefaultData()

    if (success) {
      console.log('✅ Inicialização concluída com sucesso!')
      alert(`✅ Sistema de permissões inicializado com sucesso!

🎯 O que foi criado:
• 4 Cargos (Admin, Gerente, Controlador, Usuário)
• 12 Permissões organizadas em categorias
• Matriz completa de permissões por cargo

Você pode agora gerenciar as permissões do sistema.`)
      await loadData()
    } else {
      error.value = 'Falha na inicialização automática. Verifique o console para detalhes ou execute o script SQL manualmente.'
    }
  } catch (err) {
    console.error('💥 Erro crítico na inicialização:', err)

    const errorMessage = (err as any)?.message || 'Erro desconhecido'

    // Fornecer mensagens de erro mais específicas
    if (errorMessage.includes('Could not find')) {
      error.value = `❌ Tabelas não encontradas no banco de dados.

🔧 Para resolver:
1. Execute o script SQL fornecido abaixo no Supabase Dashboard
2. Ou peça ao administrador do sistema para criar as tabelas
3. Verifique se você tem permissões adequadas no Supabase

Erro técnico: ${errorMessage}`
    } else if (errorMessage.includes('permission')) {
      error.value = `🚫 Sem permissões suficientes para criar/modificar tabelas.

🔧 Para resolver:
1. Peça ao administrador do Supabase para dar permissões de escrita
2. Ou execute o script SQL manualmente como superuser
3. Verifique as políticas RLS (Row Level Security)

Erro técnico: ${errorMessage}`
    } else {
      error.value = `⚠️ Erro inesperado durante a inicialização.

Verifique:
• Conexão com internet
• Status do Supabase
• Console do navegador para mais detalhes

Erro técnico: ${errorMessage}`
    }

    console.log(`
🆘 GUIA DE SOLUÇÃO DE PROBLEMAS:

1. TABELAS NÃO EXISTEM:
   - Acesse: https://supabase.com/dashboard/project/YOUR_PROJECT/sql
   - Cole e execute o script SQL mostrado na interface

2. SEM PERMISSÕES:
   - Verifique as políticas RLS no Supabase
   - Certifique-se que está usando a chave correta (.env)

3. ERRO DE CONEXÃO:
   - Verifique VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY
   - Teste a conectividade com o Supabase

4. SUPORTE:
   - Verifique os logs completos no console
   - Entre em contato com o administrador do sistema

Detalhes técnicos completos:`, err)
  } finally {
    initializing.value = false
  }
}
</script>

<style scoped>
.permissions-view {
  min-height: 100vh;
  background: var(--theme-background);
  padding-left: 80px;
}

.permissions-container {
  padding: 2rem;
  max-width: 1600px;
  margin: 0 auto;
}

.permissions-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
}

.header-content h1 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--theme-text-primary);
  margin: 0 0 0.5rem 0;
  font-size: 2rem;
  font-weight: 700;
}

.header-content p {
  color: var(--theme-text-secondary);
  margin: 0;
  font-size: 1.1rem;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-secondary {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid var(--theme-border);
  background: var(--theme-surface);
  color: var(--theme-text-primary);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--theme-background);
  border-color: var(--theme-primary);
}

.btn-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.loading-state, .error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  text-align: center;
  background: var(--theme-surface);
  border-radius: 16px;
  border: 1px solid var(--theme-border);
  margin-bottom: 2rem;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--theme-border);
  border-top: 3px solid var(--theme-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

.error-state p {
  color: var(--theme-text-secondary);
  margin-bottom: 1rem;
  font-size: 1.1rem;
}

.error-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

.error-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.error-state h3 {
  color: var(--theme-text-primary);
  margin: 0 0 1rem 0;
  font-size: 1.5rem;
}

.diagnostic-info {
  text-align: left;
  background: var(--theme-background);
  padding: 1.5rem;
  border-radius: 12px;
  margin: 1.5rem 0;
  border: 1px solid var(--theme-border);
}

.diagnostic-info h4 {
  color: var(--theme-text-primary);
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
}

.diagnostic-info ul, .diagnostic-info ol {
  margin: 0.5rem 0;
  padding-left: 1.5rem;
}

.diagnostic-info li {
  margin: 0.5rem 0;
  color: var(--theme-text-secondary);
  line-height: 1.5;
}

.diagnostic-info code {
  background: var(--theme-surface);
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
  color: var(--theme-primary);
}

.sql-script {
  margin-top: 1.5rem;
  background: var(--theme-background);
  border: 1px solid var(--theme-border);
  border-radius: 8px;
  padding: 1rem;
}

.sql-script summary {
  cursor: pointer;
  font-weight: 600;
  color: var(--theme-text-primary);
  margin-bottom: 1rem;
  display: block;
}

.sql-script pre {
  background: #1e1e1e;
  color: #d4d4d4;
  padding: 1rem;
  border-radius: 6px;
  overflow-x: auto;
  margin: 1rem 0 0 0;
  font-size: 0.85rem;
  line-height: 1.4;
}

.sql-script code {
  background: transparent;
  color: inherit;
  padding: 0;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

.permissions-matrix {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 4px 20px var(--theme-shadow);
  border: 1px solid var(--theme-border);
  overflow-x: auto;
}

.matrix-header {
  display: grid;
  grid-template-columns: 200px repeat(12, 120px);
  gap: 0.5rem;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid var(--theme-border);
}

.role-column {
  /* Espaço vazio para alinhamento */
}

.permission-header {
  text-align: center;
  padding: 0.5rem;
}

.permission-name {
  font-weight: 600;
  font-size: 0.8rem;
  color: var(--theme-text-primary);
  margin-bottom: 0.25rem;
}

.permission-description {
  font-size: 0.7rem;
  color: var(--theme-text-secondary);
  line-height: 1.2;
}

.matrix-row {
  display: grid;
  grid-template-columns: 200px repeat(12, 120px);
  gap: 0.5rem;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--theme-border);
}

.matrix-row:last-child {
  border-bottom: none;
}

.role-info {
  padding: 0.5rem;
}

.role-name {
  font-weight: 600;
  color: var(--theme-text-primary);
  margin-bottom: 0.25rem;
}

.role-description {
  font-size: 0.8rem;
  color: var(--theme-text-secondary);
}

.permission-cell {
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
}

.permission-checkbox {
  display: none;
}

.checkbox-label {
  width: 24px;
  height: 24px;
  border: 2px solid var(--theme-border);
  border-radius: 6px;
  background: var(--theme-background);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.permission-checkbox:checked + .checkbox-label {
  background: var(--theme-primary);
  border-color: var(--theme-primary);
  color: white;
}

.checkbox-label:hover {
  border-color: var(--theme-primary);
}

.roles-summary {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 4px 20px var(--theme-shadow);
  border: 1px solid var(--theme-border);
}

.roles-summary h2 {
  margin: 0 0 1.5rem 0;
  color: var(--theme-text-primary);
  font-size: 1.25rem;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}

.role-summary-card {
  background: var(--theme-background);
  border-radius: 12px;
  padding: 1rem;
  border: 1px solid var(--theme-border);
}

.role-summary-card h3 {
  margin: 0 0 0.75rem 0;
  color: var(--theme-text-primary);
  font-size: 1rem;
}

.permissions-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.permission-badge {
  background: var(--theme-primary);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 500;
}

.summary-stats {
  font-size: 0.8rem;
  color: var(--theme-text-secondary);
  font-style: italic;
}

.actions {
  display: flex;
  justify-content: center;
}

.btn-primary {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 2rem;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: 2px solid;
  background: var(--theme-primary);
  color: white;
  border-color: var(--theme-primary);
}

.btn-primary:hover {
  background: var(--theme-primary-hover);
  border-color: var(--theme-primary-hover);
}

@media (max-width: 1200px) {
  .permissions-matrix {
    overflow-x: scroll;
  }

  .matrix-header,
  .matrix-row {
    min-width: 1400px;
  }
}

@media (max-width: 768px) {
  .permissions-view {
    padding-left: 0;
  }

  .permissions-container {
    padding: 1rem;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }
}
</style>
