<template>
  <div class="legal-container">
    <header class="page-header">
      <div class="header-content">
        <h1>
          <Cookie :size="28" />
          Política de Cookies
        </h1>
        <div class="last-updated">
          Última atualização: {{ lastUpdated }}
        </div>
      </div>
    </header>

    <div class="legal-content">
      <!-- Navegação -->
      <nav class="legal-nav">
        <h3>Índice</h3>
        <ul>
          <li><a href="#o-que-sao">1. O que são Cookies</a></li>
          <li><a href="#como-usamos">2. Como Usamos Cookies</a></li>
          <li><a href="#tipos-cookies">3. Tipos de Cookies</a></li>
          <li><a href="#cookies-terceiros">4. Cookies de Terceiros</a></li>
          <li><a href="#gerenciar-cookies">5. Gerenciar Cookies</a></li>
          <li><a href="#tecnologias-similares">6. Tecnologias Similares</a></li>
          <li><a href="#atualizacoes">7. Atualizações</a></li>
          <li><a href="#contato">8. Contato</a></li>
        </ul>
      </nav>

      <!-- Conteúdo Principal -->
      <main class="legal-main">
        <div class="intro-section">
          <div class="cookie-notice">
            <Cookie :size="24" />
            <div>
              <strong>Sobre os Cookies:</strong>
              Esta página explica como o GestãoZe System utiliza cookies e tecnologias similares
              para melhorar sua experiência e fornecer nossos serviços.
            </div>
          </div>
        </div>

        <section id="o-que-sao" class="legal-section">
          <h2>1. O que são Cookies</h2>
          <p>
            Cookies são pequenos arquivos de texto que são armazenados no seu dispositivo
            (computador, tablet ou celular) quando você visita um site. Eles permitem que
            o site reconheça seu dispositivo e lembre de certas informações sobre você.
          </p>

          <div class="cookie-explanation">
            <div class="explanation-item">
              <FileText :size="20" />
              <div>
                <strong>Arquivo de Texto</strong>
                <p>Pequenos arquivos contendo informações em formato de texto</p>
              </div>
            </div>

            <div class="explanation-item">
              <HardDrive :size="20" />
              <div>
                <strong>Armazenamento Local</strong>
                <p>Salvos no seu navegador ou dispositivo</p>
              </div>
            </div>

            <div class="explanation-item">
              <Clock :size="20" />
              <div>
                <strong>Temporários ou Permanentes</strong>
                <p>Podem expirar ao fechar o navegador ou ter data específica</p>
              </div>
            </div>

            <div class="explanation-item">
              <Shield :size="20" />
              <div>
                <strong>Seguros</strong>
                <p>Não executam código nem transmitem vírus</p>
              </div>
            </div>
          </div>
        </section>

        <section id="como-usamos" class="legal-section">
          <h2>2. Como Usamos Cookies</h2>
          <p>Utilizamos cookies para diversas finalidades que melhoram sua experiência:</p>

          <div class="usage-purposes">
            <div class="purpose-card">
              <UserCheck :size="24" />
              <div>
                <h3>Autenticação</h3>
                <p>Manter você logado durante sua sessão</p>
                <span class="purpose-type essential">Essencial</span>
              </div>
            </div>

            <div class="purpose-card">
              <Settings :size="24" />
              <div>
                <h3>Preferências</h3>
                <p>Lembrar suas configurações e escolhas</p>
                <span class="purpose-type functional">Funcional</span>
              </div>
            </div>

            <div class="purpose-card">
              <BarChart3 :size="24" />
              <div>
                <h3>Analytics</h3>
                <p>Entender como você usa nosso sistema</p>
                <span class="purpose-type analytical">Analítico</span>
              </div>
            </div>

            <div class="purpose-card">
              <Zap :size="24" />
              <div>
                <h3>Performance</h3>
                <p>Otimizar carregamento e funcionalidades</p>
                <span class="purpose-type performance">Performance</span>
              </div>
            </div>

            <div class="purpose-card">
              <Shield :size="24" />
              <div>
                <h3>Segurança</h3>
                <p>Detectar atividades suspeitas e fraudes</p>
                <span class="purpose-type essential">Essencial</span>
              </div>
            </div>

            <div class="purpose-card">
              <Target :size="24" />
              <div>
                <h3>Personalização</h3>
                <p>Adaptar conteúdo às suas necessidades</p>
                <span class="purpose-type marketing">Personalização</span>
              </div>
            </div>
          </div>
        </section>

        <section id="tipos-cookies" class="legal-section">
          <h2>3. Tipos de Cookies que Utilizamos</h2>

          <div class="cookie-categories">
            <div class="category-section">
              <div class="category-header essential">
                <CheckCircle :size="20" />
                <h3>Cookies Essenciais</h3>
                <span class="status">Sempre Ativos</span>
              </div>
              <p>
                Necessários para o funcionamento básico do sistema. Não podem ser desativados
                pois são fundamentais para fornecer nossos serviços.
              </p>

              <div class="cookie-list">
                <div class="cookie-item">
                  <strong>auth_token</strong>
                  <div class="cookie-details">
                    <span>Propósito: Autenticação de usuário</span>
                    <span>Duração: Sessão</span>
                    <span>Tipo: HTTP Only</span>
                  </div>
                </div>

                <div class="cookie-item">
                  <strong>session_id</strong>
                  <div class="cookie-details">
                    <span>Propósito: Identificação da sessão</span>
                    <span>Duração: 24 horas</span>
                    <span>Tipo: Secure</span>
                  </div>
                </div>

                <div class="cookie-item">
                  <strong>csrf_token</strong>
                  <div class="cookie-details">
                    <span>Propósito: Proteção contra CSRF</span>
                    <span>Duração: Sessão</span>
                    <span>Tipo: Same Site</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="category-section">
              <div class="category-header functional">
                <Settings :size="20" />
                <h3>Cookies Funcionais</h3>
                <div class="toggle-switch">
                  <label class="switch">
                    <input type="checkbox" v-model="functionalCookies">
                    <span class="slider"></span>
                  </label>
                </div>
              </div>
              <p>
                Permitem funcionalidades aprimoradas e personalização baseada em suas ações anteriores.
              </p>

              <div class="cookie-list">
                <div class="cookie-item">
                  <strong>user_preferences</strong>
                  <div class="cookie-details">
                    <span>Propósito: Configurações do usuário</span>
                    <span>Duração: 1 ano</span>
                    <span>Tipo: Local Storage</span>
                  </div>
                </div>

                <div class="cookie-item">
                  <strong>theme_setting</strong>
                  <div class="cookie-details">
                    <span>Propósito: Tema claro/escuro</span>
                    <span>Duração: 6 meses</span>
                    <span>Tipo: Local Storage</span>
                  </div>
                </div>

                <div class="cookie-item">
                  <strong>language_pref</strong>
                  <div class="cookie-details">
                    <span>Propósito: Idioma preferido</span>
                    <span>Duração: 1 ano</span>
                    <span>Tipo: Cookie</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="category-section">
              <div class="category-header analytical">
                <BarChart3 :size="20" />
                <h3>Cookies Analíticos</h3>
                <div class="toggle-switch">
                  <label class="switch">
                    <input type="checkbox" v-model="analyticalCookies">
                    <span class="slider"></span>
                  </label>
                </div>
              </div>
              <p>
                Coletam informações sobre como você usa nosso sistema para nos ajudar a melhorar.
              </p>

              <div class="cookie-list">
                <div class="cookie-item">
                  <strong>_ga</strong>
                  <div class="cookie-details">
                    <span>Propósito: Google Analytics - Identificação única</span>
                    <span>Duração: 2 anos</span>
                    <span>Tipo: Terceiro</span>
                  </div>
                </div>

                <div class="cookie-item">
                  <strong>usage_stats</strong>
                  <div class="cookie-details">
                    <span>Propósito: Estatísticas de uso interno</span>
                    <span>Duração: 30 dias</span>
                    <span>Tipo: Próprio</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="category-section">
              <div class="category-header performance">
                <Zap :size="20" />
                <h3>Cookies de Performance</h3>
                <div class="toggle-switch">
                  <label class="switch">
                    <input type="checkbox" v-model="performanceCookies">
                    <span class="slider"></span>
                  </label>
                </div>
              </div>
              <p>
                Ajudam a melhorar a velocidade e performance do sistema.
              </p>

              <div class="cookie-list">
                <div class="cookie-item">
                  <strong>cache_version</strong>
                  <div class="cookie-details">
                    <span>Propósito: Controle de cache de recursos</span>
                    <span>Duração: 7 dias</span>
                    <span>Tipo: Próprio</span>
                  </div>
                </div>

                <div class="cookie-item">
                  <strong>load_balancer</strong>
                  <div class="cookie-details">
                    <span>Propósito: Distribuição de carga</span>
                    <span>Duração: Sessão</span>
                    <span>Tipo: Próprio</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="cookies-terceiros" class="legal-section">
          <h2>4. Cookies de Terceiros</h2>
          <p>
            Alguns cookies são definidos por serviços de terceiros que usamos para melhorar nossos serviços:
          </p>

          <div class="third-party-services">
            <div class="service-card">
              <div class="service-header">
                <BarChart3 :size="20" />
                <span>Google Analytics</span>
              </div>
              <div class="service-details">
                <p><strong>Propósito:</strong> Análise de tráfego e comportamento dos usuários</p>
                <p><strong>Cookies:</strong> _ga, _gid, _gat</p>
                <p><strong>Duração:</strong> 2 anos</p>
                <p><strong>Privacidade:</strong> <a href="https://policies.google.com/privacy" target="_blank">Google Privacy Policy</a></p>
              </div>
            </div>

            <div class="service-card">
              <div class="service-header">
                <Cloud :size="20" />
                <span>Supabase</span>
              </div>
              <div class="service-details">
                <p><strong>Propósito:</strong> Autenticação e banco de dados</p>
                <p><strong>Cookies:</strong> sb-auth-token</p>
                <p><strong>Duração:</strong> Configurável</p>
                <p><strong>Privacidade:</strong> <a href="https://supabase.com/privacy" target="_blank">Supabase Privacy Policy</a></p>
              </div>
            </div>

            <div class="service-card">
              <div class="service-header">
                <MessageCircle :size="20" />
                <span>Sistema de Chat</span>
              </div>
              <div class="service-details">
                <p><strong>Propósito:</strong> Suporte ao cliente</p>
                <p><strong>Cookies:</strong> chat_session, chat_prefs</p>
                <p><strong>Duração:</strong> 30 dias</p>
                <p><strong>Privacidade:</strong> Dados processados internamente</p>
              </div>
            </div>
          </div>
        </section>

        <section id="gerenciar-cookies" class="legal-section">
          <h2>5. Como Gerenciar Cookies</h2>
          <p>
            Você tem controle total sobre os cookies. Aqui estão as opções disponíveis:
          </p>

          <div class="management-options">
            <div class="management-section">
              <h3><Settings :size="20" /> Configurações do Sistema</h3>
              <p>Use os controles acima para ativar/desativar categorias específicas de cookies.</p>
              <button class="cookie-settings-btn" @click="openCookieSettings">
                <Settings :size="16" />
                Gerenciar Preferências de Cookies
              </button>
            </div>

            <div class="management-section">
              <h3><Monitor :size="20" /> Configurações do Navegador</h3>
              <p>Configure cookies diretamente no seu navegador:</p>

              <div class="browser-instructions">
                <div class="browser-item">
                  <strong>Chrome:</strong>
                  <span>Configurações → Privacidade e segurança → Cookies</span>
                </div>
                <div class="browser-item">
                  <strong>Firefox:</strong>
                  <span>Opções → Privacidade e Segurança → Cookies</span>
                </div>
                <div class="browser-item">
                  <strong>Safari:</strong>
                  <span>Preferências → Privacidade → Cookies</span>
                </div>
                <div class="browser-item">
                  <strong>Edge:</strong>
                  <span>Configurações → Cookies e permissões do site</span>
                </div>
              </div>
            </div>
          </div>

          <div class="management-warning">
            <AlertTriangle :size="20" />
            <div>
              <strong>Importante:</strong> Desativar cookies essenciais pode impactar o funcionamento
              do sistema. Algumas funcionalidades podem não estar disponíveis.
            </div>
          </div>
        </section>

        <section id="tecnologias-similares" class="legal-section">
          <h2>6. Tecnologias Similares</h2>
          <p>Além de cookies, utilizamos outras tecnologias para melhorar nossos serviços:</p>

          <div class="similar-technologies">
            <div class="tech-item">
              <HardDrive :size="20" />
              <div>
                <strong>Local Storage</strong>
                <p>Armazena dados localmente no navegador para melhor performance</p>
              </div>
            </div>

            <div class="tech-item">
              <Database :size="20" />
              <div>
                <strong>Session Storage</strong>
                <p>Dados temporários que expiram quando você fecha o navegador</p>
              </div>
            </div>

            <div class="tech-item">
              <Wifi :size="20" />
              <div>
                <strong>Web Beacons</strong>
                <p>Pequenas imagens para análise de engajamento</p>
              </div>
            </div>

            <div class="tech-item">
              <Fingerprint :size="20" />
              <div>
                <strong>Device Fingerprinting</strong>
                <p>Identificação do dispositivo para segurança</p>
              </div>
            </div>
          </div>
        </section>

        <section id="atualizacoes" class="legal-section">
          <h2>7. Atualizações desta Política</h2>
          <p>
            Esta política de cookies pode ser atualizada periodicamente. Mudanças significativas
            serão comunicadas através de:
          </p>
          <ul>
            <li>Notificação no sistema</li>
            <li>E-mail para usuários registrados</li>
            <li>Banner de cookies atualizado</li>
            <li>Atualização da data nesta página</li>
          </ul>
        </section>

        <section id="contato" class="legal-section">
          <h2>8. Contato</h2>
          <p>
            Para questões sobre nossa política de cookies ou para exercer seus direitos:
          </p>

          <div class="contact-info">
            <div class="contact-item">
              <Mail :size="16" />
              <span>cookies@gestaozesystem.com</span>
            </div>
            <div class="contact-item">
              <Phone :size="16" />
              <span>(48) 0000-0000</span>
            </div>
            <div class="contact-item">
              <MessageCircle :size="16" />
              <span>Chat de suporte no sistema</span>
            </div>
          </div>
        </section>

        <div class="legal-footer">
          <div class="signature">
            <Calendar :size="16" />
            <span>Documento válido a partir de {{ lastUpdated }}</span>
          </div>
          <div class="version">
            <Cookie :size="16" />
            <span>Política de Cookies v1.0</span>
          </div>
        </div>
      </main>
    </div>

    <!-- Cookie Settings Modal -->
    <div v-if="showCookieModal" class="cookie-modal-overlay" @click="closeCookieSettings">
      <div class="cookie-modal" @click.stop>
        <div class="modal-header">
          <h3>Configurações de Cookies</h3>
          <button @click="closeCookieSettings" class="close-btn">
            <X :size="20" />
          </button>
        </div>

        <div class="modal-content">
          <div class="cookie-category">
            <div class="category-title">
              <CheckCircle :size="20" />
              <span>Cookies Essenciais</span>
              <span class="always-on">Sempre Ativo</span>
            </div>
            <p>Necessários para o funcionamento básico do sistema.</p>
          </div>

          <div class="cookie-category">
            <div class="category-title">
              <Settings :size="20" />
              <span>Cookies Funcionais</span>
              <label class="switch">
                <input type="checkbox" v-model="functionalCookies">
                <span class="slider"></span>
              </label>
            </div>
            <p>Melhoram a funcionalidade e personalização.</p>
          </div>

          <div class="cookie-category">
            <div class="category-title">
              <BarChart3 :size="20" />
              <span>Cookies Analíticos</span>
              <label class="switch">
                <input type="checkbox" v-model="analyticalCookies">
                <span class="slider"></span>
              </label>
            </div>
            <p>Ajudam a entender como você usa nosso sistema.</p>
          </div>

          <div class="cookie-category">
            <div class="category-title">
              <Zap :size="20" />
              <span>Cookies de Performance</span>
              <label class="switch">
                <input type="checkbox" v-model="performanceCookies">
                <span class="slider"></span>
              </label>
            </div>
            <p>Otimizam velocidade e performance.</p>
          </div>
        </div>

        <div class="modal-actions">
          <button @click="acceptSelected" class="accept-btn">
            Aceitar Selecionados
          </button>
          <button @click="acceptAll" class="accept-all-btn">
            Aceitar Todos
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import {
  Cookie, FileText, HardDrive, Clock, Shield, UserCheck, Settings,
  BarChart3, Zap, Target, CheckCircle, Cloud, MessageCircle, Monitor,
  AlertTriangle, Database, Wifi, Fingerprint, Mail, Phone, Calendar,
  X
} from 'lucide-vue-next'

