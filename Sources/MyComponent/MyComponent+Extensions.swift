import UIKit

// MARK: - MyComponent Extensions

extension MyComponent {
    
    /// 便捷初始化方法
    /// - Returns: 默认配置的组件实例
    @objc public static func `default`() -> MyComponent {
        let component = MyComponent()
        component.configure()
        return component
    }
    
    /// 创建带自定义配置的组件
    /// - Parameters:
    ///   - debugMode: 是否开启调试模式
    ///   - logLevel: 日志级别
    /// - Returns: 配置好的组件实例
    @objc public static func create(debugMode: Bool = false, logLevel: LogLevel = .info) -> MyComponent {
        let component = MyComponent()
        let config = ComponentConfiguration()
        config.debugMode = debugMode
        config.logLevel = logLevel
        component.configure(with: config)
        return component
    }
}

// MARK: - ComponentConfiguration Extensions

extension ComponentConfiguration {
    
    /// 设置自定义参数
    /// - Parameters:
    ///   - value: 参数值
    ///   - key: 参数键
    @objc public func setParameter(_ value: Any, forKey key: String) {
        customParameters[key] = value
    }
    
    /// 获取自定义参数
    /// - Parameter key: 参数键
    /// - Returns: 参数值
    @objc public func parameter(forKey key: String) -> Any? {
        return customParameters[key]
    }
    
    /// 移除自定义参数
    /// - Parameter key: 参数键
    @objc public func removeParameter(forKey key: String) {
        customParameters.removeValue(forKey: key)
    }
    
    /// 清空所有自定义参数
    @objc public func clearAllParameters() {
        customParameters.removeAll()
    }
}

// MARK: - OperationResult Extensions

extension OperationResult {
    
    /// 检查操作是否成功
    /// - Returns: 是否成功
    @objc public func isSuccessful() -> Bool {
        return success
    }
    
    /// 获取格式化的时间戳
    /// - Returns: 格式化的时间字符串
    @objc public func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    /// 创建失败结果
    /// - Parameter message: 失败消息
    /// - Returns: 失败结果
    @objc public static func failure(message: String) -> OperationResult {
        return OperationResult(success: false, message: message)
    }
    
    /// 创建成功结果
    /// - Parameter message: 成功消息
    /// - Returns: 成功结果
    @objc public static func success(message: String) -> OperationResult {
        return OperationResult(success: true, message: message)
    }
}

// MARK: - LogLevel Extensions

extension LogLevel {
    
    /// 获取日志级别对应的图标
    /// - Returns: 图标字符
    public var icon: String {
        switch self {
        case .debug:
            return "🐛"
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        }
    }
    
    /// 检查是否应该记录日志
    /// - Parameter currentLevel: 当前日志级别
    /// - Returns: 是否应该记录
    public func shouldLog(currentLevel: LogLevel) -> Bool {
        return self.rawValue >= currentLevel.rawValue
    }
}
