<template>
  <div class="avatar-upload">
    <div class="avatar-preview" @click="triggerFileInput">
      <img v-if="avatarUrl" :src="avatarUrl" alt="头像" class="avatar-image" />
      <div v-else class="avatar-placeholder">
        <span class="avatar-icon">👤</span>
        <span class="avatar-text">点击上传头像</span>
      </div>
      <div class="avatar-overlay">
        <span class="upload-icon">📷</span>
      </div>
    </div>
    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      style="display: none"
      @change="handleFileChange"
    />
    <div v-if="uploading" class="upload-status">上传中...</div>
    <div v-if="error" class="upload-error">{{ error }}</div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import api from '../api'

const props = defineProps({
  currentAvatar: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['avatar-updated'])

const fileInput = ref(null)
const uploading = ref(false)
const error = ref('')

const avatarUrl = computed(() => props.currentAvatar)

const triggerFileInput = () => {
  fileInput.value.click()
}

const handleFileChange = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  // 验证文件类型
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/jpg']
  if (!allowedTypes.includes(file.type)) {
    error.value = '请上传图片文件 (JPG, PNG, GIF)'
    return
  }

  // 验证文件大小 (5MB)
  const maxSize = 5 * 1024 * 1024
  if (file.size > maxSize) {
    error.value = '图片大小不能超过5MB'
    return
  }

  error.value = ''
  uploading.value = true

  try {
    const formData = new FormData()
    formData.append('file', file)

    const response = await api.user.uploadAvatar(formData)
    
    if (response.code === 200) {
      emit('avatar-updated', response.data.avatarUrl)
      alert('头像上传成功！')
    } else {
      error.value = response.msg || '上传失败'
    }
  } catch (err) {
    console.error('上传头像失败:', err)
    error.value = err.response?.data?.msg || '上传失败，请重试'
  } finally {
    uploading.value = false
    // 清空input，允许重复选择同一文件
    event.target.value = ''
  }
}
</script>

<style scoped>
.avatar-upload {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.avatar-preview {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  position: relative;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  box-shadow: 
    8px 8px 16px #d1d9e6,
    -8px -8px 16px #ffffff;
  transition: all 0.3s ease;
}

.avatar-preview:hover {
  transform: scale(1.05);
  box-shadow: 
    12px 12px 24px #d1d9e6,
    -12px -12px 24px #ffffff;
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #666;
}

.avatar-icon {
  font-size: 40px;
  margin-bottom: 4px;
}

.avatar-text {
  font-size: 12px;
  text-align: center;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.avatar-preview:hover .avatar-overlay {
  opacity: 1;
}

.upload-icon {
  font-size: 32px;
  color: white;
}

.upload-status {
  color: #667eea;
  font-size: 14px;
}

.upload-error {
  color: #e74c3c;
  font-size: 12px;
  text-align: center;
  max-width: 150px;
}
</style>