const lastUpdated = '26 de setembro de 2025'

// Cookie preferences
const functionalCookies = ref(true)
const analyticalCookies = ref(false)
const performanceCookies = ref(true)

// Cookie settings modal
const showCookieModal = ref(false)

function openCookieSettings() {
  showCookieModal.value = true
}

function closeCookieSettings() {
  showCookieModal.value = false
}

function acceptSelected() {
  // Save cookie preferences
  localStorage.setItem('cookie-preferences', JSON.stringify({
    functional: functionalCookies.value,
    analytical: analyticalCookies.value,
    performance: performanceCookies.value,
    timestamp: new Date().toISOString()
  }))

  console.log('Cookie preferences saved:', {
    functional: functionalCookies.value,
    analytical: analyticalCookies.value,
    performance: performanceCookies.value
  })

  closeCookieSettings()
}

function acceptAll() {
  functionalCookies.value = true
  analyticalCookies.value = true
  performanceCookies.value = true
  acceptSelected()
}

// Load saved preferences on component mount
const savedPreferences = localStorage.getItem('cookie-preferences')
if (savedPreferences) {
  const prefs = JSON.parse(savedPreferences)
  functionalCookies.value = prefs.functional ?? true
  analyticalCookies.value = prefs.analytical ?? false
  performanceCookies.value = prefs.performance ?? true
}
</script>

