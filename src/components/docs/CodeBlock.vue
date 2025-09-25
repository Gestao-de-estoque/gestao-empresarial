<template>
  <div class="code-block" :class="{ expanded: isExpanded }">
    <div class="code-header">
      <div class="header-left">
        <div class="language-badge">
          <component :is="languageIcon" :size="16" v-if="languageIcon" />
          {{ displayLanguage }}
        </div>
        <span v-if="filename" class="filename">{{ filename }}</span>
      </div>

      <div class="header-actions">
        <button @click="copyCode" class="action-btn" :class="{ copied: isCopied }" title="Copiar código">
          <component :is="isCopied ? Check : Copy" :size="16" />
        </button>

        <button v-if="canExpand" @click="toggleExpanded" class="action-btn" :title="isExpanded ? 'Recolher' : 'Expandir'">
          <component :is="isExpanded ? Minimize2 : Maximize2" :size="16" />
        </button>

        <button v-if="showLineNumbers !== undefined" @click="toggleLineNumbers" class="action-btn" :title="showLineNumbers ? 'Ocultar números' : 'Mostrar números'">
          <Hash :size="16" />
        </button>
      </div>
    </div>

    <div class="code-content" :class="{ 'with-line-numbers': showLineNumbers }">
      <pre :class="`language-${language}`"><code ref="codeElement" v-html="highlightedCode"></code></pre>
    </div>

    <div v-if="description" class="code-description">
      <Info :size="16" />
      {{ description }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from 'vue'
import {
  Copy, Check, Maximize2, Minimize2, Hash, Info,
  FileCode, Database, Terminal, Globe, Braces
} from 'lucide-vue-next'

interface Props {
  code: string
  language: string
  filename?: string
  description?: string
  lineNumbers?: boolean
  maxHeight?: string
  canExpand?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  lineNumbers: true,
  maxHeight: '400px',
  canExpand: true,
})

const codeElement = ref<HTMLElement>()
const isCopied = ref(false)
const isExpanded = ref(false)
const showLineNumbers = ref(props.lineNumbers)

const languageIcons: Record<string, any> = {
  javascript: FileCode,
  typescript: FileCode,
  vue: FileCode,
  html: Globe,
  css: Braces,
  scss: Braces,
  sql: Database,
  bash: Terminal,
  shell: Terminal,
  json: Braces,
  yaml: FileCode,
  dockerfile: FileCode,
  mermaid: FileCode,
}

const languageLabels: Record<string, string> = {
  javascript: 'JavaScript',
  typescript: 'TypeScript',
  vue: 'Vue.js',
  html: 'HTML',
  css: 'CSS',
  scss: 'SCSS',
  sql: 'SQL',
  bash: 'Bash',
  shell: 'Shell',
  json: 'JSON',
  yaml: 'YAML',
  dockerfile: 'Dockerfile',
  mermaid: 'Mermaid',
}

const languageIcon = computed(() => {
  return languageIcons[props.language] || FileCode
})

const displayLanguage = computed(() => {
  return languageLabels[props.language] || props.language.toUpperCase()
})

const highlightedCode = computed(() => {
  // Implementação básica de syntax highlighting
  // Em um projeto real, você usaria uma biblioteca como Prism.js ou highlight.js
  return highlightSyntax(props.code, props.language)
})

function highlightSyntax(code: string, language: string): string {
  // Implementação simplificada de syntax highlighting
  let highlighted = code

  // Escapar HTML
  highlighted = highlighted
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

  // Adicionar números de linha se necessário
  if (showLineNumbers.value) {
    const lines = highlighted.split('\n')
    highlighted = lines
      .map((line, index) => {
        const lineNumber = (index + 1).toString().padStart(3, ' ')
        return `<span class="line-number">${lineNumber}</span>${line}`
      })
      .join('\n')
  }

  // Highlighting específico por linguagem
  switch (language) {
    case 'javascript':
    case 'typescript':
      highlighted = highlightJavaScript(highlighted)
      break
    case 'vue':
      highlighted = highlightVue(highlighted)
      break
    case 'html':
      highlighted = highlightHTML(highlighted)
      break
    case 'css':
    case 'scss':
      highlighted = highlightCSS(highlighted)
      break
    case 'sql':
      highlighted = highlightSQL(highlighted)
      break
    case 'bash':
    case 'shell':
      highlighted = highlightBash(highlighted)
      break
    case 'json':
      highlighted = highlightJSON(highlighted)
      break
  }

  return highlighted
}

