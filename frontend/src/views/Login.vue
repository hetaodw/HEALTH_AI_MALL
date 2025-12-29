<template>
  <div class="login-page">
    <div class="login-container skeuomorphic-container">
      <div class="login-header">
        <h1 class="login-title">用户登录</h1>
        <p class="login-subtitle">欢迎回到健康商城</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label class="form-label">用户名</label>
          <input
            type="text"
            v-model="formData.username"
            placeholder="请输入用户名"
            class="skeuomorphic-input"
            required
          />
        </div>

        <div class="form-group">
          <label class="form-label">密码</label>
          <input
            type="password"
            v-model="formData.password"
            placeholder="请输入密码"
            class="skeuomorphic-input"
            required
          />
        </div>

        <div v-if="error" class="error">
          {{ error }}
        </div>

        <button
          type="submit"
          class="skeuomorphic-button primary login-button"
          :disabled="loading"
        >
          {{ loading ? '登录中...' : '登录' }}
        </button>
      </form>

      <div class="login-footer">
        <p>还没有账号？</p>
        <router-link to="/register" class="register-link">
          立即注册
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import api from '../api'

const router = useRouter()
const userStore = useUserStore()

const formData = ref({
  username: '',
  password: ''
})

const loading = ref(false)
const error = ref(null)

const handleLogin = async () => {
  try {
    loading.value = true
    error.value = null

    const response = await api.auth.login(formData.value)

    if (response.code === 200) {
      userStore.setToken(response.data.token)
      userStore.setUser(response.data.userInfo)
      router.push('/')
    } else {
      error.value = response.msg || '登录失败，请检查用户名和密码'
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
    console.error('Login error:', err)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: calc(100vh - 200px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
}

.login-container {
  max-width: 400px;
  width: 100%;
  padding: 40px;
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.login-title {
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 8px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.login-subtitle {
  color: #666;
  font-size: 14px;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
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

.login-button {
  width: 100%;
  padding: 16px;
  font-size: 16px;
  margin-top: 8px;
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.login-footer {
  text-align: center;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 2px solid;
  border-image: linear-gradient(90deg, transparent, #d1d9e6, transparent) 1;
}

.login-footer p {
  color: #666;
  font-size: 14px;
  margin-bottom: 8px;
}

.register-link {
  color: #667eea;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s ease;
}

.register-link:hover {
  color: #764ba2;
  text-decoration: underline;
}
</style>
