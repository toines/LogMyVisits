//
//  DBextensions.swift
//  LogMyVisits
//
//  Created by Toine Schnabel on 02-08-18.
//  Copyright © 2018 Toine Schnabel. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData



extension NSManagedObject {
    func toJSON() -> String? {
        let keys = Array(self.entity.attributesByName.keys)
        let dict = self.dictionaryWithValues(forKeys: keys)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let reqJSONStr = String(data: jsonData, encoding: .utf8)
            return reqJSONStr
        }
        catch{}
        return nil
    }
}

extension Bezoek{    // datums in database zijn sinds 1970 !!!
    var departureDate:Date{get {return Date(timeIntervalSince1970:self.departure_1970)}
        set {self.departure_1970 = newValue.timeIntervalSince1970}}
    var arrivalDate:Date{get {return Date(timeIntervalSince1970: self.arrival_1970)}
        set {self.arrival_1970 = newValue.timeIntervalSince1970}}
    public var coordinate:CLLocationCoordinate2D{get {return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)}
        set {self.latitude = newValue.latitude ; self.longitude = newValue.longitude}
    }
    var cllocation:CLLocation {get {return CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: arrivalDate)}}
    convenience init(_ visite:CLVisit){
        self.init(context:context)
        self.coordinate = visite.coordinate
        self.arrivalDate =  visite.arrivalDate
        self.departureDate = visite.departureDate
        delegate.saveContext()
    }
    convenience init(_ visite:myCLVisit){
        self.init(context:context)
        self.coordinate = CLLocationCoordinate2D(latitude: visite.latitude, longitude: visite.longitude)
        self.arrival_1970 =  visite.arrival_1970
        self.departure_1970 = visite.departure_1970
        delegate.saveContext()
    }
}
//==============================================================================================
func fetchBezoek(aankomst_1970:Double)->Bezoek? //return 1 adres
{
    //    var Bezoeken:[Bezoek] = []
    if let bezoeken = fetchBezoeken(van_1970: aankomst_1970-1, tot_1970: aankomst_1970 + 1)
    {return bezoeken.first} else {return nil}
}

