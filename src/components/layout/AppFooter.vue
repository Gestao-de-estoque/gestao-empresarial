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

            <!-- Divider -->
            <div class="download-divider">
              <span>OU</span>
            </div>

            <!-- QR Code -->
            <div class="qr-section">
              <button @click="downloadViaQR" class="qr-code qr-clickable" title="Clique para expandir o QR Code">
                <img v-if="qrCodeDataUrl" :src="qrCodeDataUrl" alt="QR Code" class="qr-image-small" />
                <div v-else class="qr-pattern">
                  <div class="qr-dot" v-for="i in 25" :key="i"></div>
                </div>
              </button>
              <span class="qr-text">Clique para expandir e escanear</span>
            </div>
          </div>
        </div>

        <!-- Principal -->
        <div class="nav-section">
          <h4 class="section-title">
            <Home :size="20" />
            Principal
          </h4>
          <ul class="nav-links">
            <li>
              <router-link to="/dashboard" class="nav-link">
                <Home :size="16" />
                <span>Dashboard</span>
              </router-link>
            </li>
            <li>
              <router-link to="/inventory" class="nav-link">
                <Package :size="16" />
                <span>Estoque</span>
              </router-link>
            </li>
            <li>
              <router-link to="/ai" class="nav-link">
                <Zap :size="16" />
                <span>Análise IA</span>
              </router-link>
            </li>
            <li>
              <router-link to="/reports" class="nav-link">
                <BarChart3 :size="16" />
                <span>Relatórios</span>
              </router-link>
            </li>
            <li>
              <router-link to="/financial" class="nav-link">
                <BarChart3 :size="16" />
                <span>Financeiro</span>
              </router-link>
            </li>
            <li>
              <router-link to="/employees" class="nav-link">
                <Users :size="16" />
                <span>Funcionários</span>
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Gestão -->
        <div class="nav-section">
          <h4 class="section-title">
            <Navigation :size="20" />
            Gestão
          </h4>
          <ul class="nav-links">
            <li>
              <router-link to="/suppliers" class="nav-link">
                <Users :size="16" />
                <span>Fornecedores</span>
              </router-link>
            </li>
            <li>
              <router-link to="/menu" class="nav-link">
                <BookOpen :size="16" />
                <span>Menu</span>
              </router-link>
            </li>
            <li>
              <router-link to="/logs" class="nav-link">
                <FileText :size="16" />
                <span>Logs do Sistema</span>
              </router-link>
            </li>
            <li>
              <router-link to="/permissions" class="nav-link">
                <Shield :size="16" />
                <span>Permissões</span>
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Administração -->
        <div class="nav-section">
          <h4 class="section-title">
            <Shield :size="20" />
            Administração
          </h4>
          <ul class="nav-links">
            <li>
              <router-link to="/admin/users" class="nav-link">
                <Users :size="16" />
                <span>Usuários</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/audit" class="nav-link">
                <FileText :size="16" />
                <span>Auditoria</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/backup" class="nav-link">
                <Download :size="16" />
                <span>Backup</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/security" class="nav-link">
                <Shield :size="16" />
                <span>Segurança</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/notifications" class="nav-link">
                <MessageCircle :size="16" />
                <span>Notificações</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/api" class="nav-link">
                <Globe :size="16" />
                <span>API</span>
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Configurações -->
        <div class="nav-section">
          <h4 class="section-title">
            <Settings :size="20" />
            Configurações
          </h4>
          <ul class="nav-links">
            <li>
              <router-link to="/profile" class="nav-link">
                <User :size="16" />
                <span>Perfil</span>
              </router-link>
            </li>
            <li>
              <router-link to="/settings" class="nav-link">
                <Settings :size="16" />
                <span>Configurações</span>
              </router-link>
            </li>
            <li>
              <router-link to="/support" class="nav-link">
                <LifeBuoy :size="16" />
                <span>Suporte</span>
              </router-link>
            </li>
            <li>
              <router-link to="/doc" class="nav-link">
                <BookOpen :size="16" />
                <span>Documentação</span>
              </router-link>
            </li>
            <li>
              <router-link to="/about" class="nav-link">
                <MessageCircle :size="16" />
                <span>Sobre</span>
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Recursos & Contato -->
        <div class="contact-section">
          <h4 class="section-title">
            <MessageCircle :size="20" />
            Recursos & Contato
          </h4>

          <ul class="nav-links">
            <li>
              <a href="mailto:suporte@gestaozesystem.com" class="nav-link">
                <Mail :size="16" />
                <span>suporte@gestaozesystem.com</span>
              </a>
            </li>
            <li>
              <a href="tel:+554800000000" class="nav-link">
                <Phone :size="16" />
                <span>(48) 0000-0000</span>
              </a>
            </li>
            <li>
              <div class="nav-link inactive">
                <MapPin :size="16" />
                <span>Florianópolis - SC</span>
              </div>
            </li>
            <li>
              <div class="nav-link inactive">
                <Clock :size="16" />
                <span>Seg - Sex: 8h às 18h</span>
              </div>
            </li>
          </ul>

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

    <!-- QR Code Modal -->
    <Transition name="modal-fade">
      <div v-if="showQRModal" class="qr-modal-overlay" @click="closeQRModal">
        <div class="qr-modal-content" @click.stop>
          <button class="qr-modal-close" @click="closeQRModal" aria-label="Fechar">
            <X :size="24" />
          </button>

          <div class="qr-modal-header">
            <Smartphone :size="32" class="qr-modal-icon" />
            <h3>Escaneie para Baixar</h3>
            <p>Aponte a câmera do seu celular para o QR Code</p>
          </div>

          <div class="qr-modal-body">
            <div class="qr-code-container">
              <img v-if="qrCodeDataUrl" :src="qrCodeDataUrl" alt="QR Code para download" class="qr-image-large" />
              <div v-else class="qr-loading">
                <Package :size="48" class="qr-loading-icon" />
                <p>Gerando QR Code...</p>
              </div>
            </div>

            <div class="qr-info">
              <div class="qr-info-item">
                <Download :size="20" />
                <div>
                  <strong>Arquivo:</strong>
                  <span>{{ apkFileName }}</span>
                </div>
              </div>
              <div class="qr-info-item">
                <Package :size="20" />
                <div>
                  <strong>Versão:</strong>
                  <span>v{{ appVersion }}</span>
                </div>
              </div>
            </div>

            <button @click="downloadAPK" class="qr-download-button">
              <Download :size="20" />
              <span>Ou clique para baixar direto</span>
            </button>
          </div>

          <div class="qr-modal-footer">
            <p>📱 Compatível com Android 5.0 ou superior</p>
          </div>
        </div>
      </div>
    </Transition>
  </footer>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import {
  Smartphone, Package, Zap, Shield, BarChart3, Navigation, Home,
  Globe, LifeBuoy, BookOpen, FileText, Download, Users, Settings, User,
  MessageCircle, Mail, Phone, MapPin, Clock, Linkedin, Github, Instagram,
  Youtube, Heart, X
} from 'lucide-vue-next'
import QRCode from 'qrcode'

