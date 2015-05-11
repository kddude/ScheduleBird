//
//  ColorWheel.swift
//  ScheduleBird
//
//  Created by kevin das on 4/16/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

struct ColorWheel {
    var a: Int
    
    let colorsArray = [
        UIColor(hue: 195/360, saturation: 55/100, brightness: 51/100, alpha: 1), //flattealcolor
        UIColor(red: 239/255, green: 112/255, blue: 122/255, alpha: 1),
        UIColor(hue: 204/360, saturation: 78/100, brightness: 73/100, alpha: 1), // flatSkyBlueColor
        UIColor(hue: 300/360, saturation: 45/100, brightness: 37/100, alpha: 1), // flatPlumColor
        UIColor(hue: 25/360, saturation: 31/100, brightness: 64/100, alpha: 1), // flatCoffeeColor
        UIColor(hue: 184/360, saturation: 10/100, brightness: 65/100, alpha: 1), // flatGrayColor
        UIColor(hue: 210/360, saturation: 45/100, brightness: 37/100, alpha: 1) // flatNavyBlueColor
    ]
    
    let colorsArray1 = [
        UIColor(netHex:0xB0D0D3),
        UIColor(netHex:0xC08497),
        UIColor(netHex:0xF7AF9D),
        UIColor(netHex:0xF7E3AF),
        UIColor(netHex:0xF3EEC3)
    ]
    
    let colorsArray2 = [
        UIColor(netHex:0x2EC0F9),
        UIColor(netHex:0x67AAF9),
        UIColor(netHex:0x9BBDF9),
        UIColor(netHex:0xC4E0F9),
        UIColor(netHex:0xB95F89)
    ]
    
    let colorsArray3 = [
        UIColor(netHex:0xDFD9E2),
        UIColor(netHex:0xC3ACCE),
        UIColor(netHex:0x89909F),
        UIColor(netHex:0x538083),
        UIColor(netHex:0x2A7F62)
    ]
    
    let colorsArray4 = [
        UIColor(netHex:0xF2AD9A),
        UIColor(netHex:0x9A8BB0),
        UIColor(netHex:0x6174A8),
        UIColor(netHex:0x2F4B54),
        UIColor(netHex:0x1F452D)
    ]
    
    let colorsArray5 = [
        UIColor(netHex:0xD5C5C8),
        UIColor(netHex:0xF7717D),
        UIColor(netHex:0x9DA3A4),
        UIColor(netHex:0x604D53),
//        UIColor(netHex:0xFFDBDA)
    ]
    
    let colorsArraySuper = [
//        UIColor(netHex:0xD5C5C8),//5
        UIColor(netHex:0x604D53),
        UIColor(netHex:0x9DA3A4),
//        UIColor(netHex:0xF2AD9A),//4
//        UIColor(netHex:0x9A8BB0),
//        UIColor(netHex:0x6174A8),
//        UIColor(netHex:0x2F4B54),
//        UIColor(netHex:0x1F452D),
//        UIColor(netHex:0xDFD9E2),//3
//        UIColor(netHex:0xC3ACCE),
//        UIColor(netHex:0x89909F),
//        UIColor(netHex:0x538083),
//        UIColor(netHex:0x2A7F62),
////        UIColor(netHex:0x2EC0F9),//2
//        UIColor(netHex:0x67AAF9),
//        UIColor(netHex:0x9BBDF9),
////        UIColor(netHex:0xC4E0F9),
//        UIColor(netHex:0xB95F89),
//        UIColor(netHex:0xB0D0D3),//1
//        UIColor(netHex:0xC08497),
//        UIColor(netHex:0xF7AF9D),
////        UIColor(netHex:0xF7E3AF),
////        UIColor(netHex:0xF3EEC3),
        UIColor(netHex:0x6B7E77),//extra
        UIColor(netHex:0xF7717D),
        UIColor(netHex:0x484041),
        UIColor(netHex:0x353A47),
        
        
    ]
    
