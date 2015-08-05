//
//  portfolioController.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/10/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class portfolioController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var student:String = ""
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var images:Array<NSData> = []
    var image:NSData = NSData()
    var chosen_image:NSData = NSData()
    var add_Image:Bool = false
    var deleteImage:NSData = NSData()
    //need to check from where it is coming from
    //need to add back buttons
    //need to delete functionality
    
    func saveinCore(image:NSData, addImage:Bool) {
        let fetchRequest = NSFetchRequest(entityName: "Person")
        var exists:Bool = false
        if let fetchResults = try!managedObjectContext.executeFetchRequest(fetchRequest) as? [Person] {
            for (var i=0; i<fetchResults.count; i++) {
                if fetchResults[i].name == self.student {
                    exists = true
                    break
                }
            }
            if (exists == false) {
                let newStudent = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: self.managedObjectContext) as! Person
                newStudent.name = self.student
            }
        }
        if (addImage == true) {
            let newImage = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: self.managedObjectContext) as! Image
            newImage.name = self.student
            newImage.image = image
        }
        try!self.managedObjectContext.save()
        
        
    }
    
    func deleteImage(image:NSData) {
        let fetchRequest = NSFetchRequest(entityName: "Image")
        if let fetchResults = try!managedObjectContext.executeFetchRequest(fetchRequest) as? [Image] {
            for (var i=0; i<fetchResults.count; i++) {
                if fetchResults[i].name == self.student {
                    if fetchResults[i].image == self.deleteImage {
                        managedObjectContext.deleteObject(fetchResults[i])
                        try!self.managedObjectContext.save()
                        self.viewDidLoad()
                    }
                }
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Adding an image to \(self.student)")
        saveinCore(self.image, addImage: self.add_Image)
        if (self.deleteImage != NSData()) {
            deleteImage(self.deleteImage)
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 70, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 200)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Image")
        if let fetchResults = try!managedObjectContext.executeFetchRequest(fetchRequest) as? [Image] {
            for (var i=0; i<fetchResults.count; i++) {
                if fetchResults[i].name == self.student {
                    print("Showing a picture for the given student")
                    images.append(fetchResults[i].image)
                }
            }
        }

        return self.images.count
    }
    
    func collectionView(collectionview: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        _ = collectionView.cellForItemAtIndexPath(indexPath)
        print("Trying to show the image in a bigger view.")
        self.chosen_image = self.images[indexPath.item]
        print("The item chosen is \(indexPath.item)")
        performSegueWithIdentifier("closerViewSegue", sender: self)
    }
    
    let MenuSegueIdentifier = "closerViewSegue"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! imageViewController
            destination.image_display = self.chosen_image
            destination.name = self.student
        }
        else if segue.identifier == "addPicture" {
            let destination = segue.destinationViewController as! cameraController
            destination.name = self.student
        }
        else if segue.identifier == "backToMenu" {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! showMenuController
            destination.name = self.student
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        //cell.backgroundColor = UIColor.orangeColor()
        let imageView = UIImageView(frame: CGRectMake(10, 10, cell.frame.width - 10, cell.frame.height - 10))
        let image = UIImage(data: self.images[indexPath.row])
        imageView.image = image
        cell.backgroundView = UIView()
        cell.backgroundView!.addSubview(imageView)
        return cell
    }
    

}
