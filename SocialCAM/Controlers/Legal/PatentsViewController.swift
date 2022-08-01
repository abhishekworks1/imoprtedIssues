//
//  PatentsViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 30/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import WebKit

class PatentsViewController: UIViewController {

    // MARK: - Outlets Declaration
    @IBOutlet weak var lblPatentDesciption: UILabel!
    @IBOutlet weak var pdfWebView: WKWebView!
    @IBOutlet weak var imgPdf: UIImageView!
    
    // MARK: - Variable Declaration
    let documentInteractionController = UIDocumentInteractionController()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        if !pdfWebView.isHidden {
            pdfWebView.isHidden = true
            lblPatentDesciption.isHidden = false
            imgPdf.isHidden = false
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnPdfTapped(_ sender: UIButton) {
        saveToFiles()
    }
    
    func saveToFiles() {
        if let pdfUrl = Bundle.main.url(forResource: "patents", withExtension: "pdf", subdirectory: nil, localization: nil) {
            let baseUrl = FileManager.default.temporaryDirectory.appendingPathComponent("patents.pdf")
            do {
                let data = try Data(contentsOf: pdfUrl)
                try data.write(to: baseUrl)
                if #available(iOS 14.0, *) {
                    let controller = UIDocumentPickerViewController(forExporting: [baseUrl])
                    controller.delegate = self
                    present(controller, animated: true, completion: nil)
                } else {
                    let controller = UIDocumentPickerViewController(url: baseUrl, in: .exportToService)
                    present(controller, animated: true, completion: nil)
                }
            } catch {
                showAlert(alertMessage: error.localizedDescription)
            }
        }
    }
}

extension PatentsViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        Utils.appDelegate?.window?.makeToast(R.string.localizable.patentPopup())
    }
}
