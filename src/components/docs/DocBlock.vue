<template>
  <div class="doc-block" :class="[variant, { collapsible: collapsible, collapsed: isCollapsed }]">
    <div class="block-header" @click="collapsible && toggleCollapsed()">
      <div class="header-left">
        <component :is="icon" :size="20" v-if="icon" class="block-icon" />
        <h3 class="block-title">{{ title }}</h3>
        <span v-if="badge" class="title-badge" :class="badge.type">{{ badge.text }}</span>
      </div>

      <div class="header-right">
        <slot name="actions" />
        <button v-if="collapsible" class="collapse-btn" :class="{ collapsed: isCollapsed }">
          <ChevronDown :size="20" />
        </button>
      </div>
    </div>

    <div class="block-content" v-show="!isCollapsed">
      <div v-if="description" class="block-description">{{ description }}</div>
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ChevronDown } from 'lucide-vue-next'

interface Badge {
  text: string
  type?: 'info' | 'warning' | 'success' | 'error' | 'new'
}

interface Props {
  title: string
  description?: string
  variant?: 'default' | 'info' | 'warning' | 'success' | 'error' | 'code'
  icon?: any
  badge?: Badge
  collapsible?: boolean
  defaultCollapsed?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
  collapsible: false,
  defaultCollapsed: false,
})

const isCollapsed = ref(props.defaultCollapsed)

function toggleCollapsed() {
  isCollapsed.value = !isCollapsed.value
}
</script>

<style scoped>
.doc-block {
  background: var(--docs-card-bg, #ffffff);
  border: 2px solid var(--docs-border, #e2e8f0);
  border-radius: 16px;
  margin: 1.5rem 0;
  overflow: hidden;
  transition: all 0.3s ease;
}

.doc-block:hover {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
}

.block-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem;
  background: var(--docs-block-header-bg, transparent);
  border-bottom: 1px solid var(--docs-border, #e2e8f0);
}

.doc-block.collapsible .block-header {
  cursor: pointer;
}

.doc-block.collapsible .block-header:hover {
  background: var(--docs-hover, #f1f5f9);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.block-icon {
  color: var(--docs-primary, #667eea);
  flex-shrink: 0;
}

.block-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--docs-text, #1a202c);
}

.title-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.title-badge.info {
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
}

.title-badge.success {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.title-badge.warning {
  background: rgba(245, 158, 11, 0.1);
  color: #f59e0b;
}

.title-badge.error {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.title-badge.new {
  background: rgba(168, 85, 247, 0.1);
  color: #a855f7;
}

.collapse-btn {
  background: none;
  border: none;
  padding: 0.5rem;
  border-radius: 8px;
  cursor: pointer;
  color: var(--docs-text-muted, #64748b);
  transition: all 0.2s ease;
  transform-origin: center;
}

.collapse-btn:hover {
  background: var(--docs-hover, #f1f5f9);
  color: var(--docs-text, #1a202c);
}

.collapse-btn.collapsed {
  transform: rotate(-90deg);
}

.block-content {
  padding: 1.5rem;
}

.block-description {
  margin-bottom: 1rem;
  color: var(--docs-text-muted, #64748b);
  line-height: 1.6;
  font-style: italic;
}

/* Variações */
.doc-block.info {
  border-color: rgba(59, 130, 246, 0.3);
  background: rgba(59, 130, 246, 0.02);
}

.doc-block.info .block-header {
  background: rgba(59, 130, 246, 0.05);
}

.doc-block.info .block-icon {
  color: #3b82f6;
}

.doc-block.success {
  border-color: rgba(16, 185, 129, 0.3);
  background: rgba(16, 185, 129, 0.02);
}

.doc-block.success .block-header {
  background: rgba(16, 185, 129, 0.05);
}

.doc-block.success .block-icon {
  color: #10b981;
}

.doc-block.warning {
  border-color: rgba(245, 158, 11, 0.3);
  background: rgba(245, 158, 11, 0.02);
}

.doc-block.warning .block-header {
  background: rgba(245, 158, 11, 0.05);
}

.doc-block.warning .block-icon {
  color: #f59e0b;
}

.doc-block.error {
  border-color: rgba(239, 68, 68, 0.3);
  background: rgba(239, 68, 68, 0.02);
}

.doc-block.error .block-header {
  background: rgba(239, 68, 68, 0.05);
}

.doc-block.error .block-icon {
  color: #ef4444;
}

.doc-block.code {
  border-color: rgba(102, 126, 234, 0.3);
  background: var(--docs-code-bg, #f8fafc);
}

.doc-block.code .block-header {
  background: rgba(102, 126, 234, 0.05);
}

.doc-block.code .block-icon {
  color: var(--docs-primary, #667eea);
}

/* Animações */
.block-content {
  transition: all 0.3s ease;
}

.doc-block.collapsed .block-content {
  max-height: 0;
  padding-top: 0;
  padding-bottom: 0;
  overflow: hidden;
}

/* Estilos globais para conteúdo */
.doc-block :deep(h4) {
  margin: 1.5rem 0 1rem 0;
  color: var(--docs-text, #1a202c);
  font-weight: 600;
}

.doc-block :deep(p) {
  margin: 1rem 0;
  line-height: 1.6;
  color: var(--docs-text, #1a202c);
}

.doc-block :deep(ul),
.doc-block :deep(ol) {
  margin: 1rem 0;
  padding-left: 2rem;
}

.doc-block :deep(li) {
  margin: 0.5rem 0;
  line-height: 1.6;
  color: var(--docs-text, #1a202c);
}

.doc-block :deep(code) {
  background: var(--docs-code-bg, #f1f5f9);
  color: var(--docs-code-text, #e53e3e);
  padding: 0.125rem 0.375rem;
  border-radius: 4px;
  font-family: 'Fira Code', Consolas, monospace;
  font-size: 0.875rem;
}

.doc-block :deep(a) {
  color: var(--docs-primary, #667eea);
  text-decoration: none;
  font-weight: 600;
  transition: all 0.2s ease;
}

.doc-block :deep(a:hover) {
  text-decoration: underline;
  color: var(--docs-primary-dark, #5a67d8);
}

.doc-block :deep(blockquote) {
  margin: 1.5rem 0;
  padding: 1rem 1.5rem;
  border-left: 4px solid var(--docs-primary, #667eea);
  background: var(--docs-quote-bg, #f8fafc);
  border-radius: 0 8px 8px 0;
  font-style: italic;
}

.doc-block :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1.5rem 0;
}

.doc-block :deep(th),
.doc-block :deep(td) {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid var(--docs-border, #e2e8f0);
}

.doc-block :deep(th) {
  background: var(--docs-table-header-bg, #f8fafc);
  font-weight: 600;
  color: var(--docs-text, #1a202c);
}

/* Responsividade */
@media (max-width: 768px) {
  .block-header {
    padding: 1rem;
  }

  .block-content {
    padding: 1rem;
  }

  .header-left {
    flex-wrap: wrap;
  }

  .block-title {
    font-size: 1.125rem;
  }
}
</style>