Pod::Spec.new do |s|
  s.name                      = "Baraba"
  s.version                   = "1.0.1"
  s.summary                   = "Make your UIScrollView scroll automatically when user is looking 👀"
  s.homepage                  = "https://github.com/nsoojin/baraba"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Soojin Ro" => "sugarpoint33@gmail.com" }
  s.source                    = { :git => "https://github.com/nsoojin/baraba.git", :tag => s.version.to_s }
  s.swift_version             = "5.0"
  s.ios.deployment_target     = "11.0"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "UIKit"
end
