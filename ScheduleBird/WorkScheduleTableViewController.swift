//
//  WorkScheduleTableViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/17/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith
import SWXMLHash

class WorkScheduleTableViewController: UITableViewController {
    
    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    @IBOutlet weak var unscheduledView: UIView!
    var xmlData: ParseXML?
    var monthArray = [String]()
    var dateArray = [String]()
    var dayArray = [String]()
    var shiftTimeArray = [String]()
    var positionArray = [String]()
    var nameArray = [String]()
    var employeeIDArray = [String]()
    var isLoaded = false
    let colorWheel = ColorWheel()
    var prevColor = UIColor()
    var selectedID: String?
    var selectedName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        unscheduledView.hidden = true
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        if self.revealViewController() != nil {
            sidebarButton.target = self.revealViewController()
            sidebarButton.action = "rightRevealToggle:"
        }
        
        tabBarController?.tabBar.barTintColor = UIColor(red: 37.0, green: 39.0, blue: 42.0, alpha: 0.0)
        
        let user = UserInfo()
        let id:String = prefs.stringForKey("ID")!
        
        let nextWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYearCalendarUnit, value: 1, toDate: NSDate(), options: nil)!
        let styler = NSDateFormatter()
        styler.dateFormat = "MM/dd/yyyy"
        let nextWeekDateString = styler.stringFromDate(nextWeekDate)
        //        println(nextWeekDateString)
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: date)
        let month = components.month
        let year = components.year
        let day = components.day
        
        let currentDateString = "\(month)/\(day)/\(year)"
        //        let currentDateString = "04/20/2015"
        //        let nextWeekDateString = "04/30/2015"
        
        
        
        
        let callWorkSchedule: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = {
            (URLRequest, parameters) in
            var soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getScheduledShifts xmlns='http://www.schedulefly.com/api/'><acct_userid>\(user.getUsername())</acct_userid><acct_password>\(user.getPassword())</acct_password><startdate>\(currentDateString)</startdate><enddate>\(currentDateString)</enddate></getScheduledShifts></soap12:Body></soap12:Envelope>"
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
        
        Alamofire.request(.POST, "http://api.schedulefly.com/webservice.asmx", parameters: Dictionary(), encoding: .Custom(callWorkSchedule)).responseString { (request, response, data, error) -> Void in
            
            if (error == nil) {
                let callType = "getScheduledShifts"
                var xmlD = SWXMLHash.parse(data!)
                println(data!)
                self.xmlData = ParseXML(data: xmlD, callType: callType)
                self.xmlData!.makeDict(3)
                println(self.xmlData!.dates)
            }
            
            if let butt = self.xmlData?.dates {
                if butt.isEmpty {
                    self.unscheduledView.hidden = false
                } else {
                    self.unscheduledView.hidden = true
                    if (true) {
                        for date in self.xmlData!.dates {
                            let parsedDate = ParseDates(stringToParse: date)
                            parsedDate.setDates()
                            self.monthArray.append(parsedDate.month!)
                            self.dateArray.append(parsedDate.date!)
                            self.dayArray.append(parsedDate.day!)
                            
                            println(self.xmlData!.elementsShiftsDict)
                            let unwrap = self.xmlData!.elementsShiftsDict[date]!
                            println(unwrap)
                            let countShifts = count(unwrap)
                            var i = 0
                            do {
                                let unwrap2 = unwrap[i]
                                println(unwrap2)
                                self.positionArray.append(unwrap2["Schedule"]!)
                                self.nameArray.append(unwrap2["EmployeeName"]!)
                                self.employeeIDArray.append(unwrap2["EmployeeID"]!)
                                
                                let startTime = unwrap2["StartTime"]!
                                let endTime = unwrap2["EndTime"]!
                                
                                //                            let shiftTime = "\(startTime) - \(endTime)"
                                let shiftTime = startTime
                                self.shiftTimeArray.append(shiftTime)
                                
                                if (i > 0) {
                                    self.monthArray.append("")
                                    self.dateArray.append(" ")
                                    self.dayArray.append("")
                                }
                                i++
                            } while (i < countShifts)
                        }
                        
                        //                    println(monthArray)
                        //                    println(dateArray)
                        //                    println(dayArray)
                        //                    println(shiftTimeArray)
                        //                    println(positionArray)
                        
                        self.isLoaded = true
                        self.tableView.reloadData()
                    }
                }
            }
            
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = NSSet(array: positionArray).count
        return count
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (count(monthArray) > 0) {
            return count(monthArray)
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        // Create a variable that you want to send based on the destination view controller
        // You can get a reference to the data by using indexPath shown below
        selectedID = employeeIDArray[indexPath.row]
        selectedName = nameArray[indexPath.row]
        
        // Let's assume that the segue name is called playerSegue
        // This will perform the segue and pre-load the variable for you to use
        self.performSegueWithIdentifier("goto_personDetailSchedule", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! FirstViewController
        println(selectedID)
        destinationVC.passedID = selectedID
        var matchName = matchesForRegexInText("(.*) ", text: self.selectedName!)
        matchName[0] = matchName[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        destinationVC.title = "\(matchName)'s Schedule"
    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        let regex = NSRegularExpression(pattern: regex,
            options: nil, error: nil)!
        let nsString = text as NSString
        let results = regex.matchesInString(nsString as String,
            options: nil, range: NSMakeRange(0, nsString.length))
            as! [NSTextCheckingResult]
        return map(results) { nsString.substringWithRange($0.range)}
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let nibName = UINib(nibName: "WorkScheduleCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "workScheduleCell")
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(
            "workScheduleCell", forIndexPath: indexPath)
            as! WorkScheduleTableViewCell
        
        if (isLoaded) {
            
            var randColor = colorWheel.randomColor()
            
            cell.monthLabel.text = monthArray[indexPath.row]
            cell.dateLabel.text = dateArray[indexPath.row]
            cell.dayLabel.text = dayArray[indexPath.row]
            cell.shiftTimeLabel.text = shiftTimeArray[indexPath.row]
            cell.nameLabel.text = nameArray[indexPath.row]
            cell.backgroundSquare.backgroundColor = randColor
            cell.backgroundSquare.layer.cornerRadius = 10
            cell.backgroundSquare.clipsToBounds = true
        }
        return cell
    }
    
    func refresh(sender:AnyObject)
    {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

