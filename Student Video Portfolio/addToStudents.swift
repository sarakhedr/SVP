//
//  addToStudents.swift
//  Student Video Portfolio
//
//  Created by Sara Khedr on 8/3/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class addToStudents: UITableViewController {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var students:Array<String> = []
    var selectedStudents:Array<String> = []
    var selectBool:Bool = false
    var alreadyHasIt:Array<String> = []
    
    var username:String = ""
    var password:String = ""
    var refId:String = ""
    
    var image:NSData = NSData()
    var student:String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getInfoFromCore()
        getSIF()
        let tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.backgroundColor = UIColor.whiteColor()
        
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
                self.password = fetchResults[i].password
                self.refId = fetchResults[i].section
            }
        }
        
        let fetchRequest1 = NSFetchRequest(entityName: "Image")
        let fetchResults1 = try!self.managedObjectContext.executeFetchRequest(fetchRequest1) as! [Image]
        for (var i=0; i<fetchResults1.count; i++) {
            if (fetchResults1[i].image == self.image) {
                self.alreadyHasIt.append(fetchResults1[i].name)
                
            }
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        cell.imageView!.image = UIImage(named: "user_student.png")
        cell.textLabel?.text = self.students[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.accessoryType = .None
        if let j = self.selectedStudents.indexOf(self.students[indexPath.row]) {
            cell.accessoryType = .Checkmark
        }
        if let j = self.alreadyHasIt.indexOf(self.students[indexPath.row]) {
            cell.accessoryType = .Checkmark
        }
        if (self.selectBool) {
            cell.accessoryType = .Checkmark
            cell.userInteractionEnabled = true
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //if it is already select it, remove from selectedEmails list
        if let j = self.selectedStudents.indexOf(self.students[indexPath.row]) {
            self.selectedStudents.removeAtIndex(j)
        }
            //if not, add it to the lsit
        else {
            selectedStudents.append(self.students[indexPath.row])
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    
    func getSIF() {
        print("Do you get here?")
        let request = NSMutableURLRequest(URL: NSURL(string: "http://sandbox.api.hmhco.com/v1/sample_token?client_id=2e94fbac-d2ae-4afe-9a6a-812ab51c40c7.hmhco.com&grant_type=password&username=\(self.username)&password=\(self.password)")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            print("\(response)")
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let access_token: NSString = json["access_token"] as? NSString {
                self.getStudents(access_token as String)
            }
        })
        task!.resume()
    }
    
    func getStudentName(access_token:String, refId:String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://sandbox.api.hmhco.com/v1/students/\(refId)")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        request.addValue("\(access_token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let name_json1 = json["name"] as! NSDictionary
            let name_json2 = name_json1["actualNameOfRecord"] as! NSDictionary
            if let name:String = name_json2["fullName"] as? String {
                self.students.append(name)
                dispatch_async(dispatch_get_main_queue(), {
                    self.students.sortInPlace()
                    self.tableView.reloadData()
                })
            }
        })
        
        task!.resume()
    }
    
    func getStudents(access_token: String) {
        print("Do you get the student-section associations?")
        let request = NSMutableURLRequest(URL: NSURL(string: "http://sandbox.api.hmhco.com/v1/studentSectionAssociations")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        request.addValue("\(access_token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            print(response)
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSArray
            for var index = 0; index < json.count; index++ {
                print(json[index])
                print("The section ID is \(self.refId)")
                if let student:String = json[Int(index)]["studentRefId"] as? String {
                    
                    if json[Int(index)]["sectionRefId"] as! String == self.refId {
                        print("Do you send the student off?")
                        self.getStudentName(access_token, refId: student)
                    }
                }
            }
        })
        
        task!.resume()
    }
    
    
    @IBAction func submitToOthers(sender: UIBarButtonItem) {
        print("Currently trying to submit to other portfolios.")
        for (var i=0; i < self.selectedStudents.count; i++) {
            let newImage = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: self.managedObjectContext) as! Image
            newImage.name = selectedStudents[i]
            newImage.image = self.image
        }
        try!self.managedObjectContext.save()
        self.performSegueWithIdentifier("backToDisplay", sender: self)
    }

    let MenuSegueIdentifier = "backToDisplay"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! imageViewController
            destination.image_display = self.image
            destination.name = self.student

        }
    }
    

    
}
