# Gemfile.lock 更新说明

## 📝 更新内容

### 1. 升级 activesupport
- **旧版本**: 6.1.7.10
- **新版本**: 7.2.2
- **原因**: Gemfile 中要求 `activesupport >= 7.0.0`

### 2. 新增依赖包
activesupport 7.2.2 引入的新依赖：
- `benchmark (0.4.0)`
- `bigdecimal (3.1.8)`
- `connection_pool (2.4.1)`
- `drb (2.2.1)`
- `securerandom (0.4.1)`
- `uri (1.0.2)`

### 3. 更新 DEPENDENCIES 部分
```diff
DEPENDENCIES
+ activesupport (>= 7.0.0)
+ cocoapods (>= 1.16.0)
- cocoapods
  danger
  fastlane
```

### 4. 更新 Bundler 版本
```diff
BUNDLED WITH
-  2.4.22
+  2.5.22
```

## ✅ 验证

当前 Gemfile.lock 状态：
- ✅ activesupport: 7.2.2
- ✅ cocoapods: 1.16.2
- ✅ Bundler: 2.5.22
- ✅ 所有新依赖已添加

## 🚀 下一步

**立即提交并推送**：

```bash
git add Gemfile Gemfile.lock
git commit -m "fix: 更新 Gemfile.lock 以匹配 Gemfile 的依赖版本要求

- 升级 activesupport 从 6.1.7.10 到 7.2.2
- 添加 activesupport 7.2.2 需要的新依赖
- 更新 Bundler 版本从 2.4.22 到 2.5.22
- 锁定 cocoapods >= 1.16.0 和 activesupport >= 7.0.0"
git push
```

提交后，CI 会：
1. 拉取新的 Gemfile.lock
2. 清除旧的缓存
3. 使用正确的依赖版本
4. 构建应该会成功通过 ✅

## 🔍 为什么之前失败？

CI 错误信息：
```
The dependencies in your gemfile changed, but the lockfile can't be updated
because frozen mode is set
```

**原因**：
1. Gemfile 已修改（添加了版本约束）
2. 但 Gemfile.lock 还是旧的（未匹配）
3. CI 处于 frozen mode，不允许自动更新 Gemfile.lock
4. 因此需要手动更新 Gemfile.lock 并提交

**现在已解决**：Gemfile 和 Gemfile.lock 已同步！
