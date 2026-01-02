<template>
  <div class="product-image-form">
    <div class="skeuomorphic-modal">
      <h2>{{ product ? '编辑商品图片' : '添加商品图片' }}</h2>
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label>封面图片</label>
          <ImageUpload 
            v-model="formData.coverUrl" 
            type="product-cover" 
            placeholder="上传商品封面图片" 
            :auto-delete-old="false"
            @upload-success="handleCoverUploadSuccess"
            @upload-error="handleCoverUploadError"
          />
        </div>

        <div class="form-group">
          <label>详情图片</label>
          <div class="detail-images-container">
            <div v-for="(image, index) in formData.detailImages" :key="index" class="detail-image-item">
              <img :src="image" :alt="`详情图片${index + 1}`" class="detail-image-preview" />
              <div class="detail-image-actions">
                <button @click="editDetailImage(index)" class="edit-button" title="修改图片">✎</button>
                <button @click="removeDetailImage(index)" class="remove-button" title="删除图片">×</button>
              </div>
            </div>
            <div v-if="formData.detailImages.length < 5" class="add-detail-image" @click="showDetailImageUpload = true">
              <span class="add-icon">+</span>
              <span class="add-text">添加详情图</span>
            </div>
          </div>
          <p class="form-hint">最多可上传5张详情图片，将自动调整为16:9比例</p>
        </div>

        <div class="form-actions">
          <button type="button" @click="$emit('cancel')" class="skeuomorphic-button">
            取消
          </button>
          <button type="submit" class="skeuomorphic-button primary">
            {{ product ? '保存图片' : '添加图片' }}
          </button>
        </div>
      </form>
    </div>

    <div v-if="showDetailImageUpload" class="modal-overlay" @click="showDetailImageUpload = false">
      <div class="detail-image-modal skeuomorphic-modal" @click.stop>
        <h3>{{ editingDetailImageIndex !== null ? '修改详情图片' : '上传详情图片' }}</h3>
        <ImageUpload 
          v-model="newDetailImageUrl" 
          type="product-detail" 
          :placeholder="editingDetailImageIndex !== null ? '修改商品详情图片' : '上传商品详情图片'" 
          :auto-delete-old="false"
          @upload-success="handleDetailImageUploadSuccess"
          @upload-error="handleDetailImageUploadError"
        />
        <div class="modal-actions">
          <button @click="showDetailImageUpload = false" class="skeuomorphic-button">
            取消
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import ImageUpload from './ImageUpload.vue'
import api from '../api'

