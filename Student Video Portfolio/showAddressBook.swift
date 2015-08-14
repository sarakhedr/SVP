//
//  showAddressBook.swift
//  Student Video Portfolio
//
//  Created by Sara Khedr on 8/3/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class showAddressBook: UITableViewController {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var students:Array<String> = []
    var emails:Array<Array<String>> = []
    var selectedEmails:Array<String> = []
    var selectBool:Bool = false
    var currentEmails:Array<String> = []
    
    var currentSubject:String = ""
    var currentMessage:String = ""
    var link:String = ""
    var videoName:String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedEmails = self.currentEmails
        getInfoFromCore()
        var tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.backgroundColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getInfoFromCore() {
        
        //gets the username of the person logged in
        var username:String = ""
        var section:String = ""
        
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
            if (fetchResults[i].section != "") {
                username = fetchResults[i].username
                section = fetchResults[i].section
            }
        }
        
        //gets emails for each associated student
        let fetchRequest1 = NSFetchRequest(entityName: "Email")
        let fetchResults1 = try!self.managedObjectContext.executeFetchRequest(fetchRequest1) as! [Email]
        for (var i=0; i<fetchResults1.count; i++) {
            if (fetchResults1[i].username == username) {
                if let j = students.indexOf(fetchResults1[i].student) {
                    emails[j].append(fetchResults1[i].email)
                }
                else {
                    students.append(fetchResults1[i].student)
                    emails.append([fetchResults1[i].email])
                }
            }
        }
        print(self.students)
        print(self.emails)
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.students.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section > self.emails.count - 1) {
            return 0
        }
        return self.emails[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let name:String = self.students[section]
        return name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        cell.imageView!.image = UIImage(named: "user_student.png")
        cell.textLabel?.text = self.emails[indexPath.section][indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.accessoryType = .None
        if let j = self.selectedEmails.indexOf(self.emails[indexPath.section][indexPath.row]) {
            cell.accessoryType = .Checkmark
        }
        if let j = self.currentEmails.indexOf(self.emails[indexPath.section][indexPath.row]) {
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
        if let j = self.selectedEmails.indexOf(emails[indexPath.section][indexPath.row]) {
            selectedEmails.removeAtIndex(j)
        }
        //if not, add it to the lsit
        else {
            selectedEmails.append(emails[indexPath.section][indexPath.row])
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    @IBAction func selectAllEmails(sender: UIBarButtonItem) {
        self.selectBool = true
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    @IBAction func sendContacts(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("sendContact", sender: self)
    }
    
    let MenuSegueIdentifier = "sendContact"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        if let destination = navController.topViewController as? emailController {
            destination.moreContacts = self.selectedEmails
            destination.subjectBody = self.currentSubject
            destination.messageBody = self.currentMessage
            destination.added = true
            destination.link = self.link
            destination.videoName = self.videoName
        }
    }
    
    
    @IBAction func backButton(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("sendContact", sender: self)
    }
    
}
