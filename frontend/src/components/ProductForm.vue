<template>
  <div class="product-form-modal">
    <div class="skeuomorphic-modal" @click.stop>
      <div class="modal-header">
        <h2>{{ product ? '编辑商品' : '添加商品' }}</h2>
        <button type="button" class="close-btn" @click="$emit('close')" title="关闭">×</button>
      </div>
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label for="title">商品名称 *</label>
          <input
            id="title"
            v-model="formData.title"
            type="text"
            required
            class="skeuomorphic-input"
            placeholder="请输入商品名称"
          />
        </div>

        <div class="form-group">
          <label for="category">商品分类 *</label>
          <select
            id="category"
            v-model="formData.category"
            required
            class="skeuomorphic-input"
          >
            <option value="">请选择分类</option>
            <option value="保健品">保健品</option>
            <option value="医疗器械">医疗器械</option>
            <option value="健康食品">健康食品</option>
            <option value="运动健身">运动健身</option>
            <option value="母婴用品">母婴用品</option>
          </select>
        </div>

        <div class="form-group">
          <label for="description">商品描述 *</label>
          <textarea
            id="description"
            v-model="formData.description"
            required
            class="skeuomorphic-input"
            rows="4"
            placeholder="请输入商品详细描述"
          ></textarea>
        </div>

        <div class="form-group">
          <label>封面图片 *</label>
          <div class="image-upload-area">
            <input
              type="file"
              ref="fileInput"
              @change="handleFileChange"
              accept="image/*"
              style="display: none"
            />
            <div 
              class="upload-placeholder" 
              @click="triggerFileInput"
              v-if="!previewUrl"
            >
              <span class="upload-icon">+</span>
              <span class="upload-text">点击上传封面图片</span>
              <span class="upload-hint">支持 jpg、png、gif 格式，最大 5MB</span>
            </div>
            <div class="image-preview" v-else>
              <img :src="previewUrl" alt="封面预览" />
              <button type="button" class="remove-image" @click="removeImage">×</button>
            </div>
          </div>
        </div>

        <div class="form-group">
          <label for="price">价格 (¥) *</label>
          <input
            id="price"
            v-model.number="formData.price"
            type="number"
            step="0.01"
            min="0"
            required
            class="skeuomorphic-input"
            placeholder="请输入商品价格"
          />
        </div>

        <div class="form-group">
          <label for="stock">库存 *</label>
          <input
            id="stock"
            v-model.number="formData.stock"
            type="number"
            min="0"
            required
            class="skeuomorphic-input"
            placeholder="请输入库存数量"
          />
        </div>

        <div class="form-group">
          <label for="status">商品状态 *</label>
          <select
            id="status"
            v-model="formData.status"
            required
            class="skeuomorphic-input"
          >
            <option value="ON_SALE">在售</option>
            <option value="OFF_SALE">下架</option>
            <option value="OUT_OF_STOCK">缺货</option>
          </select>
        </div>

        <div class="form-group">
          <label for="features">商品特征 (JSON格式)</label>
          <textarea
            id="features"
            v-model="formData.features"
            class="skeuomorphic-input"
            rows="3"
            placeholder='{"key": "value"}'
          ></textarea>
        </div>

        <div class="form-group">
          <label>详细介绍图片</label>
          <div class="detail-images-section">
            <input
              type="file"
              ref="detailFileInput"
              @change="handleDetailFileChange"
              accept="image/*"
              multiple
              style="display: none"
            />
            <div class="detail-images-list">
              <div 
                v-for="(image, index) in detailImages" 
                :key="index"
                class="detail-image-item"
              >
                <img :src="image.preview" alt="详情图片" />
                <button type="button" class="remove-detail-image" @click="removeDetailImage(index)">×</button>
              </div>
              <div class="upload-placeholder detail-upload" @click="triggerDetailFileInput">
                <span class="upload-icon">+</span>
                <span class="upload-text">添加图片</span>
              </div>
            </div>
            <span class="upload-hint">支持多张图片，每张最大 5MB</span>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" @click="$emit('cancel')" class="skeuomorphic-button">
            取消
          </button>
          <button type="submit" class="skeuomorphic-button primary" :disabled="!isValid">
            {{ product ? '保存' : '添加' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'

const props = defineProps({
  product: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['submit', 'cancel', 'close'])

const fileInput = ref(null)
const selectedFile = ref(null)
const previewUrl = ref('')

const detailFileInput = ref(null)
const detailImages = ref([])

const formData = ref({
  title: '',
  category: '',
  description: '',
  price: 0,
  stock: 0,
  status: 'ON_SALE',
  features: '{}'
})

const isValid = computed(() => {
  return formData.value.title && 
         formData.value.category && 
         formData.value.description && 
         (selectedFile.value || props.product) &&
         formData.value.price >= 0 && 
         formData.value.stock >= 0
})

watch(() => props.product, (newProduct) => {
  if (newProduct) {
    formData.value = {
      title: newProduct.title || '',
      category: newProduct.category || '',
      description: newProduct.description || '',
      price: newProduct.price || 0,
      stock: newProduct.stock || 0,
      status: newProduct.status || 'ON_SALE',
      features: typeof newProduct.features === 'object' 
        ? JSON.stringify(newProduct.features) 
        : (newProduct.features || '{}')
    }
    if (newProduct.coverUrl) {
      previewUrl.value = newProduct.coverUrl
    }
  } else {
    resetForm()
  }
}, { immediate: true })

const resetForm = () => {
  formData.value = {
    title: '',
    category: '',
    description: '',
    price: 0,
    stock: 0,
    status: 'ON_SALE',
    features: '{}'
  }
  selectedFile.value = null
  previewUrl.value = ''
}

const triggerFileInput = (event) => {
  if (event) {
    event.preventDefault()
    event.stopPropagation()
  }
  fileInput.value.click()
}

const handleFileChange = (event) => {
  const file = event.target.files[0]
  if (!file) return

  // 验证文件类型
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
  if (!allowedTypes.includes(file.type)) {
    alert('请上传图片文件（jpg、png、gif）')
    return
  }

  // 验证文件大小（5MB）
  const maxSize = 5 * 1024 * 1024
  if (file.size > maxSize) {
    alert('文件大小不能超过5MB')
    return
  }

  selectedFile.value = file

  // 创建预览
  const reader = new FileReader()
  reader.onload = (e) => {
    previewUrl.value = e.target.result
  }
  reader.readAsDataURL(file)
}

const removeImage = (event) => {
  if (event) {
    event.preventDefault()
    event.stopPropagation()
  }
  selectedFile.value = null
  previewUrl.value = ''
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const triggerDetailFileInput = (event) => {
  if (event) {
    event.preventDefault()
    event.stopPropagation()
  }
  detailFileInput.value.click()
}

const handleDetailFileChange = (event) => {
  const files = Array.from(event.target.files)
  if (!files.length) return

  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
  const maxSize = 5 * 1024 * 1024

  files.forEach(file => {
    if (!allowedTypes.includes(file.type)) {
      alert(`文件 ${file.name} 格式不支持，仅支持 jpg、png、gif`)
      return
    }
    if (file.size > maxSize) {
      alert(`文件 ${file.name} 大小超过5MB`)
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      detailImages.value.push({
        file: file,
        preview: e.target.result
      })
    }
    reader.readAsDataURL(file)
  })

  event.target.value = ''
}

const removeDetailImage = (index) => {
  detailImages.value.splice(index, 1)
}

const handleSubmit = () => {
  try {
    if (!selectedFile.value && !props.product) {
      alert('请选择封面图片')
      return
    }

    const submitData = new FormData()
    submitData.append('title', formData.value.title)
    submitData.append('category', formData.value.category)
    submitData.append('description', formData.value.description)
    submitData.append('price', formData.value.price.toString())
    submitData.append('stock', formData.value.stock.toString())
    submitData.append('status', formData.value.status)
    
    if (selectedFile.value) {
      submitData.append('coverImage', selectedFile.value)
    }
    
    // 处理 features
    let featuresObj = {}
    try {
      featuresObj = JSON.parse(formData.value.features)
    } catch (e) {
      featuresObj = {}
    }
    submitData.append('features', JSON.stringify(featuresObj))
    
    // 添加详细介绍图片
    detailImages.value.forEach((image, index) => {
      submitData.append(`detailImages`, image.file)
    })

    emit('submit', submitData)
  } catch (error) {
    console.error('表单验证失败:', error)
    alert('请检查表单数据是否正确')
  }
}
</script>

<style scoped>
.product-form-modal {
  width: 100%;
  max-width: 600px;
}

.skeuomorphic-modal {
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 20px;
  padding: 32px;
  box-shadow: 
    10px 10px 20px rgba(0, 0, 0, 0.2),
    -10px -10px 20px rgba(255, 255, 255, 0.8);
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.modal-header h2 {
  margin: 0;
  font-size: 24px;
  color: #333;
  flex: 1;
  text-align: center;
}

.close-btn {
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 50%;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
  font-size: 24px;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  margin-left: 10px;
}

.close-btn:hover {
  color: #ff4444;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.close-btn:active {
  box-shadow: 
    inset 3px 3px 6px #d1d9e6,
    inset -3px -3px 6px #ffffff;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #666;
  font-size: 14px;
}

.form-group .skeuomorphic-input {
  width: 100%;
  padding: 12px 16px;
  font-size: 14px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
  transition: all 0.3s ease;
}

.form-group .skeuomorphic-input:focus {
  outline: none;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff,
    inset 0 0 0 2px rgba(102, 126, 234, 0.1);
}

.form-group textarea.skeuomorphic-input {
  resize: vertical;
  min-height: 80px;
}

/* 图片上传区域样式 */
.image-upload-area {
  border: 2px dashed #ccc;
  border-radius: 12px;
  padding: 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(145deg, #f8f9fa, #e9ecef);
}

.image-upload-area:hover {
  border-color: #667eea;
  background: linear-gradient(145deg, #e9ecef, #dee2e6);
}

.upload-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.upload-icon {
  font-size: 48px;
  color: #999;
  line-height: 1;
}

.upload-text {
  font-size: 16px;
  color: #666;
  font-weight: 500;
}

.upload-hint {
  font-size: 12px;
  color: #999;
}

.image-preview {
  position: relative;
  display: inline-block;
}

.image-preview img {
  max-width: 100%;
  max-height: 200px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.remove-image {
  position: absolute;
  top: -10px;
  right: -10px;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #ff4757;
  color: white;
  border: none;
  font-size: 16px;
  line-height: 1;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  transition: all 0.2s ease;
}

.remove-image:hover {
  background: #ff3838;
  transform: scale(1.1);
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #e0e0e0;
}

.form-actions .skeuomorphic-button {
  padding: 12px 32px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    4px 4px 8px #d1d9e6,
    -4px -4px 8px #ffffff;
}

.form-actions .skeuomorphic-button:hover {
  transform: translateY(-2px);
  box-shadow: 
    6px 6px 12px #d1d9e6,
    -6px -6px 12px #ffffff;
}

.form-actions .skeuomorphic-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.form-actions .skeuomorphic-button.primary {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  box-shadow: 
    4px 4px 8px rgba(102, 126, 234, 0.3),
    -4px -4px 8px rgba(255, 255, 255, 0.8);
}

.form-actions .skeuomorphic-button.primary:hover:not(:disabled) {
  background: linear-gradient(145deg, #764ba2, #667eea);
  box-shadow: 
    6px 6px 12px rgba(102, 126, 234, 0.4),
    -6px -6px 12px rgba(255, 255, 255, 0.8);
}

/* 详细介绍图片样式 */
.detail-images-section {
  border: 2px dashed #ccc;
  border-radius: 12px;
  padding: 16px;
  background: linear-gradient(145deg, #f8f9fa, #e9ecef);
}

.detail-images-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 8px;
}

.detail-image-item {
  position: relative;
  width: 100px;
  height: 100px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.detail-image-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.remove-detail-image {
  position: absolute;
  top: -8px;
  right: -8px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #ff4757;
  color: white;
  border: none;
  font-size: 14px;
  line-height: 1;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.remove-detail-image:hover {
  background: #ff3838;
  transform: scale(1.1);
}

.detail-upload {
  width: 100px;
  height: 100px;
  border: 2px dashed #667eea;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
}

.detail-upload:hover {
  background: linear-gradient(145deg, #e9ecef, #dee2e6);
  border-color: #764ba2;
}

.detail-upload .upload-icon {
  font-size: 32px;
  color: #667eea;
}

.detail-upload .upload-text {
  font-size: 12px;
  color: #667eea;
  margin-top: 4px;
}
</style>
