#!/bin/bash

# ============================================================================
# Script de Execução da Migração de Isolamento de Dados por Tenant
# Data: 2025-11-26
# ============================================================================

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Configuração
# ============================================================================

SUPABASE_URL="https://cxusoclwtixtjwghjlcj.supabase.co"
DB_HOST="db.cxusoclwtixtjwghjlcj.supabase.co"
DB_PORT="5432"
DB_NAME="postgres"
DB_USER="postgres"

echo -e "${BLUE}=============================================="
echo "MIGRAÇÃO: Isolamento de Dados por Tenant"
echo "=============================================${NC}"
echo ""

# ============================================================================
# Solicitar senha do banco de dados
# ============================================================================

echo -e "${YELLOW}Por favor, forneça as credenciais do banco de dados:${NC}"
echo "Você pode encontrar a senha em:"
echo "  - Supabase Dashboard > Project Settings > Database > Password"
echo ""

read -sp "Senha do banco de dados: " DB_PASSWORD
echo ""
echo ""

# Validar conexão
echo -e "${BLUE}Testando conexão com o banco de dados...${NC}"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -c "SELECT version();" > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo -e "${RED}ERRO: Não foi possível conectar ao banco de dados.${NC}"
  echo "Verifique suas credenciais e tente novamente."
  exit 1
fi

echo -e "${GREEN}✓ Conexão estabelecida com sucesso!${NC}"
echo ""

# ============================================================================
# Fazer backup antes da migração
# ============================================================================

echo -e "${BLUE}Fazendo backup do banco de dados...${NC}"
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"

PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -F p -f $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Backup criado: $BACKUP_FILE${NC}"
else
  echo -e "${RED}ERRO: Falha ao criar backup.${NC}"
  read -p "Deseja continuar mesmo assim? (sim/não): " continue_without_backup
  if [ "$continue_without_backup" != "sim" ]; then
    echo "Migração cancelada."
    exit 1
  fi
fi
echo ""

# ============================================================================
# Verificar estado atual
# ============================================================================

echo -e "${BLUE}=============================================="
echo "PASSO 1: Verificando estado atual do banco"
echo "=============================================${NC}"
echo ""

PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -f verify_current_state.sql > verification_report_$(date +%Y%m%d_%H%M%S).txt

echo -e "${GREEN}✓ Relatório de verificação gerado${NC}"
echo ""

# Verificar se há pelo menos 1 tenant
TENANT_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -t -c "SELECT COUNT(*) FROM public.tenants;")

if [ "$TENANT_COUNT" -eq 0 ]; then
  echo -e "${RED}ERRO: Nenhum tenant encontrado no sistema.${NC}"
  echo "Por favor, crie pelo menos um tenant antes de executar esta migração."
  exit 1
fi

echo -e "${GREEN}✓ Encontrados $TENANT_COUNT tenant(s)${NC}"
echo ""

# ============================================================================
# Confirmar execução
# ============================================================================

echo -e "${YELLOW}=============================================="
echo "ATENÇÃO: Esta migração irá:"
echo "=============================================="
echo "1. Adicionar coluna tenant_id em 19 tabelas"
echo "2. Criar políticas RLS em todas as tabelas"
echo "3. Atribuir tenant_id aos dados existentes"
echo "4. Habilitar isolamento de dados por tenant"
echo ""
echo "Esta operação pode levar alguns minutos."
echo "=============================================${NC}"
echo ""

read -p "Deseja continuar com a migração? (sim/não): " confirm

if [ "$confirm" != "sim" ]; then
  echo "Migração cancelada pelo usuário."
  exit 0
fi

echo ""

# ============================================================================
# Executar migração principal
# ============================================================================

echo -e "${BLUE}=============================================="
echo "PASSO 2: Aplicando mudanças de esquema e RLS"
echo "=============================================${NC}"
echo ""

PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -f fix_tenant_isolation.sql

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Mudanças de esquema aplicadas com sucesso${NC}"
else
  echo -e "${RED}ERRO: Falha ao aplicar mudanças de esquema${NC}"
  echo "Verifique os logs acima para detalhes."
  exit 1
