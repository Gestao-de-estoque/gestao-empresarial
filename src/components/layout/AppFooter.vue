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
                    <svg viewBox="0 0 24 24">
                      <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.61 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.92 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
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
const apkDownloadUrl = '/gestao_estoque.apk'
const apkFileName = 'GestaoZe_v' + appVersion + '.apk'

// URLs das lojas (opcional, mantém para futuro)
const googlePlayUrl = (import.meta as any).env?.VITE_GOOGLE_PLAY_URL || apkDownloadUrl
const appStoreUrl = (import.meta as any).env?.VITE_APP_STORE_URL || apkDownloadUrl

// Função para download direto do APK
function downloadAPK() {
  try {
    // Criar elemento de link temporário para download
    const link = document.createElement('a')
    link.href = apkDownloadUrl
    link.download = apkFileName
    link.style.display = 'none'

    // Adicionar ao DOM, clicar e remover
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    console.log('📱 Download do APK iniciado:', apkFileName)
  } catch (error) {
    console.error('❌ Erro ao baixar APK:', error)
    // Fallback: abrir em nova aba
    window.open(apkDownloadUrl, '_blank')
  }
}

// Função para download via QR Code
function downloadViaQR() {
  downloadAPK()
}

function onBadgeError(e: Event) {
  const el = e.target as HTMLImageElement
  if (el) {
    // Hide the broken image
    el.style.display = 'none'
  }
}

// Nome e descrição do sistema — configuráveis via env
const siteName = (import.meta as any).env?.VITE_SITE_NAME || 'GestãoZe System'
const siteDescription = (import.meta as any).env?.VITE_APP_DESCRIPTION || 'Plataforma profissional para gestão de estoque, operações e auditoria em tempo real para restaurantes. Inclui logs completos, relatórios técnicos avançados, monitoramento de performance e integração segura com banco de dados.'
</script>

<style scoped src="@/styles/footer.css"></style>