    init (arr: Int) {
        a = arr
    }
    
//    let colorsArrayx = [
    //        UIColor(red: 232/255.0, green: 99/255.0, blue: 116/255.0, alpha: 1.0),
    //        UIColor(red: 240/255.0, green: 137/255.0, blue: 120/255.0, alpha: 1.0),
    //        UIColor(red: 131/255.0, green: 77/255.0, blue: 139/255.0, alpha: 1.0),
    //        UIColor(red: 54/255.0, green: 67/255.0, blue: 137/255.0, alpha: 1.0),
    //        UIColor(red: 193/255.0, green: 190/255.0, blue: 183/255.0, alpha: 1.0),
    //        UIColor(red: 276/255.0, green: 210/255.0, blue: 98/255.0, alpha: 1.0),
    //        UIColor(red: 217/255.0, green: 214/255.0, blue: 207/255.0, alpha: 1.0),
    //        UIColor(red: 164/255.0, green: 220/255.0, blue: 219/255.0, alpha: 1.0),
    //        UIColor(red: 184/255.0, green: 224/255.0, blue: 151/255.0, alpha: 1.0),
    //        UIColor(red: 121/255.0, green: 98/255.0, blue: 92/255.0, alpha: 1.0),
    //        UIColor(red: 104/255.0, green: 72/255.0, blue: 86/255.0, alpha: 1.0),
    //        UIColor(red: 144/255.0, green: 212/255.0, blue: 171/255.0, alpha: 1.0),
    //        UIColor(red: 177/255.0, green: 107/255.0, blue: 196/255.0, alpha: 1.0),
    //        UIColor(red: 112/255.0, green: 113/255.0, blue: 131/255.0, alpha: 1.0),
    //        UIColor(red: 208/255.0, green: 120/255.0, blue: 108/255.0, alpha: 1.0),
    //        UIColor(red: 112/255.0, green: 62/255.0, blue: 53/255.0, alpha: 1.0),
    //        UIColor(red: 139/255.0, green: 214/255.0, blue: 131/255.0, alpha: 1.0)]
    
//    func advanceColor(index: Int, color: UIColor, numCells: Int) -> UIColor{
//        switch color {
//        case UIColor(hue: 195/360, saturation: 55/100, brightness: 51/100, alpha: 1):
//            var val = 1.0-(CGFloat(index+51)/CGFloat(numCells+71))
//            if index == 0 {
//                val = 51.0/100.0
//            }
//            return UIColor(hue: 195/360, saturation: 55/100, brightness: val, alpha: 1)
//        case UIColor(hue: 204/360, saturation: 78/100, brightness: 73/100, alpha: 1):
//            var val = 1.0-(CGFloat(index+73)/CGFloat(numCells+93))
//            if index == 0 {
//                val = 73.0/100.0
//            }
//            return UIColor(hue: 204/360, saturation: 78/100, brightness: val, alpha: 1)
//        case UIColor(hue: 300/360, saturation: 45/100, brightness: 37/100, alpha: 1):
//            var val = 1.0-(CGFloat(index+37)/CGFloat(numCells+57))
//            if index == 0 {
//                val = 37.0/100.0
//            }
//            return UIColor(hue: 300/360, saturation: 45/100, brightness: val, alpha: 1)
//        case UIColor(hue: 25/360, saturation: 31/100, brightness: 64/100, alpha: 1):
//            var val = 1.0-(CGFloat(index+64)/CGFloat(numCells+84))
//            if index == 0 {
//                val = 64.0/100.0
//            }
//            return UIColor(hue: 25/360, saturation: 31, brightness: val, alpha: 1)
//        case UIColor(hue: 184/360, saturation: 10/100, brightness: 65/100, alpha: 1):
//            var val = 1.0-(CGFloat(index+65)/CGFloat(numCells+85))
//            if index == 0 {
//                val = 65.0/100.0
//            }
//            return UIColor(hue: 184/360, saturation: 10/100, brightness: val, alpha: 1)
//        case UIColor(hue: 210/360, saturation: 45/100, brightness: 37/100, alpha: 1):
//            var val = 1.0-(CGFloat(index+37)/CGFloat(numCells+57))
//            if index == 0 {
//                val = 37.0/100.0
//            }
//            return UIColor(hue: 210/360, saturation: 45/100, brightness: val, alpha: 1)
//        default: return color
//        }
//    }
    
    func setColors() -> [UIColor]{
        switch a {
        case 0:
            return colorsArray
        case 1:
            return colorsArray1
        case 2:
            return colorsArray2
        case 3:
            return colorsArray3
        case 4:
            return colorsArray4
        case 5:
            return colorsArray5
        case 99:
            return colorsArraySuper
        default:
            return colorsArray
        }
    }

    func randomColor(c: [UIColor]) -> UIColor{
        let rand = Int(arc4random_uniform(UInt32(c.count)))
        return c[rand]
    }
}
