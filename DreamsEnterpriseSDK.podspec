Pod::Spec.new do |s|
  s.name           = "DreamsEnterpriseSDK"
  s.version        = "2.0.0"
  s.summary        = "Dreams Enterprise iOS SDK"

  s.homepage       = "http://dreamstech.com"
  s.license        = { :type => 'MPL 2.0', :file => 'LICENSE' }
  s.author         = { "Dreams Technology AB" => "didde.brockman@dreamstech.com" }
  s.platform       = :ios, "15.0"

  s.source         = { :git => "https://github.com/doconomy/dreams-ios-sdk.git", :tag => "#{s.version}" }
  s.source_files   = "Sources/*.swift"
  s.resource_bundles = { 'DreamsEnterpriseSDK' => ['Sources/PrivacyInfo.xcprivacy'] }
  s.frameworks     = "WebKit"
  s.swift_version  = '5.0'
end
