<template>
  <div class="legal-container">
    <header class="page-header">
      <div class="header-content">
        <h1>
          <Shield :size="28" />
          Política de Privacidade
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
          <li><a href="#introducao">1. Introdução</a></li>
          <li><a href="#dados-coletados">2. Dados Coletados</a></li>
          <li><a href="#como-usamos">3. Como Usamos os Dados</a></li>
          <li><a href="#compartilhamento">4. Compartilhamento</a></li>
          <li><a href="#seguranca">5. Segurança</a></li>
          <li><a href="#retencao">6. Retenção de Dados</a></li>
          <li><a href="#direitos">7. Seus Direitos</a></li>
          <li><a href="#cookies">8. Cookies e Tecnologias</a></li>
          <li><a href="#menores">9. Menores de Idade</a></li>
          <li><a href="#internacional">10. Transferências Internacionais</a></li>
          <li><a href="#alteracoes">11. Alterações</a></li>
          <li><a href="#contato">12. Contato</a></li>
        </ul>
      </nav>

      <!-- Conteúdo Principal -->
      <main class="legal-main">
        <div class="intro-section">
          <div class="privacy-commitment">
            <Shield :size="24" />
            <div>
              <strong>Compromisso com sua Privacidade:</strong>
              Sua privacidade é fundamental para nós. Esta política explica como coletamos,
              usamos e protegemos suas informações pessoais.
            </div>
          </div>
        </div>

        <section id="introducao" class="legal-section">
          <h2>1. Introdução</h2>
          <p>
            Esta Política de Privacidade descreve como a GestãoZe System ("nós", "nosso", "empresa")
            coleta, usa, armazena e protege informações pessoais quando você usa nosso sistema
            de gestão empresarial.
          </p>
          <p>
            Estamos comprometidos com a proteção de sua privacidade e cumprimos integralmente
            a Lei Geral de Proteção de Dados (LGPD - Lei 13.709/2018) e demais regulamentações aplicáveis.
          </p>
          <div class="lgpd-badge">
            <Check :size="16" />
            <span>Conforme LGPD (Lei 13.709/2018)</span>
          </div>
        </section>

        <section id="dados-coletados" class="legal-section">
          <h2>2. Dados Coletados</h2>

          <h3>2.1 Dados Fornecidos por Você</h3>
          <div class="data-categories">
            <div class="data-category">
              <User :size="20" />
              <div>
                <strong>Dados de Cadastro:</strong>
                <ul>
                  <li>Nome completo</li>
                  <li>E-mail</li>
                  <li>Telefone</li>
                  <li>Cargo/função</li>
                  <li>Empresa/estabelecimento</li>
                </ul>
              </div>
            </div>

            <div class="data-category">
              <Building :size="20" />
              <div>
                <strong>Dados Empresariais:</strong>
                <ul>
                  <li>Razão social</li>
                  <li>CNPJ</li>
                  <li>Endereço comercial</li>
                  <li>Dados fiscais</li>
                  <li>Informações de produtos e estoque</li>
                </ul>
              </div>
            </div>

            <div class="data-category">
              <CreditCard :size="20" />
              <div>
                <strong>Dados Financeiros:</strong>
                <ul>
                  <li>Informações de cobrança</li>
                  <li>Histórico de pagamentos</li>
                  <li>Dados bancários (quando aplicável)</li>
                </ul>
              </div>
            </div>
          </div>

          <h3>2.2 Dados Coletados Automaticamente</h3>
          <div class="auto-data">
            <div class="auto-item">
              <Monitor :size="16" />
              <span><strong>Dados Técnicos:</strong> Endereço IP, tipo de dispositivo, navegador, sistema operacional</span>
            </div>
            <div class="auto-item">
              <Activity :size="16" />
              <span><strong>Dados de Uso:</strong> Páginas visitadas, tempo de sessão, funcionalidades utilizadas</span>
            </div>
            <div class="auto-item">
              <MapPin :size="16" />
              <span><strong>Dados de Localização:</strong> Localização aproximada baseada no IP (apenas para segurança)</span>
            </div>
          </div>
        </section>

        <section id="como-usamos" class="legal-section">
          <h2>3. Como Usamos os Dados</h2>
          <p>Utilizamos suas informações pessoais para:</p>

          <div class="usage-purposes">
            <div class="purpose-item">
              <Settings :size="20" />
              <div>
                <strong>Operação do Serviço</strong>
                <p>Fornecer, manter e melhorar funcionalidades do sistema</p>
              </div>
            </div>

            <div class="purpose-item">
              <LifeBuoy :size="20" />
              <div>
                <strong>Suporte Técnico</strong>
                <p>Oferecer assistência técnica e resolver problemas</p>
              </div>
            </div>

            <div class="purpose-item">
              <Bell :size="20" />
              <div>
                <strong>Comunicação</strong>
                <p>Enviar notificações importantes sobre o serviço</p>
              </div>
            </div>

            <div class="purpose-item">
              <TrendingUp :size="20" />
              <div>
                <strong>Melhorias</strong>
                <p>Analisar uso para desenvolver novos recursos</p>
              </div>
            </div>

            <div class="purpose-item">
              <Shield :size="20" />
              <div>
                <strong>Segurança</strong>
                <p>Detectar fraudes e proteger contra atividades maliciosas</p>
              </div>
            </div>

            <div class="purpose-item">
              <Scale :size="20" />
              <div>
                <strong>Conformidade Legal</strong>
                <p>Cumprir obrigações legais e regulamentares</p>
              </div>
            </div>
          </div>
        </section>

        <section id="compartilhamento" class="legal-section">
          <h2>4. Compartilhamento de Dados</h2>
          <p>Não vendemos seus dados pessoais. Compartilhamos informações apenas nas seguintes situações:</p>

          <div class="sharing-cases">
            <div class="sharing-allowed">
              <h3><Check :size="20" /> Compartilhamento Permitido</h3>
              <ul>
                <li>Com prestadores de serviços essenciais (hospedagem, suporte)</li>
                <li>Para cumprimento de obrigações legais</li>
                <li>Com seu consentimento explícito</li>
                <li>Em casos de fusão ou aquisição (com as mesmas proteções)</li>
              </ul>
            </div>

            <div class="sharing-prohibited">
              <h3><X :size="20" /> Nunca Compartilhamos</h3>
              <ul>
                <li>Para fins publicitários sem consentimento</li>
                <li>Com empresas de marketing de terceiros</li>
                <li>Dados financeiros sensíveis</li>
                <li>Informações para fins comerciais não relacionados</li>
              </ul>
            </div>
          </div>
        </section>

        <section id="seguranca" class="legal-section">
          <h2>5. Segurança dos Dados</h2>
          <p>Implementamos medidas técnicas e organizacionais robustas para proteger seus dados:</p>

          <div class="security-measures">
            <div class="security-item">
              <Lock :size="20" />
              <div>
                <strong>Criptografia</strong>
                <p>Dados em trânsito e em repouso protegidos com criptografia AES-256</p>
              </div>
            </div>

            <div class="security-item">
              <Server :size="20" />
              <div>
                <strong>Infraestrutura Segura</strong>
                <p>Servidores em datacenters certificados com controle de acesso físico</p>
              </div>
            </div>

            <div class="security-item">
              <UserCheck :size="20" />
              <div>
                <strong>Controle de Acesso</strong>
                <p>Autenticação multifator e princípio de menor privilégio</p>
              </div>
            </div>

            <div class="security-item">
              <Eye :size="20" />
              <div>
                <strong>Monitoramento</strong>
                <p>Detecção contínua de atividades suspeitas e logs de auditoria</p>
              </div>
            </div>
          </div>
        </section>

        <section id="retencao" class="legal-section">
          <h2>6. Retenção de Dados</h2>
          <p>Mantemos seus dados pessoais apenas pelo tempo necessário para:</p>
          <ul>
            <li>Cumprir os propósitos para os quais foram coletados</li>
            <li>Atender obrigações legais e regulamentares</li>
            <li>Resolver disputas e fazer cumprir nossos acordos</li>
          </ul>

          <div class="retention-periods">
            <div class="retention-item">
              <Calendar :size="16" />
              <span><strong>Dados de conta ativa:</strong> Durante a vigência do contrato</span>
            </div>
            <div class="retention-item">
              <Calendar :size="16" />
              <span><strong>Dados financeiros:</strong> 5 anos (conforme legislação fiscal)</span>
            </div>
            <div class="retention-item">
              <Calendar :size="16" />
              <span><strong>Logs de segurança:</strong> 6 meses</span>
            </div>
            <div class="retention-item">
              <Calendar :size="16" />
              <span><strong>Dados de suporte:</strong> 2 anos após resolução</span>
            </div>
          </div>
        </section>

        <section id="direitos" class="legal-section">
          <h2>7. Seus Direitos (LGPD)</h2>
          <p>Você possui os seguintes direitos sobre seus dados pessoais:</p>

          <div class="rights-grid">
            <div class="right-item">
              <Info :size="20" />
              <div>
                <strong>Acesso</strong>
                <p>Confirmar se tratamos seus dados e acessar suas informações</p>
              </div>
            </div>

            <div class="right-item">
              <Edit :size="20" />
              <div>
                <strong>Correção</strong>
                <p>Corrigir dados incompletos, inexatos ou desatualizados</p>
              </div>
            </div>

            <div class="right-item">
              <Trash2 :size="20" />
              <div>
                <strong>Exclusão</strong>
                <p>Excluir dados desnecessários ou tratados em desconformidade</p>
              </div>
            </div>

            <div class="right-item">
              <Download :size="20" />
              <div>
                <strong>Portabilidade</strong>
                <p>Receber seus dados em formato estruturado e interoperável</p>
              </div>
            </div>

            <div class="right-item">
              <XCircle :size="20" />
              <div>
                <strong>Oposição</strong>
                <p>Opor-se ao tratamento quando baseado em interesse legítimo</p>
              </div>
            </div>

            <div class="right-item">
              <UserX :size="20" />
              <div>
                <strong>Revogação</strong>
                <p>Revogar consentimento quando for a base legal do tratamento</p>
              </div>
            </div>
          </div>

          <div class="rights-contact">
            <Mail :size="20" />
            <div>
              <strong>Para exercer seus direitos:</strong>
              <p>Entre em contato através do e-mail <a href="mailto:privacidade@gestaozesystem.com">privacidade@gestaozesystem.com</a></p>
            </div>
          </div>
        </section>

        <section id="cookies" class="legal-section">
          <h2>8. Cookies e Tecnologias Similares</h2>
          <p>Utilizamos cookies e tecnologias similares para melhorar sua experiência. Para mais detalhes, consulte nossa <router-link to="/legal/cookies" class="link">Política de Cookies</router-link>.</p>

          <div class="cookie-types">
            <div class="cookie-type">
              <strong>Cookies Essenciais:</strong> Necessários para funcionamento básico (sempre ativos)
            </div>
            <div class="cookie-type">
              <strong>Cookies de Performance:</strong> Coletam informações sobre uso do sistema
            </div>
            <div class="cookie-type">
              <strong>Cookies de Preferência:</strong> Lembram suas configurações e escolhas
            </div>
          </div>
        </section>

        <section id="menores" class="legal-section">
          <h2>9. Menores de Idade</h2>
          <p>
            Nosso serviço é destinado a empresas e não coletamos intencionalmente dados de menores de 18 anos.
            Se tomarmos conhecimento de que coletamos dados de um menor sem autorização adequada,
            tomaremos medidas para excluir essas informações.
          </p>
        </section>

        <section id="internacional" class="legal-section">
          <h2>10. Transferências Internacionais</h2>
          <p>
            Seus dados são processados principalmente no Brasil. Quando necessário transferir dados
            para outros países, garantimos proteções adequadas através de:
          </p>
          <ul>
            <li>Cláusulas contratuais padrão aprovadas</li>
            <li>Certificações de adequação</li>
            <li>Decisões de adequação da ANPD</li>
          </ul>
        </section>

        <section id="alteracoes" class="legal-section">
          <h2>11. Alterações nesta Política</h2>
          <p>
            Podemos atualizar esta política periodicamente. Mudanças significativas serão comunicadas
            com pelo menos 30 dias de antecedência através do sistema ou e-mail.
          </p>
          <p>
            Recomendamos revisar esta política regularmente para se manter informado sobre como
            protegemos suas informações.
          </p>
        </section>

        <section id="contato" class="legal-section">
          <h2>12. Contato e Encarregado de Dados</h2>
          <div class="contact-info">
            <div class="contact-section">
              <h3>Encarregado de Proteção de Dados (DPO)</h3>
              <div class="contact-item">
                <Mail :size="16" />
                <span>dpo@gestaozesystem.com</span>
              </div>
              <div class="contact-item">
                <Phone :size="16" />
                <span>(48) 0000-0000</span>
              </div>
            </div>

            <div class="contact-section">
              <h3>Dados da Empresa</h3>
              <div class="contact-item">
                <Building :size="16" />
                <span>GestãoZe System Ltda.</span>
              </div>
              <div class="contact-item">
                <MapPin :size="16" />
                <span>Florianópolis - SC, Brasil</span>
              </div>
            </div>
          </div>
        </section>

        <div class="legal-footer">
          <div class="signature">
            <Calendar :size="16" />
            <span>Documento válido a partir de {{ lastUpdated }}</span>
          </div>
          <div class="version">
            <Shield :size="16" />
            <span>Versão 1.0 - LGPD Compliant</span>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Shield, Check, User, Building, CreditCard, Monitor, Activity, MapPin,
  Settings, LifeBuoy, Bell, TrendingUp, Scale, X, Lock, Server,
  UserCheck, Eye, Calendar, Info, Edit, Trash2, Download, XCircle,
  UserX, Mail, Phone
} from 'lucide-vue-next'

