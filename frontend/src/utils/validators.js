export const validatePhone = (phone) => {
  if (!phone) {
    return { valid: false, message: '请输入手机号码' }
  }
  
  const phoneRegex = /^1[3-9]\d{9}$/
  if (!phoneRegex.test(phone)) {
    return { valid: false, message: '请输入正确的手机号码' }
  }
  
  return { valid: true, message: '' }
}

export const validateReceiverName = (name) => {
  if (!name || name.trim() === '') {
    return { valid: false, message: '请输入收货人姓名' }
  }
  
  if (name.trim().length < 2) {
    return { valid: false, message: '收货人姓名至少2个字符' }
  }
  
  if (name.trim().length > 20) {
    return { valid: false, message: '收货人姓名不能超过20个字符' }
  }
  
  return { valid: true, message: '' }
}

export const validateProvince = (province) => {
  if (!province || province.trim() === '') {
    return { valid: false, message: '请输入省份' }
  }
  
  return { valid: true, message: '' }
}

export const validateCity = (city) => {
  if (!city || city.trim() === '') {
    return { valid: false, message: '请输入城市' }
  }
  
  return { valid: true, message: '' }
}

export const validateDistrict = (district) => {
  if (!district || district.trim() === '') {
    return { valid: false, message: '请输入区/县' }
  }
  
  return { valid: true, message: '' }
}

export const validateDetailAddress = (address) => {
  if (!address || address.trim() === '') {
    return { valid: false, message: '请输入详细地址' }
  }
  
  if (address.trim().length < 5) {
    return { valid: false, message: '详细地址至少5个字符' }
  }
  
  if (address.trim().length > 100) {
    return { valid: false, message: '详细地址不能超过100个字符' }
  }
  
  return { valid: true, message: '' }
}

export const validateAddressForm = (formData) => {
  const errors = {}
  
  const nameResult = validateReceiverName(formData.receiverName)
  if (!nameResult.valid) {
    errors.receiverName = nameResult.message
  }
  
  const phoneResult = validatePhone(formData.receiverPhone)
  if (!phoneResult.valid) {
    errors.receiverPhone = phoneResult.message
  }
  
  const provinceResult = validateProvince(formData.province)
  if (!provinceResult.valid) {
    errors.province = provinceResult.message
  }
  
  const cityResult = validateCity(formData.city)
  if (!cityResult.valid) {
    errors.city = cityResult.message
  }
  
  const districtResult = validateDistrict(formData.district)
  if (!districtResult.valid) {
    errors.district = districtResult.message
  }
  
  const addressResult = validateDetailAddress(formData.detailAddress)
  if (!addressResult.valid) {
    errors.detailAddress = addressResult.message
  }
  
  return {
    valid: Object.keys(errors).length === 0,
    errors
  }
}
