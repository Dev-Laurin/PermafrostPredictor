//
//  Location.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 7/30/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

class Location{
    
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
    init() {
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

}
