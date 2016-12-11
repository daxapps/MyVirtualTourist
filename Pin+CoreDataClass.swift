//
//  Pin+CoreDataClass.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/11/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation
import CoreData
import MapKit


public class Pin: NSManagedObject {
    
    var coordinate: CLLocationCoordinate2D?
    var annotation: PointAnnotation {
        get {
            let annotation = PointAnnotation(pin: self)
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            return annotation
        }
    }
    
    convenience init(with coordinate: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.coordinate = coordinate
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
            self.set = 0
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
