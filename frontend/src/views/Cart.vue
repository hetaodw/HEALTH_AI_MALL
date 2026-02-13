<template>
  <div class="cart-page">
    <div class="page-header skeuomorphic-card">
      <h1 class="page-title">购物车</h1>
      <p class="page-subtitle">共 {{ cartItems.length }} 件商品</p>
    </div>

    <!-- 未登录提示 -->
    <div v-if="!userStore.isLoggedIn()" class="not-logged-in skeuomorphic-card">
      <p>请先登录后查看购物车</p>
      <router-link to="/login" class="skeuomorphic-button primary">
        去登录
      </router-link>
    </div>

    <!-- 空购物车 -->
    <div v-else-if="cartItems.length === 0" class="empty-cart skeuomorphic-card">
      <div class="empty-icon">🛒</div>
      <h2>购物车是空的</h2>
      <p>快去挑选心仪的商品吧</p>
      <router-link to="/products" class="skeuomorphic-button primary">
        去购物
      </router-link>
    </div>

    <!-- 购物车列表 -->
    <div v-else class="cart-content">
      <div class="cart-items skeuomorphic-card">
        <div class="cart-header">
          <label class="checkbox-label">
            <input type="checkbox" :checked="allSelected" @change="toggleSelectAll" />
            <span>全选</span>
          </label>
          <span class="header-product">商品信息</span>
          <span class="header-price">单价</span>
          <span class="header-quantity">数量</span>
          <span class="header-total">小计</span>
          <span class="header-action">操作</span>
        </div>

        <div class="cart-list">
          <div v-for="item in cartItems" :key="item.productId" class="cart-item">
            <label class="item-checkbox">
              <input type="checkbox" v-model="item.selected" />
            </label>
            <div class="item-product">
              <img :src="item.coverUrl" :alt="item.title" class="item-image" />
              <div class="item-info">
                <h3 class="item-title">{{ item.title }}</h3>
                <p class="item-stock">库存 {{ item.stock }} 件</p>
              </div>
            </div>
            <div class="item-price">¥{{ item.price.toFixed(2) }}</div>
            <div class="item-quantity">
              <div class="quantity-selector">
                <button @click="decreaseQty(item)" :disabled="item.quantity <= 1" class="qty-btn">-</button>
                <input type="number" v-model.number="item.quantity" min="1" :max="item.stock" class="qty-input" @change="updateQuantity(item)" />
                <button @click="increaseQty(item)" :disabled="item.quantity >= item.stock" class="qty-btn">+</button>
              </div>
            </div>
            <div class="item-total">¥{{ (item.price * item.quantity).toFixed(2) }}</div>
            <div class="item-action">
              <button @click="removeItem(item.productId)" class="delete-btn">删除</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 结算栏 -->
      <div class="cart-footer skeuomorphic-card">
        <div class="footer-left">
          <label class="checkbox-label">
            <input type="checkbox" :checked="allSelected" @change="toggleSelectAll" />
            <span>全选</span>
          </label>
          <button @click="clearCart" class="clear-btn">清空购物车</button>
        </div>
        <div class="footer-right">
          <div class="total-info">
            <span class="selected-count">已选 {{ selectedCount }} 件商品</span>
            <span class="total-label">合计：</span>
            <span class="total-price">¥{{ totalPrice.toFixed(2) }}</span>
          </div>
          <button @click="checkout" :disabled="selectedCount === 0" class="checkout-btn skeuomorphic-button primary">
            去结算
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

const router = useRouter()
const userStore = useUserStore()

const cartItems = ref([])

// 计算属性
const allSelected = computed(() => {
  return cartItems.value.length > 0 && cartItems.value.every(item => item.selected)
})

const selectedCount = computed(() => {
  return cartItems.value.filter(item => item.selected).reduce((sum, item) => sum + item.quantity, 0)
})

const totalPrice = computed(() => {
  return cartItems.value
    .filter(item => item.selected)
    .reduce((sum, item) => sum + item.price * item.quantity, 0)
})

// 加载购物车
const loadCart = () => {
  try {
    const cart = JSON.parse(localStorage.getItem('cart') || '[]')
    cartItems.value = cart
    console.log('Cart loaded:', cart)
  } catch (err) {
    console.error('加载购物车失败:', err)
    cartItems.value = []
  }
}

// 保存购物车
const saveCart = () => {
  try {
    localStorage.setItem('cart', JSON.stringify(cartItems.value))
    // 触发更新事件
    window.dispatchEvent(new StorageEvent('storage', { key: 'cart' }))
  } catch (err) {
    console.error('保存购物车失败:', err)
  }
}

// 全选/取消全选
const toggleSelectAll = () => {
  const newValue = !allSelected.value
  cartItems.value.forEach(item => item.selected = newValue)
  saveCart()
}

// 数量控制
const decreaseQty = (item) => {
  if (item.quantity > 1) {
    item.quantity--
    saveCart()
  }
}

