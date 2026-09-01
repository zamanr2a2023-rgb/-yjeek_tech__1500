Pod::Spec.new do |s|
  s.name                = 'BenefitInAppSDKWrapper'
  s.version             = '1.0.5'
  s.summary             = 'Benefit In-App SDK XCFramework for Yjeek'
  s.homepage            = 'https://foo.mobi'
  s.license             = { :type => 'Proprietary' }
  s.author              = 'FOO'
  s.platform            = :ios, '15.6'
  s.source              = { :git => 'https://github.com/foo-mobi/BenefitInAppSDK.git', :tag => s.version.to_s }
  s.vendored_frameworks = 'BenefitInAppSDK.xcframework'
end
