//
//  FirstViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 3/28/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith
import SWXMLHash

class FirstViewController: UITableViewController {

    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    @IBOutlet weak var unscheduledView: UIView!
    var xmlData: ParseXML?
    var monthArray = [String]()
    var dateArray = [String]()
    var dayArray = [String]()
    var yearArray = [String]()
    var shiftTimeArray = [String]()
    var positionArray = [String]()
    var scheduleIdArray = [String]()
    var firstLoadArray = [Bool]()
    var backgroundColorArray = [UIColor]()
    var isLoaded = false
    var prevColor = UIColor()
    var passedID: String?
    var passedName: String?
    var passedShift: Int?
    var passedDate: String?
    var passedMonth: String?
    var passedDay: String?
    var passedYear: String?
    var passedFullDate: String?
    var colorWheel = ColorWheel(arr: 99)
    var colors = ColorWheel(arr: 99).setColors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        self.performSegueWithIdentifier("goto_login", sender: self)
//        prefs.setInteger(1, forKey: "ISLOGGEDIN")
//        prefs.synchronize()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            viewDidLoadFunc()
        }
        self.view.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 245/255, alpha: 1)
    }
    
    func viewDidLoadFunc() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        unscheduledView.hidden = true
    
        if self.revealViewController() != nil {
            var rvc = self.revealViewController()
            sidebarButton.target = rvc
            sidebarButton.action = "rightRevealToggle:"
        }
        
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let user = UserInfo()
        var id:String = prefs.stringForKey("ID")!
        
        if passedID != nil {
            id = passedID!
        }
        
        let nextWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYearCalendarUnit, value: 1, toDate: NSDate(), options: nil)!
        let styler = NSDateFormatter()
        styler.dateFormat = "MM/dd/yyyy"
        let nextWeekDateString = styler.stringFromDate(nextWeekDate)
    
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: date)
        let month = components.month
        let year = components.year
        let day = components.day
        
        let currentDateString = "\(month)/\(day)/\(year)"
        //        let currentDateString = "04/20/2015"
        //        let nextWeekDateString = "04/30/2015"
        
        
        
        
        let callMySchedule: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = {
            (URLRequest, parameters) in
            var soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getScheduledShiftsForEmployee xmlns='http://www.schedulefly.com/api/'><acct_userid>\(user.getUsername())</acct_userid><acct_password>\(user.getPassword())</acct_password><employeeid>\(id)</employeeid><startdate>\(currentDateString)</startdate><enddate>\(nextWeekDateString)</enddate></getScheduledShiftsForEmployee></soap12:Body></soap12:Envelope>"
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
        
        Alamofire.request(.POST, "http://api.schedulefly.com/webservice.asmx", parameters: Dictionary(), encoding: .Custom(callMySchedule)).responseString { (request, response, data, error) -> Void in
            
            if (error == nil) {
                let callType = "getScheduledShiftsForEmployee"
                var xmlD = SWXMLHash.parse(data!)
                self.xmlData = ParseXML(data: xmlD, callType: callType)
                self.xmlData!.makeDict(3)
            }
            
            if let butt = self.xmlData?.dates {
                if butt.isEmpty {
                    self.unscheduledView.hidden = false
                } else {
                    self.unscheduledView.hidden = true
                    self.unscheduledView.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height * 0.1)
                    if (true) {
                        for date in self.xmlData!.dates {
                            var unique = false
                            var color = self.colorWheel.randomColor(self.colors)
                            while unique == false {
                                color = self.colorWheel.randomColor(self.colors)
                                if contains(self.backgroundColorArray, color) {
                                    unique = false
                                } else {
                                    unique = true
                                }
                            }
                            let parsedDate = ParseDates(stringToParse: date)
                            parsedDate.setDates()
                            self.monthArray.append(parsedDate.month!)
                            self.dateArray.append(parsedDate.date!)
                            self.dayArray.append(parsedDate.day!)
                            self.yearArray.append(parsedDate.year!)
                            
                            let unwrap = self.xmlData!.elementsShiftsDict[date]!
                            let countShifts = count(unwrap)
                            var i = 0
                            do {
                                let unwrap2 = unwrap[i]
                                self.backgroundColorArray.append(color)
                                self.positionArray.append(unwrap2["Schedule"]!)
                                let startTime = unwrap2["StartTime"]!
                                let endTime = unwrap2["EndTime"]!
                                
                                //                            let shiftTime = "\(startTime) - \(endTime)"
                                let shiftTime = startTime
                                self.shiftTimeArray.append(shiftTime)
                                self.firstLoadArray.append(true)
                                
                                if (i > 0) {
                                    self.monthArray.append("")
                                    self.dateArray.append("")
                                    self.dayArray.append("")
                                    self.yearArray.append(parsedDate.year!)
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
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        else if prefs.integerForKey("FIRSTLOADSCHEDULE") == 1{
            prefs.setInteger(0, forKey: "FIRSTLOADSCHEDULE")
            prefs.synchronize()
            viewDidLoadFunc()
        }

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        passedShift = indexPath.row
//        self.performSegueWithIdentifier("giveupShiftSegue", sender: self)
        var row = indexPath.row
        while (monthArray[row] == "") {
            row -= 1
        }
        
        passedDate = dateArray[row]
        
        let monthDictionary = ["Jan": "01", "Feb": "02", "Mar": "03", "Apr": "04", "May": "05", "June": "06", "July": "07", "Aug": "08", "Sep": "09", "Oct": "10", "Nov": "11", "Dec": "12"]
        passedMonth = monthDictionary[monthArray[row]]
        passedDay = dayArray[row]
        passedYear = yearArray[indexPath.row]
        self.performSegueWithIdentifier("dayAtWorkSegue", sender: self)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if passedID == nil {
            return true
        }
        return false
    }

    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        var giveupAction = UITableViewRowAction(style: .Default, title: "Giveup", handler: { (action, indexPath) in
            self.passedShift = indexPath.row
            let monthDictionary = ["Jan": "01", "Feb": "02", "Mar": "03", "Apr": "04", "May": "05", "June": "06", "July": "07", "Aug": "08", "Sep": "09", "Oct": "10", "Nov": "11", "Dec": "12"]
            var row = indexPath.row
            while (self.monthArray[row] == "") {
                row -= 1
            }
            if let mon = monthDictionary[self.monthArray[row]] {
                self.passedFullDate = "\(mon)/\(self.dateArray[row])/\(self.yearArray[indexPath.row])"
                self.performSegueWithIdentifier("giveupShiftSegue", sender: self)
            }
        })
        giveupAction.backgroundColor = UIColor.flatTealColor()
        UIButton.appearance().setTitleColor(UIColor.flatWhiteColor(), forState: UIControlState.Normal)
        return [giveupAction]

    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (count(monthArray) > 0) {
            return count(monthArray)
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let nibName = UINib(nibName: "MyScheduleCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "scheduleCell")
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(
            "scheduleCell", forIndexPath: indexPath)
            as! MyScheduleCellTableViewCell
        
        if (isLoaded) {
            
//            if (monthArray[indexPath.row] != "" && firstLoadArray[indexPath.row] == true){
//                let rect = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: 8)
//                var line: UIView = UIView(frame: rect)
//                line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//                cell.addSubview(line)
//            }
            cell.backgroundColor = backgroundColorArray[indexPath.row]
            cell.monthLabel.text = monthArray[indexPath.row].uppercaseString
            cell.dateLabel.text = dateArray[indexPath.row]
            cell.dayLabel.text = dayArray[indexPath.row].uppercaseString
            cell.shiftTimeLabel.text = shiftTimeArray[indexPath.row]
            cell.positionLabel.text = positionArray[indexPath.row]
//            cell.backgroundSquare.layer.cornerRadius = 5
//            cell.backgroundSquare.clipsToBounds = true
            cell.transform = CGAffineTransformMakeTranslation(self.tableView.bounds.size.width, 0)
            firstLoadArray[indexPath.row] = false
                
//                if (firstLoadArray[indexPath.row] == true) {
//                    UIView.animateWithDuration(1.5, delay: 0.05 * Double(indexPath.row), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: {
//                        cell.transform = CGAffineTransformMakeTranslation(0, 0);
//                        }, completion: nil)
//                    firstLoadArray[indexPath.row] = false
//                }
        }

        return cell
    }
    
    func refresh(sender:AnyObject) {
        if count(firstLoadArray) != 0 {
//            for i in 0...count(firstLoadArray)-1 {
//                firstLoadArray[i] = true
//            }
            self.unscheduledView.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height * 10)
        } else {
            viewDidLoadFunc()
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "giveupShiftSegue" {
            let destinationVC = segue.destinationViewController as! GiveupShiftViewController
            destinationVC.passedShift = passedShift
            destinationVC.passedFullDate = passedFullDate
        }
        if segue.identifier == "dayAtWorkSegue" {
            let destinationVC = segue.destinationViewController as! WorkScheduleTableViewController
            destinationVC.passedDate = passedDate
            destinationVC.passedMonth = passedMonth
            destinationVC.passedDay = passedDay
            destinationVC.passedYear = passedYear
        }
    }
    
}

