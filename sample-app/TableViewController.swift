//
//  TableViewController.swift
//  SwiftTest01
//
//  Created by nakajijapan on 2014/06/05.
//  Copyright (c) 2014年 net.nakajijapan. All rights reserved.
//

//TableViewController
import UIKit

class TableViewController: UITableViewController {
    
    var data:NSMutableArray  = NSMutableArray()
    var loading:Bool         = false
    var currentPage:Int      = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.reloadData(1)
    }
    
    func reloadData(page: Int) {

        let url            = NSURL(string:"http://frustration.me/api/public_timeline?page=\(page)")!
        let request        = NSURLRequest(URL: url)

         NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            var json = NSJSONSerialization.JSONObjectWithData(
                data,
                options: NSJSONReadingOptions.MutableContainers,
                error: nil) as NSDictionary

            var items = json.objectForKey("items") as Array<Dictionary<String, AnyObject>> // as NSArray

            for item in items {
                self.data.addObject(item)
            }

            self.currentPage = json.objectForKey("paginator")!.objectForKey("current_page") as Int
            println("current page = \(self.currentPage)")

            self.tableView.reloadData()
            self.loading = false
        }

    }
    
    // UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {

        // bottom?
        if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) {

            var q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            var q_main: dispatch_queue_t   = dispatch_get_main_queue();

            if self.loading == true {
                return
            }

            self.loading = true

            dispatch_async(q_global, {

                self.reloadData(self.currentPage + 1)

                dispatch_async(q_main, {

                    println("end")

                    })
                })

        }
    }

    // UITableViewDataSource, UITableViewDelegate
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int  {
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: TableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as TableViewCell
        
        cell.mainImageView.image = nil
        cell.nameLabel.text      = (self.data.objectAtIndex(indexPath.row).objectForKey("title") as String)

        var q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        var q_main: dispatch_queue_t   = dispatch_get_main_queue();
        
        
        dispatch_async(q_global, {
            var url               = self.data.objectAtIndex(indexPath.row).objectForKey("image_l") as String
            var imageURL: NSURL   = NSURL(string: url)!
            var imageData: NSData = NSData(contentsOfURL: imageURL)!
            var image = self.resizeImage(UIImage(data: imageData)!, rect: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
            
            dispatch_async(q_main, {
                
                cell.mainImageView.image = image;
                println("titleLabel = \(cell.nameLabel.text)")

                })

            })

        return cell;
    }
    
    // Private
    func resizeImage(image: UIImage, rect: CGRect) -> UIImage {

        UIGraphicsBeginImageContext(rect.size);
        let resizedRect = CGRect(x: 0, y: 0, width: rect.size.width, height: image.size.height * (rect.size.width / image.size.width))
        image.drawInRect(resizedRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return resizedImage
    }
}