<style scoped>
/* Estilos base importados */
@import '@/styles/legal.css';

.cookie-notice {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(251, 191, 36, 0.1);
  border: 1px solid rgba(251, 191, 36, 0.3);
  border-radius: 12px;
  color: var(--theme-text-primary);
}

.cookie-notice svg {
  color: #f59e0b;
  flex-shrink: 0;
  margin-top: 0.125rem;
}

.cookie-explanation {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.explanation-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.explanation-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.explanation-item p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.usage-purposes {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.purpose-card {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
  transition: all 0.3s ease;
}

.purpose-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.purpose-card svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

.purpose-card h3 {
  margin: 0 0 0.5rem;
  color: var(--theme-text-primary);
  font-size: 1.1rem;
}

.purpose-card p {
  margin: 0 0 1rem;
  color: var(--theme-text-secondary);
  font-size: 0.9rem;
}

.purpose-type {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.purpose-type.essential {
  background: rgba(34, 197, 94, 0.1);
  color: #16a34a;
}

.purpose-type.functional {
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
}

.purpose-type.analytical {
  background: rgba(168, 85, 247, 0.1);
  color: #7c3aed;
}

.purpose-type.performance {
  background: rgba(251, 191, 36, 0.1);
  color: #d97706;
}

.purpose-type.marketing {
  background: rgba(236, 72, 153, 0.1);
  color: #db2777;
}

.cookie-categories {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  margin: 2rem 0;
}

.category-section {
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
  overflow: hidden;
}

.category-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-surface);
  border-bottom: 1px solid var(--theme-border);
}

.category-header h3 {
  margin: 0;
  flex: 1;
  font-size: 1.2rem;
}

.category-header.essential {
  background: rgba(34, 197, 94, 0.1);
  color: #16a34a;
}

.category-header.functional {
  background: rgba(59, 130, 246, 0.1);
  color: #2563eb;
}

.category-header.analytical {
  background: rgba(168, 85, 247, 0.1);
  color: #7c3aed;
}

.category-header.performance {
  background: rgba(251, 191, 36, 0.1);
  color: #d97706;
}

.category-header svg {
  flex-shrink: 0;
}

.status {
  background: rgba(34, 197, 94, 0.2);
  color: #16a34a;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.toggle-switch {
  margin-left: auto;
}

.switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 24px;
}

