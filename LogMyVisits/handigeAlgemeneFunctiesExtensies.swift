//
//  handigeAlgemeneFunctiesExtensies.swift
//  LogMyVisits
//
//  Created by Toine Schnabel on 02-08-18.
//  Copyright © 2018 Toine Schnabel. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts
import UIKit



var contactStore : CNContactStore?
enum soortFout {case error,warning,debug}
var soortPlaatsKeuzes = ["":"🔴", "Hotel":"","Slaapplaats":"","Thuis":"🏠","Restaurant":"","Bar":"","Camperplaats":"","Kasteel":"","Station":"","Winkel":"","Camping":""]



func ErrMsg(_ titel:String,_ fout:soortFout){
    switch fout {
    case .warning : print ("warning: " + titel)
    case .debug :print ("debug: " + titel)
    default: print ("ERROR: " + titel) }
 }



//--------------- voorbeeld aanroep ------------------------------------------------------------------------
//geocode(latitude: 51.44527, longitude: 5.40365) { placemark, error in
//    guard let placemark = placemark, error == nil else { return }
//    // you should always update your UI in the main thread
//    DispatchQueue.main.async {
//        print("city:",     placemark.locality ?? "" , "state:",    placemark.administrativeArea ?? "")}}
//--------------- voorbeeld aanroep ------------------------------------------------------------------------

func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
    CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { completion($0?.first, $1) }
}
func geocode(_ coordinate:CLLocationCoordinate2D, completion: @escaping (CLPlacemark?, Error?) -> ())  {
    CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { completion($0?.first, $1) }
}
func geocode(_ location:String, completion: @escaping (CLPlacemark?,Error?)->()){
    CLGeocoder().geocodeAddressString(location){ completion($0?.first, $1)}
}



