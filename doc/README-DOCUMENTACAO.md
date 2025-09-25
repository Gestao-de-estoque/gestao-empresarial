# Manual do Usuário - GestãoZe System

## 📋 Sobre a Documentação

Este diretório contém a documentação completa do sistema **GestãoZe System**, desenvolvida especificamente para o restaurante **Pedacinho do Céu**. A documentação está escrita em LaTeX e inclui:

- ✅ Guia completo de utilização de todas as rotas
- ✅ Explicação técnica da arquitetura do sistema
- ✅ Documentação do banco de dados Supabase
- ✅ Manual de configuração e instalação
- ✅ Troubleshooting e FAQ
- ✅ Design profissional com identidade visual do restaurante

## 🎨 Características Visuais

- **Fundo azul claro suave** para melhor legibilidade
- **Capa profissional** personalizada para o restaurante Pedacinho do Céu
- **Design moderno** com elementos visuais atrativos
- **Código destacado** com sintaxe colorida
- **Caixas informativas** estilizadas com sombras
- **Paleta de cores** harmoniosa (azul, dourado, branco)

## 🔧 Como Compilar

### Requisitos

Para compilar a documentação LaTeX, você precisará ter instalado:

```bash
# Ubuntu/Debian
sudo apt-get install texlive-full
sudo apt-get install texlive-fonts-recommended
sudo apt-get install texlive-latex-extra

# macOS (com Homebrew)
brew install --cask mactex

# Windows
# Baixe e instale o MiKTeX ou TeX Live
```

### Compilação

```bash
# Navegue até o diretório da documentação
cd docs/

# Compile o documento (pode precisar executar 2-3 vezes para referências cruzadas)
pdflatex manual-usuario-gestaozesystem.tex
pdflatex manual-usuario-gestaozesystem.tex
pdflatex manual-usuario-gestaozesystem.tex
```

### Compilação Automática

Você pode usar o seguinte script para compilação automática:

```bash
#!/bin/bash
# compile-docs.sh

echo "Compilando documentação..."

# Limpar arquivos temporários anteriores
rm -f *.aux *.log *.toc *.out *.fdb_latexmk *.fls *.synctex.gz

# Compilar 3 vezes para garantir todas as referências
pdflatex -interaction=nonstopmode manual-usuario-gestaozesystem.tex
pdflatex -interaction=nonstopmode manual-usuario-gestaozesystem.tex
pdflatex -interaction=nonstopmode manual-usuario-gestaozesystem.tex

# Limpar arquivos temporários
rm -f *.aux *.log *.toc *.out *.fdb_latexmk *.fls *.synctex.gz

echo "✅ Documentação compilada: manual-usuario-gestaozesystem.pdf"
```

## 📁 Estrutura da Documentação

O manual inclui as seguintes seções principais:

1. **Introdução**
   - Visão geral do sistema
   - Tecnologias utilizadas
   - Arquitetura

2. **Configuração e Instalação**
   - Requisitos do sistema
   - Processo de instalação
   - Variáveis de ambiente

3. **Banco de Dados e Supabase**
   - Estrutura do banco
   - Políticas de segurança (RLS)
   - Configurações

4. **Sistema de Rotas**
   - Configuração do Vue Router
   - Guards de navegação
   - Estrutura de rotas

5. **Guia de Utilização das Rotas**
   - `/login` - Autenticação
   - `/dashboard` - Painel principal
   - `/inventory` - Gestão de estoque
   - `/suppliers` - Fornecedores
   - `/menu` - Gestão de cardápio
   - `/reports` - Relatórios avançados
   - `/ai` - Inteligência artificial
   - `/logs` - Auditoria
   - `/settings` - Configurações
   - `/profile` - Perfil do usuário

6. **Arquitetura de Serviços**
   - Camada de serviços
   - Integração com Supabase
   - Padrões de implementação

7. **Funcionalidades Avançadas**
   - Analytics avançado
   - Inteligência artificial
   - Relatórios personalizados
   - Visualizações

8. **Segurança e Performance**
   - Medidas de segurança
   - Otimizações
   - Monitoramento

9. **Deployment e Manutenção**
   - Processo de build
   - Deploy em produção
   - Backup e recuperação

10. **Troubleshooting e FAQ**
    - Problemas comuns
    - Comandos de diagnóstico
    - Perguntas frequentes

11. **API e Integrações**
    - Endpoints Supabase
    - Integrações externas
    - Webhooks

## 🎯 Público Alvo

Esta documentação é destinada a:

- **Desenvolvedores** que precisam entender a arquitetura
- **Administradores** que vão configurar o sistema
- **Usuários finais** que vão operar o sistema
- **Equipe técnica** responsável pela manutenção

## 📞 Suporte

Para dúvidas sobre a documentação ou sistema:

- 📧 Email: suporte@gestaozesystem.com
- 💬 Issues: [GitHub Repository Issues](https://github.com/estevam5s/gestao-estoque-vue/issues)
- 📖 Wiki: [Documentação Online](https://docs.gestaozesystem.com)

## 📄 Licença

Esta documentação está licenciada sob a mesma licença do projeto principal.

---

**GestãoZe System v1.0.0** - Sistema de Gestão de Estoque Inteligente
Desenvolvido especificamente para o Restaurante Pedacinho do Céu