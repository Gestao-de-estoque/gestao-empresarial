/**
 * Utilitários para manipulação de imagens
 */

export interface ResizeOptions {
  maxWidth: number
  maxHeight: number
  quality: number // 0.1 a 1.0
}

/**
 * Redimensiona uma imagem mantendo a proporção
 */
export function resizeImage(file: File, options: ResizeOptions): Promise<File> {
  return new Promise((resolve, reject) => {
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    const img = new Image()

    img.onload = () => {
      // Calcular novas dimensões mantendo a proporção
      let { width, height } = img
      const { maxWidth, maxHeight, quality } = options

      if (width > height) {
        if (width > maxWidth) {
          height = (height * maxWidth) / width
          width = maxWidth
        }
      } else {
        if (height > maxHeight) {
          width = (width * maxHeight) / height
          height = maxHeight
        }
      }

      // Para avatars, fazer sempre quadrado usando a menor dimensão
      const size = Math.min(width, height, maxWidth, maxHeight)
      canvas.width = size
      canvas.height = size

      if (!ctx) {
        reject(new Error('Erro ao criar contexto do canvas'))
        return
      }

      // Preencher fundo branco para transparências
      ctx.fillStyle = '#ffffff'
      ctx.fillRect(0, 0, size, size)

      // Desenhar a imagem centralizada e redimensionada
      const sourceSize = Math.min(img.width, img.height)
      const sx = (img.width - sourceSize) / 2
      const sy = (img.height - sourceSize) / 2

      ctx.drawImage(img, sx, sy, sourceSize, sourceSize, 0, 0, size, size)

      // Converter canvas para blob
      canvas.toBlob(
        (blob) => {
          if (!blob) {
            reject(new Error('Erro ao converter imagem'))
            return
          }

          // Criar novo arquivo com nome otimizado
          const fileName = file.name.replace(/\.[^/.]+$/, '.jpg')
          const resizedFile = new File([blob], fileName, {
            type: 'image/jpeg',
            lastModified: Date.now()
          })

          resolve(resizedFile)
        },
        'image/jpeg',
        quality
      )
    }

    img.onerror = () => reject(new Error('Erro ao carregar imagem'))
    img.src = URL.createObjectURL(file)
  })
}

/**
 * Valida se o arquivo é uma imagem válida
 */
export function validateImageFile(file: File): { valid: boolean; error?: string } {
  const validTypes = ['image/jpeg', 'image/jpg']

  if (!validTypes.includes(file.type)) {
    return {
      valid: false,
      error: 'Formato não suportado. Apenas arquivos JPG são aceitos.'
    }
  }

  // Limite de 10MB para arquivo original (será redimensionado)
  const maxSize = 10 * 1024 * 1024
  if (file.size > maxSize) {
    return {
      valid: false,
      error: 'Arquivo muito grande. Máximo 10MB.'
    }
  }

  return { valid: true }
}

/**
 * Gera preview da imagem para mostrar antes do upload
 */
export function generateImagePreview(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()

    reader.onload = (e) => {
      resolve(e.target?.result as string)
    }

    reader.onerror = () => reject(new Error('Erro ao gerar preview'))

    reader.readAsDataURL(file)
  })
}