func StoreAllContactsAdresses() // ->[String]
{   let contactStore = CNContactStore()
    var contacts = [CNContact]()
    let keys = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey] as! [CNKeyDescriptor]
    let request = CNContactFetchRequest(keysToFetch: keys)
    do {try contactStore.enumerateContacts(with: request){
        (contact, stop) in
        // Array containing all unified contacts from everywhere
        contacts.append(contact)
        for adres in contact.postalAddresses {
                print("\(contact.givenName) \(contact.familyName) \(adres.value.street) \(adres.value.postalCode) \(adres.value.state) \(adres.value.city) \(adres.value.isoCountryCode)")
                let adrInfo = Adres(context: context)
                adrInfo.naam = "\(contact.givenName) \(contact.familyName)"
                adrInfo.landcode = adres.value.isoCountryCode
                adrInfo.stad = adres.value.city
                adrInfo.straatHuisnummer = adres.value.street
                adrInfo.postcode = adres.value.postalCode
                delegate.saveContext()
            }
        }
 //       print(contacts)
    } catch {
        print("unable to fetch contacts")
    }
}
extension bezoekVC{
    func checkForBackgroundForeground()
    {
        //    if !(UIDevice.current.isBatteryMonitoringEnabled){UIDevice.current.isBatteryMonitoringEnabled = true}
        Foreground()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.Foreground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.Background), name: UIApplication.didEnterBackgroundNotification, object: nil)
        //    NotificationCenter.default.addObserver(self, selector: #selector(visiteVC.startZoekLocatieBijContacten),name:NSNotification.Name("zoekLocatieBijContacten"), object: nil)
        //    NotificationCenter.default.addObserver(self, selector: #selector(visiteVC.loadList(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        //    NotificationCenter.default.addObserver(self, selector: #selector(visiteVC.updateKaart),name:NSNotification.Name("MAP"), object: nil)
        //    NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: .UIDeviceBatteryLevelDidChange, object: nil)
    }
    @objc func Foreground()
    {
        ErrMsg("Foreground", .debug)
        checkDbForMisingData()
        readJson()  // externe data input
    }
    @objc func Background()
    {
        ErrMsg("background", .debug)
    }
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        ErrMsg("..visit received:\(visit)",.debug)
        if (visit.arrivalDate.geldig && visit.departureDate.geldig)
        {
            let _ = Bezoek(visit)
            delegate.saveContext()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ErrMsg("..location received:\(locations.first!)",.debug)

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        ErrMsg(" tabel lengte = \(cellTabel.count)", .debug)
        return (cellTabel.count)
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cellTabel.tabel[indexPath.row].soortCell{
        case .maand : let cell = tableView.dequeueReusableCell(withIdentifier: "MAAND", for: indexPath) as! MaandCell
        cell.met(data: cellTabel.tabel[indexPath.row])
        return cell
        case .dag : let cell  = tableView.dequeueReusableCell(withIdentifier: "DAG", for: indexPath) as! DagCell
        cell.met(data: cellTabel.tabel[indexPath.row])
        return cell
            
        default : let cell  = tableView.dequeueReusableCell(withIdentifier: "VISITE", for: indexPath) as! VisiteCell
        cell.met(data: cellTabel.tabel[indexPath.row])
        return cell
        }
        }
        
        
        // Configure the cell...

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print ("selected \(cellTabel.tabel[indexPath.row].datum.yyyyMMddHHmmss) \(cellTabel.tabel[indexPath.row].soortCell.rawValue) ")
        if selectingForMapActive {
            cellTabel.tabel[indexPath.row].selected = !cellTabel.tabel[indexPath.row].selected
            let cell = cellTabel.tabel[indexPath.row]
            switch cellTabel.tabel[indexPath.row].soortCell{
            case .visite : cellTabel.visiteSelectedVoorMap(datum_1970: cell.vanafDatum_1970, selected: cell.selected)
            case .dag : cellTabel.dagSelectedVoorMap(datum_1970: cell.vanafDatum_1970, selected: cell.selected)
            default : cellTabel.maandSelectedVoorMap(datum_1970: cell.vanafDatum_1970, selected: cell.selected)
                
            }
            NotificationCenter.default.post(name: NSNotification.Name("MAP"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("load"), object: nil)
            
            
            return
        }
        if cellTabel.tabel[indexPath.row].soortCell == .visite
        {
//            visiteDatumVoorSegue = cellTabel.tabel[indexPath.row].vanafDatum_1970
//            self.performSegue(withIdentifier: "EditAdres", sender: self)
        }
        let delta = cellTabel.cellSelected(cell:indexPath)
        print (delta)
        var deltaIdxPath = [IndexPath]()
        for x in 0..<abs(delta)
        {
            deltaIdxPath.append(IndexPath(row:(indexPath.row + 1 + x),section: indexPath.section))
        }
        tableView.beginUpdates()
        if delta < 0
        {tableView.deleteRows(at: deltaIdxPath, with: UITableView.RowAnimation.fade)}
        else
        {tableView.insertRows(at: deltaIdxPath, with: UITableView.RowAnimation.fade)}
        tableView.endUpdates()
        
        
    }
}


