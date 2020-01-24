//
//  HomeCollectionViewCell.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

class Games {
    var name: String
    var image: UIImage?
    var notificationCount: Int = 0
    var selected: Bool? = false
    
    init(name: String, image: UIImage? = UIImage(), notificationCount: Int = 0, selected: Bool = false) {
        self.name = name
        self.image = image
        self.notificationCount = notificationCount
        self.selected = selected
    }
}

class StoryGames {
    var name: String
    var games: [Games]
    
    init(name: String, games: [Games]) {
        self.name = name
        self.games = games
    }
    
    static var storyGames = [StoryGames(name: "",
                                              games: [
                                                Games(name: R.string.localizable.sport(), image: R.image.sportBitmoji(), selected: false),
                                                Games(name: R.string.localizable.dance(), image: R.image.danceBitmoji(), selected: true),
                                                Games(name: R.string.localizable.gyM(), image: R.image.gymBitmoji(), selected: false),
                                                Games(name: R.string.localizable.boxing(), image: R.image.boxingBitmoji(), selected: false)])]
}

class GameGridCell: UICollectionViewCell {
    @IBOutlet var gameNameView: UIView?
    @IBOutlet var imgView: UIImageView?
    @IBOutlet var lblGameName: UILabel?
    @IBOutlet var lblNotificationCount: UILabel?
    
    var game: Games? {
        didSet {
            if let game = self.game {
                self.configCell(game: game)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Utils.generateDiagonal(view: gameNameView)
    }
    
    func configCell(game: Games) {
        imgView?.image = game.image
        lblGameName?.text = game.name
        lblNotificationCount?.text = "\(game.notificationCount)"
    }

}
