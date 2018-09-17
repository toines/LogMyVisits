//
//  LokaleFuncties.swift
//  LogMyVisits
//
//  Created by Toine Schnabel on 04-08-18.
//  Copyright © 2018 Toine Schnabel. All rights reserved.
//

import Foundation
import CoreLocation

func checkDbForMisingData() {
    checkAdressenZonderLocatie()
}
func updateSetInDictionary( dictionary:[String:Set<String>], forKey:String,newValue:String)->[String:Set<String>]
{
    var newDict = dictionary
    var y : Set<String> = [newValue]
    if let x = dictionary[forKey] {y = y.union(x)}
    newDict.updateValue(y, forKey: forKey)
    return newDict
}
func updateSetInDictionary( dictionary:[Double:Set<String>], forKey:Double,newValue:String)->[Double:Set<String>]
{
    var newDict = dictionary
    var y : Set<String> = [newValue]
    if let x = dictionary[forKey] {y = y.union(x)}
    newDict.updateValue(y, forKey: forKey)
    return newDict
}

func checkAdressenZonderLocatie(){
    let adres = fetchFirstAdresZonderLocation()
    if adres == nil {checkBezoekenZonderAdres();ErrMsg("checkAdressenZonderLocatie afgewerkt", .debug);return}
    let adr = "\(adres!.straatHuisnummer ?? "") \(adres!.postcode ?? "") \(adres!.stad ?? "")"
    geocode(adr) { placemark, error in
        guard let placemark = placemark, error == nil else {
               let code = (error! as NSError).code
            switch code {case 8 : ErrMsg((adres!.naam ?? "noname") + " " + adr + " verwijderd", .warning) ; context.delete(adres!);delegate.saveContext();checkAdressenZonderLocatie(); return
            default: ErrMsg("adressen geocoding overload: stopped till next start", .warning) ; return }}
        DispatchQueue.main.async {
            //  update UI here
            adres!.coordinate = (placemark.location?.coordinate ?? nil)!
            adres!.landcode = (placemark.isoCountryCode ?? "")
            adres!.straatHuisnummer = (placemark.thoroughfare ?? "") + (placemark.subThoroughfare ?? "")
            adres!.postcode = placemark.postalCode
            adres!.stad = placemark.locality
            adres!.soortPlaats = "Kennis"
            delegate.saveContext()
            sleep(1)
            checkAdressenZonderLocatie()
        }
    }

}
func checkBezoekenZonderAdres(){
     if let visiteZonderAdres = fetchFirstBezoekZonderAdres()
    {
        if let closestAdres = fetchNearestAdres(latitude: visiteZonderAdres.latitude, longitude: visiteZonderAdres.longitude, distance: 50)
        {
            visiteZonderAdres.metAdres = closestAdres
            //            closestAdres.addToBezocht(visiteZonderAdresUitDB)}
            delegate.saveContext()
            checkBezoekenZonderAdres()
            return
            
        }
        while CLGeocoder().isGeocoding
        {
            sleep(10)
        }
        ErrMsg("start Geocoding bezoek", .debug)
        geocode(visiteZonderAdres.coordinate, completion: { placemark, error in
            guard let placemark = placemark, error == nil else {
                let code = (error! as NSError).code
                switch code {case 8 : ErrMsg("\(visiteZonderAdres.arrivalDate) \(visiteZonderAdres.latitude ) \(visiteZonderAdres.longitude)  verwijderd", .warning) ; context.delete(visiteZonderAdres);delegate.saveContext();checkBezoekenZonderAdres(); return
                default: ErrMsg("bezoeken geocoding overload: stopped till next start", .warning) ; return }}
            DispatchQueue.main.async {
                //  update UI here
                let adres = Adres(context: context)
                adres.coordinate = (placemark.location?.coordinate ?? nil)!
                adres.landcode = (placemark.isoCountryCode ?? "")
                adres.straatHuisnummer = (placemark.thoroughfare ?? "") + (placemark.subThoroughfare ?? "")
                adres.postcode = placemark.postalCode
                adres.stad = placemark.locality
                visiteZonderAdres.metAdres = adres
                delegate.saveContext()
                sleep(1)
                checkBezoekenZonderAdres()
            }
        })
    }
    else {ErrMsg("checkBezoekenZonderAdres afgewerkt", .debug)}
}
