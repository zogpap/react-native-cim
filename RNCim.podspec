
Pod::Spec.new do |s|
  s.name         = "RNCim"
  s.version      = "1.0.0"
  s.summary      = "RNCim"
  s.description  = <<-DESC
                  RNCim
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/author/RNCim.git", :tag => "master" }
  s.source_files  = "RNCim/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "SocketRocket", "~> 0.5.1"
  s.dependency "Protobuf", "~> 3.13.0"
  s.dependency "CocoaAsyncSocket", "~> 7.6.4"
  s.dependency "React"
  #s.dependency "others"

end

  