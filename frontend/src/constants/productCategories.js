export const PRODUCT_CATEGORIES = [
  { value: 'HEALTH_PRODUCTS', label: '保健品' },
  { value: 'MEDICAL_DEVICES', label: '医疗器械' },
  { value: 'HEALTH_FOOD', label: '健康食品' },
  { value: 'SPORTS_FITNESS', label: '运动健身' },
  { value: 'MATERNAL_BABY', label: '母婴用品' }
]

export const isValidCategory = (category) => {
  return PRODUCT_CATEGORIES.some(cat => cat.value === category)
}

export const getCategoryLabel = (value) => {
  const category = PRODUCT_CATEGORIES.find(cat => cat.value === value)
  return category ? category.label : value
}
