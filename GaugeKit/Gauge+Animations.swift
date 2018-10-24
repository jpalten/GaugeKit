//
//  Gauge+Animations.swift
//  GaugeKit
//
//  Created by David Pelletier on 16-03-30.
//  Copyright © 2016 Petr Korolev. All rights reserved.
//

import UIKit

extension Gauge {

    public func animateRate(_ duration: TimeInterval, newValue: CGFloat, completion: @escaping (Bool) -> ()) -> Void {

        animateRate(duration, newValue: newValue, newColor: nil, completion: completion)
    }

    public func animateRate(_ duration: TimeInterval, newValue: CGFloat, newColor: UIColor?, completion: @escaping (Bool) -> ()) -> Void {
        animationTimer.invalidate()
        
        let refreshRate: Double = 0.1
        let rateSpeed: CGFloat = CGFloat(refreshRate) * ((newValue - self.rate) / CGFloat(duration))
        //print(rateSpeed)

        animationTimer = Timer.scheduledTimer(
            timeInterval: refreshRate,
            target: self,
            selector: #selector(updateProgress),
            userInfo: [newValue, ( newColor ?? startColor ), rateSpeed],
            repeats: true
        )
        
        animationTimer.fire()
        
        animationCompletionBlock = completion
    }
    
    @objc func updateProgress(_ timer: Timer) -> Void {
        let userInfo = timer.userInfo as! [Any]
        guard let newValue = userInfo.first as? CGFloat else {
            print("GAUGE-KIT: Error, new value not defined...")
            return
        }
        
        guard let rateSpeed = userInfo.last as? CGFloat else {
            print("GAUGE-KIT: Error, rate speed could not be defined...")
            return
        }
        
        guard let newColor = userInfo[1] as? UIColor else {
            print("GAUGE-KIT: Error, new color not defined...")
            return
        }
        
        self.rate += rateSpeed
        self.startColor = newColor

        if rateSpeed < 0 {
            if self.rate <= newValue {
                self.rate = newValue
                timer.invalidate()
                animationCompletionBlock(true)
                //print("GAUGE-KIT: Gauge went down to \(newValue)")
            }
            
            if self.rate <= 0 {
                self.rate = 0
                timer.invalidate()
                animationCompletionBlock(true)
                //print("GAUGE-KIT: Gauge emptied")
            }
        }
        
        if rateSpeed >= 0 {
            if self.rate >= newValue {
                self.rate = newValue
                timer.invalidate()
                animationCompletionBlock(true)
                //print("GAUGE-KIT: Gauge went up to \(newValue)")
            }
            
            if self.rate >= self.maxValue {
                self.rate = self.maxValue
                timer.invalidate()
                animationCompletionBlock(true)
                //print("GAUGE-KIT: Gauge filled")
            }
        }
    }
}
