<template>
  <div class="merchant-orders-page">
    <div class="merchant-nav">
      <div class="nav-container">
        <router-link to="/merchant" class="nav-item">
          📦 商品管理
        </router-link>
        <router-link to="/merchant/orders" class="nav-item">
          📋 订单管理
        </router-link>
        <router-link to="/merchant/logistics" class="nav-item">
          🚚 物流管理
        </router-link>
        <router-link to="/merchant/tags" class="nav-item">
          🏷️ 标签管理
        </router-link>
        <router-link to="/" class="nav-item back-home">
          🏠 返回首页
        </router-link>
      </div>
    </div>

    <div class="page-header skeuomorphic-card">
      <div class="header-top">
        <h1>订单管理</h1>
      </div>
      <div class="tabs">
        <button 
          class="tab-item" 
          :class="{ active: activeTab === 'pending' }"
          @click="activeTab = 'pending'"
        >
          待确认订单
        </button>
        <button 
          class="tab-item" 
          :class="{ active: activeTab === 'all' }"
          @click="activeTab = 'all'"
        >
          全部订单
        </button>
      </div>
      
      <div v-if="activeTab === 'all'" class="status-filter">
        <select v-model="selectedStatus" @change="fetchOrders" class="skeuomorphic-select">
          <option value="">全部状态</option>
          <option value="PENDING_CONFIRMATION">待确认</option>
          <option value="CONFIRMED">已确认</option>
          <option value="SHIPPED">已发货</option>
          <option value="COMPLETED">已完成</option>
          <option value="CANCELLED">已取消</option>
          <option value="REJECTED">已拒绝</option>
        </select>
      </div>
    </div>

    <div class="orders-container">
      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>
      
      <div v-if="successMessage" class="alert alert-success">
        {{ successMessage }}
      </div>
      
      <div v-if="loading" class="loading">加载中...</div>
      
      <div v-else-if="orders.length === 0" class="empty">
        <p>暂无订单</p>
      </div>

      <div v-else class="orders-list">
        <div v-for="order in orders" :key="order.id" class="order-card skeuomorphic-card">
          <div class="order-header">
            <div class="order-info">
              <span class="order-no">订单号: {{ order.orderNo }}</span>
              <span class="order-time">{{ formatDate(order.createdAt) }}</span>
            </div>
            <div class="order-status" :class="getStatusClass(order.status)">
              {{ getStatusText(order.status) }}
            </div>
          </div>

          <div class="order-items">
            <div v-for="item in order.items" :key="item.id" class="order-item">
              <img :src="item.productCoverUrl" :alt="item.productTitle" class="item-image" />
              <div class="item-details">
                <div class="item-title">{{ item.productTitle }}</div>
                <div class="item-meta">
                  <span class="item-category">{{ item.category }}</span>
                  <span class="item-merchant">{{ item.merchantName }}</span>
                </div>
              </div>
              <div class="item-quantity">x{{ item.quantity }}</div>
              <div class="item-price">¥{{ item.unitPrice?.toFixed(2) }}</div>
            </div>
          </div>

          <div class="order-receiver">
            <div class="receiver-info">
              <span class="receiver-label">收货人:</span>
              <span class="receiver-value">{{ order.receiverName }}</span>
              <span class="receiver-phone">{{ order.receiverPhone }}</span>
            </div>
            <div class="receiver-address">
              <span class="address-label">收货地址:</span>
              <span class="address-value">{{ order.receiverAddress }}</span>
            </div>
          </div>

          <div class="order-footer">
            <div class="order-amount">
              <span>订单金额:</span>
              <span class="amount">¥{{ order.totalAmount?.toFixed(2) }}</span>
            </div>
            
            <div v-if="order.rejectReason" class="reject-reason">
              <span>拒绝原因: {{ order.rejectReason }}</span>
            </div>

            <div class="order-actions">
              <button 
                v-if="order.status === 'PENDING_CONFIRMATION'" 
                class="btn-confirm"
                @click="confirmOrder(order.id)"
                :disabled="processing"
              >
                确认订单
              </button>
              <button 
                v-if="order.status === 'PENDING_CONFIRMATION'" 
                class="btn-reject"
                @click="showRejectDialog(order)"
                :disabled="processing"
              >
                拒绝订单
              </button>
              <button 
                v-if="['CONFIRMED', 'SHIPPED', 'DELIVERED', 'COMPLETED'].includes(order.status)" 
                class="btn-logistics"
                @click="goToLogistics(order.orderNo)"
              >
                🚚 查询物流
              </button>
              <span v-if="order.autoConfirmed" class="auto-confirmed-tag">自动确认</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showRejectModal" class="modal-overlay" @click="showRejectModal = false">
      <div class="modal-content skeuomorphic-card" @click.stop>
        <div class="modal-header">
          <h3>拒绝订单</h3>
          <button class="close-btn" @click="showRejectModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>拒绝原因</label>
            <textarea 
              v-model="rejectReason" 
              placeholder="请输入拒绝原因..."
              rows="4"
              maxlength="255"
            ></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-cancel" @click="showRejectModal = false">取消</button>
          <button 
            class="btn-submit" 
            @click="submitReject"
            :disabled="!rejectReason || processing"
          >
            确认拒绝
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'

