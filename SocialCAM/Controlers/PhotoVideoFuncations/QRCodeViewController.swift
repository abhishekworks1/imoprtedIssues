//
//  QRCodeViewController.swift
//  SocialCAM
//
//  Created by Gaurang Pandya on 17/11/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import MessageUI

enum RefferelType:Int{
    case quickStart = 1
    case refferalPage = 2
}
class QRCodeViewController: UIViewController {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var imageQrCode: UIImageView!
    @IBOutlet weak var imgProfilePic: UIImageView!

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var quickStartButton: UIButton!
    @IBOutlet weak var quickStartBottomLine: UIView!
    @IBOutlet weak var quickStartBottomLineHeight: NSLayoutConstraint!
    @IBOutlet weak var refferalPageButton: UIButton!
    @IBOutlet weak var refferalPageBottomLine: UIView!
    @IBOutlet weak var refferalPageBottomLineHeight: NSLayoutConstraint!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var lblUsername: UILabel!
    let logoImage = UIImage(named:"qr_applogo")
    var refferelType:RefferelType = .quickStart
   //4541E1
   // let themeBlueColor = UIColor(hexString:"4285F4")
    let themeBlueColor = UIColor(hexString:"4F2AD8")
    let themeGreyColor = UIColor(hexString:"707070")
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var badgebtn1: UIButton!
    @IBOutlet weak var badgebtn2: UIButton!
    @IBOutlet weak var badgebtn3: UIButton!
    @IBOutlet weak var badgebtn4: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        setup()
    }
    

    // MARK: - Setup Methods
    func setup() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            self.imgProfilePic.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            self.imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
            self.imgProfilePic.contentMode = .scaleAspectFill
            self.imgProfilePic.layer.borderWidth = 1.5
            self.imgProfilePic.layer.borderColor = UIColor.white.cgColor

        }
        setUpbadges()
        self.lblUsername.text = "@\(Defaults.shared.currentUser?.channelId ?? "")"
      /*  if let qrImageURL = Defaults.shared.currentUser?.qrcode {
            self.imageQrCode.sd_setImage(with: URL.init(string: qrImageURL), placeholderImage: nil)
        }*/
        if let quickStartPage = Defaults.shared.currentUser?.quickStartPage {
           print(quickStartPage)
            let image =  URL(string: quickStartPage)?.qrImage(using: themeBlueColor, logo: logoImage)
            self.imageQrCode.image = image?.convert()
        }
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))

        leftSwipe.direction = .left
        rightSwipe.direction = .right

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        navView.addGradient()
       // imageQrCode.addGradient()
        self.quickStartClicked(self.quickStartButton)
        refferelType = .quickStart
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer)
    {
        if (sender.direction == .right)
        {
           print("Swipe Left")
            self.quickStartClicked(self.quickStartButton)
        }

        if (sender.direction == .left)
        {
           print("Swipe Right")
            self.refferalPageClicked(self.refferalPageButton)
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func shareOkButtonClicked(_ sender: UIButton) {
        let image = self.profileView.toImage()
        var shareItems: [Any] = []
        shareItems.append(image)
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
        
    }
    
    @IBAction func downloadButtonClicked(_ sender: UIButton) {
            let image = self.profileView.toImage()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        Utils.appDelegate?.window?.makeToast(R.string.localizable.qrCodeImageSaved())
    }
    @IBAction func quickStartClicked(_ sender: UIButton) {
        quickStartButton.setTitleColor(themeBlueColor, for: .normal)
        quickStartBottomLine.backgroundColor = themeBlueColor
        quickStartBottomLineHeight.constant = 2.0
        
        refferalPageButton.setTitleColor(themeGreyColor, for: .normal)
        refferalPageBottomLine.backgroundColor = ApplicationSettings.appPrimaryColor
        refferalPageBottomLineHeight.constant = 0.7
        
        refferelType = .quickStart
        
        if let quickStartPage = Defaults.shared.currentUser?.quickStartPage {
           print(quickStartPage)
          
            let image =  URL(string: quickStartPage)?.qrImage(using: themeBlueColor, logo: logoImage)
            self.imageQrCode.image = image?.convert()
        }
        
    }
    @IBAction func refferalPageClicked(_ sender: UIButton) {
        refferalPageButton.setTitleColor(themeBlueColor, for: .normal)
        refferalPageBottomLine.backgroundColor = themeBlueColor
        refferalPageBottomLineHeight.constant = 2.0
        
        quickStartButton.setTitleColor(themeGreyColor, for: .normal)
        quickStartBottomLine.backgroundColor = ApplicationSettings.appPrimaryColor
        quickStartBottomLineHeight.constant = 0.7
        
        refferelType = .refferalPage
        
        if let referralPage = Defaults.shared.currentUser?.referralPage {
           print(referralPage)
         //   let image = generateQRCode(from: referralPage)
           
            let image =  URL(string: referralPage)?.qrImage(using: themeBlueColor, logo: logoImage)
            self.imageQrCode.image = image?.convert()
        }
        
        
    }
    
    func setUpbadges() {
        let badgearry = Defaults.shared.getbadgesArray()
        view1.isHidden = true
        view2.isHidden = true
        view3.isHidden = true
        view4.isHidden = true
        
        if  badgearry.count >  0 {
            view1.isHidden = false
            badgebtn1.setImage(UIImage.init(named: badgearry[0]), for: .normal)
        }
        if  badgearry.count >  1 {
            view2.isHidden = false
            badgebtn2.setImage(UIImage.init(named: badgearry[1]), for: .normal)
        }
        if  badgearry.count >  2 {
            view3.isHidden = false
            badgebtn3.setImage(UIImage.init(named: badgearry[2]), for: .normal)
        }
        if  badgearry.count >  3 {
            view4.isHidden = false
            badgebtn4.setImage(UIImage.init(named: badgearry[3]), for: .normal)
        }
    }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image ?? UIImage()
    }
    
}

