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

const shouldShowMenu = computed(() => {
  return route.meta.requiresAuth
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
