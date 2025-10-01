<template>
  <div class="modal-overlay" @click="$emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>Detalhes do Pagamento</h3>
        <button @click="$emit('close')" class="btn-close"><X :size="20" /></button>
      </div>
      <div class="payment-details">
        <div class="detail-row">
          <span>Funcionário:</span>
          <strong>{{ payment.employee?.name }}</strong>
        </div>
        <div class="detail-row">
          <span>Data:</span>
          <strong>{{ formatDate(payment.payment_date) }}</strong>
        </div>
        <div class="detail-row">
          <span>Receita Diária:</span>
          <strong class="currency">{{ formatCurrency(payment.daily_revenue) }}</strong>
        </div>
        <div class="detail-row">
          <span>Salário Base:</span>
          <strong class="currency">{{ formatCurrency(payment.base_salary) }}</strong>
        </div>
        <div class="detail-row">
          <span>Bônus:</span>
          <strong class="currency success">{{ formatCurrency(payment.bonus) }}</strong>
        </div>
        <div class="detail-row">
          <span>Deduções:</span>
          <strong class="currency danger">{{ formatCurrency(payment.deductions) }}</strong>
        </div>
        <div class="detail-row total">
          <span>Valor Final:</span>
          <strong class="currency">{{ formatCurrency(payment.final_amount) }}</strong>
        </div>
        <div class="detail-row">
          <span>Status:</span>
          <span :class="['status-badge', payment.payment_status]">{{ payment.payment_status }}</span>
        </div>
        <div v-if="payment.payment_method" class="detail-row">
          <span>Método de Pagamento:</span>
          <strong>{{ payment.payment_method }}</strong>
        </div>
        <div v-if="payment.notes" class="notes">
          <h4>Observações:</h4>
          <p>{{ payment.notes }}</p>
        </div>
        <div v-if="payment.calculation_details" class="calculation-details">
          <h4>Detalhes do Cálculo:</h4>
          <pre>{{ JSON.stringify(payment.calculation_details, null, 2) }}</pre>
        </div>
      </div>
      <div class="modal-actions">
        <button @click="$emit('close')" class="btn-primary">Fechar</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { X } from 'lucide-vue-next'
import type { DailyPayment } from '@/types/employee'

defineProps<{ payment: DailyPayment }>()
defineEmits(['close'])

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value)
}

function formatDate(dateStr: string): string {
  return new Date(dateStr + 'T00:00:00').toLocaleDateString('pt-BR')
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
}

.payment-details {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: #f8fafc;
  border-radius: 8px;
}

.detail-row.total {
  background: #eff6ff;
  border: 2px solid #3b82f6;
  font-size: 1.1rem;
}

.currency {
  font-family: 'Courier New', monospace;
}

.currency.success { color: #10b981; }
.currency.danger { color: #ef4444; }

.status-badge {
  padding: 0.375rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge.pendente { background: #fef3c7; color: #92400e; }
.status-badge.pago { background: #dcfce7; color: #166534; }
.status-badge.cancelado { background: #fee2e2; color: #991b1b; }

.notes, .calculation-details {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.notes h4, .calculation-details h4 {
  margin: 0 0 0.5rem 0;
  color: #1e293b;
}

.notes p {
  margin: 0;
  color: #64748b;
  line-height: 1.6;
}

.calculation-details pre {
  background: #f1f5f9;
  padding: 1rem;
  border-radius: 8px;
  overflow-x: auto;
  font-size: 0.85rem;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.btn-primary {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.95rem;
  border: none;
  cursor: pointer;
  background: linear-gradient(45deg, #3b82f6, #1d4ed8);
  color: white;
}
</style>
