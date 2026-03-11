import axios from 'axios'

const api = axios.create({
  baseURL: '/v1',
  timeout: 10000
})

api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

api.interceptors.response.use(
  response => {
    return response.data
  },
  error => {
    console.error('API Error:', error)
    return Promise.reject(error)
  }
)

export default {
  auth: {
    register: (data) => api.post('/auth/register', data),
    login: (data) => api.post('/auth/login', data),
    logout: () => api.post('/auth/logout')
  },
  products: {
    getList: (params) => api.get('/products', { params }),
    search: (params) => api.get('/products/search', { params }),
    getHot: (params) => api.get('/products/hot', { params }),
    getDetail: (id) => api.get(`/products/${id}`),
    getByCategory: (category, params) => api.get(`/products/category/${category}`, { params })
  },
  merchant: {
    addProduct: (data) => {
      return api.post('/merchant/products', data)
    },
    updateProduct: (id, data) => {
      return api.put(`/merchant/products/${id}`, data)
    },
    deleteProduct: (id) => api.delete(`/merchant/products/${id}`),
    getProductList: (params) => api.get('/merchant/products', { params }),
    getProductDetail: (id) => api.get(`/merchant/products/${id}`),
    updateProductStatus: (id, status) => api.patch(`/merchant/products/${id}/status`, null, { params: { status } }),
    updateProductStock: (id, stock) => api.patch(`/merchant/products/${id}/stock`, null, { params: { stock } }),
    batchUpdateAutoConfirmMode: (data) => api.patch('/merchant/products/auto-confirm-mode', data),
    getPendingOrders: () => api.get('/merchant/orders/pending'),
    getOrders: (params) => api.get('/merchant/orders', { params }),
    confirmOrder: (orderId) => api.post(`/merchant/orders/${orderId}/confirm`),
    rejectOrder: (orderId, reason) => api.post(`/merchant/orders/${orderId}/reject`, { rejectReason: reason })
  },
  admin: {
    createProduct: (data) => {
      return api.post('/admin/products', data)
    },
    deleteProduct: (id) => api.delete(`/admin/products/${id}`)
  },
  user: {
    getProfile: () => api.get('/user/profile'),
    updateProfile: (data) => api.put('/user/profile/update', null, { params: data }),
    uploadAvatar: (formData) => api.post('/user/avatar/upload', formData)
  },
  orders: {
    create: (data) => api.post('/orders', data),
    getMyOrders: () => api.get('/orders/my'),
    getOrderDetail: (id) => api.get(`/orders/${id}`),
    cancelOrder: (id, reason) => api.post(`/orders/${id}/cancel`, null, { params: { reason } }),
    payOrder: (orderNo, payMethod) => api.post(`/orders/${orderNo}/pay`, null, { params: { payMethod } })
  },
  addresses: {
    getList: () => api.get('/addresses'),
    getDefault: () => api.get('/addresses/default'),
    getDetail: (id) => api.get(`/addresses/${id}`),
    create: (data) => api.post('/addresses', data),
    update: (id, data) => api.put(`/addresses/${id}`, data),
    delete: (id) => api.delete(`/addresses/${id}`),
    setDefault: (id) => api.post(`/addresses/${id}/default`)
  },
  productDescription: {
    get: (productId) => api.get(`/product/descriptions/${productId}`),
    createOrUpdate: (productId, data) => api.post(`/product/descriptions/${productId}`, data),
    delete: (productId) => api.delete(`/product/descriptions/${productId}`)
  },
  productReviews: {
    getList: (productId, params) => api.get(`/product/reviews/${productId}`, { params }),
    getDetail: (reviewId) => api.get(`/product/reviews/detail/${reviewId}`),
    create: (productId, data) => api.post(`/product/reviews/${productId}`, data),
    delete: (reviewId) => api.delete(`/product/reviews/${reviewId}`)
  },
  browsingHistory: {
    getList: (params) => api.get('/browsing-history', { params }),
    add: (productId) => api.post(`/browsing-history/${productId}`),
    delete: (productId) => api.delete(`/browsing-history/${productId}`),
    clear: () => api.delete('/browsing-history')
  },
  productTags: {
    generate: (productId) => api.post(`/products/tags/${productId}/generate`),
    batchGenerate: (data) => api.post('/products/tags/batch/generate', data),
    get: (productId) => api.get(`/products/tags/${productId}`),
    update: (productId, data) => api.put(`/products/tags/${productId}`, data),
    getPopular: (params) => api.get('/products/tags/popular', { params }),
    search: (params) => api.get('/products/tags/search', { params })
  },
  logistics: {
    getProviders: () => api.get('/cainiao/providers'),
    createWaybill: (data) => api.post('/merchant/logistics/waybill', data),
    getLogisticsInfo: (orderNo) => api.get(`/merchant/logistics/${orderNo}`),
    subscribe: (data) => api.post('/cainiao/subscribe', data)
  }
}
