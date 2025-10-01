export type EmployeePosition = 'garcom' | 'balconista' | 'barmen' | 'cozinheiro' | 'cozinheiro_chef'

export type EmployeeStatus = 'ativo' | 'inativo' | 'ferias' | 'afastado'

export type PaymentStatus = 'pendente' | 'processando' | 'pago' | 'cancelado'

export type PaymentMethod = 'pix' | 'transferencia' | 'dinheiro' | 'cheque'

export type AccountType = 'corrente' | 'poupanca' | 'salario'

export type PixKeyType = 'cpf' | 'email' | 'telefone' | 'chave_aleatoria' | 'qrcode'

export type CalculationType = 'percentage' | 'fixed' | 'mixed'

export type AttendanceStatus = 'presente' | 'ausente' | 'falta' | 'ferias' | 'folga' | 'atestado'

export interface Employee {
  id?: number
  name: string
  email: string
  phone?: string
  photo_url?: string
  position: EmployeePosition
  hire_date: string
  status: EmployeeStatus
  created_at?: string
  updated_at?: string
}

export interface Bank {
  id?: number
  code: string
  name: string
  icon_url?: string
  color?: string
  created_at?: string
}

export interface EmployeeBankAccount {
  id?: number
  employee_id: number
  bank_id: number
  account_type: AccountType
  agency: string
  account_number: string
  account_digit?: string
  pix_key_type?: PixKeyType
  pix_key?: string
  qr_code_pix?: string
  is_primary: boolean
  created_at?: string
  updated_at?: string
  // Dados joined
  bank?: Bank
}

export interface SalaryConfig {
  id?: number
  position: EmployeePosition
  calculation_type: CalculationType
  fixed_daily_amount: number
  percentage_rate: number
  min_daily_guarantee: number
  max_daily_limit?: number
  description?: string
  active: boolean
  created_at?: string
  updated_at?: string
}

export interface DailyPayment {
  id?: number
  employee_id: number
  payment_date: string
  daily_revenue: number
  base_salary: number
  bonus: number
  deductions: number
  final_amount: number
  calculation_details?: any
  payment_status: PaymentStatus
  payment_method?: PaymentMethod
  paid_at?: string
  notes?: string
  created_at?: string
  updated_at?: string
  // Dados joined
  employee?: Employee
}

export interface DailyFinancialSummary {
  id?: number
  summary_date: string
  total_revenue: number
  total_employee_payments: number
  total_garcom_percentage: number
  num_active_employees: number
  num_garcom_on_duty: number
  calculation_details?: any
  synced_with_financial_data: boolean
  financial_data_id?: number
  created_at?: string
  updated_at?: string
}

export interface EmployeeAttendance {
  id?: number
  employee_id: number
  attendance_date: string
  check_in?: string
  check_out?: string
  hours_worked?: number
  status: AttendanceStatus
  notes?: string
  created_at?: string
  updated_at?: string
  // Dados joined
  employee?: Employee
}

export interface EmployeePerformanceMetrics {
  id?: number
  employee_id: number
  metric_date: string
  total_earnings: number
  days_worked: number
  average_daily_earnings: number
  total_bonus: number
  total_deductions: number
  performance_score?: number
  metrics_details?: any
  created_at?: string
  updated_at?: string
}

export interface PaymentAuditLog {
  id?: number
  payment_id?: number
  employee_id: number
  action: string
  old_values?: any
  new_values?: any
  changed_by?: string // UUID
  ip_address?: string
  user_agent?: string
  created_at?: string
}

// View types
export interface ActiveEmployeeSummary {
  id: number
  name: string
  email: string
  position: EmployeePosition
  calculation_type: CalculationType
  fixed_daily_amount: number
  percentage_rate: number
  total_payments: number
  total_earned: number
  average_daily_earning: number
}

export interface PendingPayment {
  id: number
  employee_id: number
  employee_name: string
  position: EmployeePosition
  payment_date: string
  final_amount: number
  payment_status: PaymentStatus
  created_at: string
}

export interface MonthlyPaymentAnalysis {
  month: string
  position: EmployeePosition
  num_employees: number
  total_payments: number
  total_amount: number
  average_payment: number
  total_revenue: number
}

export interface GarcomPerformance {
  id: number
  name: string
  photo_url?: string
  days_worked_this_month: number
  total_earned_this_month: number
  average_daily_earning: number
  best_day_earning: number
  worst_day_earning: number
}

// Tipos para formulários
export interface EmployeeFormData {
  name: string
  email: string
  phone?: string
  photo_url?: string
  position: EmployeePosition
  hire_date: string
  status: EmployeeStatus
}

export interface BankAccountFormData {
  employee_id: number
  bank_id: number
  account_type: AccountType
  agency: string
  account_number: string
  account_digit?: string
  pix_key_type?: PixKeyType
  pix_key?: string
  qr_code_pix?: string
  is_primary: boolean
}

export interface PaymentFormData {
  employee_id: number
  payment_date: string
  daily_revenue: number
  bonus?: number
  deductions?: number
  payment_method?: PaymentMethod
  notes?: string
}

// Constantes úteis
export const EMPLOYEE_POSITIONS: Record<EmployeePosition, string> = {
  garcom: 'Garçom',
  balconista: 'Balconista',
  barmen: 'Barmen',
  cozinheiro: 'Cozinheiro',
  cozinheiro_chef: 'Cozinheiro Chef'
}

export const PAYMENT_STATUS_LABELS: Record<PaymentStatus, string> = {
  pendente: 'Pendente',
  processando: 'Processando',
  pago: 'Pago',
  cancelado: 'Cancelado'
}

export const PAYMENT_METHOD_LABELS: Record<PaymentMethod, string> = {
  pix: 'PIX',
  transferencia: 'Transferência',
  dinheiro: 'Dinheiro',
  cheque: 'Cheque'
}
