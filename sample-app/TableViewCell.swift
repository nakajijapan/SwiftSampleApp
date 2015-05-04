//
//  TableViewCell.swift
//  SwiftTest01
//
//  Created by nakajijapan on 2014/06/05.
//  Copyright (c) 2014年 net.nakajijapan. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBackGroundImage(image: UIImage) {
        let clip: CGImageRef! = CGImageCreateWithImageInRect(image.CGImage, self.frame)
        let clippedImage = UIImage(CGImage: clip)
        self.mainImageView.image = clippedImage;
    }
    
}
