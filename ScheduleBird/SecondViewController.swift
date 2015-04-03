//
//  SecondViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 3/28/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            logoutLabel.hidden = true
            loginLabel.hidden = false
        } else {
            logoutLabel.hidden = false
            loginLabel.hidden = true
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "goto_login" {
            
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
            if (isLoggedIn == 1) {
                let logoutController: UIAlertController = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .Alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                }
                logoutController.addAction(cancelAction)
                let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
                    let appDomain = NSBundle.mainBundle().bundleIdentifier
                    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
                    self.loginLabel.hidden = false
                    self.logoutLabel.hidden = true
                }
                logoutController.addAction(yesAction)
                self.presentViewController(logoutController, animated: true, completion: nil)
                
                return false
            }
                
            else {
                return true
            }
        }
        
        // by default, transition
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        logoutLabel.hidden = false
        loginLabel.hidden = true
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

