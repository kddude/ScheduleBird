//
//  UserInfo.swift
//  ScheduleBird
//
//  Created by kevin das on 3/27/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import Foundation
import Locksmith

struct UserInfo {
    
    func getPassword() -> String {
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let uname:String = prefs.stringForKey("USERNAME") {
            let (userCredentials, error) = Locksmith.loadDataForUserAccount(uname)
            let pword: String = userCredentials![uname] as! String
            
            return pword as String
        }
        return ""
    }
    
    func getUsername() -> String {
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let uname:String = prefs.stringForKey("USERNAME") {
            return uname as String
        }
        return ""
    }
    
}