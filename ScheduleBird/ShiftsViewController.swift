//
//  ShiftsViewController.swift
//  ScheduleBird
//
//  Created by kevin das on 4/14/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class ShiftsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1) Create the three views used in the swipe container view
        var AVc :ShiftsDayViewController =  ShiftsDayViewController(nibName: "ShiftsDayViewController", bundle: nil);
        var BVc :ShiftsWeekViewController =  ShiftsWeekViewController(nibName: "ShiftsWeekViewController", bundle: nil);
        
        
        // 2) Add in each view to the container view hierarchy
        //    Add them in opposite order since the view hieracrhy is a stack
        self.addChildViewController(BVc);
        self.scrollView!.addSubview(BVc.view);
        BVc.didMoveToParentViewController(self);
        
        self.addChildViewController(AVc);
        self.scrollView!.addSubview(AVc.view);
        AVc.didMoveToParentViewController(self);
        
        
        // 3) Set up the frames of the view controllers to align
        //    with eachother inside the container view
        var adminFrame :CGRect = AVc.view.frame;
        adminFrame.origin.x = adminFrame.width;
        BVc.view.frame = adminFrame;
        
        var BFrame :CGRect = BVc.view.frame;
        BFrame.origin.x = 2*BFrame.width;
        
        
        // 4) Finally set the size of the scroll view that contains the frames
        var scrollWidth: CGFloat  = 2 * self.view.frame.width
        var scrollHeight: CGFloat  = 0
        self.scrollView!.contentSize = CGSizeMake(scrollWidth, scrollHeight);
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
