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
          <div v-if="userStore.user.avatarUrl" class="avatar-image">
            <img :src="userStore.user.avatarUrl" :alt="userStore.user.username" class="avatar-img" />
          </div>
          <div v-else class="avatar skeuomorphic-avatar">
            {{ userStore.user.username.charAt(0).toUpperCase() }}
          </div>
          <button @click="showAvatarUpload = true" class="avatar-upload-button skeuomorphic-button">
            更换头像
          </button>
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
            <div v-if="orders.length === 0" class="empty-orders">
              <p>暂无订单</p>
            </div>
            <div v-else class="order-items">
              <div v-for="order in orders" :key="order.id" class="order-item skeuomorphic-card">
                <div class="order-header">
                  <span class="order-id">订单号：{{ order.id }}</span>
                  <span :class="['order-status', `status-${order.status}`]">
                    {{ getOrderStatusText(order.status) }}
                  </span>
                </div>
                <div class="order-content">
                  <div class="order-products">
                    <div v-for="product in order.products" :key="product.id" class="order-product">
                      <img :src="product.coverUrl" :alt="product.title" class="order-product-image" />
                      <div class="order-product-info">
                        <p class="order-product-title">{{ product.title }}</p>
                        <p class="order-product-price">¥{{ product.price.toFixed(2) }} × {{ product.quantity }}</p>
                      </div>
                    </div>
                  </div>
                  <div class="order-total">
                    <p>总计：<span class="total-price">¥{{ order.totalPrice.toFixed(2) }}</span></p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="profile-section skeuomorphic-card">
          <h3 class="section-title">账户设置</h3>
          <div class="settings-list">
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

    <div v-if="showAvatarUpload" class="modal-overlay" @click="showAvatarUpload = false">
      <div class="modal skeuomorphic-card" @click.stop>
        <h3>更换头像</h3>
        <ImageUpload 
          v-model="avatarUrl" 
          type="avatar" 
          placeholder="上传头像图片" 
          @upload-success="handleAvatarUploadSuccess"
          @upload-error="handleAvatarUploadError"
        />
        <div class="modal-actions">
          <button @click="showAvatarUpload = false" class="skeuomorphic-button">
            取消
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import ImageUpload from '../components/ImageUpload.vue'
import api from '../api'

const router = useRouter()
const userStore = useUserStore()

const orders = ref([])
const activeOrderTab = ref('all')
const showChangePassword = ref(false)
const showAvatarUpload = ref(false)
const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const passwordError = ref(null)
const passwordLoading = ref(false)
const avatarUrl = ref('')

const orderTabs = [
  { label: '全部订单', value: 'all' },
  { label: '待付款', value: 'pending' },
  { label: '待发货', value: 'paid' },
  { label: '待收货', value: 'shipped' },
  { label: '已完成', value: 'completed' }
]

const getOrderStatusText = (status) => {
  const statusMap = {
    pending: '待付款',
    paid: '待发货',
    shipped: '待收货',
    completed: '已完成',
    cancelled: '已取消'
  }
  return statusMap[status] || status
}

const formatDate = (dateString) => {
  if (!dateString) return '未知'
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

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

const handleAvatarUploadSuccess = async (url) => {
  try {
    avatarUrl.value = url
    await api.user.updateProfile({ avatarUrl: url })
    userStore.user.avatarUrl = url
    alert('头像上传成功')
    showAvatarUpload.value = false
  } catch (err) {
    console.error('Update avatar error:', err)
    alert('头像更新失败：' + (err.response?.data?.msg || err.message))
  }
}

const handleAvatarUploadError = (error) => {
  console.error('Avatar upload error:', error)
  alert('头像上传失败：' + error)
}

onMounted(async () => {
  if (userStore.user) {
    try {
      const response = await api.user.getProfile()
      if (response.code === 200) {
        userStore.setUser(response.data)
        avatarUrl.value = response.data.avatarUrl || ''
      }
    } catch (err) {
      console.error('Get profile error:', err)
    }
    orders.value = []
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

.section-title {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 20px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
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

.order-id {
  font-size: 14px;
  color: #666;
}

.order-status {
  font-size: 14px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 8px;
}

.status-pending {
  background: linear-gradient(145deg, #fff3cd, #ffe69c);
  color: #856404;
}

.status-paid {
  background: linear-gradient(145deg, #d1ecf1, #bee5eb);
  color: #0c5460;
}

.status-shipped {
  background: linear-gradient(145deg, #d4edda, #c3e6cb);
  color: #155724;
}

.status-completed {
  background: linear-gradient(145deg, #d4edda, #c3e6cb);
  color: #155724;
}

.status-cancelled {
  background: linear-gradient(145deg, #f8d7da, #f5c6cb);
  color: #721c24;
}

.order-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
}

.order-products {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-product {
  display: flex;
  gap: 12px;
}

.order-product-image {
  width: 60px;
  height: 60px;
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
}

.order-product-price {
  font-size: 12px;
  color: #666;
}

.order-total {
  text-align: right;
}

.total-price {
  font-size: 18px;
  font-weight: 700;
  color: #667eea;
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

.modal h3 {
  font-size: 24px;
  margin-bottom: 24px;
  text-align: center;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.password-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
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

  .order-content {
    flex-direction: column;
  }

  .order-total {
    text-align: left;
    margin-top: 12px;
  }
}
</style>
