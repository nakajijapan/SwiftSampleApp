//
//  DetailViewController.swift
//  sample-app
//
//  Created by nakajijapan on 2015/08/14.
//  Copyright © 2015年 net.nakajijapan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    var item:Dictionary<String, AnyObject>!
    
    override func viewDidLoad() {
        self.itemTitleLabel.text = self.item["title"]  as? String
        self.itemImageView.image = nil
        
        let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        let q_main: dispatch_queue_t   = dispatch_get_main_queue();
        
        dispatch_async(q_global, {
            let stringURL = self.item["image_l"] as! String
            let imageURL = NSURL(string: stringURL)!
            let imageData = NSData(contentsOfURL: imageURL)!
            let image = UIImage(data: imageData)!
            
            dispatch_async(q_main, {
                self.itemImageView.image = image
            })
            
        })
        
    }
}
