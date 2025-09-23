<template>
  <div class="login-container">
    <!-- Background animado -->
    <div class="animated-background">
      <div class="floating-shapes">
        <div class="shape shape-1" :style="{ animationDelay: '0s' }"></div>
        <div class="shape shape-2" :style="{ animationDelay: '2s' }"></div>
        <div class="shape shape-3" :style="{ animationDelay: '4s' }"></div>
        <div class="shape shape-4" :style="{ animationDelay: '1s' }"></div>
        <div class="shape shape-5" :style="{ animationDelay: '3s' }"></div>
        <div class="shape shape-6" :style="{ animationDelay: '5s' }"></div>
      </div>

      <!-- Partículas flutuantes -->
      <div class="particles">
        <div v-for="i in 50" :key="i" class="particle" :style="getParticleStyle(i)"></div>
      </div>
    </div>

    <!-- Conteúdo principal -->
    <div class="main-content">
      <!-- Lado esquerdo - Informações -->
      <div class="info-panel" :class="{ 'slide-in-left': mounted }">
        <div class="brand-section">
          <div class="logo-container">
            <div class="logo-circle">
              <div class="logo-inner">
                <span class="logo-text">GZ</span>
              </div>
            </div>
            <div class="brand-ripple"></div>
          </div>

          <h1 class="brand-title">
            <span class="word" :style="{ animationDelay: '0.5s' }">Gestao</span><span class="word highlight" :style="{ animationDelay: '0.7s' }">Ze</span>
          </h1>

          <p class="brand-subtitle" :style="{ animationDelay: '0.9s' }">
            Sistema Inteligente de Gestão
          </p>
        </div>

        <div class="features-showcase" :style="{ animationDelay: '1.1s' }">
          <h3>Recursos Avançados</h3>
          <div class="feature-list">
            <div class="feature-item" v-for="(feature, index) in features" :key="feature.icon"
                 :style="{ animationDelay: `${1.3 + index * 0.1}s` }">
              <div class="feature-icon">{{ feature.icon }}</div>
              <div class="feature-text">
                <h4>{{ feature.title }}</h4>
                <p>{{ feature.description }}</p>
              </div>
            </div>
          </div>
        </div>

        <div class="stats-section" :style="{ animationDelay: '1.8s' }">
          <div class="stat-item" v-for="stat in stats" :key="stat.label">
            <div class="stat-number">{{ stat.number }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </div>

      <!-- Lado direito - Formulário de login -->
      <div class="login-panel" :class="{ 'slide-in-right': mounted }">
        <div class="login-card">
          <!-- Header do cartão -->
          <div class="card-header">
            <div class="welcome-badge">
              <span class="badge-icon">👋</span>
              <span class="badge-text">Bem-vindo de volta!</span>
            </div>
            <h2 class="login-title">Acesse sua conta</h2>
            <p class="login-subtitle">Entre para continuar gerenciando seu restaurante</p>
          </div>

          <!-- Formulário -->
          <form @submit.prevent="handleLogin" class="login-form">
            <!-- Campo de usuário -->
            <div class="form-group" :class="{ 'has-content': credentials.username, 'has-error': error }">
              <div class="input-container">
                <div class="input-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                  </svg>
                </div>
                <input
                  id="username"
                  v-model="credentials.username"
                  type="text"
                  required
                  :disabled="loading"
                  class="form-input"
                  @focus="focusedField = 'username'"
                  @blur="focusedField = ''"
                />
                <label for="username" class="form-label">E-mail ou usuário</label>
                <div class="input-border"></div>
              </div>
            </div>

            <!-- Campo de senha -->
            <div class="form-group" :class="{ 'has-content': credentials.password, 'has-error': error }">
              <div class="input-container">
                <div class="input-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <circle cx="12" cy="16" r="1"></circle>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                  </svg>
                </div>
                <input
                  id="password"
                  v-model="credentials.password"
                  :type="showPassword ? 'text' : 'password'"
                  required
                  :disabled="loading"
                  class="form-input"
                  @focus="focusedField = 'password'"
                  @blur="focusedField = ''"
                />
                <label for="password" class="form-label">Senha</label>
                <button
                  type="button"
                  @click="showPassword = !showPassword"
                  class="password-toggle"
                >
                  <svg v-if="showPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                    <line x1="1" y1="1" x2="23" y2="23"></line>
                  </svg>
                  <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                    <circle cx="12" cy="12" r="3"></circle>
                  </svg>
                </button>
                <div class="input-border"></div>
              </div>
            </div>

            <!-- Opções adicionais -->
            <div class="form-options">
              <label class="checkbox-container">
                <input type="checkbox" v-model="rememberMe">
                <span class="checkbox-checkmark"></span>
                <span class="checkbox-text">Lembrar de mim</span>
              </label>
              <button type="button" class="forgot-password">
                Esqueceu a senha?
              </button>
            </div>

            <!-- Mensagem de erro -->
            <transition name="error-slide">
              <div v-if="error" class="error-message">
                <div class="error-icon">⚠️</div>
                <div class="error-text">{{ error }}</div>
                <button @click="error = ''" class="error-close">×</button>
              </div>
            </transition>

            <!-- Botão de login -->
            <button
              type="submit"
              :disabled="loading || !credentials.username || !credentials.password"
              class="login-button"
              :class="{ 'loading': loading }"
            >
              <span v-if="!loading" class="button-content">
                <svg class="button-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
                  <polyline points="10,17 15,12 10,7"></polyline>
                  <line x1="15" y1="12" x2="3" y2="12"></line>
                </svg>
                <span>Entrar no sistema</span>
              </span>
              <span v-else class="loading-content">
                <div class="loading-spinner"></div>
                <span>Autenticando...</span>
              </span>
            </button>

            <!-- Separador -->
            <div class="divider">
              <span class="divider-text">ou</span>
            </div>

            <!-- Botão demo -->
            <button
              type="button"
              @click="fillDemo"
              class="demo-button"
              :disabled="loading"
            >
              <span class="demo-icon">🎯</span>
              <span>Usar credenciais de demonstração</span>
            </button>

            <!-- Modo escuro toggle -->
            <div class="theme-toggle">
              <button @click="toggleTheme" class="theme-button">
                <span v-if="isDarkMode">🌞</span>
                <span v-else>🌙</span>
                <span>{{ isDarkMode ? 'Modo claro' : 'Modo escuro' }}</span>
              </button>
            </div>
          </form>
        </div>

        <!-- Informações de sistema -->
        <div class="system-info">
          <div class="info-item">
            <div class="status-indicator online"></div>
            <span>Sistema online</span>
          </div>
          <div class="info-item">
            <span>🔒 Conexão segura</span>
          </div>
          <div class="info-item">
            <span>v1.0.0</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <transition name="fade">
      <div v-if="loading" class="loading-overlay">
        <div class="loading-content">
          <div class="loading-logo">
            <div class="loading-circle"></div>
            <span class="loading-text">GZ</span>
          </div>
          <p class="loading-message">Verificando credenciais...</p>
          <div class="loading-progress">
            <div class="progress-bar" :style="{ width: loadingProgress + '%' }"></div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { LoginCredentials } from '@/types/auth'

const router = useRouter()
const authStore = useAuthStore()

const mounted = ref(false)
const credentials = ref<LoginCredentials>({
  username: '',
  password: ''
})

const error = ref('')
const loading = ref(false)
const loadingProgress = ref(0)
const showPassword = ref(false)
const rememberMe = ref(false)
const focusedField = ref('')
const isDarkMode = ref(false)

const features = [
  {
    icon: '📊',
    title: 'Analytics Avançado',
    description: 'Insights em tempo real com IA'
  },
  {
    icon: '🤖',
    title: 'Assistente IA',
    description: 'Sugestões inteligentes de gestão'
  },
  {
    icon: '📱',
    title: 'Multi-plataforma',
    description: 'Web, mobile e tablet'
  },
  {
    icon: '🔒',
    title: 'Segurança Total',
    description: 'Criptografia de ponta'
  }
]

const stats = [
  { number: '99.9%', label: 'Uptime' },
  { number: '24/7', label: 'Suporte' },
  { number: '500+', label: 'Restaurantes' }
]

function getParticleStyle(_index: number) {
  const size = Math.random() * 4 + 2
  const left = Math.random() * 100
  const animationDuration = Math.random() * 20 + 10
  const animationDelay = Math.random() * 20

  return {
    width: `${size}px`,
    height: `${size}px`,
    left: `${left}%`,
    animationDuration: `${animationDuration}s`,
    animationDelay: `${animationDelay}s`
  }
}

async function handleLogin() {
  error.value = ''
  loading.value = true
  loadingProgress.value = 0

  // Simular progresso de loading
  const progressInterval = setInterval(() => {
    if (loadingProgress.value < 90) {
      loadingProgress.value += Math.random() * 10
    }
  }, 100)

  try {
    const result = await authStore.login(credentials.value)

    loadingProgress.value = 100

    setTimeout(() => {
      if (result.success) {
        router.push('/dashboard')
      } else {
        error.value = result.error || 'Credenciais inválidas'
        clearInterval(progressInterval)
        loading.value = false
        loadingProgress.value = 0
      }
    }, 500)

  } catch (err) {
    error.value = 'Erro de conexão. Tente novamente.'
    clearInterval(progressInterval)
    loading.value = false
    loadingProgress.value = 0
  }
}

function fillDemo() {
  credentials.value = {
    username: 'rebecaluize@gmail.com',
    password: 'Restpedacinhodoceu@2025'
  }

  // Animação de preenchimento
  setTimeout(() => {
    const usernameInput = document.getElementById('username') as HTMLInputElement
    const passwordInput = document.getElementById('password') as HTMLInputElement

    if (usernameInput) usernameInput.focus()
    setTimeout(() => {
      if (passwordInput) passwordInput.focus()
    }, 500)
  }, 100)
}

function toggleTheme() {
  isDarkMode.value = !isDarkMode.value
  document.documentElement.setAttribute('data-theme', isDarkMode.value ? 'dark' : 'light')
}

onMounted(() => {
  setTimeout(() => {
    mounted.value = true
  }, 100)
})
</script>

<style scoped>
/* Reset e variáveis */
:root {
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  --accent-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  --glass-bg: rgba(255, 255, 255, 0.1);
  --glass-border: rgba(255, 255, 255, 0.2);
  --shadow-soft: 0 8px 32px rgba(31, 38, 135, 0.37);
  --shadow-strong: 0 15px 35px rgba(31, 38, 135, 0.2);
  --text-primary: #2d3748;
  --text-secondary: #4a5568;
  --border-color: #e2e8f0;
  --bg-light: #f7fafc;
  --success-color: #48bb78;
  --error-color: #f56565;
  --warning-color: #ed8936;
}

[data-theme="dark"] {
  --text-primary: #f7fafc;
  --text-secondary: #e2e8f0;
  --border-color: #4a5568;
  --bg-light: #1a202c;
}

/* Container principal */
.login-container {
  min-height: 100vh;
  position: relative;
  overflow: hidden;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
}

/* Background animado */
.animated-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: var(--primary-gradient);
  overflow: hidden;
}

