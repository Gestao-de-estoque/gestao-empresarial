-- =====================================================
-- SINCRONIZAÇÃO AUTOMÁTICA ENTRE FINANCIAL E EMPLOYEES
-- Execute este script para ativar a sincronização automática
-- =====================================================

-- Remove triggers antigos se existirem
DROP TRIGGER IF EXISTS trigger_sync_daily_financial_summary ON daily_financial_summary;
DROP TRIGGER IF EXISTS trigger_sync_financial_to_payments ON financial_data;

-- Remove funções antigas
DROP FUNCTION IF EXISTS sync_daily_financial_summary();
DROP FUNCTION IF EXISTS sync_financial_to_employee_payments();

-- =====================================================
-- TRIGGER 1: Sincroniza daily_financial_summary -> financial_data
-- Quando criar resumo diário, atualiza a tabela financial
-- =====================================================

CREATE OR REPLACE FUNCTION sync_daily_financial_summary_to_financial()
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

CREATE TRIGGER trigger_sync_summary_to_financial
    AFTER INSERT OR UPDATE ON daily_financial_summary
    FOR EACH ROW
    EXECUTE FUNCTION sync_daily_financial_summary_to_financial();

-- =====================================================
-- TRIGGER 2: Sincroniza financial_data -> Calcula pagamentos automaticamente
-- Quando adicionar/atualizar em financial_data, cria pagamentos para funcionários
-- =====================================================

CREATE OR REPLACE FUNCTION sync_financial_to_employee_payments()
RETURNS TRIGGER AS $$
DECLARE
    v_date DATE;
    v_employee RECORD;
    v_base_salary DECIMAL(10, 2);
    v_garcom_count INTEGER;
    v_garcom_total DECIMAL(10, 2);
