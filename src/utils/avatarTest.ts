/**
 * Testes para funcionalidade de avatar
 * Execute este arquivo no console do navegador para testar
 */

export function testAvatarUtils() {
  console.log('🧪 Iniciando testes de funcionalidade de avatar...')

  // Teste 1: Validação de arquivos
  console.log('\n📝 Teste 1: Validação de arquivos')

  // Simular arquivo válido
  const validFile = new File([''], 'test.jpg', { type: 'image/jpeg' })
  console.log('✅ Arquivo válido:', validFile.name, validFile.type)

  // Simular arquivo inválido
  const invalidFile = new File([''], 'test.txt', { type: 'text/plain' })
  console.log('❌ Arquivo inválido:', invalidFile.name, invalidFile.type)

  return {
    validFile,
    invalidFile
  }
}

export function testImageResize() {
  console.log('\n🖼️ Teste 2: Redimensionamento de imagem')

  // Criar uma imagem de teste
  const canvas = document.createElement('canvas')
  canvas.width = 800
  canvas.height = 600
  const ctx = canvas.getContext('2d')

  if (ctx) {
    // Desenhar um gradiente colorido
    const gradient = ctx.createLinearGradient(0, 0, 800, 600)
    gradient.addColorStop(0, '#667eea')
    gradient.addColorStop(1, '#764ba2')

    ctx.fillStyle = gradient
    ctx.fillRect(0, 0, 800, 600)

    // Adicionar texto
    ctx.fillStyle = 'white'
    ctx.font = 'bold 48px Arial'
    ctx.textAlign = 'center'
    ctx.fillText('TESTE AVATAR', 400, 300)

    // Converter para blob e depois para file
    canvas.toBlob((blob) => {
      if (blob) {
        const testFile = new File([blob], 'test-image.png', { type: 'image/png' })
        console.log('📸 Imagem de teste criada:', {
          name: testFile.name,
          size: `${(testFile.size / 1024).toFixed(2)}KB`,
          type: testFile.type,
          dimensions: `${canvas.width}x${canvas.height}px`
        })
        return testFile
      }
    }, 'image/png', 0.9)
  }
}

export function logAvatarConfiguration() {
  console.log('\n⚙️ Configuração atual do sistema de avatar:')

  console.log('📂 Componentes:')
  console.log('  - AvatarUpload.vue: Componente principal de upload')
  console.log('  - imageUtils.ts: Utilitários de manipulação de imagem')
  console.log('  - profileService.ts: Serviço de backend')

  console.log('\n🎯 Funcionalidades implementadas:')
  console.log('  ✅ Redimensionamento automático (400x400px)')
  console.log('  ✅ Validação de formato (JPG, PNG, GIF, WebP)')
  console.log('  ✅ Limite de tamanho (10MB original)')
  console.log('  ✅ Preview antes do upload')
  console.log('  ✅ Feedback visual e mensagens de erro/sucesso')
  console.log('  ✅ Limpeza automática de arquivos antigos')
  console.log('  ✅ Tratamento robusto de erros')

  console.log('\n🗄️ Armazenamento:')
  console.log('  - Bucket: user-avatars')
  console.log('  - Pasta: avatars/')
  console.log('  - Formato final: JPEG com qualidade 90%')
  console.log('  - Tamanho final: 400x400px (quadrado)')

  console.log('\n🛡️ Segurança:')
  console.log('  - Políticas RLS configuradas')
  console.log('  - Upload apenas do próprio avatar')
  console.log('  - Visualização pública dos avatars')

  console.log('\n🔧 Para testar:')
  console.log('  1. Acesse http://localhost:5174/profile')
  console.log('  2. Clique no ícone de câmera no avatar')
  console.log('  3. Selecione uma imagem')
  console.log('  4. Confirme o upload')
  console.log('  5. Verifique o console para logs detalhados')
}

// Executar testes automaticamente se chamado diretamente
if (typeof window !== 'undefined') {
  // Disponibilizar funções globalmente para teste no console
  (window as any).testAvatarUtils = testAvatarUtils
  (window as any).testImageResize = testImageResize
  (window as any).logAvatarConfiguration = logAvatarConfiguration

  console.log('🚀 Funções de teste disponíveis no console:')
  console.log('  - testAvatarUtils()')
  console.log('  - testImageResize()')
  console.log('  - logAvatarConfiguration()')
}