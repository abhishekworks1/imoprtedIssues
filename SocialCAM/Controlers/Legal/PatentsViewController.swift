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
        self.pdfWebView.isHidden = false
        lblPatentDesciption.isHidden = true
        imgPdf.isHidden = true
        if let pdfUrl = Bundle.main.url(forResource: "patents", withExtension: "pdf", subdirectory: nil, localization: nil) {
            do {
                let data = try Data(contentsOf: pdfUrl)
                pdfWebView.load(data, mimeType: "application/pdf", characterEncodingName: "", baseURL: pdfUrl.deletingLastPathComponent())
            } catch {
                showAlert(alertMessage: error.localizedDescription)
            }
        }
    }
}
