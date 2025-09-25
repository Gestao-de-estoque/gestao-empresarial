<template>
  <div class="reports-container">
    <header class="page-header">
      <div class="header-content">
        <h1>
          <BarChart3 :size="28" />
          Relatórios Avançados com IA
        </h1>
        <div class="header-actions">
          <div class="ai-analysis-btn">
            <button @click="generateAIAnalysis" class="btn-ai" :disabled="aiLoading">
              <svg v-if="!aiLoading" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 2L2 7l10 5 10-5-10-5z"/>
                <path d="M2 17l10 5 10-5"/>
                <path d="M2 12l10 5 10-5"/>
              </svg>
              <RefreshCw v-else :size="18" class="animate-spin" />
              Análise IA
            </button>
          </div>
          <div class="export-dropdown" ref="exportDropdown">
            <button @click="toggleExportMenu" class="btn-secondary">
              <Download :size="18" />
              Exportar Avançado
              <svg :class="{ 'rotate-180': showExportMenu }" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="m6 9 6 6 6-6"/>
              </svg>
            </button>
            <div v-if="showExportMenu" class="export-menu">
              <button @click="exportToPDF" class="export-option">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                  <polyline points="14,2 14,8 20,8"/>
                </svg>
                PDF com Análise IA
              </button>
              <button @click="exportToExcel" class="export-option">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                  <path d="M9 9h6v6H9z"/>
                </svg>
                Excel com Insights
              </button>
              <button @click="exportToCSV" class="export-option">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                  <polyline points="14,2 14,8 20,8"/>
                </svg>
                CSV Detalhado
              </button>
              <button @click="exportToJSON" class="export-option">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                  <polyline points="14,2 14,8 20,8"/>
                </svg>
                JSON com IA
              </button>
              <button @click="exportToImage" class="export-option">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                  <circle cx="8.5" cy="8.5" r="1.5"/>
                  <path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/>
                </svg>
                Dashboard Completo
              </button>
              <button @click="exportToPowerBI" class="export-option">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                  <path d="M7 7h.01"/>
                  <path d="M7 17h.01"/>
                  <path d="M17 7h.01"/>
                  <path d="M17 17h.01"/>
                </svg>
                Power BI Format
              </button>
            </div>
          </div>
          <button @click="refreshData" class="btn-primary" :disabled="loading">
            <RefreshCw :size="18" :class="{ 'animate-spin': loading }" />
            Atualizar
          </button>
        </div>
      </div>
    </header>

    <!-- Análise da IA -->
    <div v-if="aiAnalysis" class="ai-analysis-section">
      <div class="ai-panel">
        <div class="panel-header">
          <h2>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M12 2L2 7l10 5 10-5-10-5z"/>
              <path d="M2 17l10 5 10-5"/>
              <path d="M2 12l10 5 10-5"/>
            </svg>
            Análise Inteligente
          </h2>
          <div class="performance-score">
            <span class="score-label">Score de Performance:</span>
            <div class="score-value" :class="getScoreClass(aiAnalysis.performanceScore)">
              {{ aiAnalysis.performanceScore }}/100
            </div>
          </div>
        </div>
        <div class="ai-content">
          <div class="executive-summary">
            <h3>Resumo Executivo</h3>
            <p>{{ aiAnalysis.executiveSummary }}</p>
          </div>
          <div class="insights-grid">
            <div class="insight-card" v-if="aiAnalysis.insights?.length">
              <h4>📊 Insights Estratégicos</h4>
              <ul>
                <li v-for="insight in aiAnalysis.insights.slice(0, 3)" :key="insight">{{ insight }}</li>
              </ul>
            </div>
            <div class="insight-card" v-if="aiAnalysis.predictions?.length">
              <h4>🔮 Previsões</h4>
              <ul>
                <li v-for="prediction in aiAnalysis.predictions.slice(0, 3)" :key="prediction">{{ prediction }}</li>
              </ul>
            </div>
            <div class="insight-card" v-if="aiAnalysis.recommendations?.length">
              <h4>💡 Recomendações</h4>
              <ul>
                <li v-for="recommendation in aiAnalysis.recommendations.slice(0, 3)" :key="recommendation">{{ recommendation }}</li>
              </ul>
            </div>
            <div class="insight-card alerts" v-if="aiAnalysis.alerts?.length">
              <h4>⚠️ Alertas Críticos</h4>
              <ul>
                <li v-for="alert in aiAnalysis.alerts.slice(0, 3)" :key="alert">{{ alert }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros de período -->
    <div class="filters-section">
      <div class="period-selector">
        <label>Período de análise:</label>
        <div class="period-buttons">
          <button
            v-for="period in periods"
            :key="period.value"
            @click="selectedPeriod = period.value"
            :class="{ active: selectedPeriod === period.value }"
            class="period-btn"
          >
            {{ period.label }}
          </button>
        </div>
      </div>
      <div class="chart-type-selector">
        <label>Tipo de visualização:</label>
        <div class="chart-type-buttons">
          <button
            v-for="type in chartTypes"
            :key="type.value"
            @click="selectedChartType = type.value"
            :class="{ active: selectedChartType === type.value }"
            class="chart-type-btn"
          >
            <component :is="type.icon" :size="16" />
            {{ type.label }}
          </button>
        </div>
      </div>
    </div>

    <!-- Cards de Estatísticas -->
    <div class="stats-grid">
      <div class="stat-card primary">
        <div class="stat-icon">
          <TrendingUp :size="24" />
        </div>
        <div class="stat-content">
          <div class="stat-value">R$ {{ formatCurrency(analytics.sales.totalSales || 0) }}</div>
          <div class="stat-label">Total de Vendas</div>
          <div class="stat-change positive">
            <TrendingUp :size="12" />
            +12.5% vs período anterior
          </div>
        </div>
      </div>

      <div class="stat-card info">
        <div class="stat-icon">
          <Package :size="24" />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ analytics.stock.totalProducts || 0 }}</div>
          <div class="stat-label">Total de Produtos</div>
          <div class="stat-change neutral">
            <Minus :size="12" />
            {{ analytics.stock.lowStockCount || 0 }} com estoque baixo
          </div>
        </div>
      </div>

      <div class="stat-card warning">
        <div class="stat-icon">
          <AlertTriangle :size="24" />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ analytics.stock.outOfStockCount || 0 }}</div>
          <div class="stat-label">Produtos em Falta</div>
          <div class="stat-change negative">
            <AlertTriangle :size="12" />
            Requer atenção imediata
          </div>
        </div>
      </div>

      <div class="stat-card success">
        <div class="stat-icon">
          <DollarSign :size="24" />
        </div>
        <div class="stat-content">
          <div class="stat-value">R$ {{ formatCurrency(analytics.stock.totalValue || 0) }}</div>
          <div class="stat-label">Valor do Estoque</div>
          <div class="stat-change positive">
            <TrendingUp :size="12" />
            Inventário total
          </div>
        </div>
      </div>
    </div>

    <!-- Gráficos Avançados -->
    <div class="charts-grid">
      <!-- Gráfico Principal de Performance -->
      <section class="chart-panel primary-chart">
        <div class="panel-header">
          <h2>
            <TrendingUp :size="20" />
            Performance de Vendas Avançada
          </h2>
          <div class="chart-controls">
            <button @click="chartType = 'line'" :class="{ active: chartType === 'line' }" class="chart-btn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="22,6 12,11 2,6"/>
              </svg>
              Linha
            </button>
            <button @click="chartType = 'bar'" :class="{ active: chartType === 'bar' }" class="chart-btn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="12" y1="20" x2="12" y2="10"/>
                <line x1="18" y1="20" x2="18" y2="4"/>
                <line x1="6" y1="20" x2="6" y2="16"/>
              </svg>
              Barra
            </button>
            <button @click="chartType = 'area'" :class="{ active: chartType === 'area' }" class="chart-btn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 18v-6a9 9 0 0 1 18 0v6"/>
              </svg>
              Área
            </button>
          </div>
        </div>
        <div class="chart-container">
          <component
            v-if="salesChartData.datasets.length > 0"
            :is="getChartComponent(chartType)"
            :data="salesChartData"
            :options="getChartOptions(chartType)"
          />
          <div v-else class="chart-loading">
            <Loader2 :size="32" class="animate-spin" />
            <p>Carregando análise avançada...</p>
          </div>
        </div>
      </section>

      <!-- Gráfico Radar de Categorias -->
      <section class="chart-panel">
        <div class="panel-header">
          <h2>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polygon points="12 2 22 8.5 22 15.5 12 22 2 15.5 2 8.5 12 2"/>
              <line x1="12" y1="8" x2="12" y2="16"/>
              <line x1="8" y1="12" x2="16" y2="12"/>
            </svg>
            Análise Radar por Categoria
          </h2>
        </div>
        <div class="chart-container">
          <Radar
            v-if="categoryRadarData.datasets.length > 0"
            :data="categoryRadarData"
            :options="chartOptions.radar"
          />
          <div v-else class="chart-loading">
            <Loader2 :size="32" class="animate-spin" />
            <p>Processando análise radar...</p>
          </div>
        </div>
      </section>

      <!-- Gráfico Bubble de Produtos -->
      <section class="chart-panel">
        <div class="panel-header">
          <h2>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8"/>
              <path d="M21 21l-4.35-4.35"/>
            </svg>
            Análise de Portfolio
          </h2>
        </div>
        <div class="chart-container">
          <Scatter
            v-if="productBubbleData.datasets.length > 0"
            :data="productBubbleData"
            :options="chartOptions.bubble"
          />
          <div v-else class="chart-loading">
            <Loader2 :size="32" class="animate-spin" />
            <p>Analisando portfolio...</p>
          </div>
        </div>
      </section>

      <!-- Gráfico Polar de Estoque -->
      <section class="chart-panel">
        <div class="panel-header">
          <h2>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <path d="M12 6v6l4 2"/>
            </svg>
            Distribuição Polar de Valor
          </h2>
        </div>
        <div class="chart-container">
          <PolarArea
            v-if="stockPolarData.datasets.length > 0"
            :data="stockPolarData"
            :options="chartOptions.polar"
          />
          <div v-else class="chart-loading">
            <Loader2 :size="32" class="animate-spin" />
            <p>Calculando distribuição...</p>
          </div>
        </div>
      </section>

      <!-- Gráfico de Movimentações Stack -->
      <section class="chart-panel full-width">
        <div class="panel-header">
          <h2>
            <Activity :size="20" />
            Fluxo de Movimentações Avançado
          </h2>
          <div class="chart-metrics">
            <div class="metric">
              <span class="metric-label">Taxa de Entrada:</span>
              <span class="metric-value positive">{{ movementMetrics.entryRate }}%</span>
            </div>
            <div class="metric">
              <span class="metric-label">Taxa de Saída:</span>
              <span class="metric-value negative">{{ movementMetrics.exitRate }}%</span>
            </div>
            <div class="metric">
              <span class="metric-label">Balanceamento:</span>
              <span class="metric-value" :class="movementMetrics.balance >= 0 ? 'positive' : 'negative'">
                {{ movementMetrics.balance }}%
              </span>
            </div>
          </div>
        </div>
        <div class="chart-container">
          <Bar
            v-if="stackedMovementsData.datasets.length > 0"
            :data="stackedMovementsData"
            :options="chartOptions.stackedMovements"
          />
          <div v-else class="chart-loading">
            <Loader2 :size="32" class="animate-spin" />
            <p>Processando fluxos...</p>
          </div>
        </div>
      </section>

      <!-- Performance Score Gauge -->
      <section class="chart-panel gauge-panel">
        <div class="panel-header">
          <h2>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
              <path d="M12 17h.01"/>
            </svg>
            Score de Performance
          </h2>
        </div>
        <div class="gauge-container">
          <div class="gauge-chart">
            <Doughnut
              v-if="performanceGaugeData.datasets.length > 0"
              :data="performanceGaugeData"
              :options="chartOptions.gauge"
            />
            <div class="gauge-center">
              <div class="gauge-score">{{ aiAnalysis?.performanceScore || 0 }}</div>
              <div class="gauge-label">Score</div>
            </div>
          </div>
          <div class="performance-indicators">
            <div class="indicator" :class="getPerformanceClass('sales')">
              <span>Vendas</span>
              <div class="indicator-bar">
                <div class="indicator-fill" :style="{ width: salesPerformance + '%' }"></div>
              </div>
            </div>
            <div class="indicator" :class="getPerformanceClass('stock')">
              <span>Estoque</span>
              <div class="indicator-bar">
                <div class="indicator-fill" :style="{ width: stockPerformance + '%' }"></div>
              </div>
            </div>
            <div class="indicator" :class="getPerformanceClass('efficiency')">
              <span>Eficiência</span>
              <div class="indicator-bar">
                <div class="indicator-fill" :style="{ width: efficiencyPerformance + '%' }"></div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- Seção de Análise Preditiva -->
    <div v-if="predictiveInsights.length > 0" class="predictive-section">
      <div class="section-header">
        <h2>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
            <path d="M13 8l-3 3 3 3"/>
          </svg>
          Análise Preditiva Avançada
        </h2>
        <div class="prediction-accuracy">
          <span class="accuracy-label">Precisão Média:</span>
          <div class="accuracy-value">{{ calculateAveragePredictionAccuracy() }}%</div>
        </div>
      </div>

      <div class="predictive-grid">
        <!-- Previsão de Vendas -->
        <div class="predictive-panel sales-forecast">
          <div class="panel-header">
            <h3>
              <TrendingUp :size="20" />
              Previsão de Vendas - 30 Dias
            </h3>
          </div>
          <div class="forecast-chart" v-if="salesForecast.length > 0">
            <Line
              :data="getForecastChartData()"
              :options="getForecastChartOptions()"
            />
          </div>
          <div class="forecast-summary">
            <div class="forecast-metric">
              <span class="metric-label">Previsão Total:</span>
              <span class="metric-value">R$ {{ formatCurrency(getTotalForecast()) }}</span>
            </div>
            <div class="forecast-metric">
              <span class="metric-label">Confiança Média:</span>
              <span class="metric-value">{{ getAverageConfidence() }}%</span>
            </div>
          </div>
        </div>

        <!-- Insights Preditivos -->
        <div class="predictive-panel insights-panel">
          <div class="panel-header">
            <h3>
              <Zap :size="20" />
              Insights Preditivos
            </h3>
          </div>
          <div class="insights-list">
            <div
              v-for="insight in predictiveInsights.slice(0, 5)"
              :key="insight.title"
              class="insight-item"
              :class="{
                'high-impact': insight.impact === 'high',
                'medium-impact': insight.impact === 'medium',
                'low-impact': insight.impact === 'low'
              }"
            >
              <div class="insight-header">
                <div class="insight-type" :class="insight.type">
                  <component
                    :is="getInsightIcon(insight.type)"
                    :size="16"
                  />
                  {{ insight.type.toUpperCase() }}
                </div>
                <div class="insight-confidence">{{ insight.confidence }}%</div>
              </div>
              <h4 class="insight-title">{{ insight.title }}</h4>
              <p class="insight-description">{{ insight.description }}</p>
              <div class="insight-timeframe">{{ insight.timeframe }}</div>
              <div v-if="insight.actionRequired" class="action-required">
                ⚠️ Ação Necessária
              </div>
            </div>
          </div>
        </div>

        <!-- Previsão de Demanda -->
        <div class="predictive-panel demand-panel">
          <div class="panel-header">
            <h3>
              <Package :size="20" />
              Previsão de Demanda - Produtos
            </h3>
          </div>
          <div class="demand-list">
            <div
              v-for="(forecast, product) in demandForecast"
              :key="product"
              class="demand-item"
            >
              <div class="product-info">
                <div class="product-name">{{ product }}</div>
                <div class="current-stock">Estoque: {{ forecast.currentStock }}</div>
              </div>
              <div class="demand-forecast">
                <div class="predicted-demand">{{ forecast.predictedDemand }}</div>
                <div class="demand-label">Demanda Prev.</div>
              </div>
              <div class="reorder-recommendation">
                <div class="reorder-qty" :class="{
                  'urgent': forecast.riskLevel === 'high',
                  'warning': forecast.riskLevel === 'medium',
                  'good': forecast.riskLevel === 'low'
                }">
                  {{ forecast.recommendedOrder > 0 ? `+${forecast.recommendedOrder}` : 'OK' }}
                </div>
                <div class="reorder-label">Repor</div>
              </div>
              <div class="confidence-bar">
                <div
                  class="confidence-fill"
                  :style="{ width: forecast.confidence + '%' }"
                ></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Alertas e Anomalias -->
      <div v-if="anomalies.length > 0" class="anomalies-section">
        <div class="anomalies-header">
          <h3>
            <AlertTriangle :size="20" />
            Anomalias Detectadas
          </h3>
        </div>
        <div class="anomalies-grid">
          <div
            v-for="anomaly in anomalies"
            :key="anomaly.title"
            class="anomaly-card"
            :class="anomaly.impact"
          >
            <div class="anomaly-icon">
              <AlertTriangle :size="24" />
            </div>
            <div class="anomaly-content">
              <h4>{{ anomaly.title }}</h4>
              <p>{{ anomaly.description }}</p>
              <div class="anomaly-recommendations">
                <strong>Recomendações:</strong>
                <ul>
                  <li v-for="rec in anomaly.recommendations.slice(0, 2)" :key="rec">
                    {{ rec }}
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabelas de Dados -->
    <div class="tables-grid">
      <!-- Produtos com Estoque Baixo -->
      <section class="data-panel">
        <div class="panel-header">
          <h2>
            <AlertTriangle :size="20" />
            Produtos com Estoque Baixo
          </h2>
          <span class="count-badge warning">{{ analytics.stock.lowStockProducts?.length || 0 }}</span>
        </div>
        <div class="table-container">
          <table v-if="analytics.stock.lowStockProducts?.length > 0" class="data-table">
            <thead>
              <tr>
                <th>Produto</th>
                <th>Estoque Atual</th>
                <th>Estoque Mínimo</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in analytics.stock.lowStockProducts" :key="product.id">
                <td class="product-name">{{ product.nome }}</td>
                <td class="stock-current">{{ product.current_stock }} {{ product.unidade }}</td>
                <td class="stock-min">{{ product.min_stock }} {{ product.unidade }}</td>
                <td>
                  <span class="status-badge warning">
                    <AlertTriangle :size="14" />
                    Baixo
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
          <div v-else class="empty-table">
            <CheckCircle :size="32" />
            <p>Todos os produtos estão com estoque adequado!</p>
          </div>
        </div>
      </section>

      <!-- Movimentações Recentes -->
      <section class="data-panel">
        <div class="panel-header">
          <h2>
            <Activity :size="20" />
            Movimentações Recentes
          </h2>
          <router-link to="/inventory" class="view-all-link">
            Ver todas
            <ExternalLink :size="14" />
          </router-link>
        </div>
        <div class="table-container">
          <table v-if="analytics.movements.recentMovements?.length > 0" class="data-table">
            <thead>
              <tr>
                <th>Produto</th>
                <th>Tipo</th>
                <th>Quantidade</th>
                <th>Data</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="movement in analytics.movements.recentMovements" :key="movement.id">
                <td class="product-name">{{ movement.produtos?.nome }}</td>
                <td>
                  <span :class="`status-badge ${movement.type === 'in' ? 'success' : 'danger'}`">
                    <ArrowUp v-if="movement.type === 'in'" :size="14" />
                    <ArrowDown v-else :size="14" />
                    {{ movement.type === 'in' ? 'Entrada' : 'Saída' }}
                  </span>
                </td>
                <td class="quantity">{{ movement.quantity }}</td>
                <td class="date">{{ formatDate(movement.created_at) }}</td>
              </tr>
            </tbody>
          </table>
          <div v-else class="empty-table">
            <Activity :size="32" />
            <p>Nenhuma movimentação recente encontrada.</p>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted, computed } from 'vue'
