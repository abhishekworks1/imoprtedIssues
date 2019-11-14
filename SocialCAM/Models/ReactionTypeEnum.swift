//
//  Constant.swift
//  BeaconApp
//
//  Created by Jatin Kathrotiya on 15/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation

enum ReactionType: String {
    case laugh = "laugh"
    case wow = "wow"
    case sad = "sad"
    case angry = "angry"
    case love = "love"
    case like = "like"

    case thanks = "thanks"
    case prayer = "prayer"
    case wtf = "wtf"
    case lol = "lol"
    case peace = "peace"
    case hallelujah = "hallelujah"
    case amen = "amen"
    
    var fbReaction : Reaction {
        get {
            switch self {
            case .like:
                return Reaction.facebook.like
            case .love:
                return Reaction.facebook.love
            case .angry:
                return Reaction.facebook.angry
            case .sad:
                return Reaction.facebook.sad
            case .wow:
                return Reaction.facebook.wow
            case .laugh:
                return Reaction.facebook.laugh
            case .thanks:
                return Reaction.facebook.thanks
            case .prayer:
                return Reaction.facebook.prayer
            case .wtf:
                return Reaction.facebook.wtf
            case .lol:
                return Reaction.facebook.lol
            case .peace:
                return Reaction.facebook.peace
            case .hallelujah:
                return Reaction.facebook.hallelujah
            case .amen:
                return Reaction.facebook.amen
            }
        }
    }
}
