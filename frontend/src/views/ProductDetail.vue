<template>
  <div class="product-detail-page">
    <!-- 面包屑导航 -->
    <div class="breadcrumb skeuomorphic-card">
      <span class="breadcrumb-item" @click="$router.push('/')">首页</span>
      <span class="breadcrumb-separator">&gt;</span>
      <span class="breadcrumb-item" @click="$router.push('/products')">商品列表</span>
      <span class="breadcrumb-separator">&gt;</span>
      <span class="breadcrumb-item active">{{ product.title || '商品详情' }}</span>
    </div>

    <!-- 商品主信息区 -->
    <div class="product-main-section skeuomorphic-card">
      <div class="product-main-content">
        <!-- 左侧：图片展示区 -->
        <div class="product-gallery">
          <div class="main-image-container">
            <img 
              :src="currentImage || product.coverUrl || placeholderImage" 
              :alt="product.title"
              class="main-image"
              @click="showImagePreview = true"
            />
            <div v-if="product.stock <= 10" class="stock-badge">
              仅剩 {{ product.stock }} 件
            </div>
          </div>
          
          <!-- 缩略图列表 -->
          <div class="thumbnail-list">
            <div 
              v-for="(img, index) in allImages" 
              :key="index"
              class="thumbnail-item"
              :class="{ active: currentImage === img }"
              @click="currentImage = img"
            >
              <img :src="img" :alt="`图片${index + 1}`" />
            </div>
          </div>
        </div>

        <!-- 右侧：商品信息区 -->
        <div class="product-info-section">
          <!-- 商品标题 -->
          <h1 class="product-title">{{ product.title }}</h1>
          
          <!-- 商品副标题/描述 -->
          <p class="product-subtitle">{{ product.description }}</p>

          <!-- 价格区域 -->
          <div class="price-section">
            <div class="price-row">
              <span class="price-label">价格</span>
              <span class="current-price">¥{{ product.price?.toFixed(2) }}</span>
            </div>
            <div class="price-row">
              <span class="price-label">销量</span>
              <span class="sales-count">{{ product.sales || 0 }} 件已售</span>
            </div>
          </div>

          <!-- 商家信息 -->
          <div class="merchant-info">
            <div class="merchant-avatar">
              <img :src="merchantAvatar" alt="商家" />
            </div>
            <div class="merchant-detail">
              <span class="merchant-name">{{ product.merchantName || '官方店铺' }}</span>
            </div>
          </div>

          <!-- 规格选择 -->
          <div class="spec-section">
            <div class="spec-row">
              <span class="spec-label">数量</span>
              <div class="quantity-selector">
                <button class="qty-btn" @click="decreaseQty" :disabled="quantity <= 1">-</button>
                <input type="number" v-model.number="quantity" class="qty-input" min="1" :max="product.stock" />
                <button class="qty-btn" @click="increaseQty" :disabled="quantity >= product.stock">+</button>
              </div>
              <span class="stock-info">库存 {{ product.stock }} 件</span>
            </div>
          </div>

          <!-- 操作按钮 -->
          <div class="action-buttons">
            <button class="btn-buy-now" @click="buyNow">
              <span class="btn-icon">⚡</span>
              立即购买
            </button>
            <button class="btn-add-cart" @click="addToCart">
              <span class="btn-icon">🛒</span>
              加入购物车
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 商品详情区域 -->
    <div class="product-detail-section">
      <div class="detail-tabs skeuomorphic-card">
        <div 
          class="tab-item" 
          :class="{ active: activeTab === 'detail' }"
          @click="activeTab = 'detail'"
        >
          商品详情
        </div>
        <div 
          class="tab-item" 
          :class="{ active: activeTab === 'spec' }"
          @click="activeTab = 'spec'"
        >
          规格参数
        </div>
        <div 
          class="tab-item" 
          :class="{ active: activeTab === 'review' }"
          @click="activeTab = 'review'"
        >
          用户评价
        </div>
      </div>

      <!-- 商品详情内容 -->
      <div v-if="activeTab === 'detail'" class="detail-content skeuomorphic-card">
        <div class="detail-description">
          <h3 class="section-title">商品介绍</h3>
          <p class="desc-text">{{ product.description }}</p>
        </div>

        <div v-if="productDescription" class="product-description-section">
          <h3 class="section-title">详细介绍</h3>
          <div class="description-content">{{ productDescription.content }}</div>
        </div>

        <div class="detail-images-section">
          <h3 class="section-title">详细展示</h3>
          <div class="detail-images-list">
            <div 
              v-for="(img, index) in product.detailImages" 
              :key="index"
              class="detail-image-item"
            >
              <img 
                :src="img" 
                :alt="`详情图${index + 1}`"
                class="detail-full-image"
                @click="previewDetailImage(img)"
              />
            </div>
            <div v-if="!product.detailImages || product.detailImages.length === 0" class="no-detail-images">
              <p>暂无详细介绍图片</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 规格参数 -->
      <div v-if="activeTab === 'spec'" class="spec-content skeuomorphic-card">
        <h3 class="section-title">规格参数</h3>
        <table class="spec-table">
          <tbody>
            <tr>
              <td class="spec-name">商品名称</td>
              <td class="spec-value">{{ product.title }}</td>
            </tr>
            <tr>
              <td class="spec-name">商品分类</td>
              <td class="spec-value">{{ product.category }}</td>
            </tr>
            <tr>
              <td class="spec-name">价格</td>
              <td class="spec-value">¥{{ product.price?.toFixed(2) }}</td>
            </tr>
            <tr>
              <td class="spec-name">库存</td>
              <td class="spec-value">{{ product.stock }} 件</td>
            </tr>
            <tr>
              <td class="spec-name">销量</td>
              <td class="spec-value">{{ product.sales || 0 }} 件</td>
            </tr>
            <tr>
              <td class="spec-name">商品状态</td>
              <td class="spec-value">{{ formatStatus(product.status) }}</td>
            </tr>
            <tr v-if="product.features">
              <td class="spec-name">商品特性</td>
              <td class="spec-value">{{ product.features }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- 用户评价 -->
      <div v-if="activeTab === 'review'" class="review-content skeuomorphic-card">
        <div class="review-header">
          <h3 class="section-title">用户评价</h3>
          <div class="review-stats">
            <div class="average-rating">
              <span class="rating-number">{{ averageRating.toFixed(1) }}</span>
              <div class="rating-stars">
                <span v-for="i in 5" :key="i" class="star" :class="{ filled: i <= Math.round(averageRating) }">★</span>
              </div>
              <span class="review-count">{{ reviewCount }} 条评价</span>
            </div>
          </div>
        </div>

        <button v-if="userStore.isLoggedIn()" class="btn-write-review" @click="showReviewForm = true">
          写评价
        </button>

        <div v-if="reviews.length > 0" class="review-list">
          <div v-for="review in reviews" :key="review.id" class="review-item">
            <div class="review-user">
              <img :src="review.userAvatar || defaultAvatar" :alt="review.username" class="user-avatar" />
              <div class="user-info">
                <span class="username">{{ review.isAnonymous ? '匿名用户' : review.username }}</span>
                <div class="review-rating">
                  <span v-for="i in 5" :key="i" class="star" :class="{ filled: i <= review.rating }">★</span>
                </div>
              </div>
              <span class="review-date">{{ formatDate(review.createdAt) }}</span>
            </div>
            <div v-if="review.title" class="review-title">{{ review.title }}</div>
            <div class="review-content-text">{{ review.content }}</div>
          </div>
        </div>

        <div v-else class="review-placeholder">
          <p>暂无评价</p>
          <p class="hint">购买商品后可以发表评价</p>
        </div>

        <div v-if="reviews.length > 0 && reviewCount > reviews.length" class="load-more">
          <button class="btn-load-more" @click="loadMoreReviews" :disabled="loadingReviews">
            {{ loadingReviews ? '加载中...' : '加载更多' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 图片预览弹窗 -->
    <div v-if="showImagePreview" class="image-preview-modal" @click="showImagePreview = false">
      <div class="preview-content">
        <img :src="currentImage || product.coverUrl" :alt="product.title" />
        <button class="close-preview" @click="showImagePreview = false">×</button>
      </div>
    </div>

    <!-- 详情图片预览 -->
    <div v-if="previewDetailImageUrl" class="image-preview-modal" @click="previewDetailImageUrl = null">
      <div class="preview-content">
        <img :src="previewDetailImageUrl" alt="详情图预览" />
        <button class="close-preview" @click="previewDetailImageUrl = null">×</button>
      </div>
    </div>

    <!-- 评价表单弹窗 -->
    <div v-if="showReviewForm" class="review-modal" @click.self="showReviewForm = false">
      <div class="review-form-container skeuomorphic-card">
        <div class="modal-header">
          <h3>发表评价</h3>
          <button class="close-btn" @click="showReviewForm = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>评分</label>
            <div class="rating-selector">
              <span 
                v-for="i in 5" 
                :key="i" 
                class="star-select" 
                :class="{ active: i <= newReview.rating }"
                @click="newReview.rating = i"
              >★</span>
              <span class="rating-text">{{ ratingText[newReview.rating] || '请评分' }}</span>
            </div>
          </div>
          <div class="form-group">
            <label>评价标题（可选）</label>
            <input v-model="newReview.title" type="text" placeholder="一句话概括您的评价" maxlength="100" />
          </div>
          <div class="form-group">
            <label>评价内容（可选）</label>
            <textarea v-model="newReview.content" placeholder="分享您的使用体验..." rows="4" maxlength="500"></textarea>
          </div>
          <div class="form-group checkbox-group">
            <label>
              <input type="checkbox" v-model="newReview.isAnonymous" />
              <span>匿名评价</span>
            </label>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-cancel" @click="showReviewForm = false">取消</button>
          <button class="btn-submit" @click="submitReview" :disabled="submittingReview || newReview.rating === 0">
            {{ submittingReview ? '提交中...' : '提交评价' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../api'
import { useUserStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const product = ref({})
const loading = ref(false)
const quantity = ref(1)
const currentImage = ref('')
const activeTab = ref('detail')
const showImagePreview = ref(false)
const previewDetailImageUrl = ref(null)

const productDescription = ref(null)
const reviews = ref([])
const reviewPage = ref(1)
const reviewCount = ref(0)
const averageRating = ref(0)
const loadingReviews = ref(false)
const showReviewForm = ref(false)
const submittingReview = ref(false)
const newReview = ref({
  rating: 0,
  title: '',
  content: '',
  isAnonymous: false
})

const defaultAvatar = 'https://via.placeholder.com/50x50?text=User'

const ratingText = {
  1: '非常差',
  2: '较差',
  3: '一般',
  4: '较好',
  5: '非常好'
}

const placeholderImage = 'https://via.placeholder.com/600x600?text=Product'

const merchantAvatar = computed(() => {
  return product.value.merchantAvatar || 'https://via.placeholder.com/60x60?text=Shop'
})

const allImages = computed(() => {
  const images = []
  if (product.value.coverUrl) {
    images.push(product.value.coverUrl)
  }
  if (product.value.detailImages && product.value.detailImages.length > 0) {
    images.push(...product.value.detailImages)
  }
  return images.length > 0 ? images : [placeholderImage]
})

const fetchProductDetail = async () => {
  const productId = route.params.id
  if (!productId) return

  loading.value = true
  try {
    const response = await api.products.getDetail(productId)
    if (response.code === 200) {
      product.value = response.data
      currentImage.value = product.value.coverUrl || placeholderImage
      
      if (response.data.averageRating !== undefined) {
        averageRating.value = response.data.averageRating || 0
      }
      if (response.data.reviewCount !== undefined) {
        reviewCount.value = response.data.reviewCount || 0
      }
      
      fetchProductDescription(productId)
    } else {
      console.error('获取商品详情失败:', response.msg)
      alert('获取商品详情失败: ' + response.msg)
    }
  } catch (error) {
    console.error('获取商品详情失败:', error)
    alert('获取商品详情失败')
  } finally {
    loading.value = false
  }
}

const fetchProductDescription = async (productId) => {
  try {
    const response = await api.productDescription.get(productId)
    if (response.code === 200 && response.data) {
      productDescription.value = response.data
    }
  } catch (error) {
    console.log('暂无商品详情介绍')
  }
}

const fetchReviews = async (reset = false) => {
  const productId = route.params.id
  if (!productId) return
  
  if (reset) {
    reviewPage.value = 1
    reviews.value = []
  }
  
  loadingReviews.value = true
  try {
    const response = await api.productReviews.getList(productId, {
      page: reviewPage.value,
      size: 10
    })
    if (response.code === 200) {
      if (reset) {
        reviews.value = response.data.list || []
      } else {
        reviews.value = [...reviews.value, ...(response.data.list || [])]
      }
      reviewCount.value = response.data.reviewCount || 0
      averageRating.value = response.data.averageRating || 0
    }
  } catch (error) {
    console.error('获取评价列表失败:', error)
  } finally {
    loadingReviews.value = false
  }
}

const loadMoreReviews = () => {
  reviewPage.value++
  fetchReviews()
}

const submitReview = async () => {
  if (!userStore.isLoggedIn()) {
    alert('请先登录后再发表评价')
    router.push('/login')
    return
  }
  
  if (newReview.value.rating === 0) {
    alert('请选择评分')
    return
  }
  
  const productId = route.params.id
  submittingReview.value = true
  
  try {
    const response = await api.productReviews.create(productId, {
      rating: newReview.value.rating,
      title: newReview.value.title,
      content: newReview.value.content,
      isAnonymous: newReview.value.isAnonymous
    })
    
    if (response.code === 200) {
      alert('评价提交成功！')
      showReviewForm.value = false
      newReview.value = {
        rating: 0,
        title: '',
        content: '',
        isAnonymous: false
      }
      fetchReviews(true)
    } else if (response.code === 401) {
      alert('登录已过期，请重新登录')
      userStore.logout()
      router.push('/login')
    } else {
      alert('评价提交失败: ' + response.msg)
    }
  } catch (error) {
    console.error('提交评价失败:', error)
    if (error.response?.status === 401) {
      alert('登录已过期，请重新登录')
      userStore.logout()
      router.push('/login')
    } else {
      alert('提交评价失败，请稍后重试')
    }
  } finally {
    submittingReview.value = false
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

watch(activeTab, (newTab) => {
  if (newTab === 'review' && reviews.value.length === 0) {
    fetchReviews(true)
  }
})

const decreaseQty = () => {
  if (quantity.value > 1) quantity.value--
}

const increaseQty = () => {
  if (quantity.value < product.value.stock) quantity.value++
}

const buyNow = () => {
  const token = localStorage.getItem('token')
  if (!token) {
    alert('请先登录')
    router.push('/login')
    return
  }
  
  router.push({
    name: 'OrderConfirm',
    query: {
      productId: product.value.id,
      quantity: quantity.value
    }
  })
}

const addToCart = () => {
  const token = localStorage.getItem('token')
  if (!token) {
    alert('请先登录')
    router.push('/login')
    return
  }
  
  try {
    const cart = JSON.parse(localStorage.getItem('cart') || '[]')
    
    const existingItem = cart.find(item => item.productId === product.value.id)
    
    if (existingItem) {
      const newQuantity = existingItem.quantity + quantity.value
      if (newQuantity > product.value.stock) {
        alert(`库存不足，最多可购买 ${product.value.stock} 件`)
        return
      }
      existingItem.quantity = newQuantity
    } else {
      cart.push({
        productId: product.value.id,
        title: product.value.title,
        coverUrl: product.value.coverUrl,
        price: product.value.price,
        quantity: quantity.value,
        stock: product.value.stock,
        selected: true
      })
    }
    
    localStorage.setItem('cart', JSON.stringify(cart))
    window.dispatchEvent(new StorageEvent('storage', { key: 'cart' }))
    
    alert(`已将 ${quantity.value} 件 "${product.value.title}" 加入购物车`)
    console.log('Cart updated:', cart)
  } catch (err) {
    console.error('加入购物车失败:', err)
    alert('加入购物车失败，请稍后重试')
  }
}

const previewDetailImage = (url) => {
  previewDetailImageUrl.value = url
}

const formatStatus = (status) => {
  const statusMap = {
    'ON_SALE': '在售',
    'OFF_SALE': '已下架',
    'OUT_OF_STOCK': '缺货'
  }
  return statusMap[status] || status
}

onMounted(() => {
  fetchProductDetail()
})
</script>

<style scoped>
.product-detail-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  background: linear-gradient(135deg, #e0e5ec 0%, #c8d0e0 100%);
  min-height: 100vh;
}

/* 面包屑导航 */
.breadcrumb {
  padding: 15px 25px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
}

.breadcrumb-item {
  color: #666;
  cursor: pointer;
  transition: color 0.3s;
}

.breadcrumb-item:hover {
  color: #ff6b6b;
}

.breadcrumb-item.active {
  color: #333;
  font-weight: 600;
  cursor: default;
}

.breadcrumb-separator {
  color: #999;
}

/* 商品主信息区 */
.product-main-section {
  padding: 30px;
  margin-bottom: 20px;
}

.product-main-content {
  display: grid;
  grid-template-columns: 500px 1fr;
  gap: 40px;
}

/* 左侧图片区 */
.product-gallery {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.main-image-container {
  position: relative;
  width: 100%;
  height: 500px;
  border-radius: 20px;
  overflow: hidden;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  box-shadow: 
    inset 5px 5px 10px #bebebe,
    inset -5px -5px 10px #ffffff;
}

.main-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  cursor: zoom-in;
  transition: transform 0.3s ease;
}

.main-image:hover {
  transform: scale(1.02);
}

.stock-badge {
  position: absolute;
  top: 15px;
  right: 15px;
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.2),
    -1px -1px 3px rgba(255,255,255,0.3);
}

/* 缩略图列表 */
.thumbnail-list {
  display: flex;
  gap: 12px;
  overflow-x: auto;
  padding: 5px;
}

.thumbnail-item {
  width: 80px;
  height: 80px;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  border: 3px solid transparent;
  transition: all 0.3s ease;
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.thumbnail-item:hover {
  transform: translateY(-3px);
}

.thumbnail-item.active {
  border-color: #ff6b6b;
  box-shadow: 
    0 0 0 2px #ff6b6b,
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.thumbnail-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* 右侧信息区 */
.product-info-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.product-title {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  line-height: 1.4;
  margin: 0;
}

.product-subtitle {
  font-size: 16px;
  color: #666;
  line-height: 1.6;
  margin: 0;
}

/* 价格区域 */
.price-section {
  background: linear-gradient(135deg, #fff5f5 0%, #ffe0e0 100%);
  padding: 25px;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-shadow: 
    inset 3px 3px 6px rgba(0,0,0,0.05),
    inset -3px -3px 6px rgba(255,255,255,0.8);
}

.price-row {
  display: flex;
  align-items: center;
  gap: 15px;
}

.price-label {
  font-size: 14px;
  color: #666;
  width: 60px;
}

.current-price {
  font-size: 36px;
  font-weight: 700;
  color: #ff6b6b;
  text-shadow: 1px 1px 2px rgba(0,0,0,0.1);
}

.sales-count {
  font-size: 14px;
  color: #666;
}

/* 商家信息 */
.merchant-info {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  border-radius: 12px;
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.merchant-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  box-shadow: 
    2px 2px 4px #bebebe,
    -2px -2px 4px #ffffff;
}

.merchant-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.merchant-detail {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.merchant-name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

/* 规格选择 */
.spec-section {
  padding: 20px 0;
}

.spec-row {
  display: flex;
  align-items: center;
  gap: 20px;
}

.spec-label {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  width: 60px;
}

.quantity-selector {
  display: flex;
  align-items: center;
  gap: 0;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.qty-btn {
  width: 45px;
  height: 45px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  font-size: 20px;
  cursor: pointer;
  transition: all 0.3s;
  color: #333;
}

.qty-btn:hover:not(:disabled) {
  background: linear-gradient(145deg, #e0e0e0, #f0f0f0);
}

.qty-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.qty-input {
  width: 70px;
  height: 45px;
  border: none;
  text-align: center;
  font-size: 16px;
  font-weight: 600;
  background: #f5f5f5;
  outline: none;
}

.stock-info {
  font-size: 14px;
  color: #666;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 20px;
  margin-top: 10px;
}

.btn-buy-now,
.btn-add-cart {
  flex: 1;
  padding: 18px 30px;
  border: none;
  border-radius: 30px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.btn-buy-now {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
  box-shadow: 
    5px 5px 10px rgba(255, 107, 107, 0.3),
    -2px -2px 5px rgba(255, 255, 255, 0.5);
}

.btn-buy-now:hover {
  transform: translateY(-3px);
  box-shadow: 
    8px 8px 15px rgba(255, 107, 107, 0.4),
    -2px -2px 5px rgba(255, 255, 255, 0.5);
}

.btn-add-cart {
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  color: #333;
  box-shadow: 
    5px 5px 10px #bebebe,
    -5px -5px 10px #ffffff;
}

.btn-add-cart:hover {
  transform: translateY(-3px);
  box-shadow: 
    8px 8px 15px #bebebe,
    -5px -5px 10px #ffffff;
}

.btn-icon {
  font-size: 22px;
}

/* 商品详情区域 */
.product-detail-section {
  margin-top: 30px;
}

.detail-tabs {
  display: flex;
  gap: 0;
  margin-bottom: 20px;
  padding: 5px;
}

.tab-item {
  flex: 1;
  padding: 18px 30px;
  text-align: center;
  font-size: 16px;
  font-weight: 600;
  color: #666;
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 12px;
  position: relative;
}

.tab-item:hover {
  color: #333;
  background: rgba(0,0,0,0.03);
}

.tab-item.active {
  color: #ff6b6b;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  box-shadow: 
    inset 3px 3px 6px #bebebe,
    inset -3px -3px 6px #ffffff;
}

.tab-item.active::after {
  content: '';
  position: absolute;
  bottom: 5px;
  left: 50%;
  transform: translateX(-50%);
  width: 40px;
  height: 3px;
  background: #ff6b6b;
  border-radius: 2px;
}

/* 详情内容 */
.detail-content,
.spec-content,
.review-content {
  padding: 40px;
  min-height: 400px;
}

.section-title {
  font-size: 22px;
  font-weight: 700;
  color: #333;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #ff6b6b;
  display: inline-block;
}

.desc-text {
  font-size: 16px;
  line-height: 1.8;
  color: #555;
  margin-bottom: 30px;
}

/* 详细介绍图片 - 竖版全大小展示 */
.detail-images-section {
  margin-top: 40px;
}

.detail-images-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-image-item {
  width: 100%;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 
    8px 8px 16px #bebebe,
    -8px -8px 16px #ffffff;
  transition: transform 0.3s ease;
}

.detail-image-item:hover {
  transform: translateY(-5px);
}

.detail-full-image {
  width: 100%;
  height: auto;
  display: block;
  cursor: zoom-in;
}

.no-detail-images {
  text-align: center;
  padding: 60px;
  color: #999;
  font-size: 16px;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  border-radius: 16px;
  box-shadow: 
    inset 3px 3px 6px #bebebe,
    inset -3px -3px 6px #ffffff;
}

/* 规格表格 */
.spec-table {
  width: 100%;
  border-collapse: collapse;
}

.spec-table tr {
  border-bottom: 1px solid rgba(0,0,0,0.1);
}

.spec-table tr:last-child {
  border-bottom: none;
}

.spec-name {
  width: 150px;
  padding: 18px 20px;
  background: linear-gradient(145deg, #f5f5f5, #e8e8e8);
  font-weight: 600;
  color: #666;
  border-radius: 8px 0 0 8px;
}

.spec-value {
  padding: 18px 20px;
  color: #333;
}

/* 评价占位 */
.review-placeholder {
  text-align: center;
  padding: 80px;
  color: #999;
  font-size: 16px;
}

.review-placeholder .hint {
  font-size: 14px;
  margin-top: 10px;
  color: #bbb;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.review-stats {
  text-align: right;
}

.average-rating {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 5px;
}

.rating-number {
  font-size: 36px;
  font-weight: 700;
  color: #ff6b6b;
}

.rating-stars {
  display: flex;
  gap: 2px;
}

.star {
  font-size: 18px;
  color: #ddd;
}

.star.filled {
  color: #ffc107;
}

.review-count {
  font-size: 14px;
  color: #666;
}

.btn-write-review {
  padding: 12px 24px;
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 20px;
  box-shadow: 3px 3px 6px rgba(255, 107, 107, 0.3);
}

.btn-write-review:hover {
  transform: translateY(-2px);
  box-shadow: 5px 5px 10px rgba(255, 107, 107, 0.4);
}

.review-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.review-item {
  padding: 20px;
  background: linear-gradient(145deg, #f5f5f5, #e8e8e8);
  border-radius: 16px;
  box-shadow: inset 2px 2px 5px rgba(0,0,0,0.05), inset -2px -2px 5px rgba(255,255,255,0.8);
}

.review-user {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.user-avatar {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  object-fit: cover;
  box-shadow: 2px 2px 4px rgba(0,0,0,0.1);
}

.user-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.username {
  font-weight: 600;
  color: #333;
  font-size: 15px;
}

.review-rating {
  display: flex;
  gap: 2px;
}

.review-rating .star {
  font-size: 14px;
}

.review-date {
  font-size: 13px;
  color: #999;
}

.review-title {
  font-weight: 600;
  color: #333;
  font-size: 16px;
  margin-bottom: 8px;
}

.review-content-text {
  color: #555;
  line-height: 1.6;
  font-size: 14px;
}

.load-more {
  text-align: center;
  margin-top: 20px;
}

.btn-load-more {
  padding: 12px 30px;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  border: none;
  border-radius: 20px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 3px 3px 6px #bebebe, -3px -3px 6px #ffffff;
}

.btn-load-more:hover:not(:disabled) {
  transform: translateY(-2px);
}

.btn-load-more:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 评价弹窗 */
.review-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.review-form-container {
  width: 90%;
  max-width: 500px;
  padding: 0;
  border-radius: 20px;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
}

.close-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(255,255,255,0.2);
  color: white;
  font-size: 20px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.close-btn:hover {
  background: rgba(255,255,255,0.3);
  transform: rotate(90deg);
}

.modal-body {
  padding: 25px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  font-weight: 600;
  color: #333;
  margin-bottom: 10px;
  font-size: 14px;
}

.rating-selector {
  display: flex;
  align-items: center;
  gap: 8px;
}

.star-select {
  font-size: 32px;
  color: #ddd;
  cursor: pointer;
  transition: all 0.2s;
}

.star-select:hover,
.star-select.active {
  color: #ffc107;
  transform: scale(1.1);
}

.rating-text {
  margin-left: 15px;
  font-size: 14px;
  color: #666;
}

.form-group input[type="text"],
.form-group textarea {
  width: 100%;
  padding: 12px 15px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(145deg, #f0f0f0, #e8e8e8);
  font-size: 14px;
  color: #333;
  box-shadow: inset 2px 2px 5px rgba(0,0,0,0.05), inset -2px -2px 5px rgba(255,255,255,0.8);
  transition: all 0.3s;
}

.form-group input[type="text"]:focus,
.form-group textarea:focus {
  outline: none;
  box-shadow: inset 3px 3px 8px rgba(0,0,0,0.08), inset -3px -3px 8px rgba(255,255,255,0.9);
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.checkbox-group label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
}

.checkbox-group input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.modal-footer {
  display: flex;
  gap: 15px;
  padding: 20px 25px;
  background: linear-gradient(145deg, #f5f5f5, #e8e8e8);
}

.btn-cancel,
.btn-submit {
  flex: 1;
  padding: 14px;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel {
  background: linear-gradient(145deg, #e0e0e0, #d0d0d0);
  color: #666;
}

.btn-cancel:hover {
  background: linear-gradient(145deg, #d0d0d0, #e0e0e0);
}

.btn-submit {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
  box-shadow: 3px 3px 6px rgba(255, 107, 107, 0.3);
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 5px 5px 10px rgba(255, 107, 107, 0.4);
}

.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.description-content {
  background: linear-gradient(145deg, #f5f5f5, #e8e8e8);
  padding: 20px;
  border-radius: 12px;
  line-height: 1.8;
  color: #555;
  font-size: 15px;
  margin-bottom: 30px;
  box-shadow: inset 2px 2px 5px rgba(0,0,0,0.05), inset -2px -2px 5px rgba(255,255,255,0.8);
}

/* 图片预览弹窗 */
.image-preview-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  cursor: zoom-out;
}

.preview-content {
  position: relative;
  max-width: 90%;
  max-height: 90%;
}

.preview-content img {
  max-width: 100%;
  max-height: 90vh;
  object-fit: contain;
  border-radius: 8px;
}

.close-preview {
  position: absolute;
  top: -50px;
  right: 0;
  width: 40px;
  height: 40px;
  border: none;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  font-size: 28px;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-preview:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: rotate(90deg);
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .product-main-content {
    grid-template-columns: 1fr;
    gap: 30px;
  }

  .main-image-container {
    height: 400px;
  }
}

@media (max-width: 768px) {
  .product-detail-page {
    padding: 10px;
  }

  .product-main-section {
    padding: 20px;
  }

  .product-title {
    font-size: 22px;
  }

  .current-price {
    font-size: 28px;
  }

  .action-buttons {
    flex-direction: column;
  }

  .detail-content,
  .spec-content,
  .review-content {
    padding: 25px;
  }

  .spec-name {
    width: 100px;
  }
}
</style>