import { reportsService } from '@/services/reportsService'
import { aiAnalyticsService } from '@/services/aiAnalyticsService'
import { advancedChartsService } from '@/services/advancedChartsService'
import { predictiveAnalyticsService } from '@/services/predictiveAnalyticsService'
import { Line, Bar, Doughnut, Radar, Scatter, PolarArea } from 'vue-chartjs'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'
import * as XLSX from 'xlsx'

// Icons
import {
  BarChart3, Download, RefreshCw, TrendingUp, Package, AlertTriangle,
  DollarSign, Minus, PieChart, Loader2, CheckCircle, Activity,
  ExternalLink, ArrowUp, ArrowDown, Target, Zap, TrendingDown
} from 'lucide-vue-next'

// Chart.js configuration
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  RadialLinearScale,
  Filler
} from 'chart.js'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  RadialLinearScale,
  Filler
)

// State
const loading = ref(false)
const aiLoading = ref(false)
const selectedPeriod = ref<'7d' | '30d' | '90d'>('30d')
const chartType = ref<'line' | 'bar' | 'area'>('line')
const selectedChartType = ref<'standard' | 'advanced' | 'predictive'>('advanced')
const showExportMenu = ref(false)
const exportDropdown = ref<HTMLElement | null>(null)

// IA Analysis State
const aiAnalysis = ref<any>(null)
const salesPrediction = ref<any>(null)
const inventoryOptimization = ref<any>(null)
const marketInsights = ref<string[]>([])

