<template>
  <div class="legal-container">
    <header class="page-header">
      <div class="header-content">
        <h1>
          <FileText :size="28" />
          Termos de Uso
        </h1>
        <div class="last-updated">
          Última atualização: {{ lastUpdated }}
        </div>
      </div>
    </header>

    <div class="legal-content">
      <!-- Navegação -->
      <nav class="legal-nav">
        <h3>Índice</h3>
        <ul>
          <li><a href="#aceitacao">1. Aceitação dos Termos</a></li>
          <li><a href="#definicoes">2. Definições</a></li>
          <li><a href="#servicos">3. Descrição dos Serviços</a></li>
          <li><a href="#uso">4. Uso Permitido</a></li>
          <li><a href="#conta">5. Conta de Usuário</a></li>
          <li><a href="#responsabilidades">6. Responsabilidades</a></li>
          <li><a href="#propriedade">7. Propriedade Intelectual</a></li>
          <li><a href="#privacidade">8. Privacidade e Dados</a></li>
          <li><a href="#limitacoes">9. Limitações de Responsabilidade</a></li>
          <li><a href="#modificacoes">10. Modificações</a></li>
          <li><a href="#rescisao">11. Rescisão</a></li>
          <li><a href="#lei">12. Lei Aplicável</a></li>
          <li><a href="#contato">13. Contato</a></li>
        </ul>
      </nav>

      <!-- Conteúdo Principal -->
      <main class="legal-main">
        <div class="intro-section">
          <div class="warning-box">
            <AlertTriangle :size="20" />
            <div>
              <strong>Importante:</strong> Leia estes termos cuidadosamente antes de usar o sistema.
              Ao acessar ou usar nossos serviços, você concorda com estes termos.
            </div>
          </div>
        </div>

        <section id="aceitacao" class="legal-section">
          <h2>1. Aceitação dos Termos</h2>
          <p>
            Ao acessar, usar ou instalar o Sistema de Gestão GestãoZe ("Sistema"), você ("Usuário")
            concorda em estar vinculado por estes Termos de Uso ("Termos"). Se você não concordar
            com estes termos, não use o Sistema.
          </p>
          <p>
            Estes termos constituem um acordo legal entre você e a GestãoZe System ("Empresa", "nós", "nosso").
          </p>
        </section>

        <section id="definicoes" class="legal-section">
          <h2>2. Definições</h2>
          <div class="definitions">
            <div class="definition-item">
              <strong>"Sistema":</strong> O software GestãoZe System, incluindo aplicativos web, mobile
              e todas as funcionalidades relacionadas.
            </div>
            <div class="definition-item">
              <strong>"Usuário":</strong> Qualquer pessoa física ou jurídica que acesse ou use o Sistema.
            </div>
            <div class="definition-item">
              <strong>"Dados":</strong> Informações inseridas, processadas ou armazenadas no Sistema pelo Usuário.
            </div>
            <div class="definition-item">
              <strong>"Conta":</strong> Conta de acesso criada pelo Usuário para usar o Sistema.
            </div>
          </div>
        </section>

        <section id="servicos" class="legal-section">
          <h2>3. Descrição dos Serviços</h2>
          <p>
            O GestãoZe System é uma plataforma de gestão empresarial que oferece:
          </p>
          <ul>
            <li>Controle de estoque e inventário</li>
            <li>Gestão de produtos e cardápios</li>
            <li>Relatórios e análises financeiras</li>
            <li>Sistema de usuários e permissões</li>
            <li>APIs para integração</li>
            <li>Backup e segurança de dados</li>
            <li>Suporte técnico</li>
          </ul>
        </section>

        <section id="uso" class="legal-section">
          <h2>4. Uso Permitido</h2>
          <div class="usage-rules">
            <div class="allowed">
              <h3><CheckCircle :size="20" /> Uso Permitido</h3>
              <ul>
                <li>Uso comercial para gestão empresarial</li>
                <li>Acesso por funcionários autorizados</li>
                <li>Integração com sistemas próprios via API</li>
                <li>Personalização de configurações</li>
              </ul>
            </div>
            <div class="prohibited">
              <h3><XCircle :size="20" /> Uso Proibido</h3>
              <ul>
                <li>Revenda ou redistribuição do software</li>
                <li>Engenharia reversa ou tentativa de cópia</li>
                <li>Uso para atividades ilegais</li>
                <li>Sobrecarga intencional dos servidores</li>
                <li>Tentativas de acesso não autorizado</li>
              </ul>
            </div>
          </div>
        </section>

        <section id="conta" class="legal-section">
          <h2>5. Conta de Usuário</h2>
          <p>
            Para usar o Sistema, você deve criar uma conta fornecendo informações precisas e atualizadas.
            Você é responsável por:
          </p>
          <ul>
            <li>Manter a confidencialidade das credenciais de acesso</li>
            <li>Notificar imediatamente sobre uso não autorizado</li>
            <li>Garantir que apenas usuários autorizados acessem sua conta</li>
            <li>Manter informações de contato atualizadas</li>
          </ul>
        </section>

        <section id="responsabilidades" class="legal-section">
          <h2>6. Responsabilidades</h2>

          <h3>6.1 Responsabilidades do Usuário</h3>
          <ul>
            <li>Uso adequado e legal do Sistema</li>
            <li>Backup regular de dados importantes</li>
            <li>Segurança das credenciais de acesso</li>
            <li>Pagamento de taxas aplicáveis</li>
            <li>Conformidade com leis locais</li>
          </ul>

          <h3>6.2 Responsabilidades da Empresa</h3>
          <ul>
            <li>Manutenção da disponibilidade do Sistema</li>
            <li>Segurança dos dados armazenados</li>
            <li>Suporte técnico adequado</li>
            <li>Cumprimento da legislação de proteção de dados</li>
          </ul>
        </section>

        <section id="propriedade" class="legal-section">
          <h2>7. Propriedade Intelectual</h2>
          <p>
            Todos os direitos de propriedade intelectual sobre o Sistema pertencem à GestãoZe System.
            Isso inclui, mas não se limita a:
          </p>
          <ul>
            <li>Código fonte e algoritmos</li>
            <li>Interface e design</li>
            <li>Documentação e manuais</li>
            <li>Marcas e logotipos</li>
          </ul>
          <p>
            Os dados inseridos pelo Usuário permanecem de propriedade do Usuário.
          </p>
        </section>

        <section id="privacidade" class="legal-section">
          <h2>8. Privacidade e Dados</h2>
          <p>
            O tratamento de dados pessoais é regido por nossa
            <router-link to="/legal/privacy" class="link">Política de Privacidade</router-link>
            e está em conformidade com a LGPD (Lei Geral de Proteção de Dados).
          </p>
          <div class="data-commitment">
            <Shield :size="24" />
            <div>
              <strong>Compromisso com a Segurança:</strong>
              Utilizamos medidas técnicas e organizacionais adequadas para proteger seus dados
              contra acesso não autorizado, alteração, divulgação ou destruição.
            </div>
          </div>
        </section>

        <section id="limitacoes" class="legal-section">
          <h2>9. Limitações de Responsabilidade</h2>
          <p>
            O Sistema é fornecido "como está". A empresa não se responsabiliza por:
          </p>
          <ul>
            <li>Perdas de dados por mau uso ou falha do usuário</li>
            <li>Interrupções temporárias do serviço</li>
            <li>Decisões comerciais baseadas nos relatórios</li>
            <li>Incompatibilidade com sistemas de terceiros</li>
          </ul>
          <div class="liability-limit">
            <AlertCircle :size="20" />
            <span>A responsabilidade máxima da empresa está limitada ao valor pago pelos serviços nos últimos 12 meses.</span>
          </div>
        </section>

        <section id="modificacoes" class="legal-section">
          <h2>10. Modificações</h2>
          <p>
            Reservamos o direito de modificar estes termos a qualquer momento.
            Mudanças significativas serão comunicadas com pelo menos 30 dias de antecedência.
          </p>
          <p>
            O uso continuado do Sistema após a publicação das alterações constitui aceitação dos novos termos.
          </p>
        </section>

        <section id="rescisao" class="legal-section">
          <h2>11. Rescisão</h2>
          <p>
            Este acordo pode ser rescindido:
          </p>
          <ul>
            <li>Por qualquer das partes com aviso prévio de 30 dias</li>
            <li>Imediatamente em caso de violação dos termos</li>
            <li>Por não pagamento de taxas devidas</li>
          </ul>
          <p>
            Após a rescisão, o acesso ao Sistema será suspenso e os dados poderão ser excluídos
            após período de retenção conforme política de dados.
          </p>
        </section>

        <section id="lei" class="legal-section">
          <h2>12. Lei Aplicável</h2>
          <p>
            Estes termos são regidos pelas leis da República Federativa do Brasil.
            Qualquer disputa será resolvida no foro da comarca de Florianópolis/SC.
          </p>
        </section>

        <section id="contato" class="legal-section">
          <h2>13. Contato</h2>
          <div class="contact-info">
            <div class="contact-item">
              <Mail :size="16" />
              <span>legal@gestaozesystem.com</span>
            </div>
            <div class="contact-item">
              <Phone :size="16" />
              <span>(48) 0000-0000</span>
            </div>
            <div class="contact-item">
              <MapPin :size="16" />
              <span>Florianópolis - SC, Brasil</span>
            </div>
          </div>
          <p>
            Para questões relacionadas a estes termos, entre em contato através dos canais acima.
          </p>
        </section>

        <div class="legal-footer">
          <div class="signature">
            <Calendar :size="16" />
            <span>Documento válido a partir de {{ lastUpdated }}</span>
          </div>
          <div class="version">
            <FileText :size="16" />
            <span>Versão 1.0</span>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  FileText, AlertTriangle, CheckCircle, XCircle, Shield,
  AlertCircle, Mail, Phone, MapPin, Calendar
} from 'lucide-vue-next'

const lastUpdated = '26 de setembro de 2025'
</script>

<style scoped>
/* Estilos base importados */
@import '@/styles/legal.css';
</style>