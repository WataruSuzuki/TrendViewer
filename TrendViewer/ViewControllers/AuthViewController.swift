//
//  AuthViewController.swift
//  FlickrKitSwiftDemo
//
//  Created by David Casserly on 02/11/2015.
//  Copyright © 2015 DevedUpLtd. All rights reserved.
//

import UIKit
import FlickrKit

class AuthViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        // Begin the authentication process
        let url = URL(string: FlickrKitService.callbackURLString)
        FlickrKit.shared().beginAuth(withCallbackURL: url!, permission: FKPermissionDelete, completion: { (url, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
                    self.webView.loadRequest(urlRequest as URLRequest)
                } else {
                    print(error!)
                }
            });
        })        
    }

    // MARK: WebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //If they click NO DONT AUTHORIZE, this is where it takes you by default... maybe take them to my own web site, or show something else
        
        let url = request.url
        
        // If it's the callback url, then lets trigger that
        if  !(url?.scheme == "http") && !(url?.scheme == "https") {
            if (UIApplication.shared.canOpenURL(url!)) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                return false
            }
        }
        return true
    }
    
    @IBAction func stop() {
        self.dismiss(animated: true, completion: nil)
    }
}
