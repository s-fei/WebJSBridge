

Pod::Spec.new do |s|
  s.name         = "WebJSBridge"
  s.version      = "1.0.2"
  s.summary      = "JS与APP交互"

  s.description  = <<-DESC
               完美实现JS与APP交互
                   DESC

  s.homepage     = "http://www.mgzf.com"

  s.license      = "MIT"
 
  s.author             = { "spf-iOS" => "spf-iOS@gitHub.com" }
  s.platform     = :ios, "8.0"
 
  s.source       = { :git => "https://github.com/spf-iOS/WebJSBridge.git", :tag => "#{s.version}" }


  s.source_files  = "WebJSBridge/*.swift"


  s.frameworks =  "JavaScriptCore","UIKit"

  s.requires_arc = true

end