.floating-shapes {
  position: absolute;
  width: 100%;
  height: 100%;
}

.shape {
  position: absolute;
  border-radius: 50%;
  background: var(--glass-bg);
  backdrop-filter: blur(10px);
  animation: float 20s infinite ease-in-out;
}

.shape-1 {
  width: 80px;
  height: 80px;
  top: 10%;
  left: 10%;
  background: rgba(255, 255, 255, 0.1);
}

.shape-2 {
  width: 120px;
  height: 120px;
  top: 60%;
  left: 80%;
  background: rgba(255, 255, 255, 0.08);
}

.shape-3 {
  width: 60px;
  height: 60px;
  top: 30%;
  left: 70%;
  background: rgba(255, 255, 255, 0.12);
}

.shape-4 {
  width: 100px;
  height: 100px;
  top: 80%;
  left: 20%;
  background: rgba(255, 255, 255, 0.06);
}

.shape-5 {
  width: 140px;
  height: 140px;
  top: 20%;
  left: 50%;
  background: rgba(255, 255, 255, 0.04);
}

.shape-6 {
  width: 90px;
  height: 90px;
  top: 70%;
  left: 60%;
  background: rgba(255, 255, 255, 0.09);
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) rotate(0deg) scale(1);
  }
  33% {
    transform: translateY(-30px) rotate(120deg) scale(1.1);
  }
  66% {
    transform: translateY(30px) rotate(240deg) scale(0.9);
  }
}

