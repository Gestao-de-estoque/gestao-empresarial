import { supabase, DB_TABLES } from '@/config/supabase'
import { authService } from '@/services/authService'

export async function debugSettingsTable() {
  console.log('🔍 === DEBUG CONFIGURAÇÕES ===')

  try {
    // 1. Verificar usuário autenticado
    const user = authService.getCurrentUser()
    console.log('👤 Usuário atual:', user)

    if (!user) {
      console.log('❌ Nenhum usuário autenticado')
      return
    }

    // 2. Verificar se tabela existe
    console.log('🗄️ Testando acesso à tabela app_settings...')

    const { data: tableTest, error: tableError } = await supabase
      .from('app_settings')
      .select('*')
      .limit(1)

    if (tableError) {
      console.log('❌ Erro ao acessar tabela:', tableError)
      console.log('💡 Execute o SQL: src/database/create-settings-table.sql')
      return
    }

    console.log('✅ Tabela acessível')

    // 3. Verificar configurações existentes do usuário
    const { data: userSettings, error: userError } = await supabase
      .from('app_settings')
      .select('*')
      .eq('user_id', user.id)

    if (userError) {
      console.log('❌ Erro ao buscar configurações do usuário:', userError)
    } else {
      console.log(`📊 Configurações encontradas: ${userSettings?.length || 0}`)
      if (userSettings && userSettings.length > 0) {
        console.log('📋 Seções existentes:', userSettings.map(s => s.section))
      }
    }

    // 4. Verificar formato do user_id
    console.log('🆔 Verificando user_id:')
    console.log('   - Tipo:', typeof user.id)
    console.log('   - Valor:', user.id)
    console.log('   - É UUID?', /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(user.id))

    // 5. Testar inserção
    console.log('🧪 Testando inserção...')

    const testConfig = {
      user_id: user.id,
      section: 'debug_test',
      settings: {
        test: true,
        timestamp: new Date().toISOString(),
        user_info: user.username,
        debug: true
      }
    }

    console.log('📦 Dados para inserção:', testConfig)

    const { data: insertResult, error: insertError } = await supabase
      .from('app_settings')
      .insert(testConfig)
      .select()

    if (insertError) {
      console.log('❌ Erro na inserção:', insertError)
      console.log('🔧 Possíveis soluções:')
      console.log('   1. Execute: src/database/recreate-settings-table.sql')
      console.log('   2. Verifique se o user_id existe na tabela admin_users')
      console.log('   3. Desabilite RLS na tabela')
    } else {
      console.log('✅ Inserção bem-sucedida:', insertResult)

      // Limpar teste
      await supabase
        .from('app_settings')
        .delete()
        .eq('user_id', user.id)
        .eq('section', 'debug_test')

      console.log('🧹 Dados de teste removidos')
    }

    // 6. Verificar estrutura da tabela admin_users
    console.log('👥 Verificando usuário na tabela admin_users...')

    const { data: adminUser, error: adminError } = await supabase
      .from(DB_TABLES.USERS)
      .select('id, username, email, is_active')
      .eq('id', user.id)
      .single()

    if (adminError) {
      console.log('❌ Erro ao buscar na admin_users:', adminError)
      console.log('⚠️ O user_id pode não existir na tabela admin_users')

      // Tentar buscar qualquer usuário para ver a estrutura
      console.log('🔍 Buscando estrutura da tabela admin_users...')
      const { data: sampleUsers, error: sampleError } = await supabase
        .from(DB_TABLES.USERS)
        .select('id, username')
        .limit(3)

      if (!sampleError && sampleUsers) {
        console.log('📋 Exemplos de usuários na tabela:', sampleUsers)
        console.log('🆔 Formatos de ID na tabela:', sampleUsers.map(u => ({ id: u.id, tipo: typeof u.id })))
      }
    } else {
      console.log('✅ Usuário encontrado na admin_users:', adminUser)
    }

    // 7. Verificar constraints da tabela
    console.log('🔗 Verificando constraints da tabela app_settings...')
    const { data: constraints, error: constraintsError } = await supabase
      .rpc('get_table_constraints', { table_name: 'app_settings' })

    if (!constraintsError && constraints) {
      console.log('📋 Constraints encontradas:', constraints)
    }

  } catch (error) {
    console.log('💥 Erro inesperado no debug:', error)
  }

  console.log('🔍 === FIM DEBUG ===')
}

export async function fixSettingsTable() {
  console.log('🔧 === CORREÇÃO AUTOMÁTICA ===')

  try {
    // Tentar desabilitar RLS programaticamente
    const { error: rlsError } = await supabase.rpc('disable_rls_on_settings')

    if (rlsError) {
      console.log('⚠️ Não foi possível desabilitar RLS programaticamente')
      console.log('📋 Execute manualmente no SQL Editor:')
      console.log('   ALTER TABLE app_settings DISABLE ROW LEVEL SECURITY;')
    } else {
      console.log('✅ RLS desabilitado com sucesso')
    }

  } catch (error) {
    console.log('❌ Erro na correção automática:', error)
  }
}

// Função para criar RPC que desabilita RLS (deve ser executada no SQL Editor)
export const CREATE_DISABLE_RLS_FUNCTION = `
CREATE OR REPLACE FUNCTION disable_rls_on_settings()
RETURNS TEXT AS $$
BEGIN
  EXECUTE 'ALTER TABLE app_settings DISABLE ROW LEVEL SECURITY';
  RETURN 'RLS disabled successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
`