.switch input {
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
  transition: 0.3s;
  border-radius: 24px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: 0.3s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: var(--theme-primary);
}

input:checked + .slider:before {
  transform: translateX(26px);
}

.category-section p {
  padding: 0 1.5rem;
  margin: 1rem 0;
  color: var(--theme-text-secondary);
}

.cookie-list {
  padding: 0 1.5rem 1.5rem;
}

.cookie-item {
  padding: 1rem;
  background: var(--theme-surface);
  border-radius: 8px;
  margin-bottom: 1rem;
  border-left: 4px solid var(--theme-primary);
}

.cookie-item strong {
  color: var(--theme-primary);
  font-family: monospace;
  font-size: 0.9rem;
}

.cookie-details {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin-top: 0.5rem;
}

.cookie-details span {
  font-size: 0.8rem;
  color: var(--theme-text-secondary);
}

.third-party-services {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.service-card {
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
  overflow: hidden;
}

.service-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.5rem;
  background: var(--theme-surface);
  border-bottom: 1px solid var(--theme-border);
  font-weight: 600;
  color: var(--theme-primary);
}

.service-details {
  padding: 1.5rem;
}

.service-details p {
  margin: 0.5rem 0;
  font-size: 0.9rem;
}

.service-details a {
  color: var(--theme-primary);
  text-decoration: none;
}

