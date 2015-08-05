
//
//  ViewController.swift
//  iTunes
//
//  Created by Sara Khedr on 7/1/15.
//  Copyright (c) 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var appsTableView : UITableView!
    @IBOutlet var options : UIView!
    
    var student_names = [String]()
    var section_id:String = ""
    var username:String = ""
    var password:String = ""
    var student_name:String = ""
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let b = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: Selector("logout"))
        self.navigationItem.rightBarButtonItem = b
        getInfoFromCore()
        getSIF()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getInfoFromCore() {        //this function allows you to go back from any page and make requests with stored data
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
            if (fetchResults[i].section != "") {
                self.username = fetchResults[i].username
                self.password = fetchResults[i].password
                self.section_id = fetchResults[i].section
            }
        }
    }
    
    func storeCurrentUser() { //stores the current user information, so common information does not need to continually 
                              // be passed
        print("Trying to add \(self.student_name) to CoreData")
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
            managedObjectContext.deleteObject(fetchResults[i])
        }
        let currentUser = NSEntityDescription.insertNewObjectForEntityForName("CurrentUser", inManagedObjectContext: self.managedObjectContext) as! CurrentUser
        currentUser.username = self.username
        currentUser.password = self.password
        currentUser.section = self.section_id
        currentUser.name = self.student_name
        try!self.managedObjectContext.save()
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
                self.student_names.append(name)
                dispatch_async(dispatch_get_main_queue(), {
                    self.appsTableView!.reloadData()
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
                print("The section ID is \(self.section_id)")
                if let student:String = json[Int(index)]["studentRefId"] as? String {
                    
                    if json[Int(index)]["sectionRefId"] as! String == self.section_id {
                        print("Do you send the student off?")
                        self.getStudentName(access_token, refId: student)
                    }
                }
            }
        })
        
        task!.resume()
    }
    
    
    let MenuSegueIdentifier = "showMenuSegue"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            if let destination = navController.topViewController as? showMenuController {
                if let nameIndex = self.appsTableView.indexPathForSelectedRow?.row {
                    self.student_name = self.student_names[nameIndex]
                    self.storeCurrentUser()
                    destination.name = self.student_names[nameIndex]
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(self.student_names.count)
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        let numCells = Int(screenHeight/44)
        //print(numCells)
        var num:Int = self.student_names.count
        if self.student_names.count < numCells {
            num = numCells
        }
        self.student_names.sortInPlace()
        return num
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (appsTableView.dequeueReusableCellWithIdentifier("MyTestCell"))!
        if indexPath.row > student_names.count-1 {
            cell.textLabel!.text = ""
            cell.userInteractionEnabled = false
            if indexPath.row%2 == 0 {
                cell.backgroundColor = UIColor(red: 163/255, green: 163/255.0, blue: 163/255.0, alpha:1.0)
            }
            else {
                cell.backgroundColor = UIColor(red: 99/255, green: 99/255.0, blue: 99/255.0, alpha:0.85)
            }
            return cell
        }
        else {
            cell.userInteractionEnabled = true
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red: 51/255, green: 102/255.0, blue: 255/255.0, alpha:1.0)
            cell.selectedBackgroundView = backgroundView
            cell.textLabel!.text =  "\t" + student_names[indexPath.row]
            cell.textLabel!.font = UIFont(name: "Noteworthy-Bold", size: 15)
            cell.imageView!.image = UIImage(named: "user_student.png")
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if indexPath.row%2 == 0 {
                cell.backgroundColor = UIColor(red: 163/255, green: 163/255.0, blue: 163/255.0, alpha:0.85)
            }
            else {
                cell.backgroundColor = UIColor(red: 99/255, green: 99/255.0, blue: 99/255.0, alpha:0.85)
            }
        }
        return cell
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
    
    func logout() {
        let navigationController = UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("loginVC"))!)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
}
