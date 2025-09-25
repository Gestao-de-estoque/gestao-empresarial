<template>
  <header class="doc-header">
    <div class="header-main">
      <h1 class="doc-title" v-html="title"></h1>
      <div class="title-actions">
        <button @click="copyAnchor" class="anchor-btn" :title="`Copiar link para ${title}`">
          <Link :size="20" />
        </button>
        <button @click="toggleBookmark" class="bookmark-btn" :class="{ bookmarked: isBookmarked }" :title="isBookmarked ? 'Remover dos favoritos' : 'Adicionar aos favoritos'">
          <Bookmark :size="20" />
        </button>
      </div>
    </div>

    <p v-if="description" class="doc-description" v-html="description"></p>

    <div v-if="badges.length > 0" class="doc-badges">
      <span v-for="badge in badges" :key="badge.text" class="doc-badge" :class="badge.type">
        <component :is="badge.icon" :size="16" v-if="badge.icon" />
        {{ badge.text }}
      </span>
    </div>

    <div v-if="lastUpdated" class="doc-meta">
      <Clock :size="16" />
      <span>Última atualização: {{ formatDate(lastUpdated) }}</span>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Link, Bookmark, Clock } from 'lucide-vue-next'

interface Badge {
  text: string
  type?: 'info' | 'warning' | 'success' | 'error'
  icon?: any
}

interface Props {
  title: string
  description?: string
  badges?: Badge[]
  lastUpdated?: string
  id?: string
}

const props = withDefaults(defineProps<Props>(), {
  badges: () => [],
})

const isBookmarked = ref(false)

const sectionId = computed(() => {
  if (props.id) return props.id
  return props.title.toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
})

function copyAnchor() {
  const url = `${window.location.origin}${window.location.pathname}#${sectionId.value}`
  navigator.clipboard.writeText(url).then(() => {
    // Mostrar feedback visual
    const btn = document.querySelector('.anchor-btn')
    if (btn) {
      btn.classList.add('copied')
      setTimeout(() => btn.classList.remove('copied'), 2000)
    }
  })
}

function toggleBookmark() {
  isBookmarked.value = !isBookmarked.value
  // Implementar lógica de salvamento dos favoritos
  const bookmarks = JSON.parse(localStorage.getItem('docs-bookmarks') || '[]')

  if (isBookmarked.value) {
    bookmarks.push({
      id: sectionId.value,
      title: props.title,
      description: props.description,
      timestamp: Date.now()
    })
  } else {
    const index = bookmarks.findIndex((b: any) => b.id === sectionId.value)
    if (index > -1) bookmarks.splice(index, 1)
  }

  localStorage.setItem('docs-bookmarks', JSON.stringify(bookmarks))
}

function formatDate(dateString: string) {
  return new Intl.DateTimeFormat('pt-BR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(new Date(dateString))
}

// Verificar se já está nos favoritos
const bookmarks = JSON.parse(localStorage.getItem('docs-bookmarks') || '[]')
isBookmarked.value = bookmarks.some((b: any) => b.id === sectionId.value)
</script>

<style scoped>
.doc-header {
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid var(--docs-border, #e2e8f0);
}

.header-main {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
}

.doc-title {
  margin: 0;
  font-size: 2.5rem;
  font-weight: 800;
  color: var(--docs-text, #1a202c);
  line-height: 1.2;
  background: linear-gradient(135deg, var(--docs-primary, #667eea) 0%, var(--docs-secondary, #764ba2) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.title-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-shrink: 0;
}

.anchor-btn,
.bookmark-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 10px;
  background: var(--docs-button-bg, #ffffff);
  color: var(--docs-text-muted, #64748b);
  cursor: pointer;
  transition: all 0.3s ease;
}

.anchor-btn:hover,
.bookmark-btn:hover {
  border-color: var(--docs-primary, #667eea);
  color: var(--docs-primary, #667eea);
  transform: translateY(-2px);
}

.anchor-btn.copied {
  background: var(--docs-success, #10b981);
  color: white;
  border-color: var(--docs-success, #10b981);
}

.bookmark-btn.bookmarked {
  background: var(--docs-warning, #f59e0b);
  color: white;
  border-color: var(--docs-warning, #f59e0b);
}

.doc-description {
  margin: 0 0 1.5rem 0;
  font-size: 1.125rem;
  color: var(--docs-text-muted, #64748b);
  line-height: 1.6;
  max-width: 80%;
}

.doc-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.doc-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.doc-badge.info {
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
  border: 2px solid rgba(59, 130, 246, 0.2);
}

.doc-badge.success {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
  border: 2px solid rgba(16, 185, 129, 0.2);
}

.doc-badge.warning {
  background: rgba(245, 158, 11, 0.1);
  color: #f59e0b;
  border: 2px solid rgba(245, 158, 11, 0.2);
}

.doc-badge.error {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 2px solid rgba(239, 68, 68, 0.2);
}

.doc-meta {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--docs-text-muted, #64748b);
  font-size: 0.875rem;
  font-style: italic;
}

.doc-meta svg {
  color: var(--docs-text-muted, #64748b);
}

/* Responsividade */
@media (max-width: 768px) {
  .header-main {
    flex-direction: column;
    align-items: flex-start;
  }

  .doc-title {
    font-size: 2rem;
  }

  .doc-description {
    max-width: 100%;
  }

  .title-actions {
    align-self: flex-end;
  }
}
</style>