//
//  CalculatorConfigModel.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 10/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class CalculatorConfigurationModel: NSObject, NSCoding, Mappable {

    var code: Int?
    var message: String?
    var result: [CalculatorConfigurationData]?
    var status: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return CalculatorConfigurationModel()
    }
    
    private override init() { }
    required init?(map: Map) { }

    func mapping(map: Map) {
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
        result = aDecoder.decodeObject(forKey: "result") as? [CalculatorConfigurationData]
        status = aDecoder.decodeObject(forKey: "status") as? String
        
    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder) {
        if code != nil {
            aCoder.encodeConditionalObject(code, forKey: "code")
        }
        if message != nil {
            aCoder.encodeConditionalObject(message, forKey: "message")
        }
        if result != nil {
            aCoder.encode(result, forKey: "result")
        }
        if status != nil {
            aCoder.encodeConditionalObject(status, forKey: "status")
        }

    }

}

class CalculatorConfigurationData: NSObject, NSCoding, Mappable {

    var id: String?
    var createdAt: String?
    var levels: [Level]?
    var maxAverageRefer: Int?
    var maxExtended: Int?
    var maxLevel: Int?
    var maxLevel1: Int?
    var maxLevel2: Int?
    var maxLevel3: Int?
    var maxPersonal: Int?
    var maxRefer: Int?
    var months: Int?
    var name: String?
    var percentage: Int?
    var type: String?
    var updatedAt: String?
    var levelsArray: [Int]?
    var inAppPurchaseLimit: Int?
    
    class func newInstance(map: Map) -> Mappable? {
        return CalculatorConfigurationData()
    }
    
    required init?(map: Map) { }
    private override init() { }

    func mapping(map: Map) {
        id <- map["_id"]
        createdAt <- map["createdAt"]
        levels <- map["levels"]
        maxAverageRefer <- map["maxAverageRefer"]
        maxExtended <- map["maxExtended"]
        maxLevel <- map["maxLevel"]
        maxLevel1 <- map["maxLevel1"]
        maxLevel2 <- map["maxLevel2"]
        maxLevel3 <- map["maxLevel3"]
        maxPersonal <- map["maxPersonal"]
        maxRefer <- map["maxRefer"]
        months <- map["months"]
        name <- map["name"]
        percentage <- map["percentage"]
        type <- map["type"]
        updatedAt <- map["updatedAt"]
        levelsArray <- map["levelsArray"]
        inAppPurchaseLimit <- map["inAppPurchaseLimit"]
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "_id") as? String
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
        levels = aDecoder.decodeObject(forKey: "levels") as? [Level]
        maxAverageRefer = aDecoder.decodeObject(forKey: "maxAverageRefer") as? Int
        maxExtended = aDecoder.decodeObject(forKey: "maxExtended") as? Int
        maxLevel = aDecoder.decodeObject(forKey: "maxLevel") as? Int
        maxLevel1 = aDecoder.decodeObject(forKey: "maxLevel1") as? Int
        maxLevel2 = aDecoder.decodeObject(forKey: "maxLevel2") as? Int
        maxLevel3 = aDecoder.decodeObject(forKey: "maxLevel3") as? Int
        maxPersonal = aDecoder.decodeObject(forKey: "maxPersonal") as? Int
        maxRefer = aDecoder.decodeObject(forKey: "maxRefer") as? Int
        months = aDecoder.decodeObject(forKey: "months") as? Int
        name = aDecoder.decodeObject(forKey: "name") as? String
        percentage = aDecoder.decodeObject(forKey: "percentage") as? Int
        type = aDecoder.decodeObject(forKey: "type") as? String
        updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String
        levelsArray = aDecoder.decodeBool(forKey: "levelsArray") as? [Int]
        inAppPurchaseLimit = aDecoder.decodeObject(forKey: "inAppPurchaseLimit") as? Int
    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder) {
        if id != nil {
            aCoder.encode(id, forKey: "_id")
        }
        if createdAt != nil {
            aCoder.encode(createdAt, forKey: "createdAt")
        }
        if levels != nil {
            aCoder.encode(levels, forKey: "levels")
        }
        if maxAverageRefer != nil {
            aCoder.encode(maxAverageRefer, forKey: "maxAverageRefer")
        }
        if maxExtended != nil {
            aCoder.encode(maxExtended, forKey: "maxExtended")
        }
        if maxLevel != nil {
            aCoder.encode(maxLevel, forKey: "maxLevel")
        }
        if maxLevel1 != nil {
            aCoder.encode(maxLevel1, forKey: "maxLevel1")
        }
        if maxLevel2 != nil {
            aCoder.encode(maxLevel2, forKey: "maxLevel2")
        }
        if maxLevel3 != nil {
            aCoder.encode(maxLevel3, forKey: "maxLevel3")
        }
        if maxPersonal != nil {
            aCoder.encode(maxPersonal, forKey: "maxPersonal")
        }
        if maxRefer != nil {
            aCoder.encode(maxRefer, forKey: "maxRefer")
        }
        if months != nil {
            aCoder.encode(months, forKey: "months")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if percentage != nil {
            aCoder.encode(percentage, forKey: "percentage")
        }
        if type != nil {
            aCoder.encode(type, forKey: "type")
        }
        if updatedAt != nil {
            aCoder.encode(updatedAt, forKey: "updatedAt")
        }
        if levelsArray != nil {
            aCoder.encode(levelsArray, forKey: "levelsArray")
        }
        if inAppPurchaseLimit != nil {
            aCoder.encode(inAppPurchaseLimit, forKey: "inAppPurchaseLimit")
        }
    }

}

