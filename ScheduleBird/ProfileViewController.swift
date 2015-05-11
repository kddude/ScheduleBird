//
//  ProfileViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/17/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import Alamofire
import UIKit
import SWXMLHash

class ProfileViewController: UIViewController {

    @IBOutlet weak var viewScheduleButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var profilePictureLarge: UIImageView!
    @IBOutlet weak var profilePictureSmall: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cellphoneLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    var selfFlag: Bool?
    var passedID: String?
    var passedName: String?
    var passedEmail: String?
    var passedPhone: String?
    var passedPic: UIImage?
    var backupCall = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfFlag = true
        if let id = passedID {
            closeButton.title = "< Work"
            selfFlag = false
        }
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        profileView.hidden = true
        
        let image = profilePictureSmall
        image.layer.borderWidth=1.0
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.whiteColor().CGColor
        image.layer.cornerRadius = 13
        image.layer.cornerRadius = image.frame.size.height/2
        image.clipsToBounds = true
        
        if let id = passedID {
            
            let user = UserInfo()

            let custom: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = {
                (URLRequest, parameters) in
                var soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getStaffDetails xmlns='http://www.schedulefly.com/api/'><acct_userid>\(user.getUsername())</acct_userid><acct_password>\(user.getPassword())</acct_password><employee_id>\(self.passedID)</employee_id></getStaffDetails></soap12:Body></soap12:Envelope>"
                
                
                var theRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.schedulefly.com/webservice.asmx")!)
                theRequest.addValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                theRequest.addValue(String(count(soapMessage)), forHTTPHeaderField: "Content-Length")
                theRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) // or false
                
                let mutableURLRequest = URLRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
                mutableURLRequest.setValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.setValue(String(count(soapMessage)), forHTTPHeaderField: "Content-Length")
                mutableURLRequest.HTTPBody = theRequest.HTTPBody
                return (mutableURLRequest, nil)
            }
            
            Alamofire.request(.POST, "http://api.schedulefly.com/webservice.asmx", parameters: Dictionary(), encoding: .Custom(custom)).responseString { (request, response, data, error) -> Void in
                
                if (error == nil) {
                    let callType = "getStaffDetails"
                    println(data!)
                    if data!.rangeOfString("Error") != nil {
                        
                        let custom1: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = {
                            (URLRequest, parameters) in
                            var soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getStaff xmlns='http://www.schedulefly.com/api/'><acct_userid>\(user.getUsername())</acct_userid><acct_password>\(user.getPassword())</acct_password></getStaff></soap12:Body></soap12:Envelope>"
                            
                            
                            var theRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.schedulefly.com/webservice.asmx")!)
                            theRequest.addValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                            theRequest.addValue(String(count(soapMessage)), forHTTPHeaderField: "Content-Length")
                            theRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) // or false
                            
                            let mutableURLRequest = URLRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
                            mutableURLRequest.setValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                            mutableURLRequest.setValue(String(count(soapMessage)), forHTTPHeaderField: "Content-Length")
                            mutableURLRequest.HTTPBody = theRequest.HTTPBody
                            return (mutableURLRequest, nil)
                        }
                        
                        Alamofire.request(.POST, "http://api.schedulefly.com/webservice.asmx", parameters: Dictionary(), encoding: .Custom(custom1)).responseString { (request, response, data, error) -> Void in
                            
                            if (error == nil) {
                                let callType = "getStaff"
                                println(data!)
                                if data!.rangeOfString("Error") != nil {
                                    
                                } else {
                                    var xmlData = ParseXML(data: SWXMLHash.parse(data!), callType: callType)
                                    xmlData.getElementValues()
                                    var curStaff = xmlData.staffDict[self.passedID!]!
//                                    self.nameLabel.text = "\(curStaff['Fname']!) \(curStaff['Lname']!)"
                                    var name: String = ""
                                    if let fname = curStaff["Fname"] {
                                        name = fname
                                    }
                                    if let lname = curStaff["Lname"] {
                                        name = name + " \(lname)"
                                    }
                                    if let email = curStaff["Email"] {
                                        self.emailLabel.text = email
                                        self.passedEmail = email
                                    }
                                    if let cell = curStaff["Cellphone"] {
                                        self.cellphoneLabel.text = cell
                                        self.passedPhone = cell
                                    }
                                    if let photourl = curStaff["PhotoURL"] {
                                        let url = NSURL(string: photourl)
                                        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                                        self.profilePictureSmall.image = UIImage(data: data!)
                                        self.passedPic = UIImage(data: data!)
//                                        self.profilePictureLarge.image = UIImage(data: data!)
                                    }
                                    self.nameLabel.text = name
                                    
                                    self.activityIndicator.hidden = true
                                    self.activityIndicator.stopAnimating()
                                    self.profileView.hidden = false
                                }
                            }
                        }

                    } else {
                        var xmlData = ParseXML(data: SWXMLHash.parse(data!), callType: callType)
                        xmlData.getElementValues()
                    }
                }
            }

            
        } else {
            viewScheduleButton.hidden = true
            sendMessageButton.hidden = true
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            profileView.hidden = false
            
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let fname = prefs.stringForKey("FNAME")
            let lname = prefs.stringForKey("LNAME")
            nameLabel.text = "\(fname!) \(lname!)"
            userIDLabel.text = prefs.stringForKey("USERID")
            emailLabel.text = prefs.stringForKey("EMAIL")
            cellphoneLabel.text = prefs.stringForKey("CELLPHONE")
            positionLabel.text = prefs.stringForKey("CATEGORY")
            self.passedID = prefs.stringForKey("ID")
            self.passedName = nameLabel.text
            self.passedPhone = cellphoneLabel.text
            self.passedEmail = emailLabel.text
            if let photourl = prefs.stringForKey("PhotoURL") {
                let url = NSURL(string: photourl)
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                self.profilePictureSmall.image = UIImage(data: data!)
                self.passedPic = UIImage(data: data!)
            }

        }
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

    @IBAction func viewScheduleButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("viewScheduleSegue", sender: self)
    }
    @IBAction func sendMessageButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("sendMessageSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "viewScheduleSegue" {
            let destinationVC = segue.destinationViewController as! FirstViewController
            destinationVC.passedID = passedID
            destinationVC.title = passedName
        } else if segue.identifier == "sendMessageSegue" {
            let destinationVC = segue.destinationViewController as! SendMessageViewController
            if let id = passedID {
                destinationVC.passedID = id
                if let name = passedName {
                    destinationVC.passedName = name
                }
                if let email = passedEmail {
                    destinationVC.passedEmail = email
                }
                if let phone = passedPhone {
                    destinationVC.passedPhone = phone
                }
                if let pic = passedPic {
                    destinationVC.passedPic = pic
                }
            }
        }
    }
    
    @IBAction func editButton(sender: AnyObject) {
        self.performSegueWithIdentifier("edit_profile", sender: self)
    }

    @IBAction func closeButtonTapped(sender: AnyObject) {
        if selfFlag == false {
            self.navigationController!.popToRootViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
