//
//  PhotoEditioViewController+Picker.swift
//  StoriCam
//
//  Created by Viraj Patel on 04/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation

extension PhotoEditorViewController: PickerViewDataSource {
    
    // MARK: - PickerViewDataSource
    
    public func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return storyTimeOptions.count
    }
    
    public func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        return storyTimeOptions[index]
    }
    
}

extension PhotoEditorViewController: PickerViewDelegate {
    
    public func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 134.0
    }
    
    public func pickerView(_ pickerView: PickerView, didSelectRow row: Int, index: Int) {
        
    }
    
    public func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        
        label.font = UIFont(name: "Avenir-Heavy", size: 72.0)
        if highlighted {
            label.textColor = ApplicationSettings.appWhiteColor
        } else {
            label.textColor = ApplicationSettings.appWhiteColor.withAlphaComponent(0.75)
        }
        
        if label.text == "∞" {
            pickerView.selectionTitle.text = "no limit"
        } else {
            pickerView.selectionTitle.text = "seconds"
        }
    }
    
    public func pickerView(_ pickerView: PickerView, viewForRow row: Int, index: Int, highlighted: Bool, reusingView view: UIView?) -> UIView? {
        return nil
    }
    
}
