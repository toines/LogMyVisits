//
//  FileInput.swift
//  LogMyWay02
//
//  Created by Toine Schnabel on 04-04-15.
//  Copyright (c) 2015 Toine Schnabel. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation


class FileInput
{
    
    func leesFile()
    {
        var visiteArray :[myCLVisit] = []
//        var locationsArray:[CLLocation]=[]
        print ("leesfile started")
        //        var prevVisit:CLVisit = CLVisit()
        if let pathdm = Bundle.main.path(forResource: "visits", ofType: "vis") {
//            NSKeyedUnarchiver.setClass(myCLVisit.self, forClassName: "myCLVisit")
            if let datdm = try? Data(contentsOf: URL(fileURLWithPath: pathdm))
             {if let visits =  NSKeyedUnarchiver.unarchiveObject(with: datdm) as? [myCLVisit]
            {visiteArray = visits.sorted(by: {$0.arrival_1970 > $1.arrival_1970})}}}
            let x = visiteArray.count
            while (visiteArray.count > x-x) /*&& (locationsArray.count > 0)*/
            {
                    _ = Bezoek(visiteArray.last!)
                    visiteArray.removeLast()
            }
            
        }
}

