# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'R.swift', '5.3.1'
    pod 'SwiftLint', '0.42.0'
    pod 'Moya/RxSwift', '~> 14.0'
    pod 'Moya-ObjectMapper/RxSwift', '2.9'
    pod 'NSObject+Rx', '5.0.2'
    pod 'URLEmbeddedView', '0.18.0'
    pod 'SDWebImage', '5.6.1'
    pod 'AWSS3', '2.13.0'
    pod 'InfiniteLayout', '0.4.2'
    pod 'GMStepper', '2.2'
end

def projectShared_pods
    pod 'GoogleAPIClientForREST', '~> 1.5'
    pod 'GoogleAPIClientForREST/YouTube', '~> 1.5'
    pod 'RxCocoa', '5.1.1'
    pod 'RxDataSources', '4.0.1'
    pod 'TGPControls', '5.1.0'
    pod 'Toast-Swift', '5.0.0'
    pod 'YoutubePlayerView', :git => 'https://github.com/simformsolutions/YoutubePlayerView.git'
    pod 'SCRecorder', :git => 'https://github.com/jasminpsimform/SCRecorder'
    pod 'Gemini', '1.4.0'
    pod 'OnlyPictures', :git => 'https://github.com/simformsolutions/OnlyPictures'
    pod 'FLAnimatedImage', '1.0.12'
    pod 'SwiftVideoGenerator', :git => 'https://github.com/jasminpsimform/swift-video-generator', :branch => 'swift5'
    pod 'ColorSlider', '4.4'
    pod 'IQKeyboardManagerSwift', '6.5.5'
    pod 'FSPagerView', '0.8.2'
    pod 'NVActivityIndicatorView', '4.6.1'
    pod 'Tiercel', '3.2.0'
    pod 'SkyFloatingLabelTextField', '3.7.0'
    pod 'FontAwesome.swift', '1.5.0'
    pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
    pod 'Firebase/Core', '7.3.0'
    pod 'Firebase/Crashlytics', '7.3.0'
    pod 'Firebase/Analytics', '7.3.0'
    pod 'Firebase/Auth', '7.3.0'
    pod 'GooglePlaces', '3.1.0'
    pod 'GooglePlacePicker', '3.1.0'
    pod 'FBSDKCoreKit', '8.2.0'
    pod 'FBSDKShareKit', '8.2.0'
    pod 'FBSDKLoginKit', '8.2.0'
    pod 'SnapSDK', '1.6.2', :subspecs => ['SCSDKCreativeKit', 'SCSDKLoginKit', 'SCSDKBitmojiKit']
    pod 'AppCenter', '3.3.4'
    pod 'GoogleSignIn', '~> 5.0'
    pod 'TagListView', '1.3.2'
#    pod 'TwitterKit'
    pod 'TwitterKit5', '5.2.0'
    pod 'TikTokOpenSDK'
    pod 'SwiftySound', '1.2'
    pod 'JPSVolumeButtonHandler', '1.0.5'
    pod 'Pageboy', '~> 3.5'
#    pod 'PayPal-iOS-SDK', '2.18.1'
    pod 'MXPagerView', :git => 'https://github.com/simformsolutions/MXPagerView'
    pod 'MXSegmentedPager', :git => 'https://github.com/simformsolutions/MXSegmentedPager'
    pod "ESPullToRefresh", '2.9.3'
    pod 'ProgressHUD', '~> 2.70'
    pod 'Parchment', '3.0.1'
    pod 'Bagel'

    shared_pods
end


target 'SocialCAM' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for SocialCAM
  projectShared_pods
  
end

target 'ViralvidsLite' do
  shared_pods
  pod "SSSpinnerButton", '3.0.2'
end

target 'ViralCamLite' do
  use_frameworks!
  projectShared_pods
end

target 'SnapCamLite' do
  use_frameworks!
  projectShared_pods
end

target 'FastCamLite' do
  use_frameworks!
  projectShared_pods
end

target 'QuickCamLite' do
  use_frameworks!
  projectShared_pods
end

target 'QuickCam' do
  use_frameworks!
  projectShared_pods
end

target 'ViralCam' do
  use_frameworks!
  projectShared_pods
end

target 'Pic2Art' do
  use_frameworks!
  projectShared_pods
end

target 'TimeSpeed' do
  use_frameworks!
  projectShared_pods
end

target 'BoomiCam' do
  use_frameworks!
  projectShared_pods
end

target 'FastCam' do
  use_frameworks!
  projectShared_pods
end

target 'SoccerCam' do
  use_frameworks!
  projectShared_pods
end

target 'FutbolCam' do
  use_frameworks!
  projectShared_pods
end

target 'SnapCam' do
  use_frameworks!
  projectShared_pods
end

target 'SpeedCam' do
  use_frameworks!
  projectShared_pods
end

target 'SocialScreenRecorder' do
  use_frameworks!
  projectShared_pods
end

target 'QuickCamLiteApp' do
  use_frameworks!
  projectShared_pods
end

target 'SpeedCamLite' do
  use_frameworks!
  projectShared_pods
end

target 'SocialCamShare' do
  shared_pods
end

target 'SocialCamMediaShare' do
  shared_pods
end

target 'Pic2ArtShare' do
  shared_pods
end

target 'Viralvids' do
  shared_pods
  pod "SSSpinnerButton"
end

target 'SocialVids' do
  shared_pods
  pod "SSSpinnerButton"
end

target 'SocialScreenRecorderExtension' do
  shared_pods
end

target 'QuickCamLiteExtension' do
  shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
                config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
          config.build_settings['ENABLE_BITCODE'] = 'NO'
          end
    end
end
