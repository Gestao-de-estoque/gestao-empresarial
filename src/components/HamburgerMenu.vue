<template>
  <div v-if="show" class="hamburger-menu">
    <!-- Botão do hambúrguer -->
    <button
      class="hamburger-button"
      @click="toggleMenu"
      :class="{ 'is-active': isMenuOpen }"
      aria-label="Menu de navegação"
    >
      <div class="hamburger-box">
        <div class="hamburger-inner"></div>
      </div>
    </button>

    <!-- Overlay e menu lateral -->
    <transition name="slide">
      <div v-if="isMenuOpen" class="menu-overlay" @click="closeMenu">
        <nav class="sidebar-menu" @click.stop>
          <div class="menu-header">
            <div class="logo">
              <h2>📦 Gestão</h2>
              <p>Sistema de Estoque</p>
            </div>
            <button class="close-button" @click="closeMenu" aria-label="Fechar menu">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
            </button>
          </div>

          <div class="menu-content">
            <div class="menu-section">
              <h3>Principal</h3>
              <router-link to="/dashboard" @click="closeMenu" class="menu-item">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                  <path d="M3 9L12 2L21 9V20C21 20.5304 20.7893 21.0391 20.4142 21.4142C20.0391 21.7893 19.5304 22 19 22H5C4.46957 22 3.96086 21.7893 3.58579 21.4142C3.21071 21.0391 3 20.5304 3 20V9Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Dashboard
              </router-link>

              <router-link to="/inventory" @click="closeMenu" class="menu-item">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                  <path d="M21 16V8C20.9996 7.64928 20.9071 7.30481 20.7315 7.00116C20.556 6.69751 20.3037 6.44536 20 6.27L13 2.27C12.696 2.09446 12.3511 2.00205 12 2.00205C11.6489 2.00205 11.304 2.09446 11 2.27L4 6.27C3.69626 6.44536 3.44398 6.69751 3.26846 7.00116C3.09294 7.30481 3.00036 7.64928 3 8V16C3.00036 16.3507 3.09294 16.6952 3.26846 16.9988C3.44398 17.3025 3.69626 17.5546 4 17.73L11 21.73C11.304 21.9055 11.6489 21.9979 12 21.9979C12.3511 21.9979 12.696 21.9055 13 21.73L20 17.73C20.3037 17.5546 20.556 17.3025 20.7315 16.9988C20.9071 16.6952 20.9996 16.3507 21 16Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Estoque
              </router-link>

              <router-link to="/ai" @click="closeMenu" class="menu-item">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                  <path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Análise IA
              </router-link>
            </div>

            <div class="menu-section">
              <h3>Configurações</h3>
              <router-link to="/profile" @click="closeMenu" class="menu-item">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                  <path d="M20 21V19C20 17.9391 19.5786 16.9217 18.8284 16.1716C18.0783 15.4214 17.0609 15 16 15H8C6.93913 15 5.92172 15.4214 5.17157 16.1716C4.42143 16.9217 4 17.9391 4 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Perfil
              </router-link>
            </div>

            <div class="menu-section">
              <button @click="logoutAndCloseMenu" class="menu-item logout-item">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                  <path d="M9 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V5C3 4.46957 3.21071 3.96086 3.58579 3.58579C3.96086 3.21071 4.46957 3 5 3H9" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M16 17L21 12L16 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M21 12H9" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Sair
              </button>
            </div>
          </div>
        </nav>
      </div>
    </transition>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

export default defineComponent({
  name: 'HamburgerMenu',
  props: {
    show: {
      type: Boolean,
      required: true
    }
  },
  setup() {
    const isMenuOpen = ref(false)
    const authStore = useAuthStore()
    const router = useRouter()

    const toggleMenu = () => {
      isMenuOpen.value = !isMenuOpen.value
    }

    const closeMenu = () => {
      isMenuOpen.value = false
    }

    const logoutAndCloseMenu = async () => {
      await authStore.logout()
      closeMenu()
      router.push('/login')
    }

    watch(isMenuOpen, (isOpen) => {
      if (isOpen) {
        document.body.style.overflow = 'hidden'
      } else {
        document.body.style.overflow = ''
      }
    })

    return {
      isMenuOpen,
      toggleMenu,
      closeMenu,
      logoutAndCloseMenu
    }
  }
})
</script>

