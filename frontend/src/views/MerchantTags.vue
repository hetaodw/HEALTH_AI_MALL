<template>
  <div class="merchant-tags">
    <div class="dashboard-header">
      <div class="header-left">
        <h1 class="dashboard-title">🏷️ 商品标签管理</h1>
      </div>
      <div class="header-right">
        <button @click="router.push('/merchant')" class="skeuomorphic-button">
          ← 返回商品管理
        </button>
        <button @click="showBatchGenerateModal = true" class="skeuomorphic-button primary">
          🤖 批量生成标签
        </button>
      </div>
    </div>

    <div class="tabs">
      <button 
        v-for="tab in tabs" 
        :key="tab.key"
        @click="activeTab = tab.key"
        :class="['tab-button', { active: activeTab === tab.key }]"
      >
        {{ tab.label }}
      </button>
    </div>

    <div v-if="activeTab === 'manage'" class="tab-content">
      <div class="filters">
        <div class="filter-group">
          <label>商品状态:</label>
          <select v-model="filters.status" @change="loadProducts" class="skeuomorphic-input">
            <option value="">全部</option>
            <option value="ON_SALE">在售</option>
            <option value="OFF_SALE">下架</option>
            <option value="OUT_OF_STOCK">缺货</option>
          </select>
        </div>
        <div class="filter-group">
          <label>商品分类:</label>
          <select v-model="filters.category" @change="loadProducts" class="skeuomorphic-input">
            <option value="">全部</option>
            <option value="保健品">保健品</option>
            <option value="医疗器械">医疗器械</option>
            <option value="健康食品">健康食品</option>
            <option value="运动健身">运动健身</option>
            <option value="母婴用品">母婴用品</option>
          </select>
        </div>
      </div>

      <div v-if="loading" class="loading">加载中...</div>
      <div v-else-if="products.length === 0" class="empty-state">
        <p>暂无商品</p>
      </div>
      <div v-else class="product-list">
        <div v-for="product in products" :key="product.id" class="product-item">
          <div class="product-image">
            <img :src="product.coverUrl" :alt="product.title" />
          </div>
          <div class="product-info">
            <h3 class="product-title">{{ product.title }}</h3>
            <p class="product-category">{{ getCategoryLabel(product.category) }}</p>
            <p class="product-price">¥{{ product.price }}</p>
            <div class="tags-container">
              <div v-if="product.tags && product.tags.length > 0" class="tags">
                <span v-for="tag in product.tags" :key="tag" class="tag">{{ tag }}</span>
              </div>
              <div v-else class="no-tags">暂无标签</div>
            </div>
          </div>
          <div class="product-actions">
            <button @click="generateTags(product.id)" class="skeuomorphic-button small">
              🤖 AI生成
            </button>
            <button @click="editTags(product)" class="skeuomorphic-button small">
              ✏️ 编辑
            </button>
          </div>
        </div>
      </div>

      <div v-if="total > 0" class="pagination">
        <Pagination
          :current-page="pagination.page"
          :total-pages="Math.ceil(total / pagination.size)"
          @page-change="handlePageChange"
        />
      </div>
    </div>

    <div v-if="activeTab === 'popular'" class="tab-content">
      <div class="popular-tags-header">
        <h2>🔥 热门标签</h2>
        <div class="filter-group">
          <label>显示数量:</label>
          <select v-model="popularLimit" @change="loadPopularTags" class="skeuomorphic-input">
            <option :value="10">10</option>
            <option :value="20">20</option>
            <option :value="50">50</option>
            <option :value="100">100</option>
          </select>
        </div>
      </div>
      <div v-if="loadingPopular" class="loading">加载中...</div>
      <div v-else-if="popularTags.length === 0" class="empty-state">
        <p>暂无热门标签</p>
      </div>
      <div v-else class="popular-tags-list">
        <div v-for="item in popularTags" :key="item.tag" class="popular-tag-item">
          <span class="tag-name">{{ item.tag }}</span>
          <span class="tag-count">{{ item.count }} 个商品</span>
        </div>
      </div>
    </div>

    <div v-if="activeTab === 'search'" class="tab-content">
      <div class="search-section">
        <div class="search-input-group">
          <input
            v-model="searchQuery"
            @keyup.enter="searchByTags"
            placeholder="输入标签名称，按回车添加"
            class="skeuomorphic-input"
          />
          <button @click="addToSearchTags" class="skeuomorphic-button">
            添加标签
          </button>
        </div>
        <div class="selected-tags">
          <div v-if="selectedSearchTags.length === 0" class="no-tags">请选择至少一个标签进行搜索</div>
          <div v-else class="tags">
            <span v-for="tag in selectedSearchTags" :key="tag" class="tag selected">
              {{ tag }}
              <button @click="removeSearchTag(tag)" class="remove-tag">×</button>
            </span>
          </div>
        </div>
        <button @click="searchByTags" class="skeuomorphic-button primary search-button" :disabled="selectedSearchTags.length === 0">
          🔍 搜索商品
        </button>
      </div>

      <div v-if="searchResults.length > 0" class="search-results">
        <h3>搜索结果 ({{ searchTotal }})</h3>
        <div class="product-list">
          <div v-for="product in searchResults" :key="product.id" class="product-item">
            <div class="product-image">
              <img :src="product.coverUrl" :alt="product.title" />
            </div>
            <div class="product-info">
              <h3 class="product-title">{{ product.title }}</h3>
              <p class="product-price">¥{{ product.price }}</p>
              <div class="tags-container">
                <div v-if="product.tags && product.tags.length > 0" class="tags">
                  <span v-for="tag in product.tags" :key="tag" class="tag">{{ tag }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showEditModal" class="modal-overlay" @click.self="showEditModal = false">
      <div class="skeuomorphic-modal edit-modal">
        <h2>编辑商品标签</h2>
        <div class="product-info-display">
          <p><strong>商品:</strong> {{ editingProduct?.title }}</p>
        </div>
        <div class="form-group">
          <label>标签 (用逗号分隔):</label>
          <input
            v-model="tagsInput"
            placeholder="例如: 维生素,增强免疫力,抗氧化"
            class="skeuomorphic-input"
          />
          <div class="tags-preview">
            <span v-for="tag in previewTags" :key="tag" class="tag">{{ tag }}</span>
          </div>
        </div>
        <div class="modal-actions">
          <button @click="showEditModal = false" class="skeuomorphic-button">
            取消
          </button>
          <button @click="saveTags" class="skeuomorphic-button primary">
            保存
          </button>
        </div>
      </div>
    </div>

    <div v-if="showBatchGenerateModal" class="modal-overlay" @click.self="showBatchGenerateModal = false">
      <div class="skeuomorphic-modal batch-generate-modal">
        <h2>批量生成标签</h2>
        <div class="form-group">
          <label>选择商品:</label>
          <div class="product-selection">
            <label class="checkbox-item">
              <input type="checkbox" v-model="selectAll" @change="toggleSelectAll" />
              <span>全选</span>
            </label>
            <div class="product-checkbox-list">
              <label v-for="product in products" :key="product.id" class="checkbox-item">
                <input type="checkbox" v-model="selectedProductIds" :value="product.id" />
                <span>{{ product.title }}</span>
              </label>
            </div>
          </div>
        </div>
        <div class="modal-actions">
          <button @click="showBatchGenerateModal = false" class="skeuomorphic-button">
            取消
          </button>
          <button @click="batchGenerateTags" class="skeuomorphic-button primary" :disabled="selectedProductIds.length === 0">
            生成标签 ({{ selectedProductIds.length }})
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import api from '../api'
import Pagination from '../components/Pagination.vue'
import { getCategoryLabel } from '../constants/productCategories'

const router = useRouter()
const userStore = useUserStore()

if (!userStore.isLoggedIn || !userStore.isMerchant()) {
  router.push('/login')
}

const tabs = [
  { key: 'manage', label: '标签管理' },
  { key: 'popular', label: '热门标签' },
  { key: 'search', label: '标签搜索' }
]

const activeTab = ref('manage')

const products = ref([])
const loading = ref(false)
const total = ref(0)
const pagination = ref({
  page: 1,
  size: 10
})

const filters = ref({
  status: '',
  category: ''
})

const showEditModal = ref(false)
const showBatchGenerateModal = ref(false)
const editingProduct = ref(null)
const tagsInput = ref('')

const popularTags = ref([])
const loadingPopular = ref(false)
const popularLimit = ref(20)

const searchQuery = ref('')
const selectedSearchTags = ref([])
const searchResults = ref([])
const searchTotal = ref(0)

const selectedProductIds = ref([])
const selectAll = ref(false)

const previewTags = computed(() => {
  if (!tagsInput.value) return []
  return tagsInput.value.split(',').map(tag => tag.trim()).filter(tag => tag)
})

const loadProducts = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.value.page,
      size: pagination.value.size,
      ...filters.value
    }
    const response = await api.merchant.getProductList(params)
    products.value = response.data.list
    
    for (const product of products.value) {
      try {
        const tagsResponse = await api.productTags.get(product.id)
        if (tagsResponse.code === 200) {
          product.tags = tagsResponse.data
        } else {
          product.tags = []
        }
      } catch (error) {
        product.tags = []
      }
    }
    
    total.value = response.data.total
  } catch (error) {
    console.error('加载商品列表失败:', error)
    alert('加载商品列表失败')
  } finally {
    loading.value = false
  }
}

