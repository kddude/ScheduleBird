//
//  ProfileViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/17/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureLarge: UIImageView!
    @IBOutlet weak var profilePictureSmall: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cellphoneLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var accLabels = ["FNAME", "LNAME", "USERID", "EMAIL", "CELLPHONE", "CATEGORY", "PHOTOURL"]
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let fname = prefs.stringForKey("FNAME")
        let lname = prefs.stringForKey("LNAME")
        nameLabel.text = "\(fname!) \(lname!)"
        userIDLabel.text = prefs.stringForKey("USERID")
        emailLabel.text = prefs.stringForKey("EMAIL")
        cellphoneLabel.text = prefs.stringForKey("CELLPHONE")
        positionLabel.text = prefs.stringForKey("CATEGORY")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func editButton(sender: AnyObject) {
        self.performSegueWithIdentifier("edit_profile", sender: self)
    }

    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
