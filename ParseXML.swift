    //
//  ParseXML.swift
//  ScheduleBird
//
//  Created by kevin das on 3/30/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import Foundation
import SWXMLHash

class ParseXML {
    let dataToParse: XMLIndexer
    var elements: [String] = []
    var elementsDict = [String:String]()

    let callType: String
    var loginValid = true
    
    //staff
    var staffDict = [String: [String:String]]()
    
    //categories
    var staffCategories: [String] = []
    var staffKeys: [String] = []
    
    // shifts
    var shifts: [String] = []
    var elementsShiftsDict = [String: [[String:String]]]()
    var dates: [String] = []
    var rowCount: Int = 0
    
    init(data: XMLIndexer, callType: String) {
        self.dataToParse = data
        self.callType = callType
    }
    
    func cleanElementsArray() -> Void{
        elements.removeRange(0..<4)
    }
    
    func enumerate(indexer: XMLIndexer, type: String) {
        if type == "default" {
            for child in indexer.children {
                elements.append(child.element!.name as String!)
                enumerate(child, type: "default")
            }
        } else if type == "countShifts" {
            for child in indexer.children {
                shifts.append(child.element!.name as String!)
                enumerate(child, type: "default")
            }
        }
    }
    
    func getElements(indexer: XMLIndexer) {
        enumerate(indexer, type: "default")
        cleanElementsArray()
    }
    
    
    func makeDict(upperRange: Int) {
        if loginValid == true {
        switch callType {
        case "getAdminScheduledShifts":
        // IMPLEMENT
        break
        case "getAllStaff", "getStaff":
            var numStaff = elements.filter{$0 == "Staff"}.count
            for staff in 0...numStaff-1 {
                var tempDict = [String: String]()
                if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Id"].element?.text { tempDict["Id"] = t;
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Active"].element?.text { tempDict["Active"] = t }
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Fname"].element?.text { tempDict["Fname"] = t }
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Lname"].element?.text { tempDict["Lname"] = t }
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Email"].element?.text { tempDict["Email"] = t }
                    
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Cellphone"].element?.text { tempDict["Cellphone"] = t }
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["CategoryId"].element?.text { tempDict["CategoryId"] = t }
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["PhotoURL"].element?.text { tempDict["PhotoURL"] = t }
                    if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Admin"].element?.text { tempDict["Admin"] = t }
                }
                
                
                if let t = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Staff"][staff]["Id"].element?.text { staffDict[t] = tempDict }
            }

        case "getJobOpenings":
        // iMPLEMENT
        break
        case "getJobOpenings2":
        //IMPLEMENT
        break
        case "getScheduledShifts":
            getElements(dataToParse)
            if elements.isEmpty {
                break
            } else {
                var numDays = elements.filter{$0 == "Day"}.count
                for day in 0...numDays-1 {
                    var append = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][day]["Date"].element?.text!
                    dates.append("\(append!)")
                }
                var i: Int = 0
                for date in dates {
                    var shiftsForDayArray: [[String:String]] = []
                    //date = "friday - 4/17/2015"
                    var numShifts = countShifts(dataToParse, day: i)
                    for shift in 0...numShifts-1 {
                        var shiftDict = [String: String]()
                        shiftDict["EmployeeID"] = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][i]["Shifts"]["Shift"][shift]["EmployeeID"].element?.text
                        shiftDict["EmployeeName"] = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][i]["Shifts"]["Shift"][shift]["EmployeeName"].element?.text
                        shiftDict["Schedule"] = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][i]["Shifts"]["Shift"][shift]["Schedule"].element?.text
                        shiftDict["ScheduleId"] = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][i]["Shifts"]["Shift"][shift]["ScheduleId"].element?.text
                        shiftDict["StartTime"] = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][i]["Shifts"]["Shift"][shift]["StartTime"].element?.text
                        shiftDict["EndTime"] = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][i]["Shifts"]["Shift"][shift]["EndTime"].element?.text
                        if let note = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][i]["Shifts"]["Shift"][shift]["Note"].element?.text {
                            shiftDict["Note"] = note
                        }
                        shiftsForDayArray.append(shiftDict)
                    }
                    i = i + 1;
                    elementsShiftsDict[date] = shiftsForDayArray
                }
            }

        break
        case "getScheduledShiftsForEmployee":
            getElements(dataToParse)
            if elements.isEmpty {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "You are not scheduled for this week!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                break
            } else {
                var numDays = elements.filter{$0 == "Day"}.count
                for day in 0...numDays-1 {
                    var append = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][day]["Date"].element?.text!
                    dates.append("\(append!)")
                }
                var i: Int = 0
                for date in dates {
                    var shiftsForDayArray: [[String:String]] = []
                    //date = "friday - 4/17/2015"
                    var numShifts = countShifts(dataToParse, day: i)
                    for shift in 0...numShifts-1 {
                        var shiftDict = [String: String]()
                        shiftDict["EmployeeID"] = dataToParse["soap:Envelope"]["soap:Body"]["getScheduledShiftsForEmployeeResponse"]["getScheduledShiftsForEmployeeResult"]["Day"][i]["Shifts"]["Shift"][shift]["EmployeeID"].element?.text
                        shiftDict["EmployeeName"] = dataToParse["soap:Envelope"]["soap:Body"]["getScheduledShiftsForEmployeeResponse"]["getScheduledShiftsForEmployeeResult"]["Day"][i]["Shifts"]["Shift"][shift]["EmployeeName"].element?.text
                        shiftDict["Schedule"] = dataToParse["soap:Envelope"]["soap:Body"]["getScheduledShiftsForEmployeeResponse"]["getScheduledShiftsForEmployeeResult"]["Day"][i]["Shifts"]["Shift"][shift]["Schedule"].element?.text
                        shiftDict["ScheduleId"] = dataToParse["soap:Envelope"]["soap:Body"]["getScheduledShiftsForEmployeeResponse"]["getScheduledShiftsForEmployeeResult"]["Day"][i]["Shifts"]["Shift"][shift]["ScheduleId"].element?.text
                        shiftDict["StartTime"] = dataToParse["soap:Envelope"]["soap:Body"]["getScheduledShiftsForEmployeeResponse"]["getScheduledShiftsForEmployeeResult"]["Day"][i]["Shifts"]["Shift"][shift]["StartTime"].element?.text
                        shiftDict["EndTime"] = dataToParse["soap:Envelope"]["soap:Body"]["getScheduledShiftsForEmployeeResponse"]["getScheduledShiftsForEmployeeResult"]["Day"][i]["Shifts"]["Shift"][shift]["EndTime"].element?.text
                        shiftDict["EndTime"] = dataToParse["soap:Envelope"]["soap:Body"]["getScheduledShiftsForEmployeeResponse"]["getScheduledShiftsForEmployeeResult"]["Day"][i]["Shifts"]["Shift"][shift]["ScheduleId"].element?.text
                        shiftsForDayArray.append(shiftDict)
    //                    println(shiftDict)
                    }
                    i = i + 1;
                    elementsShiftsDict[date] = shiftsForDayArray
                }
            }
            