const handlePageChange = (page) => {
  pagination.value.page = page
  loadProducts()
}

const generateTags = async (productId) => {
  try {
    const response = await api.productTags.generate(productId)
    if (response.code === 200) {
      alert('标签生成成功: ' + response.data.join(', '))
      loadProducts()
    } else {
      alert('标签生成失败: ' + response.msg)
    }
  } catch (error) {
    console.error('生成标签失败:', error)
    alert('生成标签失败: ' + (error.response?.data?.msg || '未知错误'))
  }
}

const editTags = (product) => {
  editingProduct.value = product
  tagsInput.value = product.tags ? product.tags.join(', ') : ''
  showEditModal.value = true
}

const saveTags = async () => {
  try {
    const tags = tagsInput.value.split(',').map(tag => tag.trim()).filter(tag => tag)
    const response = await api.productTags.update(editingProduct.value.id, { tags })
    if (response.code === 200) {
      alert('标签更新成功')
      showEditModal.value = false
      loadProducts()
    } else {
      alert('标签更新失败: ' + response.msg)
    }
  } catch (error) {
    console.error('更新标签失败:', error)
    alert('更新标签失败: ' + (error.response?.data?.msg || '未知错误'))
  }
}

const loadPopularTags = async () => {
  loadingPopular.value = true
  try {
    const response = await api.productTags.getPopular({ limit: popularLimit.value })
    if (response.code === 200) {
      popularTags.value = response.data
    }
  } catch (error) {
    console.error('加载热门标签失败:', error)
    alert('加载热门标签失败')
  } finally {
    loadingPopular.value = false
  }
}