const props = defineProps({
  product: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['submit', 'cancel'])

const formData = ref({
  coverUrl: '',
  detailImages: []
})

const showDetailImageUpload = ref(false)
const newDetailImageUrl = ref('')
const editingDetailImageIndex = ref(null)
const oldImages = ref({
  coverUrl: '',
  detailImages: []
})
const isEditMode = ref(false)

watch(() => props.product, (newProduct) => {
  if (newProduct) {
    isEditMode.value = true
    oldImages.value = {
      coverUrl: newProduct.coverUrl || '',
      detailImages: [...(newProduct.detailImages || [])]
    }
    formData.value = {
      coverUrl: newProduct.coverUrl || '',
      detailImages: newProduct.detailImages || []
    }
  } else {
    isEditMode.value = false
    oldImages.value = {
      coverUrl: '',
      detailImages: []
    }
    formData.value = {
      coverUrl: '',
      detailImages: []
    }
  }
}, { immediate: true })

const handleCoverUploadSuccess = (url) => {
  formData.value.coverUrl = url
}

const handleCoverUploadError = (error) => {
  console.error('Cover upload error:', error)
  alert('封面图片上传失败：' + error)
}

const handleDetailImageUploadSuccess = (url) => {
  if (editingDetailImageIndex.value !== null) {
    formData.value.detailImages[editingDetailImageIndex.value] = url
  } else if (formData.value.detailImages.length < 5) {
    formData.value.detailImages.push(url)
  }
  newDetailImageUrl.value = ''
  editingDetailImageIndex.value = null
}

const editDetailImage = (index) => {
  editingDetailImageIndex.value = index
  newDetailImageUrl.value = formData.value.detailImages[index]
  showDetailImageUpload.value = true
}

const handleDetailImageUploadError = (error) => {
  console.error('Detail image upload error:', error)
}

const removeDetailImage = (index) => {
  formData.value.detailImages.splice(index, 1)
}

const handleSubmit = async () => {
  try {
    const submitData = { 
      coverUrl: formData.value.coverUrl,
      detailImages: formData.value.detailImages
    }
    
    emit('submit', submitData)
  } catch (error) {
    console.error('图片表单验证失败:', error)
    alert('请检查图片表单数据是否正确')
  }
}

const cleanupOldImages = async () => {
  const imagesToDelete = []
  
  if (isEditMode.value) {
    if (oldImages.value.coverUrl && oldImages.value.coverUrl !== formData.value.coverUrl) {
      imagesToDelete.push(oldImages.value.coverUrl)
    }
    
    oldImages.value.detailImages.forEach(oldImg => {
      if (!formData.value.detailImages.includes(oldImg)) {
        imagesToDelete.push(oldImg)
      }
    })
  }
  
  for (const url of imagesToDelete) {
    try {
      await api.deleteFile(url)
      console.log('Deleted old image:', url)
    } catch (err) {
      console.error('Failed to delete old image:', url, err)
    }
  }
}

defineExpose({
  cleanupOldImages
})
</script>

<style scoped>
.product-image-form {
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

.skeuomorphic-modal h2 {
  margin: 0 0 24px 0;
  font-size: 24px;
  color: #333;
  text-align: center;
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

.form-actions .skeuomorphic-button.primary {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  box-shadow: 
    4px 4px 8px rgba(102, 126, 234, 0.3),
    -4px -4px 8px rgba(255, 255, 255, 0.8);
}

.form-actions .skeuomorphic-button.primary:hover {
  background: linear-gradient(145deg, #764ba2, #667eea);
  box-shadow: 
    6px 6px 12px rgba(102, 126, 234, 0.4),
    -6px -6px 12px rgba(255, 255, 255, 0.8);
}

@media (max-width: 768px) {
  .skeuomorphic-modal {
    padding: 24px;
    margin: 16px;
  }

  .form-actions {
    flex-direction: column;
  }

  .form-actions .skeuomorphic-button {
    width: 100%;
  }
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.detail-image-modal {
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.detail-image-modal h3 {
  margin: 0 0 24px 0;
  font-size: 20px;
  color: #333;
  text-align: center;
}

.detail-images-container {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 8px;
}

.detail-image-item {
  position: relative;
  width: 100px;
  height: 100px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
}

.detail-image-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.detail-image-actions {
  position: absolute;
  top: 4px;
  right: 4px;
  display: flex;
  gap: 4px;
}

.edit-button {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(145deg, #e0f7fa, #b2ebf2);
  color: #006064;
  font-size: 12px;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 
    2px 2px 4px rgba(0, 0, 0, 0.1),
    -2px -2px 4px rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
}

.edit-button:hover {
  background: linear-gradient(145deg, #b2ebf2, #80deea);
  transform: scale(1.1);
}

.remove-button {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(145deg, #fee, #fcc);
  color: #c33;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 
    2px 2px 4px rgba(0, 0, 0, 0.1),
    -2px -2px 4px rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
}

.remove-button:hover {
  background: linear-gradient(145deg, #fdd, #fbb);
  transform: scale(1.1);
}

.add-detail-image {
  width: 100px;
  height: 100px;
  border-radius: 12px;
  border: 2px dashed #d1d9e6;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
}

.add-detail-image:hover {
  border-color: #667eea;
  transform: translateY(-2px);
}

.add-icon {
  font-size: 32px;
  color: #667eea;
  margin-bottom: 4px;
}

.add-text {
  font-size: 12px;
  color: #999;
}

.form-hint {
  font-size: 12px;
  color: #999;
  margin-top: 8px;
  margin-bottom: 0;
}
</style>