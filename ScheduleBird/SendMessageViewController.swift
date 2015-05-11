//
//  SendMessageViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/24/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class SendMessageViewController: UIViewController, UIWebViewDelegate {
    
    var passedID: String?
    var passedName: String?
    var passedEmail: String?
    var passedPhone: String?
    var passedPic: UIImage?
    var sent = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var messageBody: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = ""
        emailLabel.text = ""
        phoneLabel.text = ""
        
        if passedPic != nil {
            profilePic.image = passedPic
            let image = profilePic
            image.layer.borderWidth=1.0
            image.layer.masksToBounds = false
            image.layer.borderColor = UIColor.whiteColor().CGColor
//            image.layer.cornerRadius = 13
            image.layer.cornerRadius = image.frame.size.height/2
            image.clipsToBounds = true
        }
        if let name = passedName {
            messageLabel.text = "Send message to \(name)"
            nameLabel.text = passedName
            phoneLabel.text = passedPhone
            emailLabel.text = passedEmail
        }
        webView.hidden = true
        
        
        // Do any additional setup after loading the view.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.title = "Message Wall"
        let user = UserInfo()
        let username: String = user.getUsername()
        let password: String = user.getPassword()
        let cleanUpJS: String = "document.getElementById('header').style.display = 'none'; document.getElementById('footer').style.display = 'none'"
        webView.stringByEvaluatingJavaScriptFromString(cleanUpJS)
        
        
        if (username != "" && password != "") {
            let loadLoginJS = "document.getElementById('userid').value = '\(password)';document.getElementById('password').value = document.getElementById('userid').value; document.getElementById('userid').value = '\(username)';document.forms[0].submit()"
            let blah: String = webView.stringByEvaluatingJavaScriptFromString("document.URL")!
            
            webView.stringByEvaluatingJavaScriptFromString(loadLoginJS)
            if blah.rangeOfString("home") != nil{
                webView.stringByEvaluatingJavaScriptFromString("window.location.href = window.location.href.replace('home.aspx', 'profile.aspx?id=\(passedID!)');")
            }
        }
        
        let blah: String = webView.stringByEvaluatingJavaScriptFromString("document.URL")!
        println(blah)
        if blah.rangeOfString("profile") != nil {
            webView.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('textarea')[0].value = '\(messageBody.text)'")
            if (webView.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('textarea')[0].value")! == messageBody.text && sent != true) {
                if sent != true {
                    webView.stringByEvaluatingJavaScriptFromString("document.getElementsByName('submit')[0].click()")
                    sent = true
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        if sent != true {
            let url = NSURL (string: "http://m.schedulefly.com/");
            let requestObj = NSURLRequest(URL: url!);
            webView.delegate = self
            webView.loadRequest(requestObj);
        }
    }
}
