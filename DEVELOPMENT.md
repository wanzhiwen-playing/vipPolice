# vipPolice 开发文档

## 项目架构

### 目录结构

```
vipPolice/
├── Models/                      # 数据模型层
│   ├── Benefit.swift           # 权益模型
│   └── MemberAccount.swift     # 会员账号模型
├── Views/                       # 视图层
│   ├── MonthlyFocusView.swift  # 本月待办视图
│   ├── AllAccountsView.swift   # 全部权益视图
│   ├── AccountDetailView.swift # 账号详情视图
│   ├── ImagePickerView.swift   # 图片选择器
│   └── VerificationView.swift  # 验证和编辑视图
├── Services/                    # 业务逻辑层
│   ├── OCRParser.swift         # OCR 解析引擎
│   ├── DataManager.swift       # 数据管理器
│   └── NotificationManager.swift # 通知管理器
├── ContentView.swift            # 主视图（Tab 导航）
├── vipPoliceApp.swift          # App 入口
└── Info.plist                   # 配置文件
```

## 核心组件说明

### 1. 数据模型 (Models)

#### Benefit
- 表示单个权益
- 支持两种类型：周期性重置、一次性到期
- 包含标题、金额、日期、使用限制等信息
- 提供判断是否需要处理的方法

#### MemberAccount
- 表示一个会员账号
- 包含平台信息、权益数组
- 提供查询本月待办、即将过期权益的方法

#### Platform
- 枚举类型，定义支持的平台
- 包含主题色、图标、关键词等配置

### 2. OCR 解析引擎 (OCRParser)

#### 工作流程
1. 使用 Vision Framework 识别图片中的文字
2. 按行分割文本
3. 检测平台关键词
4. 在关键词附近的行中提取权益信息
5. 使用正则表达式匹配金额、日期、数量等

#### 解析规则
- **平台识别**：搜索预设关键词（如"美团"、"京东"）
- **金额提取**：匹配 `¥数字` 或 `数字元` 格式
- **日期提取**：匹配 `YYYY-MM-DD` 等格式
- **限制提取**：匹配"满XX可用"、"限自营"等关键词

#### 扩展新平台
在 `Platform` 枚举中添加新平台：
```swift
case newPlatform = "新平台"

var keywords: [String] {
    case .newPlatform:
        return ["关键词1", "关键词2"]
}
```

### 3. 数据管理器 (DataManager)

- 使用 `@Published` 属性发布数据变化
- 通过 UserDefaults 持久化数据
- 提供 CRUD 操作接口
- 支持查询本月任务、即将过期权益

### 4. 通知管理器 (NotificationManager)

#### 通知策略
- **周期性权益**：在重置日前一天的上午 9:00 提醒
- **一次性权益**：在过期前 5 天提醒

#### 权限处理
- 首次使用时请求通知权限
- 如果用户拒绝，引导到系统设置

### 5. 视图层 (Views)

#### MonthlyFocusView
- 显示本月需要处理的任务
- 分为"待领取"和"待使用"两个部分
- 支持 Checkbox 交互

#### AllAccountsView
- 列表展示所有账号
- 支持左滑删除
- 点击进入详情页

#### ImagePickerView
- 使用 PhotosPicker 选择图片
- 显示处理进度
- 识别完成后跳转到验证页面

#### VerificationView
- 展示识别结果
- 允许用户编辑每个权益
- 提供警告提示

## 开发环境要求

- **Xcode**: 15.0+
- **iOS**: 17.0+
- **Swift**: 5.9+
- **Frameworks**:
  - SwiftUI
  - Vision
  - UserNotifications
  - PhotosUI

## 构建和运行

### 使用 Xcode

1. 打开 Xcode
2. 选择 File → New → Project
3. 选择 iOS → App
4. 填写项目信息：
   - Product Name: vipPolice
   - Interface: SwiftUI
   - Language: Swift
5. 将所有源文件复制到项目中
6. 确保 Info.plist 配置正确
7. 选择目标设备或模拟器
8. 点击 Run (⌘R)

### 权限配置

在 Info.plist 中必须包含：
- `NSPhotoLibraryUsageDescription`: 相册访问权限说明
- `NSCameraUsageDescription`: 相机访问权限说明（可选）

## 测试建议

### 单元测试
- 测试 OCR 解析逻辑
- 测试日期计算逻辑
- 测试数据持久化

### UI 测试
- 测试添加截图流程
- 测试编辑权益流程
- 测试通知权限请求

### 手动测试
- 使用真实的会员页面截图
- 测试各种日期格式
- 测试边界情况（如过期日期、无效数据）

## 性能优化

### OCR 识别
- 在后台线程执行
- 避免阻塞主线程
- 适当降低图片分辨率

### 数据存储
- 使用 Codable 序列化
- 考虑迁移到 Core Data（如果数据量大）

### 通知调度
- 批量更新通知
- 避免重复调度

## 已知限制

1. **OCR 准确性**：依赖系统 Vision Framework，识别率约 80-90%
2. **平台支持**：目前仅预设 4 个平台，其他平台需要手动调整
3. **数据存储**：使用 UserDefaults，不适合大量数据
4. **通知限制**：iOS 系统限制待处理通知数量（64 个）

## 未来改进方向

### 功能增强
- [ ] 支持更多平台
- [ ] 添加统计图表
- [ ] 支持导入/导出数据
- [ ] 添加小组件支持
- [ ] 支持 iCloud 同步

### 技术优化
- [ ] 使用 Core Data 替代 UserDefaults
- [ ] 优化 OCR 识别算法
- [ ] 添加机器学习模型
- [ ] 支持批量导入

### UI/UX 改进
- [ ] 添加深色模式优化
- [ ] 添加动画效果
- [ ] 支持自定义主题
- [ ] 添加引导页

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 代码规范

- 遵循 Swift API Design Guidelines
- 使用有意义的变量和函数名
- 添加必要的注释
- 保持代码简洁和可读性

## 许可证

本项目仅供学习和个人使用。
