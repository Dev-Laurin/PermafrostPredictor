//
//  matlabConvertedFunctions.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 5/15/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import Foundation

func compute_ALTf(L: Double, eta: Double, Kt: Double, Ct: Double, Ags: Double, magt: Double, tau: Double)->Double{
    let aa = L*eta/(2*Ct)
    let alpha = Ags/aa
    let beta = -magt/aa
    let delta = log((alpha+1)/(beta+1)) //natural log
    
    let Ab = aa*(alpha - beta)/delta - aa //Abar
    
    let A = (Ab+aa)*aa
    let B = (Ab+aa)*(Ab*delta+Ab+aa)-aa*(alpha-beta)*aa-aa*aa
    let C = -(alpha-beta)*aa*(Ab*delta+Ab+aa)-aa*Ab*delta
    let R = (-B+sqrt(B*B-4*A*C))/(2*A)
    
    return R*sqrt(Kt*tau/Double.pi/Ct)
}

func compute_ALTt(L: Double, eta: Double, Kf: Double, Cf: Double, Ags: Double, magt: Double, tau: Double)->Double{
    let aa=L*eta/(2*Cf)
    let alpha=Ags/aa
    let beta=magt/aa
    let delta=log((alpha+1)/(beta+1)) //natural log
    
    let Ab=aa*(alpha-beta)/delta-aa     //Abar
    
    let A=(Ab+aa)*aa
    let B=(Ab+aa)*(Ab*delta+Ab+aa)-aa*(alpha-beta)*aa-aa*aa
    let C = -(alpha-beta)*aa*(Ab*delta+Ab+aa)-aa*Ab*delta
    let R=(-B+sqrt(B*B-4*A*C))/(2*A)
    
    return R*sqrt(Kf*tau/Double.pi/Cf)
}

