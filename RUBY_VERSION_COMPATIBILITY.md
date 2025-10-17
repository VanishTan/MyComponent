# Ruby 版本兼容性说明

## 问题描述

在 Ruby 3.2+ 版本中，`untaint` 方法已被移除，但 Bundler 1.17.2 仍在使用此方法，导致以下错误：

```
undefined method `untaint' for "/path/to/project":String (NoMethodError)
```

## 解决方案

### 方案1：在 CI 环境中使用 Bundler 2.x（推荐）

在 CI 配置中，确保使用与 Ruby 3.2+ 兼容的 Bundler 版本：

```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.2.9
    bundler-cache: true

- name: Install dependencies
  run: |
    gem install bundler -v '~> 2.0'
    bundle config set --local path 'vendor/bundle'
    bundle install
```

### 方案2：使用 Ruby 版本管理器

如果你需要在本地开发环境中使用 Ruby 3.2+：

```bash
# 使用 rbenv
rbenv install 3.2.9
rbenv local 3.2.9

# 或使用 rvm
rvm install 3.2.9
rvm use 3.2.9

# 然后重新安装依赖
bundle install
```

### 方案3：降级 Ruby 版本

如果项目必须使用 Bundler 1.17.2，可以降级到 Ruby 3.1 或更早版本：

```bash
# 使用 rbenv
rbenv install 3.1.6
rbenv local 3.1.6

# 或使用 rvm
rvm install 3.1.6
rvm use 3.1.6
```

## 版本兼容性表

| Ruby 版本 | 推荐 Bundler 版本 | 说明 |
|-----------|------------------|------|
| 2.6.x - 3.1.x | 1.17.2 | 稳定兼容 |
| 3.2.x+ | 2.0+ | 必须使用 Bundler 2.x |

## 注意事项

1. 确保 CI 环境和本地开发环境使用相同的 Ruby 和 Bundler 版本
2. 在 `.ruby-version` 文件中指定 Ruby 版本
3. 定期更新依赖以保持安全性
