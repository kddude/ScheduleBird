//
//  AccountTableViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/1/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController, UITableViewDataSource {
    var accountTableLabels = ["Name"]
    var accountTableValues = ["--"]
    
    override func viewDidLoad() {
        // ID, ACTIVE, FNAME, LNAME, USERID, EMAIL, CELLPHONE, CATEGORYID, PHOTOURL, ADMIN
        super.viewDidLoad()
        var accLabels = ["FNAME", "LNAME", "USERID", "EMAIL", "CELLPHONE", "CATEGORY", "PHOTOURL"]
        var fname: String = ""
        var lname: String = ""
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        for item in accLabels {
            if let prefItem:String = prefs.stringForKey("\(item)") {
                if (prefItem != "") {
                    if item == "FNAME" {
                        fname = prefItem
                    } else if item == "LNAME"{
                        lname = prefItem
                    } else {
                        accountTableLabels.append(item.lowercaseString)
                        accountTableValues.append(prefItem)
                        println(accountTableLabels)
                        println(accountTableValues)
                    }
                }
            }
        }
        
        if (fname != "" && lname != "") {
            var name = fname + " " + lname
            accountTableValues[0] = name
            
        } else if (fname != "" && lname == "") {
            accountTableLabels[0] = "First name"
            accountTableValues[0] = fname
        } else if (fname == "" && lname != ""){
            accountTableLabels[0] = "Last name"
            accountTableValues[0] = lname
        }
        
        println(accountTableLabels)
        println(accountTableValues)
        
        tableView.estimatedRowHeight = 50
    }
    
    @IBAction func editButton(sender: AnyObject) {
        self.performSegueWithIdentifier("edit_account", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return accountTableLabels.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =
        self.tableView.dequeueReusableCellWithIdentifier(
            "AccountTableCell", forIndexPath: indexPath)
            as! AccountTableViewCell
        
        let row = indexPath.row
        cell.accountTableLabel.font =
            UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        cell.accountTableLabel.text = accountTableLabels[row]
        cell.accountTableValue.text = accountTableValues[row]
        return cell
        
    }
    
    @IBAction func closeButton(sender: AnyObject) {
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
