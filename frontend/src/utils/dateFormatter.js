/**
 * 日期时间格式化工具函数
 */

/**
 * 格式化日期时间为本地字符串
 * @param {string|Date} dateString - 日期字符串或Date对象
 * @param {boolean} showSeconds - 是否显示秒数，默认true
 * @returns {string} 格式化后的日期字符串
 */
export const formatDateTime = (dateString, showSeconds = true) => {
  if (!dateString) return '未知'
  
  try {
    // 处理 "yyyy-MM-dd HH:mm:ss" 格式
    let date
    if (typeof dateString === 'string' && dateString.includes(' ')) {
      // 将 "yyyy-MM-dd HH:mm:ss" 替换为 "yyyy-MM-ddTHH:mm:ss" 以兼容 Date 解析
      const isoString = dateString.replace(' ', 'T')
      date = new Date(isoString)
    } else {
      date = new Date(dateString)
    }
    
    // 检查日期是否有效
    if (isNaN(date.getTime())) {
      console.warn('Invalid date:', dateString)
      return '未知'
    }
    
    const options = {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }
    
    if (showSeconds) {
      options.second = '2-digit'
    }
    
    return date.toLocaleString('zh-CN', options)
  } catch (err) {
    console.error('Date format error:', err, dateString)
    return '未知'
  }
}

/**
 * 格式化日期为本地字符串（仅日期部分）
 * @param {string|Date} dateString - 日期字符串或Date对象
 * @returns {string} 格式化后的日期字符串
 */
export const formatDate = (dateString) => {
  if (!dateString) return '未知'
  
  try {
    let date
    if (typeof dateString === 'string' && dateString.includes(' ')) {
      const isoString = dateString.replace(' ', 'T')
      date = new Date(isoString)
    } else {
      date = new Date(dateString)
    }
    
    if (isNaN(date.getTime())) {
      console.warn('Invalid date:', dateString)
      return '未知'
    }
    
    return date.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (err) {
    console.error('Date format error:', err, dateString)
    return '未知'
  }
}

/**
 * 获取当前时间的格式化字符串
 * @returns {string} 当前时间的格式化字符串
 */
export const getCurrentDateTime = () => {
  return formatDateTime(new Date())
}

/**
 * 计算时间差（分钟）
 * @param {string|Date} startTime - 开始时间
 * @param {string|Date} endTime - 结束时间
 * @returns {number} 时间差（分钟）
 */
export const getTimeDiffInMinutes = (startTime, endTime) => {
  try {
    const start = new Date(startTime)
    const end = new Date(endTime)
    
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return 0
    }
    
    return Math.floor((end - start) / (1000 * 60))
  } catch (err) {
    console.error('Time diff error:', err)
    return 0
  }
}

export default {
  formatDateTime,
  formatDate,
  getCurrentDateTime,
  getTimeDiffInMinutes
}