fi

echo ""

# ============================================================================
# Executar correção de dados
# ============================================================================

echo -e "${BLUE}=============================================="
echo "PASSO 3: Atribuindo tenant_id aos dados existentes"
echo "=============================================${NC}"
echo ""

PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -f fix_existing_data.sql > migration_log_$(date +%Y%m%d_%H%M%S).txt

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Dados migrados com sucesso${NC}"
else
  echo -e "${RED}ERRO: Falha ao migrar dados${NC}"
  echo "Verifique os logs acima para detalhes."
  exit 1
fi

echo ""

# ============================================================================
# Verificar se há registros órfãos
# ============================================================================

echo -e "${BLUE}=============================================="
echo "PASSO 4: Verificando registros órfãos"
echo "=============================================${NC}"
echo ""

ORPHAN_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT -t -c "
  SELECT COUNT(*) FROM public.produtos WHERE tenant_id IS NULL
  UNION ALL
  SELECT COUNT(*) FROM public.categorias WHERE tenant_id IS NULL
  UNION ALL
  SELECT COUNT(*) FROM public.employees WHERE tenant_id IS NULL
  UNION ALL
  SELECT COUNT(*) FROM public.menu_items WHERE tenant_id IS NULL
;" | awk '{s+=$1} END {print s}')

if [ "$ORPHAN_COUNT" -gt 0 ]; then
  echo -e "${RED}ATENÇÃO: Ainda existem $ORPHAN_COUNT registros órfãos (sem tenant_id)${NC}"
  echo "Você deve corrigir esses registros antes de ativar as constraints NOT NULL."
  echo ""
  echo "Para investigar:"
  echo "  SELECT * FROM public.produtos WHERE tenant_id IS NULL;"
  echo "  SELECT * FROM public.categorias WHERE tenant_id IS NULL;"
  echo "  SELECT * FROM public.employees WHERE tenant_id IS NULL;"
  echo ""
else
  echo -e "${GREEN}✓ Nenhum registro órfão encontrado${NC}"
  echo ""

  # ============================================================================
  # Ativar constraints NOT NULL
  # ============================================================================

  echo -e "${YELLOW}Deseja ativar as constraints NOT NULL agora? (sim/não): ${NC}"
  read activate_constraints

  if [ "$activate_constraints" = "sim" ]; then
    echo -e "${BLUE}Ativando constraints NOT NULL...${NC}"

    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT <<EOF
ALTER TABLE public.categorias ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.produtos ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.menu_items ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.menu_item_ingredientes ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.planejamento_semanal ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.menu_diario ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.movements ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.employees ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.daily_payments ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.employee_attendance ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.employee_bank_accounts ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.employee_performance_metrics ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.salary_configs ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.payment_audit_log ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.financial_data ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.daily_financial_summary ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.reports ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.app_settings ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE public.suppliers ALTER COLUMN tenant_id SET NOT NULL;
EOF

    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓ Constraints NOT NULL ativadas${NC}"
    else
      echo -e "${RED}ERRO: Falha ao ativar constraints NOT NULL${NC}"
    fi
  fi
fi

echo ""

# ============================================================================
# Finalização
# ============================================================================

echo -e "${GREEN}=============================================="
echo "✓ MIGRAÇÃO CONCLUÍDA COM SUCESSO!"
echo "=============================================${NC}"
echo ""
echo "Arquivos gerados:"
echo "  - $BACKUP_FILE (backup do banco)"
echo "  - verification_report_*.txt (relatório de verificação)"
echo "  - migration_log_*.txt (log da migração)"
echo ""
echo -e "${YELLOW}PRÓXIMOS PASSOS:${NC}"
echo "1. Revisar os logs de migração"
echo "2. Testar a aplicação com diferentes usuários/tenants"
echo "3. Verificar isolamento de dados"
echo "4. Monitorar erros de RLS nos logs"
echo ""
echo -e "${BLUE}Para reverter (se necessário):${NC}"
echo "  pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME -p $DB_PORT $BACKUP_FILE"
echo ""
echo "Migração completa!"