// Predictive Analytics State
const predictiveInsights = ref<any[]>([])
const salesForecast = ref<any[]>([])
const demandForecast = ref<any>({})
const profitabilityPrediction = ref<any[]>([])
const anomalies = ref<any[]>([])

const periods = [
  { label: '7 dias', value: '7d' as const },
  { label: '30 dias', value: '30d' as const },
  { label: '90 dias', value: '90d' as const }
]

const chartTypes = [
  { label: 'Padrão', value: 'standard', icon: BarChart3 },
  { label: 'Avançado', value: 'advanced', icon: Target },
  { label: 'Preditivo', value: 'predictive', icon: Zap }
]

interface AnalyticsData {
  sales: {
    totalSales?: number;
  };
  stock: {
    totalProducts?: number;
    lowStockCount?: number;
    outOfStockCount?: number;
    totalValue?: number;
    lowStockProducts: any[];
  };
  movements: {
    recentMovements: any[];
  };
  suppliers: any;
}

const analytics = ref<AnalyticsData>({
  sales: {},
  stock: {
    lowStockProducts: [],
  },
  movements: {
    recentMovements: [],
  },
  suppliers: {}
})

const salesChartData = ref<any>({ labels: [], datasets: [] })
const categoryChartData = ref<any>({ labels: [], datasets: [] })
const movementsChartData = ref<any>({ labels: [], datasets: [] })

// Advanced Chart Data
const categoryRadarData = ref<any>({ labels: [], datasets: [] })
const productBubbleData = ref<any>({ labels: [], datasets: [] })
const stockPolarData = ref<any>({ labels: [], datasets: [] })
const stackedMovementsData = ref<any>({ labels: [], datasets: [] })
const performanceGaugeData = ref<any>({ labels: [], datasets: [] })

// Metrics
const movementMetrics = ref({
  entryRate: 0,
  exitRate: 0,
  balance: 0
})

const salesPerformance = ref(75)
const stockPerformance = ref(82)
const efficiencyPerformance = ref(68)

