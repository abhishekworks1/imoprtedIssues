//
//  SpecificBoomerangOptions.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 19/02/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

enum BoomerangOptionType {
    case loop
    case second
    case speed
    case mode
}

class BoomerangOptions<T> {
    
    class BoomerangOption<T> {
        var value: T
        var displayText: String
        
        init(value: T, displayText: String) {
            self.value = value
            self.displayText = displayText
        }
    }
    
    var type: BoomerangOptionType
    var options: [BoomerangOption<T>]? {
        switch self.type {
        case .loop:
            return [
                BoomerangOption<Int>(value: 3, displayText: "1 \(R.string.localizable.loop())"),
                BoomerangOption<Int>(value: 5, displayText: "2 \(R.string.localizable.loops())"),
                BoomerangOption<Int>(value: 7, displayText: "3 \(R.string.localizable.loops())")
                ] as? [BoomerangOption<T>]
        case .second:
            return [
                BoomerangOption<Double>(value: 1, displayText: "1 \(R.string.localizable.second())"),
                BoomerangOption<Double>(value: 2, displayText: "2 \(R.string.localizable.seconds())"),
                BoomerangOption<Double>(value: 3, displayText: "3 \(R.string.localizable.seconds())")
                ] as? [BoomerangOption<T>]
        case .speed:
            if Defaults.shared.cameraName == CameraName.miniboomi{
                return [
                BoomerangOption<Int>(value: 2, displayText: "2x")
                ] as? [BoomerangOption<T>]
            }else if Defaults.shared.cameraName == CameraName.boomi{
                return [
                BoomerangOption<Int>(value: 1, displayText: "1x"),
                BoomerangOption<Int>(value: 2, displayText: "2x"),
                BoomerangOption<Int>(value: 3, displayText: "3x")
                ] as? [BoomerangOption<T>]
            }else if Defaults.shared.cameraName == CameraName.bigboomi{
                return [
                BoomerangOption<Int>(value: -3, displayText: "-3x"),
                BoomerangOption<Int>(value: -2, displayText: "-2x"),
                BoomerangOption<Int>(value: -1, displayText: "-1x"),
                BoomerangOption<Int>(value: 1, displayText: "1x"),
                BoomerangOption<Int>(value: 2, displayText: "2x"),
                BoomerangOption<Int>(value: 3, displayText: "3x")
                ] as? [BoomerangOption<T>]
            }else if Defaults.shared.cameraName == CameraName.liveboomi{
                return [
                BoomerangOption<Int>(value: -3, displayText: "-3x"),
                BoomerangOption<Int>(value: -2, displayText: "-2x"),
                BoomerangOption<Int>(value: -1, displayText: "-1x"),
                BoomerangOption<Int>(value: 1, displayText: "1x"),
                BoomerangOption<Int>(value: 2, displayText: "2x"),
                BoomerangOption<Int>(value: 3, displayText: "3x")
                ] as? [BoomerangOption<T>]
            }else{
            return [
                BoomerangOption<Int>(value: 1, displayText: "1x"),
                BoomerangOption<Int>(value: 2, displayText: "2x"),
                BoomerangOption<Int>(value: 3, displayText: "3x"),
                BoomerangOption<Int>(value: 4, displayText: "4x")
                ] as? [BoomerangOption<T>]
            }
        case .mode:
            if Defaults.shared.cameraName == CameraName.miniboomi && Defaults.shared.appMode == .free{
                return [
                BoomerangOption<Bool>(value: false, displayText: R.string.localizable.forward()),
                BoomerangOption<Bool>(value: true, displayText: R.string.localizable.reverse()),
                ] as? [BoomerangOption<T>]
            }else{
                return [
                BoomerangOption<Bool>(value: false, displayText: R.string.localizable.forward())
                ] as? [BoomerangOption<T>]
            }
        }
    }
    var displayOptions: [String] {
        var displayOptions: [String] = []
        for option in options ?? [] {
            displayOptions.append(option.displayText)
        }
        return displayOptions
    }
    var selectedIndex: Int
    var selectedOption: BoomerangOption<T>? {
        return options?[selectedIndex]
    }
    
    init(type: BoomerangOptionType, selectedIndex: Int) {
        self.type = type
        self.selectedIndex = selectedIndex
    }
}
