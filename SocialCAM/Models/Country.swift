//
//  Country.swift
//  SocialCAM
//
//  Created by Viraj Patel on 14/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

public struct Country: Equatable {
    public let name: String
    public let code: String
    public let phoneCode: String
    public let isState: Bool
    public func localizedName(_ locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forRegionCode: code)
    }
    public var flag: UIImage {
        if isState {
            return UIImage(named: "flag_state_\(code.lowercased())") ?? UIImage()
        } else {
            return UIImage(named: "flag_\(code.lowercased())") ?? UIImage()
        }
    }
}

public func ==(lhs: Country, rhs: Country) -> Bool {
    return lhs.code == rhs.code
}
public func !=(lhs: Country, rhs: Country) -> Bool {
    return lhs.code != rhs.code
}
