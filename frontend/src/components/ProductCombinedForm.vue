<template>
  <div class="product-combined-form">
    <div class="skeuomorphic-modal">
      <h2>{{ product ? '编辑商品' : '添加商品' }}</h2>
      
      <div class="form-tabs">
        <button 
          :class="['tab-button', 'skeuomorphic-button', { active: activeTab === 'info' }]"
          @click="activeTab = 'info'"
        >
          商品信息
        </button>
        <button 
          :class="['tab-button', 'skeuomorphic-button', { active: activeTab === 'images' }]"
          @click="activeTab = 'images'"
        >
          商品图片
        </button>
      </div>
      
      <div class="tab-content">
        <div v-show="activeTab === 'info'">
          <ProductForm 
            :product="product"
            @submit="handleInfoSubmit"
            @cancel="handleCancel"
          />
        </div>
        
        <div v-show="activeTab === 'images'">
          <ProductImageForm 
            :product="product"
            @submit="handleImageSubmit"
            @cancel="handleCancel"
          />
        </div>
      </div>
      
      <!-- 如果是编辑模式，显示底部操作按钮 -->
      <div v-if="product && activeTab === 'info'" class="form-actions">
        <button type="button" @click="switchToImagesTab" class="skeuomorphic-button">
          编辑图片
        </button>
        <button type="button" @click="handleCancel" class="skeuomorphic-button">
          取消
        </button>
        <button type="button" @click="submitAll" class="skeuomorphic-button primary">
          保存全部
        </button>
      </div>
      
      <div v-if="product && activeTab === 'images'" class="form-actions">
        <button type="button" @click="switchToInfoTab" class="skeuomorphic-button">
          编辑信息
        </button>
        <button type="button" @click="handleCancel" class="skeuomorphic-button">
          取消
        </button>
        <button type="button" @click="submitAll" class="skeuomorphic-button primary">
          保存全部
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ProductForm from './ProductForm.vue'
import ProductImageForm from './ProductImageForm.vue'

const props = defineProps({
  product: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['submit', 'cancel'])

const activeTab = ref('info')
const infoFormData = ref({})
const imageFormData = ref({})

const handleInfoSubmit = (data) => {
  infoFormData.value = data
  if (!props.product) {
    // 如果是添加模式，提交所有数据
    submitAll()
  } else {
    // 如果是编辑模式，切换到图片标签页
    activeTab.value = 'images'
  }
}

const handleImageSubmit = (data) => {
  imageFormData.value = data
  if (!props.product) {
    // 如果是添加模式，提交所有数据
    submitAll()
  } else {
    // 如果是编辑模式，切换到信息标签页
    activeTab.value = 'info'
  }
}

const handleCancel = () => {
  emit('cancel')
}

const switchToImagesTab = () => {
  activeTab.value = 'images'
}

const switchToInfoTab = () => {
  activeTab.value = 'info'
}

const submitAll = () => {
  const combinedData = {
    ...infoFormData.value,
    ...imageFormData.value
  }
  
  if (props.product) {
    // 编辑模式：只提交有更改的数据
    const updateData = { ...props.product }
    
    // 更新信息字段
    if (Object.keys(infoFormData.value).length > 0) {
      Object.assign(updateData, infoFormData.value)
    }
    
    // 更新图片字段
    if (Object.keys(imageFormData.value).length > 0) {
      Object.assign(updateData, imageFormData.value)
    }
    
    emit('submit', updateData)
  } else {
    // 添加模式：提交所有数据
    emit('submit', combinedData)
  }
}
</script>

<style scoped>
.product-combined-form {
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

.form-tabs {
  display: flex;
  margin-bottom: 24px;
  border-bottom: 1px solid #e0e0e0;
}

.tab-button {
  flex: 1;
  padding: 12px 20px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 12px 12px 0 0;
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(145deg, #f0f0f0, #ffffff);
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
  margin-bottom: -1px;
}

.tab-button:hover {
  background: linear-gradient(145deg, #e0e0e0, #f0f0f0);
}

.tab-button.active {
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  color: #667eea;
  box-shadow: 
    inset 3px 3px 6px #d1d9e6,
    inset -3px -3px 6px #ffffff;
}

.tab-content {
  min-height: 300px;
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
  padding: 12px 24px;
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

  .form-tabs {
    flex-direction: column;
  }

  .tab-button {
    border-radius: 12px;
    margin-bottom: 8px;
  }

  .form-actions {
    flex-direction: column;
  }

  .form-actions .skeuomorphic-button {
    width: 100%;
  }
}
</style>