.service-details a:hover {
  text-decoration: underline;
}

.management-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  margin: 2rem 0;
}

.management-section {
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.management-section h3 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--theme-primary);
  margin-bottom: 1rem;
}

.cookie-settings-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--theme-primary);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 1rem;
}

.cookie-settings-btn:hover {
  background: var(--theme-primary-dark);
  transform: translateY(-1px);
}

.browser-instructions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-top: 1rem;
}

.browser-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding: 0.75rem;
  background: var(--theme-surface);
  border-radius: 6px;
}

.browser-item strong {
  color: var(--theme-text-primary);
}

.browser-item span {
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.management-warning {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  background: rgba(239, 68, 68, 0.05);
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 8px;
  margin: 1rem 0;
}

.management-warning svg {
  color: #dc2626;
  flex-shrink: 0;
  margin-top: 0.125rem;
}

.similar-technologies {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.tech-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.tech-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.tech-item p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin: 1.5rem 0;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--theme-text-secondary);
}

.contact-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

/* Cookie Modal */
.cookie-modal-overlay {
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
  padding: 1rem;
}

.cookie-modal {
  background: var(--theme-surface);
  border-radius: 12px;
  max-width: 500px;
  width: 100%;
  max-height: 80vh;
  overflow-y: auto;
  border: 1px solid var(--theme-border);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem;
  border-bottom: 1px solid var(--theme-border);
}

