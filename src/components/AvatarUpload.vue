<template>
  <div class="avatar-upload">
    <div class="avatar-container" @click="triggerFileInput" :class="{ disabled: isUploading }">
      <div class="avatar">
        <img v-if="currentAvatarUrl" :src="currentAvatarUrl" :alt="userName || 'Avatar'" />
        <User v-else :size="size || 32" />
      </div>
      <div class="upload-overlay" :class="{ loading: isUploading }">
        <Loader2 v-if="isUploading" :size="16" class="animate-spin" />
        <Camera v-else :size="16" />
      </div>
    </div>

    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      @change="handleFileSelect"
      style="display: none"
    />

    <!-- Preview Modal -->
    <Teleport to="body">
      <div v-if="showPreview" class="preview-modal" @click="closePreview">
        <div class="preview-content" @click.stop>
          <div class="preview-header">
            <h3>Confirmar nova foto do perfil</h3>
            <button @click="closePreview" class="close-btn" :disabled="isUploading">
              <X :size="20" />
            </button>
          </div>

          <div class="preview-body">
            <div class="preview-image">
              <img :src="previewUrl" alt="Preview" />
            </div>

            <div class="image-info">
              <div class="info-item">
                <FileImage :size="16" />
                <span>{{ selectedFile?.name }}</span>
              </div>
              <div class="info-item">
                <HardDrive :size="16" />
                <span>{{ formatFileSize(selectedFile?.size || 0) }}</span>
              </div>
              <div class="info-item" v-if="resizedFile">
                <Minimize2 :size="16" />
                <span>Será redimensionado para {{ targetSize }}x{{ targetSize }}px</span>
              </div>
            </div>
          </div>

          <div class="preview-actions">
            <button @click="closePreview" class="btn-secondary" :disabled="isUploading">
              <X :size="16" />
              Cancelar
            </button>
            <button @click="confirmUpload" class="btn-primary" :disabled="isUploading">
              <Upload :size="16" />
              <span v-if="isUploading">Enviando...</span>
              <span v-else>Confirmar e Salvar</span>
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Error/Success Messages -->
    <Transition name="message">
      <div v-if="message.text" :class="['message', message.type]">
        <component :is="message.type === 'error' ? AlertCircle : CheckCircle" :size="16" />
        {{ message.text }}
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from 'vue'
import {
  User, Camera, Upload, X, AlertCircle, CheckCircle, Loader2,
  FileImage, HardDrive, Minimize2
} from 'lucide-vue-next'
import { resizeImage, validateImageFile, generateImagePreview, type ResizeOptions } from '@/utils/imageUtils'

interface Props {
  avatarUrl?: string
  userName?: string
  size?: number
  targetSize?: number // tamanho final da imagem
  maxFileSize?: number // em MB
}

interface Emits {
  (e: 'upload-success', url: string): void
  (e: 'upload-error', error: string): void
  (e: 'upload-start'): void
}

const props = withDefaults(defineProps<Props>(), {
  size: 80,
  targetSize: 400,
  maxFileSize: 10
})

const emit = defineEmits<Emits>()

// Estados reativos
const fileInput = ref<HTMLInputElement>()
const isUploading = ref(false)
const showPreview = ref(false)
const previewUrl = ref('')
const selectedFile = ref<File | null>(null)
const resizedFile = ref<File | null>(null)
const currentAvatarUrl = ref(props.avatarUrl)

// Sistema de mensagens
const message = ref<{ text: string; type: 'success' | 'error' | '' }>({
  text: '',
  type: ''
})

// Computed
const avatarSize = computed(() => `${props.size}px`)

// Funções
function triggerFileInput() {
  if (isUploading.value) return
  fileInput.value?.click()
}

function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

function showMessage(text: string, type: 'success' | 'error') {
  message.value = { text, type }
  setTimeout(() => {
    message.value = { text: '', type: '' }
  }, 5000)
}

