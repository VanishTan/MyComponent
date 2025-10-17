# Dangerfile - 自动检查 PR 质量

# 检查是否更新了 CHANGELOG
def check_changelog
  has_changelog = git.modified_files.include?("CHANGELOG.md")
  
  if !has_changelog && !git.modified_files.empty?
    warn("📝 请更新 CHANGELOG.md 文件，记录本次变更的内容")
  end
end

# 检查版本号是否更新
def check_version_update
  # 获取所有 podspec 文件
  all_podspec_files = Dir.glob("*.podspec")
  modified_podspec_files = git.modified_files.select { |file| file.end_with?(".podspec") }
  
  # 排除的文件列表
  excluded_files = ["CHANGELOG.md", "README.md", "Dangerfile"]
  
  # 检查是否有实质性的代码变更（排除文档、注释等）
  code_files = git.modified_files.reject { |file|
    # 排除特定文件
    excluded_files.include?(file) ||
    # 排除 .github 目录下的文件
    file.start_with?(".github/") ||
    # 排除文档文件
    file.end_with?(".md")
  }.select { |file|
    # 只保留代码文件
    file.end_with?(".swift", ".m", ".h", ".podspec", ".xib", ".storyboard")
  }
  
  has_code_changes = !code_files.empty?
  
  # 调试信息
  if has_code_changes
    message("📋 检测到代码文件变更:")
    code_files.each { |file| message("  - #{file}") }
  end
  
  # 情况1: podspec 文件被修改了
  if !modified_podspec_files.empty?
    modified_podspec_files.each do |podspec|
      # 检查版本号是否发生变化
      diff = git.diff_for_file(podspec)
      next unless diff
      
      # 兼容 s.version 和 spec.version 两种写法
      old_version = diff.patch.scan(/-\s*(?:s|spec)\.version\s*=\s*["']([^"']+)["']/).flatten.first
      new_version = File.read(podspec).scan(/(?:s|spec)\.version\s*=\s*["']([^"']+)["']/).flatten.first
      
      if old_version && new_version && old_version != new_version
        # 检查版本号格式
        unless new_version.match?(/^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?$/)
          fail("📋 版本号格式错误，请使用: MAJOR.MINOR.PATCH[-PRERELEASE] (当前: #{new_version})")
        end
        
        # 检查版本号是否递增
        unless version_greater_than(new_version, old_version)
          fail("📈 版本号必须递增！当前: #{old_version}, 新版本: #{new_version}")
        end
        
        message("🎯 版本号已从 #{old_version} 更新到 #{new_version}")
      elsif old_version && new_version && old_version == new_version
        warn("⚠️ podspec 文件已修改，但版本号未变化 (#{new_version})")
      end
    end
  # 情况2: 有代码变更，但 podspec 没有被修改
  elsif has_code_changes && !all_podspec_files.empty?
    # 兼容 s.version 和 spec.version 两种写法
    current_version = File.read(all_podspec_files.first).scan(/(?:s|spec)\.version\s*=\s*["']([^"']+)["']/).flatten.first
    
    fail("❌ 检测到代码变更，但 podspec 版本号未更新！")
    fail("📌 当前版本: #{current_version}")
    fail("")
    fail("💡 请更新 podspec 中的版本号，遵循语义化版本规范：")
    fail("   - 主版本号 (X.0.0): 不兼容的 API 修改")
    fail("   - 次版本号 (0.X.0): 向下兼容的功能性新增")
    fail("   - 修订号 (0.0.X): 向下兼容的问题修正")
    fail("")
    fail("📝 修改文件: #{all_podspec_files.first}")
  end
  end
end

# 版本号比较辅助方法
def version_greater_than(version1, version2)
  begin
    Gem::Version.new(version1) > Gem::Version.new(version2)
  rescue ArgumentError
    false
  end
end

# 检查提交信息格式
def check_commit_messages
  bad_commits = []
  
  git.commits.each do |commit|
    message = commit.message.lines.first
    
    # 跳过 merge commit
    next if message.start_with?("Merge branch", "Merge pull request")
    
    # 检查基本格式 (scope 可选，冒号后空格可选)
    unless message.match?(/^(feat|fix|docs|style|refactor|test|chore|perf|ci|build)(\([^)]+\))?:\s*.+/)
      bad_commits << { commit: commit, reason: "格式不符合conventional commits规范" }
      next
    end
    
    # 检查描述长度
    description = message.split(':', 2)[1]&.strip
    if description.nil? || description.length < 3
      bad_commits << { commit: commit, reason: "描述太简短(至少3个字符)" }
      next
    end
    
    # 检查是否以句号结尾(可选)
    if description.end_with?('.')
      warn("💡 建议: 提交信息描述不需要以句号结尾")
    end
  end
  
  if bad_commits.any?
    fail("📋 发现 #{bad_commits.length} 个提交信息不符合规范！")
    warn("⚠️\t请使用格式: type: description 或 type:description")
    warn("⚠️\t支持的类型: feat, fix, docs, style, refactor, test, chore, perf, ci, build")
    warn("⚠️\tscope 为可选项，如 type(scope): description")
    warn("⚠️\t冒号后的空格可选")
    warn("")
    
    bad_commits.each do |item|
      commit = item[:commit]
      reason = item[:reason]
      warn("❌ #{commit.sha[0..7]}: #{commit.message.lines.first}")
      warn("   原因: #{reason}")
    end
    
    warn("")
    warn("💡 示例:")
    warn("   feat(auth): 添加用户登录功能")
    warn("   fix: 修复按钮点击问题")
    warn("   docs:更新API文档")
  else
    message("✅ 所有提交信息格式正确")
  end
end

# 检查文件大小
def check_file_sizes
  large_files = git.modified_files.select { |file|
    File.exist?(file) && File.size(file) > 100 * 1024 # 100KB
  }
  
  if large_files.any?
    warn("📦 检测到大文件，请确认是否需要添加到仓库中:")
    large_files.each { |file| warn("- #{file} (#{File.size(file) / 1024}KB)") }
  end
end

# 检查 Swift 代码规范
def check_swift_code
  swift_files = git.modified_files.select { |file| file.end_with?(".swift") }
  
  if swift_files.any?
    # 检查是否有 TODO 或 FIXME
    swift_files.each do |file|
      content = File.read(file)
      if content.include?("TODO") || content.include?("FIXME")
        warn("⚠️ #{file} 包含 TODO 或 FIXME，请确认是否需要处理")
      end
    end
  end
end

# 检查 PR 标题和描述
def check_pr_info
  if github.pr_body.length < 20
    warn("📝 PR 描述太简短，请详细说明本次变更的内容和原因")
  end
  
  if github.pr_title.length < 10
    warn("📋 PR 标题太简短，请使用更描述性的标题")
  end
end

# 执行所有检查
check_changelog
check_version_update
check_commit_messages
check_file_sizes
check_swift_code
check_pr_info

# 成功提示
if git.modified_files.any?
  message("✅ 感谢您的贡献！请确保所有检查都通过后再合并 PR。")
end