//            println(elementsShiftsDict)
        case "getStaffCategories":
//            getElements(dataToParse)
            elements.removeRange(0..<4)
            for i in Range(0..<upperRange) {
                for ele in elements {
                    if (ele == elements[0]) {
                        var key = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"][elements[0]][i][elements[1]].element?.text!
                        var value = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"][elements[0]][i][elements[2]].element?.text!
                        elementsDict[key!] = "\(value!)"
                        staffCategories.append(value!)
                        staffKeys.append(key!)
                    }
                }
//                println(elementsDict)
            }
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let categoryID:String = prefs.stringForKey("CATEGORYID") {
                prefs.setValue(elementsDict[categoryID], forKey: "CATEGORY")
            }
            
            
        case "getStaffInfo", "getStaffDetails":
            for i in Range(0..<upperRange) {
                for ele in elements {
                    if (ele != elements[0]) {
                        var key = ele
                        var value = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"][elements[0]][i][ele].element?.text!
                        elementsDict[key] = "\(value)\(i)"
                    }
                }
            }
        default:
            break
        }
    }
    
    
    
    }
    
    
    func getElementValues() -> Void{
        enumerate(dataToParse, type: "default")
        if (callType == "getStaffDetails" || callType=="getStaffInfo")  {
            for ele in elements {
                var key = ele
                var value = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["Staff"][ele].element?.text
                elementsDict[key] = value
            }
        } else if (self.callType == "getAdminScheduledShifts" ||
        callType=="getAllStaff" ||
        callType=="getStaff" ||
        callType=="getJobOpenings" ||
        callType=="getJobOpenings2" ||
        callType=="getScheduledShifts" ||
        callType=="getScheduledShiftsForEmployee" ||
        callType=="getStaffCategories") {
            let count = NSSet(array: self.elements).count
            makeDict(elements.count/count)
        } else {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Error!"
            alertView.message = "Call type not recognized."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
    }
    
    func setAccountDetails() -> Void {
        // should set the following:
        // ID, ACTIVE, FNAME, LNAME, USERID, EMAIL, CELLPHONE, CATEGORYID, PHOTOURL, ADMIN
        for element in elementsDict {
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setObject(element.1, forKey: ("\(element.0.uppercaseString)"))
            prefs.setInteger(1, forKey: "ISLOGGEDIN")
        }
    }
    
    func loginIsValid() -> Bool {
        let isNil = dataToParse["soap:Envelope"]["soap:Body"]["getStaffInfoResponse"]["Staff"].element?.attributes["xsi:nil"]
        if isNil == "true" {
            loginValid = false
            return false
        }
        else {
            loginValid = true
            return true
        }
    }
    
    
    
    /////////// get shfits
    
    func countShifts(indexer: XMLIndexer, day: Int) -> Int{
        shifts.removeAll()
        switch dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][day]["Shifts"] {
        case .Element(let elem):
            enumerate(dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"]["Day"][day]["Shifts"], type: "countShifts")
//            println("Count shifts success!")
            return shifts.filter{$0 == "Shift"}.count
        case .Error(let error):
            println(error)
            break
        default: break
        }
        return 0
    }
}











