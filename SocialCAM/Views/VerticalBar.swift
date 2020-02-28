//
//  VerticalBar.swift
//  ReorderStackView
//
//  Created by Viraj Patel on 27/02/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

enum VerticalBarType: Int {
    case speed3x = 6
    case speed4x = 8
    case speed5x = 10
}

@IBDesignable
class VerticalBar: UIStackView {
    
    var numberOfViews: VerticalBarType = .speed4x {
        didSet {
            self.arrangedSubviews
                .forEach { view in
                    self.removeArrangedSubview(view)
                    view.removeFromSuperview()
            }
            addArranged()
        }
    }
    
    var lineView: [DottedLineView] = []
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addArranged()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        addArranged()
    }
    
    func addArranged() {
        axis = .horizontal
        spacing = 0.0
        distribution = .equalSpacing
        for index in 0...numberOfViews.rawValue {
            let view = DottedLineView()
            view.lineColor = .clear
            view.lineWidth = 2
            view.horizontal = false
            if index != (numberOfViews.rawValue / 2) && index != 0 && index != numberOfViews.rawValue {
                view.lineColor = .orange
                view.lineWidth = 2
            }
            
            view.widthAnchor.constraint(equalToConstant: 2).isActive = true
            view.tag = index
            addSubview(view)
            lineView.append(view)
        }
        
        for rView in self.subviews {
            self.addArrangedSubview(rView)
        }
    }
    
    func speedIndicatorViewColorChange(index: Int) {
        for view in lineView {
            if view.tag != (numberOfViews.rawValue / 2) && view.tag != 0 && view.tag != numberOfViews.rawValue {
                view.lineColor = .orange
            }
            if view.tag != (numberOfViews.rawValue / 2) && view.tag != 0 && view.tag != numberOfViews.rawValue && view.tag == (index + 1) {
                view.lineColor = .red
            }
            view.draw(view.frame)
        }
    }
}
