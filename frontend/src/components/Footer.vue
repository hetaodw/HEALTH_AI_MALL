<template>
  <footer class="footer">
    <div class="footer-content">
      <div class="footer-section">
        <h3 class="footer-title">关于我们</h3>
        <p class="footer-text">健康商城致力于为您提供优质的健康产品和服务</p>
      </div>

      <div class="footer-section">
        <h3 class="footer-title">快速链接</h3>
        <ul class="footer-links">
          <li><router-link to="/">首页</router-link></li>
          <li><router-link to="/products">商品列表</router-link></li>
          <li><router-link to="/profile">个人中心</router-link></li>
        </ul>
      </div>

      <div class="footer-section">
        <h3 class="footer-title">联系方式</h3>
        <ul class="footer-contact">
          <li>📞 400-888-8888</li>
          <li>📧 service@healthmall.com</li>
          <li>📍 北京市朝阳区健康路123号</li>
        </ul>
      </div>
    </div>

    <div class="footer-bottom">
      <p>&copy; 2024 健康商城. All rights reserved.</p>
    </div>
  </footer>
</template>

<script setup>
</script>

<style scoped>
.footer {
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  box-shadow: 
    0 -4px 12px rgba(0, 0, 0, 0.1);
  margin-top: auto;
  border-top: 1px solid rgba(255, 255, 255, 0.5);
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 24px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 32px;
}

.footer-section {
  background: linear-gradient(145deg, #f8f9fa, #ffffff);
  padding: 24px;
  border-radius: 16px;
  box-shadow: 
    4px 4px 8px #d1d9e6,
    -4px -4px 8px #ffffff;
  border: 1px solid rgba(255, 255, 255, 0.5);
}

.footer-title {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 16px;
  color: #333;
  background: linear-gradient(145deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.footer-text {
  color: #666;
  line-height: 1.8;
  font-size: 14px;
}

.footer-links {
  list-style: none;
}

.footer-links li {
  margin-bottom: 12px;
}

.footer-links a {
  color: #666;
  text-decoration: none;
  transition: all 0.3s ease;
  display: block;
  padding: 8px 12px;
  border-radius: 8px;
}

.footer-links a:hover {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  transform: translateX(4px);
  box-shadow: 
    3px 3px 6px #d1d9e6,
    -3px -3px 6px #ffffff;
}

.footer-contact {
  list-style: none;
}

.footer-contact li {
  margin-bottom: 12px;
  color: #666;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.footer-bottom {
  background: linear-gradient(145deg, #667eea, #764ba2);
  color: white;
  text-align: center;
  padding: 20px;
  font-size: 14px;
}

@media (max-width: 768px) {
  .footer-content {
    grid-template-columns: 1fr;
  }
}
</style>
