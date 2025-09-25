import { ChartConfiguration } from 'chart.js'

export interface AdvancedChartData {
  type: 'line' | 'bar' | 'doughnut' | 'radar' | 'bubble' | 'scatter' | 'polarArea' | 'heatmap'
  data: any
  options: any
  config?: ChartConfiguration
}

export class AdvancedChartsService {

  // Gráfico de Performance de Vendas com Múltiplas Métricas
  generateSalesPerformanceChart(salesData: any[], _period: string): AdvancedChartData {
    const labels = salesData.map(item => item.date)
    const sales = salesData.map(item => item.total)
    const movingAverage = this.calculateMovingAverage(sales, 7)

    return {
      type: 'line',
      data: {
        labels,
        datasets: [
          {
            label: 'Vendas Diárias',
            data: sales,
            borderColor: '#667eea',
            backgroundColor: 'rgba(102, 126, 234, 0.1)',
            fill: true,
            tension: 0.4,
            pointBackgroundColor: '#667eea',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 4
          },
          {
            label: 'Média Móvel (7 dias)',
            data: movingAverage,
            borderColor: '#f093fb',
            backgroundColor: 'transparent',
            borderWidth: 2,
            borderDash: [5, 5],
            pointRadius: 0,
            tension: 0.4
          }
        ]
      },
      options: this.getAdvancedLineOptions('Vendas por Período', 'R$')
    }
  }

  // Gráfico Radar de Performance por Categoria
  generateCategoryRadarChart(categoryData: any[]): AdvancedChartData {
    const labels = categoryData.map(item => item.category)
    const values = categoryData.map(item => item.count)
    const maxValue = Math.max(...values)
    const normalizedValues = values.map(v => (v / maxValue) * 100)

    return {
      type: 'radar',
      data: {
        labels,
        datasets: [{
          label: 'Performance por Categoria',
          data: normalizedValues,
          backgroundColor: 'rgba(102, 126, 234, 0.2)',
          borderColor: '#667eea',
          borderWidth: 2,
          pointBackgroundColor: '#667eea',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: '#667eea'
        }]
      },
      options: {
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
      }
    }
  }

