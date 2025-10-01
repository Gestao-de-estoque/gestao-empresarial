import { supabase } from '@/config/supabase'
import type {
  Employee,
  EmployeeFormData,
  Bank,
  EmployeeBankAccount,
  BankAccountFormData,
  DailyPayment,
  PaymentFormData,
  SalaryConfig,
  EmployeeAttendance,
  ActiveEmployeeSummary,
  PendingPayment,
  MonthlyPaymentAnalysis,
  GarcomPerformance,
  EmployeePosition
} from '@/types/employee'

class EmployeeService {
  // ============================================
  // EMPLOYEES CRUD
  // ============================================

  async getAllEmployees(): Promise<Employee[]> {
    try {
      const { data, error } = await supabase
        .from('employees')
        .select('*')
        .order('name', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar funcionários:', error)
      throw error
    }
  }

  async getActiveEmployees(): Promise<Employee[]> {
    try {
      const { data, error } = await supabase
        .from('employees')
        .select('*')
        .eq('status', 'ativo')
        .order('name', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar funcionários ativos:', error)
      throw error
    }
  }

  async getEmployeeById(id: number): Promise<Employee | null> {
    try {
      const { data, error } = await supabase
        .from('employees')
        .select('*')
        .eq('id', id)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao buscar funcionário:', error)
      throw error
    }
  }

  async getEmployeesByPosition(position: EmployeePosition): Promise<Employee[]> {
    try {
      const { data, error } = await supabase
        .from('employees')
        .select('*')
        .eq('position', position)
        .eq('status', 'ativo')
        .order('name', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar funcionários por função:', error)
      throw error
    }
  }

  async createEmployee(employee: EmployeeFormData): Promise<Employee> {
    try {
      const { data, error } = await supabase
        .from('employees')
        .insert([employee])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar funcionário:', error)
      throw error
    }
  }

  async updateEmployee(id: number, employee: Partial<EmployeeFormData>): Promise<Employee> {
    try {
      const { data, error } = await supabase
        .from('employees')
        .update(employee)
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao atualizar funcionário:', error)
      throw error
    }
  }

  async deleteEmployee(id: number): Promise<void> {
    try {
      const { error } = await supabase
        .from('employees')
        .delete()
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Erro ao deletar funcionário:', error)
      throw error
    }
  }

  // ============================================
  // BANKS
  // ============================================

  async getAllBanks(): Promise<Bank[]> {
    try {
      const { data, error } = await supabase
        .from('banks')
        .select('*')
        .order('name', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar bancos:', error)
      throw error
    }
  }

  // ============================================
  // BANK ACCOUNTS
  // ============================================

  async getEmployeeBankAccounts(employeeId: number): Promise<EmployeeBankAccount[]> {
    try {
      const { data, error } = await supabase
        .from('employee_bank_accounts')
        .select(`
          *,
          bank:banks (*)
        `)
        .eq('employee_id', employeeId)
        .order('is_primary', { ascending: false })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar contas bancárias:', error)
      throw error
    }
  }

  async createBankAccount(account: BankAccountFormData): Promise<EmployeeBankAccount> {
    try {
      const { data, error } = await supabase
        .from('employee_bank_accounts')
        .insert([account])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar conta bancária:', error)
      throw error
    }
  }

  async updateBankAccount(id: number, account: Partial<BankAccountFormData>): Promise<EmployeeBankAccount> {
    try {
      const { data, error } = await supabase
        .from('employee_bank_accounts')
        .update(account)
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao atualizar conta bancária:', error)
      throw error
    }
  }

  async deleteBankAccount(id: number): Promise<void> {
    try {
      const { error } = await supabase
        .from('employee_bank_accounts')
        .delete()
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Erro ao deletar conta bancária:', error)
      throw error
    }
  }

  // ============================================
  // SALARY CONFIGS
  // ============================================

  async getAllSalaryConfigs(): Promise<SalaryConfig[]> {
    try {
      const { data, error } = await supabase
        .from('salary_configs')
        .select('*')
        .order('position', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar configurações de salário:', error)
      throw error
    }
  }

  async getSalaryConfigByPosition(position: EmployeePosition): Promise<SalaryConfig | null> {
    try {
      const { data, error } = await supabase
        .from('salary_configs')
        .select('*')
        .eq('position', position)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao buscar configuração de salário:', error)
      throw error
    }
  }

  async updateSalaryConfig(position: EmployeePosition, config: Partial<SalaryConfig>): Promise<SalaryConfig> {
    try {
      const { data, error } = await supabase
        .from('salary_configs')
        .update(config)
        .eq('position', position)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao atualizar configuração de salário:', error)
      throw error
    }
  }

  // ============================================
  // DAILY PAYMENTS
  // ============================================

  async getAllPayments(): Promise<DailyPayment[]> {
    try {
      const { data, error } = await supabase
        .from('daily_payments')
        .select(`
          *,
          employee:employees (*)
        `)
        .order('payment_date', { ascending: false })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar pagamentos:', error)
      throw error
    }
  }

  async getPaymentsByDate(date: string): Promise<DailyPayment[]> {
    try {
      const { data, error } = await supabase
        .from('daily_payments')
        .select(`
          *,
          employee:employees (*)
        `)
        .eq('payment_date', date)
        .order('employee_id', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar pagamentos por data:', error)
      throw error
    }
  }

  async getPaymentsByEmployee(employeeId: number): Promise<DailyPayment[]> {
    try {
      const { data, error } = await supabase
        .from('daily_payments')
        .select('*')
        .eq('employee_id', employeeId)
        .order('payment_date', { ascending: false })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar pagamentos do funcionário:', error)
      throw error
    }
  }

  async getPaymentsByDateRange(startDate: string, endDate: string): Promise<DailyPayment[]> {
    try {
      const { data, error } = await supabase
        .from('daily_payments')
        .select(`
          *,
          employee:employees (*)
        `)
        .gte('payment_date', startDate)
        .lte('payment_date', endDate)
        .order('payment_date', { ascending: false })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar pagamentos por período:', error)
      throw error
    }
  }

  async createPayment(payment: PaymentFormData): Promise<DailyPayment> {
    try {
      // Buscar configuração de salário
      const employee = await this.getEmployeeById(payment.employee_id)
      if (!employee) throw new Error('Funcionário não encontrado')

      const salaryConfig = await this.getSalaryConfigByPosition(employee.position)
      if (!salaryConfig) throw new Error('Configuração de salário não encontrada')

      // Calcular salário
      const calculatedPayment = await this.calculateDailyPayment(
        employee,
        salaryConfig,
        payment.daily_revenue,
        payment.bonus || 0,
        payment.deductions || 0
      )

      const paymentData = {
        employee_id: payment.employee_id,
        payment_date: payment.payment_date,
        daily_revenue: payment.daily_revenue,
        base_salary: calculatedPayment.base_salary,
        bonus: payment.bonus || 0,
        deductions: payment.deductions || 0,
        final_amount: calculatedPayment.final_amount,
        calculation_details: calculatedPayment.calculation_details,
        payment_status: 'pendente' as const,
        payment_method: payment.payment_method,
        notes: payment.notes
      }

      const { data, error } = await supabase
        .from('daily_payments')
        .insert([paymentData])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao criar pagamento:', error)
      throw error
    }
  }

  async updatePayment(id: number, payment: Partial<DailyPayment>): Promise<DailyPayment> {
    try {
      const { data, error } = await supabase
        .from('daily_payments')
        .update(payment)
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao atualizar pagamento:', error)
      throw error
    }
  }

  async markPaymentAsPaid(id: number, paymentMethod: string): Promise<DailyPayment> {
    try {
      const { data, error } = await supabase
        .from('daily_payments')
        .update({
          payment_status: 'pago',
          payment_method: paymentMethod,
          paid_at: new Date().toISOString()
        })
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao marcar pagamento como pago:', error)
      throw error
    }
  }

  async deletePayment(id: number): Promise<void> {
    try {
      const { error } = await supabase
        .from('daily_payments')
        .delete()
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Erro ao deletar pagamento:', error)
      throw error
    }
  }

  // ============================================
  // PAYMENT CALCULATIONS
  // ============================================

  async calculateDailyPayment(
    employee: Employee,
    salaryConfig: SalaryConfig,
    dailyRevenue: number,
    bonus: number = 0,
    deductions: number = 0
  ): Promise<{
    base_salary: number
    final_amount: number
    calculation_details: any
  }> {
    let base_salary = 0
    const calculation_details: any = {
      position: employee.position,
      calculation_type: salaryConfig.calculation_type,
      daily_revenue: dailyRevenue
    }

    // Calcular salário base
    if (salaryConfig.calculation_type === 'fixed') {
      base_salary = salaryConfig.fixed_daily_amount
      calculation_details.fixed_amount = salaryConfig.fixed_daily_amount
    } else if (salaryConfig.calculation_type === 'percentage') {
      // Para garçons, dividir pelos garçons ativos
      if (employee.position === 'garcom') {
        const activeGarcons = await this.getEmployeesByPosition('garcom')
        const numGarcons = activeGarcons.length || 1
        const totalPercentage = (dailyRevenue * salaryConfig.percentage_rate) / 100
        base_salary = totalPercentage / numGarcons

        calculation_details.percentage_rate = salaryConfig.percentage_rate
        calculation_details.total_percentage_amount = totalPercentage
        calculation_details.num_garcons = numGarcons
        calculation_details.per_garcom = base_salary
      } else {
        base_salary = (dailyRevenue * salaryConfig.percentage_rate) / 100
        calculation_details.percentage_rate = salaryConfig.percentage_rate
      }

      // Garantir salário mínimo
      if (base_salary < salaryConfig.min_daily_guarantee) {
        calculation_details.min_guarantee_applied = true
        calculation_details.calculated_amount = base_salary
        base_salary = salaryConfig.min_daily_guarantee
      }
    } else if (salaryConfig.calculation_type === 'mixed') {
      const percentageAmount = (dailyRevenue * salaryConfig.percentage_rate) / 100
      base_salary = Math.max(salaryConfig.fixed_daily_amount, percentageAmount)

      calculation_details.fixed_amount = salaryConfig.fixed_daily_amount
      calculation_details.percentage_rate = salaryConfig.percentage_rate
      calculation_details.percentage_amount = percentageAmount
      calculation_details.applied_amount = base_salary
    }

    // Aplicar limite máximo se configurado
    if (salaryConfig.max_daily_limit && base_salary > salaryConfig.max_daily_limit) {
      calculation_details.max_limit_applied = true
      calculation_details.calculated_amount = base_salary
      base_salary = salaryConfig.max_daily_limit
    }

    // Calcular valor final
    const final_amount = base_salary + bonus - deductions
    calculation_details.bonus = bonus
    calculation_details.deductions = deductions
    calculation_details.final_amount = final_amount

    return {
      base_salary,
      final_amount,
      calculation_details
    }
  }

  // ============================================
  // ATTENDANCE
  // ============================================

  async getAttendanceByDate(date: string): Promise<EmployeeAttendance[]> {
    try {
      const { data, error } = await supabase
        .from('employee_attendance')
        .select(`
          *,
          employee:employees (*)
        `)
        .eq('attendance_date', date)
        .order('employee_id', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar presença:', error)
      throw error
    }
  }

  async createAttendance(attendance: Omit<EmployeeAttendance, 'id' | 'created_at' | 'updated_at'>): Promise<EmployeeAttendance> {
    try {
      const { data, error } = await supabase
        .from('employee_attendance')
        .insert([attendance])
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Erro ao registrar presença:', error)
      throw error
    }
  }

  // ============================================
  // VIEWS & ANALYTICS
  // ============================================

  async getActiveEmployeesSummary(): Promise<ActiveEmployeeSummary[]> {
    try {
      const { data, error } = await supabase
        .from('vw_active_employees_summary')
        .select('*')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar resumo de funcionários ativos:', error)
      throw error
    }
  }

  async getPendingPayments(): Promise<PendingPayment[]> {
    try {
      const { data, error } = await supabase
        .from('vw_pending_payments')
        .select('*')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar pagamentos pendentes:', error)
      throw error
    }
  }

  async getMonthlyPaymentAnalysis(): Promise<MonthlyPaymentAnalysis[]> {
    try {
      const { data, error } = await supabase
        .from('vw_monthly_payment_analysis')
        .select('*')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar análise mensal:', error)
      throw error
    }
  }

  async getGarcomPerformance(): Promise<GarcomPerformance[]> {
    try {
      const { data, error } = await supabase
        .from('vw_garcom_performance')
        .select('*')

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar performance de garçons:', error)
      throw error
    }
  }

  // ============================================
  // BATCH OPERATIONS
  // ============================================

  async processDailyPayments(date: string, dailyRevenue: number): Promise<DailyPayment[]> {
    try {
      const activeEmployees = await this.getActiveEmployees()
      const payments: DailyPayment[] = []

      for (const employee of activeEmployees) {
        // Verificar se já existe pagamento para esta data
        const { data: existingPayment } = await supabase
          .from('daily_payments')
          .select('id')
          .eq('employee_id', employee.id)
          .eq('payment_date', date)
          .single()

        if (existingPayment) {
          console.log(`Pagamento já existe para ${employee.name} na data ${date}`)
          continue
        }

        const payment = await this.createPayment({
          employee_id: employee.id!,
          payment_date: date,
          daily_revenue: dailyRevenue
        })

        payments.push(payment)
      }

      return payments
    } catch (error) {
      console.error('Erro ao processar pagamentos diários:', error)
      throw error
    }
  }
}

export const employeeService = new EmployeeService()
