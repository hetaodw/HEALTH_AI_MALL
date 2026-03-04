<template>
  <div class="product-list-page">
    <div class="page-header">
      <h1 class="page-title">全部商品</h1>
      <p class="page-subtitle">发现更多健康好物</p>
    </div>

    <div class="filters-section skeuomorphic-card">
      <div class="filter-group">
        <label class="filter-label">分类</label>
        <select v-model="filters.category" @change="applyFilters" class="skeuomorphic-select">
          <option value="">全部</option>
          <option v-for="cat in PRODUCT_CATEGORIES" :key="cat.value" :value="cat.value">{{ cat.label }}</option>
        </select>
      </div>

      <div class="filter-group">
        <label class="filter-label">价格区间</label>
        <select v-model="filters.priceRange" @change="applyFilters" class="skeuomorphic-select">
          <option value="">全部</option>
          <option value="0-100">0-100元</option>
          <option value="100-300">100-300元</option>
          <option value="300-500">300-500元</option>
          <option value="500-1000">500-1000元</option>
          <option value="1000-">1000元以上</option>
        </select>
      </div>

      <div class="filter-group">
        <label class="filter-label">排序</label>
        <select v-model="filters.sortBy" @change="applyFilters" class="skeuomorphic-select">
          <option value="default">默认排序</option>
          <option value="price-asc">价格从低到高</option>
          <option value="price-desc">价格从高到低</option>
          <option value="sales-desc">销量从高到低</option>
          <option value="stock-desc">库存从多到少</option>
        </select>
      </div>

      <div class="filter-group">
        <label class="filter-label">每页显示</label>
        <select v-model="filters.pageSize" @change="applyFilters" class="skeuomorphic-select">
          <option value="12">12件</option>
          <option value="24">24件</option>
          <option value="36">36件</option>
          <option value="48">48件</option>
        </select>
      </div>
    </div>

    <div v-if="loading" class="loading">
      <div class="skeuomorphic-card">加载中...</div>
    </div>

    <div v-else-if="error" class="error">
      {{ error }}
    </div>

    <div v-else-if="products.length === 0" class="empty">
      <div class="skeuomorphic-card">
        <p>暂无商品</p>
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

      <div class="pagination-container">
        <Pagination
          :current-page="currentPage"
          :total-pages="totalPages"
          :total-items="totalItems"
          :page-size="filters.pageSize"
          @page-change="handlePageChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ProductCard from '../components/ProductCard.vue'
import Pagination from '../components/Pagination.vue'
import api from '../api'
import { PRODUCT_CATEGORIES } from '../constants/productCategories'

const products = ref([])
const loading = ref(false)
const error = ref(null)
const currentPage = ref(1)
const totalPages = ref(1)
const totalItems = ref(0)

const filters = ref({
  category: '',
  priceRange: '',
  sortBy: 'default',
  pageSize: 12
})

const applyFilters = () => {
  currentPage.value = 1
  fetchProducts()
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchProducts()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const parsePriceRange = (range) => {
  if (!range) return { min: null, max: null }
  
  const [min, max] = range.split('-').map(Number)
  return { min: min || 0, max: max || null }
}

const fetchProducts = async () => {
  try {
    loading.value = true
    error.value = null

    const params = {
      page: currentPage.value,
      size: filters.value.pageSize
    }

    if (filters.value.category) {
      params.category = filters.value.category
    }

    if (filters.value.priceRange) {
      const { min, max } = parsePriceRange(filters.value.priceRange)
      params.minPrice = min
      if (max) {
        params.maxPrice = max
      }
    }

    if (filters.value.sortBy !== 'default') {
      const [field, order] = filters.value.sortBy.split('-')
      params.sortBy = field
      params.sortOrder = order
    }

    const response = await api.products.getList(params)

    if (response.code === 200) {
      products.value = response.data.list || []
      totalItems.value = response.data.total || 0
      totalPages.value = Math.ceil(totalItems.value / filters.value.pageSize) || 1
    } else {
      error.value = response.msg || '获取商品列表失败'
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
    console.error('Fetch products error:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchProducts()
})
</script>

<style scoped>
.product-list-page {
  min-height: calc(100vh - 200px);
  padding: 40px 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-title {
  font-size: 36px;
  font-weight: 800;
  margin-bottom: 8px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  color: #666;
  font-size: 16px;
}

.filters-section {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  padding: 24px;
  margin-bottom: 32px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 150px;
  flex: 1;
}

.filter-label {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.skeuomorphic-select {
  background: linear-gradient(145deg, #f0f0f0, #ffffff);
  box-shadow: 
    inset 4px 4px 8px #d1d9e6,
    inset -4px -4px 8px #ffffff;
  border-radius: 12px;
  padding: 12px 16px;
  font-size: 14px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23666' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  padding-right: 40px;
}

.skeuomorphic-select:hover {
  background: linear-gradient(145deg, #e8e8e8, #f8f8f8);
}

.skeuomorphic-select:focus {
  outline: none;
  box-shadow: 
    inset 6px 6px 12px #d1d9e6,
    inset -6px -6px 12px #ffffff,
    0 0 0 3px rgba(102, 126, 234, 0.3);
}

.loading,
.error,
.empty {
  text-align: center;
  padding: 60px 20px;
}

.error {
  color: #c33;
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
  .filters-section {
    flex-direction: column;
  }

  .filter-group {
    width: 100%;
  }

  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 16px;
  }

  .page-title {
    font-size: 28px;
  }
}
</style>
