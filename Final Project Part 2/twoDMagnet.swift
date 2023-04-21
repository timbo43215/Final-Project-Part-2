//
//  twoDMagnet.swift
//  Final Project
//
//  Created by Tim Stack PHYS 440 on 4/21/23.
//

import SwiftUI
import Foundation

class TwoDMagnet: ObservableObject {
    //var spins = Set<Spin>()
    var spins :[Spin] = []
    
    func setup(N: Int, spinConfiguration: [[Double]], isThereAnythingInMyVariable: Bool){
        let N = Double(N)
        let upperLimit = pow(2.0, N)
        let upperLimitInteger = Int(upperLimit)
        var currentSpinValue = true
        var isThereAnythingInMyVariable: Bool = false
        
        if (spinConfiguration.isEmpty == false) {
            isThereAnythingInMyVariable = true
        }
        
        for y in 0..<(upperLimitInteger - 1){
            
            for x in 0..<(upperLimitInteger - 1){
                                
                if (spinConfiguration[x][y] == 0.5) {
                    currentSpinValue = true
                }
                else {
                    currentSpinValue = false
                }
                    spins.append(Spin(x: Double(x), y: Double(y), spin: currentSpinValue))
            }
            
        }
    }

    func update(to date: Date, N: Int, spinConfiguration: [[Double]], isThereAnythingInMyVariable: Bool) {
        let N = Double(N)
        let upperLimit = pow(2.0, N)
        let upperLimitInteger = Int(upperLimit)
        var currentSpinValue = true
        var isThereAnythingInMyVariable: Bool = false
        
        if (spinConfiguration.isEmpty == false) {
            isThereAnythingInMyVariable = true
        }
        
        if (isThereAnythingInMyVariable == true) {
            for y in 0..<(upperLimitInteger){
                
                for x in 0..<(upperLimitInteger) {
                    
                    if (spinConfiguration[x][y] == 0.5) {
                        currentSpinValue = true
                    }
                    else {
                        currentSpinValue = false
                    }
                    spins.append(Spin(x: Double(x), y: Double(y), spin: currentSpinValue))
                }
            }
        }
    }
}
