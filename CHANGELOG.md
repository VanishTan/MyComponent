# Changelog

所有重要的项目变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且此项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.4] - 2025-10-17

### Added
- docs: 添加GitHub Actions配置修复指南文档
- docs: 添加Ruby版本兼容性说明文档
- ci: 添加CI测试脚本(test-ci.sh)
- ci: 添加.ruby-version文件指定Ruby 3.2.9版本

### Changed
- ci: 优化GitHub Actions工作流配置
- ci: 更新pr-check工作流，增强Danger检查功能
- ci: 改进tag-check工作流的版本验证逻辑
- fix(deps): 更新Gemfile.lock以支持Ruby 3.2.9

### Fixed
- fix(ci): 修复GitHub Actions中Ruby版本兼容性问题
- fix(podspec): 修正podspec文件配置
- fix(source): 修复MyComponent.swift源码问题

## [1.0.3] - 2025-10-17

### Added
- docs: 添加GitHub Actions配置修复指南文档
- docs: 添加Ruby版本兼容性说明文档
- ci: 添加CI测试脚本(test-ci.sh)
- ci: 添加.ruby-version文件指定Ruby 3.2.9版本

### Changed
- ci: 优化GitHub Actions工作流配置
- ci: 更新pr-check工作流，增强Danger检查功能
- ci: 改进tag-check工作流的版本验证逻辑
- fix(deps): 更新Gemfile.lock以支持Ruby 3.2.9

### Fixed
- fix(ci): 修复GitHub Actions中Ruby版本兼容性问题
- fix(podspec): 修正podspec文件配置
- fix(source): 修复MyComponent.swift源码问题


## [1.0.2] - 2025-01-16

### Added
- 添加更多示例组件
- 集成单元测试
- 添加文档

### Changed
- 完善自动化发版流程
- 优化项目结构

### Fixed
- 修复初始版本配置问题

## [1.0.1] - 2025-01-16

### Added
- 添加便捷的静态初始化方法
- 新增组件配置参数管理功能
- 添加操作结果格式化方法

### Fixed
- 修复日志级别检查逻辑
- 优化组件状态管理

### Changed
- 改进扩展方法的可访问性
- 优化测试用例覆盖度

## [1.0.0] - 2025-01-16

### Added
- 初始化MyComponent组件仓库
- 添加基础UI组件示例
- 配置CocoaPods支持
- 集成Fastlane自动化发版流程
- 配置GitHub Actions CI/CD
- 添加Danger自动检查机制
- 创建PR模板和发版规范文档

### Changed
- 无

### Fixed
- 无

### Removed
- 无
