//
//  editCaptionsController.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/20/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit


class editCaptionsController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBAction func submit(sender: UIButton) {
        print("The cell I am trying to change the atributes for is \(self.selected_cell)")
        self.titleImage = titleText.text!
        self.caption = captionText.text
        self.dictionary[self.selected_cell] = [self.titleImage, self.caption, self.time]
        self.performSegueWithIdentifier("returnSubmit", sender: self)
        
    }
    
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var captionText: UITextView!
    
  
    let pickerData = ["5", "6", "7", "8", "9"]
    var image:NSData = NSData()
    var data = ["","",""]
    var titleImage:String = ""
    var caption:String = ""
    var time:String = "5"
    var image_list:Array<NSData> = []
    var student:String = ""
    var dictionary:Array<Array<String>> = []
    var selected_cell:Int = -1
    var dictionary_copy:Array<Array<String>> = []
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dictionary_copy = self.dictionary
        let b = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: Selector("logout"))
        self.navigationItem.rightBarButtonItem = b
        titleText.text = self.dictionary[self.selected_cell][0]
        captionText.text = self.dictionary[self.selected_cell][1]
        self.myPicker.dataSource = self
        self.myPicker.delegate = self
        var timeInt:Int = 0
        if (self.dictionary[self.selected_cell][2] != "") {
            print("Trying to convert \(self.dictionary[self.selected_cell][2])")
            timeInt = Int(self.dictionary[selected_cell][2])! - 5
            self.time = self.dictionary[self.selected_cell][2]
        }
        
        self.myPicker.selectRow(timeInt, inComponent: 0, animated: true)
        self.view.bringSubviewToFront(myPicker)
        showImage.image = UIImage(data: self.image)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.time = pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData:String = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            
            //color  and center the label's background
            let hue = CGFloat(row)/CGFloat(pickerData.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
            pickerLabel.textAlignment = .Center
            
        }
        let titleData = pickerData[row] + " s"
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        
        return pickerLabel
        
    }
    
    //size the components of the UIPickerView
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
    
   
    let MenuSegueIdentifier = "returnSubmit"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! selectableController
            destination.images_list = self.image_list
            destination.student = self.student
            destination.dictionary = self.dictionary
            destination.add = true
        }
        else {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! selectableController
            destination.images_list = self.image_list
            destination.student = self.student
            destination.dictionary = self.dictionary_copy
            destination.add = false
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.performSegueWithIdentifier("return", sender: self)
    }
    
}
