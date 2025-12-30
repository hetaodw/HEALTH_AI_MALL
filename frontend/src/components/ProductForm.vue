<template>
  <div class="product-form-modal">
    <div class="skeuomorphic-modal">
      <h2>{{ product ? '编辑商品' : '添加商品' }}</h2>
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
          <ImageUpload 
            v-model="formData.coverUrl" 
            type="product-cover" 
            placeholder="上传商品封面图片" 
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

        <div class="form-actions">
          <button type="button" @click="$emit('cancel')" class="skeuomorphic-button">
            取消
          </button>
          <button type="submit" class="skeuomorphic-button primary">
            {{ product ? '保存' : '添加' }}
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

const props = defineProps({
  product: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['submit', 'cancel'])

const formData = ref({
  title: '',
  category: '',
  description: '',
  coverUrl: '',
  detailImages: [],
  price: 0,
  stock: 0,
  status: 'ON_SALE',
  features: '{}'
})

const showDetailImageUpload = ref(false)
const newDetailImageUrl = ref('')
const editingDetailImageIndex = ref(null)

watch(() => props.product, (newProduct) => {
  if (newProduct) {
    formData.value = {
      title: newProduct.title || '',
      category: newProduct.category || '',
      description: newProduct.description || '',
      coverUrl: newProduct.coverUrl || '',
      detailImages: newProduct.detailImages || [],
      price: newProduct.price || 0,
      stock: newProduct.stock || 0,
      status: newProduct.status || 'ON_SALE',
      features: typeof newProduct.features === 'object' 
        ? JSON.stringify(newProduct.features) 
        : (newProduct.features || '{}')
    }
  } else {
    formData.value = {
      title: '',
      category: '',
      description: '',
      coverUrl: '',
      detailImages: [],
      price: 0,
      stock: 0,
      status: 'ON_SALE',
      features: '{}'
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
  showDetailImageUpload.value = false
}

const editDetailImage = (index) => {
  editingDetailImageIndex.value = index
  newDetailImageUrl.value = formData.value.detailImages[index]
  showDetailImageUpload.value = true
}

const handleDetailImageUploadError = (error) => {
  console.error('Detail image upload error:', error)
  alert('详情图片上传失败：' + error)
}

const removeDetailImage = (index) => {
  formData.value.detailImages.splice(index, 1)
}

const handleSubmit = () => {
  try {
    const submitData = { ...formData.value }
    
    submitData.price = parseFloat(submitData.price)
    submitData.stock = parseInt(submitData.stock)
    
    try {
      submitData.features = JSON.parse(submitData.features)
    } catch (e) {
      submitData.features = {}
    }
    
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
