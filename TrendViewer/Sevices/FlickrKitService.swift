//
//  FlickrKitService.swift
//  TrendViewer
//
//  Created by WataruSuzuki on 2017/01/06.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit
import FlickrKit

class FlickrKitService: NSObject {

    static var sharedInstance: FlickrKitService = {
        return FlickrKitService()
    }()
    private override init() {}
    
    static let apiKey = "348ea26ca45d5f9d3da7fff4822a7fd1"
    static let secret = "471cc96b04e60f27"
    static let callbackDirectory = "authflickr"
    static let callbackURLString = "TrendViewer://" + FlickrKitService.callbackDirectory
    let flickr = FlickrKit.shared()!
    
    var photoURLs: [URL]!
    var completeAuthOp: FKDUNetworkOperation!
    var checkAuthOp: FKDUNetworkOperation!
    var userID: String?
    var isAuthorized: Bool {
        get{
            return flickr.isAuthorized
        }
    }
    var loadedPhotos:(([URL]?) -> Void)?
    var loggedIn:(() -> Void)?
    
    func initializeFlickrKit() {
        // Initialise FlickrKit with your flickr api key and shared secret
        flickr.initialize(withAPIKey: FlickrKitService.apiKey, sharedSecret: FlickrKitService.secret)
    }
    
    func checkAuthentication() {
        // Check if there is a stored token - You should do this once on app launch
        self.checkAuthOp = flickr.checkAuthorization { (userName, userId, fullName, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    self.loggedIn?()
                } else {
                    self.requestAuthentication()
                }
            });
        }
    }

    func completeAuthentication(callBackURL: URL) {
        if callBackURL.absoluteString.contains(FlickrKitService.callbackDirectory) {
            self.completeAuthOp = flickr.completeAuth(with: callBackURL, completion: { (userName, userId, fullName, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if ((error == nil)) {
                        self.loggedIn?()
                        if let delegate = UIApplication.shared.delegate as? AppDelegate {
                            delegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        print(error!)
                    }
                });
            })
        }
    }
    
    func requestAuthentication() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController")
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.window?.rootViewController?.present(controller, animated: true, completion: nil)
        }
    }
    
    func searchPictureByTrends(keyword: String) {
        photoURLs = []
        
        flickr.call("flickr.photos.search", args: ["tags": keyword, "text": keyword, "per_page": "15"], completion: { (response, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if let response = response {
                    // Pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [String: Any]
                    let photoArray = topPhotos["photo"] as! [[String: Any]]
                    for photoDictionary in photoArray {
                        if let photoURL = self.flickr.photoURL(for: FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary) {
                            self.photoURLs.append(photoURL)
                        }
                    }
                    self.loadedPhotos?(self.photoURLs)
                }
            })
        })
    }
    
    func showInterestingPhotos() {
        photoURLs = []
        let flickrInteresting = FKFlickrInterestingnessGetList()
        flickrInteresting.per_page = "30"
        
        flickr.call(flickrInteresting) { (response, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if let response = response {
                    // Pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [String: Any]
                    let photoArray = topPhotos["photo"] as! [[String: Any]]
                    for photoDictionary in photoArray {
                        if let photoURL = self.flickr.photoURL(for: FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary) {
                            self.photoURLs.append(photoURL)
                        }
                    }
                    self.loadedPhotos?(self.photoURLs)
                }
            })
        }
    }
    
    func logout() {
        flickr.logout()
    }
}
