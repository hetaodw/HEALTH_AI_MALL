import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import ProductList from '../views/ProductList.vue'
import ProductDetail from '../views/ProductDetail.vue'
import Search from '../views/Search.vue'
import Profile from '../views/Profile.vue'
import OrderConfirm from '../views/OrderConfirm.vue'
import Cart from '../views/Cart.vue'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import MerchantDashboard from '../views/MerchantDashboard.vue'
import MerchantOrders from '../views/MerchantOrders.vue'
import BrowsingHistory from '../views/BrowsingHistory.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/products',
    name: 'ProductList',
    component: ProductList
  },
  {
    path: '/products/:id',
    name: 'ProductDetail',
    component: ProductDetail
  },
  {
    path: '/search',
    name: 'Search',
    component: Search
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile,
    meta: { requiresAuth: true }
  },
  {
    path: '/browsing-history',
    name: 'BrowsingHistory',
    component: BrowsingHistory,
    meta: { requiresAuth: true }
  },
  {
    path: '/order/confirm',
    name: 'OrderConfirm',
    component: OrderConfirm,
    meta: { requiresAuth: true }
  },
  {
    path: '/cart',
    name: 'Cart',
    component: Cart,
    meta: { requiresAuth: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/register',
    name: 'Register',
    component: Register
  },
  {
    path: '/merchant',
    name: 'MerchantDashboard',
    component: MerchantDashboard,
    meta: { requiresAuth: true, requiresMerchant: true }
  },
  {
    path: '/merchant/orders',
    name: 'MerchantOrders',
    component: MerchantOrders,
    meta: { requiresAuth: true, requiresMerchant: true }
  }
]

const router = createRouter({
  history: createWebHistory('/'),
  routes
})

export default router
