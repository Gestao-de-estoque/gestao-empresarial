-- =====================================================
-- Sistema de Gestão de Funcionários e Pagamentos
-- Database Schema para Gestão de Estoque
-- =====================================================

-- Tabela de Funcionários
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    photo_url TEXT,
    position VARCHAR(50) NOT NULL CHECK (position IN ('garcom', 'balconista', 'barmen', 'cozinheiro', 'cozinheiro_chef')),
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'ferias', 'afastado')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para performance
CREATE INDEX idx_employees_position ON employees(position);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_email ON employees(email);

-- Tabela de Bancos Suportados
CREATE TABLE IF NOT EXISTS banks (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    icon_url TEXT,
    color VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Inserir bancos principais
INSERT INTO banks (code, name, icon_url, color) VALUES
('260', 'Nubank', '/icons/banks/nubank.svg', '#8A05BE'),
('655', 'Neon', '/icons/banks/neon.svg', '#00D964'),
('102', 'XP Investimentos', '/icons/banks/xp.svg', '#000000'),
('208', 'BTG Pactual', '/icons/banks/btg.svg', '#0C2461'),
('323', 'PicPay', '/icons/banks/picpay.svg', '#21C25E'),
('323', 'Mercado Pago', '/icons/banks/mercadopago.svg', '#00AAFF'),
('077', 'Banco Inter', '/icons/banks/inter.svg', '#FF7A00'),
('001', 'Banco do Brasil', '/icons/banks/bb.svg', '#FFED00'),
('104', 'Caixa Econômica', '/icons/banks/caixa.svg', '#0D5CA8'),
('341', 'Itaú', '/icons/banks/itau.svg', '#EC7000'),
('033', 'Santander', '/icons/banks/santander.svg', '#EC0000'),
('237', 'Bradesco', '/icons/banks/bradesco.svg', '#CC092F')
ON CONFLICT (code) DO NOTHING;

-- Tabela de Dados Bancários dos Funcionários
CREATE TABLE IF NOT EXISTS employee_bank_accounts (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    bank_id INTEGER NOT NULL REFERENCES banks(id) ON DELETE RESTRICT,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('corrente', 'poupanca', 'salario')),
    agency VARCHAR(10) NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    account_digit VARCHAR(2),
    pix_key_type VARCHAR(20) CHECK (pix_key_type IN ('cpf', 'email', 'telefone', 'chave_aleatoria', 'qrcode')),
    pix_key VARCHAR(255),
    qr_code_pix TEXT,
    is_primary BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, bank_id, agency, account_number)
);

-- Índices para performance
CREATE INDEX idx_employee_bank_accounts_employee ON employee_bank_accounts(employee_id);
CREATE INDEX idx_employee_bank_accounts_bank ON employee_bank_accounts(bank_id);

-- Tabela de Configurações de Salário por Função
CREATE TABLE IF NOT EXISTS salary_configs (
    id SERIAL PRIMARY KEY,
    position VARCHAR(50) NOT NULL UNIQUE CHECK (position IN ('garcom', 'balconista', 'barmen', 'cozinheiro', 'cozinheiro_chef')),
    calculation_type VARCHAR(20) NOT NULL CHECK (calculation_type IN ('percentage', 'fixed', 'mixed')),
    fixed_daily_amount DECIMAL(10, 2) DEFAULT 0.00,
    percentage_rate DECIMAL(5, 2) DEFAULT 0.00,
    min_daily_guarantee DECIMAL(10, 2) DEFAULT 0.00,
    max_daily_limit DECIMAL(10, 2),
    description TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Configurações padrão de salário
INSERT INTO salary_configs (position, calculation_type, fixed_daily_amount, percentage_rate, min_daily_guarantee, description) VALUES
('garcom', 'percentage', 0.00, 10.00, 0.00, 'Garçons recebem 10% do movimento diário dividido entre todos os garçons ativos'),
('balconista', 'percentage', 0.00, 5.00, 80.00, 'Balconistas recebem 5% do movimento ou R$ 80,00, o que for maior'),
('barmen', 'fixed', 120.00, 0.00, 120.00, 'Barmen recebem salário fixo diário de R$ 120,00'),
('cozinheiro', 'fixed', 150.00, 0.00, 150.00, 'Cozinheiros recebem salário fixo diário de R$ 150,00'),
('cozinheiro_chef', 'fixed', 250.00, 0.00, 250.00, 'Cozinheiro Chef recebe salário fixo diário de R$ 250,00')
ON CONFLICT (position) DO NOTHING;

-- Tabela de Pagamentos Diários
CREATE TABLE IF NOT EXISTS daily_payments (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    daily_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    base_salary DECIMAL(10, 2) NOT NULL,
    bonus DECIMAL(10, 2) DEFAULT 0.00,
    deductions DECIMAL(10, 2) DEFAULT 0.00,
    final_amount DECIMAL(10, 2) NOT NULL,
    calculation_details JSONB,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (payment_status IN ('pendente', 'processando', 'pago', 'cancelado')),
    payment_method VARCHAR(20) CHECK (payment_method IN ('pix', 'transferencia', 'dinheiro', 'cheque')),
    paid_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, payment_date)
);

