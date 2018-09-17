//
//  kaartFuncties.swift
//  LogMyWay
//
//  Created by Toine Schnabel on 05-08-17.
//  Copyright © 2017 Toine Schnabel. All rights reserved.
//

import Foundation
import MapKit
import CoreData

struct kaartData {
    var datum_1970 : TimeInterval
    var soort : SoortCell
    var datum : Date {get {return datum_1970.datum}}
}
var kaartGegevens = [kaartData]()
func mijnMapViewOverrideForOverlay(mapView:MKMapView,overlay:MKOverlay)-> MKOverlayRenderer!
{
    if overlay is MyPolyline {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        polylineRenderer.strokeColor = (overlay as! MyPolyline).kleur
        polylineRenderer.lineWidth = CGFloat((overlay as! MyPolyline).lineWidth)
        print ("Set polyline")
        return polylineRenderer
    }
    return nil
}

func mijnMapViewOveride (_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
{
    var image = "🔴".image(ofSize: 10)
    if let adres = annotation as? Adres {
        var annotView: MKAnnotationView
        var identifier = ""
        identifier = adres.soortPlaats ?? "pin"
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView { // 2
            dequeuedView.annotation = adres
            annotView = dequeuedView
            //                annoMessages.append("reuse:\(identifier)")
        } else {
            // 3
            annotView = MKAnnotationView(annotation: adres, reuseIdentifier: identifier)
            if adres.soortPlaats == "" {identifier = "Default"}
            else {identifier = adres.soortPlaats ?? "Default"
                
                if adres.soortPlaats == ""
                {
                  if let plaatje = UIImage(named: "\(identifier).png")
                  {image = plaatje.resizeImage(newWidth: 10)}
                }  else
                {image = (soortPlaatsKeuzes[adres.soortPlaats ?? ""] ?? "?").image(ofSize: 10)
                }
            //                if adres.soortplaats != Int16(0)
            //                {
            }
            //                }
            annotView.canShowCallout = true
            annotView.calloutOffset = CGPoint(x: -5, y: 5)
            annotView.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure)
            //                annoMessages.append("alloc:\(identifier)")
            annotView.image = image
        }
        print ("set annotation")
        return annotView
    }
    return nil
 
}
extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    } }
func mapBezoeken(datums_1970:[(kaartData)],_ kaart:MKMapView)
{
    kaartGegevens = [kaartData]()
    let datums_1970Sorted = datums_1970.sorted(by: {$0.datum_1970 < $1.datum_1970})
    var vorigBezoek : kaartData?
    for bezoek in datums_1970Sorted
    {
        if vorigBezoek == nil {vorigBezoek = bezoek;kaartGegevens.append(bezoek)}
        else {
            if !skipData(vorigBezoek!,bezoek) {
                kaartGegevens.append(bezoek)
                vorigBezoek = bezoek
                
            } else {print ("\(bezoek.datum.yyyyMMddHHmmss)..deleted..\(bezoek.soort.rawValue)")}
        }
    }
    if teMappenAdressen.count > 0 {kaart.removeAnnotations(teMappenAdressen)}
    //maken:remove polylines for teMappenRoutes
    let teMappenAdressenAndRoutes = adressenVanBezoeken(kaartGegevens)
    teMappenAdressen = Array(teMappenAdressenAndRoutes.adressen)   // set <Adres> -> Array<Adres>
    mapRoutesAndAdressen(newRoute : teMappenAdressenAndRoutes.routes,kaart)
    //maken: add polylines for teMappenRoutes
    kaart.addAnnotations(teMappenAdressen)
    let minMax = minMaxLocatie()
    for adres in teMappenAdressen{minMax.updateWithCLLocationCoordinate2D(adres.coordinate)}
    if let region = minMax.region
    {
    kaart.setRegion(region, animated: true)
    }
    print (" number of annotations:\(kaart.visibleAnnotations().count)")
    for mes in annoMessages {print(mes)}
}
func mapRoutesAndAdressen(newRoute:[CLLocation],  _ kaart:MKMapView){
    print ("route \(newRoute.count)")
    // remove old routes in teMappenRoutes
    kaart.remove(teMappenRoutes)
    // add newRoute
    var coord = [CLLocationCoordinate2D]()
//    var vorigeLocation : CLLocation?
    print ("-- begin mapRoutesAndAdressen voor \(newRoute.count) visites")
//    for location in newRoute {
//        if let x = vorigeLocation {
//            if let route = fetchRoute(van: x.timestamp, tot: location.timestamp)
//            {
//                for loc in route{
//                    coord.append(loc.coordinate)
//                    print ("route timestamps \(loc.timestamp)")
//                }
//            }
//
//        }
//        coord.append(location.coordinate)
//        vorigeLocation = location
//    }
//    for location in newRoute { coord.append(location.coordinate)}
    
    teMappenRoutes = MyPolyline(coordinates:&coord,count:coord.count)
    print ("-- einde mapRoutesAndAdressen voor \(coord.count) coordinaten")
    for x in coord { print ("\(x)") }
    kaart.add(teMappenRoutes)
}
var teMappenRoutes = MyPolyline()
var teMappenAdressen = Array<Adres>()
//var geMapteLocaties = Set<CLLocationCoordinate2D>()

