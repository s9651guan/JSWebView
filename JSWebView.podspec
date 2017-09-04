Pod::Spec.new do |s|
s.name        = 'JSWebView'
s.version     = '1.0.1'
s.authors     = { 's9651guan' => '245454031@qq.com' }
s.homepage    = 'https://github.com/s9651guan/JSWebView'
s.summary     = 'A clasa that H5 interacts with iOS ,controlled by cocoaPods'
s.source      = { :git => 'https://github.com/s9651guan/JSWebView.git',
:tag => "1.0.1" }
s.license     = { :type => "MIT", :file => "LICENSE" }
 
s.platform = :ios, '8.0'
s.requires_arc = true
s.source_files = 'JSWebView'
s.public_header_files = 'JSWebView/*.h'
end
