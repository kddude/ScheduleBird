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
    var elementsDict = Dictionary<String, String>()
    let callType: String
    
    init(data: XMLIndexer, callType: String) {
        self.dataToParse = data
        self.callType = callType
    }
    
    func cleanElementsArray() -> Void{
        elements.removeRange(0..<4)
//        switch call {
//            case "getAdminScheduledShifts":
//                elements.removeRange(0..<4)
//            case "getAllStaff":
//                elements.removeRange(0..<4)
//            case "getJobOpenings":
//                elements.removeRange(0..<4)
//            case "getJobOpenings2":
//                elements.removeRange(0..<4)
//            case "getJobOpenings":
//                elements.removeRange(0..<4)
//            case "getScheduledShifts":
//                elements.removeRange(0..<4)
//            case "getScheduledShiftsForEmployee":
//                elements.removeRange(0..<4)
//            case "getStaff":
//                elements.removeRange(0..<4)
//            case "getStaffCategories":
//                elements.removeRange(0..<4)
//            case "getStaffDetails":
//                elements.removeRange(0..<4)
//            case "getStaffInfo":
//                elements.removeRange(0..<4)
//            default:
//                break
//        }
    }
    
    func enumerate(indexer: XMLIndexer) {
        for child in indexer.children {
            elements.append(child.element!.name as String!)
            enumerate(child)
        }
    }
    
    func getElements(indexer: XMLIndexer) {
        enumerate(indexer)
        cleanElementsArray()
    }
    
    func makeDict(upperRange: Int) {
        switch callType {
        case "getAdminScheduledShifts":
        // IMPLEMENT
        break
        case "getAllStaff", "getStaff":
        break
        case "getJobOpenings":
        // iMPLEMENT
        break
        case "getJobOpenings2":
        //IMPLEMENT
        break
        case "getScheduledShifts":
        // IMPLEMENT
        break
        case "getScheduledShiftsForEmployee":
        // IMPLEMENT
        break
        case "getStaffCategories":
            for i in Range(0..<upperRange) {
                for ele in elements {
                    if (ele == elements[0]) {
                        var key = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"][elements[0]][i][elements[1]].element?.text!
                        var value = dataToParse["soap:Envelope"]["soap:Body"]["\(callType)Response"]["\(callType)Result"][elements[0]][i][elements[2]].element?.text!
                        elementsDict[key!] = "\(value!)"
                    }
                }
                println(elementsDict)
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
    
    func getElementValues() -> Void{
        getElements(dataToParse)
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
            return false
        }
        else {
            return true
        }
    }
    
}