// Chart options
const chartOptions = {
  line: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'top' as const,
        labels: {
          color: '#64748b',
          font: { size: 12, weight: 'bold' },
          usePointStyle: true
        }
      },
      tooltip: {
        mode: 'index' as const,
        intersect: false,
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        titleColor: '#fff',
        bodyColor: '#fff',
        borderColor: '#667eea',
        borderWidth: 1
      }
    },
    scales: {
      x: {
        display: true,
        grid: { display: false },
        ticks: { color: '#64748b' }
      },
      y: {
        display: true,
        grid: { color: 'rgba(100, 116, 139, 0.2)' },
        ticks: { color: '#64748b' }
      }
    },
    elements: {
      line: { tension: 0.4 },
      point: { radius: 4, hoverRadius: 8 }
    },
    interaction: {
      intersect: false,
      mode: 'index' as const
    }
  },
  bar: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'top' as const,
        labels: {
          color: '#64748b',
          font: { size: 12, weight: 'bold' }
        }
      }
    },
    scales: {
      x: {
        display: true,
        grid: { display: false },
        ticks: { color: '#64748b' }
      },
      y: {
        display: true,
        grid: { color: 'rgba(100, 116, 139, 0.2)' },
        ticks: { color: '#64748b' }
      }
    }
  },
  radar: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top' as const,
        labels: {
          color: '#64748b',
          font: { size: 12, weight: 'bold' }
        }
      }
    },
    scales: {
      r: {
        beginAtZero: true,
        max: 100,
        ticks: {
          color: '#64748b',
          backdropColor: 'transparent'
        },
        grid: {
          color: 'rgba(100, 116, 139, 0.3)'
        },
        angleLines: {
          color: 'rgba(100, 116, 139, 0.3)'
        }
      }
    }
  },
  bubble: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: (context: any) => {
            const data = context.raw
            return [
              `Produto: ${data.label}`,
              `Estoque: ${data.x}`,
              `Preço: R$ ${data.y.toFixed(2)}`,
              `Volume: ${Math.round(data.r ** 2 / 2)}`
            ]
          }
        }
      }
    },
    scales: {
      x: {
        title: {
          display: true,
          text: 'Estoque Atual',
          color: '#64748b',
          font: { weight: 'bold' }
        },
        grid: { color: 'rgba(100, 116, 139, 0.2)' },
        ticks: { color: '#64748b' }
      },
      y: {
        title: {
          display: true,
          text: 'Preço (R$)',
          color: '#64748b',
          font: { weight: 'bold' }
        },
        grid: { color: 'rgba(100, 116, 139, 0.2)' },
        ticks: { color: '#64748b' }
      }
    }
  },
  polar: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'right' as const,
        labels: {
          color: '#64748b',
          font: { size: 12 },
          padding: 20
        }
      }
    },
    scales: {
      r: {
        beginAtZero: true,
        ticks: { display: false },
        grid: { color: 'rgba(100, 116, 139, 0.3)' }
      }
    }
  },
  stackedMovements: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: 'top' as const }
    },
    scales: {
      x: {
        stacked: true,
        display: true,
        grid: { display: false },
        ticks: { color: '#64748b' }
      },
      y: {
        stacked: true,
        display: true,
        grid: { color: 'rgba(100, 116, 139, 0.2)' },
        ticks: { color: '#64748b' }
      }
    }
  },
  gauge: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: { enabled: false }
    },
    cutout: '75%',
    circumference: 180,
    rotation: 270
  },
  doughnut: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom' as const,
        labels: {
          padding: 20,
          usePointStyle: true,
          color: '#64748b',
          font: { size: 12 }
        }
      }
    }
  }
}

// Methods
async function loadAnalytics() {
  loading.value = true
  try {
    const [salesData, stockData, movementsData, suppliersData] = await Promise.all([
      reportsService.getSalesAnalytics(selectedPeriod.value),
      reportsService.getStockAnalytics(),
      reportsService.getMovementsAnalytics(selectedPeriod.value),
      reportsService.getSuppliersAnalytics()
    ])

    analytics.value = {
      sales: salesData,
      stock: stockData,
      movements: movementsData,
      suppliers: suppliersData
    }

    // Load chart data
    await loadChartData()
    await loadAdvancedCharts()

    // Calculate performance metrics
    calculatePerformanceMetrics()

  } catch (error) {
    console.error('Erro ao carregar analytics:', error)
  } finally {
    loading.value = false
  }
}

async function loadChartData() {
  try {
    const [salesChart, stockChart, movementsChart] = await Promise.all([
      reportsService.getChartData('sales', selectedPeriod.value),
      reportsService.getChartData('stock'),
      reportsService.getChartData('movements', selectedPeriod.value)
    ])

    salesChartData.value = salesChart
    categoryChartData.value = stockChart
    movementsChartData.value = movementsChart
  } catch (error) {
    console.error('Erro ao carregar dados dos gráficos:', error)
  }
}

async function loadAdvancedCharts() {
  try {
    if (analytics.value.sales?.dailySales) {
      const performanceChart = advancedChartsService.generateSalesPerformanceChart(
        analytics.value.sales.dailySales,
        selectedPeriod.value
      )
      salesChartData.value = performanceChart.data
    }

    if (analytics.value.stock?.categoryBreakdown) {
      const radarChart = advancedChartsService.generateCategoryRadarChart(
        analytics.value.stock.categoryBreakdown
      )
      categoryRadarData.value = radarChart.data

      const polarChart = advancedChartsService.generatePolarAreaChart(
        analytics.value.stock.categoryBreakdown.map(cat => ({
          category: cat.category,
          totalValue: cat.count * 100 // Estimativa
        }))
      )
      stockPolarData.value = polarChart.data
    }

    if (analytics.value.movements?.dailyMovements) {
      const stackedChart = advancedChartsService.generateStackedAreaChart(
        analytics.value.movements.dailyMovements
      )
      stackedMovementsData.value = stackedChart.data
    }

    // Simular dados de produtos para bubble chart
    const mockProductData = [
      { nome: 'Produto A', current_stock: 50, preco: 29.99, sales_volume: 120, performance_score: 85 },
      { nome: 'Produto B', current_stock: 20, preco: 49.99, sales_volume: 80, performance_score: 70 },
      { nome: 'Produto C', current_stock: 100, preco: 15.99, sales_volume: 200, performance_score: 90 }
    ]

    const bubbleChart = advancedChartsService.generateProductBubbleChart(mockProductData)
    productBubbleData.value = bubbleChart.data

    // Performance Gauge
    const gaugeChart = advancedChartsService.generateGaugeChart(
      aiAnalysis.value?.performanceScore || 75,
      'Performance Geral'
    )
    performanceGaugeData.value = gaugeChart.data

  } catch (error) {
    console.error('Erro ao carregar gráficos avançados:', error)
  }
}

function calculatePerformanceMetrics() {
  if (analytics.value.movements?.dailyMovements) {
    const movements = analytics.value.movements.dailyMovements
    const totalIn = movements.reduce((acc: number, mov: any) => acc + (mov.in || 0), 0)
    const totalOut = movements.reduce((acc: number, mov: any) => acc + (mov.out || 0), 0)
    const total = totalIn + totalOut

    if (total > 0) {
      movementMetrics.value = {
        entryRate: Math.round((totalIn / total) * 100),
        exitRate: Math.round((totalOut / total) * 100),
        balance: Math.round(((totalIn - totalOut) / total) * 100)
      }
    }
  }

  // Calcular performance scores
  salesPerformance.value = Math.min(95, Math.max(30,
    (analytics.value.sales?.totalSales || 0) / 10000 * 100
  ))

  stockPerformance.value = Math.min(95, Math.max(30,
    100 - (analytics.value.stock?.lowStockCount || 0) / (analytics.value.stock?.totalProducts || 1) * 100
  ))

  efficiencyPerformance.value = Math.min(95, Math.max(30,
    (movementMetrics.value.entryRate + (100 - movementMetrics.value.exitRate)) / 2
  ))
}

async function generateAIAnalysis() {
  aiLoading.value = true
  try {
    // Gerar análise completa com IA
    const [businessAnalysis, executiveSummary, salesPred, inventoryOpt, insights] = await Promise.all([
      aiAnalyticsService.analyzeBusinessData(analytics.value),
      aiAnalyticsService.generateExecutiveSummary(analytics.value),
      aiAnalyticsService.predictSalesTrends(analytics.value.sales?.dailySales || []),
      aiAnalyticsService.analyzeInventoryOptimization(analytics.value.stock),
      aiAnalyticsService.generateMarketInsights(analytics.value.sales, selectedPeriod.value)
    ])

    aiAnalysis.value = {
      ...businessAnalysis,
      executiveSummary
    }
    salesPrediction.value = salesPred
    inventoryOptimization.value = inventoryOpt
    marketInsights.value = insights

    // Recarregar gráficos com dados da IA
    await loadAdvancedCharts()

    // Carregar análises preditivas
    await loadPredictiveAnalytics()

  } catch (error) {
    console.error('Erro na análise de IA:', error)
    alert('Erro ao gerar análise com IA. Verifique sua conexão.')
  } finally {
    aiLoading.value = false
  }
}

