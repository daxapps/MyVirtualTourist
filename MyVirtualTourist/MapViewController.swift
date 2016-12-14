//
//  MapViewController.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/9/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: CoreDataViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editIndicator: UILabel!
    
    var editMode = Bool()
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing,animated:animated)
        if (self.isEditing) {
            //In Editing mode
            self.editButtonItem.title = "Done"
            editIndicator.isHidden = false
            editMode = true
        } else {
            //Not in editing mode
            self.editButtonItem.title = "Edit"
            editIndicator.isHidden = true
            editMode = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual Tourist"
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Get the stack
        fetchStoredPins { (fetchedPins) in
            performUpdatesOnMain {
                for pin in fetchedPins {
                    self.mapView.addAnnotation(pin.annotation)
                }
            }
        }
    }
    
    func fetchStoredPins(completion: ((_ fetchedPins: [Pin]) -> Void)?) {
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()
        completion?(fetchedResultsController?.fetchedObjects as! [Pin])
    }
    
    @IBAction func editButton(_ sender: AnyObject) {
        editIndicator.isHidden = !editIndicator.isHidden
    }
    
    @IBAction func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            let touchPoint = recognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let pin = Pin(with: coordinate, insertInto: fetchedResultsController!.managedObjectContext)
            mapView.addAnnotation(pin.annotation)
            stack.save()
        }
    }
    
    // Mark: MKMapViewDelegate Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? PointAnnotation {
            if editIndicator.isHidden {
                let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
                photoAlbumVC.pin = annotation.pin
                self.show(photoAlbumVC, sender: self)
                mapView.deselectAnnotation(annotation, animated: false)
            } else {
                mapView.removeAnnotation(annotation)
                stack.save()
            }
        }
    }
}
