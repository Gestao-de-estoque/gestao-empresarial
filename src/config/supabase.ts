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

// Database Tables
export const DB_TABLES = {
  USERS: 'admin_users',
  PRODUCTS: 'produtos',
  CATEGORIES: 'categorias',
  MOVEMENTS: 'movements',
  REPORTS: 'reports',
  LOGS: 'logs',
  MENU_ITEMS: 'menu_items',
  MENU_INGREDIENTS: 'menu_item_ingredientes',
  MENU_DAILY: 'menu_diario',
  WEEKLY_PLANNING: 'planejamento_semanal',
  SUPPLIERS: 'suppliers',
  SETTINGS: 'app_settings',
  FINANCIAL: 'financial_data'
}