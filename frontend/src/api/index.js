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
      // 如果是FormData，不设置Content-Type，让浏览器自动设置boundary
      const isFormData = data instanceof FormData
      return api.post('/merchant/products', data, {
        headers: isFormData ? {} : {}
      })
    },
    updateProduct: (id, data) => {
      const isFormData = data instanceof FormData
      return api.put(`/merchant/products/${id}`, data, {
        headers: isFormData ? {} : {}
      })
    },
    deleteProduct: (id) => api.delete(`/merchant/products/${id}`),
    getProductList: (params) => api.get('/merchant/products', { params }),
    getProductDetail: (id) => api.get(`/merchant/products/${id}`),
    updateProductStatus: (id, status) => api.patch(`/merchant/products/${id}/status`, null, { params: { status } }),
    updateProductStock: (id, stock) => api.patch(`/merchant/products/${id}/stock`, null, { params: { stock } })
  },
  admin: {
    createProduct: (data) => {
      const isFormData = data instanceof FormData
      return api.post('/admin/products', data, {
        headers: isFormData ? { 'Content-Type': 'multipart/form-data' } : {}
      })
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
  }
}
