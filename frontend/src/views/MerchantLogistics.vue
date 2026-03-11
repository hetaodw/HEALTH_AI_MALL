<template>
  <div class="merchant-logistics-page">
    <div class="merchant-nav">
      <div class="nav-container">
        <router-link to="/merchant" class="nav-item">
          📦 商品管理
        </router-link>
        <router-link to="/merchant/orders" class="nav-item">
          📋 订单管理
        </router-link>
        <router-link to="/merchant/logistics" class="nav-item active">
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
        <h1>物流管理</h1>
      </div>
      <div class="tabs">
        <button 
          class="tab-item" 
          :class="{ active: activeTab === 'create' }"
          @click="activeTab = 'create'"
        >
          创建运单
        </button>
        <button 
          class="tab-item" 
          :class="{ active: activeTab === 'query' }"
          @click="activeTab = 'query'"
        >
          查询物流
        </button>
      </div>
    </div>

    <div class="logistics-container">
      <div v-if="errorMessage" class="alert alert-error">
        {{ errorMessage }}
      </div>
      
      <div v-if="successMessage" class="alert alert-success">
        {{ successMessage }}
      </div>

      <div v-if="activeTab === 'create'" class="create-waybill-section skeuomorphic-card">
        <h2>创建运单</h2>
        <div class="form-group">
          <label>订单号 *</label>
          <input 
            v-model="waybillForm.orderNo" 
            type="text" 
            placeholder="请输入订单号"
            class="skeuomorphic-input"
          />
        </div>

        <div class="form-group">
          <label>物流公司 *</label>
          <select 
            v-model="waybillForm.logisticsCompany" 
            class="skeuomorphic-select"
            :disabled="loadingProviders"
          >
            <option value="">请选择物流公司</option>
            <option v-for="provider in providers" :key="provider" :value="getProviderCode(provider)">
              {{ provider }}
            </option>
          </select>
        </div>

        <div class="form-actions">
          <button 
            class="btn-submit" 
            @click="createWaybill"
            :disabled="!waybillForm.orderNo || !waybillForm.logisticsCompany || processing"
          >
            {{ processing ? '创建中...' : '创建运单' }}
          </button>
          <button class="btn-reset" @click="resetWaybillForm">
            重置
          </button>
        </div>

        <div v-if="createdWaybill" class="waybill-result">
          <h3>运单创建成功</h3>
          <div class="result-item">
            <span class="label">运单ID:</span>
            <span class="value">{{ createdWaybill.id }}</span>
          </div>
          <div class="result-item">
            <span class="label">订单号:</span>
            <span class="value">{{ createdWaybill.orderNo }}</span>
          </div>
          <div class="result-item">
            <span class="label">物流公司:</span>
            <span class="value">{{ createdWaybill.logisticsCompany }}</span>
          </div>
          <div class="result-item">
            <span class="label">运单号:</span>
            <span class="value">{{ createdWaybill.trackingNo }}</span>
          </div>
          <div class="result-item">
            <span class="label">物流状态:</span>
            <span class="value status-badge" :class="getStatusClass(createdWaybill.status)">
              {{ getStatusText(createdWaybill.status) }}
            </span>
          </div>
          <div class="result-item">
            <span class="label">预计送达:</span>
            <span class="value">{{ formatDate(createdWaybill.estimatedDelivery) }}</span>
          </div>
          <div v-if="createdWaybill.waybillUrl" class="result-item">
            <span class="label">运单链接:</span>
            <a :href="createdWaybill.waybillUrl" target="_blank" class="waybill-link">查看运单</a>
          </div>
          <div class="result-item">
            <span class="label">订阅状态:</span>
            <span class="value">{{ createdWaybill.cainiaoSubscribed ? '已订阅' : '未订阅' }}</span>
          </div>
        </div>
      </div>

      <div v-if="activeTab === 'query'" class="query-logistics-section skeuomorphic-card">
        <h2>查询物流信息</h2>
        <div class="query-form">
          <div class="form-group">
            <label>订单号 *</label>
            <input 
              v-model="queryForm.orderNo" 
              type="text" 
              placeholder="请输入订单号"
              class="skeuomorphic-input"
            />
          </div>
          <button 
            class="btn-query" 
            @click="queryLogistics"
            :disabled="!queryForm.orderNo || querying"
          >
            {{ querying ? '查询中...' : '查询物流' }}
          </button>
        </div>

        <div v-if="logisticsInfo" class="logistics-result">
          <div class="logistics-header">
            <h3>物流信息</h3>
            <button class="btn-refresh" @click="queryLogistics" :disabled="querying">
              🔄 刷新
            </button>
          </div>

          <div class="logistics-info-grid">
            <div class="info-item">
              <span class="label">订单号:</span>
              <span class="value">{{ logisticsInfo.orderNo }}</span>
            </div>
            <div class="info-item">
              <span class="label">物流公司:</span>
              <span class="value">{{ logisticsInfo.logisticsCompany }}</span>
            </div>
            <div class="info-item">
              <span class="label">运单号:</span>
              <span class="value">{{ logisticsInfo.trackingNo }}</span>
            </div>
            <div class="info-item">
              <span class="label">物流状态:</span>
              <span class="value status-badge" :class="getStatusClass(logisticsInfo.status)">
                {{ getStatusText(logisticsInfo.status) }}
              </span>
            </div>
            <div class="info-item">
              <span class="label">预计送达:</span>
              <span class="value">{{ formatDate(logisticsInfo.estimatedDelivery) }}</span>
            </div>
            <div class="info-item">
              <span class="label">实际送达:</span>
              <span class="value">{{ formatDate(logisticsInfo.deliveredAt) || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">创建时间:</span>
              <span class="value">{{ formatDate(logisticsInfo.createdAt) }}</span>
            </div>
            <div class="info-item">
              <span class="label">更新时间:</span>
              <span class="value">{{ formatDate(logisticsInfo.updatedAt) }}</span>
            </div>
          </div>

          <div v-if="logisticsInfo.waybillUrl" class="waybill-url">
            <a :href="logisticsInfo.waybillUrl" target="_blank" class="waybill-link">
              📄 查看运单详情
            </a>
          </div>

          <div v-if="logisticsInfo.traceInfo" class="trace-info">
            <h4>物流轨迹</h4>
            <div class="trace-list">
              <div 
                v-for="(trace, index) in parseTraceInfo(logisticsInfo.traceInfo)" 
                :key="index" 
                class="trace-item"
              >
                <div class="trace-dot"></div>
                <div class="trace-content">
                  <div class="trace-text">{{ trace.text }}</div>
                  <div class="trace-time">{{ trace.time }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="queried && !logisticsInfo" class="no-result">
          <p>未找到该订单的物流信息</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'

const router = useRouter()
const activeTab = ref('create')
const providers = ref([])
const loadingProviders = ref(false)
const waybillForm = ref({
  orderNo: '',
  logisticsCompany: ''
})
const queryForm = ref({
  orderNo: ''
})
const processing = ref(false)
const querying = ref(false)
const createdWaybill = ref(null)
const logisticsInfo = ref(null)
const queried = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const fetchProviders = async () => {
  loadingProviders.value = true
  try {
    const response = await api.logistics.getProviders()
    if (response.code === 200) {
      providers.value = response.data || []
    }
  } catch (error) {
    console.error('获取物流提供商失败:', error)
  } finally {
    loadingProviders.value = false
  }
}

const getProviderCode = (providerName) => {
  if (providerName.includes('菜鸟')) {
    return 'CAINIAO'
  } else if (providerName.includes('测试')) {
    return 'TEST'
  }
  return providerName.toUpperCase()
}

const createWaybill = async () => {
  if (!waybillForm.value.orderNo || !waybillForm.value.logisticsCompany) {
    errorMessage.value = '请填写完整信息'
    setTimeout(() => errorMessage.value = '', 3000)
    return
  }

  processing.value = true
  errorMessage.value = ''
  successMessage.value = ''
  createdWaybill.value = null

  try {
    const response = await api.logistics.createWaybill({
      orderNo: waybillForm.value.orderNo,
      logisticsCompany: waybillForm.value.logisticsCompany
    })

    if (response.code === 200) {
      createdWaybill.value = response.data
      successMessage.value = '运单创建成功'
      setTimeout(() => successMessage.value = '', 5000)
    } else {
      errorMessage.value = '创建运单失败: ' + response.msg
      setTimeout(() => errorMessage.value = '', 5000)
    }
  } catch (error) {
    console.error('创建运单失败:', error)
    if (error.response?.status === 401) {
      errorMessage.value = '登录已过期,请重新登录'
      setTimeout(() => {
        window.location.href = '/login'
      }, 2000)
    } else if (error.response?.status === 400) {
      errorMessage.value = error.response?.data?.msg || '参数错误'
    } else if (error.response?.status === 404) {
      errorMessage.value = '订单不存在'
    } else {
      errorMessage.value = '创建运单失败,请稍后重试'
    }
    setTimeout(() => errorMessage.value = '', 5000)
  } finally {
    processing.value = false
  }
}

const queryLogistics = async () => {
  if (!queryForm.value.orderNo) {
    errorMessage.value = '请输入订单号'
    setTimeout(() => errorMessage.value = '', 3000)
    return
  }

  querying.value = true
  errorMessage.value = ''
  logisticsInfo.value = null
  queried.value = true

  try {
    const response = await api.logistics.getLogisticsInfo(queryForm.value.orderNo)

    if (response.code === 200) {
      logisticsInfo.value = response.data
    } else {
      errorMessage.value = '查询物流信息失败: ' + response.msg
      setTimeout(() => errorMessage.value = '', 5000)
    }
  } catch (error) {
    console.error('查询物流信息失败:', error)
    if (error.response?.status === 401) {
      errorMessage.value = '登录已过期,请重新登录'
      setTimeout(() => {
        window.location.href = '/login'
      }, 2000)
    } else if (error.response?.status === 404) {
      errorMessage.value = '未找到该订单的物流信息'
    } else {
      errorMessage.value = '查询物流信息失败,请稍后重试'
    }
    setTimeout(() => errorMessage.value = '', 5000)
  } finally {
    querying.value = false
  }
}

const resetWaybillForm = () => {
  waybillForm.value = {
    orderNo: '',
    logisticsCompany: ''
  }
  createdWaybill.value = null
}

const getStatusText = (status) => {
  const statusMap = {
    'CREATED': '已创建',
    'PICKED': '已揽收',
    'IN_TRANSIT': '运输中',
    'DELIVERED': '已送达',
    'EXCEPTION': '异常'
  }
  return statusMap[status] || status
}

const getStatusClass = (status) => {
  const classMap = {
    'CREATED': 'status-created',
    'PICKED': 'status-picked',
    'IN_TRANSIT': 'status-in-transit',
    'DELIVERED': 'status-delivered',
    'EXCEPTION': 'status-exception'
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

const parseTraceInfo = (traceInfo) => {
  if (!traceInfo) return []
  const lines = traceInfo.split('\n').filter(line => line.trim())
  return lines.map(line => {
    const match = line.match(/(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s*-\s*(.+)/)
    if (match) {
      return {
        time: match[1],
        text: match[2]
      }
    }
    return {
      time: '',
      text: line
    }
  })
}

onMounted(() => {
  fetchProviders()
})
</script>

<style scoped>
.merchant-logistics-page {
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
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  font-weight: 600;
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

.logistics-container {
  min-height: 400px;
}

.create-waybill-section,
.query-logistics-section {
  padding: 30px;
}

.create-waybill-section h2,
.query-logistics-section h2 {
  margin: 0 0 30px 0;
  font-size: 24px;
  color: #333;
}

.form-group {
  margin-bottom: 25px;
}

.form-group label {
  display: block;
  margin-bottom: 10px;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.skeuomorphic-input {
  width: 100%;
  padding: 14px 18px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  border-radius: 10px;
  font-size: 16px;
  color: #333;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.1),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.skeuomorphic-input:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(0,0,0,0.15),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.skeuomorphic-input:focus {
  outline: none;
  box-shadow: 
    3px 3px 6px rgba(79, 172, 254, 0.3),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.skeuomorphic-select {
  width: 100%;
  padding: 14px 18px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  border-radius: 10px;
  font-size: 16px;
  color: #333;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.1),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.skeuomorphic-select:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(0,0,0,0.15),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.skeuomorphic-select:focus {
  outline: none;
  box-shadow: 
    3px 3px 6px rgba(79, 172, 254, 0.3),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.skeuomorphic-select:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.form-actions {
  display: flex;
  gap: 15px;
  margin-top: 30px;
}

.btn-submit {
  flex: 1;
  padding: 14px 28px;
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

.btn-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(79, 172, 254, 0.4),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-reset {
  padding: 14px 28px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  color: #666;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.1),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.btn-reset:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(0,0,0,0.15),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.waybill-result {
  margin-top: 30px;
  padding: 25px;
  background: linear-gradient(145deg, #f8fafc, #e2e8f0);
  border-radius: 12px;
}

.waybill-result h3 {
  margin: 0 0 20px 0;
  font-size: 20px;
  color: #333;
}

.result-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #e0e0e0;
}

.result-item:last-child {
  border-bottom: none;
}

.result-item .label {
  font-weight: 600;
  color: #666;
}

.result-item .value {
  color: #333;
  font-weight: 500;
}

.status-badge {
  padding: 6px 14px;
  border-radius: 15px;
  font-size: 13px;
  font-weight: 600;
}

.status-created {
  background: linear-gradient(135deg, #ffd93d 0%, #ffec8b 100%);
  color: #8b5a00;
}

.status-picked {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.status-in-transit {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.status-delivered {
  background: linear-gradient(135deg, #4cd964 0%, #8effac 100%);
  color: #006400;
}

.status-exception {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  color: white;
}

.waybill-link {
  color: #4facfe;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.3s;
}

.waybill-link:hover {
  color: #00f2fe;
  text-decoration: underline;
}

.query-form {
  display: flex;
  gap: 15px;
  align-items: flex-end;
  margin-bottom: 30px;
}

.query-form .form-group {
  flex: 1;
  margin-bottom: 0;
}

.btn-query {
  padding: 14px 28px;
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
  white-space: nowrap;
}

.btn-query:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(79, 172, 254, 0.4),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.btn-query:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.logistics-result {
  margin-top: 30px;
}

.logistics-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.logistics-header h3 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.btn-refresh {
  padding: 8px 16px;
  border: none;
  background: linear-gradient(145deg, #f0f0f0, #cacaca);
  color: #666;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 
    2px 2px 4px rgba(0,0,0,0.1),
    -2px -2px 4px rgba(255,255,255,0.8);
}

.btn-refresh:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    3px 3px 6px rgba(0,0,0,0.15),
    -3px -3px 6px rgba(255,255,255,0.9);
}

.btn-refresh:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.logistics-info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
  margin-bottom: 20px;
}

.info-item {
  padding: 15px;
  background: linear-gradient(145deg, #fafafa, #e6e6e6);
  border-radius: 10px;
}

.info-item .label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.info-item .value {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.waybill-url {
  margin-bottom: 20px;
  text-align: center;
}

.waybill-url .waybill-link {
  display: inline-block;
  padding: 12px 24px;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s;
  box-shadow: 
    3px 3px 6px rgba(79, 172, 254, 0.3),
    -3px -3px 6px rgba(255,255,255,0.8);
}

.waybill-url .waybill-link:hover {
  transform: translateY(-2px);
  box-shadow: 
    5px 5px 10px rgba(79, 172, 254, 0.4),
    -5px -5px 10px rgba(255,255,255,0.9);
}

.trace-info {
  padding: 20px;
  background: linear-gradient(145deg, #f8fafc, #e2e8f0);
  border-radius: 12px;
}

.trace-info h4 {
  margin: 0 0 20px 0;
  font-size: 18px;
  color: #333;
}

.trace-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.trace-item {
  display: flex;
  gap: 15px;
  position: relative;
}

.trace-item::before {
  content: '';
  position: absolute;
  left: 6px;
  top: 20px;
  bottom: -20px;
  width: 2px;
  background: #d1d5db;
}

.trace-item:last-child::before {
  display: none;
}

.trace-dot {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  box-shadow: 
    2px 2px 4px rgba(79, 172, 254, 0.3),
    -2px -2px 4px rgba(255,255,255,0.8);
  flex-shrink: 0;
  margin-top: 4px;
}

.trace-content {
  flex: 1;
}

.trace-text {
  font-size: 15px;
  color: #333;
  margin-bottom: 5px;
}

.trace-time {
  font-size: 13px;
  color: #999;
}

.no-result {
  text-align: center;
  padding: 60px 20px;
  color: #999;
  font-size: 16px;
}

.skeuomorphic-card {
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  border-radius: 16px;
  box-shadow: 
    5px 5px 10px #d1d9e6,
    -5px -5px 10px #ffffff;
}
</style>