//
//  GCDBlackBox.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/10/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation

func performUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
