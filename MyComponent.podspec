Pod::Spec.new do |spec|
  spec.name         = "MyComponent"
  spec.version      = "1.0.0"
  spec.summary      = "一个用于测试iOS组件发版自动化流程的示例组件"
  spec.description  = <<-DESC
                    MyComponent 是一个示例iOS组件，用于测试和演示组件发版自动化流程。
                    包含版本管理、CI/CD自动化发版等功能。
                   DESC

  spec.homepage     = "https://github.com/VanishTan/MyComponent"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "VanishTan" => "your-email@example.com" }
  spec.source       = { :git => "https://github.com/VanishTan/MyComponent.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = "12.0"
  spec.swift_versions = ["5.0"]

  spec.source_files  = "Sources/**/*.{swift,h,m}"
  spec.public_header_files = "Sources/**/*.h"

  spec.frameworks = "UIKit", "Foundation"
  spec.dependency 'Alamofire', '~> 5.0'

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift,h,m}'
  end

  spec.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.0'
  }
end
