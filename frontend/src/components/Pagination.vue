<template>
  <div class="pagination">
    <button
      @click="goToPage(currentPage - 1)"
      :disabled="currentPage === 1"
      class="skeuomorphic-button page-button"
      :class="{ disabled: currentPage === 1 }"
    >
      上一页
    </button>

    <div class="page-numbers">
      <button
        v-for="page in visiblePages"
        :key="page"
        @click="goToPage(page)"
        class="skeuomorphic-button page-number"
        :class="{ active: page === currentPage }"
      >
        {{ page }}
      </button>
    </div>

    <button
      @click="goToPage(currentPage + 1)"
      :disabled="currentPage === totalPages"
      class="skeuomorphic-button page-button"
      :class="{ disabled: currentPage === totalPages }"
    >
      下一页
    </button>
  </div>
</template>

<script setup>
import { defineProps, defineEmits, computed } from 'vue'

const props = defineProps({
  currentPage: {
    type: Number,
    required: true
  },
  totalPages: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['page-change'])

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, props.currentPage - Math.floor(maxVisible / 2))
  let end = Math.min(props.totalPages, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

const goToPage = (page) => {
  if (page >= 1 && page <= props.totalPages && page !== props.currentPage) {
    emit('page-change', page)
  }
}
</script>

<style scoped>
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-top: 32px;
  flex-wrap: wrap;
}

.page-button {
  padding: 10px 20px;
  font-size: 14px;
}

.page-button.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 8px;
}

.page-number {
  width: 44px;
  height: 44px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
}

.page-number.active {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  box-shadow: 
    5px 5px 10px #a8b5d1,
    -5px -5px 10px #ffffff;
}

.page-number:hover:not(.active) {
  transform: translateY(-2px);
  box-shadow: 
    7px 7px 14px #d1d9e6,
    -7px -7px 14px #ffffff;
}

@media (max-width: 768px) {
  .pagination {
    gap: 8px;
  }

  .page-button {
    padding: 8px 16px;
    font-size: 12px;
  }

  .page-number {
    width: 36px;
    height: 36px;
    font-size: 12px;
  }
}
</style>