<style scoped>
/* Container principal do menu */
.hamburger-menu {
  position: fixed;
  top: 20px;
  left: 20px;
  z-index: 1001;
}

/* Botão do hambúrguer */
.hamburger-button {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  border-radius: 12px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.hamburger-button:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
}

.hamburger-button:active {
  transform: translateY(0);
}

.hamburger-box {
  width: 24px;
  height: 24px;
  position: relative;
}

.hamburger-inner {
  display: block;
  top: 50%;
  margin-top: -2px;
}

.hamburger-inner,
.hamburger-inner::before,
.hamburger-inner::after {
  width: 24px;
  height: 2px;
  background-color: #ffffff;
  border-radius: 4px;
  position: absolute;
  transition: transform 0.15s ease;
}

.hamburger-inner::before,
.hamburger-inner::after {
  content: '';
  display: block;
}

.hamburger-inner::before {
  top: -8px;
}

.hamburger-inner::after {
  bottom: -8px;
}

/* Animação do botão ativo */
.hamburger-button.is-active .hamburger-inner {
  transform: rotate(45deg);
}

.hamburger-button.is-active .hamburger-inner::before {
  top: 0;
  transform: rotate(90deg);
}

.hamburger-button.is-active .hamburger-inner::after {
  bottom: 0;
  transform: rotate(90deg);
  opacity: 0;
}

/* Overlay */
.menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
}

/* Menu lateral */
.sidebar-menu {
  width: 320px;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* Cabeçalho do menu */
.menu-header {
  padding: 32px 24px 24px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.logo h2 {
  font-size: 24px;
  font-weight: 700;
  color: white;
  margin: 0 0 4px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.logo p {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.8);
  margin: 0;
  font-weight: 400;
}

.close-button {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  border-radius: 8px;
  padding: 8px;
  cursor: pointer;
  color: white;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-button:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(90deg);
}

/* Conteúdo do menu */
.menu-content {
  flex: 1;
  padding: 24px 0;
  overflow-y: auto;
}

.menu-section {
  margin-bottom: 32px;
}

.menu-section h3 {
  font-size: 12px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.7);
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0 24px 16px;
}

/* Itens do menu */
.menu-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 24px;
  color: white;
  text-decoration: none;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.2s ease;
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  cursor: pointer;
  position: relative;
}

.menu-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(8px);
}

.menu-item.router-link-active {
  background: rgba(255, 255, 255, 0.15);
  border-right: 4px solid white;
}

.menu-item.router-link-active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  background: white;
}

.menu-item svg {
  flex-shrink: 0;
  opacity: 0.8;
}

.menu-item:hover svg {
  opacity: 1;
  transform: scale(1.1);
}

/* Item de logout */
.logout-item {
  color: rgba(255, 255, 255, 0.9);
  margin-top: 16px;
}

.logout-item:hover {
  background: rgba(220, 38, 38, 0.2);
  color: #fca5a5;
}

/* Transições */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.slide-enter-from {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

/* Responsividade */
@media (max-width: 768px) {
  .sidebar-menu {
    width: 280px;
  }

  .menu-header {
    padding: 24px 20px 20px;
  }

  .logo h2 {
    font-size: 20px;
  }

  .menu-item {
    padding: 14px 20px;
    font-size: 15px;
  }

  .menu-section h3 {
    margin: 0 20px 12px;
  }
}

@media (max-width: 480px) {
  .hamburger-menu {
    top: 16px;
    left: 16px;
  }

  .sidebar-menu {
    width: 100vw;
  }
}

/* Scroll personalizado */
.menu-content::-webkit-scrollbar {
  width: 6px;
}

.menu-content::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}

.menu-content::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 3px;
}

.menu-content::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.5);
}
</style>
