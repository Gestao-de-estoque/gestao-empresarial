<template>
  <footer class="app-footer">
    <!-- Decorative wave -->
    <div class="footer-wave">
      <svg viewBox="0 0 1200 120" preserveAspectRatio="none">
        <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
      </svg>
    </div>

    <div class="footer-content">
      <div class="footer-top">
        <!-- Brand Section -->
        <div class="brand-section">
          <div class="brand">
            <div class="logo-container">
              <img :src="logoSrc" alt="Logo do sistema" class="brand-logo" @error="onLogoError" />
              <div class="logo-shine"></div>
            </div>
            <div class="brand-text">
              <h3 class="brand-title">{{ siteName }}</h3>
              <p class="brand-description">{{ siteDescription }}</p>
            </div>
          </div>

          <!-- App Download Section -->
          <div class="downloads-section">
            <h4 class="section-title">
              <Smartphone :size="20" />
              Baixe o App
            </h4>
            <div class="app-preview">
              <div class="phone-mockup">
                <div class="phone-screen">
                  <div class="app-icon">
                    <Package :size="16" />
                  </div>
                  <div class="app-info">
                    <span class="app-name">GestãoZe</span>
                    <span class="app-version">v{{ appVersion }}</span>
                  </div>
                </div>
              </div>
              <div class="app-features">
                <div class="feature-item">
                  <Zap :size="14" />
                  <span>Gestão Rápida</span>
                </div>
                <div class="feature-item">
                  <Shield :size="14" />
                  <span>100% Seguro</span>
                </div>
                <div class="feature-item">
                  <BarChart3 :size="14" />
                  <span>Relatórios</span>
                </div>
              </div>
            </div>

            <div class="store-badges">
              <button @click="downloadAPK" class="badge-link google-play" aria-label="Baixar APK Android">
                <div class="badge-content">
                  <div class="badge-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                      <path d="M17.523 7L12 2.5 6.477 7H17.523zM6.477 17L12 21.5l5.523-4.5H6.477zM12 2C10.9 2 10 2.9 10 4v16c0 1.1.9 2 2 2s2-.9 2-2V4c0-1.1-.9-2-2-2z"/>
                      <circle cx="12" cy="12" r="1.5"/>
                    </svg>
                  </div>
                  <div class="badge-text">
                    <span class="badge-subtitle">Baixar APK</span>
                    <span class="badge-title">Android v{{ appVersion }}</span>
                  </div>
                </div>
              </button>

              <button @click="downloadAPK" class="badge-link app-store" aria-label="Baixar Aplicativo">
                <div class="badge-content">
                  <div class="badge-icon">
                    <Download :size="20" />
                  </div>
                  <div class="badge-text">
                    <span class="badge-subtitle">Download Direto</span>
                    <span class="badge-title">GestãoZe APK</span>
                  </div>
                </div>
              </button>
            </div>

            <!-- QR Code -->
            <div class="qr-section">
              <button @click="downloadViaQR" class="qr-code qr-clickable" title="Clique para baixar o APK">
                <div class="qr-pattern">
                  <div class="qr-dot" v-for="i in 25" :key="i"></div>
                </div>
              </button>
              <span class="qr-text">Clique ou escaneie para baixar</span>
            </div>
          </div>
        </div>

        <!-- Navigation Links -->
        <div class="nav-section">
          <h4 class="section-title">
            <Navigation :size="20" />
            Navegação
          </h4>
          <ul class="nav-links">
            <li>
              <router-link to="/dashboard" class="nav-link">
                <Home :size="16" />
                <span>Dashboard</span>
                <ExternalLink :size="12" />
              </router-link>
            </li>
            <li>
              <router-link to="/inventory" class="nav-link">
                <Package :size="16" />
                <span>Estoque</span>
                <ExternalLink :size="12" />
              </router-link>
            </li>
            <li>
              <router-link to="/reports" class="nav-link">
                <BarChart3 :size="16" />
                <span>Relatórios</span>
                <ExternalLink :size="12" />
              </router-link>
            </li>
            <li>
              <router-link to="/api" class="nav-link">
                <Globe :size="16" />
                <span>API Management</span>
                <ExternalLink :size="12" />
              </router-link>
            </li>
            <li>
              <router-link to="/permissions" class="nav-link">
                <Shield :size="16" />
                <span>Permissões</span>
                <ExternalLink :size="12" />
              </router-link>
            </li>
            <li>
              <router-link to="/support" class="nav-link">
                <LifeBuoy :size="16" />
                <span>Suporte</span>
                <ExternalLink :size="12" />
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Resources -->
        <div class="resources-section">
          <h4 class="section-title">
            <BookOpen :size="20" />
            Recursos
          </h4>
          <ul class="resource-links">
            <li>
              <a href="/doc" class="resource-link">
                <FileText :size="16" />
                <span>Documentação</span>
              </a>
            </li>
            <li>
              <a href="#" class="resource-link">
                <Video :size="16" />
                <span>Video Tutoriais</span>
              </a>
            </li>
            <li>
              <a href="#" class="resource-link">
                <Headphones :size="16" />
                <span>Treinamentos</span>
              </a>
            </li>
            <li>
              <a href="#" class="resource-link">
                <Download :size="16" />
                <span>Downloads</span>
              </a>
            </li>
          </ul>
        </div>

        <!-- Contact & Social -->
        <div class="contact-section">
          <h4 class="section-title">
            <MessageCircle :size="20" />
            Contato & Suporte
          </h4>
          <div class="contact-info">
            <div class="contact-item">
              <Mail :size="16" />
              <a href="mailto:suporte@gestaozesystem.com">suporte@gestaozesystem.com</a>
            </div>
            <div class="contact-item">
              <Phone :size="16" />
              <a href="tel:+554800000000">(48) 0000-0000</a>
            </div>
            <div class="contact-item">
              <MapPin :size="16" />
              <span>Florianópolis - SC, Brasil</span>
            </div>
            <div class="contact-item">
              <Clock :size="16" />
              <span>Seg - Sex: 8h às 18h</span>
            </div>
          </div>

          <div class="social-section">
            <h5>Siga-nos</h5>
            <div class="social-links">
              <a href="#" class="social-link linkedin" aria-label="LinkedIn">
                <Linkedin :size="20" />
              </a>
              <a href="#" class="social-link github" aria-label="GitHub">
                <Github :size="20" />
              </a>
              <a href="#" class="social-link instagram" aria-label="Instagram">
                <Instagram :size="20" />
              </a>
              <a href="#" class="social-link youtube" aria-label="YouTube">
                <Youtube :size="20" />
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer Bottom -->
      <div class="footer-bottom">
        <div class="footer-bottom-content">
          <div class="legal-links">
            <router-link to="/legal/terms" class="legal-link">Termos de Uso</router-link>
            <router-link to="/legal/privacy" class="legal-link">Política de Privacidade</router-link>
            <router-link to="/legal/lgpd" class="legal-link">LGPD</router-link>
            <router-link to="/legal/cookies" class="legal-link">Cookies</router-link>
          </div>

          <div class="footer-meta">
            <div class="version-info">
              <div class="version-badge">
                <Zap :size="12" />
                <span>v{{ appVersion }}</span>
              </div>
              <div class="status-indicator">
                <div class="status-dot online"></div>
                <span>Sistema Online</span>
              </div>
            </div>

            <div class="copyright">
              <span>© {{ year }} GestãoZe System. Todos os direitos reservados.</span>
              <span class="made-with">
                Feito com <Heart :size="12" class="heart" /> em Florianópolis
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  Smartphone, Package, Zap, Shield, BarChart3, Navigation, Home, ExternalLink,
  Globe, LifeBuoy, BookOpen, FileText, Video, Headphones, Download,
  MessageCircle, Mail, Phone, MapPin, Clock, Linkedin, Github, Instagram,
  Youtube, Heart
} from 'lucide-vue-next'