class Level: NSObject, NSCoding, Mappable {

    var level1: Int?
    var level10: Int?
    var level2: Int?
    var level3: Int?
    var level4: Int?
    var level5: Int?
    var level6: Int?
    var level7: Int?
    var level8: Int?
    var level9: Int?

    class func newInstance(map: Map) -> Mappable? {
        return Level()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map) {
        level1 <- map["level1"]
        level10 <- map["level10"]
        level2 <- map["level2"]
        level3 <- map["level3"]
        level4 <- map["level4"]
        level5 <- map["level5"]
        level6 <- map["level6"]
        level7 <- map["level7"]
        level8 <- map["level8"]
        level9 <- map["level9"]
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
         level1 = aDecoder.decodeObject(forKey: "level1") as? Int
         level10 = aDecoder.decodeObject(forKey: "level10") as? Int
         level2 = aDecoder.decodeObject(forKey: "level2") as? Int
         level3 = aDecoder.decodeObject(forKey: "level3") as? Int
         level4 = aDecoder.decodeObject(forKey: "level4") as? Int
         level5 = aDecoder.decodeObject(forKey: "level5") as? Int
         level6 = aDecoder.decodeObject(forKey: "level6") as? Int
         level7 = aDecoder.decodeObject(forKey: "level7") as? Int
         level8 = aDecoder.decodeObject(forKey: "level8") as? Int
         level9 = aDecoder.decodeObject(forKey: "level9") as? Int

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder) {
        if level1 != nil {
            aCoder.encode(level1, forKey: "level1")
        }
        if level10 != nil {
            aCoder.encode(level10, forKey: "level10")
        }
        if level2 != nil {
            aCoder.encode(level2, forKey: "level2")
        }
        if level3 != nil {
            aCoder.encode(level3, forKey: "level3")
        }
        if level4 != nil {
            aCoder.encode(level4, forKey: "level4")
        }
        if level5 != nil {
            aCoder.encode(level5, forKey: "level5")
        }
        if level6 != nil {
            aCoder.encode(level6, forKey: "level6")
        }
        if level7 != nil {
            aCoder.encode(level7, forKey: "level7")
        }
        if level8 != nil {
            aCoder.encode(level8, forKey: "level8")
        }
        if level9 != nil {
            aCoder.encode(level9, forKey: "level9")
        }
    }

}
