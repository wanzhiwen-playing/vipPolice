# Windows + GitHub Actions + AltStore 完整部署指南

## 🎯 方案概述

这个方案让您可以：
1. ✅ 在 **Windows** 上编写和修改代码
2. ✅ 使用 **GitHub Actions** 自动编译（免费的云端 Mac）
3. ✅ 通过 **AltStore** 安装到 iPhone（无需越狱）

**完全免费，无需 Mac！**

---

## 📋 准备工作

### 需要的工具：

1. **GitHub 账号**（免费）
2. **Git**（Windows 版本）
3. **AltStore**（iPhone 上）
4. **iTunes** 或 **iCloud for Windows**
5. **Visual Studio Code**（编辑代码）

### 需要的设备：

- Windows 电脑
- iPhone（iOS 12.2+）
- USB 数据线（连接 iPhone 和电脑）

---

## 🚀 第一步：设置 GitHub 仓库

### 1. 创建 GitHub 仓库

```bash
# 在 Windows 命令行中执行

# 1. 初始化 Git 仓库
cd c:\mineApp\vipPolice
git init

# 2. 添加所有文件
git add .

# 3. 提交
git commit -m "Initial commit: vipPolice iOS App"

# 4. 在 GitHub 上创建新仓库
# 访问 https://github.com/new
# 仓库名：vipPolice
# 设置为 Public（免费使用 GitHub Actions）

# 5. 关联远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/vipPolice.git

# 6. 推送代码
git branch -M main
git push -u origin main
```

### 2. 启用 GitHub Actions

1. 进入 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 如果提示启用，点击 **I understand my workflows**
4. GitHub Actions 会自动检测 `.github/workflows/build-ios.yml`

---

## 🔧 第二步：配置自动编译

### 方法 A：使用 XcodeGen（推荐）

XcodeGen 可以自动生成 Xcode 项目文件。

#### 1. 修改 GitHub Actions 工作流

创建 `.github/workflows/build-ios.yml`：

```yaml
name: Build iOS App

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install XcodeGen
      run: brew install xcodegen
    
    - name: Generate Xcode Project
      run: xcodegen generate
    
    - name: Build App
      run: |
        xcodebuild -project vipPolice.xcodeproj \
          -scheme vipPolice \
          -configuration Release \
          -archivePath build/vipPolice.xcarchive \
          archive \
          CODE_SIGN_IDENTITY="" \
          CODE_SIGNING_REQUIRED=NO
    
    - name: Export IPA
      run: |
        mkdir Payload
        cp -r build/vipPolice.xcarchive/Products/Applications/vipPolice.app Payload/
        zip -r vipPolice.ipa Payload
    
    - name: Upload IPA
      uses: actions/upload-artifact@v4
      with:
        name: vipPolice-IPA
        path: vipPolice.ipa
```

#### 2. 创建 project.yml

已经创建好了！文件位置：`project.yml`

#### 3. 推送更改

```bash
git add .github/workflows/build-ios.yml project.yml
git commit -m "Add GitHub Actions workflow"
git push
```

### 方法 B：手动创建 Xcode 项目（备选）

如果 XcodeGen 不工作，可以：

1. 借用朋友的 Mac 创建一次 Xcode 项目
2. 将 `.xcodeproj` 文件夹提交到 Git
3. 之后就可以在 Windows 上修改代码，GitHub Actions 自动编译

---

## 📱 第三步：安装 AltStore

### 在 iPhone 上安装 AltStore

#### 1. 在 Windows 上安装 AltServer