async function loadPredictiveAnalytics() {
  try {
    if (!analytics.value.sales?.dailySales?.length) return

    // Carregar todas as análises preditivas em paralelo
    const [forecast, insights, anomaliesData, demandPred, profitPred] = await Promise.all([
      predictiveAnalyticsService.predictSalesPattern(analytics.value.sales.dailySales),
      predictiveAnalyticsService.analyzeSeasonalPatterns(analytics.value.sales.dailySales),
      predictiveAnalyticsService.detectAnomalies(analytics.value.sales.dailySales),
      predictiveAnalyticsService.forecastProductDemand(analytics.value.stock?.lowStockProducts || []),
      predictiveAnalyticsService.predictProfitability(analytics.value.sales.dailySales, analytics.value.stock)
    ])

    salesForecast.value = forecast
    predictiveInsights.value = [...insights, ...profitPred]
    anomalies.value = anomaliesData
    demandForecast.value = demandPred

  } catch (error) {
    console.error('Erro ao carregar análises preditivas:', error)
  }
}

async function refreshData() {
  await loadAnalytics()
  if (aiAnalysis.value) {
    await generateAIAnalysis()
  }
}

function toggleExportMenu() {
  showExportMenu.value = !showExportMenu.value
}

// Helper functions
function getChartComponent(type: string) {
  switch (type) {
    case 'line':
      return Line
    case 'bar':
      return Bar
    case 'area':
      return Line // With fill: true
    default:
      return Line
  }
}

function getChartOptions(type: string) {
  const baseOptions = chartOptions.line
  if (type === 'area') {
    return {
      ...baseOptions,
      elements: {
        ...baseOptions.elements,
        line: { ...baseOptions.elements.line, fill: true }
      }
    }
  }
  return chartOptions[type as keyof typeof chartOptions] || baseOptions
}

function getScoreClass(score: number): string {
  if (score >= 80) return 'excellent'
  if (score >= 60) return 'good'
  if (score >= 40) return 'fair'
  return 'poor'
}

function getPerformanceClass(type: string): string {
  let score = 0
  switch (type) {
    case 'sales':
      score = salesPerformance.value
      break
    case 'stock':
      score = stockPerformance.value
      break
    case 'efficiency':
      score = efficiencyPerformance.value
      break
  }
  return getScoreClass(score)
}

// Funções para análise preditiva
function calculateAveragePredictionAccuracy(): number {
  if (predictiveInsights.value.length === 0) return 0
  const totalConfidence = predictiveInsights.value.reduce((acc, insight) => acc + insight.confidence, 0)
  return Math.round(totalConfidence / predictiveInsights.value.length)
}

function getForecastChartData(): any {
  if (!salesForecast.value.length) return { labels: [], datasets: [] }

  const labels = salesForecast.value.map(f => f.period)
  const predictions = salesForecast.value.map(f => f.predictedValue)
  const upperBounds = salesForecast.value.map(f => f.upperBound)
  const lowerBounds = salesForecast.value.map(f => f.lowerBound)

  return {
    labels,
    datasets: [
      {
        label: 'Previsão',
        data: predictions,
        borderColor: '#4facfe',
        backgroundColor: 'rgba(79, 172, 254, 0.1)',
        fill: false,
        tension: 0.4
      },
      {
        label: 'Limite Superior',
        data: upperBounds,
        borderColor: '#fca5a5',
        backgroundColor: 'transparent',
        borderDash: [5, 5],
        fill: false
      },
      {
        label: 'Limite Inferior',
        data: lowerBounds,
        borderColor: '#a5f3fc',
        backgroundColor: 'transparent',
        borderDash: [5, 5],
        fill: false
      }
    ]
  }
}

function getForecastChartOptions(): any {
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top' as const,
        labels: {
          color: '#64748b',
          font: { size: 11 }
        }
      },
      tooltip: {
        mode: 'index' as const,
        intersect: false
      }
    },
    scales: {
      x: {
        display: true,
        grid: { display: false },
        ticks: { color: '#64748b', maxTicksLimit: 10 }
      },
      y: {
        display: true,
        grid: { color: 'rgba(100, 116, 139, 0.2)' },
        ticks: { color: '#64748b' }
      }
    },
    elements: {
      point: { radius: 3 }
    }
  }
}

function getTotalForecast(): number {
  return salesForecast.value.reduce((acc, f) => acc + f.predictedValue, 0)
}

function getAverageConfidence(): number {
  if (!salesForecast.value.length) return 0
  const totalConfidence = salesForecast.value.reduce((acc, f) => acc + f.confidence, 0)
  return Math.round(totalConfidence / salesForecast.value.length)
}

function getInsightIcon(type: string) {
  switch (type) {
    case 'trend': return TrendingUp
    case 'seasonal': return Activity
    case 'anomaly': return AlertTriangle
    case 'forecast': return Target
    default: return Zap
  }
}

async function exportToPDF() {
  try {
    loading.value = true
    showExportMenu.value = false

    const pdf = new jsPDF('p', 'mm', 'a4')
    const pageWidth = pdf.internal.pageSize.getWidth()
    const pageHeight = pdf.internal.pageSize.getHeight()
    let currentY = 20

    // Header do relatório
    pdf.setFontSize(24)
    pdf.setTextColor(102, 126, 234)
    pdf.text('Relatório Avançado com IA - GestãoZe', 20, currentY)

    currentY += 15
    pdf.setFontSize(12)
    pdf.setTextColor(100, 100, 100)
    pdf.text(`Período: ${periods.find(p => p.value === selectedPeriod.value)?.label}`, 20, currentY)
    pdf.text(`Gerado em: ${format(new Date(), 'dd/MM/yyyy HH:mm', { locale: ptBR })}`, 20, currentY + 5)

    // Performance Score
    if (aiAnalysis.value) {
      currentY += 15
      pdf.setFontSize(14)
      pdf.setTextColor(26, 32, 44)
      pdf.text(`Score de Performance: ${aiAnalysis.value.performanceScore}/100`, 20, currentY)
    }

    currentY += 20

    // Análise da IA - Resumo Executivo
    if (aiAnalysis.value?.executiveSummary) {
      pdf.setFontSize(16)
      pdf.setTextColor(26, 32, 44)
      pdf.text('Resumo Executivo (IA)', 20, currentY)
      currentY += 10

      pdf.setFontSize(10)
      pdf.setTextColor(77, 85, 104)
      const summaryLines = pdf.splitTextToSize(aiAnalysis.value.executiveSummary, pageWidth - 40)
      summaryLines.forEach((line: string, index: number) => {
        pdf.text(line, 20, currentY + (index * 5))
      })
      currentY += summaryLines.length * 5 + 10
    }

    // Insights da IA
    if (aiAnalysis.value?.insights?.length) {
      pdf.setFontSize(14)
      pdf.setTextColor(26, 32, 44)
      pdf.text('Insights Estratégicos (IA)', 20, currentY)
      currentY += 8

      pdf.setFontSize(9)
      pdf.setTextColor(77, 85, 104)
      aiAnalysis.value.insights.slice(0, 5).forEach((insight: string, index: number) => {
        const insightLines = pdf.splitTextToSize(`• ${insight}`, pageWidth - 45)
        insightLines.forEach((line: string, lineIndex: number) => {
          pdf.text(line, 25, currentY + (index * 10) + (lineIndex * 4))
        })
        currentY += insightLines.length * 4
      })
      currentY += 10
    }

    // Estatísticas avançadas
    pdf.setFontSize(14)
    pdf.setTextColor(26, 32, 44)
    pdf.text('Métricas de Performance', 20, currentY)
    currentY += 10

    const advancedStats = [
      `Total de Vendas: R$ ${formatCurrency(analytics.value.sales.totalSales || 0)}`,
      `Performance de Vendas: ${salesPerformance.value}%`,
      `Performance de Estoque: ${stockPerformance.value}%`,
      `Eficiência Operacional: ${efficiencyPerformance.value}%`,
      `Taxa de Entrada: ${movementMetrics.value.entryRate}%`,
      `Taxa de Saída: ${movementMetrics.value.exitRate}%`,
      `Balanço de Movimentações: ${movementMetrics.value.balance}%`,
      `Valor do Estoque: R$ ${formatCurrency(analytics.value.stock.totalValue || 0)}`
    ]

    pdf.setFontSize(10)
    pdf.setTextColor(77, 85, 104)
    advancedStats.forEach((stat, index) => {
      pdf.text(stat, 20, currentY + (index * 5))
    })
    currentY += advancedStats.length * 5 + 15

    // Capturar gráficos avançados
    const chartsContainer = document.querySelector('.charts-grid') as HTMLElement
    if (chartsContainer) {
      const canvas = await html2canvas(chartsContainer, {
        background: '#ffffff',
        logging: false,
        scale: 2,
        useCORS: true
      })

      const imgData = canvas.toDataURL('image/png', 1.0)
      const imgWidth = pageWidth - 40
      const imgHeight = (canvas.height * imgWidth) / canvas.width

      if (currentY + imgHeight > pageHeight - 20) {
        pdf.addPage()
        currentY = 20
      }

      pdf.setFontSize(14)
      pdf.setTextColor(26, 32, 44)
      pdf.text('Gráficos Avançados de Análise', 20, currentY)
      currentY += 10
      pdf.addImage(imgData, 'PNG', 20, currentY, imgWidth, Math.min(imgHeight, pageHeight - currentY - 20))
    }

    // Nova página para recomendações da IA
    if (aiAnalysis.value?.recommendations?.length) {
      pdf.addPage()
      currentY = 20

      pdf.setFontSize(16)
      pdf.setTextColor(26, 32, 44)
      pdf.text('Recomendações Estratégicas (IA)', 20, currentY)
      currentY += 15

      pdf.setFontSize(10)
      pdf.setTextColor(77, 85, 104)
      aiAnalysis.value.recommendations.forEach((rec: string, index: number) => {
        const recLines = pdf.splitTextToSize(`${index + 1}. ${rec}`, pageWidth - 40)
        recLines.forEach((line: string, lineIndex: number) => {
          pdf.text(line, 20, currentY + (lineIndex * 5))
        })
        currentY += recLines.length * 5 + 5

        if (currentY > pageHeight - 30) {
          pdf.addPage()
          currentY = 20
        }
      })
    }

    // Salvar PDF avançado
    pdf.save(`relatorio-avancado-ia-${selectedPeriod.value}-${format(new Date(), 'yyyy-MM-dd')}.pdf`)

  } catch (error) {
    console.error('Erro ao exportar PDF:', error)
    alert('Erro ao exportar relatório avançado em PDF')
  } finally {
    loading.value = false
  }
}

