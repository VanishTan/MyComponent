# GitLab CI/CD 迁移指南

本文档说明如何将 GitHub Actions 工作流迁移到 GitLab CI/CD。

## 📋 概述

已创建 `.gitlab-ci.yml` 文件，实现了与 GitHub Actions 工作流相同的功能：

| GitHub Actions 工作流 | GitLab CI Job | 功能说明 |
|---------------------|--------------|---------|
| `pr-check.yml` | `mr-quality-check` | MR 质量检查（Danger） |
| `ci.yml` | `ci-test` | podspec 验证测试 |
| `auto-tag.yml` | `auto-tag` | 自动创建 Tag 和 Release |
| `tag-check.yml` | `tag-validation` | Tag 格式和版本验证 |

## 🔧 关键差异对比

### 1. 触发条件

#### GitHub Actions
```yaml
on:
  pull_request:
    branches: [main]
  push:
    tags:
      - '*.*.*'
```

#### GitLab CI
```yaml
only:
  - merge_requests
  - tags
  refs:
    - main
  changes:
    - "*.podspec"
```

### 2. 环境变量

| GitHub Actions | GitLab CI | 说明 |
|---------------|-----------|------|
| `GITHUB_TOKEN` | `CI_JOB_TOKEN` / `CI_PUSH_TOKEN` | 访问令牌 |
| `GITHUB_REF` | `CI_COMMIT_REF_NAME` / `CI_COMMIT_TAG` | 分支/Tag 名称 |
| `GITHUB_SHA` | `CI_COMMIT_SHA` | 提交 SHA |
| `GITHUB_REPOSITORY` | `CI_PROJECT_PATH` | 仓库路径 |

### 3. Danger 集成

#### GitHub Actions
```yaml
env:
  DANGER_GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}
run: bundle exec danger
```

#### GitLab CI
```yaml
# 无需设置环境变量，Danger 自动识别 GitLab CI 环境
script:
  - bundle exec danger
```

**Dangerfile 已支持跨平台**（已实现）：
```ruby
# 自动检测平台
if defined?(github)
  pr_body = github.pr_body
  pr_title = github.pr_title
elsif defined?(gitlab)
  pr_body = gitlab.mr_body
  pr_title = gitlab.mr_title
end
```

### 4. 创建 Tag 和 Release

#### GitHub Actions
```yaml
- name: Create and push tag
  run: |
    git tag -a "$TAG_NAME" -m "Release version $VERSION"
    git push origin "$TAG_NAME"

- uses: actions/create-release@v1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### GitLab CI
```yaml
# 推送 Tag
- git push "https://oauth2:${CI_PUSH_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git" "$TAG_NAME"

# 创建 Release (使用 GitLab API)
- |
  curl --request POST \
    --header "PRIVATE-TOKEN: ${CI_PUSH_TOKEN}" \
    --data "tag_name=$TAG_NAME" \
    --data "name=Release v$TAG_NAME" \
    "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases"
