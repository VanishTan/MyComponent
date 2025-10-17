# GitHub Actions 错误修复说明

## 问题描述

GitHub Actions 在运行 `bundle install` 时出现以下错误：

```
undefined method `untaint' for "/home/runner/work/MyComponent/MyComponent":String (NoMethodError)
```

## 根本原因

1. **Ruby 版本不兼容**：CI 环境使用 Ruby 3.2.9，但项目锁定的是 Bundler 1.17.2
2. **Bundler 版本过旧**：Bundler 1.17.2 使用了在 Ruby 3.2+ 中已被移除的 `untaint` 方法
3. **自动版本选择**：`ruby/setup-ruby@v1` 的 `bundler-cache: true` 会自动使用 Gemfile.lock 中指定的 Bundler 版本

## 修复方案

### 1. 更新所有 Workflow 文件

#### CI Workflow (`.github/workflows/ci.yml`)
```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.2.9
    bundler-cache: false  # 禁用自动 Bundler 缓存

- name: Install Bundler 2.x
  run: gem install bundler -v '~> 2.0'

- name: Install dependencies
  run: |
    bundle config set --local path 'vendor/bundle'
    bundle install
```

#### PR Check Workflow (`.github/workflows/pr-check.yml`)
```yaml
- name: Setup Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.2'
    bundler-cache: false  # 禁用自动 Bundler 缓存

- name: Install Bundler 2.x
  run: gem install bundler -v '~> 2.0'

- name: Install dependencies
  run: |
    bundle config set --local path 'vendor/bundle'
    bundle install
```

#### Tag Check Workflow (`.github/workflows/tag-check.yml`)
```yaml
- name: Setup Ruby and Bundler
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.2'
    bundler-cache: false  # 禁用自动 Bundler 缓存

- name: Install Bundler 2.x
  run: gem install bundler -v '~> 2.0'

- name: Install dependencies
  run: |
    bundle config set --local path 'vendor/bundle'
    bundle install
```

### 2. 更新 Gemfile.lock

将 `BUNDLED WITH` 版本从 `1.17.2` 更新为 `2.4.22`：

```
BUNDLED WITH
   2.4.22
```

### 3. 关键修复点

1. **禁用 bundler-cache**：设置 `bundler-cache: false` 防止自动使用旧版本
2. **显式安装 Bundler 2.x**：在安装依赖前先安装兼容的 Bundler 版本
3. **设置本地路径**：使用 `bundle config set --local path 'vendor/bundle'` 确保依赖安装在正确位置

## 版本兼容性

| Ruby 版本 | 推荐 Bundler 版本 | 状态 |
|-----------|------------------|------|
| 2.6.x - 3.1.x | 1.17.2 | ✅ 兼容 |
| 3.2.x+ | 2.0+ | ✅ 兼容 |

## 测试验证

运行测试脚本验证修复：

```bash
./test-ci.sh
```

## 注意事项

1. **本地开发**：如果本地使用 Ruby 2.6.x，需要保持 Bundler 1.17.2
2. **CI 环境**：确保 CI 环境使用 Ruby 3.2+ 和 Bundler 2.x
3. **版本锁定**：Gemfile.lock 现在锁定 Bundler 2.4.22，确保 CI 环境一致性

## 预期结果

修复后，GitHub Actions 应该能够：
- ✅ 成功安装 Bundler 2.x
- ✅ 成功运行 `bundle install`
- ✅ 正常执行所有 CI 步骤
- ✅ 不再出现 `untaint` 方法错误
