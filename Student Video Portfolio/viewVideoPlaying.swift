//
//  viewVideoPlaying.swift
//  Student Video Portfolio
//
//  Created by Sara Khedr on 7/31/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit
import MediaPlayer

class viewVideoPlaying: UIViewController {
    
    var moviePlayer:MPMoviePlayerController!
    var link:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.link)
        self.view.backgroundColor = UIColor.blackColor()
        let url:NSURL = NSURL(string:self.link)!
        self.moviePlayer = MPMoviePlayerController(contentURL: url)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func composeEmail(sender: AnyObject) {
        self.performSegueWithIdentifier("sendEmail", sender: self)
    }
    
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    let MenuSegueIdentifier = "sendEmail"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! emailController
            destination.link = self.link
        }
    }
    
    
}
