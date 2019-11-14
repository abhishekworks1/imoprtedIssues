//
//  VerticalCenteredTextView.swift
//  ProManager
//
//  Created by Harikrishna Daraji on 08/04/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import  UIKit

/// This class help TextView's content to stay centered vertically
class VerticalCenteredTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addContentSizeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addContentSizeObserver()
    }
    
    /// Adding observer for content size of textview
    private func addContentSizeObserver() {
        self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    /// removing observer for content size of textview
    private func removeContentSizeObserver() {
        _ = self.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }
    
    deinit {
        removeContentSizeObserver()
    }
    
}
