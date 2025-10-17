#!/bin/bash

# 测试 CI 环境配置
echo "🧪 测试 CI 环境配置..."

# 检查 Ruby 版本
echo "📋 Ruby 版本:"
ruby --version

# 检查 Gemfile.lock 中的 Bundler 版本
echo "📋 Gemfile.lock 中的 Bundler 版本:"
grep "BUNDLED WITH" Gemfile.lock

# 模拟 CI 环境安装 Bundler 2.x
echo "📦 安装 Bundler 2.x..."
gem install bundler -v '~> 2.0' --no-document

# 检查安装的 Bundler 版本
echo "📋 安装的 Bundler 版本:"
bundle --version

# 测试 bundle install
echo "📦 测试 bundle install..."
bundle config set --local path 'vendor/bundle'
bundle install

echo "✅ CI 环境配置测试完成！"
