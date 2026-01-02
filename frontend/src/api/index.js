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
    const res = response.data
    if (res.code !== 200) {
      console.error('API Error:', res)
      const error = new Error(res.msg || '未知错误')
      error.response = response
      error.code = res.code
      return Promise.reject(error)
    }
    return res
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
  user: {
    getProfile: () => api.get('/user/profile'),
    updateProfile: (data) => api.put('/user/profile/update', null, { params: data })
  },
  products: {
    getList: (params) => api.get('/products', { params }),
    search: (params) => api.get('/products/search', { params }),
    getHot: (params) => api.get('/products/hot', { params }),
    getDetail: (id) => api.get(`/products/${id}`),
    getByCategory: (category, params) => api.get(`/products/category/${category}`, { params })
  },
  merchant: {
    addProduct: (data) => api.post('/merchant/products', data),
    updateProduct: (id, data) => api.put(`/merchant/products/${id}`, data),
    deleteProduct: (id) => api.delete(`/merchant/products/${id}`),
    getProductList: (params) => api.get('/merchant/products', { params }),
    getProductDetail: (id) => api.get(`/merchant/products/${id}`),
    updateProductStatus: (id, status) => api.patch(`/merchant/products/${id}/status`, null, { params: { status } }),
    updateProductStock: (id, stock) => api.patch(`/merchant/products/${id}/stock`, null, { params: { stock } })
  },
  upload: (endpoint, formData, config = {}) => api.post(endpoint, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    },
    ...config
  }),
  deleteFile: (url) => api.delete('/upload', { params: { url } })
}