const appVersion = (import.meta as any).env?.VITE_APP_VERSION || '2.0.0'
const year = new Date().getFullYear()

// Ícone/Logo: coloque o arquivo em /public/images/site-icon.png
// Fallback para /restaurante.jpeg se não existir
const logoSrc = computed(() => '/images/site-icon.png')

function onLogoError(e: Event) {
  const el = e.target as HTMLImageElement
  if (el && el.src.indexOf('/restaurante.jpeg') === -1) {
    el.src = '/restaurante.jpeg'
  }
}

// APK Download URL - Arquivo local do aplicativo
const apkDownloadUrl = '/app/gestao_estoque.apk'
const apkFileName = 'GestaoZe_v' + appVersion + '.apk'

// URLs das lojas (opcional, mantém para futuro)

// Função para download direto do APK com notificação
async function downloadAPK() {
  try {
    console.log('📱 Iniciando download do APK:', apkFileName)
    console.log('📂 URL:', apkDownloadUrl)

    // Verificar se o arquivo existe antes de baixar
    const response = await fetch(apkDownloadUrl, { method: 'HEAD' })

    if (!response.ok) {
      throw new Error(`APK não encontrado (${response.status})`)
    }

    // Mostrar notificação de sucesso
    showNotification('📥 Download iniciado!', 'O arquivo APK será baixado em instantes...', 'success')

    // Criar elemento de link temporário para download
    const link = document.createElement('a')
    link.href = apkDownloadUrl
    link.download = apkFileName
    link.style.display = 'none'

    // Adicionar ao DOM, clicar e remover
    document.body.appendChild(link)
    link.click()

    // Aguardar um pouco antes de remover para garantir o download
    setTimeout(() => {
      document.body.removeChild(link)
    }, 1000)

    console.log('✅ Download do APK iniciado com sucesso')

  } catch (error) {
    console.error('❌ Erro ao baixar APK:', error)

    // Mostrar notificação de erro
    showNotification(
      '⚠️ Erro no download',
      'Tentando método alternativo...',
      'warning'
    )

    // Fallback: abrir em nova aba
    setTimeout(() => {
      window.open(apkDownloadUrl, '_blank')
    }, 500)
  }
}