func fetchBezoeken(van:Date,tot:Date)->[Bezoek]? //return 1 adres
{
    let van_1970 = van.timeIntervalSince1970
    let tot_1970 = tot.timeIntervalSince1970
    var visites:[Bezoek] = []
    do {let request: NSFetchRequest = Bezoek.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "arrival_1970", ascending: false)]
        request.predicate = NSPredicate(format: "arrival_1970 >= %lf AND arrival_1970 <= %lf", van_1970 as Double,tot_1970 as Double)
        visites = try context.fetch(request)} catch let error {ErrMsg("fetchLog foutje .\(error.localizedDescription)",.debug)}
    return visites
}
func fetchAlleBezoekenSorted()->[Bezoek]?
{
    var bezoeken:[Bezoek] = []
    do {let request: NSFetchRequest = Bezoek.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "arrival_1970", ascending: false)]
        bezoeken = try context.fetch(request)} catch let error {ErrMsg("fetchLog foutje .\(error.localizedDescription)",.debug)}
    return bezoeken
}
func fetchFirstBezoekZonderAdres()->Bezoek?
{
    let request:NSFetchRequest = Bezoek.fetchRequest()
    var BezoekenZonderAdres:[Bezoek] = []
    request.predicate = NSPredicate(format: "metAdres = nil")
 //   request.fetchLimit = 1
    do {  BezoekenZonderAdres = try context.fetch(request)
    } catch let error {ErrMsg("foutje fetchFirstBezoekZonderAdres(.\(error.localizedDescription)",.debug)}
    ErrMsg("er zijn nog \(BezoekenZonderAdres.count) bezoeken zonder adres", .debug)
    return BezoekenZonderAdres.first
}
func telBezoeken()->Int
{
    let request:NSFetchRequest = Bezoek.fetchRequest()
    var Bezoeken:[Bezoek] = []
    do {  Bezoeken = try context.fetch(request)
    } catch let error {ErrMsg("foutje telBezoeken(.\(error.localizedDescription)",.debug)}
    return Bezoeken.count
}
func fetchFirstBezoek()->Bezoek?
{
    let request:NSFetchRequest = Bezoek.fetchRequest()
    var BezoekenZonderAdres:[Bezoek] = []
    request.fetchLimit = 1
    do {  BezoekenZonderAdres = try context.fetch(request)
    } catch let error {ErrMsg("foutje fetchFirstBezoek(.\(error.localizedDescription)",.debug)}
    return BezoekenZonderAdres.first
}
//==============================================================================================
func fetchBezoeken(van_1970:Double,tot_1970:Double)->[Bezoek]? //return 1 adres
{
    var visites:[Bezoek] = []
    do {let request: NSFetchRequest = Bezoek.fetchRequest()
        request.predicate = NSPredicate(format: "arrival_1970 >= %lf AND arrival_1970 <=%lf", van_1970 as Double,tot_1970 as Double)
        visites = try context.fetch(request)} catch let error {print("fetchLog foutje .\(error.localizedDescription)")}
    return visites
}
//==============================================================================================
func fetchBezoekenVoorMaand(_ van_1970:Double)->[Bezoek]? //return 1 adres
{
    let tot_1970 = van_1970.laatsteVanDeMaandOm2359
    var bezoeken:[Bezoek] = []
    do {let request: NSFetchRequest = Bezoek.fetchRequest()
        request.predicate = NSPredicate(format: "arrival_1970 >= %lf AND arrival_1970 <=%lf", van_1970 as Double,tot_1970 as Double)
        bezoeken = try context.fetch(request)} catch let error {print("fetchLog foutje .\(error.localizedDescription)")}
    return bezoeken
}
//==============================================================================================
func fetchBezoekenVoorDag(_ van_1970:TimeInterval)->[Bezoek]? //return 1 adres
{
    let tot_1970 = van_1970.eindeDag
    var bezoeken:[Bezoek] = []
    do {let request: NSFetchRequest = Bezoek.fetchRequest()
        request.predicate = NSPredicate(format: "arrival_1970 >= %lf AND arrival_1970 <=%lf", van_1970 as Double,tot_1970 as Double)
        bezoeken = try context.fetch(request)} catch let error {print("fetchLog foutje .\(error.localizedDescription)")}
    return bezoeken
}
//==============================================================================================



//====================== adres =====================================

