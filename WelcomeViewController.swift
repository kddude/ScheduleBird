//
//  WelcomeViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 3/28/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func logoutTapped(sender: AnyObject) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        var alertView:UIAlertView = UIAlertView()
        alertView.title = "Logout"
        alertView.message = "You are now logged out."
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }

    @IBAction func loginTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
