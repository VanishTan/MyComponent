# CocoaPods 版本问题修复

## 问题描述

CI 构建失败，报错：
```
undefined method `swift_versions=' for #<Pod::Specification name="MyComponent">
```

## 根本原因

1. **CI 环境使用了错误的 CocoaPods 版本**
   - 错误日志显示使用的是 `cocoapods-1.0.1`（2016年的旧版本）
   - `swift_versions` 属性在 CocoaPods 1.4.0+ 才引入
   
2. **CI 工作流中删除了 Gemfile.lock**
   ```yaml
   - name: Install dependencies
     run: |
       rm -f Gemfile.lock  # ❌ 删除了版本锁定文件
       bundle install
   ```
   
3. **Gemfile 中未指定 CocoaPods 版本**
   ```ruby
   gem "cocoapods"  # ❌ 没有版本约束
   ```

当删除 `Gemfile.lock` 后，Bundler 重新解析依赖，可能安装了不兼容的旧版本。

## 修复方案

### ✅ 1. 在 Gemfile 中锁定 CocoaPods 版本

**文件**: `Gemfile`

```ruby
gem "cocoapods", ">= 1.16.0"  # 指定最低版本
```

### ✅ 2. 不要删除 Gemfile.lock

**文件**: `.github/workflows/ci.yml` 和 `.github/workflows/pr-check.yml`

**修改前**:
```yaml
- name: Install dependencies
  run: |
    rm -f Gemfile.lock        # ❌ 删除版本锁定
    bundle install
```

**修改后**:
```yaml
- name: Install dependencies
  run: |
    bundle install            # ✅ 使用 Gemfile.lock 中的版本
```

### ✅ 3. 启用 bundler-cache

**修改前**:
```yaml
- name: Setup Ruby
  uses: ruby/setup-ruby@v1
  with:
    bundler-cache: false
```

**修改后**:
```yaml
- name: Setup Ruby
  uses: ruby/setup-ruby@v1
  with:
    bundler-cache: true      # ✅ 启用缓存，提升 CI 速度
```

## 为什么不应该删除 Gemfile.lock？

### ❌ 删除 Gemfile.lock 的问题

1. **版本不一致**: 每次 CI 运行可能安装不同版本的依赖
2. **难以重现问题**: 本地环境和 CI 环境使用不同的依赖版本
3. **潜在的兼容性问题**: 新版本的依赖可能引入破坏性变更
4. **构建不稳定**: 同样的代码，不同时间构建可能得到不同结果

### ✅ 保留 Gemfile.lock 的优势

1. **版本锁定**: 确保所有环境使用相同版本的依赖
2. **构建稳定**: 相同代码在任何时间、任何环境构建结果一致
3. **问题可重现**: 本地和 CI 环境完全一致
4. **安全性**: 避免意外引入未经测试的新版本

## Bundler 最佳实践

### 正确的工作流程

1. **本地开发**:
   ```bash
   bundle install           # 安装依赖
   bundle update cocoapods  # 需要更新时显式执行
   git add Gemfile.lock     # 提交锁定文件
   ```

2. **CI 环境**:
   ```yaml
   - uses: ruby/setup-ruby@v1
     with:
       bundler-cache: true  # 使用 Gemfile.lock
   - run: bundle install    # 安装锁定的版本
   ```

3. **更新依赖**:
   ```bash
   # 更新所有依赖
   bundle update
   
   # 只更新特定 gem
   bundle update cocoapods
   
   # 提交更新后的 Gemfile.lock
   git add Gemfile Gemfile.lock
   git commit -m "chore: update cocoapods to 1.16.2"
   ```

## 验证修复

修复后，CI 应该使用正确的 CocoaPods 版本：

```bash
# 在 CI 日志中应该看到
cocoapods-1.16.2 (instead of cocoapods-1.0.1)
```

## 相关配置

- **Gemfile**: 锁定 CocoaPods >= 1.16.0
- **Gemfile.lock**: CocoaPods 1.16.2
- **podspec**: 使用 `spec.swift_versions = ["5.0"]` (CocoaPods 1.4.0+)

## 参考资料

- [CocoaPods Changelog](https://github.com/CocoaPods/CocoaPods/releases)
- [Bundler Best Practices](https://bundler.io/guides/rationale.html)
- [Ruby Setup Action](https://github.com/ruby/setup-ruby)
