#!/bin/bash

# MyComponent 发版脚本
# 使用方法: ./release.sh <version>
# 示例: ./release.sh 1.2.3

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -eq 0 ]; then
    log_error "请提供版本号"
    echo "使用方法: $0 <version>"
    echo "示例: $0 1.2.3"
    exit 1
fi

VERSION=$1
PODSPEC_FILE="MyComponent.podspec"

# 验证版本号格式
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
    log_error "版本号格式错误，请使用格式: MAJOR.MINOR.PATCH[-PRERELEASE]"
    echo "示例: 1.2.3 或 1.2.3-beta.1"
    exit 1
fi

log_info "开始发版流程，版本号: $VERSION"

# 检查工作区状态
if [ -n "$(git status --porcelain)" ]; then
    log_warning "工作区有未提交的更改，请先提交或暂存"
    git status --short
    exit 1
fi

# 检查tag是否已存在
if git tag -l | grep -q "^v$VERSION$"; then
    log_error "Tag v$VERSION 已存在，请使用新的版本号"
    exit 1
fi

# 检查CHANGELOG是否已更新
if ! grep -q "\[$VERSION\]" CHANGELOG.md; then
    log_error "请在 CHANGELOG.md 中添加版本 $VERSION 的更新日志"
    exit 1
fi

log_info "✅ 发版前检查通过"

# 询问用户确认
echo
log_warning "即将发布版本 v$VERSION，请确认:"
echo "1. 版本号: $VERSION"
echo "2. CHANGELOG 已更新"
echo "3. 所有测试已通过"
echo
read -p "确认继续? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "发版已取消"
    exit 0
fi

# 更新podspec版本号
log_info "更新 podspec 版本号..."
sed -i '' "s/s.version *= *\"[0-9.]\\+\"/s.version = \"$VERSION\"/" $PODSPEC_FILE

# 验证podspec
log_info "验证 podspec 文件..."
if command -v pod >/dev/null 2>&1; then
    pod spec lint $PODSPEC_FILE --allow-warnings
    log_success "podspec 验证通过"
else
    log_warning "未安装 CocoaPods，跳过验证"
fi

# 提交更改
log_info "提交版本更改..."
git add $PODSPEC_FILE CHANGELOG.md
git commit -m "chore: prepare release v$VERSION"

# 创建tag
log_info "创建并推送 tag..."
git tag v$VERSION
git push origin main
git push origin v$VERSION

log_success "✅ 版本 v$VERSION 已成功创建并推送"

# 询问是否使用Fastlane发布
if command -v fastlane >/dev/null 2>&1; then
    echo
    read -p "是否使用 Fastlane 发布到私有仓库? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "使用 Fastlane 发布..."
        fastlane release version:$VERSION
        log_success "✅ 版本 v$VERSION 已发布到私有仓库"
    fi
else
    log_warning "未安装 Fastlane，请手动发布到私有仓库"
    echo "命令: pod repo push MyPrivateSpecs $PODSPEC_FILE --allow-warnings"
fi

# 完成
echo
log_success "🎉 发版完成！"
echo "版本: v$VERSION"
echo "Tag: https://github.com/VanishTan/MyComponent/releases/tag/v$VERSION"
echo
log_info "下一步:"
echo "1. 检查 GitHub Actions 自动发版状态"
echo "2. 验证组件可以正常安装和使用"
echo "3. 更新相关文档"
