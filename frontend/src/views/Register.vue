<template>
  <div class="register-page">
    <div class="register-container skeuomorphic-container">
      <div class="register-header">
        <h1 class="register-title">用户注册</h1>
        <p class="register-subtitle">加入健康商城，开启健康生活</p>
      </div>

      <form @submit.prevent="handleRegister" class="register-form">
        <div class="form-group">
          <label class="form-label">用户名</label>
          <input
            type="text"
            v-model="formData.username"
            placeholder="请输入用户名"
            class="skeuomorphic-input"
            required
            minlength="3"
          />
        </div>

        <div class="form-group">
          <label class="form-label">密码</label>
          <input
            type="password"
            v-model="formData.password"
            placeholder="请输入密码（至少6位）"
            class="skeuomorphic-input"
            required
            minlength="6"
          />
        </div>

        <div class="form-group">
          <label class="form-label">确认密码</label>
          <input
            type="password"
            v-model="formData.confirmPassword"
            placeholder="请再次输入密码"
            class="skeuomorphic-input"
            required
          />
        </div>

        <div class="form-group">
          <label class="form-label">邮箱</label>
          <input
            type="email"
            v-model="formData.email"
            placeholder="请输入邮箱地址"
            class="skeuomorphic-input"
            required
          />
        </div>

        <div class="form-group">
          <label class="form-label">手机号</label>
          <input
            type="tel"
            v-model="formData.phone"
            placeholder="请输入手机号码"
            class="skeuomorphic-input"
            required
            pattern="[0-9]{11}"
          />
        </div>

        <div class="form-group">
          <label class="form-label">身份类型</label>
          <div class="role-selector">
            <label class="role-option">
              <input
                type="radio"
                v-model="formData.role"
                value="USER"
                class="role-radio"
              />
              <span class="role-label skeuomorphic-button">
                <span class="role-icon">👤</span>
                <span class="role-text">普通用户</span>
              </span>
            </label>
            <label class="role-option">
              <input
                type="radio"
                v-model="formData.role"
                value="MERCHANT"
                class="role-radio"
              />
              <span class="role-label skeuomorphic-button">
                <span class="role-icon">🏪</span>
                <span class="role-text">商家</span>
              </span>
            </label>
          </div>
        </div>

        <div v-if="error" class="error">
          {{ error }}
        </div>

        <div v-if="success" class="success">
          {{ success }}
        </div>

        <button
          type="submit"
          class="skeuomorphic-button primary register-button"
          :disabled="loading"
        >
          {{ loading ? '注册中...' : '注册' }}
        </button>
      </form>

      <div class="register-footer">
        <p>已有账号？</p>
        <router-link to="/login" class="login-link">
          立即登录
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'

const router = useRouter()

const formData = ref({
  username: '',
  password: '',
  confirmPassword: '',
  email: '',
  phone: '',
  role: 'USER'
})

const loading = ref(false)
const error = ref(null)
const success = ref(null)

const handleRegister = async () => {
  try {
    loading.value = true
    error.value = null
    success.value = null

    if (formData.value.password !== formData.value.confirmPassword) {
      error.value = '两次输入的密码不一致'
      loading.value = false
      return
    }

    if (formData.value.password.length < 6) {
      error.value = '密码长度至少为6位'
      loading.value = false
      return
    }

    const registerData = {
      username: formData.value.username,
      password: formData.value.password,
      email: formData.value.email,
      phone: formData.value.phone,
      role: formData.value.role
    }

    const response = await api.auth.register(registerData)

    if (response.code === 200) {
      success.value = '注册成功！正在跳转到登录页面...'
      setTimeout(() => {
        router.push('/login')
      }, 2000)
    } else {
      error.value = response.msg || '注册失败，请稍后重试'
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
    console.error('Register error:', err)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-page {
  min-height: calc(100vh - 200px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
}

.register-container {
  max-width: 450px;
  width: 100%;
  padding: 40px;
}

.register-header {
  text-align: center;
  margin-bottom: 32px;
}

.register-title {
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 8px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.register-subtitle {
  color: #666;
  font-size: 14px;
}

.register-form {
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

.register-button {
  width: 100%;
  padding: 16px;
  font-size: 16px;
  margin-top: 8px;
}

.register-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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

.success {
  padding: 12px 16px;
  background: linear-gradient(145deg, #efe, #cfc);
  border-radius: 12px;
  color: #3c3;
  font-size: 14px;
  text-align: center;
  box-shadow: 
    inset 2px 2px 4px #dfd,
    inset -2px -2px 4px #fff;
}

.register-footer {
  text-align: center;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 2px solid;
  border-image: linear-gradient(90deg, transparent, #d1d9e6, transparent) 1;
}

.register-footer p {
  color: #666;
  font-size: 14px;
  margin-bottom: 8px;
}

.login-link {
  color: #667eea;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s ease;
}

.login-link:hover {
  color: #764ba2;
  text-decoration: underline;
}

.role-selector {
  display: flex;
  gap: 16px;
}

.role-option {
  flex: 1;
  cursor: pointer;
}

.role-radio {
  display: none;
}

.role-label {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 20px;
  transition: all 0.3s ease;
  cursor: pointer;
  background: linear-gradient(145deg, #ffffff, #e6e6e6);
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.5);
}

.role-label:hover {
  background: linear-gradient(145deg, #f0f0f0, #e0e0e0);
  transform: translateY(-2px);
  box-shadow: 
    7px 7px 14px #d1d9e6,
    -7px -7px 14px #ffffff;
}

.role-radio:checked + .role-label {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  box-shadow: 
    8px 8px 16px rgba(102, 126, 234, 0.3),
    -8px -8px 16px rgba(118, 75, 162, 0.3);
  transform: translateY(-2px);
  border-color: rgba(255, 255, 255, 0.3);
}

.role-radio:checked + .role-label:hover {
  background: linear-gradient(145deg, #764ba2, #667eea);
  box-shadow: 
    10px 10px 20px rgba(102, 126, 234, 0.4),
    -10px -10px 20px rgba(118, 75, 162, 0.4);
}

.role-icon {
  font-size: 32px;
}

.role-text {
  font-size: 14px;
  font-weight: 600;
}

@media (max-width: 768px) {
  .role-selector {
    flex-direction: column;
  }

  .role-label {
    flex-direction: row;
    justify-content: center;
    padding: 16px;
  }

  .role-icon {
    font-size: 24px;
  }
}
</style>
