import XCTest
@testable import MyComponent

final class MyComponentTests: XCTestCase {
    
    var component: MyComponent!
    
    override func setUpWithError() throws {
        component = MyComponent()
    }
    
    override func tearDownWithError() throws {
        component = nil
    }
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() throws {
        XCTAssertEqual(component.name, "MyComponent")
        XCTAssertEqual(component.version, "1.0.0")
        XCTAssertNotNil(component.configuration)
    }
    
    func testCustomInitialization() throws {
        let customComponent = MyComponent(name: "TestComponent", version: "2.0.0")
        XCTAssertEqual(customComponent.name, "TestComponent")
        XCTAssertEqual(customComponent.version, "2.0.0")
    }
    
    // MARK: - Configuration Tests
    
    func testDefaultConfiguration() throws {
        let config = ComponentConfiguration()
        XCTAssertFalse(config.isActive)
        XCTAssertFalse(config.debugMode)
        XCTAssertEqual(config.logLevel, .info)
        XCTAssertTrue(config.customParameters.isEmpty)
    }
    
    func testCustomConfiguration() throws {
        let config = ComponentConfiguration()
        config.debugMode = true
        config.logLevel = .debug
        config.setParameter("testValue", forKey: "testKey")
        
        component.configure(with: config)
        
        XCTAssertTrue(component.configuration.debugMode)
        XCTAssertEqual(component.configuration.logLevel, .debug)
        XCTAssertEqual(component.configuration.parameter(forKey: "testKey") as? String, "testValue")
    }
    
    // MARK: - Lifecycle Tests
    
    func testStartAndStop() throws {
        XCTAssertFalse(component.configuration.isActive)
        
        component.start()
        XCTAssertTrue(component.configuration.isActive)
        
        component.stop()
        XCTAssertFalse(component.configuration.isActive)
    }
    
    func testGetStatus() throws {
        let status = component.getStatus()
        XCTAssertTrue(status.contains("MyComponent"))
        XCTAssertTrue(status.contains("1.0.0"))
        XCTAssertTrue(status.contains("已停止"))
        
        component.start()
        let activeStatus = component.getStatus()
        XCTAssertTrue(activeStatus.contains("运行中"))
    }
    
    // MARK: - Operation Tests
    
    func testHelloOperation() throws {
        let result = component.performOperation(.hello)
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.message.contains("Hello from MyComponent"))
    }
    
    func testVersionOperation() throws {
        let result = component.performOperation(.version)
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.message.contains("当前版本: 1.0.0"))
    }
    
    func testStatusOperation() throws {
        let result = component.performOperation(.status)
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.message.contains("MyComponent"))
    }
    
    func testCustomOperation() throws {
        let result = component.performOperation(.custom(message: "测试消息"))
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.message.contains("自定义操作"))
        XCTAssertTrue(result.message.contains("测试消息"))
    }
    
    // MARK: - Extension Tests
    
    func testDefaultStaticMethod() throws {
        let defaultComponent = MyComponent.default()
        XCTAssertEqual(defaultComponent.name, "MyComponent")
        XCTAssertEqual(defaultComponent.version, "1.0.0")
    }
    
    func testCreateStaticMethod() throws {
        let customComponent = MyComponent.create(debugMode: true, logLevel: .debug)
        XCTAssertTrue(customComponent.configuration.debugMode)
        XCTAssertEqual(customComponent.configuration.logLevel, .debug)
    }
    
    func testOperationResultExtensions() throws {
        let successResult = OperationResult.success(message: "测试成功")
        XCTAssertTrue(successResult.success)
        XCTAssertEqual(successResult.message, "测试成功")
        
        let failureResult = OperationResult.failure(message: "测试失败")
        XCTAssertFalse(failureResult.success)
        XCTAssertEqual(failureResult.message, "测试失败")
        
        XCTAssertTrue(successResult.isSuccessful())
        XCTAssertFalse(failureResult.isSuccessful())
        
        let timestamp = successResult.formattedTimestamp()
        XCTAssertFalse(timestamp.isEmpty)
    }
    
    func testLogLevelExtensions() throws {
        XCTAssertEqual(LogLevel.debug.icon, "🐛")
        XCTAssertEqual(LogLevel.info.icon, "ℹ️")
        XCTAssertEqual(LogLevel.warning.icon, "⚠️")
        XCTAssertEqual(LogLevel.error.icon, "❌")
        
        XCTAssertTrue(LogLevel.error.shouldLog(currentLevel: .info))
        XCTAssertFalse(LogLevel.debug.shouldLog(currentLevel: .error))
    }
    
    func testConfigurationParameterManagement() throws {
        let config = ComponentConfiguration()
        
        // 设置参数
        config.setParameter("value1", forKey: "key1")
        config.setParameter(42, forKey: "key2")
        
        // 获取参数
        XCTAssertEqual(config.parameter(forKey: "key1") as? String, "value1")
        XCTAssertEqual(config.parameter(forKey: "key2") as? Int, 42)
        
        // 移除参数
        config.removeParameter(forKey: "key1")
        XCTAssertNil(config.parameter(forKey: "key1"))
        
        // 清空所有参数
        config.clearAllParameters()
        XCTAssertNil(config.parameter(forKey: "key2"))
        XCTAssertTrue(config.customParameters.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceExample() throws {
        // 测试组件初始化的性能
        measure {
            for _ in 0..<1000 {
                let testComponent = MyComponent()
                _ = testComponent.performOperation(.hello)
            }
        }
    }
}
