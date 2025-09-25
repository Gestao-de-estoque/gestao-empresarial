# 🚀 Setup Rápido - Sistema Financeiro

## Passo 1: Criar a Tabela no Supabase

1. Acesse o painel do Supabase: https://supabase.com
2. Vá para seu projeto → **SQL Editor**
3. Execute este comando:

```sql
CREATE TABLE IF NOT EXISTS financial_data (
    id BIGSERIAL PRIMARY KEY,
    full_day VARCHAR(10) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Passo 2: Testar o Sistema

1. Execute o projeto: `npm run dev`
2. Acesse `/financial` no navegador
3. O sistema irá automaticamente:
   - Detectar que não há dados
   - Migrar os dados de exemplo
   - Carregar a interface

## ✅ Pronto!

O sistema agora deve funcionar corretamente sem loop infinito.

### Funcionalidades Disponíveis:
- ✅ Visualização de dados financeiros
- ✅ Gráficos interativos
- ✅ Insights de IA (se configurado)
- ✅ Adicionar novos registros
- ✅ Exportar dados

### Se ainda houver problemas:
1. Verifique o console do navegador (F12)
2. Confirme se a tabela foi criada no Supabase
3. Teste primeiro sem a IA (comentar as chamadas do Gemini)