const lastUpdated = '26 de setembro de 2025'
</script>

<style scoped>
/* Estilos base importados */
@import '@/styles/legal.css';

.privacy-commitment {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(34, 197, 94, 0.05);
  border: 1px solid rgba(34, 197, 94, 0.2);
  border-radius: 12px;
  color: var(--theme-text-primary);
}

.privacy-commitment svg {
  color: #16a34a;
  flex-shrink: 0;
  margin-top: 0.125rem;
}

.lgpd-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: rgba(34, 197, 94, 0.1);
  color: #16a34a;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
  margin-top: 1rem;
}

.data-categories {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin: 1.5rem 0;
}

.data-category {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.data-category svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.auto-data {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin: 1.5rem 0;
}

.auto-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  background: var(--theme-background);
  border-radius: 8px;
  border-left: 4px solid var(--theme-primary);
}

.auto-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

.usage-purposes {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.purpose-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
  transition: all 0.3s ease;
}

.purpose-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.purpose-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.purpose-item p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.sharing-cases {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  margin: 1.5rem 0;
}

.sharing-allowed, .sharing-prohibited {
  padding: 1.5rem;
  border-radius: 12px;
}

.sharing-allowed {
  background: rgba(34, 197, 94, 0.05);
  border: 1px solid rgba(34, 197, 94, 0.2);
}

