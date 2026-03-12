<template>
  <div class="order-confirm-page">
    <!-- 页面标题 -->
    <div class="page-header skeuomorphic-card">
      <h1 class="page-title">确认订单</h1>
      <div class="progress-steps">
        <div class="step active">
          <span class="step-number">1</span>
          <span class="step-text">确认订单</span>
        </div>
        <div class="step-line"></div>
        <div class="step" :class="{ active: orderCreated }">
          <span class="step-number">2</span>
          <span class="step-text">支付</span>
        </div>
        <div class="step-line"></div>
        <div class="step" :class="{ active: orderPaid }">
          <span class="step-number">3</span>
          <span class="step-text">完成</span>
        </div>
      </div>
    </div>

    <!-- 未登录提示 -->
    <div v-if="!userStore.isLoggedIn()" class="not-logged-in skeuomorphic-card">
      <p>请先登录后再下单</p>
      <router-link to="/login" class="skeuomorphic-button primary">
        去登录
      </router-link>
    </div>

    <!-- 订单创建成功展示 -->
    <div v-else-if="orderCreated && createdOrder" class="order-success skeuomorphic-card">
      <div class="success-icon">✓</div>
      <h2>订单创建成功！</h2>
      <p class="order-no">订单号：{{ createdOrder.orderNo }}</p>
      
      <!-- 交易快照展示 -->
      <div class="transaction-snapshot">
        <h3>交易快照</h3>
        <div class="snapshot-items">
          <div v-for="item in createdOrder.items" :key="item.id" class="snapshot-item">
            <img :src="item.productCoverUrl" :alt="item.productTitle" class="snapshot-image" />
            <div class="snapshot-info">
              <p class="snapshot-title">{{ item.productTitle }}</p>
              <p class="snapshot-meta">{{ item.category }} | {{ item.merchantName }}</p>
              <p class="snapshot-price">
                <span class="price-label">下单时价格：</span>
                <span class="price-value">¥{{ item.unitPrice.toFixed(2) }}</span>
                <span class="quantity">× {{ item.quantity }}</span>
              </p>
              <p class="snapshot-total">
                <span class="total-label">小计：</span>
                <span class="total-value">¥{{ item.totalPrice.toFixed(2) }}</span>
              </p>
            </div>
          </div>
        </div>
        <div class="snapshot-summary">
          <div class="summary-row">
            <span>商品总数：</span>
            <span>{{ createdOrder.itemCount }} 件</span>
          </div>
          <div class="summary-row">
            <span>订单总价：</span>
            <span class="total-amount">¥{{ createdOrder.totalAmount.toFixed(2) }}</span>
          </div>
          <div class="summary-row">
            <span>收货人：</span>
            <span>{{ createdOrder.receiverName }} {{ createdOrder.receiverPhone }}</span>
          </div>
          <div class="summary-row">
            <span>收货地址：</span>
            <span>{{ createdOrder.receiverAddress }}</span>
          </div>
        </div>
      </div>

      <div class="success-actions">
        <div v-if="createdOrder.status === 'PENDING_CONFIRMATION'" class="status-message pending">
          <p>⏳ 等待商家确认订单</p>
          <p class="status-hint">商家将在30分钟内确认您的订单</p>
        </div>
        <div v-else-if="createdOrder.status === 'CONFIRMED'" class="status-message confirmed">
          <p>✓ 商家已确认订单</p>
          <p v-if="createdOrder.autoConfirmed" class="status-hint">订单已自动确认</p>
        </div>
        <div v-else-if="createdOrder.status === 'REJECTED'" class="status-message rejected">
          <p>✕ 订单已被商家拒绝</p>
          <p v-if="createdOrder.rejectReason" class="status-hint">拒绝原因：{{ createdOrder.rejectReason }}</p>
        </div>
        <button v-if="createdOrder.status === 'PENDING_PAYMENT'" 
                @click="showPayModal = true" 
                class="skeuomorphic-button primary">
          立即支付
        </button>
        <button v-if="createdOrder.status === 'CONFIRMED'" 
                @click="showPayModal = true" 
                class="skeuomorphic-button primary">
          立即支付
        </button>
        <router-link to="/profile" class="skeuomorphic-button">
          查看订单
        </router-link>
        <router-link to="/" class="skeuomorphic-button">
          继续购物
        </router-link>
      </div>
    </div>

    <!-- 订单确认表单 -->
    <div v-else class="order-form">
      <!-- 商品信息 -->
      <div class="section skeuomorphic-card">
        <h2 class="section-title">商品信息</h2>
        <div v-if="loading" class="loading">加载中...</div>
        <div v-else-if="product" class="product-info">
          <img :src="product.coverUrl" :alt="product.title" class="product-image" />
          <div class="product-details">
            <h3 class="product-title">{{ product.title }}</h3>
            <p class="product-category">{{ getCategoryLabel(product.category) }}</p>
            <p class="product-merchant">商家：{{ product.merchantName }}</p>
            <div class="product-price-row">
              <span class="price-label">单价：</span>
              <span class="price-value">¥{{ product.price.toFixed(2) }}</span>
            </div>
            <div class="quantity-row">
              <span class="quantity-label">数量：</span>
              <div class="quantity-selector">
                <button @click="decreaseQty" :disabled="quantity <= 1" class="qty-btn">-</button>
                <input type="number" v-model.number="quantity" min="1" :max="product.stock" class="qty-input" />
                <button @click="increaseQty" :disabled="quantity >= product.stock" class="qty-btn">+</button>
              </div>
              <span class="stock-info">库存 {{ product.stock }} 件</span>
            </div>
            <div class="subtotal-row">
              <span class="subtotal-label">小计：</span>
              <span class="subtotal-value">¥{{ subtotal.toFixed(2) }}</span>
            </div>
          </div>
        </div>
        <div v-else class="error-message">
          商品信息加载失败
        </div>
      </div>

      <!-- 收货地址 -->
      <div class="section skeuomorphic-card">
        <div class="section-header">
          <h2 class="section-title">收货地址</h2>
          <button @click="openAddressModal()" class="skeuomorphic-button small">
            + 新建地址
          </button>
        </div>
        <div v-if="loadingAddresses" class="loading">加载中...</div>
        <div v-else-if="addresses.length === 0" class="empty-addresses">
          <p>暂无收货地址，请先添加</p>
          <button @click="openAddressModal()" class="skeuomorphic-button primary">
            添加地址
          </button>
        </div>
        <div v-else class="address-list">
          <div v-for="address in addresses" :key="address.id" 
               :class="['address-item', { selected: selectedAddress?.id === address.id }]"
               @click="selectAddress(address)">
            <div class="address-radio">
              <div class="radio-inner" v-if="selectedAddress?.id === address.id"></div>
            </div>
            <div class="address-content">
              <div class="address-header">
                <span class="receiver-name">{{ address.receiverName }}</span>
                <span class="receiver-phone">{{ address.receiverPhone }}</span>
                <span v-if="address.isDefault" class="default-badge">默认</span>
              </div>
              <p class="address-detail">{{ address.fullAddress }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 订单备注 -->
      <div class="section skeuomorphic-card">
        <h2 class="section-title">订单备注</h2>
        <textarea v-model="remark" placeholder="请输入订单备注（选填）" class="remark-input" rows="3"></textarea>
      </div>

    </div>

    <!-- 订单汇总 - 固定底部 (仅在未创建订单时显示) -->
    <div v-if="!orderCreated" class="order-summary-bar">
      <div class="summary-content-wrapper">
        <div class="summary-left">
          <span class="summary-label">应付总额：</span>
          <span class="summary-total-price">¥{{ subtotal.toFixed(2) }}</span>
          <span class="summary-detail" @click="showSummaryDetail = !showSummaryDetail">
            明细 {{ showSummaryDetail ? '▲' : '▼' }}
          </span>
        </div>
        <div class="summary-right">
          <button @click="submitOrder" 
                  :disabled="!canSubmit" 
                  class="submit-order-btn"
                  :class="{ disabled: !canSubmit }">
            {{ submitting ? '提交中...' : '提交订单' }}
          </button>
        </div>
      </div>
      <!-- 明细展开区域 -->
      <div v-if="showSummaryDetail" class="summary-detail-panel">
        <div class="detail-row">
          <span>商品金额：</span>
          <span>¥{{ subtotal.toFixed(2) }}</span>
        </div>
        <div class="detail-row">
          <span>运费：</span>
          <span>¥0.00</span>
        </div>
        <div class="detail-row total">
          <span>应付总额：</span>
          <span>¥{{ subtotal.toFixed(2) }}</span>
        </div>
      </div>
    </div>

    <!-- 新建/编辑地址弹窗 -->
    <div v-if="showAddressModal" class="modal-overlay" @click="closeAddressModal">
      <div class="modal skeuomorphic-card" @click.stop>
        <div class="modal-header">
          <h3>{{ editingAddress ? '编辑地址' : '新建地址' }}</h3>
          <button @click="closeAddressModal" class="close-btn">×</button>
        </div>
        <form @submit.prevent="saveAddress" class="address-form">
          <div class="form-row">
            <div class="form-group">
              <label class="form-label">收货人姓名 <span class="required">*</span></label>
              <input v-model="addressForm.receiverName" type="text" placeholder="请输入收货人姓名" class="skeuomorphic-input" :class="{ 'error': formErrors.receiverName }" @blur="validateField('receiverName')" />
              <div v-if="formErrors.receiverName" class="field-error">{{ formErrors.receiverName }}</div>
            </div>
            <div class="form-group">
              <label class="form-label">手机号码 <span class="required">*</span></label>
              <input v-model="addressForm.receiverPhone" type="tel" placeholder="请输入手机号码" class="skeuomorphic-input" :class="{ 'error': formErrors.receiverPhone }" @blur="validateField('receiverPhone')" maxlength="11" />
              <div v-if="formErrors.receiverPhone" class="field-error">{{ formErrors.receiverPhone }}</div>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label">省份 <span class="required">*</span></label>
              <select v-model="addressForm.province" class="skeuomorphic-input" :class="{ 'error': formErrors.province }" @change="handleProvinceChange">
                <option value="">请选择省份</option>
                <option v-for="province in provinces" :key="province" :value="province">{{ province }}</option>
              </select>
              <div v-if="formErrors.province" class="field-error">{{ formErrors.province }}</div>
            </div>
            <div class="form-group">
              <label class="form-label">城市 <span class="required">*</span></label>
              <select v-model="addressForm.city" class="skeuomorphic-input" :class="{ 'error': formErrors.city }" @change="handleCityChange" :disabled="!addressForm.province">
                <option value="">请选择城市</option>
                <option v-for="city in cities" :key="city" :value="city">{{ city }}</option>
              </select>
              <div v-if="formErrors.city" class="field-error">{{ formErrors.city }}</div>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">区/县 <span class="required">*</span></label>
            <select v-model="addressForm.district" class="skeuomorphic-input" :class="{ 'error': formErrors.district }" :disabled="!addressForm.city">
              <option value="">请选择区/县</option>
              <option v-for="district in districts" :key="district" :value="district">{{ district }}</option>
            </select>
            <div v-if="formErrors.district" class="field-error">{{ formErrors.district }}</div>
          </div>
          <div class="form-group">
            <label class="form-label">详细地址 <span class="required">*</span></label>
            <textarea v-model="addressForm.detailAddress" placeholder="请输入详细地址，如街道、门牌号等" class="skeuomorphic-input" :class="{ 'error': formErrors.detailAddress }" rows="3" @blur="validateField('detailAddress')"></textarea>
            <div v-if="formErrors.detailAddress" class="field-error">{{ formErrors.detailAddress }}</div>
          </div>
          <div class="form-group checkbox-group">
            <label class="checkbox-label">
              <input type="checkbox" v-model="addressForm.isDefault" />
              <span>设为默认地址</span>
            </label>
          </div>
          <div v-if="addressError" class="error-message">{{ addressError }}</div>
          <div class="modal-actions">
            <button type="button" @click="closeAddressModal" class="skeuomorphic-button">取消</button>
            <button type="submit" class="skeuomorphic-button primary" :disabled="addressLoading">
              {{ addressLoading ? '保存中...' : '保存' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- 支付弹窗 -->
    <div v-if="showPayModal" class="modal-overlay" @click="showPayModal = false">
      <div class="modal skeuomorphic-card pay-modal" @click.stop>
        <div class="modal-header">
          <h3>选择支付方式</h3>
          <button @click="showPayModal = false" class="close-btn">×</button>
        </div>
        <div class="pay-content">
          <p class="pay-amount">支付金额：<span class="total-price">¥{{ createdOrder?.totalAmount?.toFixed(2) }}</span></p>
          <div class="pay-methods">
            <div v-for="method in payMethods" :key="method.value"
                 :class="['pay-method', 'skeuomorphic-card', { active: selectedPayMethod === method.value }]"
                 @click="selectedPayMethod = method.value">
              <span class="pay-icon">{{ method.icon }}</span>
              <span class="pay-name">{{ method.label }}</span>
            </div>
          </div>
          <div class="modal-actions">
            <button type="button" @click="showPayModal = false" class="skeuomorphic-button">取消</button>
            <button @click="confirmPay" class="skeuomorphic-button primary" :disabled="payLoading">
              {{ payLoading ? '支付中...' : '确认支付' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import api from '../api'
import { getCategoryLabel } from '../constants/productCategories'
import { validateAddressForm, validatePhone, validateReceiverName, validateProvince, validateCity, validateDistrict, validateDetailAddress } from '../utils/validators'
import { getProvinces, getCitiesByProvince, getDistrictsByProvinceAndCity } from '../utils/chinaRegions'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 商品相关
const product = ref(null)
const quantity = ref(1)
const loading = ref(false)

// 地址相关
const addresses = ref([])
const selectedAddress = ref(null)
const loadingAddresses = ref(false)
const showAddressModal = ref(false)
const editingAddress = ref(null)
const addressLoading = ref(false)
const addressError = ref('')

// 订单相关
const remark = ref('')
const submitting = ref(false)
const orderCreated = ref(false)
const orderPaid = ref(false)
const createdOrder = ref(null)
const showPayModal = ref(false)
const selectedPayMethod = ref('ALIPAY')
const payLoading = ref(false)
const showSummaryDetail = ref(false)

// 支付方式
const payMethods = [
  { label: '支付宝', value: 'ALIPAY', icon: '💳' },
  { label: '微信支付', value: 'WECHAT', icon: '💬' },
  { label: '银行卡', value: 'BANK', icon: '🏦' }
]

// 地址表单
const addressForm = ref({
  receiverName: '',
  receiverPhone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false
})
const formErrors = ref({})

// 地区数据
const provinces = computed(() => getProvinces())
const cities = computed(() => {
  if (!addressForm.value.province) return []
  return getCitiesByProvince(addressForm.value.province)
})
const districts = computed(() => {
  if (!addressForm.value.province || !addressForm.value.city) return []
  return getDistrictsByProvinceAndCity(addressForm.value.province, addressForm.value.city)
})

// 省份变化处理
const handleProvinceChange = () => {
  addressForm.value.city = ''
  addressForm.value.district = ''
  delete formErrors.value.province
}

// 城市变化处理
const handleCityChange = () => {
  addressForm.value.district = ''
  delete formErrors.value.city
}

// 计算属性
const subtotal = computed(() => {
  if (!product.value) return 0
  return product.value.price * quantity.value
})

const canSubmit = computed(() => {
  return product.value && selectedAddress.value && !submitting.value
})

// 获取商品详情
const fetchProductDetail = async () => {
  const productId = route.query.productId
  if (!productId) {
    alert('商品ID不能为空')
    router.push('/products')
    return
  }

  // 从路由参数获取数量
  const qty = parseInt(route.query.quantity)
  if (qty && qty > 0) {
    quantity.value = qty
  }

  loading.value = true
  try {
    console.log('Fetching product detail:', productId)
    const res = await api.products.getDetail(productId)
    if (res.code === 200) {
      product.value = res.data
      console.log('Product loaded:', product.value)
    } else {
      alert('获取商品详情失败：' + res.msg)
    }
  } catch (err) {
    console.error('获取商品详情失败:', err)
    alert('获取商品详情失败')
  } finally {
    loading.value = false
  }
}

// 获取地址列表
const fetchAddresses = async () => {
  loadingAddresses.value = true
  try {
    console.log('Fetching addresses')
    const res = await api.addresses.getList()
    if (res.code === 200) {
      addresses.value = res.data || []
      // 自动选择默认地址
      const defaultAddress = addresses.value.find(a => a.isDefault)
      if (defaultAddress) {
        selectedAddress.value = defaultAddress
      } else if (addresses.value.length > 0) {
        selectedAddress.value = addresses.value[0]
      }
      console.log('Addresses loaded:', addresses.value.length)
    }
  } catch (err) {
    console.error('获取地址失败:', err)
  } finally {
    loadingAddresses.value = false
  }
}

// 数量控制
const decreaseQty = () => {
  if (quantity.value > 1) quantity.value--
}

const increaseQty = () => {
  if (product.value && quantity.value < product.value.stock) {
    quantity.value++
  }
}

// 选择地址
const selectAddress = (address) => {
  selectedAddress.value = address
}

// 打开地址弹窗
const openAddressModal = (address = null) => {
  if (address) {
    editingAddress.value = address
    addressForm.value = { ...address }
  } else {
    editingAddress.value = null
    addressForm.value = {
      receiverName: '',
      receiverPhone: '',
      province: '',
      city: '',
      district: '',
      detailAddress: '',
      isDefault: false
    }
  }
  addressError.value = ''
  formErrors.value = {}
  showAddressModal.value = true
}

// 验证单个字段
const validateField = (field) => {
  const value = addressForm.value[field]
  let result
  
  switch (field) {
    case 'receiverName':
      result = validateReceiverName(value)
      break
    case 'receiverPhone':
      result = validatePhone(value)
      break
    case 'province':
      result = validateProvince(value)
      break
    case 'city':
      result = validateCity(value)
      break
    case 'district':
      result = validateDistrict(value)
      break
    case 'detailAddress':
      result = validateDetailAddress(value)
      break
    default:
      result = { valid: true, message: '' }
  }
  
  if (!result.valid) {
    formErrors.value[field] = result.message
  } else {
    delete formErrors.value[field]
  }
  
  return result.valid
}

// 关闭地址弹窗
const closeAddressModal = () => {
  showAddressModal.value = false
  editingAddress.value = null
}

// 保存地址
const saveAddress = async () => {
  const validation = validateAddressForm(addressForm.value)
  
  if (!validation.valid) {
    formErrors.value = validation.errors
    return
  }
  
  addressLoading.value = true
  addressError.value = ''
  try {
    let res
    if (editingAddress.value) {
      res = await api.addresses.update(editingAddress.value.id, addressForm.value)
    } else {
      res = await api.addresses.create(addressForm.value)
    }
    
    if (res.code === 200) {
      closeAddressModal()
      await fetchAddresses()
      // 如果是新建地址，自动选中新地址
      if (!editingAddress.value) {
        selectedAddress.value = res.data
      }
    } else {
      addressError.value = res.msg || '保存失败'
    }
  } catch (err) {
    console.error('保存地址失败:', err)
    addressError.value = '保存失败，请稍后重试'
  } finally {
    addressLoading.value = false
  }
}

// 提交订单
const submitOrder = async () => {
  if (!canSubmit.value) return

  submitting.value = true
  try {
    const orderData = {
      addressId: selectedAddress.value.id,
      items: [
        {
          productId: product.value.id,
          quantity: quantity.value
        }
      ],
      remark: remark.value
    }

    console.log('Submitting order:', orderData)
    const res = await api.orders.create(orderData)
    
    if (res.code === 200) {
      console.log('Order created:', res.data)
      createdOrder.value = res.data
      orderCreated.value = true
      // 清空购物车中该商品（如果存在）
      removeFromCart(product.value.id)
      // 滚动到顶部
      window.scrollTo({ top: 0, behavior: 'smooth' })
    } else {
      alert('创建订单失败：' + res.msg)
    }
  } catch (err) {
    console.error('创建订单失败:', err)
    alert('创建订单失败，请稍后重试')
  } finally {
    submitting.value = false
  }
}

// 从购物车移除商品
const removeFromCart = (productId) => {
  try {
    const cart = JSON.parse(localStorage.getItem('cart') || '[]')
    const newCart = cart.filter(item => item.productId !== productId)
    localStorage.setItem('cart', JSON.stringify(newCart))
  } catch (err) {
    console.error('更新购物车失败:', err)
  }
}

// 确认支付
const confirmPay = async () => {
  if (!createdOrder.value) return
  
  payLoading.value = true
  try {
    const res = await api.orders.payOrder(createdOrder.value.orderNo, selectedPayMethod.value)
    if (res.code === 200) {
      orderPaid.value = true
      showPayModal.value = false
      createdOrder.value = res.data
      alert('支付成功！')
    } else {
      alert('支付失败：' + res.msg)
    }
  } catch (err) {
    console.error('支付失败:', err)
    alert('支付失败，请稍后重试')
  } finally {
    payLoading.value = false
  }
}

onMounted(() => {
  if (!userStore.isLoggedIn()) {
    return
  }
  fetchProductDetail()
  fetchAddresses()
})
</script>

<style scoped>
.order-confirm-page {
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
  margin-bottom: 20px;
  color: #333;
}

.progress-steps {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.step {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #999;
}

.step.active {
  color: #667eea;
}

.step-number {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.step.active .step-number {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
}

.step-line {
  width: 60px;
  height: 2px;
  background: linear-gradient(90deg, #e0e0e0, #c0c0c0);
}

.not-logged-in {
  text-align: center;
  padding: 60px;
}

.not-logged-in p {
  margin-bottom: 20px;
  color: #666;
}

.order-success {
  text-align: center;
  padding: 40px;
}

.success-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: linear-gradient(145deg, #4ade80, #22c55e);
  color: white;
  font-size: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
  box-shadow: 
    5px 5px 10px rgba(74, 222, 128, 0.3),
    -2px -2px 5px rgba(255, 255, 255, 0.5);
}

.status-message {
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  text-align: center;
}

.status-message.pending {
  background: linear-gradient(145deg, #fef3c7, #fde68a);
  color: #92400e;
}

.status-message.confirmed {
  background: linear-gradient(145deg, #d1fae5, #a7f3d0);
  color: #065f46;
}

.status-message.rejected {
  background: linear-gradient(145deg, #fee2e2, #fecaca);
  color: #991b1b;
}

.status-message p {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}

.status-hint {
  font-size: 14px !important;
  font-weight: 400 !important;
  margin-top: 8px !important;
}

.order-success h2 {
  font-size: 24px;
  color: #333;
  margin-bottom: 8px;
}

.order-no {
  color: #666;
  margin-bottom: 24px;
}

/* 交易快照 */
.transaction-snapshot {
  text-align: left;
  background: linear-gradient(145deg, #f8f9fa, #e9ecef);
  border-radius: 16px;
  padding: 24px;
  margin: 24px 0;
}

.transaction-snapshot h3 {
  font-size: 18px;
  margin-bottom: 16px;
  color: #333;
}

.snapshot-items {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 20px;
}

.snapshot-item {
  display: flex;
  gap: 16px;
  background: white;
  padding: 16px;
  border-radius: 12px;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.05),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.snapshot-image {
  width: 100px;
  height: 100px;
  border-radius: 8px;
  object-fit: cover;
}

.snapshot-info {
  flex: 1;
}

.snapshot-title {
  font-weight: 600;
  color: #333;
  margin-bottom: 4px;
}

.snapshot-meta {
  font-size: 13px;
  color: #999;
  margin-bottom: 8px;
}

.snapshot-price {
  font-size: 14px;
  color: #666;
  margin-bottom: 4px;
}

.snapshot-price .price-value {
  color: #ff6b6b;
  font-weight: 600;
}

.snapshot-total {
  font-size: 14px;
  color: #333;
}

.snapshot-total .total-value {
  color: #667eea;
  font-weight: 700;
  font-size: 16px;
}

.snapshot-summary {
  border-top: 1px solid #e0e0e0;
  padding-top: 16px;
}

.snapshot-summary .summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.snapshot-summary .total-amount {
  font-size: 20px;
  font-weight: 700;
  color: #ff6b6b;
}

.success-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-top: 24px;
}

.order-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.section {
  padding: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-title {
  font-size: 18px;
  font-weight: 700;
  color: #333;
}

.loading {
  text-align: center;
  padding: 40px;
  color: #999;
}

.error-message {
  text-align: center;
  padding: 40px;
  color: #ef4444;
}

.field-error {
  font-size: 12px;
  color: #c33;
  margin-top: 4px;
}

.skeuomorphic-input.error {
  border: 2px solid #c33;
  background: linear-gradient(145deg, #fff5f5, #ffe0e0);
}

/* 商品信息 */
.product-info {
  display: flex;
  gap: 24px;
}

.product-image {
  width: 150px;
  height: 150px;
  border-radius: 12px;
  object-fit: cover;
  box-shadow: 
    5px 5px 10px #bebebe,
    -5px -5px 10px #ffffff;
}

.product-details {
  flex: 1;
}

.product-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.product-category,
.product-merchant {
  font-size: 14px;
  color: #666;
  margin-bottom: 4px;
}

.product-price-row {
  margin: 12px 0;
}

.price-label {
  color: #666;
}

.price-value {
  font-size: 20px;
  font-weight: 700;
  color: #ff6b6b;
}

.quantity-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 12px 0;
}

.quantity-label {
  color: #666;
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
  width: 60px;
  height: 36px;
  border: none;
  text-align: center;
  font-size: 14px;
  background: #f5f5f5;
}

.stock-info {
  font-size: 13px;
  color: #999;
}

.subtotal-row {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #e0e0e0;
}

.subtotal-label {
  color: #666;
}

.subtotal-value {
  font-size: 20px;
  font-weight: 700;
  color: #667eea;
}

/* 地址列表 */
.empty-addresses {
  text-align: center;
  padding: 40px;
}

.empty-addresses p {
  color: #999;
  margin-bottom: 16px;
}

.address-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.address-item:hover {
  transform: translateY(-2px);
}

.address-item.selected {
  border-color: #667eea;
  background: linear-gradient(145deg, #f8f9ff, #eef0ff);
}

.address-radio {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 2px solid #ccc;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin-top: 2px;
}

.address-item.selected .address-radio {
  border-color: #667eea;
}

.radio-inner {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: linear-gradient(145deg, #667eea, #764ba2);
}

.address-content {
  flex: 1;
}

.address-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 4px;
}

.receiver-name {
  font-weight: 600;
  color: #333;
}

.receiver-phone {
  color: #666;
  font-size: 14px;
}

.default-badge {
  padding: 2px 8px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  font-size: 12px;
  border-radius: 4px;
}

.address-detail {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}

/* 备注输入 */
.remark-input {
  width: 100%;
  padding: 12px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  box-shadow: 
    inset 3px 3px 6px #bebebe,
    inset -3px -3px 6px #ffffff;
  resize: vertical;
  font-family: inherit;
}

/* 订单汇总 - 固定底部 */
.order-summary-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.15);
  z-index: 100;
  border-top: 1px solid rgba(255, 255, 255, 0.5);
}

.summary-content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.summary-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.summary-label {
  font-size: 16px;
  color: #666;
}

.summary-total-price {
  font-size: 28px;
  font-weight: 700;
  color: #ff6b6b;
}

.summary-detail {
  font-size: 14px;
  color: #667eea;
  cursor: pointer;
  margin-left: 8px;
  user-select: none;
}

.summary-detail:hover {
  text-decoration: underline;
}

.summary-right {
  display: flex;
  align-items: center;
}

.submit-order-btn {
  padding: 14px 48px;
  font-size: 18px;
  font-weight: 600;
  background: linear-gradient(145deg, #ff6b6b, #ee5a5a);
  color: white;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  box-shadow: 
    4px 4px 8px rgba(255, 107, 107, 0.3),
    -2px -2px 4px rgba(255, 255, 255, 0.5);
  transition: all 0.3s ease;
}

.submit-order-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    6px 6px 12px rgba(255, 107, 107, 0.4),
    -2px -2px 4px rgba(255, 255, 255, 0.5);
}

.submit-order-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 明细展开面板 */
.summary-detail-panel {
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 24px;
  background: linear-gradient(145deg, #f8f9fa, #e9ecef);
  border-top: 1px solid #e0e0e0;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.summary-detail-panel .detail-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.summary-detail-panel .detail-row.total {
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid #e0e0e0;
  font-weight: 600;
  color: #333;
}

/* 为固定底部栏添加页面底部padding */
.order-form {
  padding-bottom: 100px;
}

/* 弹窗 */
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
  z-index: 1000;
  padding: 20px;
}

.modal {
  max-width: 500px;
  width: 100%;
  padding: 24px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.modal-header h3 {
  font-size: 20px;
  color: #333;
}

.close-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  cursor: pointer;
  font-size: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 
    3px 3px 6px #bebebe,
    -3px -3px 6px #ffffff;
}

.address-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-label {
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.required {
  color: #ef4444;
}

.checkbox-group {
  flex-direction: row;
  align-items: center;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.modal-actions {
  display: flex;
  gap: 12px;
  margin-top: 8px;
}

.modal-actions button {
  flex: 1;
}

/* 支付弹窗 */
.pay-modal {
  max-width: 400px;
}

.pay-content {
  text-align: center;
}

.pay-amount {
  font-size: 16px;
  margin-bottom: 20px;
}

.pay-methods {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 24px;
}

.pay-method {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.3s;
}

.pay-method.active {
  border-color: #667eea;
  background: linear-gradient(145deg, #f8f9ff, #eef0ff);
}

.pay-icon {
  font-size: 24px;
}

.pay-name {
  font-size: 16px;
  font-weight: 500;
}

/* 响应式 */
@media (max-width: 768px) {
  .product-info {
    flex-direction: column;
  }
  
  .product-image {
    width: 100%;
    height: 200px;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .success-actions {
    flex-direction: column;
  }
  
  /* 移动端订单汇总栏 */
  .summary-content-wrapper {
    padding: 12px 16px;
    flex-direction: column;
    gap: 12px;
  }
  
  .summary-left {
    width: 100%;
    justify-content: space-between;
  }
  
  .summary-total-price {
    font-size: 24px;
  }
  
  .submit-order-btn {
    width: 100%;
    padding: 12px 24px;
  }
  
  .order-form {
    padding-bottom: 140px;
  }
}
</style>
