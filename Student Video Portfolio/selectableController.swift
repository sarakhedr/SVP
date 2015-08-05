//
//  selectableController.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/20/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit

class selectableController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var student:String = ""
    var images_list:Array<NSData> = []
    var collectionView: UICollectionView!
    var selected_cell:Int = -1
    var dictionary:Array<Array<String>> = Array()
    var add:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let b = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: Selector("logout"))
        self.navigationItem.rightBarButtonItem = b
        if (self.add != true) { make_dictionary() }
        makeCollectionView()
        print("The student is \(self.student)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func make_dictionary() {
        for (var i=0; i<images_list.count; i++) {
            self.dictionary.append(["","",""])
        }
    }
    
    
    func makeCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 70, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 235, height: 600)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
    }
    
    func collectionView(collection: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images_list.count
    }
    
    func collectionView(collection: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        let imageView = UIImageView(frame: CGRectMake(10, 10, cell.frame.width - 20, cell.frame.height - 270))
        let image = UIImage(data: self.images_list[indexPath.row])
        imageView.image = image
        cell.backgroundView = UIView()
        cell.backgroundView!.addSubview(imageView)
        cell.backgroundColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0)
        
        //label for Duration
        let label = UILabel(frame: CGRectMake(5, 350, cell.frame.width - 150, 30))
        label.textAlignment = NSTextAlignment.Center
        label.text = "Duration:"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Farah", size: 16)
        cell.backgroundView!.addSubview(label)
        
        //label for the actual time
        let myLabel = UILabel(frame: CGRectMake(85, 350, cell.frame.width - 80, 30))
        myLabel.textAlignment = NSTextAlignment.Left
        if (self.dictionary[indexPath.item][2] == "") {
            myLabel.text = "Not provided"
            myLabel.textColor = UIColor.redColor()
            myLabel.font = UIFont(name: "Farah", size: 16)
        }
        else {
            myLabel.text = "\(self.dictionary[indexPath.item][2]) s"
            myLabel.textColor = UIColor.blackColor()
            myLabel.font = UIFont(name: "Farah", size: 24)
        }
        
        //label for Title
        let label2 = UILabel(frame: CGRectMake(20, 380, cell.frame.width - 150, 30))
        label2.textAlignment = NSTextAlignment.Center
        label2.text = "Title:"
        label2.textColor = UIColor.whiteColor()
        label2.font = UIFont(name: "Farah", size: 16)
        cell.backgroundView!.addSubview(label2)
        
        //label for actual title
        let title = UILabel(frame: CGRectMake(85, 380, cell.frame.width - 80, 30))
        title.numberOfLines = 0
        title.textAlignment = NSTextAlignment.Left
        if (self.dictionary[indexPath.item][0] == "") {
            title.text = "Not provided"
            title.textColor = UIColor.redColor()
            title.font = UIFont(name: "Farah", size: 16)
        }
        else {
            title.text = "\(self.dictionary[indexPath.item][0])"
            title.textColor = UIColor.blackColor()
            title.font = UIFont(name: "Farah", size: 16)
        }
        
        //label for Caption
        let label3 = UILabel(frame: CGRectMake(-5, 415, cell.frame.width - 150, 30))
        label3.textAlignment = NSTextAlignment.Right
        label3.text = "Caption:"
        label3.textColor = UIColor.whiteColor()
        label3.font = UIFont(name: "Farah", size: 16)
        cell.backgroundView!.addSubview(label3)
        
        //label for actual caption
        let caption = UILabel(frame: CGRectMake(85, 405, cell.frame.width - 80, 55))
        caption.numberOfLines = 0
        caption.textAlignment = NSTextAlignment.Left
        if (self.dictionary[indexPath.item][1] == "") {
            caption.text = "Not provided"
            caption.textColor = UIColor.redColor()
            caption.font = UIFont(name: "Farah", size: 16)
        }
        else {
            caption.text = "\(self.dictionary[indexPath.item][1])"
            caption.textColor = UIColor.blackColor()
            caption.font = UIFont(name: "Farah", size: 16)
        }
        
        cell.backgroundView!.addSubview(myLabel)
        cell.backgroundView!.addSubview(title)
        cell.backgroundView!.addSubview(caption)
        
        return cell
        
    }
    
    func collectionView(collection: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selected_cell = indexPath.item
        self.performSegueWithIdentifier("editAttributes", sender: self)
    }
    
    let MenuSegueIdentifier = "editAttributes"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            //let destination = segue.destinationViewController as! editCaptionsController
            let destination = navController.topViewController as! editCaptionsController
            destination.image = self.images_list[self.selected_cell]
            destination.image_list = self.images_list
            destination.student = self.student
            destination.dictionary = self.dictionary
            destination.selected_cell = self.selected_cell
        }
        else if segue.identifier == "finishedSend" {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! sendToParentController
            destination.student = self.student
            destination.image_list = self.images_list
            destination.dictionary = self.dictionary
        }
    }
    
    @IBAction func finished(sender: AnyObject) {
        let alert = UIAlertController(title: "Creating Video", message: "Are you sure you want to create the video? You will not be able to add any more photos.", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            //print("The user pressed cancel.")
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
           // print("The user pressed okay.")
            self.performSegueWithIdentifier("finishedSend", sender: self)
        }))
    }
    
    func logout() {
        let navigationController = UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("loginVC"))!)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }

}
