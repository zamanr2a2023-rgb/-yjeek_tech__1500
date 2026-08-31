Pod::Spec.new do |s|
  s.name             = 'BenefitInAppSDKWrapper'
  s.version          = '1.0.5'
  s.summary          = 'Benefit In-App SDK XCFramework for Yjeek'
  s.homepage         = 'https://foo.mobi'
  s.license          = { :type => 'Proprietary' }
  s.author           = 'FOO'
  s.platform         = :ios, '15.6'
  s.source           = { :path => '.' }
  s.vendored_frameworks = '../benefit_sdk/ios/BenefitInAppSDK.xcframework'
end
