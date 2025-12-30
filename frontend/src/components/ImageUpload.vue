<template>
  <div class="image-upload">
    <div class="upload-container">
      <div
        v-if="!imageUrl"
        @click="triggerUpload"
        class="upload-placeholder skeuomorphic-card"
        :class="{ 'drag-over': isDragOver }"
        @dragover.prevent="handleDragOver"
        @dragleave.prevent="handleDragLeave"
        @drop.prevent="handleDrop"
      >
        <div class="upload-icon">📷</div>
        <p class="upload-text">{{ placeholder }}</p>
        <p class="upload-hint">点击或拖拽上传</p>
      </div>

      <div v-else class="image-preview-container">
        <div class="image-preview skeuomorphic-card">
          <img :src="imageUrl" :alt="alt" class="preview-image" />
          <div class="image-actions">
            <button @click.stop="triggerUpload" class="action-button skeuomorphic-button">
              修改图片
            </button>
            <button @click.stop="handleRemove" class="action-button skeuomorphic-button danger">
              删除
            </button>
          </div>
        </div>
      </div>

      <input
        ref="fileInput"
        type="file"
        accept="image/*"
        @change="handleFileChange"
        style="display: none"
      />
    </div>

    <div v-if="processing" class="processing-message">
      <div class="processing-spinner"></div>
      <p>图片处理中...</p>
    </div>

    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <div v-if="uploading" class="upload-progress">
      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: uploadProgress + '%' }"></div>
      </div>
      <p class="progress-text">上传中... {{ uploadProgress }}%</p>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import api from '../api'
import { ImageProcessor } from '../utils/imageProcessor'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    default: 'avatar',
    validator: (value) => ['avatar', 'product-cover', 'product-detail'].includes(value)
  },
  placeholder: {
    type: String,
    default: '上传图片'
  },
  alt: {
    type: String,
    default: '预览图片'
  }
})

const emit = defineEmits(['update:modelValue', 'upload-success', 'upload-error'])

const fileInput = ref(null)
const imageUrl = ref(props.modelValue)
const uploading = ref(false)
const uploadProgress = ref(0)
const error = ref(null)
const isDragOver = ref(false)
const processing = ref(false)

watch(() => props.modelValue, (newValue) => {
  imageUrl.value = newValue
})

const triggerUpload = () => {
  fileInput.value.click()
}

const handleFileChange = (event) => {
  const file = event.target.files[0]
  if (file) {
    processAndUploadFile(file)
  }
  event.target.value = ''
}

const handleDragOver = () => {
  isDragOver.value = true
}

const handleDragLeave = () => {
  isDragOver.value = false
}

const handleDrop = (event) => {
  isDragOver.value = false
  const file = event.dataTransfer.files[0]
  if (file && file.type.startsWith('image/')) {
    processAndUploadFile(file)
  }
}

const processAndUploadFile = async (file) => {
  if (!validateFile(file)) {
    return
  }

  try {
    processing.value = true
    error.value = null

    let processedFile = file

    switch (props.type) {
      case 'avatar':
        processedFile = await ImageProcessor.createAvatar(file, 300)
        break
      case 'product-cover':
        processedFile = await ImageProcessor.createCoverImage(file)
        break
      case 'product-detail':
        processedFile = await ImageProcessor.createDetailImage(file)
        break
    }

    await uploadFile(processedFile)
  } catch (err) {
    error.value = err.message || '图片处理失败'
    emit('upload-error', error.value)
    console.error('Process error:', err)
  } finally {
    processing.value = false
  }
}

