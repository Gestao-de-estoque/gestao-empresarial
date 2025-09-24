<template>
  <div id="app">
    <HamburgerMenu :show="shouldShowMenu" />
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import HamburgerMenu from '@/components/HamburgerMenu.vue'

const route = useRoute()

const shouldShowMenu = computed((): boolean => {
  // Mostrar o menu em todas as rotas exceto login
  const hideOnRoutes = ['/login', '/register', '/']
  return !hideOnRoutes.includes(route.path)
})
</script>

<style>
#app {
  width: 100%;
  height: 100vh;
}

body {
  background-color: #1a1a1a;
}
</style>