const router = useRouter()
const activeTab = ref('pending')
const selectedStatus = ref('')
const orders = ref([])
const loading = ref(false)
const processing = ref(false)
const showRejectModal = ref(false)
const rejectReason = ref('')
const currentOrder = ref(null)
const errorMessage = ref('')
const successMessage = ref('')

const fetchOrders = async () => {
  loading.value = true
  errorMessage.value = ''
  try {
    let response
    if (activeTab.value === 'pending') {
      response = await api.merchant.getPendingOrders()
    } else {
      const params = selectedStatus.value ? { status: selectedStatus.value } : {}
      response = await api.merchant.getOrders(params)
    }
    
    if (response.code === 200) {
      orders.value = response.data || []
    } else {
      errorMessage.value = '获取订单列表失败: ' + response.msg
      setTimeout(() => errorMessage.value = '', 5000)
    }
  } catch (error) {
    console.error('获取订单列表失败:', error)
    if (error.response?.status === 401) {
      errorMessage.value = '登录已过期,请重新登录'
      setTimeout(() => {
        window.location.href = '/login'
      }, 2000)
    } else if (error.response?.status === 403) {
      errorMessage.value = '无权访问此资源'
    } else {
      errorMessage.value = '获取订单列表失败,请稍后重试'
    }
    setTimeout(() => errorMessage.value = '', 5000)
  } finally {
    loading.value = false
  }
}

const confirmOrder = async (orderId) => {
  if (!confirm('确认接受此订单？')) {
    return
  }

  processing.value = true
  errorMessage.value = ''
  try {
    const response = await api.merchant.confirmOrder(orderId)
    if (response.code === 200) {
      successMessage.value = '订单已确认'
      setTimeout(() => successMessage.value = '', 3000)
      fetchOrders()
    } else {
      errorMessage.value = '确认订单失败: ' + response.msg
      setTimeout(() => errorMessage.value = '', 5000)
    }
  } catch (error) {
    console.error('确认订单失败:', error)
    if (error.response?.status === 404) {
      errorMessage.value = '订单不存在'
    } else if (error.response?.status === 400) {
      errorMessage.value = '参数错误: ' + (error.response?.data?.msg || '订单ID格式错误')
    } else {
      errorMessage.value = '确认订单失败,请稍后重试'
    }
    setTimeout(() => errorMessage.value = '', 5000)
  } finally {
    processing.value = false
  }
}

const showRejectDialog = (order) => {
  currentOrder.value = order
  rejectReason.value = ''
  showRejectModal.value = true
}

const submitReject = async () => {
  if (!currentOrder.value || !rejectReason.value) {
    errorMessage.value = '请输入拒绝原因'
    setTimeout(() => errorMessage.value = '', 3000)
    return
  }

  processing.value = true
  errorMessage.value = ''
  try {
    const response = await api.merchant.rejectOrder(currentOrder.value.id, rejectReason.value)
    if (response.code === 200) {
      successMessage.value = '订单已拒绝'
      setTimeout(() => successMessage.value = '', 3000)
      showRejectModal.value = false
      fetchOrders()
    } else {
      errorMessage.value = '拒绝订单失败: ' + response.msg
      setTimeout(() => errorMessage.value = '', 5000)
    }
  } catch (error) {
    console.error('拒绝订单失败:', error)
    if (error.response?.status === 404) {
      errorMessage.value = '订单不存在'
    } else if (error.response?.status === 400) {
      errorMessage.value = error.response?.data?.msg || '拒绝原因不能为空'
    } else {
      errorMessage.value = '拒绝订单失败,请稍后重试'
    }
    setTimeout(() => errorMessage.value = '', 5000)
  } finally {
    processing.value = false
  }
}

