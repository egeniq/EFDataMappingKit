Pod::Spec.new do |s|
  s.name         = "MappingKit"
  s.version      = "0.0.3"
  s.summary      = "MappingKit maps data such as those coming from JSON onto an instance using mappings. The mappings are also used to simplify implementing the NSCoding protocol for a class, and to create a dictionary representation of an instance."
  s.homepage     = "https://github.com/Egeniq/EFMapping"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Johan Kool" => "johan@egeniq.com" }
  s.platform     = :ios
  s.ios.deployment_target = "5.1.1"
  s.source       = { :git => "https://github.com/Egeniq/EFMapping.git", :tag => s.version.to_s }
  s.public_header_files = 'EFMapping/NSObject+EFMapping.h'
  s.source_files = 'EFMapping/NSObject+EFMapping.{h,m}'
  s.requires_arc = true
end
