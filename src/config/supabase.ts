import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false
  }
})

// Database Tables - Todas as tabelas do sistema
export const DB_TABLES = {
  // Autenticação e Usuários
  USERS: 'admin_users',
  ROLES: 'user_roles',
  PERMISSIONS: 'permissions',
  ROLE_PERMISSIONS: 'role_permissions',

  // Estoque e Produtos
  PRODUCTS: 'produtos',
  CATEGORIES: 'categorias',
  MOVEMENTS: 'movements',
  SUPPLIERS: 'suppliers',

  // Cardápio e Menu
  MENU_ITEMS: 'menu_items',
  MENU_INGREDIENTS: 'menu_item_ingredientes',
  MENU_DAILY: 'menu_diario',
  WEEKLY_PLANNING: 'planejamento_semanal',

  // Financeiro
  FINANCIAL: 'financial_data',
  DAILY_FINANCIAL_SUMMARY: 'daily_financial_summary',

  // Funcionários e Pagamentos
  EMPLOYEES: 'employees',
  BANKS: 'banks',
  EMPLOYEE_BANK_ACCOUNTS: 'employee_bank_accounts',
  SALARY_CONFIGS: 'salary_configs',
  DAILY_PAYMENTS: 'daily_payments',
  EMPLOYEE_ATTENDANCE: 'employee_attendance',
  EMPLOYEE_PERFORMANCE_METRICS: 'employee_performance_metrics',
  PAYMENT_AUDIT_LOG: 'payment_audit_log',

  // API e Integrações
  API_KEYS: 'api_keys',
  API_REQUESTS: 'api_requests',
  API_METRICS: 'api_metrics',

  // Suporte
  SUPPORT_CONVERSATIONS: 'support_conversations',
  SUPPORT_MESSAGES: 'support_messages',
  SUPPORT_PARTICIPANTS: 'support_participants',

  // Sistema
  LOGS: 'logs',
  REPORTS: 'reports',
  SETTINGS: 'app_settings',
  SYSTEM_ALERTS: 'system_alerts'
}