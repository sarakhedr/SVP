//
//  sendToParentController.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/14/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AVFoundation
import MediaPlayer

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

class sendToParentController: UIViewController {
    var moviePlayer:MPMoviePlayerController!
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var nameView: UIView!
    
    @IBAction func submitName(sender: AnyObject) {
        print("Do you get here?")
        self.videoName = self.nameText.text!
        self.nameView.hidden = true
        self.progressView.hidden = false
        self.activityIndicator.startAnimating()
        login()
        NSTimer.scheduledTimerWithTimeInterval(80, target: self, selector: "getVideo:", userInfo: self, repeats: false)

    }
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var key:String = ""
    var token:String = ""
    var student:String = ""
    var image_list:Array<NSData> = []
    var image_json:Array<NSString> = []
    var video_id:String = ""
    var time:Int = 0 //keeps track of time in video
    var count:Int = 0 //keeps track of index
    var dictionary:Array<Array<String>> = []
    var link:String = ""
    var videoName:String = ""
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressView.hidden = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func login() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://uapi-f1.picovico.com/v2.1/login/app")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let bodyData = "app_id=1bb40909a7efa5599657db866b13d639f388d485ce3cb590bf6adffed26ea878&app_secret=6bb8365b688623439a02a3bd41ad7e7ee3c7d0a4e1b5947a1067e5cae9970b2f"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            self.key = json["access_key"] as! String
            self.token = json["access_token"] as! String
            dispatch_async(dispatch_get_main_queue()) {
                self.makeVideo()
                self.uploadMusic()
                self.getTopUps()
            }
            self.getPhotos()
        })
        
        task!.resume()
    }
    
    func getTopUps() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://uapi-f1.picovico.com/v2.1/me")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("\(self.key)", forHTTPHeaderField: "X-Access-Key")
        request.addValue("\(self.token)", forHTTPHeaderField: "X-Access-Token")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            print(json)
            
        })
        
        task!.resume()
    }
    
    func getPhotos() {
        if (self.count < self.image_list.count) {
            self.sendPhotosRequests(self.image_list[self.count])
        }
        else {
            self.editVideo()
        }
        //for (var i=0; i<self.image_list.count; i++) {
            //print("~~~~~ I am trying to get photo \(i) into the video")
            //self.sendPhotosRequests(self.image_list[i], count: i)
        //}
    }
    
    func sendPhotosRequests(var image:NSData) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://uapi-f1.picovico.com/v2.1/me/photos")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        request.addValue("\(self.key)", forHTTPHeaderField: "X-Access-Key")
        request.addValue("\(self.token)", forHTTPHeaderField: "X-Access-Token")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //rotate the picture that will be sent to the API
        var rotated = UIImage(data: image)
        rotated = rotated!.imageRotatedByDegrees(90, flip: false)
        image = UIImageJPEGRepresentation(rotated!, 1.0)!
        request.HTTPBody = image
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            print("~~~~~ I am adding photo \(self.count) into the video")
            
            let asset_id = json["id"] as! String
            
            var end_time:Int = 0
            //print(count)
            if self.dictionary[self.count][2] == "" {
                end_time = self.time + 5
            }
            else {
                end_time = self.time + Int(self.dictionary[self.count][2])!
            }
            let name = self.dictionary[self.count][0]
            let caption = self.dictionary[self.count][1]
            let dictionary:NSDictionary = ["start_time":self.time, "end_time":end_time, "asset_id":"\(asset_id)", "name":"image", "data":["title":name, "text":caption]]
            self.time = end_time
            let theJSONData = try!NSJSONSerialization.dataWithJSONObject(
                dictionary ,
                options: NSJSONWritingOptions(rawValue: 0))
            let theJSONText = NSString(data: theJSONData,
                encoding: NSASCIIStringEncoding)
            
            self.image_json.append(theJSONText!)
            self.count += 1
            self.getPhotos()
        })
        
        task!.resume()
    }
    
    func makeVideo() {  
        let request = NSMutableURLRequest(URL: NSURL(string: "http://uapi-f1.picovico.com/v2.1/me/videos")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("\(self.key)", forHTTPHeaderField: "X-Access-Key")
        request.addValue("\(self.token)", forHTTPHeaderField: "X-Access-Token")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print("The name of this video should be \(self.student)")
        let bodyData = "name=\(self.student)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            print(json)
            self.video_id = json["id"] as! String
            print(self.video_id)


        })
        
        task!.resume()
        
    }
    
    func postVideo() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://uapi-f1.picovico.com/v2.1/me/videos/\(self.video_id)/render")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("\(self.key)", forHTTPHeaderField: "X-Access-Key")
        request.addValue("\(self.token)", forHTTPHeaderField: "X-Access-Token")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            print(json)
        })
        
        task!.resume()
 
    }
    
    func editVideo() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://uapi-f1.picovico.com/v2.1/me/videos/\(self.video_id)")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("\(self.key)", forHTTPHeaderField: "X-Access-Key")
        request.addValue("\(self.token)", forHTTPHeaderField: "X-Access-Token")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let bodyData = "style=blinds&assets=\(self.image_json)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            print(json)
            self.postVideo()
        })
        
        task!.resume()
    }
    
    func uploadMusic() {
        let dictionary:NSDictionary = ["start_time":0.0, "end_time":0.0, "asset_id":"nMiqr", "name":"music", "data":["title":"Test Music", "text":"This is a test caption for music"]]
        let theJSONData = try!NSJSONSerialization.dataWithJSONObject(
            dictionary ,
            options: NSJSONWritingOptions(rawValue: 0))
        let theJSONText = NSString(data: theJSONData,
            encoding: NSASCIIStringEncoding)
        
        self.image_json.append(theJSONText!)
    
    }
    
    func getVideo(timer: NSTimer) {
        print("Trying to play the video.")
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "emailParent:")
        self.view.backgroundColor = UIColor.blackColor()
        let url:NSURL = NSURL(string:"http://uapi-f1.picovico.com/v2.1/v/\(self.video_id)/A.mp4")!
        self.link = "http://uapi-f1.picovico.com/v2.1/v/\(self.video_id)/A.mp4"
        self.moviePlayer = MPMoviePlayerController(contentURL: url)
        self.makeNotification()
        if let player = self.moviePlayer {
            player.view.frame = CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: self.view.frame.size.height/2 + 50)
            player.view.sizeToFit()
            player.scalingMode = MPMovieScalingMode.None
            player.movieSourceType = MPMovieSourceType.File
            player.repeatMode = MPMovieRepeatMode.One;
            self.view.addSubview(player.view)
            player.play()
            
        }
      
    }
    
    @IBAction func cancelVideo(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("cancelVideo", sender: self)
    }
    
    let MenuSegueIdentifier = "returnSubmit"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            if let destination = navController.topViewController as? showMenuController {
                destination.name = self.student
            }
        }
        else if segue.identifier == "emailParent" {
            let navController = segue.destinationViewController as! UINavigationController
            if let destination = navController.topViewController as? emailController {
                destination.student = self.student
                destination.link = self.link
                destination.videoName = self.videoName
            }
        }
    }
    
    
    func emailParent(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("emailParent", sender: self)
    }
    
    func makeNotification() {
        //make a notification
        let notification = UILocalNotification()
        notification.alertBody = "Your video has been created." // text that will be displayed in the notification
        notification.alertAction = "Open App" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = NSDate(timeIntervalSinceNow: 5) // todo item due date (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    
    
}
