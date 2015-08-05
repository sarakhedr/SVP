//
//  imageViewController.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/14/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit

class imageViewController: UIViewController {

    @IBOutlet weak var largerImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButton(sender: UIButton) {
        let alert = UIAlertController(title: "Deleting Image", message: "Are you sure you want to delete this picture from the portfolio?", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("The user pressed cancel.")
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            print("The user pressed okay.")
            self.performSegueWithIdentifier("deleteImage", sender: self)
        }))
    }
    
    var image_display:NSData = NSData()
    var name:String = ""
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        largerImage.image = UIImage(data: self.image_display)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let MenuSegueIdentifier = "deleteImage"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let destination = segue.destinationViewController as! portfolioController
            destination.student = self.name
            destination.deleteImage = self.image_display
        }
        else if segue.identifier == "doneSegue" {
            let destination = segue.destinationViewController as! portfolioController
            destination.student = self.name
        }
        else if segue.identifier == "addToOthers" {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! addToStudents
            destination.image = self.image_display
            destination.student = self.name

        }
    }
    
    @IBAction func addToOthers(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("addToOthers", sender: self)
    }
    
    
    
    

}
