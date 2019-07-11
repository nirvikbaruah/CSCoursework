//
//  CustomTableViewCell.swift
//  CS Coursework
//
//  Created by Nirvik Baruah on 9/11/18.
//  Copyright © 2018 Nirvik Baruah. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDetail: UILabel!
    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var cellStartDate: UILabel!
    @IBOutlet weak var dailyListStartDate: UILabel!
    @IBOutlet weak var dailyListDetail: UILabel!
    @IBOutlet weak var dailyListTitle: UILabel!
    @IBOutlet weak var dailyListBackground: UIView!
    @IBOutlet weak var cellHyphen: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
