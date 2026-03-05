<template>
  <div class="browsing-history-page">
    <div class="page-header">
      <h1 class="page-title">浏览记录</h1>
      <p class="page-subtitle">查看您最近浏览的商品</p>
    </div>

    <div v-if="loading" class="loading">
      <div class="skeuomorphic-card">加载中...</div>
    </div>

    <div v-else-if="error" class="error">
      <div class="skeuomorphic-card">{{ error }}</div>
    </div>

    <div v-else-if="historyList.length === 0" class="empty-state">
      <div class="skeuomorphic-card">
        <div class="empty-icon">📝</div>
        <h3>暂无浏览记录</h3>
        <p>您还没有浏览过任何商品</p>
        <router-link to="/products" class="skeuomorphic-button primary">
          去逛逛
        </router-link>
      </div>
    </div>

    <div v-else>
      <div class="history-actions">
        <button @click="clearAllHistory" class="skeuomorphic-button danger">
          清空所有记录
        </button>
      </div>

      <div class="history-grid">
        <div v-for="item in historyList" :key="item.id" class="history-item skeuomorphic-card">
          <div class="history-item-content" @click="goToProduct(item.productId)">
            <img 
              :src="item.productCoverUrl || placeholderImage" 
              :alt="item.productTitle"
              class="product-image"
            />
            <div class="product-info">
              <h3 class="product-title">{{ item.productTitle }}</h3>
              <p class="product-price">¥{{ item.productPrice?.toFixed(2) || '0.00' }}</p>
              <p class="view-time">{{ formatDate(item.viewedAt) }}</p>
            </div>
            <button 
              @click.stop="deleteHistoryItem(item.productId)" 
              class="delete-btn"
              title="删除记录"
            >
              ×
            </button>
          </div>
        </div>
      </div>

      <div v-if="totalPages > 1" class="pagination-container">
        <Pagination
          :current-page="currentPage"
          :total-pages="totalPages"
          :total-items="totalItems"
          :page-size="pageSize"
          @page-change="handlePageChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'
import Pagination from '../components/Pagination.vue'

const router = useRouter()
const historyList = ref([])
const loading = ref(false)
const error = ref(null)
const currentPage = ref(1)
const pageSize = ref(20)
const totalPages = ref(1)
const totalItems = ref(0)

const placeholderImage = 'https://via.placeholder.com/300x300?text=Product'

const fetchHistory = async () => {
  loading.value = true
  error.value = null
  
  try {
    const response = await api.browsingHistory.getList({
      page: currentPage.value,
      size: pageSize.value
    })
    
    if (response.code === 200) {
      historyList.value = response.data.list || []
      totalItems.value = response.data.total || 0
      totalPages.value = Math.ceil(totalItems.value / pageSize.value)
    } else {
      error.value = response.msg || '获取浏览记录失败'
    }
  } catch (err) {
    console.error('获取浏览记录失败:', err)
    error.value = '获取浏览记录失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

const deleteHistoryItem = async (productId) => {
  if (!confirm('确定删除这条浏览记录吗？')) {
    return
  }
  
  try {
    const response = await api.browsingHistory.delete(productId)
    if (response.code === 200) {
      fetchHistory()
    } else {
      alert('删除失败: ' + response.msg)
    }
  } catch (err) {
    console.error('删除浏览记录失败:', err)
    alert('删除失败，请稍后重试')
  }
}

const clearAllHistory = async () => {
  if (!confirm('确定清空所有浏览记录吗？此操作不可恢复。')) {
    return
  }
  
  try {
    const response = await api.browsingHistory.clear()
    if (response.code === 200) {
      fetchHistory()
    } else {
      alert('清空失败: ' + response.msg)
    }
  } catch (err) {
    console.error('清空浏览记录失败:', err)
    alert('清空失败，请稍后重试')
  }
}

const goToProduct = (productId) => {
  router.push(`/products/${productId}`)
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now - date
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  
  if (minutes < 1) {
    return '刚刚'
  } else if (minutes < 60) {
    return `${minutes}分钟前`
  } else if (hours < 24) {
    return `${hours}小时前`
  } else if (days < 7) {
    return `${days}天前`
  } else {
    return date.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }
}

const handlePageChange = (newPage) => {
  currentPage.value = newPage
  fetchHistory()
}

onMounted(() => {
  fetchHistory()
})
</script>

<style scoped>
.browsing-history-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  background: linear-gradient(135deg, #e0e5ec 0%, #c8d0e0 100%);
  min-height: 100vh;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 32px;
  color: #333;
  margin-bottom: 10px;
}

.page-subtitle {
  font-size: 16px;
  color: #666;
}

.loading,
.error {
  text-align: center;
  padding: 40px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
}

.empty-state h3 {
  font-size: 24px;
  color: #333;
  margin-bottom: 10px;
}

.empty-state p {
  font-size: 16px;
  color: #666;
  margin-bottom: 20px;
}

.history-actions {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 20px;
}

.history-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.history-item {
  position: relative;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
}

.history-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}

.history-item-content {
  display: flex;
  flex-direction: column;
  gap: 15px;
  padding: 20px;
}

.product-image {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 12px;
  background: #f5f5f5;
}

.product-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.product-title {
  font-size: 16px;
  color: #333;
  font-weight: 600;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.product-price {
  font-size: 20px;
  color: #ff6b6b;
  font-weight: 700;
}

.view-time {
  font-size: 14px;
  color: #999;
}

.delete-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
  border-radius: 50%;
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.delete-btn:hover {
  background: #ff6b6b;
  color: white;
  transform: scale(1.1);
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}
</style>