const getStatusText = (status) => {
  const statusMap = {
    'PENDING_CONFIRMATION': '待确认',
    'CONFIRMED': '已确认',
    'REJECTED': '已拒绝',
    'PENDING_PAYMENT': '待支付',
    'PAID': '已支付',
    'SHIPPED': '已发货',
    'DELIVERED': '已送达',
    'COMPLETED': '已完成',
    'CANCELLED': '已取消',
    'REFUNDED': '已退款'
  }
  return statusMap[status] || status
}

const getStatusClass = (status) => {
  const classMap = {
    'PENDING_CONFIRMATION': 'status-pending',
    'CONFIRMED': 'status-confirmed',
    'REJECTED': 'status-rejected',
    'PENDING_PAYMENT': 'status-pending',
    'PAID': 'status-paid',
    'SHIPPED': 'status-shipped',
    'DELIVERED': 'status-delivered',
    'COMPLETED': 'status-completed',
    'CANCELLED': 'status-cancelled',
    'REFUNDED': 'status-refunded'
  }
  return classMap[status] || ''
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const goToLogistics = (orderNo) => {
  router.push({
    path: '/merchant/logistics',
    query: { orderNo }
  })
}

watch(activeTab, () => {
  fetchOrders()
})

onMounted(() => {
  fetchOrders()
})
</script>

<style scoped>
.merchant-orders-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  background: linear-gradient(135deg, #e0e5ec 0%, #c8d0e0 100%);
  min-height: 100vh;
}

.merchant-nav {
  margin-bottom: 20px;
  padding: 16px;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.nav-container {
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: center;
}

.nav-item {
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 600;
  color: #666;
  transition: all 0.3s ease;
  text-decoration: none;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
  display: flex;
  align-items: center;
  gap: 8px;
}

.nav-item:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}

.nav-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 
    3px 3px 6px #a8b5d1,
    -3px -3px 6px #ffffff;
}

