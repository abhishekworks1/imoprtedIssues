//
//  CalculatorConfigModel.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 10/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class RootClass : NSObject, NSCoding, Mappable{

    var code : Int?
    var message : String?
    var result : [CalculatorConfigModel]?
    var status : String?


    class func newInstance(map: Map) -> Mappable?{
        return RootClass()
    }
    private override init(){}
    required init?(map: Map){}

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
        message = aDecoder.decodeObject(forKey: "message") as? String
        result = aDecoder.decodeObject(forKey: "result") as? [CalculatorConfigModel]
        status = aDecoder.decodeObject(forKey: "status") as? String
        
    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if code != nil{
            aCoder.encodeConditionalObject(code, forKey: "code")
        }
        if message != nil{
            aCoder.encodeConditionalObject(message, forKey: "message")
        }
        if result != nil{
            aCoder.encode(result, forKey: "result")
        }
        if status != nil{
            aCoder.encodeConditionalObject(status, forKey: "status")
        }

    }

}

class CalculatorConfigModel : NSObject, NSCoding, Mappable{

    var id : String?
    var createdAt : String?
    var level1 : Int?
    var level2 : Int?
    var level3 : Int?
    var maxAverageRefer : Int?
    var maxLevel : Int?
    var maxRefer : Int?
    var months : Int?
    var name : String?
    var percentage : Int?
    var type : String?
    var updatedAt : String?


    class func newInstance(map: Map) -> Mappable?{
        return CalculatorConfigModel()
    }
    private override init(){}
    required init?(map: Map){}

    func mapping(map: Map)
    {
        id <- map["_id"]
        createdAt <- map["createdAt"]
        level1 <- map["level1"]
        level2 <- map["level2"]
        level3 <- map["level3"]
        maxAverageRefer <- map["maxAverageRefer"]
        maxLevel <- map["maxLevel"]
        maxRefer <- map["maxRefer"]
        months <- map["months"]
        name <- map["name"]
        percentage <- map["percentage"]
        type <- map["type"]
        updatedAt <- map["updatedAt"]
        
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         id = aDecoder.decodeObject(forKey: "_id") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
         level1 = aDecoder.decodeObject(forKey: "level1") as? Int
         level2 = aDecoder.decodeObject(forKey: "level2") as? Int
         level3 = aDecoder.decodeObject(forKey: "level3") as? Int
         maxAverageRefer = aDecoder.decodeObject(forKey: "maxAverageRefer") as? Int
         maxLevel = aDecoder.decodeObject(forKey: "maxLevel") as? Int
         maxRefer = aDecoder.decodeObject(forKey: "maxRefer") as? Int
         months = aDecoder.decodeObject(forKey: "months") as? Int
         name = aDecoder.decodeObject(forKey: "name") as? String
         percentage = aDecoder.decodeObject(forKey: "percentage") as? Int
         type = aDecoder.decodeObject(forKey: "type") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if id != nil{
            aCoder.encodeConditionalObject(id, forKey: "_id")
        }
        if createdAt != nil{
            aCoder.encodeConditionalObject(createdAt, forKey: "createdAt")
        }
        if level1 != nil{
            aCoder.encodeConditionalObject(level1, forKey: "level1")
        }
        if level2 != nil{
            aCoder.encodeConditionalObject(level2, forKey: "level2")
        }
        if level3 != nil{
            aCoder.encodeConditionalObject(level3, forKey: "level3")
        }
        if maxAverageRefer != nil{
            aCoder.encodeConditionalObject(maxAverageRefer, forKey: "maxAverageRefer")
        }
        if maxLevel != nil{
            aCoder.encodeConditionalObject(maxLevel, forKey: "maxLevel")
        }
        if maxRefer != nil{
            aCoder.encodeConditionalObject(maxRefer, forKey: "maxRefer")
        }
        if months != nil{
            aCoder.encodeConditionalObject(months, forKey: "months")
        }
        if name != nil{
            aCoder.encodeConditionalObject(name, forKey: "name")
        }
        if percentage != nil{
            aCoder.encodeConditionalObject(percentage, forKey: "percentage")
        }
        if type != nil{
            aCoder.encodeConditionalObject(type, forKey: "type")
        }
        if updatedAt != nil{
            aCoder.encodeConditionalObject(updatedAt, forKey: "updatedAt")
        }

    }

}
