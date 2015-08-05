//
//  homeViewController.swift
//  Fix Portfolio
//
//  Created by Sara Khedr on 7/9/15.
//  Copyright © 2015 Sara Khedr. All rights reserved.
//

import UIKit

class homeViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override  func viewDidAppear(animated: Bool) {
        self.performSegueWithIdentifier("gotto_login", sender: self)
        
    }
    
    @IBAction func logoutTapped(sender: UIButton) {
        self.performSegueWithIdentifier("gotto_login", sender: self)
    }
    

}
