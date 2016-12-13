//
//  CoreDataViewController.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/12/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class CoreDataViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    init(fetchedResultsController: NSFetchedResultsController<NSManagedObject>) {
        self.fetchedResultsController = fetchedResultsController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError{
                self.presentError(title: "Fetch Request Failed", errorMessage: e.localizedDescription)
            }
        }
    }
}
