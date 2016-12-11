//
//  PointAnnotation.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/11/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit
import MapKit

class PointAnnotation: MKPointAnnotation {
    let pin: Pin
    init(pin: Pin) {
        self.pin = pin
        super.init()
    }
}
