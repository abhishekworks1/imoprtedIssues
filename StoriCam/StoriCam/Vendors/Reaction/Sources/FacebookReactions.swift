/*
 * Reactions
 *
 * Copyright 2016-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

/// Default implementation of the facebook reactions.
extension Reaction {
  /// Struct which defines the standard facebook reactions.
  public struct facebook {
    /// The facebook's "like" reaction.
    public static var like: Reaction {
      return reactionWithId("like")
    }

    /// The facebook's "love" reaction.
    public static var love: Reaction {
      return reactionWithId("love")
    }

    /// The facebook's "haha" reaction.
    public static var laugh: Reaction {
      return reactionWithId("laugh")
    }

    /// The facebook's "wow" reaction.
    public static var wow: Reaction {
      return reactionWithId("wow")
    }

    /// The facebook's "sad" reaction.
    public static var sad: Reaction {
      return reactionWithId("sad")
    }

    /// The facebook's "angry" reaction.
    public static var angry: Reaction {
      return reactionWithId("angry")
    }
    
    public static var thanks: Reaction {
        return reactionWithId("thanks")
    }
    
    public static var prayer: Reaction {
        return reactionWithId("prayer")
    }

    public static var wtf: Reaction {
        return reactionWithId("wtf")
    }
    
    public static var peace: Reaction {
        return reactionWithId("peace")
    }
    public static var hallelujah: Reaction {
        return reactionWithId("hallelujah")
    }
    
    public static var amen: Reaction {
        return reactionWithId("amen")
    }
    
    public static var lol: Reaction {
        return reactionWithId("lol")
    }
    
    /// The list of standard facebook reactions in this order: `.like`, `.love`, `.haha`, `.wow`, `.sad`, `.angry`.
    public static let all: [Reaction] = [facebook.like, facebook.love, facebook.thanks, facebook.lol,facebook.wtf,facebook.peace, facebook.prayer,facebook.hallelujah,facebook.amen]

   // facebook.wow, facebook.sad, facebook.angry
    // MARK: - Convenience Methods

    public static func reactionWithId(_ id: String) -> Reaction {
      var color: UIColor            = .black
      var alternativeIcon: UIImage? = nil

      switch id {
      case "like":
        color           = ApplicationSettings.appPrimaryColor
        alternativeIcon = imageWithName("like-template").withRenderingMode(.alwaysTemplate)
      case "love":
        color = UIColor(red: 0.93, green: 0.23, blue: 0.33, alpha: 1)
      case "angry":
        color = UIColor(red: 0.96, green: 0.37, blue: 0.34, alpha: 1)
      case "prayer":
        color = UIColor(red: 0.96, green: 0.37, blue: 0.34, alpha: 1)
      default:
        color = UIColor(red: 0.99, green: 0.84, blue: 0.38, alpha: 1)
      }

      return Reaction(id: id, title: id.localized(from: "FacebookReactionLocalizable"), color: color, icon: imageWithName(id), alternativeIcon: alternativeIcon)
    }

    private static func imageWithName(_ name: String) -> UIImage {
      return UIImage(named: name, in: .reactionsBundle(), compatibleWith: nil)!
    }
  }
}

extension Bundle {
    /// Returns the current lib bundle
    class func reactionsBundle() -> Bundle {
        var bundle = Bundle(for: ReactionButton.self)
        
        if let url = bundle.url(forResource: "Reactions", withExtension: "bundle"), let podBundle = Bundle(url: url) {
            bundle = podBundle
        }
        
        return bundle
    }
}

extension String {
    
    /**
     Returns the string localized.
     
     - Parameter tableName: The receiver’s string table to search. By default the method attempts to use the table in FeedbackLocalizable.strings.
     */
    func localized(from tableName: String? = "FeedbackLocalizable") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: .reactionsBundle(), value: self, comment: "")
    }
}
