//
//  SaveUserDefaultsProtocol.swift
//  ProManager
//
//  Created by Viraj Patel on 02/05/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

protocol SaveUserDefaultsProtocol { }

extension SaveUserDefaultsProtocol where Self: Codable {
    
    func saveWithKey(key: String, in suiteName: String = "SaveInUserDefaults") {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self),
            let userDefaults = UserDefaults(suiteName: suiteName) {
            userDefaults.set(encoded, forKey: key)
            userDefaults.synchronize()
        }
    }

    static func loadWithKey<T: Codable>(key: String, in suiteName: String = "SaveInUserDefaults", T: T.Type) -> T? {
        let decoder = JSONDecoder()
        if let userDefaults = UserDefaults(suiteName: suiteName),
            let obj = userDefaults.object(forKey: key) as? Data,
            let saveInUserDefaults = try? decoder.decode(T.self, from: obj) {
            return saveInUserDefaults
        }
        return nil
    }
    
    static func removeAll(for suiteName: String = "SaveInUserDefaults") {
        let defaults = UserDefaults(suiteName: suiteName)
        UserDefaults(suiteName: suiteName)?.dictionaryRepresentation().keys.forEach({ (key) -> Void in
            if key != "sessionToken" {
                 defaults?.removeObject(forKey: key)
            }
        })
    }
}
