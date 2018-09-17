//
//  bezoekVC.swift
//  LogMyVisits
//
//  Created by Toine Schnabel on 02-08-18.
//  Copyright © 2018 Toine Schnabel. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit


let delegate = (UIApplication.shared.delegate as! AppDelegate)
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
var selectingForMapActive = false
let cellTabel = CellTabel()






class bezoekVC: UIViewController, CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate  {

    @IBOutlet var tabel: UITableView!
    @IBOutlet var Kaart: MKMapView!
    @IBOutlet var knoppenStack: UIStackView!
    @IBOutlet var setup: UIButton!
    @IBOutlet var upButton: UIButton!
    @IBOutlet var downButton: UIButton!
    
    
    var lm : CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        if lm == nil {
            lm = CLLocationManager()
            lm!.requestAlwaysAuthorization()
            lm!.allowsBackgroundLocationUpdates = true
            lm!.delegate = self
            lm!.startMonitoringVisits()
//            lm!.startUpdatingLocation()
//            lm!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        let tel = telAdressen()
        if tel == 0 {StoreAllContactsAdresses()} else {ErrMsg("aantal adressen: \(tel)", .debug)}
        checkForBackgroundForeground()
    }

          // Do any additional setup after loading the view.
        
    override func viewWillAppear(_ animated: Bool) {
        ErrMsg("viewWillAppear",.debug)
        self.navigationController?.navigationBar.isHidden = true
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    @IBAction func up(_ sender: UIButton) {
        let hoogte = (UIScreen.main.bounds.height - 50)/2
        UIView.animate(withDuration: 0.2, animations: {
            self.tabel.frame.size.height = self.tabel.frame.size.height - hoogte
            self.knoppenStack.frame.origin.y = self.knoppenStack.frame.origin.y - hoogte
            self.Kaart.frame.origin.y = self.Kaart.frame.origin.y - hoogte
            self.Kaart.frame.size.height =  self.Kaart.frame.size.height + hoogte
            
        })
        downButton.isHidden = false
        if tabel.frame.size.height <= 0 {upButton.isHidden = true}
    }
    @IBAction func changeSortOrder(_ sender: UIButton) {
        cellTabel.sortAscending = !cellTabel.sortAscending
        cellTabel.sort()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @IBAction func selectForMap(_ sender: UIButton) {
        if sender.titleLabel?.text == "Select" {
            sender.setTitle("Ready", for: .normal)
            sender.setTitleColor(.red, for: .normal)
            selectingForMapActive = true
        }
        else
        {
            sender.setTitle("Select", for: .normal)
            sender.setTitleColor(.yellow, for: .normal)
            selectingForMapActive = false
        }
    }
    
    @IBAction func down(_ sender: UIButton) {
        let hoogte = (UIScreen.main.bounds.height-50)/2
        UIView.animate(withDuration: 0.2, animations: {
            self.tabel.frame.size.height = self.tabel.frame.size.height + hoogte
            self.knoppenStack.frame.origin.y = self.knoppenStack.frame.origin.y + hoogte
            self.Kaart.frame.origin.y = self.Kaart.frame.origin.y + hoogte
            self.Kaart.frame.size.height =  self.Kaart.frame.size.height - hoogte
        })
        upButton.isHidden = false
        if Kaart.frame.size.height <= 0 {downButton.isHidden = true}
        
        
    }


}

struct Coordinaat: Codable {
    var latitude: Double
    var longitude: Double
}
class myCLVisit:Codable {  // tijdelijk
    let info : String?
    let  latitude : Double
    let longitude : Double
    let departure_1970 : Double
    let arrival_1970 : Double
//    public init (_ arrivalDate: Date,_ departureDate: Date,_ coordinate: Coordinaat){
//        self.arrival_1970 = arrivalDate.timeIntervalSince1970
//        self.departure_1970 = departureDate.timeIntervalSince1970
//        self.coordinate = coordinate
//        self.horizontalAccuracy = 20
//    }
    
}