const addToSearchTags = () => {
  const tag = searchQuery.value.trim()
  if (tag && !selectedSearchTags.value.includes(tag)) {
    selectedSearchTags.value.push(tag)
    searchQuery.value = ''
  }
}

const removeSearchTag = (tag) => {
  const index = selectedSearchTags.value.indexOf(tag)
  if (index > -1) {
    selectedSearchTags.value.splice(index, 1)
  }
}

const searchByTags = async () => {
  if (selectedSearchTags.value.length === 0) {
    alert('请选择至少一个标签')
    return
  }

  try {
    const params = {
      tags: selectedSearchTags.value,
      page: 1,
      size: 20
    }
    const response = await api.productTags.search(params)
    if (response.code === 200) {
      searchResults.value = response.data.list
      searchTotal.value = response.data.total
    } else {
      alert('搜索失败: ' + response.msg)
    }
  } catch (error) {
    console.error('搜索失败:', error)
    alert('搜索失败: ' + (error.response?.data?.msg || '未知错误'))
  }
}

const toggleSelectAll = () => {
  if (selectAll.value) {
    selectedProductIds.value = products.value.map(p => p.id)
  } else {
    selectedProductIds.value = []
  }
}

const batchGenerateTags = async () => {
  if (selectedProductIds.value.length === 0) {
    alert('请选择至少一个商品')
    return
  }

  try {
    const response = await api.productTags.batchGenerate({ productIds: selectedProductIds.value })
    if (response.code === 200) {
      const { successCount, failedCount, failedProductIds } = response.data
      let message = `批量生成完成！成功: ${successCount}`
      
      if (failedCount > 0) {
        message += `，失败: ${failedCount}`
        if (failedProductIds && failedProductIds.length > 0) {
          message += '\n失败商品ID: ' + failedProductIds.join(', ')
        }
      }
      
      alert(message)
      showBatchGenerateModal.value = false
      selectedProductIds.value = []
      selectAll.value = false
      loadProducts()
    } else {
      alert('批量生成失败: ' + response.msg)
    }
  } catch (error) {
    console.error('批量生成失败:', error)
    alert('批量生成失败: ' + (error.response?.data?.msg || '未知错误'))
  }
}

onMounted(() => {
  loadProducts()
  loadPopularTags()
})
</script>

