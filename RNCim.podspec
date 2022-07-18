require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNCim"
  s.version      = package['version']
  s.summary      = package['description']
  s.description  = package['description']
  s.homepage     = package['homepage']
  s.license      = package['license']
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = package['author']
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/author/RNCim.git", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "SocketRocket", "~> 0.5.1"
  s.dependency "Protobuf", "~> 3.13.0"
  s.dependency "CocoaAsyncSocket", "~> 7.6.4"
  s.dependency "React"
  #s.dependency "others"

end

  