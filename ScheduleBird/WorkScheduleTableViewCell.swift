//
//  WorkScheduleTableViewCell.swift
//  ScheduleBird
//
//  Created by kevin das on 4/17/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class WorkScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var shiftTimeLabel: UILabel!
    @IBOutlet weak var backgroundSquare: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
