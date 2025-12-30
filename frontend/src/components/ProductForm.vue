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
          <label for="coverUrl">封面图片URL *</label>
          <input
            id="coverUrl"
            v-model="formData.coverUrl"
            type="url"
            required
            class="skeuomorphic-input"
            placeholder="请输入封面图片URL"
          />
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
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

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
  price: 0,
  stock: 0,
  status: 'ON_SALE',
  features: '{}'
})

watch(() => props.product, (newProduct) => {
  if (newProduct) {
    formData.value = {
      title: newProduct.title || '',
      category: newProduct.category || '',
      description: newProduct.description || '',
      coverUrl: newProduct.coverUrl || '',
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
      price: 0,
      stock: 0,
      status: 'ON_SALE',
      features: '{}'
    }
  }
}, { immediate: true })

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
</style>
