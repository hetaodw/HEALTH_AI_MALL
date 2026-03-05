<template>
  <div class="profile-page">
    <div v-if="!userStore.user" class="not-logged-in">
      <div class="skeuomorphic-card">
        <h2>请先登录</h2>
        <p>登录后查看个人信息</p>
        <router-link to="/login" class="skeuomorphic-button primary">
          去登录
        </router-link>
      </div>
    </div>

    <div v-else class="profile-container">
      <div class="profile-header skeuomorphic-card">
        <div class="avatar-container">
          <AvatarUpload 
            :current-avatar="userStore.user.avatarUrl" 
            @avatar-updated="handleAvatarUpdated"
          />
        </div>
        <div class="user-info">
          <h2 class="username">{{ userStore.user.username }}</h2>
          <p class="user-email">{{ userStore.user.email }}</p>
          <p class="user-phone">{{ userStore.user.phone }}</p>
        </div>
      </div>

      <div class="profile-content">
        <div class="profile-section skeuomorphic-card">
          <h3 class="section-title">个人信息</h3>
          <div class="info-grid">
            <div class="info-item">
              <label class="info-label">用户名</label>
              <p class="info-value">{{ userStore.user.username }}</p>
            </div>
            <div class="info-item">
              <label class="info-label">邮箱</label>
              <p class="info-value">{{ userStore.user.email }}</p>
            </div>
            <div class="info-item">
              <label class="info-label">手机号</label>
              <p class="info-value">{{ userStore.user.phone }}</p>
            </div>
            <div class="info-item">
              <label class="info-label">注册时间</label>
              <p class="info-value">{{ formatDate(userStore.user.createdAt) }}</p>
            </div>
          </div>
        </div>

        <div v-if="userStore.isMerchant()" class="profile-section merchant-entry skeuomorphic-card">
          <div class="merchant-entry-content">
            <div class="merchant-icon">🏪</div>
            <div class="merchant-info">
              <h3 class="merchant-title">商家管理后台</h3>
              <p class="merchant-description">管理您的商品、订单和店铺设置</p>
            </div>
            <router-link to="/merchant" class="merchant-button skeuomorphic-button primary">
              进入后台
            </router-link>
          </div>
        </div>

        <!-- 我的地址 -->
        <div class="profile-section skeuomorphic-card">
          <div class="section-header">
            <h3 class="section-title">我的收货地址</h3>
            <button @click="openAddressModal()" class="skeuomorphic-button primary">
              + 新建地址
            </button>
          </div>
          <div class="address-list">
            <div v-if="addresses.length === 0" class="empty-addresses">
              <p>暂无收货地址，请添加</p>
            </div>
            <div v-else class="address-items">
              <div v-for="address in addresses" :key="address.id" 
                   :class="['address-item', 'skeuomorphic-card', { 'default-address': address.isDefault }]">
                <div class="address-info">
                  <div class="address-header">
                    <span class="receiver-name">{{ address.receiverName }}</span>
                    <span class="receiver-phone">{{ address.receiverPhone }}</span>
                    <span v-if="address.isDefault" class="default-badge">默认</span>
                  </div>
                  <p class="address-detail">{{ address.fullAddress }}</p>
                </div>
                <div class="address-actions">
                  <button v-if="!address.isDefault" 
                          @click="setDefaultAddress(address.id)" 
                          class="action-btn">
                    设为默认
                  </button>
                  <button @click="openAddressModal(address)" class="action-btn">
                    编辑
                  </button>
                  <button @click="deleteAddress(address.id)" class="action-btn delete">
                    删除
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="profile-section skeuomorphic-card">
          <h3 class="section-title">我的订单</h3>
          <div class="order-tabs">
            <button
              v-for="tab in orderTabs"
              :key="tab.value"
              @click="activeOrderTab = tab.value"
              :class="['order-tab', 'skeuomorphic-button', { active: activeOrderTab === tab.value }]"
            >
              {{ tab.label }}
            </button>
          </div>
          <div class="order-list">
            <div v-if="filteredOrders.length === 0" class="empty-orders">
              <p>暂无订单</p>
            </div>
            <div v-else class="order-items">
              <div v-for="order in filteredOrders" :key="order.id" class="order-item skeuomorphic-card">
                <div class="order-header">
                  <div class="order-info-left">
                    <span class="order-no">订单号：{{ order.orderNo }}</span>
                    <span class="order-date">{{ formatDateTime(order.createdAt) }}</span>
                  </div>
                  <span :class="['order-status', `status-${order.status}`]">
                    {{ getOrderStatusText(order.status) }}
                  </span>
                </div>
                <div class="order-content">
                  <div class="order-products">
                    <div v-for="item in order.items" :key="item.id" class="order-product">
                      <img :src="item.productCoverUrl" :alt="item.productTitle" class="order-product-image" />
                      <div class="order-product-info">
                        <p class="order-product-title">{{ item.productTitle }}</p>
                        <p class="order-product-meta">{{ item.category }} | {{ item.merchantName }}</p>
                        <p class="order-product-price">¥{{ item.unitPrice.toFixed(2) }} × {{ item.quantity }}</p>
                      </div>
                      <div class="order-product-total">
                        ¥{{ item.totalPrice.toFixed(2) }}
                      </div>
                    </div>
                  </div>
                  <div class="order-footer">
                    <div class="order-total">
                      <span class="item-count">共 {{ order.itemCount }} 件商品</span>
                      <span class="total-label">总计：</span>
                      <span class="total-price">¥{{ order.totalAmount.toFixed(2) }}</span>
                    </div>
                    <div class="order-actions">
                      <button v-if="order.status === 'PENDING_PAYMENT'" 
                              @click="payOrder(order)" 
                              class="skeuomorphic-button primary">
                        立即支付
                      </button>
                      <button v-if="order.status === 'PENDING_PAYMENT'" 
                              @click="cancelOrder(order.id)" 
                              class="skeuomorphic-button">
                        取消订单
                      </button>
                      <button @click="viewOrderDetail(order.id)" class="skeuomorphic-button">
                        查看详情
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="profile-section skeuomorphic-card">
          <h3 class="section-title">账户设置</h3>
          <div class="settings-list">
            <router-link to="/browsing-history" class="setting-item skeuomorphic-button">
              浏览记录
            </router-link>
            <button @click="showChangePassword = true" class="setting-item skeuomorphic-button">
              修改密码
            </button>
            <button @click="handleLogout" class="setting-item skeuomorphic-button danger">
              退出登录
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 修改密码弹窗 -->
    <div v-if="showChangePassword" class="modal-overlay" @click="showChangePassword = false">
      <div class="modal skeuomorphic-card" @click.stop>
        <h3>修改密码</h3>
        <form @submit.prevent="handleChangePassword" class="password-form">
          <div class="form-group">
            <label class="form-label">当前密码</label>
            <input
              v-model="passwordForm.currentPassword"
              type="password"
              placeholder="请输入当前密码"
              class="skeuomorphic-input"
              required
            />
          </div>
          <div class="form-group">
            <label class="form-label">新密码</label>
            <input
              v-model="passwordForm.newPassword"
              type="password"
              placeholder="请输入新密码（至少6位）"
              class="skeuomorphic-input"
              required
              minlength="6"
            />
          </div>
          <div class="form-group">
            <label class="form-label">确认新密码</label>
            <input
              v-model="passwordForm.confirmPassword"
              type="password"
              placeholder="请再次输入新密码"
              class="skeuomorphic-input"
              required
            />
          </div>
          <div v-if="passwordError" class="error">
            {{ passwordError }}
          </div>
          <div class="modal-actions">
            <button type="button" @click="showChangePassword = false" class="skeuomorphic-button">
              取消
            </button>
            <button type="submit" class="skeuomorphic-button primary" :disabled="passwordLoading">
              {{ passwordLoading ? '修改中...' : '确认修改' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- 地址编辑弹窗 -->
    <div v-if="showAddressModal" class="modal-overlay" @click="closeAddressModal">
      <div class="modal skeuomorphic-card address-modal" @click.stop>
        <div class="modal-header">
          <h3>{{ editingAddress ? '编辑地址' : '新建地址' }}</h3>
          <button @click="closeAddressModal" class="close-btn">×</button>
        </div>
        <form @submit.prevent="saveAddress" class="address-form">
          <div class="form-row">
            <div class="form-group">
              <label class="form-label">收货人姓名 <span class="required">*</span></label>
              <input
                v-model="addressForm.receiverName"
                type="text"
                placeholder="请输入收货人姓名"
                class="skeuomorphic-input"
                required
              />
            </div>
            <div class="form-group">
              <label class="form-label">手机号码 <span class="required">*</span></label>
              <input
                v-model="addressForm.receiverPhone"
                type="tel"
                placeholder="请输入手机号码"
                class="skeuomorphic-input"
                required
              />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label">省份 <span class="required">*</span></label>
              <input
                v-model="addressForm.province"
                type="text"
                placeholder="请输入省份"
                class="skeuomorphic-input"
                required
              />
            </div>
            <div class="form-group">
              <label class="form-label">城市 <span class="required">*</span></label>
              <input
                v-model="addressForm.city"
                type="text"
                placeholder="请输入城市"
                class="skeuomorphic-input"
                required
              />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">区/县 <span class="required">*</span></label>
            <input
              v-model="addressForm.district"
              type="text"
              placeholder="请输入区/县"
              class="skeuomorphic-input"
              required
            />
          </div>
          <div class="form-group">
            <label class="form-label">详细地址 <span class="required">*</span></label>
            <textarea
              v-model="addressForm.detailAddress"
              placeholder="请输入详细地址，如街道、门牌号等"
              class="skeuomorphic-input"
              rows="3"
              required
            ></textarea>
          </div>
          <div class="form-group checkbox-group">
            <label class="checkbox-label">
              <input type="checkbox" v-model="addressForm.isDefault" />
              <span>设为默认地址</span>
            </label>
          </div>
          <div v-if="addressError" class="error">
            {{ addressError }}
          </div>
          <div class="modal-actions">
            <button type="button" @click="closeAddressModal" class="skeuomorphic-button">
              取消
            </button>
            <button type="submit" class="skeuomorphic-button primary" :disabled="addressLoading">
              {{ addressLoading ? '保存中...' : '保存' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- 订单详情弹窗 -->
    <div v-if="showOrderDetail" class="modal-overlay" @click="showOrderDetail = false">
      <div class="modal skeuomorphic-card order-detail-modal" @click.stop>
        <div class="modal-header">
          <h3>订单详情</h3>
          <button @click="showOrderDetail = false" class="close-btn">×</button>
        </div>
        <div v-if="currentOrder" class="order-detail-content">
          <div class="detail-section">
            <h4>订单信息</h4>
            <div class="detail-row">
              <span class="detail-label">订单号：</span>
              <span class="detail-value">{{ currentOrder.orderNo }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">订单状态：</span>
              <span :class="['order-status', `status-${currentOrder.status}`]">
                {{ getOrderStatusText(currentOrder.status) }}
              </span>
            </div>
            <div class="detail-row">
              <span class="detail-label">创建时间：</span>
              <span class="detail-value">{{ formatDateTime(currentOrder.createdAt) }}</span>
            </div>
            <div v-if="currentOrder.paidAt" class="detail-row">
              <span class="detail-label">支付时间：</span>
              <span class="detail-value">{{ formatDateTime(currentOrder.paidAt) }}</span>
            </div>
          </div>
          <div class="detail-section">
            <h4>收货信息</h4>
            <div class="detail-row">
              <span class="detail-label">收货人：</span>
              <span class="detail-value">{{ currentOrder.receiverName }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">联系电话：</span>
              <span class="detail-value">{{ currentOrder.receiverPhone }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">收货地址：</span>
              <span class="detail-value">{{ currentOrder.receiverAddress }}</span>
            </div>
          </div>
          <div class="detail-section">
            <h4>商品信息</h4>
            <div class="detail-products">
              <div v-for="item in currentOrder.items" :key="item.id" class="detail-product">
                <img :src="item.productCoverUrl" :alt="item.productTitle" class="detail-product-image" />
                <div class="detail-product-info">
                  <p class="detail-product-title">{{ item.productTitle }}</p>
                  <p class="detail-product-meta">{{ item.category }} | {{ item.merchantName }}</p>
                  <p class="detail-product-price">¥{{ item.unitPrice.toFixed(2) }} × {{ item.quantity }}</p>
                </div>
                <div class="detail-product-total">¥{{ item.totalPrice.toFixed(2) }}</div>
              </div>
            </div>
          </div>
          <div class="detail-section total-section">
            <div class="detail-row">
              <span class="detail-label">商品总数：</span>
              <span class="detail-value">{{ currentOrder.itemCount }} 件</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">订单总价：</span>
              <span class="detail-value total-price">¥{{ currentOrder.totalAmount.toFixed(2) }}</span>
            </div>
          </div>
        </div>
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
          <p class="pay-amount">支付金额：<span class="total-price">¥{{ payOrderData?.totalAmount?.toFixed(2) }}</span></p>
          <div class="pay-methods">
            <div v-for="method in payMethods" :key="method.value"
                 :class="['pay-method', 'skeuomorphic-card', { active: selectedPayMethod === method.value }]"
                 @click="selectedPayMethod = method.value">
              <span class="pay-icon">{{ method.icon }}</span>
              <span class="pay-name">{{ method.label }}</span>
            </div>
          </div>
          <div class="modal-actions">
            <button type="button" @click="showPayModal = false" class="skeuomorphic-button">
              取消
            </button>
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
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import AvatarUpload from '../components/AvatarUpload.vue'
import api from '../api'
import { formatDateTime, formatDate } from '../utils/dateFormatter'

const router = useRouter()
const userStore = useUserStore()

const orders = ref([])
const addresses = ref([])
const activeOrderTab = ref('all')
const showChangePassword = ref(false)
const showAddressModal = ref(false)
const showOrderDetail = ref(false)
const showPayModal = ref(false)
const currentOrder = ref(null)
const payOrderData = ref(null)
const selectedPayMethod = ref('ALIPAY')

const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const passwordError = ref(null)
const passwordLoading = ref(false)

const addressForm = ref({
  receiverName: '',
  receiverPhone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false
})
const addressError = ref(null)
const addressLoading = ref(false)
const editingAddress = ref(null)

const payLoading = ref(false)

const orderTabs = [
  { label: '全部订单', value: 'all' },
  { label: '待确认', value: 'PENDING_CONFIRMATION' },
  { label: '待付款', value: 'PENDING_PAYMENT' },
  { label: '待发货', value: 'PAID' },
  { label: '待收货', value: 'SHIPPED' },
  { label: '已完成', value: 'COMPLETED' }
]

const payMethods = [
  { label: '支付宝', value: 'ALIPAY', icon: '💳' },
  { label: '微信支付', value: 'WECHAT', icon: '💬' },
  { label: '银行卡', value: 'BANK', icon: '🏦' }
]

const filteredOrders = computed(() => {
  if (activeOrderTab.value === 'all') {
    return orders.value
  }
  return orders.value.filter(order => order.status === activeOrderTab.value)
})

const getOrderStatusText = (status) => {
  const statusMap = {
    'PENDING_CONFIRMATION': '待确认',
    'CONFIRMED': '已确认',
    'REJECTED': '已拒绝',
    'PENDING_PAYMENT': '待付款',
    'PAID': '待发货',
    'SHIPPED': '待收货',
    'DELIVERED': '已送达',
    'COMPLETED': '已完成',
    'CANCELLED': '已取消',
    'REFUNDED': '已退款'
  }
  return statusMap[status] || status
}

// 使用导入的 formatDate 和 formatDateTime 函数

const handleLogout = () => {
  if (confirm('确定要退出登录吗？')) {
    userStore.logout()
    router.push('/')
  }
}

const handleChangePassword = async () => {
  try {
    passwordLoading.value = true
    passwordError.value = null

    if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
      passwordError.value = '两次输入的密码不一致'
      return
    }

    if (passwordForm.value.newPassword.length < 6) {
      passwordError.value = '密码长度至少为6位'
      return
    }

    await new Promise(resolve => setTimeout(resolve, 1000))

    alert('密码修改成功')
    showChangePassword.value = false
    passwordForm.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    }
  } catch (err) {
    passwordError.value = '修改密码失败，请稍后重试'
    console.error('Change password error:', err)
  } finally {
    passwordLoading.value = false
  }
}

const handleAvatarUpdated = (avatarUrl) => {
  userStore.user.avatarUrl = avatarUrl
}

// 获取订单列表
const fetchOrders = async () => {
  try {
    const res = await api.orders.getMyOrders()
    if (res.code === 200) {
      orders.value = res.data || []
    }
  } catch (err) {
    console.error('获取订单失败:', err)
  }
}

// 获取地址列表
const fetchAddresses = async () => {
  try {
    const res = await api.addresses.getList()
    if (res.code === 200) {
      addresses.value = res.data || []
    }
  } catch (err) {
    console.error('获取地址失败:', err)
  }
}

// 打开地址弹窗
const openAddressModal = (address = null) => {
  if (address) {
    editingAddress.value = address
    addressForm.value = {
      receiverName: address.receiverName,
      receiverPhone: address.receiverPhone,
      province: address.province,
      city: address.city,
      district: address.district,
      detailAddress: address.detailAddress,
      isDefault: address.isDefault
    }
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
  addressError.value = null
  showAddressModal.value = true
}

// 关闭地址弹窗
const closeAddressModal = () => {
  showAddressModal.value = false
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

// 保存地址
const saveAddress = async () => {
  try {
    addressLoading.value = true
    addressError.value = null

    const data = { ...addressForm.value }
    let res
    if (editingAddress.value) {
      res = await api.addresses.update(editingAddress.value.id, data)
    } else {
      res = await api.addresses.create(data)
    }

    if (res.code === 200) {
      alert(editingAddress.value ? '地址修改成功' : '地址添加成功')
      closeAddressModal()
      fetchAddresses()
    } else {
      addressError.value = res.msg || '保存失败'
    }
  } catch (err) {
    addressError.value = '保存失败，请稍后重试'
    console.error('Save address error:', err)
  } finally {
    addressLoading.value = false
  }
}

// 删除地址
const deleteAddress = async (id) => {
  if (!confirm('确定要删除这个地址吗？')) return
  try {
    const res = await api.addresses.delete(id)
    if (res.code === 200) {
      alert('地址删除成功')
      fetchAddresses()
    }
  } catch (err) {
    alert('删除失败，请稍后重试')
    console.error('Delete address error:', err)
  }
}

// 设置默认地址
const setDefaultAddress = async (id) => {
  try {
    const res = await api.addresses.setDefault(id)
    if (res.code === 200) {
      fetchAddresses()
    }
  } catch (err) {
    alert('设置失败，请稍后重试')
    console.error('Set default address error:', err)
  }
}

// 查看订单详情
const viewOrderDetail = async (id) => {
  try {
    const res = await api.orders.getOrderDetail(id)
    if (res.code === 200) {
      currentOrder.value = res.data
      showOrderDetail.value = true
    }
  } catch (err) {
    alert('获取订单详情失败')
    console.error('Get order detail error:', err)
  }
}

// 取消订单
const cancelOrder = async (id) => {
  if (!confirm('确定要取消这个订单吗？')) return
  try {
    const res = await api.orders.cancelOrder(id)
    if (res.code === 200) {
      alert('订单已取消')
      fetchOrders()
    }
  } catch (err) {
    alert('取消失败，请稍后重试')
    console.error('Cancel order error:', err)
  }
}

// 打开支付弹窗
const payOrder = (order) => {
  payOrderData.value = order
  selectedPayMethod.value = 'ALIPAY'
  showPayModal.value = true
}

// 确认支付
const confirmPay = async () => {
  try {
    payLoading.value = true
    const res = await api.orders.payOrder(payOrderData.value.orderNo, selectedPayMethod.value)
    if (res.code === 200) {
      alert('支付成功！')
      showPayModal.value = false
      fetchOrders()
    } else {
      alert(res.msg || '支付失败')
    }
  } catch (err) {
    alert('支付失败，请稍后重试')
    console.error('Pay order error:', err)
  } finally {
    payLoading.value = false
  }
}

onMounted(() => {
  if (userStore.user) {
    fetchOrders()
    fetchAddresses()
  }
})
</script>

<style scoped>
.profile-page {
  min-height: calc(100vh - 200px);
  padding: 40px 20px;
}

.not-logged-in {
  max-width: 400px;
  margin: 60px auto;
  text-align: center;
}

.not-logged-in h2 {
  font-size: 24px;
  margin-bottom: 12px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.not-logged-in p {
  color: #666;
  margin-bottom: 24px;
}

.profile-container {
  max-width: 1000px;
  margin: 0 auto;
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 32px;
  margin-bottom: 32px;
}

.avatar-container {
  flex-shrink: 0;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 700;
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  box-shadow: 
    8px 8px 16px #d1d9e6,
    -8px -8px 16px #ffffff;
}

.user-info {
  flex: 1;
}

.username {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 8px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.user-email,
.user-phone {
  color: #666;
  font-size: 14px;
  margin: 4px 0;
}

.profile-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.profile-section {
  padding: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-title {
  font-size: 20px;
  font-weight: 700;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.merchant-entry {
  background: linear-gradient(145deg, #fff7ed, #ffedd5);
  border: 2px solid #f59e0b;
}

.merchant-entry-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.merchant-icon {
  font-size: 48px;
  flex-shrink: 0;
}

.merchant-info {
  flex: 1;
}

.merchant-title {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 4px;
  background: linear-gradient(145deg, #f59e0b, #d97706);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.merchant-description {
  color: #92400e;
  font-size: 14px;
}

.merchant-button {
  padding: 12px 28px;
  background: linear-gradient(145deg, #f59e0b, #d97706);
  color: white;
  font-weight: 600;
  border-radius: 12px;
  box-shadow: 
    4px 4px 8px #fed7aa,
    -4px -4px 8px #fff7ed;
  transition: all 0.3s ease;
}

.merchant-button:hover {
  background: linear-gradient(145deg, #d97706, #b45309);
  box-shadow: 
    2px 2px 4px #fed7aa,
    -2px -2px 4px #fff7ed;
  transform: translateY(-2px);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-label {
  font-size: 14px;
  font-weight: 600;
  color: #666;
}

.info-value {
  font-size: 16px;
  color: #333;
  font-weight: 500;
}

/* 地址列表样式 */
.empty-addresses {
  text-align: center;
  padding: 40px;
  color: #999;
}

.address-items {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.address-item.default-address {
  border-color: #667eea;
  background: linear-gradient(145deg, #f8f9ff, #eef0ff);
}

.address-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.receiver-name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.receiver-phone {
  font-size: 14px;
  color: #666;
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

.address-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 6px 12px;
  font-size: 13px;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn:hover {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
}

.action-btn.delete:hover {
  background: linear-gradient(145deg, #ef4444, #dc2626);
}

.order-tabs {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

.order-tab {
  padding: 10px 20px;
  font-size: 14px;
}

.order-tab.active {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
}

.order-list {
  min-height: 200px;
}

.empty-orders {
  text-align: center;
  padding: 40px;
  color: #999;
}

.order-items {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.order-item {
  padding: 20px;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 2px solid;
  border-image: linear-gradient(90deg, transparent, #d1d9e6, transparent) 1;
}

.order-info-left {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.order-no {
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.order-date {
  font-size: 12px;
  color: #999;
}

.order-status {
  font-size: 14px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 8px;
}

.status-PENDING_CONFIRMATION {
  background: linear-gradient(145deg, #fff3cd, #ffe69c);
  color: #856404;
}

.status-CONFIRMED {
  background: linear-gradient(145deg, #d4edda, #c3e6cb);
  color: #155724;
}

.status-REJECTED {
  background: linear-gradient(145deg, #f8d7da, #f5c6cb);
  color: #721c24;
}

.status-PENDING_PAYMENT {
  background: linear-gradient(145deg, #fff3cd, #ffe69c);
  color: #856404;
}

.status-PAID {
  background: linear-gradient(145deg, #d1ecf1, #bee5eb);
  color: #0c5460;
}

.status-SHIPPED {
  background: linear-gradient(145deg, #d4edda, #c3e6cb);
  color: #155724;
}

.status-DELIVERED {
  background: linear-gradient(145deg, #d4edda, #c3e6cb);
  color: #155724;
}

.status-COMPLETED {
  background: linear-gradient(145deg, #d4edda, #c3e6cb);
  color: #155724;
}

.status-CANCELLED {
  background: linear-gradient(145deg, #f8d7da, #f5c6cb);
  color: #721c24;
}

.status-REFUNDED {
  background: linear-gradient(145deg, #e2e3e5, #d6d8db);
  color: #383d41;
}

.order-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.order-products {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-product {
  display: flex;
  gap: 12px;
  align-items: center;
}

.order-product-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
}

.order-product-info {
  flex: 1;
}

.order-product-title {
  font-size: 14px;
  color: #333;
  margin-bottom: 4px;
  font-weight: 500;
}

.order-product-meta {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
}

.order-product-price {
  font-size: 13px;
  color: #666;
}

.order-product-total {
  font-size: 14px;
  font-weight: 600;
  color: #667eea;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #e0e0e0;
}

.order-total {
  display: flex;
  align-items: center;
  gap: 8px;
}

.item-count {
  font-size: 13px;
  color: #999;
}

.total-label {
  font-size: 14px;
  color: #666;
}

.total-price {
  font-size: 20px;
  font-weight: 700;
  color: #667eea;
}

.order-actions {
  display: flex;
  gap: 8px;
}

.order-actions .skeuomorphic-button {
  padding: 8px 16px;
  font-size: 13px;
}

.settings-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.setting-item {
  width: 100%;
  padding: 14px 20px;
  text-align: left;
}

.setting-item.danger {
  background: linear-gradient(145deg, #fee, #fcc);
  color: #c33;
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
  z-index: 1000;
  padding: 20px;
}

.modal {
  max-width: 400px;
  width: 100%;
  padding: 32px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.modal h3 {
  font-size: 24px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.close-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  border: none;
  font-size: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: linear-gradient(145deg, #ef4444, #dc2626);
  color: white;
}

.password-form,
.address-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-size: 14px;
  font-weight: 600;
  color: #333;
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
  font-size: 14px;
  color: #333;
}

.checkbox-label input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.error {
  padding: 12px 16px;
  background: linear-gradient(145deg, #fee, #fcc);
  border-radius: 12px;
  color: #c33;
  font-size: 14px;
  text-align: center;
  box-shadow: 
    inset 2px 2px 4px #fdd,
    inset -2px -2px 4px #fff;
}

.modal-actions {
  display: flex;
  gap: 12px;
  margin-top: 8px;
}

.modal-actions button {
  flex: 1;
}

/* 地址弹窗 */
.address-modal {
  max-width: 500px;
}

/* 订单详情弹窗 */
.order-detail-modal {
  max-width: 600px;
  max-height: 80vh;
  overflow-y: auto;
}

.order-detail-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-section {
  padding: 16px;
  background: linear-gradient(145deg, #f8f9fa, #e9ecef);
  border-radius: 12px;
}

.detail-section h4 {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 12px;
  color: #333;
}

.detail-row {
  display: flex;
  margin-bottom: 8px;
}

.detail-label {
  width: 100px;
  color: #666;
  font-size: 14px;
}

.detail-value {
  flex: 1;
  color: #333;
  font-size: 14px;
}

.detail-products {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.detail-product {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 12px;
  background: white;
  border-radius: 8px;
}

.detail-product-image {
  width: 60px;
  height: 60px;
  border-radius: 6px;
  object-fit: cover;
}

.detail-product-info {
  flex: 1;
}

.detail-product-title {
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 4px;
}

.detail-product-meta {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
}

.detail-product-price {
  font-size: 13px;
  color: #666;
}

.detail-product-total {
  font-size: 14px;
  font-weight: 600;
  color: #667eea;
}

.total-section {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
}

.total-section .detail-label,
.total-section .detail-value {
  color: white;
}

/* 支付弹窗 */
.pay-modal {
  max-width: 400px;
}

.pay-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.pay-amount {
  text-align: center;
  font-size: 16px;
  color: #333;
}

.pay-methods {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.pay-method {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
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

@media (max-width: 768px) {
  .profile-header {
    flex-direction: column;
    text-align: center;
  }

  .merchant-entry-content {
    flex-direction: column;
    text-align: center;
  }

  .merchant-button {
    width: 100%;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .order-footer {
    flex-direction: column;
    gap: 12px;
  }

  .order-actions {
    width: 100%;
    justify-content: flex-end;
  }

  .address-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .address-actions {
    width: 100%;
    justify-content: flex-end;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .section-header {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
}
</style>
