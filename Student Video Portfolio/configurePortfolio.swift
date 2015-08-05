//
//  configurePortfolio.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/16/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import Foundation
import CoreData

// UIImageExt.swift

import UIKit

class configurePortfolio: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var subCollectionView: UICollectionView!
    
    var student:String = "" //name of student
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var images:Array<NSData> = [] //list of images
    var selected:Array<NSData> = [] //list of selected images
    var selected_cell:Int = -1 //index of the item in the subview
    var alreadymade:Bool = false //allows for the code to only calculate number of images once
    var disable_background:Bool = false //allows code to disable background of view controller
    var portfolio_full:Bool = false //indication that all pictures have been selected, so subview stays
    var still_moving:Bool = false //indication that the user is trying to adjust picture arrangement
    

    @IBAction func viewCurrentOrder(sender: UIBarButtonItem) {
        self.makeSubCollection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func makeCollectionView() {
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
    
    func makeSubCollection() {
        let testFrame : CGRect = CGRectMake(150,150,450,750)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 65, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 133)
        self.disable_background = true
        
        //make the subcollection
        subCollectionView = UICollectionView(frame: testFrame, collectionViewLayout: layout)
        subCollectionView.dataSource = self
        subCollectionView.delegate = self
        subCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier:"Clicked")
        subCollectionView.backgroundColor == UIColor.grayColor()
        collectionView.alpha = 0.4
        self.view.addSubview(subCollectionView)
        
        //make the label
        let label = UILabel(frame: CGRectMake(25, 10, 425, 70))
        //label.center = CGPointMake(300, 170)
        label.textAlignment = NSTextAlignment.Left
        label.text = "The photos and their order in the portfolio:"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Farah", size: 20)
        self.subCollectionView.addSubview(label)
        
        let line = UIView(frame: CGRectMake(15,55,425,1))
        line.backgroundColor = UIColor.whiteColor()
        self.subCollectionView.addSubview(line)
        
        if (self.selected.count == self.images.count) {
            self.portfolio_full = true
        }
        else { self.portfolio_full = false }
        
        if (self.still_moving) {
            let items:Array<String> = ["Move Left","Move Right"]
            let customSC = UISegmentedControl(items: items)
            customSC.selectedSegmentIndex - 0
            
            let frame = subCollectionView.bounds
            customSC.frame = CGRectMake(frame.minX + 25, frame.minY + 655, frame.width - 225, 35)
            customSC.layer.cornerRadius = 5.0
            customSC.backgroundColor = UIColor.whiteColor()
            customSC.tintColor = UIColor(red: 0/255, green: 122/255.0, blue: 0/255.0, alpha:1.0)
            customSC.addTarget(self, action: "changePosition:", forControlEvents: .ValueChanged)
            self.subCollectionView.addSubview(customSC)
            
            let posButton   = UIButton()
            posButton.frame = CGRectMake(frame.minX + 25, frame.minY + 700, frame.width - 350, 25)
            posButton.backgroundColor = UIColor(red: 153/255, green: 200/255.0, blue: 153/255.0, alpha:1.0)
            posButton.setTitle("Done", forState: UIControlState.Normal)
            posButton.addTarget(self, action: "doneMoving:", forControlEvents: UIControlEvents.TouchUpInside)
            self.subCollectionView.addSubview(posButton)
            
            let deleteButton = UIButton()
            deleteButton.frame = CGRectMake(frame.minX + 350, frame.minY + 680, frame.width - 390, 50)
            deleteButton.setBackgroundImage(UIImage(named:"trash_port.png"), forState: UIControlState.Normal)
            deleteButton.addTarget(self, action: "deleteImage:", forControlEvents:UIControlEvents.TouchUpInside)
            self.subCollectionView.addSubview(deleteButton)
            
        }
        else if (self.selected.count < 4) {
            let doneButton   = UIButton()
            let frame = subCollectionView.bounds
            doneButton.frame = CGRectMake(frame.minX + 290, frame.minY + 700, frame.width - 325, 35)
            doneButton.backgroundColor = UIColor(red: 76/255, green:76/255, blue:76/255, alpha: 1.0)
            doneButton.setTitle("Return", forState: UIControlState.Normal)
            doneButton.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchUpInside)
            self.subCollectionView.addSubview(doneButton)
        }
        else if (self.portfolio_full == false) {
            let doneButton   = UIButton()
            let frame = subCollectionView.bounds
            doneButton.frame = CGRectMake(frame.minX + 290, frame.minY + 655, frame.width - 325, 35)
            doneButton.backgroundColor = UIColor(red: 76/255, green:76/255, blue:76/255, alpha: 1.0)
            doneButton.setTitle("Return", forState: UIControlState.Normal)
            doneButton.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchUpInside)
            self.subCollectionView.addSubview(doneButton)
            
            let moveButton   = UIButton()
            moveButton.frame = CGRectMake(frame.minX + 290, frame.minY + 700, frame.width - 325, 35)
            moveButton.backgroundColor = UIColor.blueColor()
            moveButton.setTitle("Submit", forState: UIControlState.Normal)
            moveButton.addTarget(self, action: "submit:", forControlEvents: UIControlEvents.TouchUpInside)
            self.subCollectionView.addSubview(moveButton)
        }
        else {
            let frame = subCollectionView.bounds
            let moveButton   = UIButton()
            moveButton.frame = CGRectMake(frame.minX + 290, frame.minY + 700, frame.width - 325, 35)
            moveButton.backgroundColor = UIColor.blueColor()
            moveButton.setTitle("Submit", forState: UIControlState.Normal)
            moveButton.addTarget(self, action: "submit:", forControlEvents: UIControlEvents.TouchUpInside)
            self.subCollectionView.addSubview(moveButton)
        }
    }

    
    func collectionView(collection: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collection == collectionView) {
            if (self.alreadymade == true) {return self.images.count}
            let fetchRequest = NSFetchRequest(entityName: "Image")
            if let fetchResults = try!managedObjectContext.executeFetchRequest(fetchRequest) as? [Image] {
                for (var i=0; i<fetchResults.count; i++) {
                    if fetchResults[i].name == self.student {
                        images.append(fetchResults[i].image)
                    }
                }
            }
            self.alreadymade = true
            return self.images.count
        }
        else {
            return self.selected.count
        }
    }
    
    func collectionView(collection: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collection == collectionView) {
            //need to get selected image
            let chosen_image:NSData = self.images[indexPath.item]
            var check:Bool = false
            //check the selected image to see if it has already been selected
            for (var i=0; i<self.selected.count; i++) {
                if selected[i] == chosen_image {
                    check = true
                    break
                }
            }
            if (check == false && self.disable_background == false) {
                self.selected.append(chosen_image)
                self.makeSubCollection()
            }
        }
        else {
            var chosen_image:NSData = self.selected[indexPath.item]
            self.selected_cell = indexPath.item
            self.still_moving = true
            makeSubCollection()
            self.subCollectionView.reloadData()
            
        }
    }
    
    func collectionView(collection: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collection == collectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
            let imageView = UIImageView(frame: CGRectMake(10, 10, cell.frame.width - 10, cell.frame.height - 10))
            let image = UIImage(data: self.images[indexPath.row])
            //checks if the image has already been selected and dims it
            imageView.image = image
            for (var i=0; i<selected.count; i++) {
                if selected[i] == images[indexPath.item] {
                    imageView.alpha = 0.5
                    break
                }
            }
            cell.backgroundView = UIView()
            cell.backgroundView!.addSubview(imageView)
            return cell
        }
        else {
            let cell = subCollectionView.dequeueReusableCellWithReuseIdentifier("Clicked", forIndexPath: indexPath)
            let imageView = UIImageView(frame: CGRectMake(5, 5, cell.frame.width - 10, cell.frame.height - 10))
            let image = UIImage(data: self.selected[indexPath.row])
            imageView.image = image
            cell.backgroundView = UIView()
            cell.backgroundView!.addSubview(imageView)
            if (indexPath.item == self.selected_cell) {
                cell.backgroundView?.backgroundColor = UIColor.yellowColor()
            }
            return cell

        }
    }
    
    func close(sender: UIButton) {
        self.disable_background = false
        subCollectionView.removeFromSuperview()
        collectionView.removeFromSuperview()
        makeCollectionView()
    }
    
    func submit(sender: UIButton) {
        self.performSegueWithIdentifier("editCaptions", sender: self)
    }
    
    func changePosition(sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {   //if move left is hit
            if (self.selected_cell > 0) {
                let swap:NSData = self.selected[self.selected_cell]
                self.selected[self.selected_cell] = self.selected[self.selected_cell - 1]
                self.selected[self.selected_cell - 1] = swap
                self.selected_cell = self.selected_cell - 1
                subCollectionView.removeFromSuperview()
                makeSubCollection()
                self.subCollectionView.reloadData()
            }
            else {  //if they are trying to move the leftmost picture, make segmented control not appear
                subCollectionView.reloadData()
            }
        }
        else {
            if (self.selected_cell != self.selected.count - 1) {
                let swap:NSData = self.selected[self.selected_cell]
                self.selected[self.selected_cell] = self.selected[self.selected_cell + 1]
                self.selected[self.selected_cell + 1] = swap
                self.selected_cell = self.selected_cell + 1
                subCollectionView.removeFromSuperview()
                makeSubCollection()
                self.subCollectionView.reloadData()
            }
            else {  //if they are trying to move the leftmost picture, make segmented control not appear
                subCollectionView.reloadData()
            }
        }
    }
    
    func doneMoving(sender: UIButton) {
        subCollectionView.removeFromSuperview()
        self.selected_cell = -1
        self.still_moving = false
        makeSubCollection()
    }
    
    func deleteImage(sender: UIButton) {
        selected.removeAtIndex(self.selected_cell)
        self.selected_cell = -1
        self.still_moving = false
        subCollectionView.removeFromSuperview()
        makeSubCollection()
    }
    
    
    let MenuSegueIdentifier = "editCaptions"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! selectableController
            destination.student = self.student
            destination.images_list = self.selected
        }
        else if segue.identifier == "backToMenu" {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! showMenuController
            destination.name = self.student
        }
    }

    
}

