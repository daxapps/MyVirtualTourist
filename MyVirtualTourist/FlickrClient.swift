//
//  FlickrClient.swift
//  MyVirtualTourist
//
//  Created by Jason Crawford on 12/10/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient: NSObject {
    
    struct PhotoMeta {
        let url: URL
        let title: String
    }
    
    // MARK: HTTPMethods
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: Properties
    var session = URLSession.shared
    
    func getURL(for urlComponents: URLComponents, with path: String?, with parameters: [String: Any]?) -> URL {
        
        var components = urlComponents
        if let path = path {
            components.path += path
        }
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    // Mark: Functions
    func createAndRunTask(for request: URLRequest, with completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            completion(data, nil)
        }
        task.resume()
    }
    
    func getJson(for request: URLRequest, with completion: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
        createAndRunTask(for: request) { (data, error) in
            guard (error == nil) else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completion)
        }
    }
    
    func createRequest(for url: URL, as type: HTTPMethod?, with headers: [String: String]?, with body: String?) -> URLRequest {
        var request = URLRequest(url: url)
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if let type = type {
            request.httpMethod = type.rawValue
        }
        if let body = body {
            request.httpBody = body.data(using: String.Encoding.utf8)
        }
        return request
    }
    
    func serializeDataToJson(data: Data) throws -> [String: Any]? {
        let parsedResult: [String: Any]?
        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        return parsedResult
    }
    
    func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: [String: Any]?, _ error: NSError?) -> Void) {
        let parsedResult: [String: Any]?
        do {
            parsedResult = try serializeDataToJson(data: data)
            completionHandlerForConvertData(parsedResult, nil)
        } catch {
            let newData = data.subdata(in: Range(5...data.count))
            do {
                parsedResult = try serializeDataToJson(data: newData)
                completionHandlerForConvertData(parsedResult, nil)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
            }
        }
        
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func search(by latitude: Double, by longitude: Double, completion: ((_ photos: [PhotoMeta]?, _ error: Error?) -> Void)?) {
        let methodParameters = [
        Constants.ParameterKeys.Method: Constants.ParameterValues.SearchMethod,
        Constants.ParameterKeys.APIKey: Constants.ParameterValues.APIKey,
        Constants.ParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
        Constants.ParameterKeys.SafeSearch: Constants.ParameterValues.UseSafeSearch,
        Constants.ParameterKeys.Extras: Constants.ParameterValues.MediumURL,
        Constants.ParameterKeys.Format: Constants.ParameterValues.ResponseFormat,
        Constants.ParameterKeys.NoJSONCallback: Constants.ParameterValues.DisableJSONCallback
        ]
        
        getPhotos(with: methodParameters) {(photos, error) in
            completion?(photos, error)
        }
    }
    
    func getPhotos(with methodParameters: [String: Any], completion: ((_ photos: [PhotoMeta]?, _ error: Error?) -> Void)?) {
        let url = getURL(for: Constants.urlComponents, with: nil, with: methodParameters)
        print(url.absoluteString)
        let request = createRequest(for: url, as: HTTPMethod.get, with: nil, with: nil)
        
        getJson(for: request) { (result, error) in
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = result?[Constants.ResponseKeys.Status] as? String , stat == Constants.ResponseValues.OKStatus else {
                completion?(nil, error)
                return
                }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = result?[Constants.ResponseKeys.Photos] as? [String:Any] else {
                completion?(nil, NSError(domain: "Cannot find keys \(Constants.ResponseKeys.Photos)", code: 1, userInfo: nil))
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard (photosDictionary[Constants.ResponseKeys.Pages] as? Int) != nil else {
                completion?(nil, NSError(domain: "Cannot find key \(Constants.ResponseKeys.Pages)", code: 1, userInfo: nil))
                return
            }
            
            guard let photos = photosDictionary[Constants.ResponseKeys.Photo] as? [[String:Any]] else {
                completion?(nil, NSError(domain: "Cannot find key \(Constants.ResponseKeys.Photo)", code: 1, userInfo: nil))
                return
            }
            
            var photosArray = [PhotoMeta]()
            
            for photo in photos {
            
                guard let title = photo[Constants.ResponseKeys.Title] as? String else {
                    completion?(nil, NSError(domain: "Cannot find key \(Constants.ResponseKeys.Title)", code: 1, userInfo: nil))
                    return
                }
                
                guard let urlString = photo[Constants.ResponseKeys.MediumURL] as? String else {
                    completion?(nil, NSError(domain: "Cannot find key \(Constants.ResponseKeys.MediumURL)", code: 1, userInfo: nil))
                    return
                }
                
                guard let url = URL(string: urlString) else {
                    completion?(nil, NSError(domain: "Cannot convert \(urlString)", code: 1, userInfo: nil))
                    return
                }
                
                photosArray.append(PhotoMeta(url: url, title: title))
            }
            
            completion?(photosArray, nil)
        }
    }
    
    func getPhoto(from url: URL, completion: @escaping (_ imageData: Data?, _ error: Error?) -> Void) {
        let request = createRequest(for: url, as: HTTPMethod.get, with: nil, with: nil)
        createAndRunTask(for: request) { (data, error) in
            guard (error == nil) else {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}

