# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'YoutubeShortsClone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for YoutubeShortsClone
  pod 'FirebaseAuth'
  pod 'FirebaseAnalytics'
  pod 'FirebaseStorage'
  pod 'FirebaseDatabase'
  pod 'FirebaseCore'
  pod 'ProgressHUD'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
    if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 11.0
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
 end
end