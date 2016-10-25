
Pod::Spec.new do |s|

  s.name         = "SZQRCode"

  s.version      = "0.0.2"

  s.summary      = "simple qrcode view controller"

  s.homepage     = "https://github.com/chenshengzhi/SZQRCodeDemo.git"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "陈圣治" => "329012084@qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/chenshengzhi/SZQRCodeDemo.git", :tag => s.version.to_s }

  s.source_files = "SZQRCode/*.{h,m}"

  s.requires_arc = true

  s.dependency 'SZQRCodeCoverView'

end