const uploadFile = async (file) => {
  try {
    uploading.value = true
    uploadProgress.value = 0
    error.value = null

    const formData = new FormData()
    formData.append('file', file)

    let endpoint
    switch (props.type) {
      case 'avatar':
        endpoint = '/upload/avatar'
        break
      case 'product-cover':
        endpoint = '/upload/product/cover'
        break
      case 'product-detail':
        endpoint = '/upload/product/detail'
        break
      default:
        endpoint = '/upload/avatar'
    }

    uploadProgress.value = 50

    const response = await api.upload(endpoint, formData, {
      onUploadProgress: (progressEvent) => {
        const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
        uploadProgress.value = progress
      }
    })

    uploadProgress.value = 100

    if (response.code === 200) {
      const oldImageUrl = imageUrl.value
      imageUrl.value = response.data.url
      emit('update:modelValue', response.data.url)
      emit('upload-success', response.data.url)
      
      if (oldImageUrl) {
        try {
          await api.deleteFile(oldImageUrl)
        } catch (err) {
          console.error('Delete old image error:', err)
        }
      }
    } else {
      error.value = response.msg || '上传失败'
      emit('upload-error', error.value)
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
    emit('upload-error', error.value)
    console.error('Upload error:', err)
  } finally {
    uploading.value = false
  }
}

const validateFile = (file) => {
  if (!file.type.startsWith('image/')) {
    error.value = '请上传图片文件'
    return false
  }

  if (file.size > 10 * 1024 * 1024) {
    error.value = '图片大小不能超过10MB'
    return false
  }

  error.value = null
  return true
}

const handleRemove = async () => {
  if (imageUrl.value) {
    try {
      await api.deleteFile(imageUrl.value)
    } catch (err) {
      console.error('Delete image error:', err)
    }
  }
  imageUrl.value = ''
  emit('update:modelValue', '')
}
</script>

<style scoped>
.image-upload {
  width: 100%;
}

.upload-container {
  width: 100%;
}

.upload-placeholder {
  width: 100%;
  min-height: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 3px dashed #d1d9e6;
}

.upload-placeholder:hover {
  border-color: #667eea;
  transform: translateY(-2px);
}

.upload-placeholder.drag-over {
  border-color: #667eea;
  background: linear-gradient(145deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
}

.upload-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.upload-text {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.upload-hint {
  font-size: 14px;
  color: #999;
}

.image-preview-container {
  width: 100%;
}

.image-preview {
  width: 100%;
  padding: 16px;
}

.preview-image {
  width: 100%;
  height: auto;
  max-height: 400px;
  object-fit: contain;
  border-radius: 12px;
  box-shadow: 
    4px 4px 8px #d1d9e6,
    -4px -4px 8px #ffffff;
}

.image-actions {
  display: flex;
  gap: 12px;
  margin-top: 16px;
  justify-content: center;
}

.action-button {
  padding: 10px 20px;
  font-size: 14px;
}

.action-button.danger {
  background: linear-gradient(145deg, #fee, #fcc);
  color: #c33;
}

.action-button.danger:hover {
  background: linear-gradient(145deg, #fdd, #fbb);
}

.error-message {
  padding: 12px 16px;
  background: linear-gradient(145deg, #fee, #fcc);
  border-radius: 12px;
  color: #c33;
  font-size: 14px;
  margin-top: 12px;
  box-shadow: 
    inset 2px 2px 4px #fdd,
    inset -2px -2px 4px #fff;
}

.upload-progress {
  margin-top: 12px;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: linear-gradient(145deg, #f0f0f0, #ffffff);
  border-radius: 4px;
  overflow: hidden;
  box-shadow: 
    inset 2px 2px 4px #d1d9e6,
    inset -2px -2px 4px #ffffff;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  transition: width 0.3s ease;
  border-radius: 4px;
}

.progress-text {
  font-size: 12px;
  color: #666;
  margin-top: 8px;
  text-align: center;
}

.processing-message {
  padding: 20px;
  background: linear-gradient(145deg, #f0f0f0, #ffffff);
  border-radius: 12px;
  margin-top: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  box-shadow: 
    inset 2px 2px 4px #d1d9e6,
    inset -2px -2px 4px #ffffff;
}

.processing-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f0f0f0;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.processing-message p {
  font-size: 14px;
  color: #666;
  margin: 0;
}
</style>
