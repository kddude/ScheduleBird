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
    var shiftTimeArray = [String]()
    var positionArray = [String]()
    var isLoaded = false
    let colorWheel = ColorWheel()
    var prevColor = UIColor()
    var passedID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.addSubview(refreshControl!)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        unscheduledView.hidden = true
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
        
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            if self.revealViewController() != nil {
                sidebarButton.target = self.revealViewController()
                sidebarButton.action = "rightRevealToggle:"
            }
            
            let user = UserInfo()
            var id:String = prefs.stringForKey("ID")!
            
            println(passedID)
            if passedID != nil {
                id = passedID!
            }
            
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
                                
                                let unwrap = self.xmlData!.elementsShiftsDict[date]!
                                let countShifts = count(unwrap)
                                var i = 0
                                do {
                                    let unwrap2 = unwrap[i]
                                    self.positionArray.append(unwrap2["Schedule"]!)
                                    let startTime = unwrap2["StartTime"]!
                                    let endTime = unwrap2["EndTime"]!
                                    
        //                            let shiftTime = "\(startTime) - \(endTime)"
                                    let shiftTime = startTime
                                    self.shiftTimeArray.append(shiftTime)
                                    
                                    if (i > 0) {
                                        self.monthArray.append("")
                                        self.dateArray.append("        ")
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
        return 1
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
            
            var randColor = colorWheel.randomColor()
            
            cell.monthLabel.text = monthArray[indexPath.row]
            cell.dateLabel.text = dateArray[indexPath.row]
            cell.dayLabel.text = dayArray[indexPath.row]
            cell.shiftTimeLabel.text = shiftTimeArray[indexPath.row]
            cell.positionLabel.text = positionArray[indexPath.row]
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