extension Adres{
    var land : String {get {
        let currentLocale : NSLocale = NSLocale.init(localeIdentifier :  NSLocale.current.identifier)
        let countryName : String? = currentLocale.displayName(forKey: NSLocale.Key.countryCode, value: landcode!)
        print(countryName ?? "Invalid country code")
        return countryName!
        }
    }
    public var coordinate:CLLocationCoordinate2D{get {return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)}
        set {self.latitude = newValue.latitude ; self.longitude = newValue.longitude}}
}
func fetchNearestAdres(latitude:Double,longitude:Double,distance:Double)->Adres? //return 1 adres
{
    let maxDelta = 0.002
    let maxLat = (latitude + maxDelta) as Double
    let minLat = (latitude - maxDelta) as Double
    let maxLon = (longitude + maxDelta) as Double
    let minLon = (longitude - maxDelta) as Double
    
    var naburigeAdressen:[Adres] = []
    do {let request: NSFetchRequest = Adres.fetchRequest()
         request.predicate = NSPredicate(format: "latitude > %f AND latitude < %f AND longitude > %f AND longitude < %f", minLat, maxLat,minLon,maxLon)
        naburigeAdressen = try context.fetch(request)} catch let error {print("foutje fetchNearestAdres .\(error.localizedDescription)")}
    var kortsteAfstand = distance
    //        print (">>>> \(kortsteAfstand)")
    var indexKortsteAfstand = 999999
    for (index,element) in naburigeAdressen.enumerated()
    {
        let afstand = CLLocation(latitude: element.latitude, longitude: element.longitude).distance(from: CLLocation.init(latitude: latitude, longitude: longitude))
        ErrMsg("afstand = \(afstand) : \(element.naam ?? "")",.debug)
        if afstand < kortsteAfstand {kortsteAfstand = afstand
            indexKortsteAfstand = index}
    }
    if indexKortsteAfstand < 999999
    {
        print ("Gewonnen : \(naburigeAdressen[indexKortsteAfstand].naam ?? "")")
    }
    
    if kortsteAfstand != distance {return naburigeAdressen[indexKortsteAfstand]}
    
    //        print ("geen closestAdres?")
    return nil
}
func fetchFirstAdresZonderLocation()->Adres?
{
    let request:NSFetchRequest = Adres.fetchRequest()
    var AdresZonderLocation:[Adres] = []
    request.predicate = NSPredicate(format: "latitude = 0")
    do {  AdresZonderLocation = try context.fetch(request)
    } catch let error {ErrMsg("foutje fetchFirstAdresZonderLocation(.\(error.localizedDescription)",.debug)}
    ErrMsg("er zijn nog \(AdresZonderLocation.count) adressen zonder coördinaten", .debug)
    return AdresZonderLocation.first
}
func telAdressen()->Int
{
    var adressen:[Adres] = []
    do {let request: NSFetchRequest = Adres.fetchRequest()
        adressen = try context.fetch(request)} catch let error {ErrMsg("telAdressen foutje .\(error.localizedDescription)",.debug)}
    return adressen.count
}
func fetchFirstAdres()->Adres? //return 1 adres
{
    var adressen:[Adres] = []
    do {let request: NSFetchRequest = Adres.fetchRequest()
         adressen = try context.fetch(request)} catch let error {ErrMsg("fetchAdres foutje .\(error.localizedDescription)",.debug)}
    return adressen.first
}
func fetchAllAdressen()->[Adres]
{
    var adressen:[Adres] = []
    do {let request: NSFetchRequest = Adres.fetchRequest()
        adressen = try context.fetch(request)} catch let error {ErrMsg("fetchAdres foutje .\(error.localizedDescription)",.debug)}
    return adressen
}
func readJson() {
    let tel = telBezoeken()
    if  tel > 0 {ErrMsg ("er zijn \(tel) bezoeken",.debug) ; return}
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
        if let fileURL = Bundle.main.url(forResource: "visites", withExtension: "json")
        {
            let data = try Data(contentsOf: fileURL)
            let bezoeken = try decoder.decode([myCLVisit].self, from: data)
            print (bezoeken.count)
            var bezoekCount = 0
            var geweigerd = 0
            for bezoek in bezoeken
            {
                if
                (Date(timeIntervalSince1970: bezoek.arrival_1970) == Date.distantFuture) ||
                (Date(timeIntervalSince1970: bezoek.arrival_1970) == Date.distantPast) ||
                (Date(timeIntervalSince1970: bezoek.departure_1970) == Date.distantFuture) ||
                    (Date(timeIntervalSince1970: bezoek.departure_1970) == Date.distantPast)
                    || (bezoek.departure_1970 == bezoek.arrival_1970)
                    {
                    geweigerd = geweigerd + 1
                } else {bezoekCount = bezoekCount + 1
                    // print ("\(Date(timeIntervalSince1970: bezoek.arrival_1970))  tot \(Date(timeIntervalSince1970: bezoek.departure_1970))")
                    let nwBezoek = Bezoek(context:context)
                    nwBezoek.arrival_1970 = bezoek.arrival_1970
                    nwBezoek.departure_1970 = bezoek.departure_1970
                    nwBezoek.coordinate.latitude = bezoek.latitude
                    nwBezoek.coordinate.longitude = bezoek.longitude
                    nwBezoek.info = bezoek.info
                    delegate.saveContext()
                }
            }
            print ("geweigerd: \(geweigerd),over: \(bezoekCount)")
        }
    }
    catch {print ("Error",error)}
}


