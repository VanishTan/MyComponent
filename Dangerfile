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
  podspec_files = git.modified_files.select { |file| file.end_with?(".podspec") }
  
  if !podspec_files.empty?
    podspec_files.each do |podspec|
      # 检查版本号是否发生变化
      old_version = git.diff_for_file(podspec).patch.scan(/s\.version\s*=\s*["']([^"']+)["']/).flatten.first
      new_version = File.read(podspec).scan(/s\.version\s*=\s*["']([^"']+)["']/).flatten.first
      
      if old_version && new_version && old_version != new_version
        message("🎯 版本号已从 #{old_version} 更新到 #{new_version}")
      end
    end
  end
end

# 检查提交信息格式
def check_commit_messages
  bad_commits = git.commits.select { |commit| 
    commit.message.lines.first.length < 10 || 
    !commit.message.match?(/^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: /)
  }
  
  if bad_commits.any?
    warn("📋 请使用规范的提交信息格式: `type(scope): description`")
    warn("支持的类型: feat, fix, docs, style, refactor, test, chore")
    
    bad_commits.each do |commit|
      warn("❌ 提交信息不规范: `#{commit.message.lines.first}`")
    end
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