function highlightJavaScript(code: string): string {
  return code
    .replace(/\b(const|let|var|function|class|interface|type|import|export|from|default|async|await|return|if|else|for|while|do|switch|case|break|continue|try|catch|finally|throw|new|this|super|extends|implements)\b/g, '<span class="keyword">$1</span>')
    .replace(/\b(true|false|null|undefined|NaN|Infinity)\b/g, '<span class="literal">$1</span>')
    .replace(/\b(\d+\.?\d*)\b/g, '<span class="number">$1</span>')
    .replace(/(\/\/.*$|\/\*[\s\S]*?\*\/)/gm, '<span class="comment">$1</span>')
    .replace(/(['"`])((?:\\.|(?!\1)[^\\])*)\1/g, '<span class="string">$1$2$1</span>')
}

function highlightVue(code: string): string {
  return code
    .replace(/&lt;(\/?)(template|script|style)([^&]*)&gt;/g, '<span class="tag">&lt;<span class="tag-name">$1$2</span>$3&gt;</span>')
    .replace(/&lt;(\/?)([\w-]+)([^&]*)&gt;/g, '<span class="tag">&lt;<span class="tag-name">$1$2</span><span class="attribute">$3</span>&gt;</span>')
    .replace(/\b(v-if|v-else|v-for|v-model|v-show|v-bind|v-on|@click|@input|:class|:style)\b/g, '<span class="vue-directive">$1</span>')
}

function highlightHTML(code: string): string {
  return code
    .replace(/&lt;(\/?)([\w-]+)([^&]*)&gt;/g, '<span class="tag">&lt;<span class="tag-name">$1$2</span><span class="attribute">$3</span>&gt;</span>')
    .replace(/([\w-]+)=(['"`])((?:\\.|(?!\2)[^\\])*)\2/g, '<span class="attr-name">$1</span>=<span class="string">$2$3$2</span>')
}

function highlightCSS(code: string): string {
  return code
    .replace(/([.#]?[\w-]+)\s*{/g, '<span class="selector">$1</span> {')
    .replace(/([\w-]+):\s*([^;]+);/g, '<span class="property">$1</span>: <span class="value">$2</span>;')
    .replace(/(\/\*[\s\S]*?\*\/)/g, '<span class="comment">$1</span>')
}

function highlightSQL(code: string): string {
  return code
    .replace(/\b(SELECT|FROM|WHERE|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP|TABLE|DATABASE|INDEX|JOIN|LEFT|RIGHT|INNER|OUTER|ON|AS|AND|OR|NOT|IN|EXISTS|LIKE|BETWEEN|ORDER BY|GROUP BY|HAVING|LIMIT|OFFSET)\b/gi, '<span class="keyword">$1</span>')
    .replace(/\b(VARCHAR|TEXT|INT|INTEGER|BIGINT|DECIMAL|FLOAT|DOUBLE|DATE|DATETIME|TIMESTAMP|BOOLEAN|BLOB)\b/gi, '<span class="type">$1</span>')
    .replace(/(['"`])((?:\\.|(?!\1)[^\\])*)\1/g, '<span class="string">$1$2$1</span>')
}

function highlightBash(code: string): string {
  return code
    .replace(/^(\$|#)\s*/gm, '<span class="prompt">$1</span> ')
    .replace(/\b(cd|ls|mkdir|rm|mv|cp|chmod|chown|grep|find|sed|awk|curl|wget|git|npm|yarn|docker|sudo)\b/g, '<span class="command">$1</span>')
    .replace(/(-{1,2}[\w-]+)/g, '<span class="flag">$1</span>')
    .replace(/(#.*$)/gm, '<span class="comment">$1</span>')
}

function highlightJSON(code: string): string {
  return code
    .replace(/("[\w_]+")(\s*:)/g, '<span class="key">$1</span>$2')
    .replace(/:\s*("(?:\\.|[^"\\])*")/g, ': <span class="string">$1</span>')
    .replace(/:\s*(true|false|null)/g, ': <span class="literal">$1</span>')
    .replace(/:\s*(\d+\.?\d*)/g, ': <span class="number">$1</span>')
}

async function copyCode() {
  try {
    await navigator.clipboard.writeText(props.code)
    isCopied.value = true
    setTimeout(() => {
      isCopied.value = false
    }, 2000)
  } catch (err) {
    console.error('Failed to copy code:', err)
  }
}

function toggleExpanded() {
  isExpanded.value = !isExpanded.value
}

function toggleLineNumbers() {
  showLineNumbers.value = !showLineNumbers.value
}

onMounted(() => {
  // Aqui você pode inicializar uma biblioteca de syntax highlighting como Prism.js
  // if (window.Prism) {
  //   nextTick(() => {
  //     window.Prism.highlightElement(codeElement.value)
  //   })
  // }
})
</script>

<style scoped>
.code-block {
  background: var(--docs-code-bg, #1e293b);
  border: 2px solid var(--docs-border, #334155);
  border-radius: 12px;
  margin: 1.5rem 0;
  overflow: hidden;
  font-family: 'Fira Code', 'Cascadia Code', Consolas, monospace;
  transition: all 0.3s ease;
}

.code-block:hover {
  border-color: var(--docs-primary, #667eea);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
}

.code-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.5rem;
  background: var(--docs-code-header-bg, #0f172a);
  border-bottom: 1px solid var(--docs-border, #334155);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.language-badge {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.25rem 0.75rem;
  background: var(--docs-primary, #667eea);
  color: white;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.filename {
  color: var(--docs-code-text, #94a3b8);
  font-size: 0.875rem;
  font-weight: 500;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 6px;
  background: transparent;
  color: var(--docs-code-text, #94a3b8);
  cursor: pointer;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: rgba(148, 163, 184, 0.1);
  color: white;
}

.action-btn.copied {
  color: var(--docs-success, #10b981);
  background: rgba(16, 185, 129, 0.1);
}

.code-content {
  position: relative;
  max-height: v-bind(maxHeight);
  overflow: auto;
}

.code-block.expanded .code-content {
  max-height: none;
}

.code-content pre {
  margin: 0;
  padding: 1.5rem;
  overflow: visible;
  background: transparent;
  color: var(--docs-code-text, #f1f5f9);
  font-size: 0.875rem;
  line-height: 1.6;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.code-content code {
  font-family: inherit;
  background: none;
  padding: 0;
  border-radius: 0;
}

.code-content.with-line-numbers pre {
  padding-left: 4rem;
}

.code-description {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 1.5rem;
  background: var(--docs-info-bg, rgba(59, 130, 246, 0.1));
  color: var(--docs-info-text, #3b82f6);
  border-top: 1px solid var(--docs-border, #334155);
  font-size: 0.875rem;
}

/* Syntax highlighting styles */
:deep(.line-number) {
  position: absolute;
  left: 0;
  width: 3rem;
  text-align: right;
  color: var(--docs-code-line-numbers, #64748b);
  user-select: none;
  padding-right: 1rem;
}

:deep(.keyword) {
  color: #c792ea;
  font-weight: 600;
}

:deep(.string) {
  color: #c3e88d;
}

:deep(.number) {
  color: #f78c6c;
}

:deep(.literal) {
  color: #ff5370;
  font-weight: 600;
}

:deep(.comment) {
  color: #546e7a;
  font-style: italic;
}

:deep(.tag) {
  color: #f07178;
}

:deep(.tag-name) {
  color: #f07178;
  font-weight: 600;
}

:deep(.attribute) {
  color: #ffcb6b;
}

:deep(.attr-name) {
  color: #ffcb6b;
}

:deep(.value) {
  color: #c3e88d;
}

:deep(.selector) {
  color: #ffcb6b;
  font-weight: 600;
}

:deep(.property) {
  color: #82aaff;
}

:deep(.type) {
  color: #ffcb6b;
  font-weight: 600;
}

:deep(.command) {
  color: #82aaff;
  font-weight: 600;
}

:deep(.flag) {
  color: #c792ea;
}

:deep(.prompt) {
  color: #c3e88d;
  font-weight: 600;
}

:deep(.key) {
  color: #82aaff;
  font-weight: 600;
}

:deep(.vue-directive) {
  color: #c792ea;
  font-weight: 600;
}

/* Scrollbar styling */
.code-content::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.code-content::-webkit-scrollbar-track {
  background: var(--docs-code-scrollbar-track, #334155);
}

.code-content::-webkit-scrollbar-thumb {
  background: var(--docs-code-scrollbar-thumb, #64748b);
  border-radius: 4px;
}

.code-content::-webkit-scrollbar-thumb:hover {
  background: var(--docs-code-scrollbar-thumb-hover, #94a3b8);
}

/* Responsividade */
@media (max-width: 768px) {
  .code-header {
    padding: 0.75rem 1rem;
  }

  .code-content pre {
    padding: 1rem;
    font-size: 0.75rem;
  }

  .code-content.with-line-numbers pre {
    padding-left: 3rem;
  }

  :deep(.line-number) {
    width: 2.5rem;
    font-size: 0.75rem;
  }
}
</style>