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
        warn("⚠️ 版本号未发生变化，请确认是否需要更新版本")
      end
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