// Função para download via QR Code
function downloadViaQR() {
  showNotification('📱 QR Code', 'Iniciando download do aplicativo...', 'info')
  downloadAPK()
}

// Função auxiliar para mostrar notificações
function showNotification(title: string, message: string, type: 'success' | 'error' | 'warning' | 'info' = 'info') {
  // Criar elemento de notificação
  const notification = document.createElement('div')
  notification.className = `app-notification ${type}`
  notification.innerHTML = `
    <div class="notification-content">
      <strong>${title}</strong>
      <p>${message}</p>
    </div>
  `

  // Adicionar estilos inline
  Object.assign(notification.style, {
    position: 'fixed',
    bottom: '20px',
    right: '20px',
    backgroundColor: type === 'success' ? '#10b981' :
                     type === 'error' ? '#ef4444' :
                     type === 'warning' ? '#f59e0b' : '#3b82f6',
    color: 'white',
    padding: '16px 24px',
    borderRadius: '12px',
    boxShadow: '0 10px 25px rgba(0, 0, 0, 0.2)',
    zIndex: '99999',
    maxWidth: '350px',
    animation: 'slideInRight 0.3s ease-out',
    fontSize: '14px',
    fontFamily: 'system-ui, -apple-system, sans-serif'
  })

  // Adicionar ao body
  document.body.appendChild(notification)

  // Remover após 4 segundos
  setTimeout(() => {
    notification.style.animation = 'slideOutRight 0.3s ease-out'
    setTimeout(() => {
      document.body.removeChild(notification)
    }, 300)
  }, 4000)
}


// Nome e descrição do sistema — configuráveis via env
const siteName = (import.meta as any).env?.VITE_SITE_NAME || 'GestãoZe System'
const siteDescription = (import.meta as any).env?.VITE_APP_DESCRIPTION || 'Plataforma profissional para gestão de estoque, operações e auditoria em tempo real para restaurantes. Inclui logs completos, relatórios técnicos avançados, monitoramento de performance e integração segura com banco de dados.'
</script>

<style scoped src="@/styles/footer.css"></style>

<style scoped>
/* Animações para notificações */
@keyframes slideInRight {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideOutRight {
  from {
    transform: translateX(0);
    opacity: 1;
  }
  to {
    transform: translateX(100%);
    opacity: 0;
  }
}

/* Melhorias nos botões de download */
.badge-link {
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.badge-link::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  transform: translate(-50%, -50%);
  transition: width 0.6s, height 0.6s;
}

.badge-link:hover::before {
  width: 300px;
  height: 300px;
}

.badge-link:active {
  transform: scale(0.95);
}

.qr-clickable {
  cursor: pointer;
  transition: all 0.3s ease;
}

.qr-clickable:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

.qr-clickable:active {
  transform: scale(0.98);
}

/* Indicador de download */
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.badge-link:active .badge-icon {
  animation: pulse 0.5s ease-in-out;
}
</style>
