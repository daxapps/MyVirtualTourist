//
//  Photo+CoreDataProperties.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/11/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var data: NSData?
    @NSManaged public var index: Int16
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
