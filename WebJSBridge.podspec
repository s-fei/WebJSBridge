

Pod::Spec.new do |s|
  s.name         = "WebJSBridge"
  s.version      = “1.0.0”
  s.summary      = "JS与APP交互"

  s.description  = <<-DESC
               JS与APP交互
                   DESC

  s.homepage     = "https://github.com/spf-iOS/WebJSBridge"

  s.license      = "MIT"
 
  s.author             = { "spf-iOS" => "spf-iOS@gitHub.com" }
  s.platform     = :ios, “7.0”
 
  s.source       = { :git => "https://github.com/spf-iOS/WebJSBridge.git", :tag => "#{s.version}" }


  s.source_files  = "WebJSBridge/*.swift"


  s.frameworks = "UIKit", "JavaScriptCore"

  s.requires_arc = true

end