.nav-item.back-home {
  background: linear-gradient(145deg, #f59e0b, #d97706);
  color: white;
}

.nav-item.back-home:hover {
  background: linear-gradient(145deg, #d97706, #b45309);
}

.page-header {
  padding: 20px 30px;
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0 0 20px 0;
  font-size: 28px;
  color: #333;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.skeuomorphic-button {
  padding: 12px 24px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  border-radius: 10px;
  cursor: pointer;
  font-size: 16px;
  color: #666;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.1),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.skeuomorphic-button:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(0,0,0,0.15),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.tabs {
  display: flex;
  gap: 10px;
}

.tab-item {
  padding: 12px 24px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  border-radius: 10px;
  cursor: pointer;
  font-size: 16px;
  color: #666;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.1),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.tab-item:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(0,0,0,0.15),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.tab-item.active {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
  font-weight: 600;
}

.status-filter {
  margin-top: 15px;
}

.skeuomorphic-select {
  padding: 10px 16px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  border-radius: 10px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.1),
    -3px -3px 6px rgba(255,255,255,0.8);
  min-width: 150px;
}

.skeuomorphic-select:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(0,0,0,0.15),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.skeuomorphic-select:focus {
  outline: none;
  border-color: #ff6b6b;
}

.alert {
  padding: 15px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
  font-size: 14px;
  font-weight: 600;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.alert-error {
  background: linear-gradient(145deg, #fee2e2, #fecaca);
  color: #dc2626;
  border-left: 4px solid #dc2626;
}

.alert-success {
  background: linear-gradient(145deg, #d1fae5, #a7f3d0);
  color: #059669;
  border-left: 4px solid #059669;
}

.orders-container {
  min-height: 400px;
}

.loading,
.empty {
  text-align: center;
  padding: 60px 20px;
  color: #999;
  font-size: 16px;
}

.orders-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.order-card {
  padding: 25px;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 20px;
  border-bottom: 2px solid #e0e0e0;
  margin-bottom: 20px;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.order-no {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.order-time {
  font-size: 14px;
  color: #999;
}

.order-status {
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
}

.status-pending {
  background: linear-gradient(135deg, #ffd93d 0%, #ffec8b 100%);
  color: #8b5a00;
}

.status-confirmed {
  background: linear-gradient(135deg, #4cd964 0%, #8effac 100%);
  color: #006400;
}

.status-rejected {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
}

.status-paid {
  background: linear-gradient(135deg, #5c6bc0 0%, #8e9eff 100%);
  color: white;
}

.status-shipped {
  background: linear-gradient(135deg, #9b59b6 0%, #be90d4 100%);
  color: white;
}

.order-items {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-bottom: 20px;
}

.order-receiver {
  padding: 15px;
  background: linear-gradient(145deg, #f8fafc, #e2e8f0);
  border-radius: 12px;
  margin-bottom: 20px;
}

.receiver-info {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.receiver-label {
  font-weight: 600;
  color: #666;
}

.receiver-value {
  font-weight: 600;
  color: #333;
}

.receiver-phone {
  color: #666;
  font-size: 14px;
}

.receiver-address {
  display: flex;
  gap: 10px;
}

.address-label {
  font-weight: 600;
  color: #666;
}

.address-value {
  color: #666;
  flex: 1;
}

.order-item {
  display: grid;
  grid-template-columns: 80px 1fr auto auto;
  gap: 15px;
  align-items: center;
  padding: 15px;
  background: linear-gradient(145deg, #fafafa, #e6e6e6);
  border-radius: 12px;
}

.item-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  box-shadow: 
    2px 2px 4px rgba(0,0,0,0.1),
    -2px -2px 4px rgba(255,255,255,0.8);
}

.item-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.item-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.item-meta {
  display: flex;
  gap: 10px;
  font-size: 14px;
  color: #999;
}

.item-quantity {
  font-size: 16px;
  color: #666;
}

.item-price {
  font-size: 18px;
  font-weight: 700;
  color: #ff6b6b;
}

.order-footer {
  display: flex;
  flex-direction: column;
  gap: 15px;
  padding-top: 20px;
  border-top: 2px solid #e0e0e0;
}

.order-amount {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
}

.order-amount span:first-child {
  color: #666;
}

.amount {
  font-size: 24px;
  font-weight: 700;
  color: #ff6b6b;
}

.reject-reason {
  padding: 12px;
  background: linear-gradient(145deg, #fff5f5, #ffe0e0);
  border-radius: 8px;
  color: #ff6b6b;
  font-size: 14px;
}

.order-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.btn-confirm {
  flex: 1;
  padding: 12px 24px;
  border: none;
  background: linear-gradient(135deg, #4cd964 0%, #8effac 100%);
  color: #006400;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(76, 217, 100, 0.3),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.btn-confirm:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(76, 217, 100, 0.4),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.btn-confirm:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-reject {
  flex: 1;
  padding: 12px 24px;
  border: none;
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(255, 107, 107, 0.3),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.btn-reject:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(255, 107, 107, 0.4),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.btn-reject:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-logistics {
  padding: 12px 24px;
  border: none;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(79, 172, 254, 0.3),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.btn-logistics:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(79, 172, 254, 0.4),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.auto-confirmed-tag {
  padding: 6px 12px;
  background: linear-gradient(135deg, #ffd93d 0%, #ffec8b 100%);
  color: #8b5a00;
  border-radius: 15px;
  font-size: 12px;
  font-weight: 600;
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
}

.modal-content {
  width: 500px;
  max-width: 90%;
  padding: 30px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.modal-header h3 {
  margin: 0;
  font-size: 22px;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 28px;
  cursor: pointer;
  color: #999;
  transition: color 0.3s;
}

.close-btn:hover {
  color: #333;
}

.modal-body {
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 10px;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.form-group textarea {
  width: 100%;
  padding: 12px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 16px;
  font-family: inherit;
  resize: vertical;
  box-shadow: 
    inset 3px 3px 6px rgba(0,0,0,0.05),
    inset -3px -3px 6px rgba(255,255,255,0.8);
}

.form-group textarea:focus {
  outline: none;
  border-color: #ff6b6b;
}

.modal-footer {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn-cancel {
  padding: 12px 24px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  color: #666;
  border-radius: 10px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel:hover {
  transform: translateY(-2px);
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.1),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.btn-submit {
  padding: 12px 24px;
  border: none;
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    3px 3px 6px rgba(255, 107, 107, 0.3),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