.sharing-prohibited {
  background: rgba(239, 68, 68, 0.05);
  border: 1px solid rgba(239, 68, 68, 0.2);
}

.sharing-allowed h3 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #16a34a;
  margin-bottom: 1rem;
}

.sharing-prohibited h3 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #dc2626;
  margin-bottom: 1rem;
}

.security-measures {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.security-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(59, 130, 246, 0.05);
  border: 1px solid rgba(59, 130, 246, 0.2);
  border-radius: 12px;
}

.security-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.security-item p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.retention-periods {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin: 1.5rem 0;
}

.retention-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background: var(--theme-background);
  border-radius: 8px;
  border-left: 4px solid var(--theme-accent);
}

.retention-item svg {
  color: var(--theme-accent);
  flex-shrink: 0;
}

.rights-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.right-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
  text-align: left;
}

.right-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.right-item p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.rights-contact {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(59, 130, 246, 0.05);
  border: 1px solid rgba(59, 130, 246, 0.2);
  border-radius: 12px;
  margin: 2rem 0;
}

.rights-contact svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.125rem;
}

.rights-contact a {
  color: var(--theme-primary);
  text-decoration: none;
  font-weight: 500;
}

.rights-contact a:hover {
  text-decoration: underline;
}

.cookie-types {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin: 1.5rem 0;
}

.cookie-type {
  padding: 1rem;
  background: var(--theme-background);
  border-radius: 8px;
  border-left: 4px solid var(--theme-primary);
}

.contact-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin: 1.5rem 0;
}

.contact-section h3 {
  color: var(--theme-primary);
  margin-bottom: 1rem;
  font-size: 1.1rem;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
  color: var(--theme-text-secondary);
}

.contact-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

.link {
  color: var(--theme-primary);
  text-decoration: none;
  font-weight: 500;
}

.link:hover {
  text-decoration: underline;
}

/* Responsive */
@media (max-width: 1024px) {
  .sharing-cases {
    grid-template-columns: 1fr;
  }

  .data-categories {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .usage-purposes,
  .security-measures,
  .rights-grid {
    grid-template-columns: 1fr;
  }

  .contact-info {
    grid-template-columns: 1fr;
  }
}
</style>