const increaseQty = (item) => {
  if (item.quantity < item.stock) {
    item.quantity++
    saveCart()
  }
}

const updateQuantity = (item) => {
  // 确保数量在有效范围内
  if (item.quantity < 1) item.quantity = 1
  if (item.quantity > item.stock) item.quantity = item.stock
  saveCart()
}

// 删除商品
const removeItem = (productId) => {
  if (!confirm('确定要删除这个商品吗？')) return
  cartItems.value = cartItems.value.filter(item => item.productId !== productId)
  saveCart()
}

// 清空购物车
const clearCart = () => {
  if (!confirm('确定要清空购物车吗？')) return
  cartItems.value = []
  saveCart()
}

// 去结算
const checkout = () => {
  const selectedItems = cartItems.value.filter(item => item.selected)
  if (selectedItems.length === 0) {
    alert('请先选择商品')
    return
  }
  
  if (selectedItems.length === 1) {
    // 单个商品直接跳转到订单确认页
    const item = selectedItems[0]
    router.push({
      path: '/order/confirm',
      query: {
        productId: item.productId,
        quantity: item.quantity
      }
    })
  } else {
    // 多个商品暂不支持，提示用户
    alert('暂不支持多个商品同时结算，请逐个结算')
  }
}

onMounted(() => {
  if (userStore.isLoggedIn()) {
    loadCart()
  }
})
</script>

<style scoped>
.cart-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  background: linear-gradient(135deg, #e0e5ec 0%, #c8d0e0 100%);
  min-height: 100vh;
}

.page-header {
  padding: 24px 32px;
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #333;
  margin-bottom: 8px;
}

.page-subtitle {
  color: #666;
  font-size: 14px;
}

.not-logged-in,
.empty-cart {
  text-align: center;
  padding: 80px;
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 20px;
}

.empty-cart h2 {
  font-size: 24px;
  color: #333;
  margin-bottom: 8px;
}

.empty-cart p {
  color: #999;
  margin-bottom: 24px;
}

.cart-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.cart-items {
  padding: 0;
  overflow: hidden;
}

.cart-header {
  display: grid;
  grid-template-columns: 60px 2fr 120px 150px 120px 80px;
  align-items: center;
  padding: 16px 24px;
  background: linear-gradient(145deg, #f8f9fa, #e9ecef);
  font-weight: 600;
  color: #666;
  font-size: 14px;
}

.cart-list {
  padding: 0 24px;
}

.cart-item {
  display: grid;
  grid-template-columns: 60px 2fr 120px 150px 120px 80px;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid #e0e0e0;
}

.cart-item:last-child {
  border-bottom: none;
}

.checkbox-label,
.item-checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.checkbox-label input,
.item-checkbox input {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.item-product {
  display: flex;
  gap: 16px;
  align-items: center;
}

.item-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.item-info {
  flex: 1;
}

.item-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 4px;
}

.item-stock {
  font-size: 13px;
  color: #999;
}

.item-price,
.item-total {
  font-size: 16px;
  color: #333;
}

.item-total {
  font-weight: 600;
  color: #ff6b6b;
}

.quantity-selector {
  display: flex;
  align-items: center;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.qty-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  cursor: pointer;
  font-size: 18px;
  transition: all 0.3s;
}

.qty-btn:hover:not(:disabled) {
  background: linear-gradient(145deg, #e0e0e0, #f0f0f0);
}

.qty-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.qty-input {
  width: 50px;
  height: 36px;
  border: none;
  text-align: center;
  font-size: 14px;
  background: #f5f5f5;
}

.delete-btn {
  padding: 6px 12px;
  background: transparent;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 13px;
  transition: color 0.3s;
}

.delete-btn:hover {
  color: #ef4444;
}

/* 结算栏 */
.cart-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  position: sticky;
  bottom: 20px;
}

.footer-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.clear-btn {
  padding: 8px 16px;
  background: transparent;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 14px;
}

.clear-btn:hover {
  color: #ef4444;
}

.footer-right {
  display: flex;
  align-items: center;
  gap: 24px;
}

.total-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.selected-count {
  color: #666;
  font-size: 14px;
}

.total-label {
  font-size: 16px;
  color: #333;
}

.total-price {
  font-size: 28px;
  font-weight: 700;
  color: #ff6b6b;
}

.checkout-btn {
  padding: 16px 48px;
  font-size: 18px;
}

.checkout-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 响应式 */
@media (max-width: 768px) {
  .cart-header {
    display: none;
  }
  
  .cart-item {
    grid-template-columns: 1fr;
    gap: 12px;
    padding: 20px;
  }
  
  .item-checkbox {
    position: absolute;
  }
  
  .cart-footer {
    flex-direction: column;
    gap: 16px;
  }
  
  .footer-left,
  .footer-right {
    width: 100%;
    justify-content: space-between;
  }
  
  .checkout-btn {
    width: 100%;
  }
}
</style>
