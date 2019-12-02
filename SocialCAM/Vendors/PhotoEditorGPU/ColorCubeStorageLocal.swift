//
//  ColorCubeStorage.swift
//  ProManager
//
//  Created by Viraj Patel on 29/07/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension Collection where Index == Int {
    
    fileprivate func concurrentMap<U>(_ transform: (Element) -> U) -> [U] {
        var buffer = [U?].init(repeating: nil, count: count)
        let lock = NSLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let e = self[i]
            let r = transform(e)
            lock.lock()
            buffer[i] = r
            lock.unlock()
        }
        return buffer.compactMap { $0 }
    }
}

extension ColorCubeStorage {
    static func loadToDefault() {
        
        do {
            
            try autoreleasepool {
                let bundle = Bundle.main
                let rootPath = bundle.bundlePath as NSString
                let fileList = try FileManager.default.contentsOfDirectory(atPath: rootPath as String)
                
                let filters = fileList
                    .filter { $0.hasSuffix(".png") || $0.hasSuffix(".PNG") }
                    .sorted()
                    .concurrentMap { path -> FilterColorCube in
                        let url = URL(fileURLWithPath: rootPath.appendingPathComponent(path))
                        let data = try? Data(contentsOf: url)
                        let image = UIImage(data: data ?? Data()) ?? UIImage()
                        let name = path
                            .replacingOccurrences(of: "LUT_", with: "")
                            .replacingOccurrences(of: ".png", with: "")
                            .replacingOccurrences(of: ".PNG", with: "")
                        return FilterColorCube.init(
                            name: name,
                            identifier: path,
                            lutImage: image,
                            dimension: 64
                        )
                }
                
                self.default.filters = filters
            }
            
        } catch {
            
            assertionFailure("\(error)")
        }
    }
}
