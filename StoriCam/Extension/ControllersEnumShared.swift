//
//  ControllersShared.swift
//  ProManager
//
//  Created by Viraj Patel on 16/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

enum Storyboards: String {
    case AddPost
    
    var filename: String {
        return rawValue
    }
    
    public var storyboard: UIStoryboard {
        return UIStoryboard(name: filename, bundle: nil)
    }
}

enum Controllers: String {
    case AlbumListViewController
    case SelectPrivacyViewController
    case SelectFriendViewController
    
    var identifier: String {
        return rawValue
    }
    
    var controller: UIViewController {
        switch self {
        case .AlbumListViewController, .SelectPrivacyViewController, .SelectFriendViewController:
            return Storyboards.AddPost.storyboard.instantiateViewController(withIdentifier: identifier)
        }
    }
    
}
