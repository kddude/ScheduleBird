//
//  TabBarViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/23/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit
import ChameleonFramework

class TabBarViewController: UITabBarController {
    @IBOutlet weak var myTabBar: UITabBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rect = CGRect(x: 0, y: 0, width: Int(myTabBar.layer.frame.width), height: 1)
        var line: UIView = UIView(frame: rect)
        line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        myTabBar.addSubview(line)
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 239/255, green: 112/255, blue: 122/255, alpha: 1)], forState:.Selected)
        UITabBar.appearance().tintColor = UIColor(red: 239/255, green: 112/255, blue: 122/255, alpha: 1)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