.modal-header h3 {
  margin: 0;
  color: var(--theme-text-primary);
}

.close-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  color: var(--theme-text-secondary);
  border-radius: 6px;
  transition: all 0.2s ease;
}

.close-btn:hover {
  background: var(--theme-background);
  color: var(--theme-text-primary);
}

.modal-content {
  padding: 1.5rem;
}

.cookie-category {
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--theme-border);
}

.cookie-category:last-child {
  margin-bottom: 0;
  padding-bottom: 0;
  border-bottom: none;
}

.category-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.category-title svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

.category-title span {
  flex: 1;
  font-weight: 600;
  color: var(--theme-text-primary);
}

.always-on {
  background: rgba(34, 197, 94, 0.1);
  color: #16a34a;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.cookie-category p {
  margin: 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.modal-actions {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  border-top: 1px solid var(--theme-border);
}

.accept-btn, .accept-all-btn {
  flex: 1;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.accept-btn {
  background: var(--theme-background);
  color: var(--theme-text-primary);
  border: 1px solid var(--theme-border);
}

.accept-btn:hover {
  background: var(--theme-surface);
}

.accept-all-btn {
  background: var(--theme-primary);
  color: white;
}

.accept-all-btn:hover {
  background: var(--theme-primary-dark);
}

/* Responsive */
@media (max-width: 1024px) {
  .management-options {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .cookie-explanation,
  .usage-purposes,
  .third-party-services,
  .similar-technologies {
    grid-template-columns: 1fr;
  }

  .modal-actions {
    flex-direction: column;
  }

  .cookie-modal {
    margin: 1rem;
    max-height: 90vh;
  }
}
</style>