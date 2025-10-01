<template>
  <div class="modal-overlay" @click="$emit('close')">
    <div class="modal-content large" @click.stop>
      <div class="modal-header">
        <h3>Dados Bancários - {{ employee?.name }}</h3>
        <button @click="$emit('close')" class="btn-close"><X :size="20" /></button>
      </div>

      <div class="accounts-list">
        <div v-for="account in accounts" :key="account.id" class="account-card">
          <div class="account-header">
            <div class="bank-info">
              <div class="bank-icon" :style="{ background: account.bank?.color || '#3b82f6' }">
                {{ account.bank?.name.charAt(0) }}
              </div>
              <div>
                <h4>{{ account.bank?.name }}</h4>
                <p>{{ accountTypeLabels[account.account_type] }}</p>
              </div>
            </div>
            <button @click="deleteAccount(account.id!)" class="btn-icon delete">
              <Trash2 :size="16" />
            </button>
          </div>
          <div class="account-details">
            <div class="detail">
              <span>Agência:</span> <strong>{{ account.agency }}</strong>
            </div>
            <div class="detail">
              <span>Conta:</span> <strong>{{ account.account_number }}-{{ account.account_digit }}</strong>
            </div>
            <div v-if="account.pix_key" class="detail">
              <span>Chave PIX:</span> <strong>{{ account.pix_key }}</strong>
            </div>
          </div>
        </div>
      </div>

      <button @click="showAddForm = true" class="btn-primary">
        <Plus :size="18" /> Adicionar Conta Bancária
      </button>

      <div v-if="showAddForm" class="add-form">
        <h4>Nova Conta Bancária</h4>
        <form @submit.prevent="handleSubmit" class="form">
          <div class="form-group">
            <label>Banco *</label>
            <select v-model="form.bank_id" required class="form-input">
              <option v-for="bank in banks" :key="bank.id" :value="bank.id">
                {{ bank.name }}
              </option>
            </select>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Tipo de Conta *</label>
              <select v-model="form.account_type" required class="form-input">
                <option value="corrente">Corrente</option>
                <option value="poupanca">Poupança</option>
                <option value="salario">Salário</option>
              </select>
            </div>
            <div class="form-group">
              <label>Agência *</label>
              <input v-model="form.agency" required class="form-input" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Número da Conta *</label>
              <input v-model="form.account_number" required class="form-input" />
            </div>
            <div class="form-group">
              <label>Dígito</label>
              <input v-model="form.account_digit" class="form-input" maxlength="2" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Tipo de Chave PIX</label>
              <select v-model="form.pix_key_type" class="form-input">
                <option value="">Nenhum</option>
                <option value="cpf">CPF</option>
                <option value="email">E-mail</option>
                <option value="telefone">Telefone</option>
                <option value="chave_aleatoria">Chave Aleatória</option>
              </select>
            </div>
            <div class="form-group" v-if="form.pix_key_type">
              <label>Chave PIX</label>
              <input v-model="form.pix_key" class="form-input" />
            </div>
          </div>
          <div class="form-actions">
            <button type="button" @click="showAddForm = false" class="btn-secondary">Cancelar</button>
            <button type="submit" class="btn-primary" :disabled="loading">
              {{ loading ? 'Salvando...' : 'Salvar' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { X, Trash2, Plus } from 'lucide-vue-next'
import { employeeService } from '@/services/employeeService'
import type { Employee, EmployeeBankAccount, Bank } from '@/types/employee'

const props = defineProps<{ employee: Employee | null }>()
const emit = defineEmits(['close', 'refresh'])

const loading = ref(false)
const showAddForm = ref(false)
const accounts = ref<EmployeeBankAccount[]>([])
const banks = ref<Bank[]>([])

const accountTypeLabels = {
  corrente: 'Conta Corrente',
  poupanca: 'Poupança',
  salario: 'Conta Salário'
}

const form = reactive({
  bank_id: 0,
  account_type: 'corrente' as const,
  agency: '',
  account_number: '',
  account_digit: '',
  pix_key_type: '' as any,
  pix_key: '',
  is_primary: false
})

async function loadAccounts() {
  if (!props.employee?.id) return
  try {
    accounts.value = await employeeService.getEmployeeBankAccounts(props.employee.id)
  } catch (error) {
    console.error('Erro ao carregar contas:', error)
  }
}

async function loadBanks() {
  try {
    banks.value = await employeeService.getAllBanks()
  } catch (error) {
    console.error('Erro ao carregar bancos:', error)
  }
}

async function handleSubmit() {
  if (!props.employee?.id) return
  try {
    loading.value = true
    await employeeService.createBankAccount({
      ...form,
      employee_id: props.employee.id
    })
    showAddForm.value = false
    await loadAccounts()
    emit('refresh')
  } catch (error) {
    console.error('Erro ao salvar conta:', error)
    alert('Erro ao salvar conta bancária')
  } finally {
    loading.value = false
  }
}

async function deleteAccount(id: number) {
  if (!confirm('Deseja remover esta conta bancária?')) return
  try {
    await employeeService.deleteBankAccount(id)
    await loadAccounts()
    emit('refresh')
  } catch (error) {
    console.error('Erro ao deletar conta:', error)
    alert('Erro ao remover conta bancária')
  }
}

onMounted(() => {
  loadAccounts()
  loadBanks()
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
  max-width: 700px;
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

.accounts-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 2rem;
}

.account-card {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 1.5rem;
}

.account-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.bank-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.bank-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 1.25rem;
}

.bank-info h4 {
  margin: 0;
  font-size: 1.1rem;
  color: #1e293b;
}

.bank-info p {
  margin: 0;
  font-size: 0.9rem;
  color: #64748b;
}

.account-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.detail {
  font-size: 0.9rem;
  color: #64748b;
}

.detail strong {
  color: #1e293b;
}

.btn-icon.delete {
  padding: 0.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.add-form {
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid #e5e7eb;
}

.add-form h4 {
  margin: 0 0 1.5rem 0;
  color: #1e293b;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
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
}

.btn-primary, .btn-secondary {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.95rem;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-primary {
  background: linear-gradient(45deg, #3b82f6, #1d4ed8);
  color: white;
}

.btn-secondary {
  background: #fff;
  color: #374151;
  border: 1px solid #e5e7eb;
}
</style>
