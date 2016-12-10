//
//  Constants.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/10/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit

// MARK: - Constants

extension FlickrClient {
    struct Constants {
        
        // MARK: Flickr
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static var urlComponents: URLComponents {
            get {
                var components = URLComponents()
                components.scheme = APIScheme
                components.host = APIHost
                components.path = APIPath
                return components
            }
        }
        
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        
        
        // MARK: Flickr Parameter Keys
        struct ParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let GalleryID = "gallery_id"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            static let Page = "page"
        }
        
        // MARK: Flickr Parameter Values
        struct ParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "69682a72dba78976f7919106e9c5fe37"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
            static let GalleryID = "5704-72157622566655097"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
        }
        
        // MARK: Flickr Response Keys
        struct ResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        // MARK: Flickr Response Values
        struct ResponseValues {
            static let OKStatus = "ok"
        }
    }
}
