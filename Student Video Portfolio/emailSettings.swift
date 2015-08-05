//
//  emailSettings.swift
//  Student Video Portfolio
//
//  Created by Sara Khedr on 7/30/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class emailSettings: UIViewController, UITableViewDataSource, UITableViewDelegate { 

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteEmail(sender: AnyObject) {
        self.email_list.removeAtIndex(self.index)
        deleteFromCore()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView!.reloadData()
        })
        deleteButton.hidden = true
    }
    
    @IBAction func addEmail(sender: UIButton) {
        self.email = emailText.text!
        self.email_list.append(self.email)
        //add into CoreData
        let newEmail = NSEntityDescription.insertNewObjectForEntityForName("Email", inManagedObjectContext: self.managedObjectContext) as! Email
        newEmail.student = self.student
        newEmail.email = self.email
        newEmail.username = self.username
        try!self.managedObjectContext.save()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView!.reloadData()
            self.emailText.text = ""
        })
    }
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var email:String = ""
    var email_list:Array<String> = []
    var student:String = ""
    var selected:String = ""
    var index:Int = -1
    var username:String = ""
    
    func getFromCore() {
        let fR = NSFetchRequest(entityName: "CurrentUser")
        let fRq = try!self.managedObjectContext.executeFetchRequest(fR) as! [CurrentUser]
        self.username = fRq[0].username
        let fetchRequest = NSFetchRequest(entityName: "Email")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Email]
        for (var i=0; i<fetchResults.count; i++) {
            if (fetchResults[i].student == self.student) {
                email_list.append(fetchResults[i].email)
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView!.reloadData()
        })
    }
    
    func deleteFromCore() {
        let fetchRequest = NSFetchRequest(entityName: "Email")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Email]
        for (var i=0; i<fetchResults.count; i++) {
            if fetchResults[i].email == self.selected {
                self.managedObjectContext.deleteObject(fetchResults[i])
                try!self.managedObjectContext.save()
                self.selected = ""
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.email_list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        cell.userInteractionEnabled = true
        cell.textLabel!.text = self.email_list[indexPath.row]
        cell.imageView!.image = UIImage(named: "email_icon copy.png")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selected = self.email_list[indexPath.row]
        self.index = indexPath.row
        print(self.index)
        deleteButton.hidden = false
        
    }
    
    let MenuSegueIdentifier = "backToPortfolio"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! showMenuController
            destination.name = self.student
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.hidden = true
        print(self.student)
        getFromCore()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
