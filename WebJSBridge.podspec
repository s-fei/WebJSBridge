

Pod::Spec.new do |s|
  s.name         = "WebJSBridge"
  s.version      = "1.0.0"
  s.summary      = "JS与APP交互"

  s.description  = <<-DESC
               JS与APP交互
                   DESC

  s.homepage     = "https://github.com/spf-iOS/WebJSBridge"

  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
 
  s.author             = { "spf-iOS" => "spf-iOS@gitHub.com" }
  s.platform     = :ios, "8.0"
 
  s.source       = { :git => "https://github.com/spf-iOS/WebJSBridge.git", :tag => "#{s.version}" }


  s.source_files  = "WebJSBridge/*.swift"


  s.frameworks =  "JavaScriptCore","UIKit"

  s.requires_arc = true

end
