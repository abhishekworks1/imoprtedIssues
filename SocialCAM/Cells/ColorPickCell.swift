//
//  ColorPickCell.swift
//  SocialCAM
//
//  Created by Viraj Patel on 10/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class ColorsData {
    var name: String
    var color: UIColor
    var image: UIImage?
    var styleImage: UIImage?
    var isSelected = false
    
    init(name: String, color: UIColor, isSelected: Bool) {
        self.name = name
        self.color = color
        self.isSelected = isSelected
    }
    
    static var activeColorData: [ColorsData] {
        var colorsData: [ColorsData] = []
        colorsData.append(ColorsData(name: "", color: R.color.active1()!, isSelected: true))
        colorsData.append(ColorsData(name: "", color: R.color.active2()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active3()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active4()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active5()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active6()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active7()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active8()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active9()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.active10()!, isSelected: false))
        return colorsData
    }
    
    static var inActiveColorData: [ColorsData] {
        var colorsData: [ColorsData] = []
        colorsData.append(ColorsData(name: "", color: R.color.inActive1()!, isSelected: true))
        colorsData.append(ColorsData(name: "", color: R.color.inActive2()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive3()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive4()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive5()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive6()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive7()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive8()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive9()!, isSelected: false))
        colorsData.append(ColorsData(name: "", color: R.color.inActive10()!, isSelected: false))

        return colorsData
    }
    
}

class ColorPickCell: UITableViewCell {

    var activeColorsData: [ColorsData] = ColorsData.activeColorData
    var inActiveColorsData: [ColorsData] = ColorsData.inActiveColorData
    
    @IBOutlet weak var activeColorsCollectionView: UICollectionView!
    @IBOutlet weak var inActiveColorsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for style in self.activeColorsData {
            style.isSelected = (style.color == Defaults.shared.cameraGuidelineActiveColor)
        }
        
        for style in self.inActiveColorsData {
            style.isSelected = (style.color == Defaults.shared.cameraGuidelineInActiveColor)
        }
        
        activeColorsCollectionView.dataSource = self
        activeColorsCollectionView.delegate = self
        inActiveColorsCollectionView.dataSource = self
        inActiveColorsCollectionView.delegate = self
    }
    
}

extension ColorPickCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.activeColorsCollectionView {
            return activeColorsData.count
        } else {
            return inActiveColorsData.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.colorCollectionViewCell, for: indexPath) else {
            return UICollectionViewCell()
        }
        cell.imageView.image = nil
        if activeColorsData[indexPath.row].isSelected, collectionView == self.activeColorsCollectionView {
            cell.imageView.image = R.image.selectedItem()
        }
        if inActiveColorsData[indexPath.row].isSelected, collectionView == self.inActiveColorsCollectionView {
            cell.imageView.image = R.image.selectedItem()
        }
        if collectionView == self.inActiveColorsCollectionView {
            cell.backgroundColor = inActiveColorsData[indexPath.row].color
        } else {
            cell.backgroundColor = activeColorsData[indexPath.row].color
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !activeColorsData[indexPath.row].isSelected, collectionView == self.activeColorsCollectionView {
            for (index, style) in self.activeColorsData.enumerated() {
                style.isSelected = (index == (indexPath.row % activeColorsData.count))
            }
            Defaults.shared.cameraGuidelineActiveColor = activeColorsData[indexPath.row].color
            collectionView.reloadData()
        } else if !inActiveColorsData[indexPath.row].isSelected, collectionView == self.inActiveColorsCollectionView {
            for (index, style) in self.inActiveColorsData.enumerated() {
                style.isSelected = (index == (indexPath.row % inActiveColorsData.count))
            }
            Defaults.shared.cameraGuidelineInActiveColor = inActiveColorsData[indexPath.row].color
            collectionView.reloadData()
        }
    }
}
