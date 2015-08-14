//
//  loginVC.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/9/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class loginVC: UIViewController {
    
    var realUser:Bool = true
    var username:String = ""
    var password:String = ""
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    @IBOutlet weak var textUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBAction func signinTapped(sender: UIButton) {
        username = textUsername.text!
        password = txtPassword.text!
        tryLogin(username as String, password: password)
    }
    
    func tryLogin(username:String, password:String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://sandbox.api.hmhco.com/v1/sample_token?client_id=2e94fbac-d2ae-4afe-9a6a-812ab51c40c7.hmhco.com&grant_type=password&username=\(username)&password=\(password)")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        request.timeoutInterval = 70
        
        let task = try!session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let _: NSString = json["error"] as? NSString {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign up Failed!"
                    alertView.message = "You have entered an incorrect username or password."
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("showSuccessfulLogin", sender: self)
                }
            }
        })
        task!.resume()
        
    }
    
    let MenuSegueIdentifier = "showSuccessfulLogin"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! sectionViewController
            destination.username = self.username
            destination.password = self.password
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteCurrentUser()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteCurrentUser() {
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
            managedObjectContext.deleteObject(fetchResults[i])
        }

    }


}
