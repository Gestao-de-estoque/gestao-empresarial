Esta criando varios admins para o sistema.

Tem que melhorar na estrutura completa do sql, pois quando cria varios usuarios, cada usuario tem acesso a todos os dados dos outros usuarios. Qualquer usuario criado consegue ver todos os dados.

Sugestão de melhoria:
Cada usuario criado na rota "/register", e logado no sistema, nao vai ter acesso aos dados dos outros usuarios.
Cada usuario so vai ter acesso aos dados que ele mesmo criou.
Essas dados sao:
Criar funcionarios (rota /employees), adicionar produtos no menu (rota /menu), adiconar registros financeiros (rota /financial), adicionar novos produtos no estoque (rota /inventory), adicionar fornecedores (rota /suppliers).
Para implementar essa funcionalidade, você precisará fazer algumas alterações na estrutura do banco de dados e nas consultas SQL que você está utilizando.

Deve analisar a estrutura completa das tabelas do banco que estao no arquivo src/sql/scheme.sql

Resumindo:
* Cada usuario criado no banco de dados deve ter apenas os seus dados no dashboard (banco de dados tambem) e nao pode acessar, consultar, editar ou deletar os dados dos outros usuarios das rotas mencionadas acima.

Tem que melhorar as politicas de acesso dos usuarios no sistema. Para que ninguem consiga acessar os dados dos outros usuarios.

Deve ver no supabase quais sao as politicas de acesso que estao criadas atualmente e melhorar elas. Todas as politicas das tabelas estao no arquivo politicas.json

Deve organizar tambem os erros para cada rota (/inventory, /financial, /employees, /suppliers, /menu)

Erro na rota /inventory:
POST https://cxusoclwtixtjwghjlcj.supabase.co/rest/v1/produtos?columns=%22nome%22%2C%22preco%22%2C%22custo%22%2C%22current_stock%22%2C%22min_stock%22%2C%22unidade%22%2C%22categoria_id%22%2C%22descricao%22%2C%22codigo_barras%22%2C%22estoque_atual%22%2C%22estoque_minimo%22%2C%22ativo%22%2C%22created_by%22%2C%22updated_at%22%2C%22created_at%22 400 (Bad Request)
Erro ao salvar produto: {code: '22P02', details: null, hint: null, message: 'invalid input syntax for type uuid: ""'}

Erro na rota /financial:
POST https://cxusoclwtixtjwghjlcj.supabase.co/rest/v1/financial_data?columns=%22full_day%22%2C%22total%22%2C%22amount%22&select=* 400 (Bad Request)
Erro ao adicionar registro financeiro: {code: 'P0001', details: null, hint: null, message: 'Usuário não está associado a nenhum tenant. Faça logout e login novamente.'}
Erro ao salvar registro: {code: 'P0001', details: null, hint: null, message: 'Usuário não está associado a nenhum tenant. Faça logout e login novamente.'}

Erro na rota /employees:
POST https://cxusoclwtixtjwghjlcj.supabase.co/rest/v1/employees?columns=%22name%22%2C%22email%22%2C%22phone%22%2C%22photo_url%22%2C%22position%22%2C%22hire_date%22%2C%22status%22&select=* 400 (Bad Request)
Erro ao criar funcionário: {code: 'P0001', details: null, hint: null, message: 'Usuário não está associado a nenhum tenant. Faça logout e login novamente.'}

Erro na rota /suppliers:
POST https://cxusoclwtixtjwghjlcj.supabase.co/rest/v1/suppliers?columns=%22name%22%2C%22contact%22%2C%22phone%22%2C%22email%22%2C%22address%22%2C%22category%22%2C%22status%22%2C%22products_count%22&select=* 400 (Bad Request)
Erro ao criar fornecedor: {code: 'P0001', details: null, hint: null, message: 'Usuário não está associado a nenhum tenant. Faça logout e login novamente.'}
Erro ao criar fornecedor: Error: Não foi possível criar o fornecedor
    at SuppliersService.createSupplier (suppliersService.ts:86:15)
    at async saveSupplier (SuppliersView.vue:466:7)

Erro na rota /menu:
POST https://cxusoclwtixtjwghjlcj.supabase.co/rest/v1/menu_items?columns=%22nome%22%2C%22descricao%22%2C%22categoria_id%22%2C%22preco_venda%22%2C%22custo_ingredientes%22%2C%22tempo_preparo%22%2C%22dificuldade%22%2C%22porcoes%22%2C%22score_popularidade%22%2C%22disponivel%22%2C%22destaque%22%2C%22calorias%22%2C%22proteina_g%22%2C%22carboidratos_g%22%2C%22gordura_g%22%2C%22tags%22%2C%22ativo%22%2C%22criado_por%22%2C%22updated_at%22%2C%22created_at%22 400 (Bad Request)
Erro ao salvar item: {code: '22P02', details: null, hint: null, message: 'invalid input syntax for type uuid: ""'}

Deve corrigir todos esses erros nas rotas mencionadas acima. Deve corrigir os erros de permissão de acesso dos usuarios no sistema.
Deve garantir que cada usuario so consiga acessar os dados que ele mesmo criou. Ninguem deve conseguir acessar os dados dos outros usuarios.