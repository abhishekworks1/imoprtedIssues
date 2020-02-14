# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'R.swift', '5.0.3'
    pod 'SwiftLint'
    pod 'ObjectMapper', '3.5.1'
    pod 'RxAlamofire', '4.3.0'
    pod 'Moya/RxSwift', '12.0.1'
    pod 'Moya-ObjectMapper/RxSwift', '2.8.0'
    pod 'RxSwift', '4.4.1'
    pod 'NSObject+Rx', '4.4.1'
    pod 'URLEmbeddedView', '0.17.1'
end

target 'SocialCAM' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for SocialCAM
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.14.0'
  pod 'SDWebImage', '5.2.5'
  pod 'AWSS3', '2.12.0'
  pod 'RxCocoa', '4.4.1'
  pod 'RxDataSources', '3.1.0'
  pod 'Alamofire', '4.9.1'
  pod 'TGPControls', '5.1.0'
  pod 'Toast-Swift', '5.0.0'
  pod 'YoutubePlayerView', :git => 'https://github.com/simformsolutions/YoutubePlayerView.git'
  pod 'SCRecorder', :git => 'https://github.com/jasminpsimform/SCRecorder'
  pod 'Gemini', '1.3.1'
  pod 'OnlyPictures', :git => 'https://github.com/simformsolutions/OnlyPictures'
  pod 'FLAnimatedImage', '1.0.12'
  pod 'SVProgressHUD', '2.2.5'
  pod 'SwiftVideoGenerator', :git => 'https://github.com/jasminpsimform/swift-video-generator', :branch => 'swift5'
  pod 'ColorSlider', '4.3.0'
  pod 'IQKeyboardManagerSwift', '6.2.0'
  pod 'FSPagerView', '0.8.2'
  pod 'NVActivityIndicatorView', '4.6.1'
  pod 'MXSegmentedPager', :git => 'https://github.com/simformsolutions/MXSegmentedPager'
  pod 'Tiercel', '2.3.0'
  pod 'SkyFloatingLabelTextField', '3.7.0'
  pod 'FontAwesome.swift', '1.5.0'
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'GooglePlaces'
  pod 'GooglePlacePicker'
  pod 'FBSDKShareKit/Swift'
  pod 'FBSDKLoginKit/Swift'
  pod 'SnapSDK', :subspecs => ['SCSDKCreativeKit', 'SCSDKLoginKit', 'SCSDKBitmojiKit']
  pod 'AppCenter'
  pod 'GoogleSignIn', '~> 5.0'
  pod 'TagListView', '1.3.2'
  pod 'TwitterKit'
  pod 'TikTokOpenSDK', '~> 2.0.0'
  pod 'SwiftySound', '1.2'
  pod 'JPSVolumeButtonHandler'
  pod 'Pageboy', '~> 3.2'
  shared_pods
end

target 'SocialCamShare' do
  shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end
