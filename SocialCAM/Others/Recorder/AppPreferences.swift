//
//  AppPreferences.swift
//  SocialScreenRecorder
//
//  Created by Viraj Patel on 11/12/20.
//

import Foundation

// MARK: - AppPreferences class
final class AppPreferences {
    static let shared = AppPreferences()
    fileprivate static let ud = UserDefaults.standard
    private init() {}
}

// MARK: - Bool
protocol BoolDefaults: KeyNamespaceable {
    associatedtype BoolKey: RawRepresentable
}

extension BoolDefaults where BoolKey.RawValue == String {
    
    func set(value: Bool, forKey key: BoolKey) {
        AppPreferences.ud.set(value, forKey: namespaced(key))
    }
    
    @discardableResult
    func bool(forKey key: BoolKey) -> Bool {
        return AppPreferences.ud.bool(forKey: namespaced(key))
    }
    
    func removeObject(forKey key: BoolKey) {
        AppPreferences.ud.removeObject(forKey: namespaced(key))
    }
}

// MARK: - bool value
extension AppPreferences: BoolDefaults {
    enum BoolKey: String {
        case startedScreenRecording
        case finishedTutorial
    }
}

protocol KeyNamespaceable {
    func namespaced<T: RawRepresentable>(_ key: T) -> String
}

extension KeyNamespaceable {
    func namespaced<T: RawRepresentable>(_ key: T) -> String {
        return "\(Self.self).\(String(describing: type(of: key))).\(key.rawValue)"
    }
}
