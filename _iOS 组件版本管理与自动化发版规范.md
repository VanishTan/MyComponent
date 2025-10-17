目标
- 所有组件 独立发版、独立维护
- 发版过程 无人值守、一键触发
- 保证组件间版本 兼容性与依赖关系稳定
- 提供 版本追踪、回滚与日志机制
版本号规范
MAJOR.MINOR.PATCH[-PRERELEASE]
示例：
级别
说明
示例
触发场景
MAJOR
不兼容的API变更
1.0.0 → 2.0.0
方法签名变动、接口参数修改、移除旧功能
MINOR
向下兼容的功能新增
1.0.0 → 1.1.0
新增方法、属性、UI模块
PATCH
向下兼容的Bug修复
1.0.0 → 1.0.1
修复崩溃、逻辑错误、小优化
PRERELEASE
测试版
1.2.3-beta.1
测试中版本
分支管理规范
使用 Git Flow 或简化版分支模型：
分支
说明
命名规则
示例
main
线上稳定分支
main
main
dev
开发主分支
dev
dev
feature/
新功能分支
feature/模块名
feature/login-view
hotfix/
紧急修复分支
hotfix/问题描述
hotfix/fix-crash-when-login
release/
发版准备分支
release/x.y.z
release/1.2.0
流程图示：
暂时无法在飞书文档外展示此内容
版本号管理规则
版本号记录方式
组件版本号统一维护在 *.podspec 文件中，例：
s.version = '1.2.3'
SPM不需要记录版本号，是根据 git tag 管理。
变更控制
- 每次变更必须在 PR 或提交说明中附上：
  - CHANGELOG 更新
  - 版本号变更（如 podspec 内 version 修改）
 CHANGELOG 模板
## [1.2.3] - 2025-10-16
### Added
- 新增用户卡片组件支持圆角裁剪

### Fixed
- 修复 iOS 17 上图片拉伸问题

### Changed
- 优化缓存逻辑，减少内存占用
优点：git log  拉取日志整理的时候清晰可见
自动化发版
发版流程
暂时无法在飞书文档外展示此内容
发版方式
一、发版命令（CI/CD 自动化）
1. 本地命令（示例）
可使用 Fastlane 或自定义脚本发版，例如：
fastlane release version:1.2.3 podspec:CoreKit.podspec
2. Fastlane 示例配置
default_platform(:ios)

platform :ios do
  desc "自动更新版本、打tag并发布到私有仓库"
  lane :release do |options|
    version = options[:version]
    podspec = options[:podspec] || Dir.glob("*.podspec").first
    repo_name = "MyPrivateSpecs"

    UI.message("📦 Releasing #{podspec} v#{version}")

    # 1. 修改 podspec 版本
    sh "sed -i '' 's/s.version *= *\"[0-9.]\\+\"/s.version = \"#{version}\"/' #{podspec}"

    # 2. 提交、打tag
    sh "git add #{podspec} CHANGELOG.md"
    sh "git commit -m 'Release #{version}'"
    sh "git tag v#{version}"
    sh "git push origin main --tags"

    # 3. 发布
    sh "pod repo push #{repo_name} #{podspec} --allow-warnings --verbose"
  end
end

二、GitHub Actions 自动发版流程
示例 .github/workflows/release.yml：
name: iOS Component Release

on:
  push:
    tags:
      - '*.*.*'

jobs:
  release:
    runs-on: macos-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'

      - name: Install CocoaPods
        run: gem install cocoapods

      - name: Publish Pod
        run: |
          pod repo push MyPrivateSpecs MyComponent.podspec --allow-warnings
触发方式：
git tag 1.2.3
git push origin 1.2.3
回滚与应急策略
场景
操作步骤
组件版本错误
删除 tag git tag -d 1.2.3 && git push origin :1.2.3
线上崩溃
建立 hotfix/xxx → 修复 → 1.2.4
依赖冲突
回退依赖版本，重新打 tag 发布
发布失败
检查私有 repo 状态，执行 pod repo push 手动补发
辅助工具
工具
作用
备注
Fastlane
自动化构建与发版
最推荐
GitHub Actions / GitLab CI
CI/CD 自动发布
与 tag 结合
danger
PR 自动检查是否更新 CHANGELOG
防漏发版日志
总结
项
规则
PR 必须包含模板信息
.github/pull_request_template.md
Danger 自动检查版本号/CHANGELOG
防止漏发版
CI 集成 Danger
pull_request 事件触发
所有警告必须在 PR 处理完再合并
保障质量
可配合 SwiftLint / Fastlane 联动
一站式自动化