/* Partículas */
.particles {
  position: absolute;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.particle {
  position: absolute;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 50%;
  animation: particleFloat infinite linear;
}

@keyframes particleFloat {
  0% {
    transform: translateY(100vh) rotate(0deg);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 1;
  }
  100% {
    transform: translateY(-10vh) rotate(360deg);
    opacity: 0;
  }
}

/* Conteúdo principal */
.main-content {
  position: relative;
  z-index: 1;
  display: flex;
  min-height: 100vh;
}

/* Painel de informações */
.info-panel {
  flex: 1;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  color: white;
  position: relative;
  opacity: 0;
  transform: translateX(-50px);
  animation: slideInLeft 0.8s forwards;
}

.info-panel.slide-in-left {
  animation: slideInLeft 0.8s forwards;
}

@keyframes slideInLeft {
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* Seção da marca */
.brand-section {
  text-align: center;
  margin-bottom: 60px;
}

.logo-container {
  position: relative;
  display: inline-block;
  margin-bottom: 30px;
}

.logo-circle {
  width: 120px;
  height: 120px;
  background: var(--glass-bg);
  backdrop-filter: blur(20px);
  border: 2px solid var(--glass-border);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  position: relative;
  animation: logoGlow 3s ease-in-out infinite;
}

.logo-inner {
  width: 80px;
  height: 80px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
}

.logo-text {
  font-size: 32px;
  font-weight: 800;
  background: var(--primary-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.brand-ripple {
  position: absolute;
  top: -10px;
  left: -10px;
  right: -10px;
  bottom: -10px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  animation: ripple 2s ease-out infinite;
}

@keyframes logoGlow {
  0%, 100% {
    box-shadow: 0 0 20px rgba(255, 255, 255, 0.3);
  }
  50% {
    box-shadow: 0 0 40px rgba(255, 255, 255, 0.5);
  }
}

@keyframes ripple {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  100% {
    transform: scale(1.3);
    opacity: 0;
  }
}

.brand-title {
  font-size: 48px;
  font-weight: 800;
  margin-bottom: 16px;
  display: flex;
  justify-content: center;
  gap: 8px;
}

.word {
  opacity: 0;
  animation: wordReveal 0.6s forwards;
}

.word.highlight {
  background: var(--secondary-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

@keyframes wordReveal {
  to {
    opacity: 1;
  }
}

.brand-subtitle {
  font-size: 20px;
  opacity: 0.9;
  font-weight: 300;
  letter-spacing: 1px;
  opacity: 0;
  animation: fadeInUp 0.6s forwards;
}

@keyframes fadeInUp {
  to {
    opacity: 0.9;
    transform: translateY(0);
  }
  from {
    opacity: 0;
    transform: translateY(20px);
  }
}

/* Showcase de recursos */
.features-showcase {
  margin-bottom: 40px;
  opacity: 0;
  animation: fadeInUp 0.8s forwards;
}

.features-showcase h3 {
  font-size: 24px;
  margin-bottom: 30px;
  text-align: center;
  font-weight: 600;
}

.feature-list {
  display: grid;
  gap: 20px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: var(--glass-bg);
  backdrop-filter: blur(10px);
  border: 1px solid var(--glass-border);
  border-radius: 16px;
  transition: all 0.3s ease;
  opacity: 0;
  animation: fadeInUp 0.6s forwards;
}

.feature-item:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-strong);
}

.feature-icon {
  font-size: 24px;
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
}

.feature-text h4 {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 4px;
}

.feature-text p {
  font-size: 14px;
  opacity: 0.8;
  line-height: 1.4;
}

/* Seção de estatísticas */
.stats-section {
  display: flex;
  justify-content: center;
  gap: 40px;
  opacity: 0;
  animation: fadeInUp 1s forwards;
}

.stat-item {
  text-align: center;
}

.stat-number {
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 8px;
  background: var(--accent-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-label {
  font-size: 14px;
  opacity: 0.8;
  text-transform: uppercase;
  letter-spacing: 1px;
}

/* Painel de login */
.login-panel {
  flex: 0 0 500px;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-left: 1px solid var(--glass-border);
  opacity: 0;
  transform: translateX(50px);
}

.login-panel.slide-in-right {
  animation: slideInRight 0.8s forwards;
}

@keyframes slideInRight {
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* Cartão de login */
.login-card {
  background: white;
  border-radius: 24px;
  padding: 40px;
  box-shadow: var(--shadow-soft);
  border: 1px solid var(--border-color);
  margin-bottom: 20px;
}

.card-header {
  text-align: center;
  margin-bottom: 40px;
}

.welcome-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: var(--bg-light);
  color: var(--text-secondary);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  margin-bottom: 20px;
  border: 1px solid var(--border-color);
}

.badge-icon {
  font-size: 16px;
}

.login-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 8px;
}

.login-subtitle {
  color: var(--text-secondary);
  font-size: 16px;
  line-height: 1.5;
}

/* Formulário */
.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  position: relative;
}

.input-container {
  position: relative;
}

.input-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 20px;
  color: var(--text-secondary);
  z-index: 2;
  transition: color 0.3s ease;
}

.form-input {
  width: 100%;
  height: 56px;
  padding: 16px 16px 16px 48px;
  border: 2px solid var(--border-color);
  border-radius: 12px;
  font-size: 16px;
  background: white;
  color: var(--text-primary);
  transition: all 0.3s ease;
  outline: none;
}

.form-input:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input:focus + .form-label,
.form-group.has-content .form-label {
  top: -8px;
  left: 12px;
  font-size: 12px;
  color: #667eea;
  background: white;
  padding: 0 4px;
}

.form-label {
  position: absolute;
  left: 48px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-secondary);
  font-size: 16px;
  pointer-events: none;
  transition: all 0.3s ease;
  background: transparent;
}

.password-toggle {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 20px;
  border: none;
  background: none;
  color: var(--text-secondary);
  cursor: pointer;
  transition: color 0.3s ease;
}

.password-toggle:hover {
  color: var(--text-primary);
}

.input-border {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--primary-gradient);
  transition: width 0.3s ease;
}

.form-input:focus ~ .input-border {
  width: 100%;
}

/* Opções do formulário */
.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 10px 0;
}

