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

        <!-- 详细介绍图片 - 竖版全大小展示 -->
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
        <h3 class="section-title">用户评价</h3>
        <div class="review-placeholder">
          <p>暂无评价</p>
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
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../api'

const route = useRoute()
const router = useRouter()

const product = ref({})
const loading = ref(false)
const quantity = ref(1)
const currentImage = ref('')
const activeTab = ref('detail')
const showImagePreview = ref(false)
const previewDetailImageUrl = ref(null)

const placeholderImage = 'https://via.placeholder.com/600x600?text=Product'

// 商家头像 - 使用API返回的头像或默认占位符
const merchantAvatar = computed(() => {
  return product.value.merchantAvatar || 'https://via.placeholder.com/60x60?text=Shop'
})

// 所有图片（封面图 + 详情图）
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

// 获取商品详情
const fetchProductDetail = async () => {
  const productId = route.params.id
  if (!productId) return

  loading.value = true
  try {
    const response = await api.products.getDetail(productId)
    if (response.code === 200) {
      product.value = response.data
      currentImage.value = product.value.coverUrl || placeholderImage
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

// 数量控制
const decreaseQty = () => {
  if (quantity.value > 1) quantity.value--
}

const increaseQty = () => {
  if (quantity.value < product.value.stock) quantity.value++
}

// 立即购买
const buyNow = () => {
  const token = localStorage.getItem('token')
  if (!token) {
    alert('请先登录')
    router.push('/login')
    return
  }
  
  // 跳转到确认订单页面
  router.push({
    name: 'OrderConfirm',
    query: {
      productId: product.value.id,
      quantity: quantity.value
    }
  })
}

// 加入购物车
const addToCart = () => {
  const token = localStorage.getItem('token')
  if (!token) {
    alert('请先登录')
    router.push('/login')
    return
  }
  
  try {
    // 获取现有购物车
    const cart = JSON.parse(localStorage.getItem('cart') || '[]')
    
    // 检查商品是否已在购物车中
    const existingItem = cart.find(item => item.productId === product.value.id)
    
    if (existingItem) {
      // 更新数量
      const newQuantity = existingItem.quantity + quantity.value
      if (newQuantity > product.value.stock) {
        alert(`库存不足，最多可购买 ${product.value.stock} 件`)
        return
      }
      existingItem.quantity = newQuantity
    } else {
      // 添加新商品
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
    
    // 保存到 localStorage
    localStorage.setItem('cart', JSON.stringify(cart))
    
    // 触发购物车更新事件
    window.dispatchEvent(new StorageEvent('storage', { key: 'cart' }))
    
    alert(`已将 ${quantity.value} 件 "${product.value.title}" 加入购物车`)
    console.log('Cart updated:', cart)
  } catch (err) {
    console.error('加入购物车失败:', err)
    alert('加入购物车失败，请稍后重试')
  }
}

// 预览详情图片
const previewDetailImage = (url) => {
  previewDetailImageUrl.value = url
}

// 格式化状态
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
