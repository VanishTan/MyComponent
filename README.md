# MyComponent

[![CI Status](https://github.com/VanishTan/MyComponent/workflows/CI/badge.svg)](https://github.com/VanishTan/MyComponent/actions)
[![Version](https://img.shields.io/cocoapods/v/MyComponent.svg?style=flat)](https://cocoapods.org/pods/MyComponent)
[![License](https://img.shields.io/cocoapods/l/MyComponent.svg?style=flat)](https://cocoapods.org/pods/MyComponent)
[![Platform](https://img.shields.io/cocoapods/p/MyComponent.svg?style=flat)](https://cocoapods.org/pods/MyComponent)

一个用于测试iOS组件发版自动化流程的示例组件。

## 🎯 项目目标

- 所有组件独立发版、独立维护
- 发版过程无人值守、一键触发
- 保证组件间版本兼容性与依赖关系稳定
- 提供版本追踪、回滚与日志机制

## 📦 安装

### CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'MyComponent', '~> 1.0.0'
```

然后运行：

```bash
pod install
```

### Swift Package Manager

在 Xcode 中添加包依赖：

```
https://github.com/VanishTan/MyComponent.git
```

## 🚀 快速开始

```swift
import MyComponent

// 使用示例组件
let component = MyComponent()
component.configure()
```

## 📋 版本管理

### 版本号规范

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

- **MAJOR**: 不兼容的API变更
- **MINOR**: 向下兼容的功能新增  
- **PATCH**: 向下兼容的Bug修复

### 发版流程

#### 1. 本地发版

```bash
# 安装依赖
bundle install

# 执行发版前检查
fastlane pre_release_check version:1.2.3

# 自动发版
fastlane release version:1.2.3 repo_name:MyPrivateSpecs
```

#### 2. 自动发版（推荐）

```bash
# 创建并推送tag触发自动发版
git tag v1.2.3
git push origin v1.2.3
```

#### 3. 手动发版

在 GitHub Actions 中手动触发 `iOS Component Release` 工作流。

### 回滚版本

```bash
fastlane rollback version:1.2.3
```

## 🔧 开发指南

### 分支管理

- `main`: 线上稳定分支
- `dev`: 开发主分支
- `feature/*`: 新功能分支
- `hotfix/*`: 紧急修复分支
- `release/*`: 发版准备分支

### 提交规范

使用规范的提交信息格式：

```
type(scope): description

feat(login): 添加登录功能
fix(auth): 修复认证问题
docs(readme): 更新安装说明
```

支持的类型：`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### 变更日志

每次发版前必须更新 `CHANGELOG.md` 文件，记录所有变更内容。

## 🛠️ 技术栈

- **语言**: Swift 5.0+
- **平台**: iOS 12.0+
- **依赖管理**: CocoaPods
- **自动化**: Fastlane + GitHub Actions
- **代码检查**: Danger
- **测试**: XCTest

## 📁 项目结构

```
MyComponent/
├── Sources/                 # 源代码
│   └── MyComponent/
├── Tests/                   # 测试代码
├── .github/
│   ├── workflows/          # GitHub Actions 配置
│   └── pull_request_template.md
├── MyComponent.podspec     # CocoaPods 配置
├── Fastfile               # Fastlane 配置
├── Dangerfile             # Danger 配置
├── CHANGELOG.md           # 变更日志
└── README.md              # 项目说明
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### PR 检查

每个 PR 都会自动执行以下检查：

- ✅ 代码规范检查
- ✅ 单元测试验证
- ✅ CHANGELOG 更新检查
- ✅ 版本号变更检查
- ✅ 文件大小检查

## 📄 许可证

本项目使用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- 作者: VanishTan
- 邮箱: your-email@example.com
- 项目链接: [https://github.com/VanishTan/MyComponent](https://github.com/VanishTan/MyComponent)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

## 📚 相关文档

- [iOS 组件版本管理与自动化发版规范](./_iOS%20组件版本管理与自动化发版规范.md)
- [CHANGELOG](./CHANGELOG.md)
- [CocoaPods 文档](https://guides.cocoapods.org/)
- [Fastlane 文档](https://docs.fastlane.tools/)
