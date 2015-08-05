//
//  addPortfolioOptions.swift
//  Student Video Portfolio
//
//  Created by Sara Khedr on 7/31/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class DataTableViewController: UITableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        
        return cell
    }
    
}

class addPortfolioOptions: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var emailView: UITableView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var student:String = ""
    var image:NSData = NSData()
    var emails:Array<Array<String>> = []
    var students:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        //gets all videos for current user and section
        let fetchRequest1 = NSFetchRequest(entityName: "Email")
        let fetchResults1 = try!self.managedObjectContext.executeFetchRequest(fetchRequest1) as! [Email]
        for (var i=0; i<fetchResults1.count; i++) {
            if (fetchResults1[i].username == username) {
                emails.append([fetchResults1[i].student, fetchResults1[i].email])   //appends to email list
                
                var check:Bool = false                      //appends to student list, which is what cells are grouped by
                for (var j=0; j < students.count; j++) {
                    if (students[j] == fetchResults1[i].student) {
                        check = true
                        break
                    }
                }
                if (check == false) {
                    students.append(fetchResults1[i].student)
                }
            }
        }
        
        //reload table
        dispatch_async(dispatch_get_main_queue(), {
            self.emailView!.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.students.count  //number of students  or groups
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Do you get here?")
        var count:Int = 0                           //number of emails under each group
        for (var i=0; i < emails.count; i++) {
            if emails[i][0] == students[section] {
                count+=1
            }
        }
        return count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("Do you get here?")
        return students[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("Do you get here?")
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        
        return cell
    }
}
