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
    var section:String = ""
    var videos:Array<Array<String>> = []
    var link:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfoFromCore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getInfoFromCore() {
        //gets the username of the person logged in
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
            if (fetchResults[i].section != "") {
                self.username = fetchResults[i].username
                self.section = fetchResults[i].section
                self.student = fetchResults[i].name
            }
        }
        
        //gets all videos for current user and section
        let fetchRequest1 = NSFetchRequest(entityName: "Video")
        let fetchResults1 = try!self.managedObjectContext.executeFetchRequest(fetchRequest1) as! [Video]
        for (var i=0; i<fetchResults1.count; i++) {
            if (fetchResults1[i].username == self.username && fetchResults1[i].section == self.section) {
                videos.append([fetchResults1[i].student, fetchResults1[i].date, fetchResults1[i].video])
                
            }
        }
        
        //reload table
        dispatch_async(dispatch_get_main_queue(), {
            self.videoHistory!.reloadData()
        })
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
