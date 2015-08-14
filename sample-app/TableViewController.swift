//
//  TableViewController.swift
//  SwiftTest01
//
//  Created by nakajijapan on 2014/06/05.
//  Copyright (c) 2014年 net.nakajijapan. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var data:NSMutableArray  = NSMutableArray()
    var loading:Bool         = false
    var currentPage:Int      = 0
    var selectedRowIndex     = 0

    func reloadData(page: Int) {

        let url = NSURL(string:"http://frustration.me/api/public_timeline?page=\(page)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            let json = try! NSJSONSerialization.JSONObjectWithData(
                data!,
                options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            let items = json["items"] as! Array<Dictionary<String, AnyObject>> // as NSArray
            
            for item in items {
                self.data.addObject(item)
            }
            
            self.currentPage = json.objectForKey("paginator")!.objectForKey("current_page") as! Int
            print("current page = \(self.currentPage)")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
            self.loading = false
            
        }
        
        task.resume()

    }
    
    // MARK: - UIScrollViewDelegate

    override func scrollViewDidScroll(scrollView: UIScrollView) {

        // bottom?
        if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) {

            if self.loading == true {
                return
            }

            self.loading = true
            self.reloadData(self.currentPage + 1)

        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: TableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! TableViewCell
        
        cell.mainImageView.image = nil
        cell.nameLabel.text      = self.data[indexPath.row]["title"] as? String

        let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(q_global, {
            let stringURL         = self.data[indexPath.row]["image_l"] as! String
            let imageURL = NSURL(string: stringURL)!
            let imageData = NSData(contentsOfURL: imageURL)!
            let image = self.resizeImage(UIImage(data: imageData)!, rect: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
            
            dispatch_async(dispatch_get_main_queue(), {
                
                cell.mainImageView.image = image;
                print("titleLabel = \(cell.nameLabel.text)")

                })

            })

        return cell;
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedRowIndex = indexPath.row
        return indexPath
    }
    
    // MARK: - Private
    func resizeImage(image: UIImage, rect: CGRect) -> UIImage {

        UIGraphicsBeginImageContext(rect.size);
        let resizedRect = CGRect(x: 0, y: 0, width: rect.size.width, height: image.size.height * (rect.size.width / image.size.width))
        image.drawInRect(resizedRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return resizedImage
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            let selectedItem = self.data[selectedRowIndex] as! Dictionary<String, AnyObject>
            let viewController = segue.destinationViewController as! DetailViewController
            viewController.item = selectedItem
        }
    }
}