async function handleFileSelect(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  // Reset estados
  selectedFile.value = null
  resizedFile.value = null
  previewUrl.value = ''

  try {
    // Validar arquivo
    const validation = validateImageFile(file)
    if (!validation.valid) {
      showMessage(validation.error!, 'error')
      return
    }

    selectedFile.value = file
    showMessage('Preparando imagem...', 'success')

    // Gerar preview original
    const originalPreview = await generateImagePreview(file)

    // Redimensionar imagem
    const resizeOptions: ResizeOptions = {
      maxWidth: props.targetSize,
      maxHeight: props.targetSize,
      quality: 0.9
    }

    const resized = await resizeImage(file, resizeOptions)
    resizedFile.value = resized

    // Gerar preview final
    previewUrl.value = await generateImagePreview(resized)
    showPreview.value = true

    console.log('📸 Arquivo original:', formatFileSize(file.size))
    console.log('🔄 Arquivo redimensionado:', formatFileSize(resized.size))

  } catch (error: any) {
    console.error('Erro ao processar imagem:', error)
    showMessage('Erro ao processar imagem: ' + error.message, 'error')
  } finally {
    // Reset input
    if (fileInput.value) {
      fileInput.value.value = ''
    }
  }
}

function closePreview() {
  if (isUploading.value) return

  showPreview.value = false
  previewUrl.value = ''
  selectedFile.value = null
  resizedFile.value = null
}

async function confirmUpload() {
  if (!resizedFile.value) {
    showMessage('Nenhuma imagem selecionada', 'error')
    return
  }

  isUploading.value = true
  emit('upload-start')

  try {
    showMessage('Enviando imagem...', 'success')

    // Upload da imagem redimensionada
    const avatarUrl = await uploadAvatar(resizedFile.value)

    // Atualizar avatar local imediatamente
    currentAvatarUrl.value = avatarUrl

    showMessage('Avatar atualizado com sucesso!', 'success')
    emit('upload-success', avatarUrl)
    closePreview()

  } catch (error: any) {
    console.error('Erro no upload:', error)
    const errorMsg = error.message || 'Erro ao fazer upload da imagem'
    showMessage(errorMsg, 'error')
    emit('upload-error', errorMsg)
  } finally {
    isUploading.value = false
  }
}

// Integração com profileService
async function uploadAvatar(file: File): Promise<string> {
  const { profileService } = await import('@/services/profileService')
  return await profileService.uploadAvatar(file)
}

// Watch para atualizar avatar quando prop mudar
import { watch } from 'vue'
watch(() => props.avatarUrl, (newUrl) => {
  currentAvatarUrl.value = newUrl
})
</script>

<style scoped>
.avatar-upload {
  position: relative;
  display: inline-block;
}

.avatar-container {
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
}

.avatar-container:hover:not(.disabled) {
  transform: scale(1.05);
}

.avatar-container.disabled {
  cursor: not-allowed;
  opacity: 0.7;
}

.avatar {
  width: v-bind(avatarSize);
  height: v-bind(avatarSize);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  position: relative;
  overflow: hidden;
  border: 3px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.upload-overlay {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 28px;
  height: 28px;
  background: #4facfe;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  border: 3px solid white;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(79, 172, 254, 0.4);
}

.upload-overlay:hover {
  background: #00f2fe;
  transform: scale(1.1);
}

.upload-overlay.loading {
  background: #f59e0b;
  cursor: not-allowed;
}

.preview-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(10px);
  padding: 1rem;
}

.preview-content {
  background: white;
  border-radius: 20px;
  padding: 2rem;
  max-width: 500px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.preview-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.1);
  color: #333;
}

.close-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.preview-body {
  margin-bottom: 1.5rem;
}

.preview-image {
  text-align: center;
  margin-bottom: 1.5rem;
}

.preview-image img {
  max-width: 200px;
  max-height: 200px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid #667eea;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
}

.image-info {
  background: #f8fafc;
  border-radius: 12px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #64748b;
}

.preview-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

.btn-primary, .btn-secondary {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  font-weight: 600;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: rgba(0, 0, 0, 0.05);
  color: #666;
  border: 1px solid rgba(0, 0, 0, 0.1);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.message {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 0.75rem;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 500;
}

.message.success {
  background: rgba(16, 185, 129, 0.1);
  color: #065f46;
  border: 1px solid rgba(16, 185, 129, 0.2);
}

.message.error {
  background: rgba(239, 68, 68, 0.1);
  color: #dc2626;
  border: 1px solid rgba(239, 68, 68, 0.2);
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Transições */
.message-enter-active, .message-leave-active {
  transition: all 0.3s ease;
}

.message-enter-from, .message-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* Responsividade */
@media (max-width: 768px) {
  .preview-content {
    width: 95%;
    padding: 1.5rem;
  }

  .preview-actions {
    flex-direction: column;
  }

  .btn-primary, .btn-secondary {
    width: 100%;
    justify-content: center;
  }

  .preview-image img {
    max-width: 150px;
    max-height: 150px;
  }
}
</style>