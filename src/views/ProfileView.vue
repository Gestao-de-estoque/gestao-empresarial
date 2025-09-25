<template>
  <div class="profile-view">
    <!-- Header -->
    <header class="profile-header">
      <div class="header-content">
        <div class="header-info">
          <AvatarUpload
            :avatar-url="user?.avatar_url"
            :user-name="user?.name"
            :size="80"
            @upload-success="handleAvatarSuccess"
            @upload-error="handleAvatarError"
            @upload-start="isLoading = true"
          />
          <div class="user-info">
            <h1>{{ user?.name || 'Usuário' }}</h1>
            <p>{{ getUserRole() }}</p>
            <div class="last-activity">
              <Clock :size="14" />
              Última atividade: {{ profileStats.lastLogin ? formatDate(new Date(profileStats.lastLogin)) : 'Nunca' }}
            </div>
          </div>
        </div>
        <div class="header-actions">
          <button @click="resetChanges" class="btn-secondary" :disabled="!hasChanges">
            <RotateCcw :size="16" />
            Descartar Alterações
          </button>
          <button @click="saveProfile" class="btn-primary" :disabled="!hasChanges || isLoading">
            <Save :size="16" />
            <span v-if="isLoading">Salvando...</span>
            <span v-else>Salvar Alterações</span>
          </button>
        </div>
      </div>
    </header>

    <!-- Content -->
    <div class="profile-content">
      <div class="form-container">
        <!-- Informações Pessoais -->
        <section class="form-section">
          <div class="section-header">
            <h2>
              <UserCheck :size="20" />
              Informações Pessoais
            </h2>
            <div class="section-description">
              Atualize suas informações básicas do perfil
            </div>
          </div>

          <div class="form-grid">
            <div class="form-group">
              <label for="name">Nome Completo</label>
              <div class="input-wrapper">
                <User :size="16" />
                <input
                  id="name"
                  v-model="formData.name"
                  type="text"
                  placeholder="Digite seu nome completo"
                  @input="markAsChanged"
                />
              </div>
            </div>

            <div class="form-group">
              <label for="username">Nome de Usuário</label>
              <div class="input-wrapper">
                <AtSign :size="16" />
                <input
                  id="username"
                  v-model="formData.username"
                  type="text"
                  placeholder="Digite seu nome de usuário"
                  @input="markAsChanged"
                />
              </div>
            </div>

            <div class="form-group">
              <label for="email">Email</label>
              <div class="input-wrapper">
                <Mail :size="16" />
                <input
                  id="email"
                  v-model="formData.email"
                  type="email"
                  placeholder="Digite seu email"
                  @input="markAsChanged"
                />
              </div>
            </div>

            <div class="form-group">
              <label for="role">Função</label>
              <div class="input-wrapper">
                <Shield :size="16" />
                <select id="role" v-model="formData.role" @change="markAsChanged">
                  <option value="admin">Administrador</option>
                  <option value="manager">Gerente</option>
                  <option value="stock_controller">Controlador de Estoque</option>
                </select>
              </div>
            </div>
          </div>
        </section>

        <!-- Segurança -->
        <section class="form-section">
          <div class="section-header">
            <h2>
              <Lock :size="20" />
              Segurança
            </h2>
            <div class="section-description">
              Atualize sua senha e configurações de segurança
            </div>
          </div>

          <div class="form-grid">
            <div class="form-group">
              <label for="current-password">Senha Atual</label>
              <div class="input-wrapper">
                <Lock :size="16" />
                <input
                  id="current-password"
                  v-model="passwordData.currentPassword"
                  :type="showPasswords.current ? 'text' : 'password'"
                  placeholder="Digite sua senha atual"
                />
                <button
                  type="button"
                  @click="togglePasswordVisibility('current')"
                  class="toggle-password"
                >
                  <component :is="showPasswords.current ? EyeOff : Eye" :size="16" />
                </button>
              </div>
            </div>

            <div class="form-group">
              <label for="new-password">Nova Senha</label>
              <div class="input-wrapper">
                <Lock :size="16" />
                <input
                  id="new-password"
                  v-model="passwordData.newPassword"
                  :type="showPasswords.new ? 'text' : 'password'"
                  placeholder="Digite sua nova senha"
                />
                <button
                  type="button"
                  @click="togglePasswordVisibility('new')"
                  class="toggle-password"
                >
                  <component :is="showPasswords.new ? EyeOff : Eye" :size="16" />
                </button>
              </div>
              <div class="password-strength" v-if="passwordData.newPassword">
                <div class="strength-bar">
                  <div
                    class="strength-fill"
                    :class="passwordStrength.level"
                    :style="{ width: passwordStrength.percentage + '%' }"
                  ></div>
                </div>
                <span :class="passwordStrength.level">{{ passwordStrength.text }}</span>
              </div>
            </div>

            <div class="form-group">
              <label for="confirm-password">Confirmar Nova Senha</label>
              <div class="input-wrapper">
                <Lock :size="16" />
                <input
                  id="confirm-password"
                  v-model="passwordData.confirmPassword"
                  :type="showPasswords.confirm ? 'text' : 'password'"
                  placeholder="Confirme sua nova senha"
                />
                <button
                  type="button"
                  @click="togglePasswordVisibility('confirm')"
                  class="toggle-password"
                >
                  <component :is="showPasswords.confirm ? EyeOff : Eye" :size="16" />
                </button>
              </div>
              <div v-if="passwordData.confirmPassword && passwordData.newPassword !== passwordData.confirmPassword" class="error-message">
                As senhas não coincidem
              </div>
            </div>
          </div>

          <div class="password-actions">
            <button @click="updatePassword" class="btn-primary" :disabled="!canUpdatePassword || isLoading">
              <Shield :size="16" />
              Atualizar Senha
            </button>
          </div>
        </section>

        <!-- Preferências -->
        <section class="form-section">
          <div class="section-header">
            <h2>
              <Settings :size="20" />
              Preferências
            </h2>
            <div class="section-description">
              Configure suas preferências do sistema
            </div>
          </div>

          <div class="preferences-grid">
            <div class="preference-item">
              <div class="preference-info">
                <h3>Notificações por Email</h3>
                <p>Receba notificações importantes por email</p>
              </div>
              <label class="toggle-switch">
                <input
                  type="checkbox"
                  v-model="formData.preferences.emailNotifications"
                  @change="markAsChanged"
                />
                <span class="slider"></span>
              </label>
            </div>

            <div class="preference-item">
              <div class="preference-info">
                <h3>Notificações Push</h3>
                <p>Receba notificações push no navegador</p>
              </div>
              <label class="toggle-switch">
                <input
                  type="checkbox"
                  v-model="formData.preferences.pushNotifications"
                  @change="markAsChanged"
                />
                <span class="slider"></span>
              </label>
            </div>

            <div class="preference-item">
              <div class="preference-info">
                <h3>Modo Escuro</h3>
                <p>Use o tema escuro na interface</p>
              </div>
              <label class="toggle-switch">
                <input
                  type="checkbox"
                  v-model="formData.preferences.darkMode"
                  @change="markAsChanged"
                />
                <span class="slider"></span>
              </label>
            </div>

            <div class="preference-item">
              <div class="preference-info">
                <h3>Idioma</h3>
                <p>Selecione o idioma da interface</p>
              </div>
              <select v-model="formData.preferences.language" @change="markAsChanged">
                <option value="pt-BR">Português (Brasil)</option>
                <option value="en-US">English (United States)</option>
                <option value="es-ES">Español (España)</option>
              </select>
            </div>
          </div>
        </section>
      </div>

      <!-- Sidebar com informações adicionais -->
      <aside class="profile-sidebar">
        <div class="sidebar-section">
          <h3>
            <Activity :size="18" />
            Estatísticas do Perfil
          </h3>
          <div class="stats-grid">
            <div class="stat-item">
              <div class="stat-value">{{ profileStats.loginCount }}</div>
              <div class="stat-label">Total de Logins</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ profileStats.daysActive }}</div>
              <div class="stat-label">Dias Ativo</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ profileStats.actionsCount }}</div>
              <div class="stat-label">Ações Realizadas</div>
            </div>
          </div>
        </div>

        <div class="sidebar-section">
          <h3>
            <Calendar :size="18" />
            Conta Criada
          </h3>
          <div class="account-info">
            <p>{{ user?.created_at ? formatDate(new Date(user.created_at)) : formatDate(new Date()) }}</p>
            <small>{{ user?.created_at ? formatTimeAgo(new Date(user.created_at)) : 'Recente' }}</small>
          </div>
        </div>

        <div class="sidebar-section">
          <h3>
            <Shield :size="18" />
            Segurança
          </h3>
          <div class="security-status">
            <div class="security-item" :class="{ active: securityStatus.strongPassword }">
              <CheckCircle v-if="securityStatus.strongPassword" :size="16" />
              <AlertCircle v-else :size="16" />
              Senha Forte
            </div>
            <div class="security-item" :class="{ active: securityStatus.emailVerified }">
              <CheckCircle v-if="securityStatus.emailVerified" :size="16" />
              <AlertCircle v-else :size="16" />
              Email Verificado
            </div>
            <div class="security-item" :class="{ active: securityStatus.recentActivity }">
              <CheckCircle v-if="securityStatus.recentActivity" :size="16" />
              <AlertCircle v-else :size="16" />
              Atividade Recente
            </div>
          </div>
        </div>
      </aside>
    </div>

    <!-- Loading Overlay -->
    <div v-if="isLoading || isLoadingProfile" class="loading-overlay">
      <div class="loading-spinner">
        <Loader2 :size="32" class="animate-spin" />
        <p>{{ isLoadingProfile ? 'Carregando perfil...' : 'Salvando alterações...' }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import {
  User, UserCheck, Mail, Lock, Shield, Settings, Activity, Calendar,
  Save, RotateCcw, Clock, AtSign, Eye, EyeOff,
  CheckCircle, AlertCircle, Loader2
} from 'lucide-vue-next'
import AvatarUpload from '@/components/AvatarUpload.vue'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'
import { profileService, type UserStats, type SecurityStatus } from '@/services/profileService'
import { format, formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const authStore = useAuthStore()
const themeStore = useThemeStore()
const { user } = authStore

// Estados reativos
const isLoading = ref(false)
const isLoadingProfile = ref(true)
const hasChanges = ref(false)
const saveMessage = ref('')

// Dados do formulário (inicializados vazios, serão carregados)
const formData = ref({
  name: '',
  username: '',
  email: '',
  role: 'admin',
  preferences: {
    emailNotifications: true,
    pushNotifications: true,
    darkMode: false,
    language: 'pt-BR'
  }
})

// Dados de senha
const passwordData = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// Controles de visibilidade de senha
const showPasswords = ref({
  current: false,
  new: false,
  confirm: false
})

// Estatísticas do perfil (dados reais do banco)
const profileStats = ref<UserStats>({
  loginCount: 0,
  daysActive: 0,
  actionsCount: 0,
  lastLogin: '',
  accountAge: 0
})

// Status de segurança (dados reais do banco)
const securityStatus = ref<SecurityStatus>({
  strongPassword: false,
  emailVerified: false,
  recentActivity: false
})

// Dados originais para comparação
const originalFormData = ref<any>({})

// Computed para força da senha
const passwordStrength = computed(() => {
  const password = passwordData.value.newPassword
  if (!password) return { level: '', percentage: 0, text: '' }

  let score = 0

  // Verificações de força
  if (password.length >= 8) score += 25
  if (/[a-z]/.test(password)) score += 25
  if (/[A-Z]/.test(password)) score += 25
  if (/[0-9]/.test(password)) score += 15
  if (/[^A-Za-z0-9]/.test(password)) score += 10

  if (score < 30) return { level: 'weak', percentage: score, text: 'Fraca' }
  if (score < 60) return { level: 'medium', percentage: score, text: 'Média' }
  if (score < 90) return { level: 'strong', percentage: score, text: 'Forte' }
  return { level: 'very-strong', percentage: 100, text: 'Muito Forte' }
})

// Computed para validação de atualização de senha
const canUpdatePassword = computed(() => {
  return passwordData.value.currentPassword &&
         passwordData.value.newPassword &&
         passwordData.value.confirmPassword &&
         passwordData.value.newPassword === passwordData.value.confirmPassword &&
         passwordData.value.newPassword.length >= 8
})

// Funções
function getUserRole() {
  const roles: Record<string, string> = {
    admin: 'Administrador',
    manager: 'Gerente',
    stock_controller: 'Controlador de Estoque'
  }
  return roles[user?.role || ''] || 'Usuário'
}

function markAsChanged() {
  hasChanges.value = true
}

function resetChanges() {
  formData.value = JSON.parse(JSON.stringify(originalFormData.value))
  hasChanges.value = false
}

async function saveProfile() {
  if (!hasChanges.value) return

  isLoading.value = true
  try {
    await profileService.updateUserProfile(formData.value)

    // Atualizar dados originais
    originalFormData.value = JSON.parse(JSON.stringify(formData.value))
    hasChanges.value = false

    // Aplicar tema se mudou
    if (formData.value.preferences.darkMode !== themeStore.isDarkMode) {
      themeStore.setTheme(formData.value.preferences.darkMode ? 'dark' : 'light')
    }

    saveMessage.value = 'Perfil atualizado com sucesso!'
    setTimeout(() => saveMessage.value = '', 3000)
  } catch (error: any) {
    console.error('Erro ao salvar perfil:', error)
    saveMessage.value = `Erro: ${error.message}`
    setTimeout(() => saveMessage.value = '', 5000)
  } finally {
    isLoading.value = false
  }
}

async function updatePassword() {
  if (!canUpdatePassword.value) return

  isLoading.value = true
  try {
    await profileService.updatePassword(
      passwordData.value.currentPassword,
      passwordData.value.newPassword
    )

    // Limpar campos de senha
    passwordData.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    }

    saveMessage.value = 'Senha atualizada com sucesso!'
    setTimeout(() => saveMessage.value = '', 3000)
  } catch (error: any) {
    console.error('Erro ao atualizar senha:', error)
    saveMessage.value = `Erro: ${error.message}`
    setTimeout(() => saveMessage.value = '', 5000)
  } finally {
    isLoading.value = false
  }
}

function togglePasswordVisibility(field: 'current' | 'new' | 'confirm') {
  showPasswords.value[field] = !showPasswords.value[field]
}

async function handleAvatarSuccess(avatarUrl: string) {
  try {
    // Atualizar o usuário local imediatamente para feedback visual
    if (user) {
      user.avatar_url = avatarUrl
    }

    // Marcar como alterado para salvar depois se necessário
    markAsChanged()

    saveMessage.value = 'Avatar enviado com sucesso!'
    setTimeout(() => saveMessage.value = '', 3000)
  } catch (error: any) {
    console.error('Erro ao processar sucesso do avatar:', error)
  } finally {
    isLoading.value = false
  }
}

function handleAvatarError(errorMessage: string) {
  saveMessage.value = `Erro no upload: ${errorMessage}`
  setTimeout(() => saveMessage.value = '', 5000)
  isLoading.value = false
}

function formatDate(date: Date) {
  return format(date, 'dd/MM/yyyy')
}

function formatTimeAgo(date: Date) {
  return formatDistanceToNow(date, { addSuffix: true, locale: ptBR })
}

// Watcher para aplicar mudanças de tema em tempo real
watch(
  () => formData.value.preferences.darkMode,
  (newValue) => {
    if (newValue !== themeStore.isDarkMode) {
      themeStore.setTheme(newValue ? 'dark' : 'light')
    }
  }
)

// Função para carregar dados do perfil
async function loadProfile() {
  try {
    isLoadingProfile.value = true
    const profile = await profileService.loadUserProfile()

    // Preencher formulário com dados reais
    formData.value = {
      name: profile.name,
      username: profile.username,
      email: profile.email,
      role: profile.role,
      preferences: profile.preferences
    }

    // Salvar dados originais
    originalFormData.value = JSON.parse(JSON.stringify(formData.value))

    console.log('✅ Perfil carregado:', profile)
  } catch (error: any) {
    console.error('❌ Erro ao carregar perfil:', error)
    saveMessage.value = `Erro ao carregar perfil: ${error.message}`
  } finally {
    isLoadingProfile.value = false
  }
}

// Função para carregar estatísticas reais
async function loadUserStats() {
  try {
    const stats = await profileService.getUserStats()
    profileStats.value = stats
    console.log('✅ Estatísticas carregadas:', stats)
  } catch (error: any) {
    console.error('❌ Erro ao carregar estatísticas:', error)
  }
}

// Função para carregar status de segurança real
async function loadSecurityStatus() {
  try {
    const status = await profileService.getSecurityStatus()
    securityStatus.value = status
    console.log('✅ Status de segurança carregado:', status)
  } catch (error: any) {
    console.error('❌ Erro ao carregar status de segurança:', error)
  }
}

onMounted(async () => {
  await loadProfile()
  await loadUserStats()
  await loadSecurityStatus()
})
</script>

<style scoped>
.profile-view {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
}

.profile-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  padding: 2rem 2rem 1.5rem;
  margin-bottom: 2rem;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 2rem;
}

