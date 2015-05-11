//
//  EmployeesTableViewController.swift
//  ScheduleBird
//
//  Created by tweeki on 5/8/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class EmployeesTableViewController: UITableViewController {
    var empDict = [String:[Employee]]()
    var empArray = [Employee]()
    var letters = [String]()
    var isLoaded = false
    var selectedID: String?
    var selectedName: String?
    
    class Employee: NSObject {
        var name: String?
        var employeeID: String?
        var photo: UIImage?
        var position: String?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadFunctions()
    }
    
    func viewDidLoadFunctions() {
        
        let user = UserInfo()
        
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
                if data!.rangeOfString("Error") != nil {
                    
                } else {
                    var xmlData = ParseXML(data: SWXMLHash.parse(data!), callType: callType)
                    xmlData.getElementValues()
                    for curStaff in xmlData.staffDict {
                        var newEmployee = Employee()
                        var name = ""
                        if let fname = curStaff.1["Fname"] {
                            name = fname
                        }
                        if let lname = curStaff.1["Lname"] {
                            name = name + " \(lname)"
                        }
                        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        let catid = curStaff.1["CategoryId"]
                        newEmployee.position = prefs.stringForKey(catid!)
                        newEmployee.name = name
                        newEmployee.employeeID = curStaff.1["Id"]!
//                        if let photourl = curStaff.1["PhotoURL"] {
//                            let url = NSURL(string: photourl)
//                            let data = NSData(contentsOfURL: url!)
//                            let photo = UIImage(data: data!)
//                            newEmployee.photo = photo
//                        } else {
//                            newEmployee.photo = nil
//                        }
                        self.letters.append(String(name[name.startIndex]))
                        self.empArray.append(newEmployee)
                        
                    }
                }
                
                let unique = NSSet(array: self.letters).allObjects
                self.letters.removeAll()
                for uni in unique {
                    self.empDict[uni as! String] = [Employee]()
                    self.letters.append(uni as! String)
                }
                
                for emp in self.empArray {
                    var str = String(emp.name![emp.name!.startIndex])
                    self.empDict[str]!.append(emp)
                }
                self.empArray.sort({ $0.name < $1.name })
                
                
//                for shift in self.shiftsArray {
//                    self.categoriesDict[shift.position!]!.append(shift)
//                }
                

            }
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                
                self.letters.sort({ $0 < $1 })
                dispatch_async(dispatch_get_main_queue()) {
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return letters.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return count(empDict[letters[section]]!)
    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "\(letters[section])"
//    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return letters[section]
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
//        header.textLabel.textColor = UIColor.flatWhiteColor()
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedID = empDict[letters[indexPath.section]]![indexPath.row].employeeID
        selectedName = empDict[letters[indexPath.section]]![indexPath.row].name
        self.performSegueWithIdentifier("profileSegue", sender: self)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        println(letters)
        return letters
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("employeeCell", forIndexPath: indexPath) as! UITableViewCell

        var thisCell = empDict[letters[indexPath.section]]![indexPath.row]
        cell.textLabel!.text = thisCell.name
//        if isLoaded == true {
//            if thisCell.photo != nil{
//                cell.profilePic.image = thisCell.photo
//            } else {
//                cell.profilePic.alpha = 0
//            }
//        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! OtherProfileViewController
        destinationVC.passedID = selectedID
        destinationVC.passedName = selectedName
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
