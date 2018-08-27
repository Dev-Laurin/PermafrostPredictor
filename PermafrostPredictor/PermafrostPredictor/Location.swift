//
//  Location.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 7/30/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit
import os.log

class Location : NSObject, NSCoding {
 
    //Name of the place
    var name: String
    var Kvf: Double
    var Kvt: Double
    var Kmf: Double
    var Kmt: Double
    var Cmf: Double
    var Cmt: Double
    var Cvf: Double
    var Cvt: Double
    var Hs: Double
    var Hv: Double //organic layer thickness
    var Cs: Double //volumetric heat capacity of snow
    var Tgs: Double //Mineral layer temperature
    var eta: Double //Volumetric water content
    var Ks: Double //Thermal conductivity of snow
    var Tair: Double //Mean Annual temperature
    var Aair : Double //Amplitude of the air temperature
    var ALT: Double //Active Layer Thickness
    
    //default constructor
    override init() {
        self.name = ""
        self.Kvf = 0.0
        self.Kvt = 0.0
        self.Kmf = 0.0
        self.Kmt = 0.0
        self.Cmf = 0.0
        self.Cmt = 0.0
        self.Cvf = 0.0
        self.Cvt = 0.0
        self.Hs = 0.0
        self.Hv = 0.0
        self.Cs = 0.0
        self.Tgs = 0.0
        self.eta = 0.0
        self.Ks = 0.0
        self.Tair = 0.0
        self.Aair = 0.0
        self.ALT = 0.0
    }
    
    //constructor with parameters
    init?(name: String, Kvf: Double, Kvt: Double, Kmf: Double, Kmt: Double, Cmf: Double, Cmt: Double, Cvf: Double, Cvt: Double, Hs: Double, Hv: Double, Cs: Double, Tgs: Double, eta: Double, Ks: Double, Tair: Double, Aair: Double, ALT: Double){
        
        //check if name exists
        guard !name.isEmpty else{
            return nil //throw error otherwise 
        }
        self.name = name
        self.Kvf = Kvf
        self.Kvt = Kvt
        self.Kmf = Kmf
        self.Kmt = Kmt
        self.Cmf = Cmf
        self.Cmt = Cmt
        self.Cvf = Cvf
        self.Cvt = Cvt
        self.Hs = Hs
        self.Hv = Hv
        self.Cs = Cs
        self.Tgs = Tgs
        self.eta = eta
        self.Ks = Ks
        self.Tair = Tair
        self.Aair = Aair
        self.ALT = ALT
        
    }
    
    //MARK: types
    struct PropertyKey {
        static let name = "name"
        static let Kvf = "Kvf"
        static let Kvt = "Kvt"
        static let Kmf = "Kmf"
        static let Kmt = "Kmt"
        static let Cmf = "Cmf"
        static let Cmt = "Cmt"
        static let Cvf = "Cvf"
        static let Cvt = "Cvt"
        static let Hs = "Hs"
        static let Hv = "Hv"
        static let Cs = "Cs"
        static let Tgs = "Tgs"
        static let eta = "eta"
        static let Ks = "Ks"
        static let Tair = "Tair"
        static let Aair = "Aair"
        static let ALT = "ALT"
        
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(Kvf, forKey: PropertyKey.Kvf)
        aCoder.encode(Kvt, forKey: PropertyKey.Kvt)
        aCoder.encode(Kmf, forKey: PropertyKey.Kmf)
        aCoder.encode(Kmt, forKey: PropertyKey.Kmt)
        
        aCoder.encode(Cmf, forKey: PropertyKey.Cmf)
        aCoder.encode(Cmt, forKey: PropertyKey.Cmt)
        aCoder.encode(Cvf, forKey: PropertyKey.Cvf)
        aCoder.encode(Cvt, forKey: PropertyKey.Cvt)
        
        aCoder.encode(Hs, forKey: PropertyKey.Hs)
        aCoder.encode(Hv, forKey: PropertyKey.Hv)
        
        aCoder.encode(Cs, forKey: PropertyKey.Cs)
        aCoder.encode(Tgs, forKey: PropertyKey.Tgs)
        aCoder.encode(eta, forKey: PropertyKey.eta)
        aCoder.encode(Ks, forKey: PropertyKey.Ks)
        
        aCoder.encode(Tair, forKey: PropertyKey.Tair)
        aCoder.encode(Aair, forKey: PropertyKey.Aair)
        aCoder.encode(ALT, forKey: PropertyKey.ALT)
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        //the name is required, if cannot decode should fail
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a location.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let Kvf = aDecoder.decodeDouble(forKey: PropertyKey.Kvf) as Double? else {
            os_log("Unable to decode Kvf number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Kvt = aDecoder.decodeDouble(forKey: PropertyKey.Kvt) as Double? else {
            os_log("Unable to decode Kvt number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Kmf = aDecoder.decodeDouble(forKey: PropertyKey.Kmf) as Double? else {
            os_log("Unable to decode Kmf number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Kmt = aDecoder.decodeDouble(forKey: PropertyKey.Kmt) as Double? else {
            os_log("Unable to decode Kmt number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Cmf = aDecoder.decodeDouble(forKey: PropertyKey.Cmf) as Double? else {
            os_log("Unable to decode Cmf number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Cmt = aDecoder.decodeDouble(forKey: PropertyKey.Cmt) as Double? else {
            os_log("Unable to decode Cmt number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Cvf = aDecoder.decodeDouble(forKey: PropertyKey.Cvf) as Double? else {
            os_log("Unable to decode Cvf number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Cvt = aDecoder.decodeDouble(forKey: PropertyKey.Cvt) as Double? else {
            os_log("Unable to decode Cvt number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Hs = aDecoder.decodeDouble(forKey: PropertyKey.Hs) as Double? else {
            os_log("Unable to decode Hs number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Hv = aDecoder.decodeDouble(forKey: PropertyKey.Hv) as Double? else {
            os_log("Unable to decode Hv number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Cs = aDecoder.decodeDouble(forKey: PropertyKey.Cs) as Double? else {
            os_log("Unable to decode Cs number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Tgs = aDecoder.decodeDouble(forKey: PropertyKey.Tgs) as Double? else {
            os_log("Unable to decode Tgs number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let eta = aDecoder.decodeDouble(forKey: PropertyKey.eta) as Double? else {
            os_log("Unable to decode eta number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Ks = aDecoder.decodeDouble(forKey: PropertyKey.Ks) as Double? else {
            os_log("Unable to decode Ks number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Tair = aDecoder.decodeDouble(forKey: PropertyKey.Tair) as Double? else {
            os_log("Unable to decode Tair number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let Aair = aDecoder.decodeDouble(forKey: PropertyKey.Aair) as Double? else {
            os_log("Unable to decode Aair number.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let ALT = aDecoder.decodeDouble(forKey: PropertyKey.ALT) as Double? else {
            os_log("Unable to decode ALT number.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name, Kvf: Kvf, Kvt: Kvt, Kmf: Kmf, Kmt: Kmt, Cmf: Cmf, Cmt: Cmt, Cvf: Cvf, Cvt: Cvt, Hs: Hs, Hv: Hv, Cs: Cs, Tgs: Tgs, eta: eta, Ks: Ks, Tair: Tair, Aair: Aair, ALT: ALT)
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("locations")
    static let oneLocationURL = DocumentsDirectory.appendingPathComponent("location")
}
