<template>
  <div class="home">
    <section class="hero-section">
      <div class="hero-content skeuomorphic-container">
        <h1 class="hero-title">健康生活，从这里开始</h1>
        <p class="hero-subtitle">精选优质健康产品，为您的健康保驾护航</p>
        <router-link to="/products" class="skeuomorphic-button primary hero-button">
          浏览商品
        </router-link>
      </div>
    </section>

    <section class="hot-products-section">
      <div class="section-header">
        <h2 class="section-title">🔥 热门商品</h2>
        <router-link to="/products" class="skeuomorphic-button">查看全部</router-link>
      </div>

      <div v-if="loading" class="loading">
        <div class="skeuomorphic-card">加载中...</div>
      </div>

      <div v-else-if="error" class="error">
        {{ error }}
      </div>

      <div v-else class="products-grid">
        <ProductCard
          v-for="product in hotProducts"
          :key="product.id"
          :product="product"
        />
      </div>
    </section>

    <section class="features-section">
      <div class="features-grid">
        <div class="feature-card skeuomorphic-card">
          <div class="feature-icon">🚚</div>
          <h3 class="feature-title">快速配送</h3>
          <p class="feature-desc">全国范围内快速配送，让您尽快收到心仪商品</p>
        </div>
        <div class="feature-card skeuomorphic-card">
          <div class="feature-icon">🛡️</div>
          <h3 class="feature-title">正品保证</h3>
          <p class="feature-desc">所有商品均为正品，品质有保障</p>
        </div>
        <div class="feature-card skeuomorphic-card">
          <div class="feature-icon">💬</div>
          <h3 class="feature-title">专业客服</h3>
          <p class="feature-desc">7x24小时专业客服在线，为您解答疑问</p>
        </div>
        <div class="feature-card skeuomorphic-card">
          <div class="feature-icon">🔄</div>
          <h3 class="feature-title">无忧退换</h3>
          <p class="feature-desc">7天无理由退换货，购物更放心</p>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ProductCard from '../components/ProductCard.vue'
import api from '../api'

const hotProducts = ref([])
const loading = ref(true)
const error = ref(null)

const fetchHotProducts = async () => {
  try {
    loading.value = true
    error.value = null
    const response = await api.products.getHot({ limit: 8 })
    if (response.code === 200) {
      hotProducts.value = response.data || []
    } else {
      error.value = response.msg || '获取热门商品失败'
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
    console.error('Failed to fetch hot products:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchHotProducts()
})
</script>

<style scoped>
.home {
  display: flex;
  flex-direction: column;
  gap: 48px;
}

.hero-section {
  padding: 40px 0;
}

.hero-content {
  text-align: center;
  padding: 60px 40px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
}

.hero-title {
  font-size: 48px;
  font-weight: 800;
  margin-bottom: 16px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.hero-subtitle {
  font-size: 20px;
  margin-bottom: 32px;
  opacity: 0.9;
}

.hero-button {
  padding: 16px 40px;
  font-size: 18px;
  background: white;
  color: #667eea;
  box-shadow: 
    6px 6px 12px rgba(0, 0, 0, 0.2),
    -6px -6px 12px rgba(255, 255, 255, 0.5);
  display: inline-block;
  text-decoration: none;
}

.hero-button:hover {
  transform: translateY(-4px);
  box-shadow: 
    8px 8px 16px rgba(0, 0, 0, 0.2),
    -8px -8px 16px rgba(255, 255, 255, 0.5);
}

.hot-products-section {
  padding: 20px 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.section-title {
  font-size: 32px;
  font-weight: 700;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

.features-section {
  padding: 40px 0;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
}

.feature-card {
  text-align: center;
  padding: 32px 24px;
  transition: all 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-8px);
  box-shadow: 
    12px 12px 24px #d1d9e6,
    -12px -12px 24px #ffffff;
}

.feature-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.feature-title {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 12px;
  color: #333;
}

.feature-desc {
  color: #666;
  font-size: 14px;
  line-height: 1.6;
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 32px;
  }

  .hero-subtitle {
    font-size: 16px;
  }

  .section-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }

  .products-grid {
    grid-template-columns: 1fr;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }
}
</style>
