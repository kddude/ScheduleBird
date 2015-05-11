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
    @IBOutlet weak var topBar: UIView!

    @IBOutlet weak var dateTextField: UITextField!
    
    var datePicker:UIDatePicker!
    var xmlData: ParseXML?
    var positionArray = [String]()
    var shiftsArray = [Shift]()
    var categoriesDict = [String:[Shift]]()
    var staffCategories = [String]()
    var categoryColors = [UIColor]()
    var isLoaded = false
    var selectedID: String?
    var selectedName: String?
    var overrideDay: NSDate?
    var firstLoad = true
    var firstCellLoad = true
    var passedDate: String?
    var passedMonth: String?
    var passedDay: String?
    var passedYear: String?
    var colorWheel = ColorWheel(arr: 99)
    var colors = ColorWheel(arr: 99).setColors()
    
    class Shift: NSObject {
        var name: String?
        var section: Int?
        var position: String?
        var month: String?
        var day: String?
        var date: String?
        var startTime: String?
        var endTime: String?
        var employeeID: String?
        var note: String?
        var backgroundColor: UIColor?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // colors
        self.view.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 245/255, alpha: 1)
        self.topBar.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 245/255, alpha: 1)
        
        // date picker
        var customView:UIView = UIView (frame: CGRectMake(0, 100, 320, 160))
        datePicker = UIDatePicker(frame: CGRectMake(0, 0, 320, 160))
        datePicker.datePickerMode = UIDatePickerMode.Date
        customView.addSubview(datePicker)
        dateTextField.inputView = customView
        var doneButton:UIButton = UIButton (frame: CGRectMake(100, 100, 100, 44))
        doneButton.backgroundColor = UIColor(red: 239/255, green: 112/255, blue: 122/255, alpha: 1)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "datePickerSelected", forControlEvents: UIControlEvents.TouchUpInside)
        dateTextField.inputAccessoryView = doneButton
        dateTextField.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        

        viewDidLoadFunctions()
    }
    
    func datePickerSelected() {
        let dayDictionary = ["2": "Mon", "3": "Tue", "4": "Wed", "5": "Thu", "6": "Fri", "7": "Sat", "1": "Sun"]
        let monthDictionary = ["1": "Jan", "2": "Feb", "3": "Mar", "4": "Apr", "5": "May", "6": "June", "7": "July", "8": "Aug", "9": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"]
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay | .CalendarUnitWeekday, fromDate: datePicker.date)
        let dateString = "\(dayDictionary[String(components.weekday)]!), \(monthDictionary[String(components.month)]!) \(components.day)"
        self.dateTextField.text = dateString
        overrideDay = datePicker.date
        dateTextField.resignFirstResponder()
        viewDidLoadFunctions()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
    }
    
    func viewDidLoadFunctions() {
        shiftsArray.removeAll()
        staffCategories.removeAll()
        positionArray.removeAll()
        categoriesDict.removeAll()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        unscheduledView.hidden = true
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        
        if self.revealViewController() != nil {
            sidebarButton.target = self.revealViewController()
            sidebarButton.action = "rightRevealToggle:"
        }
        
        let user = UserInfo()
        let id:String = prefs.stringForKey("ID")!
        
        let nextWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYearCalendarUnit, value: 1, toDate: NSDate(), options: nil)!
        let styler = NSDateFormatter()
        styler.dateFormat = "MM/dd/yyyy"
        let nextWeekDateString = styler.stringFromDate(nextWeekDate)
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: date)
        
        var currentDateString: String
        
        if let oday = overrideDay {
            let newDateString = styler.stringFromDate(oday)
            currentDateString = newDateString
        } else {
            overrideDay = date
            currentDateString = "\(components.month)/\(components.day)/\(components.year)"
        }
        
        if let pDate = passedDate {
            firstLoad = false
            let monthDictionary = ["01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr", "05": "May", "06": "June", "07": "July", "08": "Aug", "09": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"]
            currentDateString = "\(passedMonth!)/\(pDate)/\(passedYear!)"
            self.dateTextField.text = "\(passedDay!), \(monthDictionary[passedMonth!]!) \(pDate)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let date = dateFormatter.dateFromString("\(components.year)-\(passedMonth!)-\(pDate)")
            overrideDay = date
        }
        passedDate = nil
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
                self.xmlData = ParseXML(data: xmlD, callType: callType)
                self.xmlData!.makeDict(3)
            }
            
            if let butt = self.xmlData?.dates {
                if butt.isEmpty {
                    self.unscheduledView.hidden = false
                    self.unscheduledView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height * 0.3)
                } else {
                    self.unscheduledView.hidden = true
                    self.unscheduledView.frame = CGRectMake(0, 0, 0, 0)
                    self.unscheduledView.sizeToFit()
                    for date in self.xmlData!.dates {
                        let parsedDate = ParseDates(stringToParse: date)
                        parsedDate.setDates()
                        let dayDictionary = ["2": "Mon", "3": "Tue", "4": "Wed", "5": "Thu", "6": "Fri", "7": "Sat", "1": "Sun"]
                        let monthDictionary = ["1": "Jan", "2": "Feb", "3": "Mar", "4": "Apr", "5": "May", "6": "June", "7": "July", "8": "Aug", "9": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"]
                        if let day = self.overrideDay {
                            if self.firstLoad == true {
                                let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay | .CalendarUnitWeekday, fromDate: self.overrideDay!)
                                let dateString = "\(dayDictionary[String(components.weekday)]!), \(monthDictionary[String(components.month)]!) \(components.day)"
                                self.dateTextField.text = dateString
                            }
                        }
                        
                        let unwrap = self.xmlData!.elementsShiftsDict[date]!
                        let countShifts = count(unwrap)
                        var i = 0
                        do {
                            let unwrap2 = unwrap[i]
                            
                            var newShift = Shift()
                            newShift.month = parsedDate.month!
                            newShift.date = parsedDate.date!
                            newShift.day = parsedDate.day!
                            if let schedule = unwrap2["Schedule"] {
                                newShift.position = schedule
                            }
                            newShift.name = unwrap2["EmployeeName"]
                            newShift.employeeID = unwrap2["EmployeeID"]
                            self.positionArray.append(unwrap2["Schedule"]!)
                            self.staffCategories.append(unwrap2["Schedule"]!)
                            if let note = unwrap2["Note"] {
                                newShift.note = unwrap2["Note"]
                            } else {
                                newShift.note = ""
                            }
                            
                            var randColor = self.colorWheel.randomColor(self.colors)
                            newShift.backgroundColor = randColor
                            
                            
                            
                            newShift.startTime = unwrap2["StartTime"]
                            newShift.endTime = unwrap2["EndTime"]
                            
                            if (i > 0) {
//                                                                    newShift.month = ""
//                                                                    newShift.date = " "
//                                                                    newShift.day = " "
                            }
                            i++
                            self.shiftsArray.append(newShift)
                            
                        } while (i < countShifts)
                    }
                    
                    let unique = NSSet(array: self.staffCategories).allObjects
                    self.staffCategories.removeAll()
                    for uni in unique {
                        self.categoriesDict[uni as! String] = [Shift]()
                        self.staffCategories.append(uni as! String)
                    }
                    
                    for shift in self.shiftsArray {
                        self.categoriesDict[shift.position!]!.append(shift)
                    }
                    
                    self.isLoaded = true
                    self.tableView.reloadData()
                    
                    
                }
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(categoriesDict)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(categoriesDict[staffCategories[section]]!)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        // Create a variable that you want to send based on the destination view controller
        // You can get a reference to the data by using indexPath shown below
        selectedID = categoriesDict[staffCategories[indexPath.section]]![indexPath.row].employeeID
        selectedName = categoriesDict[staffCategories[indexPath.section]]![indexPath.row].name
        // Let's assume that the segue name is called playerSegue
        // This will perform the segue and pre-load the variable for you to use
        self.performSegueWithIdentifier("profileDetailsSegue", sender: self)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(staffCategories[section])s"
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
//        header.contentView.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 245/255, alpha: 1)
        if self.categoryColors.isEmpty != true {
            header.contentView.backgroundColor = categoryColors[section]
        } else {
            header.contentView.backgroundColor = colors[section]
        }
