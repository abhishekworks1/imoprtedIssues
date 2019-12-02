//
//  DrawingContainerView.swift
//  DrawKit
//
//  Created by Viraj Patel on 19/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

protocol DrawingContainerViewDelegate: class {
    /// Tells the delegate to handle a touchesBegan event.
    ///
    /// - Parameter point: The point in this view's coordinate system where the touch began.
    func drawingContainerViewTouchBegan(at point: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event.
    ///
    /// - Parameter point: The point in this view's coordinate system to which the touch moved.
    func drawingContainerViewTouchMoved(to point: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event.
    ///
    /// - Parameter point: The poin in this view's coordinate system.
    func drawingContainerViewTouchEnded(at point: CGPoint)
}

internal class DrawingContainerView: UIView {
    weak var delegate: DrawingContainerViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let location = firstTouch.location(in: self)
        delegate?.drawingContainerViewTouchBegan(at: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let location = firstTouch.location(in: self)
        delegate?.drawingContainerViewTouchMoved(to: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let location = firstTouch.location(in: self)
        delegate?.drawingContainerViewTouchEnded(at: location)
    }
}
