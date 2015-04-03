//
//  FirstViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 3/28/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var personalButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        
        if self.revealViewController() != nil {
            personalButton.target = self.revealViewController().rightViewController
            personalButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
    }

    @IBAction func personalButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("goto_personal", sender: self)
    }

}

