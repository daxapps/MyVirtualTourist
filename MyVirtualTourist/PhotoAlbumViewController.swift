//
//  PhotoAlbumViewController.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/9/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {

        @IBOutlet weak var smallMapView: MKMapView!
    //    @IBOutlet weak var collectionView: UICollectionView!
    //    @IBOutlet weak var collectionCell: UICollectionViewCell!
    
    var annotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let annotation = annotation {
            smallMapView.addAnnotation(annotation)
            smallMapView.centerCoordinate = annotation.coordinate
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    @IBAction func newCollectionButton(_ sender: Any) {
    }
}

