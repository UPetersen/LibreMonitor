//
//  BloodSugarGraphViewTableViewCell.swift
//
//  Created by Uwe Petersen on 23.03.16.
//

import Foundation
import UIKit
import Charts

class BloodSugarGraphViewTableViewCell: UITableViewCell {
    
    
    // Just the outlets are needed here, for these UI elements to be accessible from the corresponding parent table view controller
    // target action and that stuff is then all handled from within the table view controller
    @IBOutlet weak var barChartView: BloodSugarGraphView!
    @IBOutlet weak var lineChartView: BloodSugarGraphView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }    
}
