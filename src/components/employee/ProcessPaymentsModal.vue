<template>
  <div class="modal-overlay" @click="$emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>Processar Pagamentos Diários</h3>
        <button @click="$emit('close')" class="btn-close"><X :size="20" /></button>
      </div>
      <form @submit.prevent="handleSubmit" class="form">
        <div class="form-group">
          <label>Data do Pagamento *</label>
          <input v-model="form.date" type="date" required class="form-input" />
        </div>
        <div class="form-group">
          <label>Receita Total do Dia (R$) *</label>
          <input v-model.number="form.revenue" type="number" step="0.01" min="0" required class="form-input" />
        </div>
        <div class="info-box">
          <p>Este processo irá calcular automaticamente os pagamentos para todos os funcionários ativos baseado nas configurações de salário.</p>
        </div>
        <div class="form-actions">
          <button type="button" @click="$emit('close')" class="btn-secondary">Cancelar</button>
          <button type="submit" class="btn-primary" :disabled="loading">
            {{ loading ? 'Processando...' : 'Processar Pagamentos' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { X } from 'lucide-vue-next'
import { employeeService } from '@/services/employeeService'

const emit = defineEmits(['close', 'success'])
const loading = ref(false)
const form = reactive({
  date: new Date().toISOString().split('T')[0],
  revenue: 0
})

async function handleSubmit() {
  try {
    loading.value = true
    await employeeService.processDailyPayments(form.date, form.revenue)
    alert('Pagamentos processados com sucesso!')
    emit('success')
  } catch (error) {
    console.error('Erro ao processar pagamentos:', error)
    alert('Erro ao processar pagamentos')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(10px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 20px;
  padding: 2rem;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.btn-close {
  background: none;
  border: none;
  cursor: pointer;
  color: #9ca3af;
  padding: 0.5rem;
  border-radius: 6px;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 600;
  color: #374151;
  font-size: 0.9rem;
}

.form-input {
  padding: 0.75rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.info-box {
  background: #eff6ff;
  border-left: 3px solid #3b82f6;
  padding: 1rem;
  border-radius: 8px;
}

.info-box p {
  margin: 0;
  font-size: 0.9rem;
  color: #1e40af;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 1rem;
}

.btn-primary, .btn-secondary {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.95rem;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: linear-gradient(45deg, #3b82f6, #1d4ed8);
  color: white;
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: #fff;
  color: #374151;
  border: 1px solid #e5e7eb;
}
</style>
