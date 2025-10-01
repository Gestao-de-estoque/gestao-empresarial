<template>
  <div class="modal-overlay" @click="$emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>{{ employee ? 'Editar Funcionário' : 'Novo Funcionário' }}</h3>
        <button @click="$emit('close')" class="btn-close">
          <X :size="20" />
        </button>
      </div>
      <form @submit.prevent="handleSubmit" class="form">
        <div class="form-row">
          <div class="form-group">
            <label>Nome *</label>
            <input v-model="form.name" type="text" required class="form-input" />
          </div>
          <div class="form-group">
            <label>Email *</label>
            <input v-model="form.email" type="email" required class="form-input" />
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>Telefone</label>
            <input v-model="form.phone" type="tel" class="form-input" />
          </div>
          <div class="form-group">
            <label>Função *</label>
            <select v-model="form.position" required class="form-input">
              <option value="garcom">Garçom</option>
              <option value="balconista">Balconista</option>
              <option value="barmen">Barmen</option>
              <option value="cozinheiro">Cozinheiro</option>
              <option value="cozinheiro_chef">Cozinheiro Chef</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>Data de Contratação *</label>
            <input v-model="form.hire_date" type="date" required class="form-input" />
          </div>
          <div class="form-group">
            <label>Status *</label>
            <select v-model="form.status" required class="form-input">
              <option value="ativo">Ativo</option>
              <option value="inativo">Inativo</option>
              <option value="ferias">Férias</option>
              <option value="afastado">Afastado</option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <label>URL da Foto</label>
          <input v-model="form.photo_url" type="url" class="form-input" placeholder="https://..." />
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
import type { Employee } from '@/types/employee'

const props = defineProps<{
  employee?: Employee | null
}>()

const emit = defineEmits(['close', 'save'])

const loading = ref(false)
const form = reactive({
  name: '',
  email: '',
  phone: '',
  photo_url: '',
  position: 'garcom' as const,
  hire_date: new Date().toISOString().split('T')[0],
  status: 'ativo' as const
})

async function handleSubmit() {
  try {
    loading.value = true
    if (props.employee) {
      await employeeService.updateEmployee(props.employee.id!, form)
    } else {
      await employeeService.createEmployee(form)
    }
    emit('save')
  } catch (error) {
    console.error('Erro ao salvar funcionário:', error)
    alert('Erro ao salvar funcionário')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (props.employee) {
    Object.assign(form, props.employee)
  }
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
  max-width: 600px;
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
  transition: all 0.2s ease;
}

.btn-close:hover {
  background: rgba(0, 0, 0, 0.1);
  color: #374151;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
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
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
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
  transition: all 0.3s ease;
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
  background: rgba(255, 255, 255, 0.9);
  color: #374151;
  border: 1px solid #e5e7eb;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>
