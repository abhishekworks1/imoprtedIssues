//
//  MusicPickerVC.swift
//  ProManager
//
//  Created by Viraj Patel on 16/08/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation

class MusicCell: UITableViewCell {
    
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var settingsName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SlideShowMusic {
    var name: String
    var isSelected: Bool
    
    init(name: String, isSelected: Bool) {
        self.name = name
        self.isSelected = isSelected
    }
    
}

class MusicPickerVC: UIViewController {
    
    @IBOutlet weak var musicTableView: UITableView!
    
    var finishAddMusicBlock: ((URL?, Bool) -> Void)?
    
    var firstPercentage: Double = 0.0
    
    var firstUploadCompletedSize: Double = 0.0
    
    var selectedURL: URL?
    
    var musicOptions = [SlideShowMusic(name: "01 Instrumental Theme (Intro)", isSelected: false),
                        SlideShowMusic(name: "02 Instrumental Theme (Orchestral Sunset)", isSelected: false),
                        SlideShowMusic(name: "03 Mysterious Intro", isSelected: false)]
    
    var musicOptionsImages = [#imageLiteral(resourceName: "storySound"),
                              #imageLiteral(resourceName: "storySound"),
                              #imageLiteral(resourceName: "storySound")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (_, slideShowMusic) in self.musicOptions.enumerated() {
            if let selectedurl = self.selectedURL,
                selectedurl.deletingPathExtension().lastPathComponent == slideShowMusic.name {
                slideShowMusic.isSelected = true
                selectedURL = selectedurl
            } else {
                slideShowMusic.isSelected = false
            }
        }
        musicTableView.reloadData()
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDone(_ sender: Any) {
        finishAddMusicBlock?(selectedURL, (selectedURL != nil))
        navigationController?.popViewController(animated: true)
    }
    
}

extension MusicPickerVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as? MusicCell else {
            fatalError("MusicCell Not Found")
        }
        cell.settingsName.text = musicOptions[indexPath.row].name
        cell.onOffButton.isSelected = musicOptions[indexPath.row].isSelected
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for (index, slideShowMusic) in self.musicOptions.enumerated() {
            if index == indexPath.row {
                slideShowMusic.isSelected = !slideShowMusic.isSelected
                if slideShowMusic.isSelected {
                    selectedURL = Bundle.main.url(forResource: slideShowMusic.name, withExtension: "mp3")!
                } else {
                    selectedURL = nil
                }
            } else {
                slideShowMusic.isSelected = false
            }
        }
        tableView.reloadData()
    }
    
}
