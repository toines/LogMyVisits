//
//  MaandCell.swift
//  LogMyWay
//
//  Created by Toine Schnabel on 16-07-17.
//  Copyright © 2017 Toine Schnabel. All rights reserved.
//

import UIKit

class MaandCell: UITableViewCell {

    @IBOutlet var jaar: UILabel!
    @IBOutlet var maand: UILabel!
    @IBOutlet var landen: UILabel!
    @IBOutlet var selectedVoorKaart: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func met(data:cellData){
     jaar.text =  data.datum.yyyy
     maand.text = data.datum.MMMM
     landen.text = data.data[0]
        if data.selected {selectedVoorKaart.text = "√"} else {selectedVoorKaart.text = ""}
        selectedVoorKaart.isHidden = !data.selected
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
