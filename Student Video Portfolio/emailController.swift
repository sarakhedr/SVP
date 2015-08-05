//
//  emailController.swift
//  Student Video Portfolio
//
//  Created by Sara Khedr on 7/29/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class emailController: UIViewController {
    var personTo:String = ""
    var messageBody:String = ""
    var subjectBody:String = ""
    var email:String = ""
    var link:String = ""
    var student:String = ""
    var email_string:String = ""
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    var username:String = ""
    var section:String = ""
    
    var moreContacts:Array<String> = []
    
    
    @IBOutlet weak var sendee: UITextView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var subject: UITextField!
    var layout: UIView!
    var textBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFromCore()
        self.makeEmailString()
        if (self.moreContacts.count > 0) {
            self.addMoreContacts()
        }
        self.message.text  = "The video link is " + self.link + "."
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addMoreContacts() {            //EMAIL STRING IS EDITED HERE
        self.email_string = ""
        for (var i=0; i < self.moreContacts.count; i++) {
            if (i != self.moreContacts.count - 1) {
                self.email_string += self.moreContacts[i] + ", "
            }
            else {
                self.email_string += self.moreContacts[i]
            }
        }
        
        self.sendee.text = self.email_string
    }

    func getFromCore() {
        let fetchRequest = NSFetchRequest(entityName: "Email")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Email]
        if (fetchResults.count == 0) {
            self.presentSubview()
        }
        
        print("Do you get to this point?")
        
        let fetchRequest1 = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults1 = try!self.managedObjectContext.executeFetchRequest(fetchRequest1) as! [CurrentUser]
        for (var i=0; i<fetchResults1.count; i++) {
            self.username = fetchResults1[i].username
            self.section = fetchResults1[i].section
            self.student = fetchResults1[i].name
            
        }
        self.email = self.username + "@hmhco.com"
    }
    
    func saveVideoInCore() {
        //get the username and section
        print("Do you save the video in core?")
        let newVideo = NSEntityDescription.insertNewObjectForEntityForName("Video", inManagedObjectContext: self.managedObjectContext) as! Video
        newVideo.username = self.username
        newVideo.student = self.student
        newVideo.video = self.link
        newVideo.section = self.section
        newVideo.date = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    
        try!self.managedObjectContext.save()
    }

    func presentSubview() {
        let testFrame : CGRect = CGRectMake(90, 120, 560, 305)
        self.layout = UIView(frame: testFrame)
        self.layout.backgroundColor = UIColor.blackColor()
        //disabling user interaction
        self.sendee.userInteractionEnabled = false
        self.message.userInteractionEnabled = false
        self.subject.userInteractionEnabled = false
        self.view.alpha = 0.8
        self.view.addSubview(self.layout)
        
        let label = UILabel(frame: CGRectMake(25, 25, 425, 30))
        label.textAlignment = NSTextAlignment.Left
        label.text = "Uh oh. There are no emails associated with this student."
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Farah", size: 18)
        self.layout.addSubview(label)
        
        let label2 = UILabel(frame: CGRectMake(25, 50, 425, 40))
        label2.textAlignment = NSTextAlignment.Left
        label2.text = "Add one below."
        label2.textColor = UIColor.whiteColor()
        label2.font = UIFont(name: "Farah", size: 22)
        self.layout.addSubview(label2)
        
        let frame = self.layout.bounds
        let addButton   = UIButton()
        addButton.frame = CGRectMake(frame.minX + 235, frame.minY + 210, 100, 35)
        addButton.backgroundColor = UIColor(red: 153/255, green: 200/255.0, blue: 153/255.0, alpha:1.0)
        addButton.setTitle("Add Email", forState: UIControlState.Normal)
        addButton.addTarget(self, action: "addEmail:", forControlEvents: UIControlEvents.TouchUpInside)
        self.layout.addSubview(addButton)
        
        self.textBox = UITextField()
        self.textBox.frame = CGRectMake(frame.minX + 150, frame.minY + 130, 265, 35)
        self.textBox.backgroundColor = UIColor.whiteColor()
        self.layout.addSubview(self.textBox)

    }
    
    
    func sendEmail() {
        //see if it anything is empty
        if (self.sendee.text == "") {
            let alert = UIAlertController(title: "Missing field", message: "You must fill in the 'To' field to send the email.", preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                return
            }))
        }
        if (self.subject.text == "") {
            let alert = UIAlertController(title: "Missing field", message: "You must fill in the 'Subject' field to send the email.", preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                return
            }))
        }
        if (self.message.text == "") {
            let alert = UIAlertController(title: "Missing field", message: "You must fill in the 'Message' field to send the email.", preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                return
            }))
        }
        
        //set up the API call
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.sendgrid.com/api/mail.send.json")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var bodyData:String = ""
        
        //see how many people we are sending it to and change body data accordingly
        let emails = self.sendee.text.componentsSeparatedByString(", ")
        if (emails.count == 0) {
            let alert = UIAlertController(title: "Missing field", message: "You must fill in the 'To' field to send the email.", preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                return
            }))
        }
        else if (emails.count == 1) {
            bodyData = "to=\(emails[0])&"
        }
        else {
            //let basedon:String = "to[]=sara.khedr@gmail.com&to[]=khedrs@rpi.edu&subject=Test&text=testingtesting&from=gandalf@hmhco.com"
            for (var i=0 ; i < emails.count; i++) {
                bodyData += "to[]=" + emails[i] + "&"
            }
        }
        bodyData += "subject=\(self.subjectBody)&text=\(self.messageBody)&from=\(self.email)"
        print(bodyData)
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
    
        let task = try!session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if (json["message"] as! String == "success") {
                self.saveVideoInCore()
            }
        })
        task!.resume()
    }
    
    
    @IBAction func sendEmail(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sending Email", message: "Are you sure you want to send the email with the information below?", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.personTo = self.sendee.text!
            self.messageBody = self.message.text!
            self.subjectBody = self.subject.text!
            self.sendEmail()
            self.performSegueWithIdentifier("sendToPortfolio", sender: self)
        }))

    }
    
    func makeEmailString() {
        print("The student is \(self.student)")
        var emails:Array<String> = []
        let fetchRequest = NSFetchRequest(entityName: "Email")
        var fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Email]
        for (var i=0; i < fetchResults.count; i++) {
            if fetchResults[i].student == self.student {
                emails.append(fetchResults[i].email)
            }
        }
        
        for (var i=0; i < emails.count; i++) {
            if (i != emails.count - 1) {
                self.email_string += emails[i] + ", "
            }
            else {
                self.email_string += emails[i]
            }
        }
        
        self.sendee.text = self.email_string
    }
    
    func addEmail(sender: UIButton) {
        self.sendee.userInteractionEnabled = true
        self.message.userInteractionEnabled = true
        self.subject.userInteractionEnabled = true
        let newEmail = NSEntityDescription.insertNewObjectForEntityForName("Email", inManagedObjectContext: self.managedObjectContext) as! Email
        newEmail.student = self.student
        newEmail.email = self.textBox.text!
        newEmail.username = self.username
        try!self.managedObjectContext.save()
        self.layout.removeFromSuperview()
        self.makeEmailString()
    }
    
    
    @IBAction func restoreLink(sender: AnyObject) {
        let currentMessage:String = self.message.text
        self.message.text = currentMessage + " The video link is " + self.link + "."
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("cancelToPortfolio", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "addressBook" {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! showMenuController
            destination.name = self.student
        }
        else {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! showAddressBook
            let emails = self.sendee.text.componentsSeparatedByString(", ")
            destination.currentEmails = emails
            
        }
    }

}
