//
//  TrendPicturesViewController.swift
//  TrendViewer
//
//  Created by WataruSuzuki on 2017/01/06.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit

class TrendPicturesViewController: UICollectionViewController {
    
    let twitterService = TwitterAPIService.sharedInstance
    let flickrService = FlickrKitService.sharedInstance
    
    var curretTrends: [Any]!
    var photoURLs: [URL]!
    var selectedImage: UIImage!
    var searchedIndex = 0
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(PhotoLoadCell.self, forCellWithReuseIdentifier: String(describing: PhotoLoadCell.self))
        // Do any additional setup after loading the view, typically from a nib.
        photoURLs = []
        flickrService.loggedIn = {
            self.twitterService.loadedTrends = {(results) in
                if let trends = results {
                    self.curretTrends = trends
                    if(self.flickrService.isAuthorized) {
                        self.loadTrendPicrures(trends: trends)
                    } else {
                        self.flickrService.requestAuthentication()
                    }
                }
            }
            self.twitterService.loadTrend()
        }
        flickrService.checkAuthentication()
        
        self.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func incrementSearchIndex() {
        if curretTrends.count > searchedIndex {
            searchedIndex += 1
        } else {
            searchedIndex = 0
        }
    }
    
    func loadTrendPicrures(trends: [Any]) {
        flickrService.loadedPhotos = { (results) in
            self.photoURLs = results
            if 0 == self.photoURLs.count {
                self.showNotFoundAlert()
            } else {
                self.collectionView?.reloadData()
            }
        }
        
        if let trend = trends[searchedIndex] as? NSDictionary {
            if let keyword = trend["name"] as? String {
                print("keyword = \(keyword)")
                self.navigationItem.title = "話題のキーワード: " + keyword
                flickrService.searchPictureByTrends(keyword: keyword)
            }
        }
        incrementSearchIndex()
    }
    
    func showNotFoundAlert() {
        let controller = UIAlertController(title: "(・A・)", message: "とある話題のキーワードでは画像が見つかりませんでした。次のキーワードで検索してみます。", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.incrementSearchIndex()
            self.loadTrendPicrures(trends: self.curretTrends)
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    func registerCustomCell(_ nibIdentifier: String) {
        let nib = UINib(nibName: nibIdentifier, bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: nibIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoLoadCell", for: indexPath) as! PhotoLoadCell
        
        // Configure the cell
        cell.tappedCell = {(image) in
            self.selectedImage = image
            self.performSegue(withIdentifier: "PhotoViewController", sender: self)
        }
        cell.loadPhotoFromUrl(url: photoURLs[indexPath.row])
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let margin = self.view.frame.width / 2
        return CGSize(width: margin, height: margin)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "PhotoViewController":
                let controller = segue.destination as! PhotoViewController
                controller.myImage = selectedImage
                
            default:
                break
            }
        }
    }
    
    // MARK: Motion
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        print(#function + " - subtype: \(motion.rawValue) with \(event)")
        if motion == UIEventSubtype.motionShake {
            print("  SHAKE!!")
            loadTrendPicrures(trends: curretTrends)
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        print(#function + " - subtype: \(motion.rawValue) with \(event)")
    }
    
    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?) {
        print(#function + " - subtype: \(motion.rawValue) with \(event)")
    }
}

