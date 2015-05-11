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
    var year: String?
    
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
        let monthDictionary = ["1": "Jan", "2": "Feb", "3": "Mar", "4": "Apr", "5": "May", "6": "June", "7": "July", "8": "Aug", "9": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"]
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
        var date = newMatch
        if newMatch.toInt() < 10 {
            date = "0\(date)"
        }
        self.date = date
    }
    
    func getYear() {
        let match = matchesForRegexInText("\\d\\d\\d\\d", text: self.stringToParse)
        self.year = match[0]
    }
    
    func setDates() {
        getDay()
        getMonth()
        getDate()
        getYear()
    }
}
