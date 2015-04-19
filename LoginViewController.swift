//
//  LoginViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 3/28/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//


import UIKit
import Locksmith
import Alamofire
import SWXMLHash

class LoginViewController: UIViewController {
    
    @IBOutlet weak private var usernameField: UITextField!
    @IBOutlet weak private var passwordField: UITextField!
    @IBOutlet weak var pwUnderline: UIImageView!
    @IBOutlet weak var unUnderline: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicator.hidden = true
        
        usernameField.attributedPlaceholder =  NSAttributedString(string:NSLocalizedString("username", comment:""),
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        passwordField.attributedPlaceholder =  NSAttributedString(string:NSLocalizedString("password", comment:""),
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        if (usernameField.editing || usernameField.highlighted) {
            unUnderline.backgroundColor = UIColor.whiteColor()
        }
        if (passwordField.editing || passwordField.highlighted) {
            pwUnderline.backgroundColor = UIColor.whiteColor()
        }
        
        var swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipe)
        


    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func dismissKeyboard() {
        self.passwordField.resignFirstResponder()
        self.usernameField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSize(width:10, height:10)
    }
    
    @IBAction func loginButton() {
        if (usernameField.text == "" || passwordField.text == "") {
            let alertController: UIAlertController = UIAlertController(title: "Please enter both username and password", message: nil, preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setObject(usernameField.text, forKey: "USERNAME")
            
            let error = Locksmith.saveData([usernameField.text: passwordField.text], forUserAccount: usernameField.text)
            println(error)
            
            prefs.setInteger(1, forKey: "ISLOGGEDIN")
            prefs.synchronize()
            
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            let custom: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = {
                (URLRequest, parameters) in
                var soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getStaffInfo xmlns='http://www.schedulefly.com/api/'><acct_userid>\(self.usernameField.text)</acct_userid><acct_password>\(self.passwordField.text)</acct_password></getStaffInfo></soap12:Body></soap12:Envelope>"
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
                    let callType = "getStaffInfo"
                    var xmlD = SWXMLHash.parse(data!)
                    var xmlData = ParseXML(data: xmlD, callType: callType)
                    if !xmlData.loginIsValid() {
                        let alertController: UIAlertController = UIAlertController(title: "Your username/password may be incorrect", message: nil, preferredStyle: .Alert)
                        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        }
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        xmlData.getElementValues()
                        xmlData.setAccountDetails()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //stop refresh animation
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                    })
                } else {
                    let alertController: UIAlertController = UIAlertController(title: "Error. Check connection", message: nil, preferredStyle: .Alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                    }
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //stop refresh animation
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                    })
                    
                }
            }
            
            
            
            let custom1: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = {
                (URLRequest, parameters) in
                var soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getStaffCategories xmlns='http://www.schedulefly.com/api/'><acct_userid>\(self.usernameField.text)</acct_userid><acct_password>\(self.passwordField.text)</acct_password></getStaffCategories></soap12:Body></soap12:Envelope>"
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
                    let callType = "getStaffCategories"
                    println(data!)
                    var xmlD = SWXMLHash.parse(data!)
                    var xmlData = ParseXML(data: xmlD, callType: callType)
                    xmlData.getElementValues()
                    println(xmlData.elementsDict)
                }
            }
        }
    }
    
    @IBAction func closeLoginTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
