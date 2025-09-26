<template>
  <div class="legal-container">
    <header class="page-header">
      <div class="header-content">
        <h1>
          <Scale :size="28" />
          LGPD - Lei Geral de Proteção de Dados
        </h1>
        <div class="last-updated">
          Lei 13.709/2018 - Em vigor
        </div>
      </div>
    </header>

    <div class="legal-content">
      <!-- Navegação -->
      <nav class="legal-nav">
        <h3>Índice</h3>
        <ul>
          <li><a href="#sobre-lgpd">1. Sobre a LGPD</a></li>
          <li><a href="#nossa-conformidade">2. Nossa Conformidade</a></li>
          <li><a href="#bases-legais">3. Bases Legais</a></li>
          <li><a href="#direitos-titular">4. Direitos do Titular</a></li>
          <li><a href="#exercer-direitos">5. Como Exercer Direitos</a></li>
          <li><a href="#dpo">6. Encarregado de Dados</a></li>
          <li><a href="#incidentes">7. Incidentes de Segurança</a></li>
          <li><a href="#avaliacao-impacto">8. Avaliação de Impacto</a></li>
          <li><a href="#auditoria">9. Auditoria e Compliance</a></li>
          <li><a href="#relatorio-impacto">10. Relatório de Impacto</a></li>
          <li><a href="#anpd">11. Relacionamento com ANPD</a></li>
          <li><a href="#recursos">12. Recursos e Documentos</a></li>
        </ul>
      </nav>

      <!-- Conteúdo Principal -->
      <main class="legal-main">
        <div class="intro-section">
          <div class="lgpd-badge">
            <Shield :size="24" />
            <div>
              <strong>100% Conforme LGPD:</strong>
              Nosso sistema foi desenvolvido e é operado em total conformidade com a
              Lei Geral de Proteção de Dados (Lei 13.709/2018).
            </div>
          </div>
        </div>

        <section id="sobre-lgpd" class="legal-section">
          <h2>1. Sobre a LGPD</h2>
          <p>
            A Lei Geral de Proteção de Dados (LGPD - Lei 13.709/2018) é a legislação brasileira
            que regula o tratamento de dados pessoais, garantindo maior controle aos titulares
            sobre suas informações pessoais.
          </p>

          <div class="lgpd-info">
            <div class="info-item">
              <Calendar :size="20" />
              <div>
                <strong>Vigência:</strong>
                <p>Em vigor desde 18 de setembro de 2020</p>
              </div>
            </div>

            <div class="info-item">
              <Scale :size="20" />
              <div>
                <strong>Autoridade:</strong>
                <p>ANPD - Autoridade Nacional de Proteção de Dados</p>
              </div>
            </div>

            <div class="info-item">
              <DollarSign :size="20" />
              <div>
                <strong>Multas:</strong>
                <p>Até R$ 50 milhões ou 2% do faturamento</p>
              </div>
            </div>

            <div class="info-item">
              <Globe :size="20" />
              <div>
                <strong>Alcance:</strong>
                <p>Tratamento de dados no Brasil ou de brasileiros</p>
              </div>
            </div>
          </div>
        </section>

        <section id="nossa-conformidade" class="legal-section">
          <h2>2. Nossa Conformidade com a LGPD</h2>
          <p>
            A GestãoZe System adota medidas rigorosas para garantir conformidade total com a LGPD:
          </p>

          <div class="compliance-measures">
            <div class="measure-category">
              <h3><UserCheck :size="20" /> Governança de Dados</h3>
              <ul>
                <li>Política interna de proteção de dados</li>
                <li>Procedimentos de tratamento de dados documentados</li>
                <li>Treinamento regular de funcionários</li>
                <li>Comitê de privacidade e proteção de dados</li>
              </ul>
            </div>

            <div class="measure-category">
              <h3><Lock :size="20" /> Segurança Técnica</h3>
              <ul>
                <li>Criptografia de dados em trânsito e repouso</li>
                <li>Controles de acesso rigorosos</li>
                <li>Monitoramento contínuo de segurança</li>
                <li>Backup seguro e recuperação de dados</li>
              </ul>
            </div>

            <div class="measure-category">
              <h3><FileText :size="20" /> Documentação</h3>
              <ul>
                <li>Registro de atividades de tratamento</li>
                <li>Contratos com fornecedores adequados</li>
                <li>Políticas de retenção de dados</li>
                <li>Procedimentos de resposta a incidentes</li>
              </ul>
            </div>

            <div class="measure-category">
              <h3><Users :size="20" /> Direitos dos Titulares</h3>
              <ul>
                <li>Portal para exercício de direitos</li>
                <li>Processos ágeis de resposta</li>
                <li>Transparência sobre tratamento</li>
                <li>Canais de comunicação dedicados</li>
              </ul>
            </div>
          </div>
        </section>

        <section id="bases-legais" class="legal-section">
          <h2>3. Bases Legais para Tratamento</h2>
          <p>Tratamos dados pessoais com base nas seguintes hipóteses legais da LGPD:</p>

          <div class="legal-bases">
            <div class="base-item">
              <Check :size="20" />
              <div>
                <strong>Consentimento (Art. 7º, I)</strong>
                <p>Para funcionalidades opcionais e marketing (quando aplicável)</p>
              </div>
            </div>

            <div class="base-item">
              <FileText :size="20" />
              <div>
                <strong>Execução de Contrato (Art. 7º, V)</strong>
                <p>Para fornecimento dos serviços contratados</p>
              </div>
            </div>

            <div class="base-item">
              <Scale :size="20" />
              <div>
                <strong>Cumprimento de Obrigação Legal (Art. 7º, II)</strong>
                <p>Para atender obrigações fiscais e regulamentares</p>
              </div>
            </div>

            <div class="base-item">
              <Shield :size="20" />
              <div>
                <strong>Interesse Legítimo (Art. 7º, IX)</strong>
                <p>Para segurança, prevenção de fraudes e melhorias do serviço</p>
              </div>
            </div>

            <div class="base-item">
              <LifeBuoy :size="20" />
              <div>
                <strong>Exercício Regular de Direitos (Art. 7º, VI)</strong>
                <p>Para defesa em processos e exercício de direitos</p>
              </div>
            </div>

            <div class="base-item">
              <Heart :size="20" />
              <div>
                <strong>Proteção da Vida (Art. 7º, III)</strong>
                <p>Em situações de emergência que requeiram proteção à vida</p>
              </div>
            </div>
          </div>
        </section>

        <section id="direitos-titular" class="legal-section">
          <h2>4. Direitos do Titular de Dados</h2>
          <p>Conforme Art. 18 da LGPD, você possui os seguintes direitos:</p>

          <div class="rights-detailed">
            <div class="right-detail">
              <div class="right-header">
                <Info :size="20" />
                <span>Confirmação da Existência de Tratamento</span>
              </div>
              <p>Direito de saber se tratamos seus dados pessoais</p>
              <div class="article">Art. 18, I da LGPD</div>
            </div>

            <div class="right-detail">
              <div class="right-header">
                <Eye :size="20" />
                <span>Acesso aos Dados</span>
              </div>
              <p>Direito de acessar seus dados tratados por nós</p>
              <div class="article">Art. 18, II da LGPD</div>
            </div>

            <div class="right-detail">
              <div class="right-header">
                <Edit :size="20" />
                <span>Correção de Dados</span>
              </div>
              <p>Direito de corrigir dados incompletos, inexatos ou desatualizados</p>
              <div class="article">Art. 18, III da LGPD</div>
            </div>

            <div class="right-detail">
              <div class="right-header">
                <Trash2 :size="20" />
                <span>Eliminação dos Dados</span>
              </div>
              <p>Direito de solicitar a exclusão de dados desnecessários ou tratados ilicitamente</p>
              <div class="article">Art. 18, IV da LGPD</div>
            </div>

            <div class="right-detail">
              <div class="right-header">
                <Download :size="20" />
                <span>Portabilidade</span>
              </div>
              <p>Direito de receber dados em formato estruturado e interoperável</p>
              <div class="article">Art. 18, V da LGPD</div>
            </div>

            <div class="right-detail">
              <div class="right-header">
                <XCircle :size="20" />
                <span>Oposição ao Tratamento</span>
              </div>
              <p>Direito de se opor ao tratamento baseado em interesse legítimo</p>
              <div class="article">Art. 18, § 2º da LGPD</div>
            </div>
          </div>
        </section>

        <section id="exercer-direitos" class="legal-section">
          <h2>5. Como Exercer Seus Direitos</h2>
          <p>Disponibilizamos canais facilitados para exercício de seus direitos:</p>

          <div class="exercise-methods">
            <div class="method-item">
              <Mail :size="24" />
              <div>
                <strong>E-mail Dedicado</strong>
                <p>lgpd@gestaozesystem.com</p>
                <span class="response-time">Resposta em até 15 dias</span>
              </div>
            </div>

            <div class="method-item">
              <Settings :size="24" />
              <div>
                <strong>Portal de Privacidade</strong>
                <p>Acesso direto através do sistema</p>
                <span class="response-time">Autoatendimento 24/7</span>
              </div>
            </div>

            <div class="method-item">
              <Phone :size="24" />
              <div>
                <strong>Suporte Telefônico</strong>
                <p>(48) 0000-0000</p>
                <span class="response-time">Horário comercial</span>
              </div>
            </div>

            <div class="method-item">
              <MessageCircle :size="24" />
              <div>
                <strong>Chat Online</strong>
                <p>Suporte ao vivo no sistema</p>
                <span class="response-time">Disponível durante o uso</span>
              </div>
            </div>
          </div>

          <div class="process-timeline">
            <h3>Processo de Atendimento:</h3>
            <div class="timeline">
              <div class="timeline-item">
                <div class="timeline-marker">1</div>
                <div>
                  <strong>Recebimento da Solicitação</strong>
                  <p>Confirmação automática em até 2 horas</p>
                </div>
              </div>
              <div class="timeline-item">
                <div class="timeline-marker">2</div>
                <div>
                  <strong>Análise e Verificação</strong>
                  <p>Validação da identidade e legitimidade</p>
                </div>
              </div>
              <div class="timeline-item">
                <div class="timeline-marker">3</div>
                <div>
                  <strong>Processamento</strong>
                  <p>Execução da solicitação conforme direito exercido</p>
                </div>
              </div>
              <div class="timeline-item">
                <div class="timeline-marker">4</div>
                <div>
                  <strong>Resposta Final</strong>
                  <p>Comunicação do resultado em até 15 dias</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="dpo" class="legal-section">
          <h2>6. Encarregado de Proteção de Dados (DPO)</h2>
          <p>
            Conforme Art. 41 da LGPD, designamos um Encarregado de Proteção de Dados responsável
            por zelar pela conformidade com a lei:
          </p>

          <div class="dpo-info">
            <div class="dpo-card">
              <UserCheck :size="32" />
              <div class="dpo-details">
                <h3>Dados para Proteção Officer</h3>
                <p><strong>E-mail:</strong> dpo@gestaozesystem.com</p>
                <p><strong>Telefone:</strong> (48) 0000-0000</p>
                <p><strong>Horário:</strong> Segunda a Sexta, 8h às 18h</p>
              </div>
            </div>

            <div class="dpo-responsibilities">
              <h3>Responsabilidades do DPO:</h3>
              <ul>
                <li>Orientar funcionários sobre práticas de proteção de dados</li>
                <li>Atuar como canal de comunicação com titulares e ANPD</li>
                <li>Realizar treinamentos sobre LGPD</li>
                <li>Acompanhar auditorias e avaliações de impacto</li>
                <li>Elaborar relatórios de conformidade</li>
              </ul>
            </div>
          </div>
        </section>

        <section id="incidentes" class="legal-section">
          <h2>7. Incidentes de Segurança</h2>
          <p>
            Seguimos rigoroso protocolo para incidentes de segurança conforme Art. 48 da LGPD:
          </p>

          <div class="incident-protocol">
            <div class="protocol-step">
              <AlertTriangle :size="20" />
              <div>
                <strong>Detecção (0-1h)</strong>
                <p>Identificação automática ou manual do incidente</p>
              </div>
            </div>

            <div class="protocol-step">
              <Zap :size="20" />
              <div>
                <strong>Contenção (1-4h)</strong>
                <p>Medidas imediatas para conter o incidente</p>
              </div>
            </div>

            <div class="protocol-step">
              <Search :size="20" />
              <div>
                <strong>Investigação (4-24h)</strong>
                <p>Análise da causa e extensão do incidente</p>
              </div>
            </div>

            <div class="protocol-step">
              <Bell :size="20" />
              <div>
                <strong>Notificação (até 72h)</strong>
                <p>Comunicação à ANPD e titulares afetados</p>
              </div>
            </div>

            <div class="protocol-step">
              <Settings :size="20" />
              <div>
                <strong>Remediação</strong>
                <p>Implementação de correções e melhorias</p>
              </div>
            </div>
          </div>
        </section>

        <section id="avaliacao-impacto" class="legal-section">
          <h2>8. Avaliação de Impacto à Proteção de Dados</h2>
          <p>
            Realizamos Relatórios de Impacto à Proteção de Dados (RIPD) conforme Art. 38 da LGPD
            sempre que o tratamento puder gerar riscos às liberdades e direitos fundamentais.
          </p>

          <div class="impact-assessment">
            <div class="assessment-item">
              <Target :size="20" />
              <div>
                <strong>Identificação de Riscos</strong>
                <p>Mapeamento de potenciais riscos aos titulares</p>
              </div>
            </div>

            <div class="assessment-item">
              <BarChart3 :size="20" />
              <div>
                <strong>Análise de Impacto</strong>
                <p>Avaliação da probabilidade e severidade dos riscos</p>
              </div>
            </div>

            <div class="assessment-item">
              <Shield :size="20" />
              <div>
                <strong>Medidas de Mitigação</strong>
                <p>Implementação de salvaguardas apropriadas</p>
              </div>
            </div>
          </div>
        </section>

        <section id="auditoria" class="legal-section">
          <h2>9. Auditoria e Compliance</h2>
          <p>Mantemos programa contínuo de auditoria para garantir conformidade:</p>

          <div class="audit-program">
            <div class="audit-frequency">
              <h3>Frequência de Auditorias:</h3>
              <ul>
                <li><strong>Auditoria Interna:</strong> Trimestral</li>
                <li><strong>Auditoria Externa:</strong> Anual</li>
                <li><strong>Revisão de Políticas:</strong> Semestral</li>
                <li><strong>Treinamento de Equipe:</strong> Trimestral</li>
              </ul>
            </div>

            <div class="audit-scope">
              <h3>Escopo das Auditorias:</h3>
              <ul>
                <li>Conformidade com procedimentos internos</li>
                <li>Eficácia das medidas de segurança</li>
                <li>Adequação dos contratos com terceiros</li>
                <li>Atendimento aos direitos dos titulares</li>
              </ul>
            </div>
          </div>
        </section>

        <section id="anpd" class="legal-section">
          <h2>11. Relacionamento com a ANPD</h2>
          <p>
            Mantemos relacionamento transparente com a Autoridade Nacional de Proteção de Dados:
          </p>

          <div class="anpd-contact">
            <div class="anpd-info">
              <Scale :size="24" />
              <div>
                <strong>ANPD - Autoridade Nacional de Proteção de Dados</strong>
                <p>Website: gov.br/anpd</p>
                <p>E-mail: atendimento@anpd.gov.br</p>
                <p>Canal do Cidadão: 0800 285 0153</p>
              </div>
            </div>
          </div>
        </section>

        <section id="recursos" class="legal-section">
          <h2>12. Recursos e Documentos</h2>
          <p>Documentos e recursos relacionados à LGPD disponíveis:</p>

          <div class="resources-grid">
            <div class="resource-item">
              <FileText :size="20" />
              <div>
                <strong>Política de Privacidade</strong>
                <router-link to="/legal/privacy">Acessar documento</router-link>
              </div>
            </div>

            <div class="resource-item">
              <Cookie :size="20" />
              <div>
                <strong>Política de Cookies</strong>
                <router-link to="/legal/cookies">Acessar documento</router-link>
              </div>
            </div>

            <div class="resource-item">
              <Download :size="20" />
              <div>
                <strong>Registro de Atividades</strong>
                <a href="/docs/registro-atividades.pdf" target="_blank">Download PDF</a>
              </div>
            </div>

            <div class="resource-item">
              <Users :size="20" />
              <div>
                <strong>Portal do Titular</strong>
                <router-link to="/privacy/portal">Exercer direitos</router-link>
              </div>
            </div>
          </div>
        </section>

        <div class="legal-footer">
          <div class="signature">
            <Calendar :size="16" />
            <span>Conformidade LGPD verificada em {{ lastUpdated }}</span>
          </div>
          <div class="version">
            <Scale :size="16" />
            <span>Lei 13.709/2018 - Versão Completa</span>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  Scale, Shield, Calendar, DollarSign, Globe, UserCheck, Lock, FileText,
  Users, Check, LifeBuoy, Heart, Info, Eye, Edit, Trash2, Download,
  XCircle, Mail, Settings, Phone, MessageCircle, AlertTriangle, Zap,
  Search, Bell, Target, BarChart3, Cookie
} from 'lucide-vue-next'

