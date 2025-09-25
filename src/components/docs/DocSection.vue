<template>
  <section :id="id" class="doc-section">
    <div class="section-anchor" :data-id="id"></div>
    <div class="section-content">
      <slot />
    </div>
  </section>
</template>

<script setup lang="ts">
interface Props {
  id: string
}

defineProps<Props>()
</script>

<style scoped>
.doc-section {
  margin-bottom: 3rem;
  scroll-margin-top: 100px;
}

.section-anchor {
  position: relative;
}

.section-content {
  position: relative;
}

.doc-section:target {
  animation: highlight 2s ease-in-out;
}

@keyframes highlight {
  0% {
    background: rgba(102, 126, 234, 0.1);
  }
  100% {
    background: transparent;
  }
}

.doc-section + .doc-section {
  border-top: 1px solid var(--docs-border, #e2e8f0);
  padding-top: 3rem;
}
</style>