//        if header.subviews.count == 2 {
//            if categoriesDict[staffCategories[section]]![0].startTime!.rangeOfString("AM") != nil {
//                let rect = CGRect(x: 0, y: 0, width: header.contentView.frame.width, height: header.contentView.frame.height)
//                var tint: UIView = UIView(frame: rect)
//                tint.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
//                header.addSubview(tint)
//            }

//            let rect = CGRect(x: 0, y: 0, width: header.contentView.frame.width, height: 8)
//            var line: UIView = UIView(frame: rect)
//            line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//            header.addSubview(line)
//        }

        header.textLabel.textColor = UIColor.flatWhiteColor()
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 1))
//        footerView.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 245/255, alpha: 1)
        if self.categoryColors.isEmpty != true {
            footerView.backgroundColor = categoryColors[section]
        } else {
            footerView.backgroundColor = colors[section]
        }
        
        return footerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! OtherProfileViewController
        destinationVC.passedID = selectedID
        destinationVC.passedName = selectedName
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
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(
            "workScheduleCell", forIndexPath: indexPath)
            as! WorkScheduleTableViewCell        
        
        
        if (isLoaded) {

            for i in 0...count(categoriesDict)-1 {
                switch indexPath.section {
                case i:
                    var thisCell = categoriesDict[staffCategories[i]]![indexPath.row]
                    
                    if thisCell.startTime!.rangeOfString("AM") != nil {
//                        println(cell.subviews.count)
//                        if cell.subviews.count == 2 {
//                            if i > 0 {
//                                let rect = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height)
//                                var tint: UIView = UIView(frame: rect)
//                                tint.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
//                                cell.addSubview(tint)
//                                
//                            }
//                        }
                        cell.shiftTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1)
                    }
                    if thisCell.startTime!.rangeOfString("PM") != nil {
//                        if cell.subviews.count == 0 {
//                            if i > 0 {
//                                let rect = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height)
//                                var tint: UIView = UIView(frame: rect)
//                                tint.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//                                cell.addSubview(tint)
//                                
//                            }
//                        }
                        cell.shiftTimeLabel.textColor = UIColor(red: 255/255, green: 240/255, blue: 255/255, alpha: 1)
                    }
                    let time = thisCell.startTime!
//                    .substringToIndex(advance(thisCell.startTime!.startIndex, substringIndex))
                    
                    cell.shiftTimeLabel.text = time
                    cell.nameLabel.text = thisCell.name
                    cell.noteLabel.text = thisCell.note
                    if self.categoryColors.isEmpty != true {
                        cell.backgroundColor = categoryColors[indexPath.section]
                    } else {
                        cell.backgroundColor = self.colors[i]
                    }
                    break
                default:
                    break
                }
            }
        }

        return cell
    }
    
    func refresh(sender:AnyObject)
    {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    @IBAction func nextDayButton(sender: AnyObject) {
        var dateToChange = NSDate()
        if overrideDay != nil {
            dateToChange = overrideDay!
            dateToChange = NSCalendar.currentCalendar().dateByAddingUnit(.DayCalendarUnit, value: 1, toDate: overrideDay!, options: nil)!
            overrideDay = dateToChange
        } else {
            overrideDay = NSCalendar.currentCalendar().dateByAddingUnit(.DayCalendarUnit, value: 1, toDate: NSDate(), options: nil)!
        }
        
        viewDidLoadFunctions()
        self.tableView.reloadData()
        let dayDictionary = ["2": "Mon", "3": "Tue", "4": "Wed", "5": "Thu", "6": "Fri", "7": "Sat", "1": "Sun"]
        let monthDictionary = ["1": "Jan", "2": "Feb", "3": "Mar", "4": "Apr", "5": "May", "6": "June", "7": "July", "8": "Aug", "9": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"]
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay | .CalendarUnitWeekday, fromDate: overrideDay!)
        self.dateTextField.text = "\(dayDictionary[String(components.weekday)]!), \(monthDictionary[String(components.month)]!) \(components.day)"
    }
    @IBAction func prevDayButton(sender: AnyObject) {
        var dateToChange = NSDate()
        if overrideDay != nil {
            dateToChange = overrideDay!
            dateToChange = NSCalendar.currentCalendar().dateByAddingUnit(.DayCalendarUnit, value: -1, toDate: overrideDay!, options: nil)!
            overrideDay = dateToChange
        } else {
            overrideDay = NSCalendar.currentCalendar().dateByAddingUnit(.DayCalendarUnit, value: -1, toDate: NSDate(), options: nil)!
        }
        
        viewDidLoadFunctions()
        self.tableView.reloadData()
        let dayDictionary = ["2": "Mon", "3": "Tue", "4": "Wed", "5": "Thu", "6": "Fri", "7": "Sat", "1": "Sun"]
        let monthDictionary = ["1": "Jan", "2": "Feb", "3": "Mar", "4": "Apr", "5": "May", "6": "June", "7": "July", "8": "Aug", "9": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"]
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay | .CalendarUnitWeekday, fromDate: overrideDay!)
        self.dateTextField.text = "\(dayDictionary[String(components.weekday)]!), \(monthDictionary[String(components.month)]!) \(components.day)"
    }
    @IBAction func dateButtonPressed(sender: AnyObject) {
    
        
    }
    
}



