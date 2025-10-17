# CI/CD 配置使用指南

## 🎯 已完成的配置

### 1. GitHub Actions 工作流
- **PR检查工作流** (`.github/workflows/pr-check.yml`)
  - 自动检查PR质量
  - 验证版本号格式和递增
  - 检查提交信息规范
  - 验证CHANGELOG更新

- **Tag版本检查工作流** (`.github/workflows/tag-check.yml`)
  - 验证tag格式 (v1.2.3)
  - 检查podspec版本与tag匹配
  - 验证CHANGELOG包含版本记录

### 2. 增强的Dangerfile
- ✅ 版本号格式验证 (MAJOR.MINOR.PATCH[-PRERELEASE])
- ✅ 版本号递增检查
- ✅ 提交信息规范检查 (conventional commits)
- ✅ CHANGELOG更新检查
- ✅ 文件大小检查
- ✅ Swift代码质量检查

### 3. PR模板
- 标准化的PR描述模板
- 变更类型选择
- 检查清单

## 🚀 如何使用

### 提交Pull Request时
1. 创建PR时会自动触发质量检查
2. 确保所有检查都通过后再合并
3. 使用规范的提交信息格式：
   ```
   feat(auth): 添加用户登录功能
   fix(ui): 修复按钮点击问题
   docs: 更新API文档
   ```

### 发布新版本时
1. 更新 `MyComponent.podspec` 中的版本号
2. 更新 `CHANGELOG.md` 添加版本记录
3. 创建并推送tag：
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```
4. GitHub Actions会自动验证版本格式和一致性

## 📋 提交信息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**支持的类型：**
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式化
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具
- `perf`: 性能优化
- `ci`: CI/CD相关

**示例：**
```
feat(auth): 添加OAuth登录支持
fix(ui): 修复按钮在iOS 17上的显示问题
docs: 更新README中的安装说明
chore: 更新依赖版本
```

## 🔧 版本号规范

使用 [Semantic Versioning](https://semver.org/) 格式：

```
MAJOR.MINOR.PATCH[-PRERELEASE]
```

**示例：**
- `1.0.0` - 正式版本
- `1.2.3` - 补丁版本
- `1.2.3-beta.1` - 预发布版本

## 🎛️ GitHub仓库设置

### 分支保护规则
1. 进入 Settings → Branches
2. 添加保护规则给main分支
3. 启用：
   - ✅ "Require status checks to pass before merging"
   - ✅ "Require branches to be up to date before merging"
   - 选择 "PR Quality Check" 检查

### 权限设置
1. 确保GitHub Actions有权限访问仓库
2. 设置 `GITHUB_TOKEN` 权限（通常自动配置）

## 🐛 故障排除

### PR检查失败
1. 检查提交信息格式
2. 确保更新了CHANGELOG.md
3. 检查版本号格式和递增
4. 查看GitHub Actions日志获取详细错误信息

### Tag验证失败
1. 检查tag格式是否为 `v1.2.3`
2. 确保podspec版本与tag匹配
3. 确保CHANGELOG.md包含版本记录

### 本地测试
```bash
# 检查配置语法
ruby -c Dangerfile

# 安装依赖
bundle install

# 推送代码到GitHub后测试PR检查
```

## 📞 支持

如果遇到问题：
1. 查看GitHub Actions日志
2. 检查Dangerfile配置
3. 参考 [Danger官方文档](https://danger.systems/ruby/)
4. 参考 [GitHub Actions文档](https://docs.github.com/en/actions)
