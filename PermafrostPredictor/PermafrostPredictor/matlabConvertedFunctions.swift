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
*/

func computePermafrost(Kvf: Double, Kvt: Double, Kmf: Double, Kmt: Double, Cmf: Double, Cmt: Double, Cvf: Double, Cvt: Double, Hs: Double, Hv: Double)->Double{
    //For programming in swift convenience
    let pi = Double.pi
    
    //constants for formula
    var Tair:Double = -2 //Mean annual air temperature
    var Aair:Double = 17 //Amplitude of the air temperature
    var eta:Double = 0.45 //Volumetric water content
    let Ks:Double = 0.15 //Thermal conductivity of snow
    let Cs:Double = 500000 //Volumetric heat capacity of snow
    let L:Double = 334000000 //Volumetric latent heat of ice fusion
    let tau:Double = 365*24*3600
//    let time=0:100:tau
    
    //Thermal diffusivity of vegetation
    let Dvf = Kvf/Cvf
    let Dvt = Kvt/Cvt
    
    let t0 = -tau/2/pi*asin(Tair/Aair)
    let t1 = tau/2/pi*(pi+asin(Tair/Aair))
    
    let tau_s=t1-t0;
    let tau_w=tau-tau_s;
    
    //Computing an effect of snow cover
    var a = 2*Aair*Cvf/(L*eta)
    var b = abs(Tair)*2*Cvf/(L*eta)
    
    var Cfe = Cvf*(a-b)/((a-b)-log((a+1)/(b+1)))
    
    var mu = (sqrt(Ks*Cs)-sqrt(Kvf*Cfe))/(sqrt(Ks*Cs)+sqrt(Kvf*Cfe))
    var r=2*Hs*sqrt(pi*Cs/(tau*Ks))
    var s = exp(r) + 2*mu*cos(r) + mu*mu*exp(-r)
    
    var da   = Aair*(1-(1+mu)/sqrt(s))
    var dAs = da*tau_w/tau
    var dTs = (2/pi)*dAs
    
    var Tvs=Tair+dTs  //Mean annual temperature at the top of vegetation
    var Avs=Aair-dAs  //Amplitude of the temperature at the top of vegetation
    
    //Computing an effect of the vegetation layer
    var daw = (Avs - Tvs)*(1-exp(-Hv*sqrt(pi/(Dvf*2*tau_w))))
    var das = (Aair - Tair)*(1-exp(-Hv*sqrt(pi/(Dvt*2*tau_s))))
    
    var dAv = (daw*tau_w + das*tau_s)/tau
    var dTv = (daw*tau_w - das*tau_s)/tau*2/pi
    
    var Tgs=Tvs+dTv    //Mean annual temperature at the top of mineral layer
    var Ags=Avs-dAv    //Amplitude of the temperature at the top of mineral layer

    var dTg:Double = 0.0 //to save it outside the if statement for use
    var magt:Double = 0.0
    var ALD = 0.0
    
    //Phase change processes occur in the mineral soil
    if(Ags>abs(Tgs)){
        var t00 = -tau/2/pi*asin(Tgs/Ags)
        var t11=tau/2/pi*(pi+asin(Tgs/Ags))
        
        var Ith=Ags*(cos(2*pi*t00/tau)-cos(2*pi*t11/tau))*tau/2/pi+Tgs*(t11-t00);
        var Ifr=Tgs*tau-Ith;
        
        var KIt = Kmt*Ith;
        var KIf = Kmf*Ifr;
        
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