async function exportToPowerBI() {
  try {
    showExportMenu.value = false

    const powerBIData = {
      metadata: {
        title: 'GestãoZe Business Intelligence Dataset',
        description: 'Dados avançados para análise no Power BI',
        period: selectedPeriod.value,
        generatedAt: new Date().toISOString(),
        aiAnalysisIncluded: !!aiAnalysis.value
      },
      businessMetrics: {
        totalSales: analytics.value.sales?.totalSales || 0,
        totalProducts: analytics.value.stock?.totalProducts || 0,
        stockValue: analytics.value.stock?.totalValue || 0,
        performanceScore: aiAnalysis.value?.performanceScore || 0,
        salesPerformance: salesPerformance.value,
        stockPerformance: stockPerformance.value,
        efficiencyPerformance: efficiencyPerformance.value
      },
      salesData: analytics.value.sales?.dailySales || [],
      stockData: analytics.value.stock?.categoryBreakdown || [],
      movementsData: analytics.value.movements?.dailyMovements || [],
      aiInsights: {
        executiveSummary: aiAnalysis.value?.executiveSummary || '',
        insights: aiAnalysis.value?.insights || [],
        recommendations: aiAnalysis.value?.recommendations || [],
        predictions: aiAnalysis.value?.predictions || [],
        alerts: aiAnalysis.value?.alerts || []
      },
      kpis: {
        movementBalance: movementMetrics.value.balance,
        entryRate: movementMetrics.value.entryRate,
        exitRate: movementMetrics.value.exitRate,
        lowStockCount: analytics.value.stock?.lowStockCount || 0,
        outOfStockCount: analytics.value.stock?.outOfStockCount || 0
      }
    }

    const jsonString = JSON.stringify(powerBIData, null, 2)
    const blob = new Blob([jsonString], { type: 'application/json' })
    const url = URL.createObjectURL(blob)

    const link = document.createElement('a')
    link.href = url
    link.download = `powerbi-dataset-${selectedPeriod.value}-${format(new Date(), 'yyyy-MM-dd')}.json`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)

  } catch (error) {
    console.error('Erro ao exportar para Power BI:', error)
    alert('Erro ao exportar dataset para Power BI')
  }
}

async function exportToExcel() {
  try {
    showExportMenu.value = false

    const workbook = XLSX.utils.book_new()

    // Planilha de Resumo Avançado
    const summaryData = [
      ['Relatório Avançado com IA - GestãoZe'],
      [''],
      [`Período: ${periods.find(p => p.value === selectedPeriod.value)?.label}`],
      [`Gerado em: ${format(new Date(), 'dd/MM/yyyy HH:mm', { locale: ptBR })}`],
      [''],
      ['MÉTRICAS DE PERFORMANCE'],
      ['Total de Vendas', `R$ ${formatCurrency(analytics.value.sales.totalSales || 0)}`],
      ['Performance de Vendas', `${salesPerformance.value}%`],
      ['Performance de Estoque', `${stockPerformance.value}%`],
      ['Eficiência Operacional', `${efficiencyPerformance.value}%`],
      ['Score Geral IA', aiAnalysis.value?.performanceScore || 0],
      ['Taxa de Entrada', `${movementMetrics.value.entryRate}%`],
      ['Taxa de Saída', `${movementMetrics.value.exitRate}%`],
      ['Balanço', `${movementMetrics.value.balance}%`],
      ['Total de Produtos', analytics.value.stock.totalProducts || 0],
      ['Produtos em Falta', analytics.value.stock.outOfStockCount || 0],
      ['Valor do Estoque', `R$ ${formatCurrency(analytics.value.stock.totalValue || 0)}`]
    ]

    const summarySheet = XLSX.utils.aoa_to_sheet(summaryData)
    XLSX.utils.book_append_sheet(workbook, summarySheet, 'Resumo Avançado')

    // Planilha de Análise da IA
    if (aiAnalysis.value) {
      const aiData = [
        ['ANÁLISE DA INTELIGÊNCIA ARTIFICIAL'],
        [''],
        ['RESUMO EXECUTIVO'],
        [aiAnalysis.value.executiveSummary || 'Não disponível'],
        [''],
        ['INSIGHTS ESTRATÉGICOS'],
        ...(aiAnalysis.value.insights || []).map((insight: string) => [insight]),
        [''],
        ['RECOMENDAÇÕES'],
        ...(aiAnalysis.value.recommendations || []).map((rec: string) => [rec]),
        [''],
        ['PREVISÕES'],
        ...(aiAnalysis.value.predictions || []).map((pred: string) => [pred]),
        [''],
        ['ALERTAS'],
        ...(aiAnalysis.value.alerts || []).map((alert: string) => [alert])
      ]

      const aiSheet = XLSX.utils.aoa_to_sheet(aiData)
      XLSX.utils.book_append_sheet(workbook, aiSheet, 'Análise IA')
    }

    // Planilha de Vendas Detalhadas
    if (analytics.value.sales?.dailySales?.length > 0) {
      const salesData = [
        ['Data', 'Vendas (R$)', 'Média Móvel', 'Crescimento (%)'],
        ...analytics.value.sales.dailySales.map((sale: any, index: number) => {
          const prevSale = index > 0 ? analytics.value.sales.dailySales[index - 1] : null
          const growth = prevSale ? ((sale.total - prevSale.total) / prevSale.total * 100).toFixed(2) : '0.00'

          return [
            format(new Date(sale.date), 'dd/MM/yyyy'),
            sale.total?.toFixed(2) || '0.00',
            '', // Média móvel seria calculada aqui
            growth + '%'
          ]
        })
      ]

      const salesSheet = XLSX.utils.aoa_to_sheet(salesData)
      XLSX.utils.book_append_sheet(workbook, salesSheet, 'Vendas Detalhadas')
    }

    // Planilha de Performance por Categoria
    if (analytics.value.stock?.categoryBreakdown?.length > 0) {
      const categoryData = [
        ['Categoria', 'Produtos', 'Percentual', 'Performance'],
        ...analytics.value.stock.categoryBreakdown.map((cat: any) => {
          const total = analytics.value.stock.categoryBreakdown.reduce((sum: number, c: any) => sum + c.count, 0)
          const percentage = total > 0 ? ((cat.count / total) * 100).toFixed(2) : '0.00'
          const performance = cat.count > 5 ? 'Excelente' : cat.count > 2 ? 'Boa' : 'Regular'

          return [
            cat.category,
            cat.count,
            percentage + '%',
            performance
          ]
        })
      ]

      const categorySheet = XLSX.utils.aoa_to_sheet(categoryData)
      XLSX.utils.book_append_sheet(workbook, categorySheet, 'Performance Categorias')
    }

    // Salvar arquivo avançado
    XLSX.writeFile(workbook, `relatorio-avancado-ia-${selectedPeriod.value}-${format(new Date(), 'yyyy-MM-dd')}.xlsx`)

  } catch (error) {
    console.error('Erro ao exportar Excel avançado:', error)
    alert('Erro ao exportar relatório avançado em Excel')
  }
}

