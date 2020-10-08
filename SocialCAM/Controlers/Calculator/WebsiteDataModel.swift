//
//  WebsiteDataModel.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 10/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class WebsiteDataModel: NSObject, NSCoding, Mappable {

    var code: Int?
    var message: AnyObject?
    var result: Website?
    var status: String?

    class func newInstance(map: Map) -> Mappable?{
        return WebsiteDataModel()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        code <- map["code"]
        message <- map["message"]
        result <- map["result"]
        status <- map["status"]
        
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         code = aDecoder.decodeObject(forKey: "code") as? Int
         message = aDecoder.decodeObject(forKey: "message") as? AnyObject
         result = aDecoder.decodeObject(forKey: "result") as? Website
         status = aDecoder.decodeObject(forKey: "status") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if code != nil {
            aCoder.encode(code, forKey: "code")
        }
        if message != nil {
            aCoder.encode(message, forKey: "message")
        }
        if result != nil {
            aCoder.encode(result, forKey: "result")
        }
        if status != nil {
            aCoder.encode(status, forKey: "status")
        }

    }

}

class Website: NSObject, NSCoding, Mappable {

    var v: Int?
    var id: String?
    var createdAt: String?
    var name: String?
    var updatedAt: String?
    var count: Int?
    var result: [WebsiteDetails]?


    class func newInstance(map: Map) -> Mappable?{
        return Website()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        v <- map["__v"]
        id <- map["_id"]
        createdAt <- map["createdAt"]
        name <- map["name"]
        updatedAt <- map["updatedAt"]
        count <- map["count"]
        result <- map["result"]
        
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         v = aDecoder.decodeObject(forKey: "__v") as? Int
         id = aDecoder.decodeObject(forKey: "_id") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String
         count = aDecoder.decodeObject(forKey: "count") as? Int
         result = aDecoder.decodeObject(forKey: "result") as? [WebsiteDetails]

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if v != nil {
            aCoder.encode(v, forKey: "__v")
        }
        if id != nil {
            aCoder.encode(id, forKey: "_id")
        }
        if createdAt != nil {
            aCoder.encode(createdAt, forKey: "createdAt")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if updatedAt != nil {
            aCoder.encode(updatedAt, forKey: "updatedAt")
        }
        if count != nil {
            aCoder.encode(count, forKey: "count")
        }
        if result != nil {
            aCoder.encode(result, forKey: "result")
        }

    }

}

class WebsiteDetails: NSObject, NSCoding, Mappable {

    var v: Int?
    var id: String?
    var createdAt: String?
    var name: String?
    var updatedAt: String?


    class func newInstance(map: Map) -> Mappable? {
        return WebsiteDetails()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        v <- map["__v"]
        id <- map["_id"]
        createdAt <- map["createdAt"]
        name <- map["name"]
        updatedAt <- map["updatedAt"]
        
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         v = aDecoder.decodeObject(forKey: "__v") as? Int
         id = aDecoder.decodeObject(forKey: "_id") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder) {
        if v != nil {
            aCoder.encode(v, forKey: "__v")
        }
        if id != nil {
            aCoder.encode(id, forKey: "_id")
        }
        if createdAt != nil {
            aCoder.encode(createdAt, forKey: "createdAt")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if updatedAt != nil {
            aCoder.encode(updatedAt, forKey: "updatedAt")
        }

    }

}