const appVersion = (import.meta as any).env?.VITE_APP_VERSION || '1.0.0'
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

// APK Download URL - GitHub Releases
const apkDownloadUrl = 'https://github.com/estevam5s/estevam5s/releases/download/v1.0.0/gestao_estoque.apk'
const apkFileName = 'gestao_estoque.apk'

// Estado do modal do QR Code
const showQRModal = ref(false)
const qrCodeDataUrl = ref('')

// Gerar QR Code ao montar o componente
onMounted(async () => {
  try {
    qrCodeDataUrl.value = await QRCode.toDataURL(apkDownloadUrl, {
      width: 300,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    })
  } catch (error) {
    console.error('Erro ao gerar QR Code:', error)
  }
})

// Função para download direto do APK com notificação
async function downloadAPK() {
  try {
    console.log('📱 Iniciando download do APK:', apkFileName)
    console.log('📂 URL:', apkDownloadUrl)

    // Mostrar notificação de sucesso
    showNotification('📥 Download iniciado!', 'O arquivo APK será baixado do GitHub...', 'success')

    // Criar elemento de link temporário para download
    const link = document.createElement('a')
    link.href = apkDownloadUrl
    link.download = apkFileName
    link.target = '_blank'
    link.rel = 'noopener noreferrer'
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
      'Abrindo página de download...',
      'warning'
    )

    // Fallback: abrir em nova aba
    setTimeout(() => {
      window.open(apkDownloadUrl, '_blank')
    }, 500)
  }
}

