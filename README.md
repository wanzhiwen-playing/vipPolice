# vipPolice

一个基于 SwiftUI 的 iPhone App，用于管理各平台会员权益。

**✨ 特别支持：Windows 开发 + GitHub Actions 编译 + AltStore 安装！**

## 🎯 核心功能

1. **截图识别**：通过系统 OCR 识别会员页面截图
2. **权益管理**：自动提取和管理各平台权益信息
3. **本月待办**：显示当月需要处理的任务（待领取、待使用）
4. **全部权益**：查看所有已录入的会员账号和权益详情
5. **到期提醒**：在权益失效前5天弹出提醒

## 🚀 快速开始

### 方案 A：Windows 用户（推荐）⭐

**无需 Mac，完全免费！**

1. **在 Windows 上编写代码**（使用 VS Code）
2. **推送到 GitHub**（自动触发编译）
3. **下载 IPA**（GitHub Actions 自动构建）
4. **通过 AltStore 安装**（无需越狱）

```bash
# 1. 运行快速设置脚本
setup-github.bat

# 2. 等待 GitHub Actions 编译完成（5-10分钟）

# 3. 下载 IPA 并通过 AltStore 安装
```

**详细教程**：📖 [WINDOWS_GITHUB_ALTSTORE.md](WINDOWS_GITHUB_ALTSTORE.md)

### 方案 B：Mac 用户

使用 Xcode 直接开发和运行。

**详细教程**：📖 [QUICK_START.md](QUICK_START.md)

## 📚 完整文档

| 文档 | 说明 |
|------|------|
| **[WINDOWS_GITHUB_ALTSTORE.md](WINDOWS_GITHUB_ALTSTORE.md)** | ⭐ Windows 用户必读！完整部署指南 |
| **[QUICK_START.md](QUICK_START.md)** | Mac 用户快速入门 |
| **[USAGE_GUIDE.md](USAGE_GUIDE.md)** | 详细使用说明 |
| **[DEVELOPMENT.md](DEVELOPMENT.md)** | 开发和技术文档 |
| **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** | 项目结构说明 |

## 💻 技术栈

- **SwiftUI** - 现代化 UI 框架
- **Vision Framework** - 系统 OCR 识别
- **UserNotifications** - 本地通知提醒
- **Swift 正则表达式** - 文本解析
- **GitHub Actions** - 自动化编译
- **XcodeGen** - 项目配置管理

## 📁 项目结构

```
vipPolice/
├── Models/                      # 数据模型
│   ├── Benefit.swift           # 权益模型
│   └── MemberAccount.swift     # 会员账号模型
├── Views/                       # 视图层
│   ├── MonthlyFocusView.swift  # 本月待办
│   ├── AllAccountsView.swift   # 全部权益
│   ├── AccountDetailView.swift # 账号详情
│   ├── ImagePickerView.swift   # 图片选择
│   └── VerificationView.swift  # 验证编辑
├── Services/                    # 业务逻辑
│   ├── OCRParser.swift         # OCR 解析引擎
│   ├── DataManager.swift       # 数据管理
│   └── NotificationManager.swift # 通知管理
├── .github/workflows/           # GitHub Actions
│   └── build-ios.yml           # 自动编译配置
├── ContentView.swift            # 主视图
├── vipPoliceApp.swift          # App 入口
├── Info.plist                   # 配置文件
├── project.yml                  # XcodeGen 配置
└── setup-github.bat            # Windows 快速设置脚本
```

## 🎨 支持的平台

- ✅ 淘宝 / 天猫
- ✅ 京东
- ✅ 美团
- ✅ 饿了么
- 🔄 其他平台（可尝试，可能需要手动调整）

## 🔧 开发环境

### Windows 用户
- Windows 10/11
- Git for Windows
- Visual Studio Code
- GitHub 账号（免费）
- AltStore + AltServer

### Mac 用户
- macOS 12.0+
- Xcode 15.0+
- iOS 17.0+ (设备或模拟器)

## 🎯 核心特性

✅ **完整的 OCR 识别流程**  
✅ **本地规则解析引擎**（正则表达式 + 关键词匹配）  
✅ **手动校验和微调界面**  
✅ **本月待办智能筛选**  
✅ **到期提醒通知**（5天前）  
✅ **数据持久化**（本地存储）  
✅ **iOS 原生设计风格**  
✅ **完善的错误处理**  
✅ **Windows 开发支持**（GitHub Actions）  
✅ **无需越狱安装**（AltStore）  

## 📊 使用流程

```
截图会员页面
    ↓
导入 vipPolice
    ↓
OCR 自动识别
    ↓
手动确认校验
    ↓
保存到本地
    ↓
自动提醒到期
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目仅供学习和个人使用。

## 🙏 致谢

- Apple Vision Framework
- GitHub Actions
- AltStore
- XcodeGen

---

**开始使用：**
- Windows 用户：查看 [WINDOWS_GITHUB_ALTSTORE.md](WINDOWS_GITHUB_ALTSTORE.md)
- Mac 用户：查看 [QUICK_START.md](QUICK_START.md)

**祝您使用愉快！再也不会错过任何优惠！** 🎉
