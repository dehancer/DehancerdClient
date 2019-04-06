Pod::Spec.new do |s|

  s.name         = "DehancerdClient"
  s.version      = "0.3.1"
  s.summary      = "Dehancerd services client"
  s.description  = "Dehancerd services client"

  s.homepage     = "https://dehancer.com"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors            = { "denis svinarchuk" => "denn.nevera@gmail.com" }
  s.social_media_url   = "https://dehancer.com"

  s.platform     = :ios
  s.platform     = :osx

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.14"
 
  s.swift_version = "5.0"

  s.source       = { :git => "https://github.com/dehancer/DehancerdClient", :tag => "#{s.version}" }

  s.source_files  = "DehancerdClient/Classes/**/*.{swift}",

  s.frameworks = "Foundation"

  s.requires_arc = true

  s.dependency 'ed25519'
  s.dependency 'ObjectMapper'
  s.dependency 'PromiseKit'
  #, :git => 'https://github.com/dnevera/ed25519cpp', :tag => "0.1"
  
end