-- Índices para performance
CREATE INDEX idx_daily_payments_employee ON daily_payments(employee_id);
CREATE INDEX idx_daily_payments_date ON daily_payments(payment_date);
CREATE INDEX idx_daily_payments_status ON daily_payments(payment_status);
CREATE INDEX idx_daily_payments_date_status ON daily_payments(payment_date, payment_status);

-- Tabela de Histórico de Movimentação Financeira (integração com financial_data)
CREATE TABLE IF NOT EXISTS daily_financial_summary (
    id SERIAL PRIMARY KEY,
    summary_date DATE NOT NULL UNIQUE,
    total_revenue DECIMAL(12, 2) NOT NULL,
    total_employee_payments DECIMAL(12, 2) NOT NULL,
    total_garcom_percentage DECIMAL(12, 2) NOT NULL,
    num_active_employees INTEGER NOT NULL DEFAULT 0,
    num_garcom_on_duty INTEGER NOT NULL DEFAULT 0,
    calculation_details JSONB,
    synced_with_financial_data BOOLEAN DEFAULT false,
    financial_data_id INTEGER REFERENCES financial_data(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índice para performance
CREATE INDEX idx_daily_financial_summary_date ON daily_financial_summary(summary_date);
CREATE INDEX idx_daily_financial_summary_synced ON daily_financial_summary(synced_with_financial_data);

-- Tabela de Pontos de Trabalho (para controle de presença)
CREATE TABLE IF NOT EXISTS employee_attendance (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    check_in TIME,
    check_out TIME,
    hours_worked DECIMAL(5, 2),
    status VARCHAR(20) NOT NULL DEFAULT 'presente' CHECK (status IN ('presente', 'ausente', 'falta', 'ferias', 'folga', 'atestado')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, attendance_date)
);

-- Índices para performance
CREATE INDEX idx_employee_attendance_employee ON employee_attendance(employee_id);
CREATE INDEX idx_employee_attendance_date ON employee_attendance(attendance_date);
CREATE INDEX idx_employee_attendance_status ON employee_attendance(status);

-- Tabela de Métricas de Performance do Funcionário
CREATE TABLE IF NOT EXISTS employee_performance_metrics (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    metric_date DATE NOT NULL,
    total_earnings DECIMAL(12, 2) DEFAULT 0.00,
    days_worked INTEGER DEFAULT 0,
    average_daily_earnings DECIMAL(10, 2) DEFAULT 0.00,
    total_bonus DECIMAL(10, 2) DEFAULT 0.00,
    total_deductions DECIMAL(10, 2) DEFAULT 0.00,
    performance_score DECIMAL(5, 2),
    metrics_details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, metric_date)
);

-- Índices para performance
CREATE INDEX idx_employee_performance_employee ON employee_performance_metrics(employee_id);
CREATE INDEX idx_employee_performance_date ON employee_performance_metrics(metric_date);

-- Tabela de Auditoria de Pagamentos
CREATE TABLE IF NOT EXISTS payment_audit_log (
    id SERIAL PRIMARY KEY,
    payment_id INTEGER REFERENCES daily_payments(id) ON DELETE SET NULL,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    changed_by INTEGER REFERENCES admin_users(id),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índice para auditoria
CREATE INDEX idx_payment_audit_log_payment ON payment_audit_log(payment_id);
CREATE INDEX idx_payment_audit_log_employee ON payment_audit_log(employee_id);
CREATE INDEX idx_payment_audit_log_date ON payment_audit_log(created_at);

-- Triggers para atualização automática de timestamps

-- Trigger para employees
CREATE OR REPLACE FUNCTION update_employees_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_employees_updated_at
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION update_employees_updated_at();

-- Trigger para employee_bank_accounts
CREATE OR REPLACE FUNCTION update_employee_bank_accounts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_employee_bank_accounts_updated_at
    BEFORE UPDATE ON employee_bank_accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_employee_bank_accounts_updated_at();

-- Trigger para daily_payments
CREATE OR REPLACE FUNCTION update_daily_payments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_daily_payments_updated_at
    BEFORE UPDATE ON daily_payments
    FOR EACH ROW
    EXECUTE FUNCTION update_daily_payments_updated_at();

-- Trigger para salary_configs
CREATE OR REPLACE FUNCTION update_salary_configs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_salary_configs_updated_at
    BEFORE UPDATE ON salary_configs
    FOR EACH ROW
    EXECUTE FUNCTION update_salary_configs_updated_at();

-- Trigger para sincronização com financial_data
CREATE OR REPLACE FUNCTION sync_daily_financial_summary()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza ou cria registro em financial_data
    INSERT INTO financial_data (full_day, amount, total, created_at, updated_at)
    VALUES (
        TO_CHAR(NEW.summary_date, 'DD/MM/YYYY'),
        NEW.total_garcom_percentage,
        NEW.total_revenue,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (full_day)
    DO UPDATE SET
        amount = EXCLUDED.amount,
        total = EXCLUDED.total,
        updated_at = CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_daily_financial_summary
    AFTER INSERT OR UPDATE ON daily_financial_summary
    FOR EACH ROW
    EXECUTE FUNCTION sync_daily_financial_summary();

-- Views úteis para relatórios

-- View de Resumo de Funcionários Ativos
CREATE OR REPLACE VIEW vw_active_employees_summary AS
SELECT
    e.id,
    e.name,
    e.email,
    e.position,
    sc.calculation_type,
    sc.fixed_daily_amount,
    sc.percentage_rate,
    COUNT(DISTINCT dp.id) as total_payments,
    COALESCE(SUM(dp.final_amount), 0) as total_earned,
    COALESCE(AVG(dp.final_amount), 0) as average_daily_earning
FROM employees e
LEFT JOIN salary_configs sc ON e.position = sc.position
LEFT JOIN daily_payments dp ON e.id = dp.employee_id
    AND dp.payment_status = 'pago'
WHERE e.status = 'ativo'
GROUP BY e.id, e.name, e.email, e.position, sc.calculation_type, sc.fixed_daily_amount, sc.percentage_rate;

-- View de Pagamentos Pendentes
CREATE OR REPLACE VIEW vw_pending_payments AS
SELECT
    dp.id,
    dp.employee_id,
    e.name as employee_name,
    e.position,
    dp.payment_date,
    dp.final_amount,
    dp.payment_status,
    dp.created_at
FROM daily_payments dp
INNER JOIN employees e ON dp.employee_id = e.id
WHERE dp.payment_status IN ('pendente', 'processando')
ORDER BY dp.payment_date DESC;

-- View de Análise Mensal de Pagamentos
CREATE OR REPLACE VIEW vw_monthly_payment_analysis AS
SELECT
    DATE_TRUNC('month', dp.payment_date) as month,
    e.position,
    COUNT(DISTINCT e.id) as num_employees,
    COUNT(dp.id) as total_payments,
    SUM(dp.final_amount) as total_amount,
    AVG(dp.final_amount) as average_payment,
    SUM(dp.daily_revenue) as total_revenue
FROM daily_payments dp
INNER JOIN employees e ON dp.employee_id = e.id
WHERE dp.payment_status = 'pago'
GROUP BY DATE_TRUNC('month', dp.payment_date), e.position
ORDER BY month DESC, e.position;

-- View de Performance de Garçons (para dashboard)
CREATE OR REPLACE VIEW vw_garcom_performance AS
SELECT
    e.id,
    e.name,
    e.photo_url,
    COUNT(DISTINCT dp.payment_date) as days_worked_this_month,
    COALESCE(SUM(dp.final_amount), 0) as total_earned_this_month,
    COALESCE(AVG(dp.final_amount), 0) as average_daily_earning,
    COALESCE(MAX(dp.final_amount), 0) as best_day_earning,
    COALESCE(MIN(dp.final_amount), 0) as worst_day_earning
FROM employees e
LEFT JOIN daily_payments dp ON e.id = dp.employee_id
    AND dp.payment_status = 'pago'
    AND DATE_TRUNC('month', dp.payment_date) = DATE_TRUNC('month', CURRENT_DATE)
WHERE e.position = 'garcom'
    AND e.status = 'ativo'
GROUP BY e.id, e.name, e.photo_url
ORDER BY total_earned_this_month DESC;

-- Comentários nas tabelas
COMMENT ON TABLE employees IS 'Cadastro de funcionários do estabelecimento';
COMMENT ON TABLE banks IS 'Lista de bancos suportados para pagamentos';
COMMENT ON TABLE employee_bank_accounts IS 'Dados bancários dos funcionários para pagamentos';
COMMENT ON TABLE salary_configs IS 'Configurações de cálculo de salário por função';
COMMENT ON TABLE daily_payments IS 'Registro de pagamentos diários realizados aos funcionários';
COMMENT ON TABLE daily_financial_summary IS 'Resumo financeiro diário integrado com a tabela financial_data';
COMMENT ON TABLE employee_attendance IS 'Controle de presença e horas trabalhadas dos funcionários';
COMMENT ON TABLE employee_performance_metrics IS 'Métricas de performance e produtividade dos funcionários';
COMMENT ON TABLE payment_audit_log IS 'Log de auditoria de todas as alterações em pagamentos';

-- Grants (ajustar conforme necessário)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO seu_usuario_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO seu_usuario_app;