//: ## =================================== Date ==============================================
extension Date
{
    func week()->Date
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyww"
        Formatter.locale = Locale.current
        return Formatter.date(from: Formatter.string(from: self))!
        
    }
    func dagLong0()->String
    {
        let Formatter = DateFormatter()
        Formatter.dateStyle = DateFormatter.Style.long
        Formatter.locale = Locale.current
        //        println("dag   --\(Formatter.stringFromDate(self))")
        return Formatter.string(from: self)
    }
    var geldig :Bool {get {return (self != Date.distantFuture) && (self != Date.distantPast) }}
    var eindeDag :Date {get {return (dateToFormattedString("yyyyMMdd235959").toDate(yyyyMMddHHmmss))}}
    var beginDag :Date {get {return (dateToFormattedString("yyyyMMdd000001").toDate(yyyyMMddHHmmss))}}
    var dagLong :  String {get {return self.dagLong0()}}
    var dd : String {get {return self.dateToFormattedString("dd")}}
    var d : String {get {return self.dateToFormattedString("d")}}
    var MMMM_yyyy : String {get {return dateToFormattedString("MMMM yyyy")}}
    var dag:String {get {return dateToFormattedString("yyMMdd")}}
    var jaar:String {get {return dateToFormattedString("yy")}}
    var maand:String {get {return dateToFormattedString("yyMM")}}
    var MMMM:String {get {return dateToFormattedString("MMMM")}}
    var MMM:String {get {return dateToFormattedString("MMM")}}
    var yyyy : String {get {return dateToFormattedString("yyyy")}}
    var yyMM : String {get {return dateToFormattedString("yyMM")}}
    var yyyyMM : String {get {return dateToFormattedString("yyyyMM")}}
    var yyyyMMdd : String {get {return dateToFormattedString("yyyyMMdd")}}
    var yy : String {get {return self.dateToFormattedString("yy")}}
    var mm : String {get {return self.dateToFormattedString("MM")}}
    var yyMMddHHmmss : String {get {return self.dateToFormattedString("yyMMddHHmmss")}}
    var yyyyMMddHHmmss : String {get {return self.dateToFormattedString("yyyyMMddHHmmss")}}
    var yyyy_MM_dd_HH_mm_ss : String {get {return self.dateToFormattedString("yyyy-MM-dd HH:mm:ss")}}
    var dd_MM_yyyy_HH_mm : String {get {return self.dateToFormattedString("dd MM yyyy HH:mm")}}
    var dd_MMM_yyyy_HH_mm : String {get {return self.dateToFormattedString("dd MMM yyyy HH:mm")}}
    var yyMMddHHmm : String {get {return self.dateToFormattedString("yyMMddHHmm")}}
    var dd_MM : String {get {return self.dateToFormattedString("dd-MM")}}
    var HHmm : String{get {return self.dateToFormattedString("HH:mm")}}
    var HH_mm_ss : String{get {return self.dateToFormattedString("HH:mm:ss SSS")}}
    var eersteVanDeMaandOm0000 : Date {get {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyyyMMdd"
        Formatter.locale = Locale.current
        return Formatter.date(from:self.dateToFormattedString("yyyyMM") + "01")!}
    }
    var laatsteVanDeMaandOm2359 : Date {get {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyyyMMdd"
        Formatter.locale = Locale.current
        let work = Formatter.date(from:self.dateToFormattedString("yyyyMM") + "01")!.addingTimeInterval(-1)
        
        let date = Calendar.current.date(byAdding: .month, value: 1, to: work)
        return date!}
    }
    func dateToFormattedString(_ _dateFormat:String)->String
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = _dateFormat
        
        Formatter.locale = Locale.current
        
        print ("\(Locale.current.languageCode)  -- \(Locale.current)")
        return Formatter.string(from: self)
    }
    
    
    
    func ww()->String
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "ww"
        Formatter.locale = Locale.current
        return Formatter.string(from: self)
        
    }
    func ee()->String    //returns dag in de week 1...7
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "ee"
        Formatter.locale = Locale.current
        return Formatter.string(from: self)
        
    }
    func EE()->String    //returns dag in de week 1...7
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "EE"
        Formatter.locale = Locale.current
        return Formatter.string(from: self)
        
    }
    func eee()->String    //returns dag in de week 1...7
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "eee"
        Formatter.locale = Locale.current
        return Formatter.string(from: self)
        
    }
    func EEE()->String    //returns dag in de week 1...7
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "EEE"
        Formatter.locale = Locale.current
        return Formatter.string(from: self)
        
    }
    func EEEE()->String    //returns dag in de week 1...7
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "EEEE"
        Formatter.locale = Locale.current
        return Formatter.string(from: self)
        
    }
    
    func string()->String
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyMMddhhmmss"
        Formatter.locale = Locale.current
        //        println("dag   --\(Formatter.stringFromDate(self))")
        return Formatter.string(from: self)
        
    }
    
    func maandDagString()->String
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyMMdd"
        Formatter.locale = Locale.current
        //        println("dag   --\(Formatter.stringFromDate(self))")
        return Formatter.string(from: self)
    }
    func hh_mm()->String
    {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm"
        Formatter.locale = Locale.current
        //        println("dag   --\(Formatter.stringFromDate(self))")
        return Formatter.string(from: self)
        
    }
    
    
}
func zelfdeDag(_ a:TimeInterval,_ b:TimeInterval)->Bool {return a.datum.yyyyMMdd == b.datum.yyyyMMdd}
func zelfdeMaand(_ a:TimeInterval,_ b:TimeInterval)->Bool {return a.datum.yyyyMM == b.datum.yyyyMM}

