//
//  PhotoAlbumViewController.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/9/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: CoreDataViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var tabBarButton: UIBarButtonItem!
    @IBOutlet weak var noPhotosFound: UILabel!
    
    var pin: Pin?
    var photos = [Photo]()
    let maxPhotos: Int = 24
    
    let itemsPerRowInPortrait = 3
    let itemsPerRowInLandscape = 6
    let spaceBetweenItems: CGFloat = 3.0
    
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.allowsMultipleSelection = true
        configureFlowLayout(viewWidth: view.frame.width, viewHeight: view.frame.height)
        
        addAnnotationToMapView(completion: nil)
        
        annotation.coordinate.latitude = (pin?.latitude)! as Double
        annotation.coordinate.longitude = (pin?.longitude)! as Double
        
        centerMapOnLocation(annotation, regionRadius: 500.0)
        
        fetchStoredPhotos() {
            performUpdatesOnMain {
                self.photoCollectionView.reloadData()
            }
        }
    }
    
    // Mark: Layout Functions
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let newWidth = view.frame.height
        let newHeight = view.frame.width
        configureFlowLayout(viewWidth: newWidth, viewHeight: newHeight)
    }
    
    func configureFlowLayout(viewWidth width: CGFloat, viewHeight height: CGFloat) {
        let numPerRow: Int
        if width < height {
            numPerRow = itemsPerRowInPortrait
        } else {
            numPerRow = itemsPerRowInLandscape
        }
        let dimension = (width - (CGFloat(numPerRow-1) * spaceBetweenItems)) / CGFloat(numPerRow)
        flowLayout.minimumInteritemSpacing = spaceBetweenItems
        flowLayout.minimumLineSpacing = spaceBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // Mark: Photo Management Functions
    func setFetchedResultsController() {
        photos.removeAll()
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        if let pin = pin {
            let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
            fetchRequst.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()
    }
    
    func fetchStoredPhotos(completion: (() -> Void)?) {
        setFetchedResultsController()
        if let numSavedPhotos = fetchedResultsController?.fetchedObjects?.count {
            if numSavedPhotos == 0 {
                setPhotos() {
                    self.stack.save()
                    completion?()
                }
            } else {
                for item in fetchedResultsController!.fetchedObjects! {
                    if let photo = item as? Photo {
                        photos.append(photo)
                    }
                }
                completion?()
            }
        }
    }
    
    func setPhotos(completion: (() -> Void)?) {
        noPhotosFound.isHidden = true
        if let pin = pin {
            let client = FlickrClient.sharedInstance()
            client.search(by: pin.latitude, by: pin.longitude) { (photosArray, error) in
                guard let photosArray = photosArray else {
                    self.presentError(title: "Unable to download photos", errorMessage: error!.localizedDescription)
                    return
                }
                if let totalPhotos = Int16(exactly: photosArray.count) {
                    self.pin?.totalPhotos = totalPhotos
                } else {
                    self.pin?.totalPhotos = 0
                }
                let startIndex: Int
                
                if self.pin!.set == 0 || self.pin!.totalPhotos == 0 {
                    startIndex = photosArray.startIndex
                } else {
                    startIndex = (self.maxPhotos * Int(self.pin!.set)) % Int(self.pin!.totalPhotos)
                }
                
                if photosArray.count == 1 {
                    self.photos.append(self.createPhoto(from: photosArray[0]))
                } else if photosArray.count > 1 {
                    self.createPhotos(from: photosArray[startIndex...photosArray.endIndex-1])
                    if self.photos.count < self.maxPhotos && photosArray.count >= self.maxPhotos {
                        self.createPhotos(from: photosArray[photosArray.startIndex...photosArray.endIndex-1])
                    }
                } else if photosArray.count == 0 {
                    self.noPhotosFound.isHidden = false
                }
                completion?()
            }
        }
    }
    
    func createPhotos(from metaArray: ArraySlice<FlickrClient.PhotoMeta>) {
        for photoMeta in metaArray {
            if self.photos.count >= self.maxPhotos {
                break
            }
            let photo = self.createPhoto(from: photoMeta)
            self.photos.append(photo)
        }
    }
    
    func createPhoto(from meta: FlickrClient.PhotoMeta) -> Photo {
        return Photo(with: meta.url.absoluteString, pin: pin!, title: meta.title, insertInto: fetchedResultsController!.managedObjectContext)
    }
    
    func downloadPhoto(photo: Photo, completion: (() -> Void)?) {
        let flickrClient = FlickrClient.sharedInstance()
        guard let urlString = photo.url else {
            fatalError("No urlString found")
        }
        guard let url = URL(string: urlString) else {
            fatalError("Unable to convert \(urlString) to URL")
        }
        flickrClient.getPhoto(from: url) { (data, error) in
            if let error = error {
                performUpdatesOnMain {
                    self.presentError(title: "Error downloading photos", errorMessage: error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                fatalError("No data found")
            }
            
            photo.data = data as NSData?
            
            guard (photo.image != nil) else {
                fatalError("no image found")
            }
            completion?()
        }
    }
    
    func updateButton() {
        if photoCollectionView.indexPathsForSelectedItems?.count != 0 {
            tabBarButton.title = "Delete Selected Photos"
        } else {
            tabBarButton.title = "New Collection"
        }
    }
    
    func deletePhotos() {
        var photosToDelete = [Photo]()
        for indexPath in photoCollectionView.indexPathsForSelectedItems! {
            photosToDelete.append(photos[indexPath.item])
        }
        
        for photo in photosToDelete {
            fetchedResultsController!.managedObjectContext.delete(photo)
            photos.remove(at: photos.index(of: photo)!)
        }
        stack.save()
        photoCollectionView.reloadData()
        updateButton()
    }
    
    func getNewCollection() {
        stack.delete(objects: photos)
        stack.save()
        photos.removeAll()
        pin?.set += 1
        setPhotos {
            self.stack.save()
            performUpdatesOnMain {
                self.photoCollectionView.reloadData()
                self.updateButton()
            }
        }
    }
    
    @IBAction func tabBarButton(_ sender: AnyObject) {
        if photoCollectionView.indexPathsForSelectedItems?.count != 0 {
            deletePhotos()
        } else {
            getNewCollection()
        }
    }
    
    // Mark: Map Management Functions
    func addAnnotationToMapView(completion: (() -> Void)?) {
        
        if let annotation = pin?.annotation {
            mapView.addAnnotation(annotation)
            mapView.centerCoordinate = annotation.coordinate
        }
        completion?()
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
    
    //Centers the map on a coordinate (with lat and lon) with requisite radius
    func centerMapOnLocation(_ location: MKPointAnnotation, regionRadius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        photos[indexPath.item].index = Int16(exactly: indexPath.item)!
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.alpha = 1.0
        let photo = photos[indexPath.item]
        if let image = photo.image {
            print("persisted photo")
            cell.imageView.image = image
        } else {
            print("downloading photo...")
            cell.activityIndicator.startAnimating()
            downloadPhoto(photo: photo) {
                self.stack.save()
                performUpdatesOnMain {
                    cell.activityIndicator.stopAnimating()
                    cell.imageView.image = photo.image
                }
            }
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        print(cell.isSelected)
        if cell.isSelected {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        print(cell.isSelected)
        cell.imageView.alpha = 0.5
        updateButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        if cell.isSelected {
            return true
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        print(cell.isSelected)
        cell.imageView.alpha = 1.0
        updateButton()
    }
}