```

## ⚙️ GitLab 配置要求

### 1. 设置项目访问令牌（推荐）

在 GitLab 项目中创建 Project Access Token：

1. 进入 **Settings** → **Access Tokens**
2. 创建新令牌，权限选择：
   - `api` - 调用 GitLab API
   - `write_repository` - 推送 Tag
3. 复制生成的令牌
4. 在 **Settings** → **CI/CD** → **Variables** 中添加：
   - Key: `CI_PUSH_TOKEN`
   - Value: `{your-token}`
   - Protected: ✅
   - Masked: ✅

### 2. 或使用个人访问令牌（备选）

如果无法使用项目令牌，可以使用个人访问令牌（PAT）：

1. 进入 GitLab 个人 **Settings** → **Access Tokens**
2. 创建令牌，范围选择 `api` + `write_repository`
3. 添加到项目 CI/CD 变量中

### 3. 配置保护分支规则（可选）

为 `main` 分支设置保护规则：

1. **Settings** → **Repository** → **Protected branches**
2. 配置 `main` 分支：
   - Allowed to merge: Maintainers
   - Allowed to push: No one (通过 MR 合并)

### 4. 配置 Merge Request 设置（推荐）

1. **Settings** → **Merge requests**
2. 启用：
   - ✅ **Enable "Delete source branch" option by default**
   - ✅ **Pipelines must succeed** (要求 CI 通过才能合并)
   - ✅ **All discussions must be resolved** (可选)

## 🚀 使用流程

### 功能开发流程

1. **创建 MR**
   ```bash
   git checkout -b feature/new-feature
   git commit -m "feat: 添加新功能"
   git push origin feature/new-feature
   ```
   → 触发 `mr-quality-check` + `ci-test`

2. **Danger 自动检查**
   - ✅ CHANGELOG 更新检查
   - ✅ 版本号更新检查
   - ✅ 提交信息格式检查
   - ✅ 文件大小检查
   - ✅ MR 描述完整性检查

3. **修复问题并推送**
   ```bash
   # 根据 Danger 提示修复问题
   git add .
   git commit -m "fix: 修复 Danger 检查问题"
   git push
   ```
   → 重新触发检查

4. **合并到 main**
   - 确保所有检查通过
   - 点击 **Merge** 按钮

### 发版流程

1. **更新版本号**（在开发分支中）
   - 修改 `*.podspec` 中的版本号
   - 在 `CHANGELOG.md` 中添加版本记录

2. **合并到 main**
   ```bash
   git checkout main
   git pull origin main
   ```
   → 触发 `auto-tag` job

3. **自动创建 Tag 和 Release**
   - ✅ 提取 podspec 版本号
   - ✅ 检查 Tag 是否已存在
   - ✅ 验证 CHANGELOG 是否包含版本记录
   - ✅ 创建 annotated tag
   - ✅ 推送 Tag 到远程
   - ✅ 创建 GitLab Release

4. **Tag 自动验证**
   → 触发 `tag-validation` job
   - ✅ 验证 Tag 格式
   - ✅ 验证 podspec 版本匹配
   - ✅ 验证 CHANGELOG 记录
   - ✅ 运行 Fastlane 预发布检查

## 📦 缓存优化

GitLab CI 使用分支级缓存加速构建：

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}  # 每个分支独立缓存
  paths:
    - vendor/bundle  # 缓存 Ruby gems
```

## 🔍 调试技巧

### 查看 CI 日志
1. 进入 **CI/CD** → **Pipelines**
2. 点击具体的 Pipeline
3. 查看每个 Job 的日志输出

### 本地测试 Danger
```bash
# GitHub 环境测试
export DANGER_GITHUB_API_TOKEN="your-token"
bundle exec danger pr https://github.com/owner/repo/pull/1

# GitLab 环境测试
export DANGER_GITLAB_API_TOKEN="your-token"
bundle exec danger --verbose
```

### 跳过 CI（紧急情况）
```bash
git commit -m "docs: 更新文档 [skip ci]"
```

## ⚠️ 注意事项

### 1. Token 权限
- `CI_PUSH_TOKEN` 需要有 `write_repository` 权限
- 确保 Token 没有过期

### 2. 保护分支
- `main` 分支建议设置为保护分支
- 只允许通过 MR 合并，禁止直接推送

### 3. 并发控制
如果需要确保 `auto-tag` job 不会并发执行：

```yaml
auto-tag:
  resource_group: production  # 同一时间只运行一个
```

### 4. 环境变量
- 敏感信息（Token、密钥）必须使用 CI/CD Variables
- 设置为 **Masked** 避免泄露到日志中

## 🆚 平台特性对比

| 特性 | GitHub Actions | GitLab CI |
|------|----------------|-----------|
| 配置文件 | `.github/workflows/*.yml` | `.gitlab-ci.yml` |
| 触发器 | `on:` | `only:` / `except:` / `rules:` |
| PR/MR | Pull Request | Merge Request |
| 环境变量 | `secrets.*` / `env.*` | CI/CD Variables |
| 缓存 | `actions/cache@v2` | `cache:` (内置) |
| 并发控制 | `concurrency:` | `resource_group:` |
| Marketplace | GitHub Actions | 无（使用 Docker/脚本） |

## 📚 参考资料

- [GitLab CI/CD 官方文档](https://docs.gitlab.com/ee/ci/)
- [Danger GitLab 集成](https://danger.systems/guides/getting_started.html#gitlab)
- [GitLab API - Releases](https://docs.gitlab.com/ee/api/releases/)
- [CI/CD Variables](https://docs.gitlab.com/ee/ci/variables/)

## ✅ 迁移清单

- [x] 创建 `.gitlab-ci.yml` 配置文件
- [x] Dangerfile 兼容 GitLab（已实现）
- [ ] 在 GitLab 项目中配置 `CI_PUSH_TOKEN`
- [ ] 测试 MR 质量检查流程
- [ ] 测试 CI 测试流程
- [ ] 测试自动打 Tag 流程
- [ ] 测试 Tag 验证流程
- [ ] 配置保护分支规则
- [ ] 更新团队文档

---

**提示**：GitLab CI 和 GitHub Actions 的核心逻辑相同，主要差异在于语法和环境变量。本配置已实现 1:1 功能对等。