.checkbox-container {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 14px;
  color: var(--text-secondary);
}

.checkbox-container input[type="checkbox"] {
  display: none;
}

.checkbox-checkmark {
  width: 18px;
  height: 18px;
  border: 2px solid var(--border-color);
  border-radius: 4px;
  position: relative;
  transition: all 0.3s ease;
}

.checkbox-container input[type="checkbox"]:checked + .checkbox-checkmark {
  background: var(--primary-gradient);
  border-color: #667eea;
}

.checkbox-container input[type="checkbox"]:checked + .checkbox-checkmark::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 12px;
  font-weight: bold;
}

.forgot-password {
  background: none;
  border: none;
  color: #667eea;
  font-size: 14px;
  cursor: pointer;
  text-decoration: underline;
  transition: color 0.3s ease;
}

.forgot-password:hover {
  color: #5a67d8;
}

/* Mensagem de erro */
.error-message {
  display: flex;
  align-items: center;
  gap: 12px;
  background: linear-gradient(135deg, #fef5e7 0%, #fff2f2 100%);
  border: 1px solid #fed7d7;
  border-radius: 12px;
  padding: 16px;
  color: var(--error-color);
  animation: shake 0.5s ease-in-out;
}

.error-icon {
  font-size: 18px;
}

.error-text {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
}

.error-close {
  background: none;
  border: none;
  color: var(--error-color);
  font-size: 18px;
  cursor: pointer;
  padding: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

.error-slide-enter-active,
.error-slide-leave-active {
  transition: all 0.3s ease;
}

.error-slide-enter-from,
.error-slide-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* Botões */
.login-button {
  height: 56px;
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.login-button:before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.login-button:hover:before {
  left: 100%;
}

.login-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.button-icon {
  width: 20px;
  height: 20px;
}

.loading-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Separador */
.divider {
  position: relative;
  text-align: center;
  margin: 20px 0;
}

.divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1px;
  background: var(--border-color);
}

.divider-text {
  background: white;
  color: var(--text-secondary);
  padding: 0 16px;
  font-size: 14px;
  position: relative;
}

/* Botão demo */
.demo-button {
  height: 48px;
  background: var(--bg-light);
  color: var(--text-secondary);
  border: 2px solid var(--border-color);
  border-radius: 12px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.demo-button:hover:not(:disabled) {
  background: #667eea;
  color: white;
  border-color: #667eea;
  transform: translateY(-1px);
}

.demo-icon {
  font-size: 16px;
}

/* Toggle de tema */
.theme-toggle {
  margin-top: 20px;
}

.theme-button {
  background: var(--bg-light);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 8px 12px;
  color: var(--text-secondary);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.theme-button:hover {
  background: var(--border-color);
}

/* Informações do sistema */
.system-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 12px;
  font-size: 12px;
  color: var(--text-secondary);
}

.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--success-color);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

/* Loading overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(10px);
}

.loading-content {
  text-align: center;
  color: white;
  max-width: 300px;
}

.loading-logo {
  position: relative;
  display: inline-block;
  margin-bottom: 20px;
}

.loading-circle {
  width: 80px;
  height: 80px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.loading-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 24px;
  font-weight: 800;
}

.loading-message {
  font-size: 16px;
  margin-bottom: 20px;
  opacity: 0.9;
}

.loading-progress {
  width: 200px;
  height: 4px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 2px;
  overflow: hidden;
  margin: 0 auto;
}

.progress-bar {
  height: 100%;
  background: var(--accent-gradient);
  border-radius: 2px;
  transition: width 0.3s ease;
}

/* Fade transition */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Responsividade */
@media (max-width: 1024px) {
  .main-content {
    flex-direction: column;
  }

  .info-panel {
    flex: none;
    padding: 20px;
    min-height: 40vh;
  }

  .login-panel {
    flex: none;
    border-left: none;
    border-top: 1px solid var(--glass-border);
  }

  .brand-title {
    font-size: 36px;
  }

  .stats-section {
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .info-panel,
  .login-panel {
    padding: 20px;
  }

  .login-card {
    padding: 24px;
  }

  .brand-title {
    font-size: 28px;
  }

  .features-showcase {
    margin-bottom: 20px;
  }

  .feature-item {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }

  .stats-section {
    flex-direction: column;
    gap: 15px;
  }

  .form-options {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .system-info {
    flex-direction: column;
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .login-container {
    padding: 10px;
  }

  .login-card {
    padding: 20px;
    border-radius: 16px;
  }

  .login-title {
    font-size: 24px;
  }

  .brand-title {
    font-size: 24px;
  }

  .logo-circle {
    width: 80px;
    height: 80px;
  }

  .logo-inner {
    width: 60px;
    height: 60px;
  }

  .logo-text {
    font-size: 24px;
  }
}
</style>