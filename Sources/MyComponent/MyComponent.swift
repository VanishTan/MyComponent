import UIKit
import Foundation

/// MyComponent 主类
/// 这是一个示例组件，用于演示iOS组件发版自动化流程
@objc public class MyComponent: NSObject {
    
    // MARK: - Properties
    
    /// 组件名称
    @objc public let name: String
    
    /// 组件版本
    @objc public let version: String
    
    /// 配置信息
    @objc public var configuration: ComponentConfiguration
    
    // MARK: - Initialization
    
    /// 初始化组件
    /// - Parameters:
    ///   - name: 组件名称，默认为 "MyComponent"
    ///   - version: 组件版本，默认为 "1.0.0"
    @objc public init(name: String = "MyComponent", version: String = "1.0.0") {
        self.name = name
        self.version = version
        self.configuration = ComponentConfiguration()
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// 配置组件
    /// - Parameter config: 配置对象
    @objc public func configure(with config: ComponentConfiguration? = nil) {
        if let config = config {
            self.configuration = config
        }
        
        print("🚀 \(name) v\(version) 已配置完成")
        print("📋 配置信息: \(configuration)")
    }
    
    /// 启动组件
    @objc public func start() {
        print("▶️ \(name) 已启动")
        configuration.isActive = true
    }
    
    /// 停止组件
    @objc public func stop() {
        print("⏹️ \(name) 已停止")
        configuration.isActive = false
    }
    
    /// 获取组件状态
    /// - Returns: 组件状态描述
    @objc public func getStatus() -> String {
        let status = configuration.isActive ? "运行中" : "已停止"
        return "\(name) v\(version) - 状态: \(status)"
    }
    
    /// 执行示例操作
    /// - Parameter operation: 操作类型
    /// - Returns: 操作结果
    @objc public func performOperation(_ operation: ComponentOperation) -> OperationResult {
        print("🔧 执行操作: \(operation.description)")
        
        switch operation {
        case .hello:
            return OperationResult(success: true, message: "Hello from \(name)!")
        case .version:
            return OperationResult(success: true, message: "当前版本: \(version)")
        case .status:
            return OperationResult(success: true, message: getStatus())
        case .custom(let message):
            return OperationResult(success: true, message: "自定义操作: \(message)")
        }
    }
}

// MARK: - Component Configuration

/// 组件配置类
@objc public class ComponentConfiguration: NSObject {
    
    /// 是否激活
    @objc public var isActive: Bool = false
    
    /// 调试模式
    @objc public var debugMode: Bool = false
    
    /// 日志级别
    @objc public var logLevel: LogLevel = .info
    
    /// 自定义参数
    @objc public var customParameters: [String: Any] = [:]
    
    public override init() {
        super.init()
    }
    
    public override var description: String {
        return "Configuration(active: \(isActive), debug: \(debugMode), logLevel: \(logLevel))"
    }
}

// MARK: - Component Operation

/// 组件操作类型
@objc public enum ComponentOperation: Int, CaseIterable {
    case hello = 0
    case version = 1
    case status = 2
    case custom = 3
    
    public var description: String {
        switch self {
        case .hello:
            return "打招呼"
        case .version:
            return "获取版本"
        case .status:
            return "获取状态"
        case .custom:
            return "自定义操作"
        }
    }
}

// MARK: - Operation Result

/// 操作结果
@objc public class OperationResult: NSObject {
    
    /// 是否成功
    @objc public let success: Bool
    
    /// 结果消息
    @objc public let message: String
    
    /// 时间戳
    @objc public let timestamp: Date
    
    @objc public init(success: Bool, message: String) {
        self.success = success
        self.message = message
        self.timestamp = Date()
        super.init()
    }
    
    public override var description: String {
        let status = success ? "✅" : "❌"
        return "\(status) \(message) (时间: \(timestamp))"
    }
}

// MARK: - Log Level

/// 日志级别
@objc public enum LogLevel: Int, CaseIterable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    public var description: String {
        switch self {
        case .debug:
            return "调试"
        case .info:
            return "信息"
        case .warning:
            return "警告"
        case .error:
            return "错误"
        }
    }
}

// MARK: - Extensions

extension ComponentOperation {
    /// 创建自定义操作
    /// - Parameter message: 自定义消息
    /// - Returns: 自定义操作实例
    public static func custom(message: String) -> ComponentOperation {
        return .custom
    }
}
