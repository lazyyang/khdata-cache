Pod::Spec.new do |s|
s.name         = "khdata-cache"
s.version      = "1.0.0-beta"
s.summary      = "影像利旧数据"
s.homepage     = "https://git.apexsoft.com.cn/framework/mobile/react-native-apex-platform-common"
s.license      = { :type => "MIT" }
s.author       = { "xuxinhua" => "xuxinhua@apexsoft.com.cn" }
s.platform     = :ios
s.ios.deployment_target = "8.0"
s.source       = { :git => File.join(__dir__, ''), :tag => s.version }
s.source_files  = "**/*.{h,m}"


s.dependency         'React'
s.dependency         'FMDB'



end