1. 访问 [AltStore 官网](https://altstore.io/)
2. 下载 **AltServer for Windows**
3. 安装并运行 AltServer
4. 确保安装了 **iTunes** 或 **iCloud for Windows**

#### 2. 在 iPhone 上安装 AltStore

1. 用 USB 连接 iPhone 到 Windows 电脑
2. 在 Windows 系统托盘找到 AltServer 图标
3. 右键点击 → **Install AltStore** → 选择您的 iPhone
4. 输入 Apple ID 和密码（仅用于本地签名）
5. 在 iPhone 上信任开发者证书：
   - 设置 → 通用 → VPN与设备管理 → 信任

#### 3. 保持 AltServer 运行

- AltStore 需要每 7 天重新签名
- 保持 AltServer 在 Windows 上运行
- 连接同一 Wi-Fi 时会自动刷新

---

## 📥 第四步：下载和安装 IPA

### 1. 从 GitHub Actions 下载 IPA

#### 方法 1：从 Actions 页面下载

1. 访问 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择最新的成功构建
4. 在 **Artifacts** 部分下载 `vipPolice-IPA`
5. 解压得到 `vipPolice.ipa`

#### 方法 2：从 Releases 下载（如果配置了）

1. 访问 GitHub 仓库
2. 点击 **Releases**
3. 下载最新的 `vipPolice.ipa`

### 2. 通过 AltStore 安装

#### 方法 1：通过 AltStore 应用（推荐）

1. 将 `vipPolice.ipa` 传到 iPhone
   - 通过 AirDrop
   - 通过 iCloud Drive
   - 通过其他文件传输工具

2. 在 iPhone 上：
   - 打开 **文件** App
   - 找到 `vipPolice.ipa`
   - 点击分享按钮
   - 选择 **AltStore**
   - 等待安装完成

#### 方法 2：通过 Windows 安装

1. 确保 iPhone 和 Windows 在同一 Wi-Fi
2. 在 Windows 上：
   - 右键点击系统托盘的 AltServer 图标
   - 选择 **Sideload .ipa** → 选择您的 iPhone
   - 选择 `vipPolice.ipa` 文件
   - 等待安装完成

### 3. 首次运行

1. 在 iPhone 上找到 vipPolice App
2. 点击打开
3. 如果提示"未受信任的开发者"：
   - 设置 → 通用 → VPN与设备管理
   - 点击您的 Apple ID
   - 点击"信任"

---

## 🔄 日常开发流程

### 完整工作流程

```
1. 在 Windows 上修改代码（VS Code）
   ↓
2. 提交到 GitHub
   git add .
   git commit -m "Update features"
   git push
   ↓
3. GitHub Actions 自动编译（5-10分钟）
   ↓
4. 下载新的 IPA
   ↓
5. 通过 AltStore 安装到 iPhone
   ↓
6. 测试和使用
```

### 快速命令

```bash
# 在 Windows 上修改代码后

# 1. 查看修改
git status

# 2. 添加所有修改
git add .

# 3. 提交
git commit -m "描述你的修改"

# 4. 推送到 GitHub（触发自动编译）
git push

# 5. 等待 5-10 分钟，然后访问 GitHub Actions 下载 IPA
```

---

## 💡 使用技巧

### 1. 自动化下载 IPA

创建一个 PowerShell 脚本自动下载最新的 IPA：

```powershell
# download-ipa.ps1

$repo = "YOUR_USERNAME/vipPolice"
$token = "YOUR_GITHUB_TOKEN"  # 在 GitHub Settings → Developer settings → Personal access tokens 创建

# 获取最新的 workflow run
$runs = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/actions/runs" -Headers @{Authorization="token $token"}
$latestRun = $runs.workflow_runs[0]

# 获取 artifacts
$artifacts = Invoke-RestMethod -Uri $latestRun.artifacts_url -Headers @{Authorization="token $token"}
$ipaArtifact = $artifacts.artifacts | Where-Object { $_.name -eq "vipPolice-IPA" }

# 下载
$downloadUrl = $ipaArtifact.archive_download_url
Invoke-WebRequest -Uri $downloadUrl -OutFile "vipPolice.zip" -Headers @{Authorization="token $token"}

# 解压
Expand-Archive -Path "vipPolice.zip" -DestinationPath "." -Force
Write-Host "IPA downloaded: vipPolice.ipa"
```

### 2. 设置自动刷新

在 AltStore 设置中：
- 启用 **Background Refresh**
- 保持 iPhone 和 Windows 在同一网络
- AltServer 会自动刷新签名

### 3. 使用 Git 分支

```bash
# 创建开发分支
git checkout -b develop

# 修改代码...

# 提交到开发分支
git add .
git commit -m "New feature"
git push -u origin develop

# 测试通过后，合并到主分支
git checkout main
git merge develop
git push
```

---

## ⚠️ 注意事项

### AltStore 限制

1. **7 天签名限制**
   - 免费 Apple ID 签名有效期 7 天
   - 需要定期刷新（AltServer 可自动完成）

2. **最多 3 个 App**
   - 免费 Apple ID 最多同时安装 3 个侧载 App
   - 付费开发者账号（$99/年）可安装更多

3. **需要保持连接**
   - 刷新时需要 iPhone 和 Windows 在同一网络
   - 或通过 USB 连接

### GitHub Actions 限制

1. **免费额度**
   - Public 仓库：无限制
   - Private 仓库：每月 2000 分钟

2. **构建时间**
   - 每次构建约 5-10 分钟
   - 可以手动触发或自动触发

---

## 🐛 故障排除

### 问题 1：GitHub Actions 构建失败

**解决方案**：
1. 检查 Actions 日志查看错误信息
2. 确保 `project.yml` 配置正确
3. 尝试手动触发构建

### 问题 2：AltStore 安装失败

**解决方案**：
1. 确保 iTunes 或 iCloud 已安装
2. 重启 AltServer
3. 重新连接 iPhone
4. 检查 Apple ID 是否正确

### 问题 3：App 无法打开

**解决方案**：
1. 检查是否信任了开发者证书
2. 检查签名是否过期（7天）
3. 通过 AltStore 刷新签名

### 问题 4：编译错误

**解决方案**：
1. 检查 Swift 代码语法
2. 确保所有文件都已提交
3. 查看 GitHub Actions 日志

---

## 📊 成本对比

| 方案 | 成本 | 优点 | 缺点 |
|------|------|------|------|
| **GitHub Actions + AltStore** | 免费 | 完全免费，自动化 | 7天签名限制 |
| 付费开发者账号 | $99/年 | 无限制，可上架 | 需要付费 |
| Mac 电脑 | 3000-7000元 | 完整开发环境 | 初期投资大 |

---

## 🎓 进阶配置

### 1. 添加自动测试

在 `.github/workflows/build-ios.yml` 中添加：

```yaml
- name: Run Tests
  run: |
    xcodebuild test \
      -project vipPolice.xcodeproj \
      -scheme vipPolice \
      -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 2. 添加版本号自动递增

```yaml
- name: Increment Build Number
  run: |
    buildNumber=${{ github.run_number }}
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" Info.plist
```

### 3. 发送通知

使用 GitHub Actions 的通知功能，构建完成后发送邮件或消息。

---

## 📚 相关资源

- [AltStore 官网](https://altstore.io/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [XcodeGen 文档](https://github.com/yonaskolb/XcodeGen)
- [Apple 开发者文档](https://developer.apple.com/documentation/)

---

## ✅ 检查清单

开始之前，确保：

- [ ] 已安装 Git
- [ ] 已创建 GitHub 账号
- [ ] 已安装 AltServer（Windows）
- [ ] 已安装 AltStore（iPhone）
- [ ] 已安装 iTunes 或 iCloud
- [ ] iPhone 和 Windows 可以连接
- [ ] 已准备好 Apple ID

---

## 🎉 总结

这个方案的优势：

✅ **完全免费**（除非需要付费开发者账号）
✅ **在 Windows 上开发**（使用 VS Code）
✅ **自动化编译**（GitHub Actions）
✅ **无需越狱**（AltStore 合法侧载）
✅ **持续更新**（修改代码后自动编译）

**开始您的 iOS 开发之旅吧！** 🚀
