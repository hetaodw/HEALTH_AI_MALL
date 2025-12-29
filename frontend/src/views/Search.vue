<template>
  <div class="search-page">
    <div class="search-header">
      <div class="search-bar-container skeuomorphic-card">
        <input
          v-model="searchQuery"
          @keyup.enter="performSearch"
          type="text"
          placeholder="搜索商品名称、描述..."
          class="search-input skeuomorphic-input"
        />
        <button @click="performSearch" class="skeuomorphic-button primary search-button">
          搜索
        </button>
      </div>
      <div v-if="lastSearchQuery" class="search-info">
        <p>搜索结果：<span class="search-keyword">"{{ lastSearchQuery }}"</span></p>
        <p class="result-count">共找到 {{ totalItems }} 个商品</p>
      </div>
    </div>

    <div v-if="loading" class="loading">
      <div class="skeuomorphic-card">搜索中...</div>
    </div>

    <div v-else-if="error" class="error">
      {{ error }}
    </div>

    <div v-else-if="products.length === 0 && hasSearched" class="empty">
      <div class="skeuomorphic-card">
        <p>未找到相关商品</p>
        <p class="empty-hint">试试其他关键词</p>
      </div>
    </div>

    <div v-else-if="!hasSearched" class="initial-state">
      <div class="skeuomorphic-card">
        <h3>热门搜索</h3>
        <div class="hot-keywords">
          <span
            v-for="keyword in hotKeywords"
            :key="keyword"
            @click="searchKeyword(keyword)"
            class="keyword-tag skeuomorphic-button"
          >
            {{ keyword }}
          </span>
        </div>
      </div>
    </div>

    <div v-else>
      <div class="products-grid">
        <ProductCard
          v-for="product in products"
          :key="product.id"
          :product="product"
        />
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
import { useRoute, useRouter } from 'vue-router'
import ProductCard from '../components/ProductCard.vue'
import Pagination from '../components/Pagination.vue'
import api from '../api'

const route = useRoute()
const router = useRouter()

const searchQuery = ref('')
const lastSearchQuery = ref('')
const products = ref([])
const loading = ref(false)
const error = ref(null)
const hasSearched = ref(false)
const currentPage = ref(1)
const totalPages = ref(1)
const totalItems = ref(0)
const pageSize = ref(12)

const hotKeywords = ref([
  '维生素',
  '蛋白粉',
  '按摩仪',
  '益生菌',
  '钙片',
  '血压计',
  '燕麦',
  '瑜伽垫'
])

const performSearch = () => {
  if (!searchQuery.value.trim()) {
    return
  }
  
  lastSearchQuery.value = searchQuery.value
  hasSearched.value = true
  currentPage.value = 1
  fetchProducts()
  
  router.push({
    path: '/search',
    query: { q: searchQuery.value }
  })
}

const searchKeyword = (keyword) => {
  searchQuery.value = keyword
  performSearch()
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchProducts()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const fetchProducts = async () => {
  try {
    loading.value = true
    error.value = null

    const params = {
      keyword: lastSearchQuery.value,
      page: currentPage.value,
      size: pageSize.value
    }

    const response = await api.products.search(params)

    if (response.code === 200) {
      products.value = response.data.list || []
      totalPages.value = response.data.totalPages || 1
      totalItems.value = response.data.total || 0
    } else {
      error.value = response.msg || '搜索失败'
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
    console.error('Search error:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  const query = route.query.q
  if (query) {
    searchQuery.value = query
    performSearch()
  }
})
</script>

<style scoped>
.search-page {
  min-height: calc(100vh - 200px);
  padding: 40px 20px;
}

.search-header {
  max-width: 800px;
  margin: 0 auto 40px;
}

.search-bar-container {
  display: flex;
  gap: 16px;
  padding: 16px;
}

.search-input {
  flex: 1;
  padding: 14px 20px;
  font-size: 16px;
}

.search-button {
  padding: 14px 32px;
  white-space: nowrap;
}

.search-info {
  text-align: center;
  margin-top: 24px;
  padding: 20px;
}

.search-info p {
  margin: 8px 0;
  color: #666;
  font-size: 14px;
}

.search-keyword {
  color: #667eea;
  font-weight: 600;
  font-size: 18px;
}

.result-count {
  font-size: 16px;
}

.loading,
.error,
.empty,
.initial-state {
  text-align: center;
  padding: 60px 20px;
}

.error {
  color: #c33;
}

.empty-hint {
  color: #999;
  font-size: 14px;
  margin-top: 8px;
}

.initial-state h3 {
  font-size: 24px;
  margin-bottom: 24px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hot-keywords {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: center;
}

.keyword-tag {
  padding: 10px 20px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.keyword-tag:hover {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  transform: translateY(-2px);
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 40px;
}

@media (max-width: 768px) {
  .search-bar-container {
    flex-direction: column;
  }

  .search-button {
    width: 100%;
  }

  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 16px;
  }

  .search-keyword {
    font-size: 16px;
  }
}
</style>
