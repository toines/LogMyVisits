//
//  CellTabel.swift
//  LogMyWay
//
//  Created by Toine Schnabel on 17-07-17.
//  Copyright © 2017 Toine Schnabel. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import UIKit

class CellTabel
{
    var count : Int {get {return tabel.count}}
    var tabel = [cellData]()
    var sortAscending = false
    init()
    {
        if tabel.count > 0 {return}
        var maand = Date.distantFuture
        var landenPerMaand = Set<String>()
        
        if let bezoeken = fetchAlleBezoekenSorted(){
            for bezoek in bezoeken
            {
                print ("\(bezoek.arrivalDate.yyyy) \(bezoek.arrivalDate.yyyyMM) ")
                if maand == Date.distantFuture {maand = bezoek.arrivalDate}
                if bezoek.arrivalDate.yyyyMM != maand.yyyyMM {
                    var landen = ""
                    var komma = ""
                    for land in landenPerMaand{landen += komma + land; komma = ", "}
                    landenPerMaand = Set<String>()
                    let cell = cellData(_soort: .maand, _datum_1970: maand.eersteVanDeMaandOm0000.timeIntervalSince1970,_totDatum_1970 : (maand.laatsteVanDeMaandOm2359 + 0.8).timeIntervalSince1970, _data: [landen], _selected: false, _soortplaats: "")
                    tabel.append(cell)
                    maand = bezoek.arrivalDate
//                    print ("\(bezoek.arrivalDate.laatsteVanDeMaandOm2359)")
                }
                if let land = bezoek.metAdres?.landcode {landenPerMaand.insert(land)}
            }
        }
        
    }
    func sort()
    {
        if sortAscending {tabel = tabel.sorted(by:{$0.vanafDatum_1970 < $1.vanafDatum_1970})}
        else {tabel = tabel.sorted(by:{$0.totDatum_1970 > $1.totDatum_1970})}
//        for item in tabel {print ("\(item.totDatum.yyyy_MM_dd_HH_mm_ss) === \(item.soortCell.rawValue) ")}
    }
    func cellSelected(cell:IndexPath)->Int
    {
        switch tabel[cell.row].soortCell {
        case .maand: return maandSelected(datum_1970: tabel[cell.row].vanafDatum_1970,selected:tabel[cell.row].selected)
        case .dag: return dagSelected(datum_1970: tabel[cell.row].vanafDatum_1970,selected:tabel[cell.row].selected)
        case.visite: return 0
        default: print ("geen entry gevonden?")
        }

        return 0
    }
    func visiteSelectedVoorMap(datum_1970:TimeInterval,selected:Bool)
    {
        if !selected {
            for (index, data) in tabel.enumerated()
            {
                if (data.datum.yyyyMMddHHmmss == datum_1970.datum.yyyyMM + "01000000" && data.soortCell == .maand) || (data.datum.yyyyMMddHHmmss == datum_1970.datum.yyyyMMdd + "000000" && data.soortCell == .dag)
                {
                    data.selected = selected
                    tabel[index] = data
                }
            }
            
        }
    }
    func dagSelectedVoorMap(datum_1970:TimeInterval,selected:Bool)
    {
            for (index, data) in tabel.enumerated()
            {
                if zelfdeDag(data.vanafDatum_1970, datum_1970) && data.soortCell != .maand
//                if (data.datum.yyyyMMdd == datum_1970.datum.yyyyMMdd)
                {
                    data.selected = selected
                    tabel[index] = data
                }
            }
        if !selected {
            for (index, data) in tabel.enumerated()
            {
//                if (data.datum.yyyyMMddHHmmss == datum_1970.datum.yyyyMM + "01000000") && (data.soortCell == .maand)
                if (data.datum.yyyyMMddHHmmss == datum_1970.datum.eersteVanDeMaandOm0000.yyyyMMddHHmmss) && (data.soortCell == .maand)
                {
                    data.selected = selected
                    tabel[index] = data
                }
            }
            
        }
    }
    func dagSelected(datum_1970:TimeInterval,selected:Bool)->Int
    {
        if let _ = selectedDates.removeValue(forKey: datum_1970){
        var teDeleten = Set<Int>()
        for (index , data) in tabel.enumerated()
        {
//            if (data.datum.yyyyMMdd == datum_1970.datum.yyyyMMdd)
            if zelfdeDag(data.vanafDatum_1970, datum_1970)
            {
                switch data.soortCell {
                case .visite: teDeleten.insert(index)
                default: break
                }
            }
        }
        tabel = tabel
            .enumerated()
            .filter { !teDeleten.contains($0.offset) }
            .map { $0.element }
            return -teDeleten.count}
        if let dag = fetchBezoeken(van_1970: datum_1970, tot_1970: datum_1970.eindeDag)
        {
            let delta = dag.count
            for visite in dag{
                if let adres = visite.metAdres
                {
                    tabel.append(cellData(_soort: .visite, _datum_1970: visite.arrival_1970,_totDatum_1970 :visite.departure_1970, _data: [visite.arrivalDate.HHmm,visite.departureDate.HHmm], _selected: selected, _soortplaats: adres.soortPlaats ?? ""))
                }
            }
            selectedDates.updateValue(delta, forKey: datum_1970)
            sort()
            return delta
        }
        return 0  // mag niet voorkomen ??
    }
    var selectedDates = [TimeInterval:Int]()  //timeInterval = date since 1970,Int = delta
    func rebuildCellTabel()
    {
        
    }
    func maandSelectedVoorMap(datum_1970:TimeInterval,selected:Bool)
    {
      for (index, data) in tabel.enumerated()
      {
//        if (data.datum.yyyyMM == datum_1970.datum.yyyyMM)
        if zelfdeMaand(data.vanafDatum_1970, datum_1970)
        {
           data.selected = selected
           tabel[index] = data
        }
      }
    }
    func maandSelected(datum_1970:TimeInterval,selected:Bool)->Int
    {
        if let _ = selectedDates.removeValue(forKey: datum_1970){
            var teDeleten = Set<Int>()
            for (index , data) in tabel.enumerated()
            {
//                if (data.datum.yyyyMM == datum_1970.datum.yyyyMM)
                if zelfdeMaand(data.vanafDatum_1970, datum_1970)
    
                {
                    switch data.soortCell {
                    case .dag,.visite: teDeleten.insert(index)
                    default: break
                    }
                }
            }
            tabel = tabel
                .enumerated()
                .filter { !teDeleten.contains($0.offset) }
                .map { $0.element }
            return -teDeleten.count}
        var dagen = [Double:Set<String>]()
        if let bezoeken = fetchBezoeken(van_1970: datum_1970, tot_1970: datum_1970.laatsteVanDeMaandOm2359)
        {
         for bezoek in bezoeken{
            if let adres = bezoek.metAdres
            {
            dagen = updateSetInDictionary(dictionary: dagen, forKey: bezoek.arrival_1970.beginDag + 0.001, newValue:adres.stad!)
            }
          }
//          print (dagen)
        }
        let dagenKeys = dagen.keys.sorted()
        for key in dagenKeys
        {
            var stedenString = ""
            if let stedenArray = dagen[key]
            {
            for stad in stedenArray{stedenString = stedenString + stad + " "}
            }
            tabel.insert(cellData(_soort: .dag, _datum_1970: key ,_totDatum_1970 : key.eindeDag + 0.5, _data: [stedenString],_selected : selected, _soortplaats: ""), at: 0)
//            print ("..\(key) \(stedenString) \(tabel[cellNo.row + 2].datum)")
        }
        selectedDates.updateValue(dagen.count, forKey: datum_1970)
        sort()
        return dagen.count

    }

}

enum SoortCell : Int8
{
    case empty = 0
    case maand = 1
    case dag = 2
    case visite = 3
}
class cellData {
    var soortCell : SoortCell
    var vanafDatum_1970 = Double()
    var totDatum_1970 = Double()
    var data = [String]()
    var selected = false
    init(_soort:SoortCell,_datum_1970:Double,_totDatum_1970:Double,_data:[String],_selected:Bool,_soortplaats : String)
    {
        soortCell = _soort
        vanafDatum_1970 = _datum_1970
        totDatum_1970 = _totDatum_1970
        data = _data
        selected = _selected
    }
//    init(_soort:SoortCell,_datum:String,_totDatum:String,_data:[String])
//    {
//        soortCell = _soort
//        vanafDatum_1970 = _datum.toDate("yyyyMMddHHmm").timeIntervalSince1970
//        totDatum_1970 = _totDatum.toDate("yyyyMMddHHmm").timeIntervalSince1970
//        data = _data
//    }
    var datum:Date {get {return Date(timeIntervalSince1970 : vanafDatum_1970)}}
    var totDatum:Date {get {return Date(timeIntervalSince1970 : totDatum_1970)}}
    
}
