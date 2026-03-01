@echo off
REM vipPolice - GitHub 快速设置脚本
REM 用于 Windows 系统

echo ========================================
echo vipPolice GitHub 快速设置
echo ========================================
echo.

REM 检查 Git 是否安装
git --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Git，请先安装 Git for Windows
    echo 下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo [1/6] 初始化 Git 仓库...
git init
if errorlevel 1 (
    echo [错误] Git 初始化失败
    pause
    exit /b 1
)

echo [2/6] 添加所有文件...
git add .
if errorlevel 1 (
    echo [错误] 添加文件失败
    pause
    exit /b 1
)

echo [3/6] 创建初始提交...
git commit -m "Initial commit: vipPolice iOS App"
if errorlevel 1 (
    echo [错误] 提交失败
    pause
    exit /b 1
)

echo.
echo [4/6] 请在 GitHub 上创建新仓库
echo.
echo 步骤:
echo 1. 访问 https://github.com/new
echo 2. 仓库名: vipPolice
echo 3. 设置为 Public (免费使用 GitHub Actions)
echo 4. 不要初始化 README、.gitignore 或 license
echo 5. 点击 "Create repository"
echo.
pause

echo.
set /p username="[5/6] 请输入您的 GitHub 用户名: "
if "%username%"=="" (
    echo [错误] 用户名不能为空
    pause
    exit /b 1
)

echo [6/6] 关联远程仓库并推送...
git branch -M main
git remote add origin https://github.com/%username%/vipPolice.git
git push -u origin main

if errorlevel 1 (
    echo.
    echo [错误] 推送失败，可能的原因:
    echo 1. GitHub 仓库未创建
    echo 2. 用户名错误
    echo 3. 需要配置 Git 凭据
    echo.
    echo 请手动执行以下命令:
    echo git remote add origin https://github.com/%username%/vipPolice.git
    echo git push -u origin main
    pause
    exit /b 1
)

echo.
echo ========================================
echo 设置完成！
echo ========================================
echo.
echo 下一步:
echo 1. 访问 https://github.com/%username%/vipPolice
echo 2. 点击 "Actions" 标签查看构建状态
echo 3. 等待 5-10 分钟完成编译
echo 4. 下载 IPA 文件并通过 AltStore 安装
echo.
echo 详细说明请查看: WINDOWS_GITHUB_ALTSTORE.md
echo.
pause