const lastUpdated = '26 de setembro de 2025'
</script>

<style scoped>
/* Estilos base importados */
@import '@/styles/legal.css';

.lgpd-badge {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: rgba(34, 197, 94, 0.05);
  border: 1px solid rgba(34, 197, 94, 0.2);
  border-radius: 12px;
  color: var(--theme-text-primary);
}

.lgpd-badge svg {
  color: #16a34a;
  flex-shrink: 0;
  margin-top: 0.125rem;
}

.lgpd-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.info-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.info-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.info-item p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.compliance-measures {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  margin: 2rem 0;
}

.measure-category {
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.measure-category h3 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--theme-primary);
  margin-bottom: 1rem;
  font-size: 1.1rem;
}

.legal-bases {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.base-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border-left: 4px solid var(--theme-primary);
}

.base-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.base-item p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.rights-detailed {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.right-detail {
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.right-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--theme-primary);
  font-weight: 600;
  margin-bottom: 0.75rem;
}

.right-header svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

.article {
  background: rgba(59, 130, 246, 0.1);
  color: var(--theme-primary);
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  margin-top: 0.75rem;
  display: inline-block;
}

.exercise-methods {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.method-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
  transition: all 0.3s ease;
}

.method-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.method-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

.response-time {
  background: rgba(34, 197, 94, 0.1);
  color: #16a34a;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  margin-top: 0.5rem;
  display: inline-block;
}

