//
//  TwitterAPIService.swift
//  TrendViewer
//
//  Created by WataruSuzuki on 2017/01/06.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit
import STTwitter

class TwitterAPIService: NSObject {
    
    static var sharedInstance: TwitterAPIService = {
        return TwitterAPIService()
    }()
    private override init() {}

    static let apyKey = "PdLBPYUXlhQpt4AguShUIw"
    static let secretKey = "drdhGuKSingTbsDLtYpob4m5b5dn1abf9XXYyZKQzk"
    static var woeid = "23424856"//Japan

    let callbackDirectory = "twitter_access_tokens/"
    let twitterAPI = STTwitterAPI.init(oAuthConsumerKey: apyKey, consumerSecret: secretKey)!
    var loadedTrends:(([Any]?) -> Void)?
    
    func requestAccessToken() {
        twitterAPI.postTokenRequest({ (url, str) in
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }, oauthCallback: "TrendViewer://" + callbackDirectory, errorBlock: (commonErrorBlock))
    }
    
    func parseCallbackFromQueryString(queryString: String) -> Dictionary<String, String> {
        var responses = Dictionary<String, String>()
        
        let queryComponents = queryString.components(separatedBy: "&")
        for component in queryComponents {
            let pair = component.components(separatedBy: "=")
            if 2 != pair.count {
                continue
            }
            
            //"oauth_token"
            //"oauth_verifier"
            responses[pair[0]] = pair[1]
        }
        
        return responses
    }
    
    func saveTokenFromOpenURL(url: URL) {
        if url.absoluteString.contains(callbackDirectory) {
            print(url.absoluteString)
            let token = parseCallbackFromQueryString(queryString: url.query!)
            twitterAPI.postAccessTokenRequest(withPIN: token["oauth_verifier"], successBlock: (successAccessTokenRequest), errorBlock: (commonErrorBlock))
        }
    }

    func successAccessTokenRequest(oauthToken: String?, oauthTokenSecret: String?, userID: String?, screenName: String?) {
//        print("-- oauthToken: \(oauthToken)")
//        print("-- oauthTokenSecret: \(oauthTokenSecret)")
//        print("-- userID: \(userID)")
//        print("-- screenName: \(screenName)")
    }
    
    func loadTrend() {
        twitterAPI.getTrendsForWOEID(TwitterAPIService.woeid, excludeHashtags: NSNumber.init(value: 1), successBlock: (successTrendsForWOEID), errorBlock: { (error) in
            self.requestAccessToken()
        })
    }
    
    func successTrendsForWOEID(asOf: Date?, createdAt: Date?, locations: [Any]?, trends: [Any]?) {
//        print("-- asOf: \(asOf)")
//        print("-- createdAt: \(createdAt)")
//        print("-- locations: \(locations)")
//        print("-- trends: \(trends)")
        
        self.loadedTrends?(trends)
    }
    
    func commonErrorBlock(error: Error?) {
        print(error!)
        let controller = UIAlertController(title: "(・A・)!!", message: "なんかダメです..", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.window?.rootViewController?.present(controller, animated: true, completion: nil)
        }
    }
}
