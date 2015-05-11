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
import QuartzCore
import CoreGraphics

class LoginViewController: UIViewController {
    
    @IBOutlet weak private var usernameField: UITextField!
    @IBOutlet weak private var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var loginValid: Bool?
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        usernameField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        activityIndicator.hidden = true
        
        var swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipe)

    }
    @IBAction func textFieldShouldReturn(sender: AnyObject) {
        if (self == usernameField) {
            passwordField.becomeFirstResponder()
        }
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
    
    
    @IBAction func loginButtonTapped() {
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
                        
                        self.loginValid = false
                        let boundsu = self.usernameField.bounds
                        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 50, options: nil, animations: {
                            self.usernameField.bounds = CGRect(x: boundsu.origin.x - 20, y: boundsu.origin.y, width: boundsu.size.width, height: boundsu.size.height)
                            }, completion: nil)
                        let bounds = self.passwordField.bounds
                        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 50, options: nil, animations: {
                            self.passwordField.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)

                            }, completion: nil)
                    } else {
                        xmlData.getElementValues()
                        xmlData.setAccountDetails()
                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
                        prefs.setInteger(1, forKey: "FIRSTLOADSCHEDULE")
                        prefs.synchronize()
                        self.getCat()
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
            
        }
    }
    
    func getCat() {
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
                var xmlD = SWXMLHash.parse(data!)
                var xmlData = ParseXML(data: xmlD, callType: callType)
                xmlData.getElementValues()
                let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let unique = NSSet(array: xmlData.staffCategories).allObjects
                xmlData.staffCategories.removeAll()
                for uni in unique {
                    xmlData.staffCategories.append(uni as! String)
                }
                let unique1 = NSSet(array: xmlData.staffKeys).allObjects
                xmlData.staffKeys.removeAll()
                for uni in unique1 {
                    xmlData.staffKeys.append(uni as! String)
                }
                
                for i in 0...count(xmlData.staffKeys)-1 {
                    prefs.setValue(xmlData.staffCategories[i], forKey:"\(xmlData.staffKeys[i])")
                }
            
                prefs.synchronize()
            }
        }
        
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
