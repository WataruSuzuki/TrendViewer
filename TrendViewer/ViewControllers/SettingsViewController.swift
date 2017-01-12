//
//  SettingsViewController.swift
//  TrendViewer
//
//  Created by WataruSuzuki on 2017/01/06.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menu.max.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        if let menu = Menu(rawValue: indexPath.row) {
            cell.textLabel?.text = menu.getTextlabel()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = Menu(rawValue: indexPath.row) {
            menu.executeMenu()
        }
    }

    enum Menu: Int {
        case logout_twitter = 0,
        logout_flickr,
        max
        
        func getTextlabel() -> String {
            switch self {
            case .logout_twitter: return "Twitterログアウト"
            case .logout_flickr : return "Flickrログアウト"
            default:
                return ""
            }
        }
        
        func executeMenu() {
            switch self {
            case .logout_twitter:
                let controller = UIAlertController(title: "(・A・)", message: "Twitterのページから認証を解除してください..", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                if let delegate = UIApplication.shared.delegate as? AppDelegate {
                    delegate.window?.rootViewController?.present(controller, animated: true, completion: nil)
                }
            case .logout_flickr:
                FlickrKitService.sharedInstance.logout()
            default:
                break
        }
        }
    }
}