// MARK: - MFMail Compose View Controller Delegate
extension QRCodeViewController: MFMailComposeViewControllerDelegate {
    
    private func createEmailUrl(to: String, subject: String, body: String, emailType: EmailType) -> URL? {
        if let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                guard let imageData = self.profileView.toImage().pngData() else {
                    
                    return URL(string: "")
                }
               print(imageData)
            switch emailType {
            case .gmail:
                let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                
                if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
                    return gmailUrl
                } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
                    return yahooMail
                } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
                    return sparkUrl
                }
            case .outlook:
                let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                if let outlookUrl = outlookUrl,
                   UIApplication.shared.canOpenURL(outlookUrl) {
                    return outlookUrl
                }
            }
            let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
            return defaultUrl
        }
        return URL(string: "")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
extension UIView {
    
   // #1566F6 #4A2EDA #6418D0
    
    
   
    func addGradient2(colors: [UIColor] = [UIColor(hexString:"1566F6"),UIColor(hexString:"4A2EDA"), UIColor(hexString:"6418D0")], locations: [NSNumber] = [0, 2], startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0), endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0), type: CAGradientLayerType = .axial){
        
        let gradient = CAGradientLayer()
        
        gradient.frame.size = self.frame.size
        gradient.frame.origin = CGPoint(x: 0.0, y: 0.0)

        // Iterates through the colors array and casts the individual elements to cgColor
        // Alternatively, one could use a CGColor Array in the first place or do this cast in a for-loop
        gradient.colors = colors.map{ $0.cgColor }
        
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        // Insert the new layer at the bottom-most position
        // This way we won't cover any other elements
        self.layer.insertSublayer(gradient, at: 0)
    }
    func addGradient(){
       
        let gradient = CAGradientLayer()
         let color3 = UIColor(hexString:"4285F4")
         let color1 = UIColor(hexString:"4F2AD8")
        let color2 = UIColor(hexString:"4A2EDA")
         gradient.frame = self.bounds
        gradient.colors = [color1.cgColor,color2.cgColor,color3.cgColor]
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5) // vertical gradient start
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        self.layer.insertSublayer(gradient, at: 0)
    }
}
extension CIImage {
    /// Inverts the colors and creates a transparent image by converting the mask to alpha.
    /// Input image should be black and white.
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }

    /// Inverts the colors.
    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }

        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }

    /// Converts all black to transparent.
    var blackTransparent: CIImage? {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }

    /// Applies the given color as a tint color.
    func tinted(using color: UIColor) -> CIImage?
    {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }

        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage

        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)

        return filter.outputImage!
    }
    func convert() -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(self, from: self.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    /// Combines the current image with the given image centered.
    func combined(with image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
        combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage!
    }
}
extension URL {

    /// Creates a QR code for the current URL in the given color.
   /* func qrImage(using color: UIColor) -> CIImage? {
        return qrImage?.tinted(using: color)
    } */

    /// Returns a black and white QR code for this URL.
    var qrImage: CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = absoluteString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")

        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        return qrFilter.outputImage?.transformed(by: qrTransform)
    }
    func qrImage(using color: UIColor, logo: UIImage? = nil) -> CIImage? {
            let tintedQRImage = qrImage?.tinted(using: color)

            guard let logo = logo?.cgImage else {
                return tintedQRImage
            }

            return tintedQRImage?.combined(with: CIImage(cgImage: logo))
        }
}
