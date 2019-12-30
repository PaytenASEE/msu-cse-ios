#
# Be sure to run `pod lib lint MsuCse.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MsuCse'
  s.version          = '1.0.0-SNAPSHOT'
  s.summary          = 'MSU Client Side Encryption'

  s.description      = <<-DESC
MSU Client Side Encryption description
                       DESC
  s.homepage         = 'https://github.com/jasmin.suljic/MsuCse'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jasmin.suljic' => 'jasmin.suljich@gmail.com' }
  s.source           = { :git => 'https://github.com/jasmin.suljic/MsuCse.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'

  s.source_files = 'MsuCse/Classes/**/*'
end
