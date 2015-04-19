//
//  ParseDates.swift
//  ScheduleBird
//
//  Created by kevin das on 4/15/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import Foundation

class ParseDates {
    let stringToParse: String
    var day: String?
    var month: String?
    var date: String?
    
    init(stringToParse: String) {
        self.stringToParse = stringToParse
    }
    
    // Sunday - 4/19/2015
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        let regex = NSRegularExpression(pattern: regex,
            options: nil, error: nil)!
        let nsString = text as NSString
        let results = regex.matchesInString(nsString as String,
            options: nil, range: NSMakeRange(0, nsString.length))
            as! [NSTextCheckingResult]
        return map(results) { nsString.substringWithRange($0.range)}
    }
    
    func getDay() {
        let dayDictionary = ["Monday": "Mon", "Tuesday": "Tue", "Wednesday": "Wed", "Thursday": "Thu", "Friday": "Fri", "Saturday": "Sat", "Sunday": "Sun"]
        let match = matchesForRegexInText("([A-z]*)\\s", text: self.stringToParse)
        let newMatch = match[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.day = dayDictionary[newMatch]
    }
    
    func getMonth() {
        let monthDictionary = ["1": "Jan", "2": "Feb", "3": "Mar", "4": "Apr", "5": "May", "6": "June", "7": "July", "8": "August", "9": "September", "10": "October", "11": "November", "12": "December"]
        let match = matchesForRegexInText("[-]{1}\\s(\\d*)", text: self.stringToParse)
        var newMatch = match[0]
        newMatch.removeAtIndex(newMatch.startIndex)
        newMatch = newMatch.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.month = monthDictionary[newMatch]
    }
    
    func getDate() {
        let match = matchesForRegexInText("\\/([\\d*]{1,})\\/", text: self.stringToParse)
        var newMatch = match[0].substringToIndex(match[0].endIndex.predecessor())
        newMatch = newMatch.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self.date = newMatch
    }
    
    func setDates() {
        getDay()
        getMonth()
        getDate()
    }
}
