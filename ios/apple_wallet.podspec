#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint apple_wallet.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'apple_wallet'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter package for Apple Wallet integration with in-app provisioning and wallet extension support'
  s.description      = <<-DESC
A Flutter package for Apple Wallet integration with in-app provisioning and wallet extension support.
This package provides native iOS PassKit integration for adding payment passes to Apple Wallet.
                       DESC
  s.homepage         = 'https://github.com/SolitaryWolf/apple_wallet'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flow' => 'datvu.it@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # PassKit framework is required for wallet functionality
  s.frameworks = 'PassKit', 'UIKit'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end