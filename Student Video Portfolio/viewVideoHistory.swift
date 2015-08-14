//
//  viewVideoHistory.swift
//  Student Video Portfolio
//
//  Created by Sara Khedr on 7/31/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class viewVideoHistory: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var videoHistory: UITableView!
    
    @IBAction func backButton(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("backToPortfolio", sender: self)
    }
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var student:String = ""
    var username:String = ""
    var password:String = ""
    var videos:Array<Array<String>> = []
    var link:String = ""
    var tagID:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfoFromCore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVideos(access_token:String) {
        let query = "\([String(self.tagID).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!])"
        let request = NSMutableURLRequest(URL: NSURL(string: "http://sandbox.api.hmhco.com/v1/documents?filter_tags=\(query)")!)
        print(request)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        request.addValue("\(access_token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            if let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSArray {
                for (var i=0; i<json.count; i++) {
                    let video:Array<String> = [json[i]["title"] as! String, json[i]["note_html"] as! String, json[i]["link_url"] as! String]
                    self.videos.append(video)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.videoHistory!.reloadData()
            })
        })
        task!.resume()
    }
    
    func getSIF() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://sandbox.api.hmhco.com/v1/sample_token?client_id=2e94fbac-d2ae-4afe-9a6a-812ab51c40c7.hmhco.com&grant_type=password&username=\(self.username)&password=\(self.password)")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            print(response)
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let access_token: String = json["access_token"] as! String
            self.getVideos(access_token)
        })
        task!.resume()
    }
    
    
    
    
    func getInfoFromCore() {
        //gets the username of the person logged in
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
            if (fetchResults[i].section != "") {
                self.username = fetchResults[i].username
                self.student = fetchResults[i].name
                self.tagID = Int(fetchResults[i].tag)
                self.password = fetchResults[i].password
            }
        }
        
        self.getSIF()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        cell.userInteractionEnabled = true
        cell.textLabel!.text = self.videos[indexPath.row][0]
        cell.imageView!.image = UIImage(named: "video_icon.png")
        cell.detailTextLabel!.text = self.videos[indexPath.row][1]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.link = videos[indexPath.row][2]
        print(videos)
        self.performSegueWithIdentifier("playVideo", sender: self)
    }
    
    let MenuSegueIdentifier = "backToPortfolio"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! showMenuController
            destination.name = self.student
        }
        else if (segue.identifier == "playVideo") {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! viewVideoPlaying
            destination.link = self.link
            
        }
    }
    
}
