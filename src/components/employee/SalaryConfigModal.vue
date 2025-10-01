<template>
  <div class="modal-overlay" @click="$emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>Configurar Salário - {{ EMPLOYEE_POSITIONS[config.position] }}</h3>
        <button @click="$emit('close')" class="btn-close"><X :size="20" /></button>
      </div>
      <form @submit.prevent="handleSubmit" class="form">
        <div class="form-group">
          <label>Tipo de Cálculo *</label>
          <select v-model="form.calculation_type" required class="form-input">
            <option value="fixed">Fixo</option>
            <option value="percentage">Percentual</option>
            <option value="mixed">Misto</option>
          </select>
        </div>
        <div v-if="['fixed', 'mixed'].includes(form.calculation_type)" class="form-group">
          <label>Valor Fixo Diário (R$)</label>
          <input v-model.number="form.fixed_daily_amount" type="number" step="0.01" min="0" class="form-input" />
        </div>
        <div v-if="['percentage', 'mixed'].includes(form.calculation_type)" class="form-group">
          <label>Taxa Percentual (%)</label>
          <input v-model.number="form.percentage_rate" type="number" step="0.01" min="0" max="100" class="form-input" />
        </div>
        <div class="form-group">
          <label>Garantia Mínima Diária (R$)</label>
          <input v-model.number="form.min_daily_guarantee" type="number" step="0.01" min="0" class="form-input" />
        </div>
        <div class="form-group">
          <label>Limite Máximo Diário (R$)</label>
          <input v-model.number="form.max_daily_limit" type="number" step="0.01" min="0" class="form-input" />
        </div>
        <div class="form-group">
          <label>Descrição</label>
          <textarea v-model="form.description" rows="3" class="form-input"></textarea>
        </div>
        <div class="form-actions">
          <button type="button" @click="$emit('close')" class="btn-secondary">Cancelar</button>
          <button type="submit" class="btn-primary" :disabled="loading">
            {{ loading ? 'Salvando...' : 'Salvar' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { X } from 'lucide-vue-next'
import { employeeService } from '@/services/employeeService'
import type { SalaryConfig } from '@/types/employee'
import { EMPLOYEE_POSITIONS } from '@/types/employee'

const props = defineProps<{ config: SalaryConfig }>()
const emit = defineEmits(['close', 'save'])

const loading = ref(false)
const form = reactive({
  calculation_type: 'fixed' as const,
  fixed_daily_amount: 0,
  percentage_rate: 0,
  min_daily_guarantee: 0,
  max_daily_limit: 0,
  description: '',
  active: true
})

async function handleSubmit() {
  try {
    loading.value = true
    await employeeService.updateSalaryConfig(props.config.position, form)
    emit('save')
  } catch (error) {
    console.error('Erro ao salvar configuração:', error)
    alert('Erro ao salvar configuração de salário')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  Object.assign(form, props.config)
})
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
  max-height: 90vh;
  overflow-y: auto;
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

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
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
