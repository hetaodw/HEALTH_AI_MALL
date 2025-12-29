<template>
  <div class="product-card skeuomorphic-card" @click="goToDetail">
    <div class="product-image-container">
      <img :src="product.coverUrl || placeholderImage" :alt="product.title" class="product-image skeuomorphic-image" />
      <div v-if="product.stock <= 10" class="stock-badge skeuomorphic-badge">
        仅剩 {{ product.stock }} 件
      </div>
    </div>

    <div class="product-info">
      <h3 class="product-title">{{ product.title }}</h3>
      <div class="product-price">
        <span class="skeuomorphic-price">¥{{ product.price.toFixed(2) }}</span>
      </div>
      <div class="product-actions">
        <button class="skeuomorphic-button add-to-cart">
          加入购物车
        </button>
        <button class="skeuomorphic-button primary view-detail">
          查看详情
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  product: {
    type: Object,
    required: true
  }
})

const router = useRouter()
const placeholderImage = 'https://via.placeholder.com/300x300?text=Product'

const goToDetail = () => {
  router.push({ name: 'ProductDetail', params: { id: props.product.id } })
}
</script>

<style scoped>
.product-card {
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.product-card:hover {
  transform: translateY(-8px);
  box-shadow: 
    12px 12px 24px #d1d9e6,
    -12px -12px 24px #ffffff;
}

.product-image-container {
  position: relative;
  width: 100%;
  padding-top: 100%;
  overflow: hidden;
  border-radius: 16px;
}

.product-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.product-card:hover .product-image {
  transform: scale(1.05);
}

.stock-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 10;
}

.product-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.product-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 44px;
}

.product-price {
  display: flex;
  align-items: center;
}

.product-actions {
  display: flex;
  gap: 8px;
}

.add-to-cart,
.view-detail {
  flex: 1;
  padding: 10px 16px;
  font-size: 14px;
}

@media (max-width: 768px) {
  .product-actions {
    flex-direction: column;
  }
}
</style>