//# =============================== TimeInterval ===================================

extension TimeInterval{
    var datum: Date {get {return Date(timeIntervalSince1970: self)}}
    var eindeDag :Double {get {let x = Date(timeIntervalSince1970: self)
        return (x.dateToFormattedString("yyyyMMdd235959").toDate("yyyyMMddHHmmss")).timeIntervalSince1970}}
    var beginDag :Double {get {let x = Date(timeIntervalSince1970: self)
        return (x.dateToFormattedString("yyyyMMdd000000").toDate("yyyyMMddHHmmss")).timeIntervalSince1970}}
    var milliseconds: Int{
        return Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
    }
    var seconds: Int{
        return Int(self.remainder(dividingBy: 60))
    }
    var minutes: Int{
        return Int((self/60).remainder(dividingBy: 60))
    }
    var hours: Int{
        return Int(self / (60*60))
    }
    var stringTime: String{
        if self.hours != 0{
            return "\(self.hours): \(self.minutes)"
        }else if self.minutes != 0{
            return "00:\(self.minutes)"
        } else {return "00:00"}
    }
    var laatsteVanDeMaandOm2359 : Double {get {
        let x = Date(timeIntervalSince1970: self)
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyyyMMdd"
        Formatter.locale = Locale.current
        let work = Formatter.date(from:x.dateToFormattedString("yyyyMM") + "01")!.addingTimeInterval(-1)
        
        let date_1970 = Calendar.current.date(byAdding: .month, value: 1, to: work)?.timeIntervalSince1970
        return date_1970!}
    }
}

//=============================== String ===================================

extension String{
    var generatingSearchArguments :(van:Date,tot:Date) {get {
        var tot = Date()
        let dc = NSDateComponents()
        let ca = NSCalendar.current
        switch self.count {
        case 4: dc.year = 1 ; dc.second = -1
        case 6:dc.month = 1 ; dc.second = -1
        case 8:dc.day = 1 ; dc.second = -1
        case 14: dc.second = 60
        default: print ("Length Error generatingSearchArguments")
        }
        tot = ca.date(byAdding: dc as DateComponents,to: self.yyyyMMddHHmmssToDate)!
        
        return (self.yyyyMMddHHmmssToDate,tot)}}
    
    var yyyyMMddHHmmssToDate : Date {get {return self.toDate("yyyyMMddHHmmss")}}
    func toDate(_ _dateFormat:String)->Date
    {
        let Formatter = DateFormatter()
        //        Formatter.dateFormat = _dateFormat
        Formatter.dateFormat = "yyyyMMddHHmmss"
        Formatter.locale = Locale.current
        var retValue = self
        while retValue.count < 8 {retValue += "01"}
        while retValue.count < 14 {retValue += "00"}
        while retValue.count > 14 {retValue.removeLast()}
        if let x = Formatter.date(from: retValue){return x}
        else { print ("x= \(retValue)")
            return Formatter.date(from: "19000101000000")!
        }
    }
    public func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    /* creates a image from a string */
    
    func image(ofSize:CGFloat) -> UIImage {
        if self == "" {return UIImage()}
        let size = CGSize(width: ofSize * CGFloat(self.count) , height: ofSize)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set()
        let rect = CGRect(x:0,y:0 ,width:size.width,height:size.height)
        UIRectFill(rect)
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(ofSize * 0.8))])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    
    
}