BEGIN
    -- Converte DD/MM/YYYY para DATE
    BEGIN
        v_date := TO_DATE(NEW.full_day, 'DD/MM/YYYY');
    EXCEPTION WHEN OTHERS THEN
        -- Se falhar, tenta formato ISO
        v_date := NEW.full_day::DATE;
    END;

    -- Conta quantos garçons ativos existem
    SELECT COUNT(*) INTO v_garcom_count
    FROM employees
    WHERE position = 'garcom' AND status = 'ativo';

    IF v_garcom_count = 0 THEN
        v_garcom_count := 1; -- Evita divisão por zero
    END IF;

    -- Calcula o total para garçons (10% dividido)
    v_garcom_total := (NEW.total * 0.10) / v_garcom_count;

    -- Para cada funcionário ativo, cria ou atualiza o pagamento
    FOR v_employee IN
        SELECT e.id, e.name, e.position,
               COALESCE(sc.calculation_type, 'fixed') as calculation_type,
               COALESCE(sc.fixed_daily_amount, 0) as fixed_daily_amount,
               COALESCE(sc.percentage_rate, 0) as percentage_rate,
               COALESCE(sc.min_daily_guarantee, 0) as min_daily_guarantee,
               sc.max_daily_limit
        FROM employees e
        LEFT JOIN salary_configs sc ON e.position = sc.position
        WHERE e.status = 'ativo'
    LOOP
        -- Calcula o salário base conforme a configuração
        IF v_employee.calculation_type = 'fixed' THEN
            v_base_salary := v_employee.fixed_daily_amount;

        ELSIF v_employee.calculation_type = 'percentage' THEN
            IF v_employee.position = 'garcom' THEN
                v_base_salary := v_garcom_total;
            ELSE
                v_base_salary := NEW.total * (v_employee.percentage_rate / 100);
            END IF;

            -- Aplica garantia mínima
            IF v_base_salary < v_employee.min_daily_guarantee THEN
                v_base_salary := v_employee.min_daily_guarantee;
            END IF;

        ELSIF v_employee.calculation_type = 'mixed' THEN
            v_base_salary := GREATEST(
                v_employee.fixed_daily_amount,
                NEW.total * (v_employee.percentage_rate / 100)
            );

            -- Aplica garantia mínima
            IF v_base_salary < v_employee.min_daily_guarantee THEN
                v_base_salary := v_employee.min_daily_guarantee;
            END IF;
        ELSE
            v_base_salary := 0;
        END IF;

        -- Aplica limite máximo se configurado
        IF v_employee.max_daily_limit IS NOT NULL AND v_base_salary > v_employee.max_daily_limit THEN
            v_base_salary := v_employee.max_daily_limit;
        END IF;

        -- Insere ou atualiza o pagamento
        INSERT INTO daily_payments (
            employee_id,
            payment_date,
            daily_revenue,
            base_salary,
            bonus,
            deductions,
            final_amount,
            calculation_details,
            payment_status,
            created_at,
            updated_at
        ) VALUES (
            v_employee.id,
            v_date,
            NEW.total,
            v_base_salary,
            0,
            0,
            v_base_salary,
            jsonb_build_object(
                'employee_name', v_employee.name,
                'position', v_employee.position,
                'calculation_type', v_employee.calculation_type,
                'daily_revenue', NEW.total,
                'garcom_count', v_garcom_count,
                'auto_calculated', true,
                'source', 'financial_data',
                'synced_at', CURRENT_TIMESTAMP
            ),
            'pendente',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        )
        ON CONFLICT (employee_id, payment_date)
        DO UPDATE SET
            daily_revenue = EXCLUDED.daily_revenue,
            base_salary = EXCLUDED.base_salary,
            final_amount = EXCLUDED.final_amount,
            calculation_details = daily_payments.calculation_details || EXCLUDED.calculation_details,
            updated_at = CURRENT_TIMESTAMP;
    END LOOP;

    -- Atualiza ou cria o resumo diário
    INSERT INTO daily_financial_summary (
        summary_date,
        total_revenue,
        total_employee_payments,
        total_garcom_percentage,
        num_active_employees,
        num_garcom_on_duty,
        calculation_details,
        synced_with_financial_data,
        financial_data_id,
        created_at,
        updated_at
    )
    SELECT
        v_date,
        NEW.total,
        COALESCE(SUM(dp.final_amount), 0),
        NEW.amount,
        (SELECT COUNT(*) FROM employees WHERE status = 'ativo'),
        v_garcom_count,
        jsonb_build_object(
            'auto_synced', true,
            'source', 'financial_data',
            'synced_at', CURRENT_TIMESTAMP,
            'original_full_day', NEW.full_day
        ),
        true,
        NEW.id,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    FROM daily_payments dp
    WHERE dp.payment_date = v_date
    ON CONFLICT (summary_date)
    DO UPDATE SET
        total_revenue = EXCLUDED.total_revenue,
        total_employee_payments = EXCLUDED.total_employee_payments,
        total_garcom_percentage = EXCLUDED.total_garcom_percentage,
        num_active_employees = EXCLUDED.num_active_employees,
        num_garcom_on_duty = EXCLUDED.num_garcom_on_duty,
        synced_with_financial_data = true,
        financial_data_id = NEW.id,
        updated_at = CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_financial_to_payments
    AFTER INSERT OR UPDATE ON financial_data
    FOR EACH ROW
    EXECUTE FUNCTION sync_financial_to_employee_payments();

-- =====================================================
-- MENSAGEM DE SUCESSO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Sincronização automática ativada com sucesso!';
    RAISE NOTICE '📊 Agora quando você adicionar dados em /financial, os pagamentos serão calculados automaticamente em /employees';
    RAISE NOTICE '💰 E quando processar pagamentos em /employees, será sincronizado com /financial';
    RAISE NOTICE '';
    RAISE NOTICE '🔄 Para testar:';
    RAISE NOTICE '1. Adicione um registro na rota /financial';
    RAISE NOTICE '2. Vá para /employees e veja os pagamentos criados automaticamente';
END $$;

-- =====================================================
-- SCRIPT DE SINCRONIZAÇÃO RETROATIVA (OPCIONAL)
-- Execute este bloco se quiser sincronizar dados antigos
-- =====================================================

-- Descomente as linhas abaixo para sincronizar dados existentes:

/*
DO $$
DECLARE
    financial_record RECORD;
    total_synced INTEGER := 0;
BEGIN
    RAISE NOTICE '🔄 Iniciando sincronização retroativa...';

    FOR financial_record IN
        SELECT * FROM financial_data
        WHERE id NOT IN (SELECT financial_data_id FROM daily_financial_summary WHERE financial_data_id IS NOT NULL)
        ORDER BY created_at
    LOOP
        -- O trigger será executado automaticamente
        UPDATE financial_data
        SET updated_at = updated_at
        WHERE id = financial_record.id;

        total_synced := total_synced + 1;
    END LOOP;

    RAISE NOTICE '✅ Sincronização retroativa concluída: % registros processados', total_synced;
END $$;
*/
