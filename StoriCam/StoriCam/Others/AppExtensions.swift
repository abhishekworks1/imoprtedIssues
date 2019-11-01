//
//  Extensions.swift
//  BeaconApp
//
//  Created by Jatin Kathrotiya on 15/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import SDWebImage
import AVFoundation

extension UIFont {
    @nonobjc public static let tagTxtSel = UIFont.init(name: "HelveticaNeue", size: 12)
    @nonobjc public static let sfuifont = UIFont.init(name: "SFUIText-Medium", size: 13)
}

extension UIViewController {
    
    func showHUD() {
        SVProgressHUD.show()
    }
    
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
    
    func dismissHUDWithError(_ error: String) {
        SVProgressHUD.dismiss()
       // SVProgressHUD.showError(withStatus: error)
    }
    
    func dismissHUDWithSuccessMsg(_ message: String) {
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    func changeChannelData(newChannel channel:User) {
         
        Defaults.shared.currentUser = channel
       
//        StoryDataManager.shared.deleteAllRecords()
//        StoryDataManager.shared.stopAll()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwitchChannel"), object: nil)
    }
    
}

extension Float {
    // Rounds the double to decimal places value
    func roundToPlaces(places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return Darwin.round(self * divisor) / divisor
    }
}

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

extension UIFont {
    
    /**
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]
        
        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[NSAttributedString.Key.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }
}

extension NSObject {
    
    func  getController<T>(storybord:String,controller:String) -> T {
        let obj:T = UIStoryboard(name:storybord, bundle: nil).instantiateViewController(withIdentifier: controller) as! T
        return obj
    }
    
    func checkVideoAccess(callBack:((_ granted:Bool,_ msg:String?)->Void)?) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    if let block = callBack {
                        block(true,nil)
                    }
                }
            } else {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                    if granted == true {
                        DispatchQueue.main.async {
                            if let block = callBack {
                                block(true,nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            if let block = callBack {
                                block(false,"Camera Permission decline. Camera access required for capturing Video")
                            }
                        }
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                if let block = callBack {
                    block(false,"Camera not available")
                }
            }
        }
        
    }
    
    func checkMicrophonePermission(block:((_ isGranted:Bool, _ msg:String?)->Void)?) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            if let callBloack = block {
                callBloack(true,"Permission granted")
            }
            
        case .denied:
            print("Pemission denied")
            if let callBlock = block {
                callBlock(false,"Microphone Pemission denied")
            }
            
        case .undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
                if let callBlock = block {
                    callBlock(granted, "Permission granted")
                }
            })
        default:
            if let callBlock = block {
                callBlock(false, "Microphone Pemission denied")
            }
        }
    }
}

extension UIScrollView {
    
    func g_scrollToTop() {
        setContentOffset(CGPoint.zero, animated: false)
    }
    
    func g_updateBottomInset(_ value: CGFloat) {
        var inset = contentInset
        inset.bottom = value
        
        contentInset = inset
        scrollIndicatorInsets = inset
    }
}

extension UIImageView {
    
    func setProfileUrl(url: URL, placeholdeImage: UIImage) {
        if Defaults.shared.playGIF {
            self.sd_setImage(with:url, placeholderImage:placeholdeImage)
        } else {
            self.sd_setImage(with:url, placeholderImage:placeholdeImage)
        }
    }
    
    func setImageFromURL(_ urlString: String?, placeholderImage: UIImage? = nil, indicatorStyle: UIActivityIndicatorView.Style = UIActivityIndicatorView.Style.gray) {
        sd_imageIndicator = SDWebImageActivityIndicator.gray
        let urlString = urlString
        //urlString = urlString?.addingPercentEscapes(using: .utf8)
        // urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        
        let url = URL(string: urlString ?? "")
        sd_setImage(with: url, placeholderImage: placeholderImage)
    }
}


extension Notification.Name {
    
    static let switchChannel = Notification.Name("SwitchChannel")
    
}
