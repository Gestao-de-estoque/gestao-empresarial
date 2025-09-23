<template>
  <div v-if="show" class="hamburger-menu">
    <div class="hamburger-icon" @click="toggleMenu" :class="{ 'is-active': isMenuOpen }">
      <div class="line line-1"></div>
      <div class="line line-2"></div>
      <div class="line line-3"></div>
    </div>

    <transition name="fade">
      <div v-if="isMenuOpen" class="menu-overlay" @click="closeMenu">
        <nav class="menu">
          <router-link to="/dashboard" @click="closeMenu">Dashboard</router-link>
          <router-link to="/inventory" @click="closeMenu">Inventory</router-link>
          <router-link to="/ai" @click="closeMenu">AI Assistant</router-link>
          <router-link to="/profile" @click="closeMenu">Profile</router-link>
          <a href="#" @click.prevent="logoutAndCloseMenu">Logout</a>
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
.hamburger-menu {
  position: fixed;
  top: 30px;
  right: 30px;
  z-index: 1001;
}

.hamburger-icon {
  cursor: pointer;
  width: 40px;
  height: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.line {
  width: 28px;
  height: 2px;
  background-color: #fff;
  transition: all 0.3s ease;
}

.line-1 { margin-bottom: 8px; }
.line-3 { margin-top: 8px; }

.hamburger-icon.is-active .line-1 {
  transform: translateY(5px) rotate(45deg);
}

.hamburger-icon.is-active .line-2 {
  opacity: 0;
}

.hamburger-icon.is-active .line-3 {
  transform: translateY(-5px) rotate(-45deg);
}

.menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(26, 26, 26, 0.95);
  z-index: 1000;
  display: flex;
  justify-content: center;
  align-items: center;
}

.menu {
  display: flex;
  flex-direction: column;
  text-align: center;
}

.menu a {
  color: #fff;
  text-decoration: none;
  font-size: 2.5rem;
  font-weight: 300;
  margin: 15px 0;
  transition: color 0.3s, transform 0.3s;
  transform: translateY(20px);
  opacity: 0;
  animation: slide-up 0.5s forwards;
}

.menu a:hover {
  color: #e67e22;
}

.fade-enter-active .menu a {
  animation-delay: 0.3s;
}

@keyframes slide-up {
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.4s ease;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