/**
 - parameter Cs and Ks: Volumetric heat capacity and thermal conductivity of snow
 - parameter eta: Volumetric water content (mineral soil)
 - parameter Kvf: Thermal conductivity of frozen organic layer
 - parameter Kvt: Thermal conductivity of thawed organic layer
 - parameter Kmf: Thermal conductivity of frozen mineral soil
 - parameter Kmt: Thermal conductivity of thawed mineral soil
 - parameter Cmf: Volumetric heat capacity of frozen mineral soil
 - parameter Cmt: Volumetric heat capacity of thawed mineral soil
 - parameter Cvf: Volumetric heat capacity of frozen organic layer
 - parameter Cvt: Volumetric heat capacity of thawed organic layer
 - parameter Hs: Snow Height
 - parameter Hv: Thickness of vegetation cover
 - parameter Tgs: Mean annual temperature at the top of mineral layer. This is inout (by reference) because it is meant to be storage of a result, not an actual parameter.
 - parameter tTemp: Mean annual air temperature
 - parameter aTemp: Amplitude of the air temperature
*/
func computePermafrost(Kvf: Double, Kvt: Double, Kmf: Double, Kmt: Double, Cmf: Double, Cmt: Double, Cvf: Double, Cvt: Double, Hs: Double, Hv: Double, Cs: Double, Tgs: inout Double, tTemp: Double, aTemp: Double)->Double{
    
    //convert to Kelvin - otherwise we get NaN
    let Tair = tTemp //convertToKelvin(num: tTemp)
    let Aair = aTemp // convertToKelvin(num: aTemp)
    
    //For programming in swift convenience
    let pi = Double.pi
    
    //constants for formula
    let eta:Double = 0.45 //Volumetric water content
    let Ks:Double = 0.15 //Thermal conductivity of snow
    let L:Double = 334000000 //Volumetric latent heat of ice fusion
    let tau:Double = 365*24*3600
//    let time=0:100:tau
    
    //Thermal diffusivity of vegetation
    let Dvf = Kvf/Cvf
    let Dvt = Kvt/Cvt

    //fix the nan - asin rounding problem. Fix the numbers bet [-1, 1]
    var fixNan = Tair/Aair
    if(fixNan > 1){
        fixNan = 1
    }
    else if(fixNan < -1){
        fixNan = -1
    }
    print("fixNan: " + String(fixNan))
    let t0 = -tau/2/pi*asin(fixNan)
    let t1 = tau/2/pi*(pi+asin(fixNan))
    print("t0: " + String(t0))
    print("t1: " + String(t1))
    let tau_s=t1-t0;
    let tau_w=tau-tau_s;
    print("tau_s: " + String(tau_s))
    print("tau_w: " + String(tau_w))
    

    //Computing an effect of snow cover
    let a = 2*Aair*Cvf/(L*eta)
    let b = abs(Tair)*2*Cvf/(L*eta)
    print("a: " + String(a))
    print("b: " + String(b))
 
    let Cfe = Cvf*(a-b)/((a-b)-log((a+1)/(b+1))) // if a == b, log(0) == infinity == nan
    print("Cfe: " + String(Cfe))
    let mu = (sqrt(Ks*Cs)-sqrt(Kvf*Cfe))/(sqrt(Ks*Cs)+sqrt(Kvf*Cfe))
    let r=2*Hs*sqrt(pi*Cs/(tau*Ks))
    let s = exp(r) + 2*mu*cos(r) + mu*mu*exp(-r)
    print("mu: " + String(mu))
    print("r: " + String(r))
    print("s: " + String(s))
    
    let da   = Aair*(1-(1+mu)/sqrt(s))
    let dAs = da*tau_w/tau
    let dTs = (2/pi)*dAs
    let Tvs=Tair+dTs  //Mean annual temperature at the top of vegetation
    let Avs=Aair-dAs  //Amplitude of the temperature at the top of vegetation
    print("da: " + String(da))
    print("dAs: " + String(dAs))
    print("dTs: " + String(dTs))
    print("Tvs: " + String(Tvs))
    print("Avs: " + String(Avs))
    
    //Computing an effect of the vegetation layer
    let daw = (Avs - Tvs)*(1-exp(-Hv*sqrt(pi/(Dvf*2*tau_w))))
    let das = (Aair - Tair)*(1-exp(-Hv*sqrt(pi/(Dvt*2*tau_s))))
    
    let dAv = (daw*tau_w + das*tau_s)/tau
    let dTv = (daw*tau_w - das*tau_s)/tau*2/pi
    
    Tgs=Tvs+dTv    //Mean annual temperature at the top of mineral layer
    let Ags=Avs-dAv    //Amplitude of the temperature at the top of mineral layer

    var dTg:Double = 0.0 //to save it outside the if statement for use
    var magt:Double = 0.0
    var ALD = 0.0
    
    //Phase change processes occur in the mineral soil
    if(Ags>abs(Tgs)){
        let t00 = -tau/2/pi*asin(Tgs/Ags)
        let t11=tau/2/pi*(pi+asin(Tgs/Ags))
        
        let Ith=Ags*(cos(2*pi*t00/tau)-cos(2*pi*t11/tau))*tau/2/pi+Tgs*(t11-t00);
        let Ifr=Tgs*tau-Ith;
        
        let KIt = Kmt*Ith;
        let KIf = Kmf*Ifr;
        
        if(abs(KIt) < abs(KIf)){
            dTg = abs(Ith)*(Kmt/Kmf - 1)/tau
            magt = Tgs + dTg
        }
        else{
            dTg = abs(Ifr)*(1 - Kmf/Kmt)/tau
            magt = Tgs + dTg
        }
    }
    else{
        //Phase change processes do not occur in the mineral soil, vegetation layer is too insulative
        return ALD//ALT is within the organic layer. Remember that there phase change processes are not assumed in this layer.
    }
    
    
    if(magt<0){
        ALD = compute_ALTf(L: L, eta: eta, Kt: Kmt, Ct: Cmt, Ags: Ags, magt: magt, tau: tau)
        let wv = min(Hv/ALD,1)
        let wm = 1 - wv
        let Kt = pow(Kvt,wv)*pow(Kmt,wm)
        let Ct = Cvt*wv+Cmt*wm
        ALD = compute_ALTf(L: L, eta: eta, Kt: Kt, Ct: Ct, Ags: Avs, magt: magt, tau: tau)
    }
    else{
        ALD = compute_ALTt(L: L, eta: eta, Kf: Kmf, Cf: Cmf, Ags: Ags, magt: magt, tau: tau)
        let wv=min(Hv/ALD,1)
        let wm=1-wv
        let Kf=pow(Kvf,wv)*pow(Kmf,wm)
        let Cf=Cvf*wv+Cmf*wm
        ALD=compute_ALTt(L: L, eta: eta, Kf: Kf, Cf: Cf, Ags: Avs, magt: magt, tau: tau)
    }
    
    if(ALD<Hv){
        return ALD//ALT is within the organic layer. Remember that there phase change processes are not assumed in this layer.
    }
    
    return ALD
}