.process-timeline {
  margin: 2rem 0;
}

.timeline {
  position: relative;
  padding-left: 2rem;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 1rem;
  top: 0;
  bottom: 0;
  width: 2px;
  background: var(--theme-border);
}

.timeline-item {
  position: relative;
  margin-bottom: 2rem;
  display: flex;
  gap: 1rem;
}

.timeline-marker {
  position: absolute;
  left: -2rem;
  width: 2rem;
  height: 2rem;
  background: var(--theme-primary);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 0.9rem;
}

.timeline-item p {
  margin: 0.25rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.dpo-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  margin: 2rem 0;
}

.dpo-card {
  display: flex;
  gap: 1rem;
  padding: 2rem;
  background: rgba(59, 130, 246, 0.05);
  border: 1px solid rgba(59, 130, 246, 0.2);
  border-radius: 12px;
}

.dpo-card svg {
  color: var(--theme-primary);
  flex-shrink: 0;
}

.dpo-details h3 {
  color: var(--theme-primary);
  margin-bottom: 1rem;
}

.dpo-responsibilities {
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.incident-protocol {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin: 2rem 0;
}

.protocol-step {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border-left: 4px solid #f59e0b;
  text-align: center;
  flex-direction: column;
  align-items: center;
}

.protocol-step svg {
  color: #f59e0b;
  margin-bottom: 0.5rem;
}

.protocol-step p {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: var(--theme-text-secondary);
}

.impact-assessment {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.assessment-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.assessment-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.audit-program {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  margin: 2rem 0;
}

.audit-frequency, .audit-scope {
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.anpd-contact {
  margin: 2rem 0;
}

.anpd-info {
  display: flex;
  gap: 1rem;
  padding: 2rem;
  background: rgba(59, 130, 246, 0.05);
  border: 1px solid rgba(59, 130, 246, 0.2);
  border-radius: 12px;
}

.anpd-info svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.resources-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.resource-item {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  background: var(--theme-background);
  border-radius: 12px;
  border: 1px solid var(--theme-border);
}

.resource-item svg {
  color: var(--theme-primary);
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.resource-item a {
  color: var(--theme-primary);
  text-decoration: none;
  font-weight: 500;
}

.resource-item a:hover {
  text-decoration: underline;
}

/* Responsive */
@media (max-width: 1024px) {
  .dpo-info,
  .audit-program {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .lgpd-info,
  .compliance-measures,
  .legal-bases,
  .rights-detailed,
  .exercise-methods,
  .incident-protocol,
  .impact-assessment,
  .resources-grid {
    grid-template-columns: 1fr;
  }

  .timeline {
    padding-left: 1.5rem;
  }

  .timeline-marker {
    left: -1.5rem;
    width: 1.5rem;
    height: 1.5rem;
    font-size: 0.8rem;
  }
}
</style>