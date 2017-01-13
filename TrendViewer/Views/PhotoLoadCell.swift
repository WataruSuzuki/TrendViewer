//
//  PhotoLoadCell.swift
//  TrendViewer
//
//  Created by WataruSuzuki on 2017/01/06.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit

@IBDesignable
class PhotoLoadCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    var tappedCell:((UIImage) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PhotoLoadCell", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UICollectionViewCell
        addSubview(view)
    }
    
    func loadPhotoFromUrl(url: URL) {
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.image = UIImage(data: data!)
            }
        }).resume()
    }
    
    @IBAction func tapImage(sender: Any) {
        if let image = self.imageView.image {
            self.tappedCell?(image)
        }
    }
}
