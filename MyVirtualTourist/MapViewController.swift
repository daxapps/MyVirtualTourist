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

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editIndicator: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // set initial location in Honolulu
//        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
//        centerMapOnLocation(location: initialLocation)
        
        // Set map view delegate with controller
        self.mapView.delegate = self
        
        let newYorkLocation = CLLocationCoordinate2DMake(40.730872, -74.003066)
        // Drop a pin
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = newYorkLocation
        dropPin.title = "New York City"
        mapView.addAnnotation(dropPin)
        
    }
    
    // Mark: MKMapViewDelegate Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    @IBAction func removeMapPin(_ sender: Any) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
