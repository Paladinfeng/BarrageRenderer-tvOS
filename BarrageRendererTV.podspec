Pod::Spec.new do |s|
  s.name         = "BarrageRendererTV"
  s.version      = "2.1.1"
  s.summary      = "BarrageRenderer for tvOS, Fork From unash/BarrageRenderer"
  s.homepage     = "https://github.com/Paladinfeng/BarrageRenderer-tvOS"
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.author       = { "Paladinfeng" => "zfxue@icloud.com" }
  
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/Paladinfeng/BarrageRenderer-tvOS.git", :tag => s.version }
  s.source_files = "BarrageRenderer/*.{h,m}","BarrageRenderer/*/*.{h,m}"
end
