//
//  TimeOffViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/2/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit
import Locksmith

class TimeOffViewController: UIViewController, UIWebViewDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    var refreshControl:UIRefreshControl!
    var theBool: Bool = false
    var myTimer: NSTimer = NSTimer()
    var counter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 245/255, alpha: 1)
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        webView.scrollView.addSubview(refreshControl)
        
//        self.title = "Loading"
        // Do any additional setup after Loading the view, typically from a nib.
        let url = NSURL (string: "http://m.schedulefly.com/timeoff.aspx");
        let requestObj = NSURLRequest(URL: url!);
        webView.hidden = true
        webView.delegate = self
        progressBar.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        webView.loadRequest(requestObj);
        
        if self.revealViewController() != nil {
            sidebarButton.target = self.revealViewController()
            sidebarButton.action = "rightRevealToggle:"
        }
        // Do any additional setup after Loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject)
    {
        self.webView.reload()
        self.refreshControl.endRefreshing()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.progressBar.progress = 0.0
        self.theBool = false
        self.myTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
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
                webView.stringByEvaluatingJavaScriptFromString("window.location.href = window.location.href.replace('home', 'timeoff');")
            } else if blah.rangeOfString("timeoff") != nil {
                webView.hidden = false
                progressBar.hidden = false
                activityIndicator.hidden = true
                activityIndicator.stopAnimating()
            }
            
            self.theBool = true
            //        webView.stringByEvaluatingJavaScriptFromString("window.location.href = window.location.href.replace('home', 'timeoff');")
        }
    }
    
    func timerCallback() {
        if self.theBool {
            if self.progressBar.progress >= 1 {
                self.progressBar.hidden = true
                self.myTimer.invalidate()
            } else {
                self.progressBar.progress += 0.1
            }
        } else {
            self.progressBar.progress += 0.01
            counter++
            if (counter == 10) {
                counter = 0
            }
            if self.progressBar.progress >= 0.95 {
                self.progressBar.progress = 0.95
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