function exportToCSV() {
  try {
    showExportMenu.value = false

    let csvContent = 'data:text/csv;charset=utf-8,'
    csvContent += 'Relatório de Análises - GestãoZe\n\n'
    csvContent += `Período: ${periods.find(p => p.value === selectedPeriod.value)?.label}\n`
    csvContent += `Gerado em: ${format(new Date(), 'dd/MM/yyyy HH:mm', { locale: ptBR })}\n\n`

    // Resumo
    csvContent += 'RESUMO EXECUTIVO\n'
    csvContent += `Total de Vendas,R$ ${formatCurrency(analytics.value.sales.totalSales || 0)}\n`
    csvContent += `Total de Produtos,${analytics.value.stock.totalProducts || 0}\n`
    csvContent += `Produtos em Falta,${analytics.value.stock.outOfStockCount || 0}\n`
    csvContent += `Valor do Estoque,R$ ${formatCurrency(analytics.value.stock.totalValue || 0)}\n\n`

    // Produtos com estoque baixo
    if (analytics.value.stock.lowStockProducts?.length > 0) {
      csvContent += 'PRODUTOS COM ESTOQUE BAIXO\n'
      csvContent += 'Produto,Estoque Atual,Unidade,Estoque Mínimo,Status\n'

      analytics.value.stock.lowStockProducts.forEach((product: any) => {
        csvContent += `"${product.nome}",${product.current_stock},"${product.unidade}",${product.min_stock},Baixo\n`
      })
    }

    const encodedUri = encodeURI(csvContent)
    const link = document.createElement('a')
    link.setAttribute('href', encodedUri)
    link.setAttribute('download', `relatorio-gestao-${selectedPeriod.value}-${format(new Date(), 'yyyy-MM-dd')}.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

  } catch (error) {
    console.error('Erro ao exportar CSV:', error)
    alert('Erro ao exportar relatório em CSV')
  }
}

function exportToJSON() {
  try {
    showExportMenu.value = false

    const reportData = {
      metadata: {
        title: 'Relatório de Análises - GestãoZe',
        period: periods.find(p => p.value === selectedPeriod.value)?.label,
        generatedAt: format(new Date(), 'dd/MM/yyyy HH:mm', { locale: ptBR }),
        periodValue: selectedPeriod.value
      },
      analytics: analytics.value,
      charts: {
        salesData: salesChartData.value,
        categoryData: categoryChartData.value,
        movementsData: movementsChartData.value
      }
    }

    const jsonString = JSON.stringify(reportData, null, 2)
    const blob = new Blob([jsonString], { type: 'application/json' })
    const url = URL.createObjectURL(blob)

    const link = document.createElement('a')
    link.href = url
    link.download = `relatorio-gestao-${selectedPeriod.value}-${format(new Date(), 'yyyy-MM-dd')}.json`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    URL.revokeObjectURL(url)

  } catch (error) {
    console.error('Erro ao exportar JSON:', error)
    alert('Erro ao exportar relatório em JSON')
  }
}

async function exportToImage() {
  try {
    loading.value = true
    showExportMenu.value = false

    const container = document.querySelector('.reports-container') as HTMLElement
    if (!container) return

    const canvas = await html2canvas(container, {
      background: '#ffffff',
      logging: false,
      useCORS: true,
      allowTaint: true
    })

    const link = document.createElement('a')
    link.download = `relatorio-gestao-${selectedPeriod.value}-${format(new Date(), 'yyyy-MM-dd')}.png`
    link.href = canvas.toDataURL('image/png')
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

  } catch (error) {
    console.error('Erro ao exportar imagem:', error)
    alert('Erro ao exportar relatório como imagem')
  } finally {
    loading.value = false
  }
}

// Fechar dropdown ao clicar fora
function handleClickOutside(event: Event) {
  if (exportDropdown.value && !exportDropdown.value.contains(event.target as Node)) {
    showExportMenu.value = false
  }
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

function formatDate(dateString: string): string {
  return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
}

// Watchers
watch(selectedPeriod, () => {
  loadAnalytics()
})

// Computed
const currentPeriodLabel = computed(() => {
  return periods.find(p => p.value === selectedPeriod.value)?.label || '30 dias'
})

const hasAIAnalysis = computed(() => {
  return !!aiAnalysis.value && Object.keys(aiAnalysis.value).length > 0
})

const overallHealthScore = computed(() => {
  if (!hasAIAnalysis.value) return 0
  return Math.round((salesPerformance.value + stockPerformance.value + efficiencyPerformance.value) / 3)
})

// Lifecycle
onMounted(() => {
  loadAnalytics()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.reports-container {
  padding: 0;
  width: 100vw;
  background: linear-gradient(135deg, var(--theme-background) 0%, #f8fafc 100%);
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
}

.page-header {
  margin: 0;
  padding: 0;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, var(--theme-surface) 0%, #ffffff 100%);
  padding: 24px 32px;
  border-bottom: 1px solid var(--theme-border);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08), 0 2px 8px rgba(0, 0, 0, 0.04);
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(10px);
}

.header-content h1 {
  display: flex;
  align-items: center;
  gap: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
  font-size: 28px;
  font-weight: 800;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

/* Dropdown de Exportação */
.export-dropdown {
  position: relative;
}

.rotate-180 {
  transform: rotate(180deg);
  transition: transform 0.3s ease;
}

.export-menu {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  background: var(--theme-surface);
  border: 1px solid var(--theme-border);
  border-radius: 12px;
  box-shadow: 0 10px 40px var(--theme-shadow);
  min-width: 200px;
  z-index: 1000;
  animation: slideDown 0.2s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.export-option {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 12px 16px;
  background: none;
  border: none;
  color: var(--theme-text-primary);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: left;
  border-radius: 0;
}

.export-option:first-child {
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
}

.export-option:last-child {
  border-bottom-left-radius: 12px;
  border-bottom-right-radius: 12px;
}

.export-option:hover {
  background: var(--theme-primary);
  color: white;
}

.export-option svg {
  opacity: 0.8;
  transition: opacity 0.2s ease;
}

.export-option:hover svg {
  opacity: 1;
}

.btn-primary, .btn-secondary, .btn-ai {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  border-radius: 12px;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: none;
  cursor: pointer;
  font-size: 14px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  position: relative;
  overflow: hidden;
}

.btn-primary::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.btn-primary:hover:not(:disabled)::before {
  left: 100%;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-ai {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  position: relative;
  overflow: hidden;
}

.btn-ai::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  transition: width 0.3s, height 0.3s;
}

.btn-ai:hover:not(:disabled)::after {
  width: 300px;
  height: 300px;
}

.btn-ai:hover:not(:disabled) {
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 12px 35px rgba(79, 172, 254, 0.4);
}

.btn-ai:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  background: #cbd5e0;
}

.btn-secondary {
  background: var(--theme-surface);
  color: var(--theme-text-primary);
  border: 2px solid var(--theme-border);
}

.btn-secondary:hover {
  background: var(--theme-border);
  border-color: var(--theme-primary);
}

.filters-section {
  margin: 0;
  background: linear-gradient(135deg, var(--theme-surface) 0%, #f7fafc 100%);
  padding: 24px 32px;
  border-bottom: 1px solid var(--theme-border);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 32px;
  flex-wrap: wrap;
}

.chart-type-selector {
  flex: 1;
  min-width: 300px;
}

.chart-type-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.chart-type-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: var(--theme-surface);
  border: 2px solid var(--theme-border);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
  color: var(--theme-text-secondary);
  font-size: 13px;
}

.chart-type-btn:hover {
  background: var(--theme-border);
  color: var(--theme-text-primary);
  transform: translateY(-1px);
}

.chart-type-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.period-selector label {
  display: block;
  font-weight: 600;
  color: var(--theme-text-primary);
  margin-bottom: 12px;
}

.period-buttons {
  display: flex;
  gap: 8px;
}

.period-btn {
  padding: 8px 16px;
  background: var(--theme-surface);
  border: 2px solid var(--theme-border);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
  color: var(--theme-text-secondary);
}

.period-btn:hover {
  background: var(--theme-border);
  color: var(--theme-text-primary);
}

.period-btn.active {
  background: var(--theme-primary);
  color: white;
  border-color: var(--theme-primary);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  padding: 32px;
  margin: 0;
}

.stat-card {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px var(--theme-shadow);
  border: 1px solid var(--theme-border);
  display: flex;
  align-items: center;
  gap: 16px;
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-card.primary .stat-icon { background: linear-gradient(135deg, #667eea, #764ba2); }
.stat-card.info .stat-icon { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
.stat-card.warning .stat-icon { background: linear-gradient(135deg, #f59e0b, #d97706); }
.stat-card.success .stat-icon { background: linear-gradient(135deg, #10b981, #059669); }

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 800;
  color: var(--theme-text-primary);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: var(--theme-text-secondary);
  font-weight: 500;
  margin-bottom: 8px;
}

.stat-change {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.stat-change.positive { color: #10b981; }
.stat-change.negative { color: #ef4444; }
.stat-change.neutral { color: #64748b; }

.charts-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  padding: 0 32px 32px;
  margin: 0;
}

.chart-panel {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px var(--theme-shadow);
  border: 1px solid var(--theme-border);
}

.chart-panel.full-width {
  grid-column: span 2;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.panel-header h2 {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 700;
  color: var(--theme-text-primary);
  margin: 0;
}

.chart-controls {
  display: flex;
  gap: 8px;
}

.chart-btn {
  padding: 6px 12px;
  background: #f7fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 12px;
  font-weight: 500;
  color: #64748b;
}

.chart-btn:hover {
  background: #e2e8f0;
}

.chart-btn.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.chart-container {
  height: 300px;
  position: relative;
}

.chart-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #64748b;
  gap: 16px;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.tables-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  padding: 0 32px 32px;
  margin: 0;
}

.data-panel {
  background: var(--theme-surface);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px var(--theme-shadow);
  border: 1px solid var(--theme-border);
}

.count-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.count-badge.warning {
  background: #fed7d7;
  color: #c53030;
}

.table-container {
  max-height: 400px;
  overflow-y: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th,
.data-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #f1f5f9;
}

.data-table th {
  background: var(--theme-border);
  font-weight: 600;
  color: var(--theme-text-primary);
  font-size: 14px;
}

.data-table td {
  color: var(--theme-text-secondary);
  font-size: 14px;
}

.product-name {
  font-weight: 600;
  color: var(--theme-text-primary);
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
}

.status-badge.warning {
  background: #fed7d7;
  color: #c53030;
}

.status-badge.success {
  background: #c6f6d5;
  color: #2f855a;
}

.status-badge.danger {
  background: #fed7d7;
  color: #c53030;
}

.empty-table {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: var(--theme-text-muted);
  gap: 12px;
}

.view-all-link {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: var(--theme-primary);
  text-decoration: none;
  font-weight: 500;
  transition: color 0.3s ease;
}

.view-all-link:hover {
  color: var(--theme-secondary);
}

/* Responsividade */
@media (max-width: 1024px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }

  .chart-panel.full-width {
    grid-column: span 1;
  }

  .tables-grid {
    grid-template-columns: 1fr;
  }
}

/* Estilos da Análise IA */
.ai-analysis-section {
  margin: 0;
  padding: 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.ai-panel {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  color: var(--theme-text-primary);
}

.ai-panel .panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f1f5f9;
}

.performance-score {
  display: flex;
  align-items: center;
  gap: 12px;
}

.score-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--theme-text-secondary);
}

.score-value {
  font-size: 24px;
  font-weight: 800;
  padding: 8px 16px;
  border-radius: 12px;
  color: white;
}

.score-value.excellent { background: linear-gradient(135deg, #10b981 0%, #059669 100%); }
.score-value.good { background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%); }
.score-value.fair { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); }
.score-value.poor { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); }

.ai-content {
  display: grid;
  gap: 24px;
}

.executive-summary {
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  padding: 20px;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.executive-summary h3 {
  margin: 0 0 12px 0;
  color: var(--theme-text-primary);
  font-size: 16px;
  font-weight: 700;
}

.executive-summary p {
  margin: 0;
  line-height: 1.6;
  color: var(--theme-text-secondary);
}

.insights-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.insight-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f5f9;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.insight-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
}

.insight-card.alerts {
  background: linear-gradient(135deg, #fef2f2 0%, #fecaca 100%);
  border-color: #fca5a5;
}

.insight-card h4 {
  margin: 0 0 12px 0;
  font-size: 14px;
  font-weight: 700;
  color: var(--theme-text-primary);
}

.insight-card ul {
  margin: 0;
  padding: 0;
  list-style: none;
}

.insight-card li {
  padding: 8px 0;
  border-bottom: 1px solid #f1f5f9;
  font-size: 13px;
  line-height: 1.5;
  color: var(--theme-text-secondary);
}

.insight-card li:last-child {
  border-bottom: none;
}

.insight-card li:before {
  content: '▸';
  color: #667eea;
  font-weight: bold;
  margin-right: 8px;
}

/* Gráficos Avançados */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
  padding: 32px;
  margin: 0;
}

.chart-panel.primary-chart {
  grid-column: span 2;
}

.chart-panel.gauge-panel {
  display: flex;
  flex-direction: column;
}

.gauge-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.gauge-chart {
  position: relative;
  width: 200px;
  height: 120px;
}

.gauge-center {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -30%);
  text-align: center;
}

.gauge-score {
  font-size: 36px;
  font-weight: 800;
  color: var(--theme-text-primary);
}

.gauge-label {
  font-size: 12px;
  color: var(--theme-text-secondary);
  font-weight: 600;
}

.performance-indicators {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.indicator {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.indicator span {
  font-size: 12px;
  font-weight: 600;
  color: var(--theme-text-secondary);
  min-width: 80px;
}

.indicator-bar {
  flex: 1;
  height: 6px;
  background: #f1f5f9;
  border-radius: 3px;
  margin-left: 12px;
  overflow: hidden;
}

.indicator-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.8s ease;
}

.indicator.excellent .indicator-fill { background: linear-gradient(90deg, #10b981, #059669); }
.indicator.good .indicator-fill { background: linear-gradient(90deg, #3b82f6, #1d4ed8); }
.indicator.fair .indicator-fill { background: linear-gradient(90deg, #f59e0b, #d97706); }
.indicator.poor .indicator-fill { background: linear-gradient(90deg, #ef4444, #dc2626); }

.chart-metrics {
  display: flex;
  gap: 20px;
  align-items: center;
}

.metric {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.metric-label {
  font-size: 11px;
  color: var(--theme-text-secondary);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.metric-value {
  font-size: 16px;
  font-weight: 800;
}

.metric-value.positive { color: #10b981; }
.metric-value.negative { color: #ef4444; }
.metric-value.neutral { color: #64748b; }

.ai-analysis-btn {
  margin-right: 12px;
}

@media (max-width: 1200px) {
  .chart-panel.primary-chart {
    grid-column: span 1;
  }

  .charts-grid {
    grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  }
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
    padding: 20px;
  }

  .header-actions {
    justify-content: center;
    flex-wrap: wrap;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    padding: 20px;
  }

  .charts-grid {
    padding: 0 20px 20px;
    grid-template-columns: 1fr;
  }

  .tables-grid {
    padding: 0 20px 20px;
  }

  .filters-section {
    padding: 20px;
    flex-direction: column;
    gap: 20px;
  }

  .period-buttons, .chart-type-buttons {
    flex-direction: column;
  }

  .export-menu {
    right: auto;
    left: 0;
    min-width: 180px;
  }

  .ai-analysis-section {
    padding: 20px;
  }

  .ai-panel {
    padding: 20px;
  }

  .insights-grid {
    grid-template-columns: 1fr;
  }

  .chart-metrics {
    flex-direction: column;
    gap: 12px;
  }

  .performance-score {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>