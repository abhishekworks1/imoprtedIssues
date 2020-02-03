//
//  RxAlamofire+ObjectMapper.swift
//  SimpleInstagram
//
//  Created on 23/01/2020.
//  Copyright © 2020 clementozemoya. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import RxAlamofire

extension ObservableType {
    public func mapObject<T: Mappable>(type: T.Type) -> Observable<T> {
        return flatMap { data -> Observable<T> in
            guard let (_, json) = data as? (HTTPURLResponse, Any),
             let object = Mapper<T>().map(JSONObject: json) else {
                throw NSError(
                    domain: "studio",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Object mapper can't map this object"]
                )
            }
            return Observable.just(object)
        }
    }
    
    public func mapArray<T: Mappable>(type: T.Type) -> Observable<[T]> {
        return flatMap({ data -> Observable<[T]> in
            let json = data as AnyObject
            guard let objects = Mapper<T>().mapArray(JSONObject: json) else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Object mapper can't map this array"]
                )
            }
            return Observable.just(objects)
        })
    }
}
