//
//  AccountTableViewCell.swift
//  ScheduleBird
//
//  Created by kevin das on 4/1/15.
//  Copyright (c) 2015 kdas. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    @IBOutlet weak var accountTableLabel: UILabel!
    @IBOutlet weak var accountTableValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