.header-info {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}


.user-info h1 {
  margin: 0 0 0.5rem 0;
  font-size: 2rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.user-info p {
  margin: 0 0 0.5rem 0;
  color: #666;
  font-weight: 500;
}

.last-activity {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #888;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

.btn-primary, .btn-secondary {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  font-weight: 600;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
  text-decoration: none;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.9);
  color: #667eea;
  border: 1px solid rgba(102, 126, 234, 0.3);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(102, 126, 234, 0.1);
  transform: translateY(-2px);
}

.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.profile-content {
  max-width: 1200px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 2rem;
  padding: 0 2rem 2rem;
}

.form-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.form-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
}

.section-header {
  margin-bottom: 2rem;
}

.section-header h2 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: #333;
}

.section-description {
  color: #666;
  font-size: 0.875rem;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 600;
  color: #333;
  font-size: 0.875rem;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper svg {
  position: absolute;
  left: 1rem;
  color: #667eea;
  z-index: 2;
}

.input-wrapper input,
.input-wrapper select {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  border: 2px solid rgba(102, 126, 234, 0.2);
  border-radius: 12px;
  font-size: 1rem;
  background: white;
  transition: all 0.3s ease;
}

.input-wrapper input:focus,
.input-wrapper select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.toggle-password {
  position: absolute;
  right: 1rem;
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  padding: 0.25rem;
  z-index: 2;
}

.toggle-password:hover {
  color: #667eea;
}

.password-strength {
  margin-top: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.strength-bar {
  flex: 1;
  height: 4px;
  background: #e2e8f0;
  border-radius: 2px;
  overflow: hidden;
}

.strength-fill {
  height: 100%;
  transition: all 0.3s ease;
}

.strength-fill.weak { background: #ef4444; }
.strength-fill.medium { background: #f59e0b; }
.strength-fill.strong { background: #10b981; }
.strength-fill.very-strong { background: #059669; }

.password-strength span {
  font-size: 0.75rem;
  font-weight: 600;
}

.password-strength span.weak { color: #ef4444; }
.password-strength span.medium { color: #f59e0b; }
.password-strength span.strong { color: #10b981; }
.password-strength span.very-strong { color: #059669; }

.error-message {
  color: #ef4444;
  font-size: 0.75rem;
  margin-top: 0.25rem;
}

.password-actions {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid rgba(102, 126, 234, 0.1);
}

.preferences-grid {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.preference-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: rgba(102, 126, 234, 0.05);
  border-radius: 12px;
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.preference-info h3 {
  margin: 0 0 0.25rem 0;
  font-size: 1rem;
  font-weight: 600;
  color: #333;
}

.preference-info p {
  margin: 0;
  font-size: 0.875rem;
  color: #666;
}

.preference-item select {
  padding: 0.5rem 1rem;
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 8px;
  background: white;
  min-width: 150px;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 60px;
  height: 34px;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: 0.4s;
  border-radius: 34px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  transition: 0.4s;
  border-radius: 50%;
}

input:checked + .slider {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

input:checked + .slider:before {
  transform: translateX(26px);
}

.profile-sidebar {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.sidebar-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
}

.sidebar-section h3 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0 0 1rem 0;
  font-size: 1.125rem;
  font-weight: 700;
  color: #333;
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}

.stat-item {
  text-align: center;
  padding: 1rem;
  background: rgba(102, 126, 234, 0.05);
  border-radius: 12px;
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #667eea;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.75rem;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.account-info {
  text-align: center;
}

.account-info p {
  margin: 0 0 0.5rem 0;
  font-weight: 600;
  color: #333;
}

.account-info small {
  color: #666;
  font-size: 0.875rem;
}

.security-status {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.security-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #666;
}

.security-item.active {
  color: #10b981;
}

.security-item svg {
  flex-shrink: 0;
}

.loading-overlay {
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
  backdrop-filter: blur(5px);
}

.loading-spinner {
  background: white;
  padding: 2rem;
  border-radius: 20px;
  text-align: center;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
}

.loading-spinner p {
  margin: 1rem 0 0 0;
  color: #666;
  font-weight: 600;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Responsividade */
@media (max-width: 768px) {
  .profile-content {
    grid-template-columns: 1fr;
    padding: 0 1rem 2rem;
  }

  .profile-header {
    padding: 1.5rem 1rem 1rem;
  }

  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 1.5rem;
  }

  .header-info {
    justify-content: center;
    text-align: center;
  }

  .user-info h1 {
    font-size: 1.5rem;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }

  .form-section {
    padding: 1.5rem;
  }
}
</style>