//
//  TextImageCreaterVC.swift
//  ProManager
//
//  Created by Viraj Patel on 18/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

enum ImageEditModes:Int {
    case editModeDrawing
    case editModeText
}

class TextImageCreaterVC: UIViewController ,UITextViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet private weak var imgCorrection: UIImageView!
    
    //MARK: Variables
    private var viewInputText: UIView!
    private var txtCorrection: UITextView!
    private var lastPoint = CGPoint.zero
    private var pointerWidth: CGFloat = 5.0
    private var swiped = false
    private var editMode:ImageEditModes?
    private var tempOldImage: UIImage!
    
    internal var delegate:AnyObject?
    internal var imageToBeEdited: UIImage!
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the view for input and add on the self view
        viewInputText = UIView(frame:CGRect.init(x: 0, y: 0, width: 33, height: 40))
        
        viewInputText.backgroundColor = ApplicationSettings.appBlackColor
        txtCorrection = UITextView(frame:CGRect.init(x: 5, y: 5, width: 23, height: 30))
        txtCorrection.delegate = self
        txtCorrection.font = UIFont.systemFont(ofSize: 18.0)
        txtCorrection.textColor = ApplicationSettings.appWhiteColor
        txtCorrection.backgroundColor = ApplicationSettings.appClearColor
        
        viewInputText.addSubview(txtCorrection)
        self.view.addSubview(viewInputText)
        viewInputText.isHidden = true
        
        //add pan gesture for moving the input view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGestureRecognizer:)))
        self.viewInputText.addGestureRecognizer(panGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    
    /**
     This method is called when user will click on the pencil icon on the UI
     
     - parameter sender: bar button object
     */
    
    @IBAction func drawingItemClicked(sender: UIButton) {
        tempOldImage = self.imgCorrection.image
        editMode = ImageEditModes.editModeDrawing
    }
    
    /**
     This method is called when user will click on the T icon on the UI
     
     - parameter sender: bar button object
     */
    @IBAction func textItemClicked(sender: UIButton) {
        tempOldImage = self.imgCorrection.image
        editMode = ImageEditModes.editModeText
    }
    
    //MARK: TextView Delegates
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let strCorrection = "\(String(describing: textView.text)) \(text)"
        let size = (strCorrection as NSString).size(withAttributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 11.0)])
        let remainingWidth = UIScreen.main.bounds.width - viewInputText.frame.origin.x - 20
        
        viewInputText.frame = CGRect.init(x: viewInputText.frame.origin.x, y: viewInputText.frame.origin.y, width: txtCorrection.contentSize.width < remainingWidth ? size.width + 20 : remainingWidth + 10, height: (txtCorrection.contentSize.height < 30 ? 30 : txtCorrection.contentSize.height) + 10)
        
        txtCorrection.frame = CGRect.init(x: txtCorrection.frame.origin.x, y: txtCorrection.frame.origin.y, width: txtCorrection.contentSize.width < remainingWidth ? size.width + 20 : remainingWidth + 10, height: (txtCorrection.contentSize.height < 30 ? 30 : txtCorrection.contentSize.height) + 10)
        
        return true
    }
    
    //MARK: Private functions
    /**
     This method will be called when user will click on the back button
     
     - parameter sender: buttonObject
     */
    @IBAction func saveButtonClicked(sender:UIButton) {
        if viewInputText.isHidden == false {
            //Draw the text view on the image if it is not hidden
            UIGraphicsBeginImageContextWithOptions(viewInputText.bounds.size, true, 0)
            viewInputText.drawHierarchy(in: viewInputText.bounds, afterScreenUpdates: true)
            let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //crate a uiimage from the current context and save it to camera roll.
            UIGraphicsBeginImageContextWithOptions(imgCorrection.bounds.size, true, 0)
            
            imgCorrection.image?.draw(in: CGRect(x: 0, y: 0,
                                                 width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
            imageWithText?.draw(in: viewInputText.frame)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(image ?? UIImage(), nil, nil, nil)
        }else
        {
            UIGraphicsBeginImageContext(imgCorrection.bounds.size)
            imgCorrection.image?.draw(in: CGRect(x: 0, y: 0,
                                                 width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(image ?? UIImage(), nil, nil, nil)
        }
    }
    
    /**
     This method will be called when user will click on the cancel button in the UI while editing
     
     - parameter sender: button objects
     */
    func cancelClicked(sender:UIButton) {
        if editMode == ImageEditModes.editModeText {
            self.viewInputText.isHidden = true
        }
        editMode = nil
        self.imgCorrection.image = tempOldImage
    }
    
    /**
     This method will be called when user will click on the done button in the UI while editing
     
     - parameter sender: button object
     */
    func doneClicked(sender:UIButton) {
        if editMode == ImageEditModes.editModeText {
            txtCorrection.isEditable = false
            txtCorrection.resignFirstResponder()
            viewInputText.endEditing(true)
        } else {
            UIGraphicsBeginImageContext(imgCorrection.bounds.size)
            imgCorrection.image?.draw(in: CGRect(x: 0, y: 0,
                                                 width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imgCorrection.image = image
        }
        editMode = nil
    }
    
    //MARK: Pan Gesture
    /**
     This method will be called when user will move the edited text.
     
     - parameter panGestureRecognizer: pangesture object
     */
    @objc func handlePanGesture(panGestureRecognizer : UIPanGestureRecognizer) {
        let translation =  panGestureRecognizer.translation(in: self.imgCorrection)
        viewInputText.center = CGPoint.init(x: (panGestureRecognizer.view?.center.x)! + translation.x, y: (panGestureRecognizer.view?.center.y)! + translation.y)
        
        panGestureRecognizer.setTranslation(CGPoint.init(x: 0, y: 0), in: self.imgCorrection)
    }
}


// MARK: - Class extension to implement the touch methods
extension TextImageCreaterVC {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if editMode == ImageEditModes.editModeDrawing {
            swiped = false
            //store the fisrt point where clicked
            if let touch = touches.first  {
                lastPoint = touch.location(in: self.view)
            }
        } else if editMode == ImageEditModes.editModeText {
            //store the fisrt point where clicked and unhide the textview if hidden to capture the text
            if let touch = touches.first  {
                lastPoint = touch.location(in: self.imgCorrection)
            }
            if viewInputText.isHidden == true {
                self.viewInputText.isHidden = false
                viewInputText.frame = CGRect.init(x: lastPoint.x, y: lastPoint.y, width: viewInputText.frame.size.width, height: viewInputText.frame.size.height)
                
                txtCorrection.becomeFirstResponder()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if editMode == ImageEditModes.editModeDrawing {
            swiped = true
            
            // Draw a line in the image and display it
            if let touch = touches.first {
                let currentPoint = touch.location(in: view)
                drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if editMode == ImageEditModes.editModeDrawing {
            if !swiped {
                drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
            }
            //Draw the line and create the image to set on the imageview
            
            UIGraphicsBeginImageContext(imgCorrection.frame.size)
            imgCorrection.image?.draw(in: CGRect(x: 0, y: 0, width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
            imgCorrection.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    /**
     This function is called to draw a line between two points
     
     - parameter fromPoint: start point
     - parameter toPoint:   end point
     */
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(imgCorrection.frame.size)
        let context = UIGraphicsGetCurrentContext()
        imgCorrection.image?.draw(in: CGRect(x: 0, y: 0, width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
        context!.move(to: CGPoint.init(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint.init(x: toPoint.x, y: toPoint.y))
        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(pointerWidth)
        context!.setStrokeColor(UIColor.init(red: 254.0/255.0, green: 87.0/255.0, blue: 86.0/255.0, alpha: 1).cgColor)
        context!.setBlendMode(CGBlendMode.normal)
        context!.strokePath()
        imgCorrection.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
}

