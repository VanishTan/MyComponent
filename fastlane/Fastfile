# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
#     https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
#     https://docs.fastlane.tools/plugins/available-plugins
#

default_platform(:ios)

platform :ios do
  desc "自动更新版本、打tag并发布到私有仓库"
  lane :release do |options|
    version = options[:version]
    podspec = options[:podspec] || Dir.glob("*.podspec").first
    repo_name = options[:repo_name] || "MyPrivateSpecs"

    UI.message("📦 Releasing #{podspec} v#{version}")

    # 1. 检查版本号格式
    unless version.match?(/^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?$/)
      UI.user_error!("版本号格式错误，请使用格式：MAJOR.MINOR.PATCH[-PRERELEASE]")
    end

    # 2. 检查tag是否已存在
    if git_tag_exists(tag: "v#{version}")
      UI.user_error!("Tag v#{version} 已存在，请使用新的版本号")
    end

    # 3. 修改 podspec 版本
    UI.message("🔧 更新 podspec 版本号...")
    sh "sed -i '' 's/s.version *= *\"[0-9.]\\+\"/s.version = \"#{version}\"/' #{podspec}"

    # 4. 验证podspec文件
    UI.message("✅ 验证 podspec 文件...")
    sh "pod spec lint #{podspec} --allow-warnings"

    # 5. 检查工作区状态
    UI.message("📋 检查工作区状态...")
    unless git_status_clean
      UI.message("⚠️  工作区有未提交的更改，将自动提交...")
      sh "git add ."
      sh "git commit -m 'chore: prepare release v#{version}'"
    end

    # 6. 创建并推送tag
    UI.message("🏷️  创建并推送 tag...")
    sh "git tag v#{version}"
    sh "git push origin main --tags"

    # 7. 发布到私有仓库
    UI.message("🚀 发布到私有仓库...")
    begin
      sh "pod repo push #{repo_name} #{podspec} --allow-warnings --verbose"
      UI.success("✅ 成功发布 #{podspec} v#{version} 到 #{repo_name}")
    rescue => ex
      UI.error("❌ 发布失败: #{ex.message}")
      UI.message("🔄 回滚tag...")
      sh "git tag -d v#{version}"
      sh "git push origin :v#{version}"
      raise ex
    end

    UI.success("🎉 发版完成！版本 v#{version} 已成功发布")
  end

  desc "检查发版前的准备工作"
  lane :pre_release_check do |options|
    version = options[:version]
    podspec = options[:podspec] || Dir.glob("*.podspec").first

    UI.message("🔍 执行发版前检查...")

    # 1. 检查版本号格式
    unless version.match?(/^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?$/)
      UI.user_error!("版本号格式错误，请使用格式：MAJOR.MINOR.PATCH[-PRERELEASE]")
    end

    # 2. 检查tag是否已存在
    if git_tag_exists(tag: "v#{version}")
      UI.user_error!("Tag v#{version} 已存在，请使用新的版本号")
    end

    # 3. 检查CHANGELOG是否已更新
    changelog_content = File.read("CHANGELOG.md")
    unless changelog_content.include?("[#{version}]")
      UI.user_error!("请在 CHANGELOG.md 中添加版本 #{version} 的更新日志")
    end

    # 4. 验证podspec文件
    UI.message("✅ 验证 podspec 文件...")
    sh "pod spec lint #{podspec} --allow-warnings"

    UI.success("✅ 发版前检查通过！")
  end

  desc "回滚指定版本"
  lane :rollback do |options|
    version = options[:version]
    
    UI.message("🔄 回滚版本 v#{version}...")
    
    # 删除本地tag
    sh "git tag -d v#{version}"
    
    # 删除远程tag
    sh "git push origin :v#{version}"
    
    UI.success("✅ 版本 v#{version} 已回滚")
  end

  # 辅助方法
  def git_tag_exists(tag:)
    `git tag -l "#{tag}"`.strip == tag
  end

  def git_status_clean
    `git status --porcelain`.strip.empty?
  end
end
