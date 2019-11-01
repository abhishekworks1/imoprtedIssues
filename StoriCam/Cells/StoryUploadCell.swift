//
//  StoryUploadCell.swift
//  ProManager
//
//  Created by Jasmin Patel on 11/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class StoryUploadCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var remainBytesLabel: UILabel!
    @IBOutlet weak var remainFileLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var uploadProgressView: UIProgressView!
    
    var deleteHandler: ((_ isDelete : Int,_ currentTask: AnyObject?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func cancleButtonTapped(_ sender: AnyObject) {
        if let deleteHandler = self.deleteHandler {
            deleteHandler(self.tag,nil)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func getOneDecimalPlaceValue(_ num: Float) -> String {
        return String(format: "%.1f", num)
    }
    
    func sizePerMB(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }

}
