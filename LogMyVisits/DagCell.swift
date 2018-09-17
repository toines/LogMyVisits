//
//  DagCell.swift
//  LogMyWay
//
//  Created by Toine Schnabel on 16-07-17.
//  Copyright © 2017 Toine Schnabel. All rights reserved.
//

import UIKit
import CoreData

class DagCell: UITableViewCell {

    @IBOutlet var dag: UILabel!
    @IBOutlet var ddmm: UILabel!
    @IBOutlet var steden: UILabel!
    @IBOutlet var selectedVoorKaart: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func met(data:cellData){
        dag.text =  data.datum.dateToFormattedString("eeee")
//        if test {dag.text = data.totDatum.HH_mm_ss}  // tijdelijk
        ddmm.text = data.datum.dateToFormattedString("d MMM")
        steden.text = data.data[0]
        if data.selected
        {selectedVoorKaart.text = "√"}
        else {selectedVoorKaart.text = ""}
        selectedVoorKaart.isHidden = !data.selected
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
