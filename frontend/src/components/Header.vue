<template>
  <header class="header">
    <div class="header-content">
      <div class="logo">
        <router-link to="/" class="logo-link">
          <div class="logo-icon">💊</div>
          <span class="logo-text">健康商城</span>
        </router-link>
      </div>

      <nav class="nav">
        <router-link to="/" class="nav-link">首页</router-link>
        <router-link to="/products" class="nav-link">商品列表</router-link>
        <router-link v-if="userStore.isMerchant()" to="/merchant" class="nav-link merchant-link">
          🏪 商家后台
        </router-link>
      </nav>

      <div class="header-actions">
        <div class="search-box">
          <input
            type="text"
            v-model="searchQuery"
            placeholder="搜索商品..."
            class="skeuomorphic-input search-input"
            @keyup.enter="handleSearch"
          />
          <button @click="handleSearch" class="search-button">🔍</button>
        </div>

        <div v-if="userStore.isLoggedIn" class="user-menu">
          <router-link to="/profile" class="user-link">
            <div class="skeuomorphic-avatar user-avatar">
              {{ userStore.user?.username?.charAt(0).toUpperCase() || 'U' }}
            </div>
          </router-link>
          <button @click="handleLogout" class="skeuomorphic-button logout-button">
            退出
          </button>
        </div>
        <div v-else class="auth-buttons">
          <router-link to="/login" class="skeuomorphic-button">登录</router-link>
          <router-link to="/register" class="skeuomorphic-button primary">注册</router-link>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()
const searchQuery = ref('')

const handleSearch = () => {
  if (searchQuery.value.trim()) {
    router.push({ name: 'Search', query: { q: searchQuery.value } })
  }
}

const handleLogout = () => {
  userStore.logout()
  router.push('/')
}
</script>

<style scoped>
.header {
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    0 4px 12px rgba(0, 0, 0, 0.1),
    0 2px 4px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid rgba(255, 255, 255, 0.5);
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 32px;
}

.logo-link {
  display: flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
}

.logo-icon {
  font-size: 32px;
  background: linear-gradient(145deg, #667eea, #764ba2);
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 
    4px 4px 8px #d1d9e6,
    -4px -4px 8px #ffffff;
}

.logo-text {
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.nav {
  display: flex;
  gap: 8px;
}

.nav-link {
  padding: 10px 20px;
  border-radius: 12px;
  font-weight: 500;
  color: #666;
  transition: all 0.3s ease;
  text-decoration: none;
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
}

.nav-link:hover,
.nav-link.router-link-active {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  box-shadow: 
    5px 5px 10px #a8b5d1,
    -5px -5px 10px #ffffff;
  transform: translateY(-2px);
}

.nav-link.merchant-link {
  background: linear-gradient(145deg, #f59e0b, #d97706);
  color: white;
}

.nav-link.merchant-link:hover,
.nav-link.merchant-link.router-link-active {
  background: linear-gradient(145deg, #d97706, #b45309);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  flex: 1;
  justify-content: flex-end;
}

.search-box {
  display: flex;
  gap: 8px;
  align-items: center;
  flex: 1;
  max-width: 400px;
}

.search-input {
  flex: 1;
  padding: 10px 16px;
}

.search-button {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  box-shadow: 
    4px 4px 8px #d1d9e6,
    -4px -4px 8px #ffffff;
  transition: all 0.3s ease;
}

.search-button:hover {
  transform: translateY(-2px);
  box-shadow: 
    6px 6px 12px #d1d9e6,
    -6px -6px 12px #ffffff;
}

.user-menu {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-link {
  text-decoration: none;
}

.user-avatar {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 700;
  color: #667eea;
  cursor: pointer;
  transition: all 0.3s ease;
}

.user-avatar:hover {
  transform: scale(1.1);
}

.logout-button {
  padding: 8px 16px;
  font-size: 14px;
}

.auth-buttons {
  display: flex;
  gap: 8px;
}

.auth-buttons .skeuomorphic-button {
  padding: 10px 20px;
  font-size: 14px;
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    gap: 16px;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
  }

  .search-box {
    width: 100%;
    max-width: none;
  }

  .nav {
    width: 100%;
    justify-content: center;
  }
}
</style>
