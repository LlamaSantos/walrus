//
//  Receipt.swift
//  walrus
//
//  Created by James White on 12/3/14.
//  Copyright (c) 2014 James White. All rights reserved.
//

import Foundation
import CoreData

@objc(Receipt)
class Receipt: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var ts: NSDate
    @NSManaged var image: NSData
    
    class func MR_entityName() -> String{
        return "Receipt"
    }

}
