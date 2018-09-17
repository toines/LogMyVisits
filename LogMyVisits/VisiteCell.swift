//
//  VisiteCell.swift
//  LogMyWay
//
//  Created by Toine Schnabel on 16-07-17.
//  Copyright © 2017 Toine Schnabel. All rights reserved.
//

import UIKit
import CoreData

class VisiteCell: UITableViewCell {

    @IBOutlet var icoon: UIImageView!
    @IBOutlet var vanaf: UILabel!

    @IBOutlet var naam: UILabel!
    @IBOutlet var straatHuisnummer: UILabel!
    @IBOutlet var Land: UILabel!
    @IBOutlet var selectedVoorKaart: UILabel!
    @IBOutlet var datumTijdelijk: UILabel!

    func met(data:cellData){
        datumTijdelijk.text = data.datum.dateToFormattedString("EE d MMM")
//        if test {datumTijdelijk.text = data.totDatum.HH_mm_ss}  // tijdelijk
//
//        vanaf.text = data.data[0] + "-" + data.data[1]
//            naam.text = data.data[2]
//        straatHuisnummer.text = data.data[3]
//        Land.text = data.data[4]
        if let bezoek = fetchBezoek(aankomst_1970: data.vanafDatum_1970) {
            if let adres = bezoek.metAdres
            {
                datumTijdelijk.text = bezoek.arrivalDate.dateToFormattedString("EE d MMM")
                naam.text = adres.naam
                straatHuisnummer.text = adres.straatHuisnummer
                vanaf.text = bezoek.arrivalDate.hh_mm() + "-" + bezoek.departureDate.hh_mm()
                Land.text = (adres.stad ?? "") + " " + adres.land
                if data.selected {selectedVoorKaart.text = "√"} else {selectedVoorKaart.text = ""}
                selectedVoorKaart.isHidden = !data.selected
                if let soort = adres.soortPlaats
                {
                 icoon.image = (soortPlaatsKeuzes[soort] ?? " ").image(ofSize: 50)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
