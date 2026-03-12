# Health Mall 文档分类说明

## 文档结构

```
docs/
├── api/                    # API文档
├── architecture/           # 架构设计
├── testing/                # 测试相关
├── development/            # 开发指南
├── bugfix/                 # Bug修复
├── review/                 # 代码审查
├── database/               # 数据库
├── release/                # 发布版本
└── project/                # 项目管理
```

## 分类说明

### 📚 api/ - API文档
存放所有API接口文档，包括：
- `API_DOCUMENTATION.md` - 主API文档
- `SHIPPING_API_DOCUMENTATION.md` - 物流API文档
- `CAINIAO_API_INTEGRATION.md` - 菜鸟API集成文档

### 🏗️ architecture/ - 架构设计
存放系统架构和设计文档：
- `PROJECT_STRUCTURE.md` - 项目结构说明
- `PAYMENT_ARCHITECTURE.md` - 支付架构设计
- `ROBUSTNESS_MECHANISM.md` - 健壮性保障机制
- `NEW_LOGISTICS_SYSTEM.md` - 新物流系统设计

### 🧪 testing/ - 测试相关
存放测试文档和报告：
- `README_TESTING.md` - 测试指南
- `test_reports/` - 测试报告目录
  - 各模块API测试报告
  - 综合测试报告
  - 物流测试报告
- `test_results/` - 测试结果文件
  - CSV格式的测试结果数据
- 其他专项测试文档

### 💻 development/ - 开发指南
存放开发相关的指南和文档：
- `START_GUIDE.md` - 系统启动指南
- `README_UI.md` - UI开发说明
- `startguide.md` - 启动指南（备用）

### 🐛 bugfix/ - Bug修复
存放Bug修复相关文档：
- `BUG_FIX_DOCUMENTATION.md` - Bug修复文档
- `AUTH_FIX_GUIDE.md` - 认证修复指南
- `category-encoding-fix.md` - 分类编码修复
- `category-system-improvements.md` - 分类系统改进

### 🔍 review/ - 代码审查
存放代码审查相关文档：
- `CODE_REVIEW_REPORT.md` - 代码审查报告

### 🗄️ database/ - 数据库
存放数据库相关文档：
- `database-schema.md` - 数据库结构说明

### 📦 release/ - 发布版本
存放版本发布相关文档：
- `RELEASE_v1.05.md` - v1.05版本发布说明

### 📋 project/ - 项目管理
存放项目管理相关文档：
- `发货开发计划.md` - 发货功能开发计划
- `开题报告.md` - 项目开题报告

## 文档命名规范

### Markdown文档
- 使用英文命名，使用下划线分隔单词
- 示例：`API_DOCUMENTATION.md`, `BUG_FIX_DOCUMENTATION.md`

### 测试报告
- 以`TEST_REPORT_`开头，后跟模块名称
- 示例：`TEST_REPORT_AUTH_API.md`, `TEST_REPORT_ORDER_API.md`

### 测试结果文件
- 使用CSV格式，以`test_`开头
- 示例：`test_auth_api_results.csv`

## 文档维护建议

1. **新增文档时**：
   - 根据文档类型选择合适的分类文件夹
   - 遵循命名规范
   - 更新本说明文档

2. **更新文档时**：
   - 保持文档结构清晰
   - 使用统一的格式和风格
   - 及时更新相关链接

3. **删除文档时**：
   - 确认不再需要该文档
   - 检查是否有其他文档引用
   - 更新相关索引

## 快速导航

- **新手入门**：从 `development/START_GUIDE.md` 开始
- **API开发**：查看 `api/API_DOCUMENTATION.md`
- **系统架构**：参考 `architecture/` 目录
- **测试验证**：查阅 `testing/README_TESTING.md`
- **问题排查**：检查 `bugfix/` 目录

## 文档版本

- **创建日期**：2026-03-12
- **最后更新**：2026-03-12
- **版本**：v1.0