func getAdressen(_ bezoeken:[Bezoek])->Array<Adres>
{
    var adressen = Array<Adres>()
    for bezoek in bezoeken {if let adres = bezoek.metAdres{adressen.append(adres)}}
    return adressen
}

func adressenVanBezoeken(_ data:[kaartData])->(adressen:Set<Adres>,routes:Array<CLLocation>){
    var adressenArray = Array<Adres>()
    var adressenSet = Set<Adres>()
    var bezoekLocations = Array<CLLocation>()
    for item in data
    {
        switch item.soort
        {
        case .maand  : if let bezoekenTemp = fetchBezoekenVoorMaand(item.datum_1970)
        {adressenArray = adressenArray + getAdressen(bezoekenTemp)
            for bezoek in bezoekenTemp {bezoekLocations.append(bezoek.cllocation)}}
        case.dag : if let bezoekenTemp = fetchBezoekenVoorDag(item.datum_1970)
        {adressenArray += getAdressen(bezoekenTemp)
            for bezoek in bezoekenTemp {bezoekLocations.append(bezoek.cllocation)}}
        default: if let bezoekTemp = fetchBezoek(aankomst_1970: item.datum_1970)
        {adressenArray += getAdressen([bezoekTemp])
            bezoekLocations.append(bezoekTemp.cllocation)}}
    }
    adressenSet = Set(adressenArray)
    
    return (adressenSet,bezoekLocations)
}



func skipData(_ a:kaartData,_ b:kaartData)->Bool {
    if a.soort == .maand {if zelfdeMaand(a.datum_1970, b.datum_1970) {return true}}
    if a.soort == .dag {if zelfdeDag(a.datum_1970, b.datum_1970) {return true}}
    return false
}



class MyPolyline: MKPolyline {
//    var coordinaten = [CLLocationCoordinate2D]()
    var kleur = UIColor.green
    var lineWidth = 1
    var tag = 0
    var minMax = minMaxLocatie()
}
extension Adres : MKAnnotation
{
    public var subtitle: String? {return stad}
    public var title: String? {return naam}
}
var annoMessages = [String]()

//func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//    guard let annotation = annotation as? MKAnnotation else {return nil}
//    if let view = mapView.dequeueReusableAnnotationViewWithIdentifier(annotation.identifier) as? MKPinAnnotationView {
//        return view
//    }else {
//        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
//        view.pinTintColor = UIColor.green
//        return view
//    }
//}


extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}
class minMaxLocatie:NSObject {
    required init(coder aDecoder: NSCoder) {
        minLatitude = aDecoder.decodeDouble(forKey: "minLatitude")
        maxLatitude = aDecoder.decodeDouble(forKey: "maxLatitude")
        minLongitude = aDecoder.decodeDouble(forKey: "minLongitude")
        maxLongitude = aDecoder.decodeDouble(forKey: "maxLongitude")
    }
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(minLatitude, forKey: "minLatitude")
        aCoder.encode(maxLatitude, forKey: "maxLatitude")
        aCoder.encode(minLongitude, forKey: "minLongitude")
        aCoder.encode(maxLongitude, forKey: "maxLongitude")
    }
    override init(){}  //=> is verplicht
    var minLatitude = 90.0
    var minLongitude = 180.0
    
    var maxLatitude = -90.0
    var maxLongitude = -180.0
    
    
    var region : MKCoordinateRegion? { get {return regionCalc()}}
    
    
    func updateWithCLLocationCoordinates2D(_ locs:[CLLocationCoordinate2D])
    {
        for new in locs {updateWithCLLocationCoordinate2D(new)}
    }
    func updateWithCLLocationCoordinate2D(_ new:CLLocationCoordinate2D)
    {
        minLatitude = smallest(minLatitude, val2: new.latitude)
        minLongitude = smallest(minLongitude, val2: new.longitude)
        maxLatitude = greatest(maxLatitude, val2: new.latitude)
        maxLongitude = greatest(maxLongitude, val2: new.longitude )
    }
    func updateWithMinMax(_ new:minMaxLocatie)
    {
        minLatitude = smallest(minLatitude, val2: new.minLatitude)
        minLongitude = smallest(minLongitude, val2: new.minLongitude)
        maxLatitude = greatest(maxLatitude, val2: new.maxLatitude)
        maxLongitude = greatest(maxLongitude, val2: new.maxLongitude )
    }
    func greatest(_ val1:Double,val2:Double)->Double{return (val1 > val2 ? val1 : val2)}
    func smallest(_ val1:Double,val2:Double)->Double{return (val1 < val2 ? val1 : val2)}
    
    func regionCalc()->MKCoordinateRegion?
    {
        let center = CLLocationCoordinate2DMake((minLatitude + maxLatitude)/2, (minLongitude + maxLongitude)/2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude) * 1.1 + 0.01, longitudeDelta: (maxLongitude - minLongitude) * 1.1 + 0.01)
        if (center.latitude == 0 && center.longitude == 0) {return nil}
        return MKCoordinateRegion(center: center, span: span)
    }
}

