#
# Be sure to run `pod lib lint MsuCse.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MsuCse'
  s.version          = '1.1.0'
  s.summary          = 'MSU Client Side Encryption'

  s.description      = <<-DESC
MSU Client Side Encryption description
                       DESC
  s.homepage         = 'https://github.com/PaytenASEE/msu-cse-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jasmin.suljic' => 'jasmin.suljich@gmail.com' }
  s.source           = { :git => 'https://github.com/PaytenASEE/msu-cse-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'

  s.source_files = 'MsuCse/Classes/**/*'
  
  # s.test_spec 'Tests' do |test_spec|
  #   test_spec.requires_app_host = true
  #   test_spec.source_files = 'Example/Tests/**/*'
  # end
end