  // Gráfico de Bubble para Análise de Produtos
  generateProductBubbleChart(productsData: any[]): AdvancedChartData {
    const bubbleData = productsData.map(product => ({
      x: product.current_stock || 0,  // Estoque atual
      y: product.preco || 0,          // Preço
      r: Math.sqrt((product.sales_volume || 1) * 2), // Volume de vendas (raio)
      label: product.nome,
      color: this.getColorByPerformance(product.performance_score || 50)
    }))

    return {
      type: 'bubble',
      data: {
        datasets: [{
          label: 'Análise de Produtos',
          data: bubbleData,
          backgroundColor: bubbleData.map(item => item.color + '80'),
          borderColor: bubbleData.map(item => item.color),
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
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
      }
    }
  }

  // Gráfico de Area Stacked para Movimentações
  generateStackedAreaChart(movementsData: any[]): AdvancedChartData {
    const labels = movementsData.map(item => item.date)
    const entriesData = movementsData.map(item => item.in || 0)
    const exitsData = movementsData.map(item => item.out || 0)

    return {
      type: 'line',
      data: {
        labels,
        datasets: [
          {
            label: 'Entradas',
            data: entriesData,
            backgroundColor: 'rgba(72, 187, 120, 0.6)',
            borderColor: '#48bb78',
            borderWidth: 2,
            fill: true,
            tension: 0.4
          },
          {
            label: 'Saídas',
            data: exitsData.map(val => -val), // Valores negativos para visualização
            backgroundColor: 'rgba(245, 101, 101, 0.6)',
            borderColor: '#f56565',
            borderWidth: 2,
            fill: true,
            tension: 0.4
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: 'index' as const,
          intersect: false
        },
        plugins: {
          legend: {
            position: 'top' as const,
            labels: {
              color: '#64748b',
              font: { size: 12, weight: 'bold' },
              usePointStyle: true
            }
          }
        },
        scales: {
          x: {
            title: {
              display: true,
              text: 'Período',
              color: '#64748b',
              font: { weight: 'bold' }
            },
            grid: { display: false },
            ticks: { color: '#64748b' }
          },
          y: {
            title: {
              display: true,
              text: 'Quantidade',
              color: '#64748b',
              font: { weight: 'bold' }
            },
            grid: { color: 'rgba(100, 116, 139, 0.2)' },
            ticks: {
              color: '#64748b',
              callback: (value: any) => Math.abs(value) // Mostrar valores absolutos
            }
          }
        }
      }
    }
  }

  // Gráfico Polar Area para Distribuição de Estoque
  generatePolarAreaChart(stockData: any[]): AdvancedChartData {
    const labels = stockData.map(item => item.category)
    const values = stockData.map(item => item.totalValue)

    return {
      type: 'polarArea',
      data: {
        labels,
        datasets: [{
          data: values,
          backgroundColor: [
            'rgba(102, 126, 234, 0.8)',
            'rgba(118, 75, 162, 0.8)',
            'rgba(240, 147, 251, 0.8)',
            'rgba(79, 172, 254, 0.8)',
            'rgba(67, 233, 123, 0.8)',
            'rgba(250, 112, 154, 0.8)'
          ],
          borderColor: [
            '#667eea', '#764ba2', '#f093fb', '#4facfe', '#43e97b', '#fa709a'
          ],
          borderWidth: 2
        }]
      },
      options: {
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
            ticks: {
              display: false
            },
            grid: {
              color: 'rgba(100, 116, 139, 0.3)'
            }
          }
        }
      }
    }
  }

  // Gráfico de Heatmap para Vendas por Período
  generateHeatmapData(salesData: any[], period: string): any {
    const heatmapData = this.processDataForHeatmap(salesData, period)

    return {
      type: 'matrix',
      data: heatmapData,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              title: () => '',
              label: (context: any) => `${context.label}: R$ ${context.formattedValue}`
            }
          }
        }
      }
    }
  }

  // Gráfico de Gauge para Performance Score
  generateGaugeChart(score: number, _title: string): AdvancedChartData {
    return {
      type: 'doughnut',
      data: {
        datasets: [{
          data: [score, 100 - score],
          backgroundColor: [
            this.getScoreColor(score),
            'rgba(229, 231, 235, 0.3)'
          ],
          borderColor: [
            this.getScoreColor(score),
            'transparent'
          ],
          borderWidth: 0,
          cutout: '75%',
          circumference: 180,
          rotation: 270
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            enabled: false
          }
        }
      }
    }
  }

  // Métodos auxiliares
  private calculateMovingAverage(data: number[], window: number): number[] {
    const result: number[] = []
    for (let i = 0; i < data.length; i++) {
      if (i < window - 1) {
        result.push(data[i])
      } else {
        const slice = data.slice(i - window + 1, i + 1)
        const average = slice.reduce((a, b) => a + b) / window
        result.push(average)
      }
    }
    return result
  }

  private getAdvancedLineOptions(_title: string, yAxisLabel: string): any {
    return {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        mode: 'index' as const,
        intersect: false
      },
      plugins: {
        legend: {
          position: 'top' as const,
          labels: {
            color: '#64748b',
            font: { size: 12, weight: 'bold' },
            usePointStyle: true
          }
        }
      },
      scales: {
        x: {
          title: {
            display: true,
            text: 'Período',
            color: '#64748b',
            font: { weight: 'bold' }
          },
          grid: { display: false },
          ticks: { color: '#64748b' }
        },
        y: {
          title: {
            display: true,
            text: yAxisLabel,
            color: '#64748b',
            font: { weight: 'bold' }
          },
          grid: { color: 'rgba(100, 116, 139, 0.2)' },
          ticks: { color: '#64748b' }
        }
      }
    }
  }

  private getColorByPerformance(score: number): string {
    if (score >= 80) return '#10b981' // Verde
    if (score >= 60) return '#f59e0b' // Amarelo
    if (score >= 40) return '#ef4444' // Vermelho
    return '#6b7280' // Cinza
  }

  private getScoreColor(score: number): string {
    if (score >= 80) return '#10b981'
    if (score >= 60) return '#f59e0b'
    if (score >= 40) return '#ef4444'
    return '#ef4444'
  }

  private processDataForHeatmap(salesData: any[], _period: string): any {
    // Implementação básica - pode ser expandida para dados mais complexos
    const processedData = salesData.map((item, index) => ({
      x: index,
      y: 0,
      v: item.total || 0
    }))

    return {
      datasets: [{
        label: 'Vendas',
        data: processedData,
        backgroundColor: (context: any) => {
          const value = context.parsed?.v || 0
          const max = Math.max(...salesData.map(d => d.total || 0))
          const intensity = value / max
          return `rgba(102, 126, 234, ${intensity})`
        }
      }]
    }
  }
}

export const advancedChartsService = new AdvancedChartsService()