<template>
  <div class="merchant-dashboard">
    <div class="dashboard-header">
      <div class="header-left">
        <h1 class="dashboard-title">🏪 商家管理后台</h1>
      </div>
      <div class="header-right">
        <div class="merchant-profile">
          <AvatarUpload 
            :current-avatar="userProfile?.avatarUrl" 
            @avatar-updated="handleAvatarUpdated"
          />
          <span class="merchant-name">{{ userProfile?.username || '商家' }}</span>
        </div>
        <button @click="router.push('/merchant/orders')" class="skeuomorphic-button orders-button">
          📋 订单管理
        </button>
        <button @click="showAddModal = true" class="skeuomorphic-button primary add-button">
          + 添加商品
        </button>
      </div>
    </div>

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
          <p class="product-category">{{ product.category }}</p>
          <p class="product-price">¥{{ product.price }}</p>
          <div class="product-stats">
            <span class="stat">库存: {{ product.stock }}</span>
            <span class="stat">销量: {{ product.sales }}</span>
            <span class="stat status" :class="product.status.toLowerCase()">
              {{ getStatusText(product.status) }}
            </span>
          </div>
        </div>
        <div class="product-actions">
          <button @click="editProduct(product)" class="skeuomorphic-button small">
            编辑
          </button>
          <button @click="showStockModal(product)" class="skeuomorphic-button small">
            库存
          </button>
          <button @click="toggleStatus(product)" class="skeuomorphic-button small">
            {{ product.status === 'ON_SALE' ? '下架' : '上架' }}
          </button>
          <button @click="deleteProduct(product.id)" class="skeuomorphic-button small danger">
            删除
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

    <div v-if="showAddModal || showEditModal" class="modal-overlay">
      <ProductForm
        :product="editingProduct"
        @submit="handleSubmit"
        @cancel="closeModals"
        @close="closeModals"
      />
    </div>

    <div v-if="showStockModalFlag" class="modal-overlay" @click.self="showStockModalFlag = false">
      <div class="skeuomorphic-modal stock-modal">
        <h2>更新库存</h2>
        <div class="form-group">
          <label>当前库存:</label>
          <span class="current-stock">{{ currentProduct?.stock }}</span>
        </div>
        <div class="form-group">
          <label>新库存:</label>
          <input
            v-model.number="newStock"
            type="number"
            min="0"
            class="skeuomorphic-input"
          />
        </div>
        <div class="modal-actions">
          <button @click="showStockModalFlag = false" class="skeuomorphic-button">
            取消
          </button>
          <button @click="updateStock" class="skeuomorphic-button primary">
            确定
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import api from '../api'
import Pagination from '../components/Pagination.vue'
import ProductForm from '../components/ProductForm.vue'
import AvatarUpload from '../components/AvatarUpload.vue'

const router = useRouter()
const userStore = useUserStore()

if (!userStore.isLoggedIn || !userStore.isMerchant()) {
  router.push('/login')
}

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

const showAddModal = ref(false)
const showEditModal = ref(false)
const showStockModalFlag = ref(false)
const editingProduct = ref(null)
const currentProduct = ref(null)
const newStock = ref(0)
const userProfile = ref(null)

const loadUserProfile = async () => {
  try {
    const response = await api.user.getProfile()
    if (response.code === 200) {
      userProfile.value = response.data
    }
  } catch (error) {
    console.error('加载用户信息失败:', error)
  }
}

const handleAvatarUpdated = (newAvatarUrl) => {
  if (userProfile.value) {
    userProfile.value.avatarUrl = newAvatarUrl
  }
}

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

const editProduct = (product) => {
  editingProduct.value = product
  showEditModal.value = true
}

const handleSubmit = async (formData) => {
  try {
    if (editingProduct.value) {
      await api.merchant.updateProduct(editingProduct.value.id, formData)
      alert('商品更新成功')
    } else {
      await api.merchant.addProduct(formData)
      alert('商品添加成功')
    }
    closeModals()
    loadProducts()
  } catch (error) {
    console.error('操作失败:', error)
    alert('操作失败: ' + (error.response?.data?.msg || '未知错误'))
  }
}

const closeModals = () => {
  showAddModal.value = false
  showEditModal.value = false
  editingProduct.value = null
}

const showStockModal = (product) => {
  currentProduct.value = product
  newStock.value = product.stock
  showStockModalFlag.value = true
}

const updateStock = async () => {
  try {
    await api.merchant.updateProductStock(currentProduct.value.id, newStock.value)
    alert('库存更新成功')
    showStockModalFlag.value = false
    loadProducts()
  } catch (error) {
    console.error('更新库存失败:', error)
    alert('更新库存失败')
  }
}

const toggleStatus = async (product) => {
  const newStatus = product.status === 'ON_SALE' ? 'OFF_SALE' : 'ON_SALE'
  try {
    await api.merchant.updateProductStatus(product.id, newStatus)
    alert('状态更新成功')
    loadProducts()
  } catch (error) {
    console.error('更新状态失败:', error)
    alert('更新状态失败')
  }
}

const deleteProduct = async (id) => {
  if (!confirm('确定要删除这个商品吗？')) return
  try {
    await api.merchant.deleteProduct(id)
    alert('删除成功')
    loadProducts()
  } catch (error) {
    console.error('删除失败:', error)
    alert('删除失败')
  }
}

const getStatusText = (status) => {
  const statusMap = {
    'ON_SALE': '在售',
    'OFF_SALE': '下架',
    'OUT_OF_STOCK': '缺货'
  }
  return statusMap[status] || status
}

onMounted(() => {
  loadUserProfile()
  loadProducts()
})
</script>

<style scoped>
.merchant-dashboard {
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
  gap: 24px;
}

.merchant-profile {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow:
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.merchant-name {
  font-size: 14px;
  font-weight: 600;
  color: #666;
}

.dashboard-title {
  font-size: 32px;
  font-weight: 700;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.add-button {
  padding: 12px 24px;
  font-size: 16px;
}

.orders-button {
  padding: 12px 24px;
  font-size: 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
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

.product-stats {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.stat {
  padding: 4px 12px;
  border-radius: 8px;
  font-size: 14px;
  color: #666;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    2px 2px 4px #d1d9e6,
    -2px -2px 4px #ffffff;
}

.stat.status {
  font-weight: 600;
}

.stat.status.on_sale {
  color: #10b981;
}

.stat.status.off_sale {
  color: #f59e0b;
}

.stat.status.out_of_stock {
  color: #ef4444;
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

.product-actions .skeuomorphic-button.danger {
  background: linear-gradient(145deg, #ef4444, #dc2626);
  color: white;
}

.pagination {
  margin-top: 32px;
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

.stock-modal .form-group {
  margin-bottom: 20px;
}

.stock-modal label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #666;
}

.stock-modal .current-stock {
  font-size: 24px;
  font-weight: 700;
  color: #667eea;
}

.stock-modal .skeuomorphic-input {
  width: 100%;
  padding: 12px 16px;
  font-size: 16px;
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
}
</style>
