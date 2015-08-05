//
//  showMenuController.swift
//  Student Portfolio
//
//  Created by Sara Khedr on 7/7/15.
//  Copyright (c) 2015 Sara Khedr. All rights reserved.
//

import UIKit
import CoreData

class showMenuController: UIViewController {
    var name = String()
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet var options : UIView!

    @IBOutlet weak var viewPortfolio: UIButton!
    @IBOutlet weak var addToPortfolio: UIButton!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        //this is where we make the label
        studentNameLabel.text = name
        studentNameLabel.textColor = UIColor.whiteColor()
        studentNameLabel.font = UIFont(name: "Chalkduster", size: 25)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let b = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: Selector("logout"))
        var history = UIBarButtonItem(image: UIImage(named: "history_icon.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("viewHistory"))
        //self.navigationItem.rightBarButtonItem = b
        self.navigationItem.rightBarButtonItems = [b, history]
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "blackboard.jpg")!)
        _ = UITapGestureRecognizer(target: self, action: "imageTapped")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let MenuSegueIdentifier = "showPortfolio"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let destination = segue.destinationViewController as! portfolioController
            destination.student = self.name
        }
        else if segue.identifier == "cameraSegue" {
            let destination = segue.destinationViewController as! cameraController
            destination.name = self.name
        }
        else if segue.identifier == "configurePortfolio" {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! configurePortfolio
            destination.student = self.name
        }
        else if segue.identifier == "emailSettings" {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! emailSettings
            destination.student = self.name
        }
    }
    
    func logout() {
        let navigationController = UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("loginVC"))!)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func emailPortfolio(sender: UIButton) {
        let fetchRequest = NSFetchRequest(entityName: "Image")
        var num_images:Int = 0
        if let fetchResults = try!managedObjectContext.executeFetchRequest(fetchRequest) as? [Image] {
            for (var i=0; i<fetchResults.count; i++) {
                if fetchResults[i].name == self.name {
                    num_images += 1
                }
            }
            if (num_images > 3) {
                self.performSegueWithIdentifier("configurePortfolio", sender: self)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Can't Make Portfolio!"
                    alertView.message = "Sorry, you need at least 4 photos to make a video portfolio."
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                })
            }
        }

    }

    @IBAction func deleteAllPIctures(sender: AnyObject) {
        let alert = UIAlertController(title: "Deleting Portfolio", message: "Are you sure you want to delete all the pictures in the portfolio? You will not be able to restore them.", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("The user pressed cancel.")
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            print("The user pressed okay.")
            let fetchRequest = NSFetchRequest(entityName: "Image")
            if let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Image] {
                for (var i=0; i<fetchResults.count; i++) {
                    if fetchResults[i].name == self.name {
                        self.managedObjectContext.deleteObject(fetchResults[i])
                    }
                }

            }
        }))
    }
    
    func viewHistory() {
        print("The button was clicked to view the history.")
        self.performSegueWithIdentifier("showHistory", sender: self)
    }
    
    
    
}
