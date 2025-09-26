<template>
  <div id="app">
    <HamburgerMenu :show="shouldShowMenu" />
    <main class="app-content">
      <router-view />
    </main>
    <AppFooter />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useThemeStore } from '@/stores/theme'
import HamburgerMenu from '@/components/HamburgerMenu.vue'
import AppFooter from '@/components/layout/AppFooter.vue'

const route = useRoute()
const themeStore = useThemeStore()

const shouldShowMenu = computed((): boolean => {
  // Mostrar o menu em todas as rotas exceto login
  const hideOnRoutes = ['/login', '/register', '/']
  return !hideOnRoutes.includes(route.path)
})

onMounted(() => {
  themeStore.initTheme()
})
</script>

<style>
@import './styles/themes.css';

/* CSS Variables são definidas dinamicamente pelo theme store */
:root {
  --theme-primary: #667eea;
  --theme-secondary: #764ba2;
  --theme-background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  --theme-background-solid: #ffffff;
  --theme-surface: #ffffff;
  --theme-text-primary: #1a202c;
  --theme-text-secondary: #64748b;
  --theme-text-muted: #94a3b8;
  --theme-border: #e2e8f0;
  --theme-shadow: rgba(0, 0, 0, 0.1);
  --theme-accent-success: #10b981;
  --theme-accent-warning: #f59e0b;
  --theme-accent-error: #ef4444;
  --theme-accent-info: #3b82f6;
}

#app {
  width: 100%;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--theme-background);
  transition: background 0.3s ease;
}

.app-content {
  flex: 1 1 auto;
  min-height: 0;
}

body {
  background: var(--theme-background-solid);
  color: var(--theme-text-primary);
  transition: background-color 0.3s ease, color 0.3s ease;
  margin: 0;
  padding: 0;
  font-family: 'Inter', system-ui, sans-serif;
}

/* Tema escuro */
body.theme-dark {
  background: #282a36;
}

/* Tema claro */
body.theme-light {
  background: #ffffff;
}

/* Transições globais para mudança de tema */
* {
  transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease;
}

/* CSS global para garantir visibilidade do menu hambúrguer */
.hamburger-menu {
  z-index: 10000 !important;
  position: fixed !important;
  top: 20px !important;
  left: 20px !important;
}

/* Garantir que headers das páginas não sobreponham o menu */
.inventory-header,
.ai-header,
.reports-header,
.suppliers-header,
.menu-header,
.profile-header,
.settings-header {
  z-index: 100 !important;
}
</style>