// Função para abrir modal do QR Code
function downloadViaQR() {
  showQRModal.value = true
  showNotification('📱 QR Code aberto!', 'Escaneie com seu celular para baixar', 'info')
}

// Função para fechar modal do QR Code
function closeQRModal() {
  showQRModal.value = false
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
  background: white;
  border: none;
  padding: 12px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.qr-clickable:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

.qr-clickable:active {
  transform: scale(0.98);
}

.qr-image-small {
  width: 84px;
  height: 84px;
  display: block;
  border-radius: 8px;
  object-fit: contain;
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

/* Download Divider */
.download-divider {
  position: relative;
  text-align: center;
  margin: 8px 0;
}

.download-divider::before,
.download-divider::after {
  content: '';
  position: absolute;
  top: 50%;
  width: calc(50% - 30px);
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.3), transparent);
}

.download-divider::before {
  left: 0;
}

.download-divider::after {
  right: 0;
}

.download-divider span {
  font-size: 11px;
  font-weight: 600;
  color: #94a3b8;
  background: rgba(255, 255, 255, 0.9);
  padding: 4px 12px;
  border-radius: 12px;
  display: inline-block;
  letter-spacing: 1px;
}

/* QR Code Modal */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: all 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-from .qr-modal-content,
.modal-fade-leave-to .qr-modal-content {
  transform: scale(0.9) translateY(-20px);
}

.qr-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100000;
  padding: 20px;
  animation: fadeIn 0.3s ease;
}

.qr-modal-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 24px;
  max-width: 500px;
  width: 100%;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  animation: modalSlideUp 0.4s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes modalSlideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.qr-modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  color: white;
  z-index: 10;
  backdrop-filter: blur(10px);
}

.qr-modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.qr-modal-header {
  text-align: center;
  padding: 32px 32px 24px;
  color: white;
}

.qr-modal-icon {
  margin: 0 auto 16px;
  display: block;
  animation: floatIcon 3s ease-in-out infinite;
}

@keyframes floatIcon {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.qr-modal-header h3 {
  font-size: 28px;
  font-weight: 700;
  margin: 0 0 8px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.qr-modal-header p {
  font-size: 14px;
  opacity: 0.9;
  margin: 0;
}

.qr-modal-body {
  padding: 0 32px 32px;
}

.qr-code-container {
  background: white;
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.qr-image-large {
  width: 300px;
  height: 300px;
  display: block;
  animation: zoomIn 0.4s ease;
}

@keyframes zoomIn {
  from {
    transform: scale(0.8);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

.qr-loading {
  text-align: center;
  color: #666;
}

.qr-loading-icon {
  margin: 0 auto 16px;
  animation: spin 2s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.qr-info {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
}

.qr-info-item {
  flex: 1;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  padding: 16px;
  display: flex;
  gap: 12px;
  align-items: center;
  color: white;
}

.qr-info-item > svg {
  flex-shrink: 0;
  opacity: 0.8;
}

.qr-info-item div {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.qr-info-item strong {
  font-size: 12px;
  opacity: 0.8;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.qr-info-item span {
  font-size: 14px;
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.qr-download-button {
  width: 100%;
  background: white;
  color: #667eea;
  border: none;
  padding: 16px 24px;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.qr-download-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
  background: #f8f9ff;
}

.qr-download-button:active {
  transform: translateY(0);
}

.qr-modal-footer {
  background: rgba(0, 0, 0, 0.2);
  padding: 16px 32px;
  text-align: center;
  color: white;
  font-size: 13px;
  opacity: 0.9;
}

.qr-modal-footer p {
  margin: 0;
}

/* Responsividade */
@media (max-width: 640px) {
  .qr-modal-content {
    margin: 20px;
  }

  .qr-modal-header {
    padding: 24px 20px 16px;
  }

  .qr-modal-header h3 {
    font-size: 24px;
  }

  .qr-modal-body {
    padding: 0 20px 20px;
  }

  .qr-code-container {
    padding: 16px;
    min-height: 250px;
  }

  .qr-image-large {
    width: 250px;
    height: 250px;
  }

  .qr-info {
    flex-direction: column;
    gap: 12px;
  }

  .qr-modal-footer {
    padding: 12px 20px;
    font-size: 12px;
  }
}
</style>