<style scoped>
.merchant-tags {
  max-width: 1400px;
  margin: 0 auto;
  padding: 32px 24px;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.dashboard-title {
  font-size: 32px;
  font-weight: 700;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  padding: 8px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.tab-button {
  padding: 12px 24px;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  background: transparent;
  color: #666;
}

.tab-button:hover {
  background: linear-gradient(145deg, #f0f0f0, #ffffff);
}

.tab-button.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
}

.tab-content {
  min-height: 400px;
}

.filters {
  display: flex;
  gap: 24px;
  margin-bottom: 24px;
  padding: 20px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.filter-group label {
  font-weight: 600;
  color: #666;
}

.filter-group select {
  padding: 10px 16px;
  min-width: 150px;
}

.loading,
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #999;
  font-size: 18px;
}

.product-list {
  display: grid;
  gap: 20px;
}

.product-item {
  display: flex;
  gap: 20px;
  padding: 20px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
  transition: all 0.3s ease;
}

.product-item:hover {
  transform: translateY(-2px);
  box-shadow: 
    7px 7px 14px #d1d9e6,
    -7px -7px 14px #ffffff;
}

.product-image {
  width: 120px;
  height: 120px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.product-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.product-category {
  color: #999;
  font-size: 14px;
  margin: 0;
}

.product-price {
  font-size: 24px;
  font-weight: 700;
  color: #667eea;
  margin: 0;
}

.tags-container {
  margin-top: 8px;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  padding: 4px 12px;
  border-radius: 8px;
  font-size: 14px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  box-shadow: 
    2px 2px 4px #d1d9e6,
    -2px -2px 4px #ffffff;
}

.tag.selected {
  background: linear-gradient(145deg, #10b981, #059669);
}

.remove-tag {
  background: none;
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  padding: 0 4px;
  margin-left: 4px;
}

.remove-tag:hover {
  color: #fca5a5;
}

.no-tags {
  color: #999;
  font-size: 14px;
  font-style: italic;
}

.product-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  justify-content: center;
}

.product-actions .skeuomorphic-button {
  padding: 8px 16px;
  font-size: 14px;
}

.pagination {
  margin-top: 32px;
}

.popular-tags-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 20px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.popular-tags-header h2 {
  margin: 0;
  font-size: 24px;
  color: #333;
}

.popular-tags-list {
  display: grid;
  gap: 12px;
}

.popular-tag-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 12px;
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
  transition: all 0.3s ease;
}

.popular-tag-item:hover {
  transform: translateX(4px);
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.tag-name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.tag-count {
  font-size: 14px;
  color: #667eea;
  font-weight: 600;
}

.search-section {
  padding: 24px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
  margin-bottom: 24px;
}

.search-input-group {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.search-input-group .skeuomorphic-input {
  flex: 1;
  padding: 12px 16px;
  font-size: 16px;
}

.selected-tags {
  margin-bottom: 16px;
}

.search-button {
  width: 100%;
  padding: 12px 24px;
  font-size: 16px;
}

.search-results h3 {
  margin: 0 0 16px 0;
  font-size: 20px;
  color: #333;
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
  z-index: 2000;
  padding: 20px;
}

.skeuomorphic-modal {
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 20px;
  padding: 32px;
  max-width: 500px;
  width: 100%;
  box-shadow: 
    10px 10px 20px rgba(0, 0, 0, 0.2),
    -10px -10px 20px rgba(255, 255, 255, 0.8);
}

.skeuomorphic-modal h2 {
  margin: 0 0 24px 0;
  font-size: 24px;
  color: #333;
}

.edit-modal .product-info-display {
  padding: 12px;
  background: linear-gradient(145deg, #f8f9fa, #ffffff);
  border-radius: 8px;
  margin-bottom: 20px;
}

.edit-modal .product-info-display p {
  margin: 0;
  color: #666;
}

.edit-modal .form-group {
  margin-bottom: 20px;
}

.edit-modal .form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #666;
}

.edit-modal .skeuomorphic-input {
  width: 100%;
  padding: 12px 16px;
  font-size: 16px;
}

.edit-modal .tags-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
  padding: 12px;
  background: linear-gradient(145deg, #f8f9fa, #ffffff);
  border-radius: 8px;
  min-height: 40px;
}

.batch-generate-modal {
  max-width: 600px;
  max-height: 80vh;
  overflow-y: auto;
}

.batch-generate-modal .product-selection {
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  padding: 16px;
  max-height: 300px;
  overflow-y: auto;
  background: linear-gradient(145deg, #ffffff, #f8f9fa);
}

.batch-generate-modal .checkbox-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  cursor: pointer;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.batch-generate-modal .checkbox-item:hover {
  background: linear-gradient(145deg, #f0f0f0, #ffffff);
}

.batch-generate-modal .checkbox-item input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.batch-generate-modal .checkbox-item span {
  font-size: 14px;
  color: #333;
}

.batch-generate-modal .product-checkbox-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-top: 12px;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 24px;
}

.modal-actions .skeuomorphic-button {
  padding: 12px 24px;
  font-size: 16px;
}

@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }

  .header-right {
    width: 100%;
    flex-wrap: wrap;
  }

  .tabs {
    flex-wrap: wrap;
  }

  .tab-button {
    flex: 1;
    min-width: 100px;
  }

  .filters {
    flex-direction: column;
    gap: 16px;
  }

  .filter-group {
    width: 100%;
  }

  .filter-group select {
    flex: 1;
  }

  .product-item {
    flex-direction: column;
  }

  .product-image {
    width: 100%;
    height: 200px;
  }

  .product-actions {
    flex-direction: row;
    flex-wrap: wrap;
  }

  .popular-tags-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }

  .search-input-group {
    flex-direction: column;
  }
}
</style>
