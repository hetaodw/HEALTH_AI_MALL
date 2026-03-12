import chinaRegionsData from '../../tools/china_regions.json'

export const chinaRegions = chinaRegionsData

export function getProvinces() {
  return chinaRegions.regions.map(region => region.province)
}

export function getCitiesByProvince(provinceName) {
  const region = chinaRegions.regions.find(r => r.province === provinceName)
  if (!region) return []
  return region.cities.map(city => city.name)
}

export function getDistrictsByProvinceAndCity(provinceName, cityName) {
  const region = chinaRegions.regions.find(r => r.province === provinceName)
  if (!region) return []
  const city = region.cities.find(c => c.name === cityName)
  if (!city) return []
  return city.districts
}

export function validateProvinceExists(provinceName) {
  return getProvinces().includes(provinceName)
}

export function validateCityExists(provinceName, cityName) {
  return getCitiesByProvince(provinceName).includes(cityName)
}

export function validateDistrictExists(provinceName, cityName, districtName) {
  return getDistrictsByProvinceAndCity(provinceName, cityName).includes(districtName)
}
