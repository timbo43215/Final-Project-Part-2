//
//  twoDMagnet.swift
//  Final Project
//
//  Created by Tim Stack PHYS 440 on 4/21/23.
//

import SwiftUI
import Foundation

class TwoDMagnet: ObservableObject {
        
        @ObservedObject var plotSpinConfiguration = Spins()
        
        func setup(number: Int){
            
            for y in 0..<(number){
                
                for x in 0..<number{
                    
                    plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(x), y: Double(y), spin: true))
                    
                }
                
            }
        }

        func update(to date: Date) {
            
        }
    }
    
//    //var spins = Set<Spin>()
//    var spins :[Spin] = []
//    var spinConfiguration: [[Double]]?
//
//    func setup(N: Int, isThereAnythingInMyVariable: Bool){
//        let N = Double(N)
//        let upperLimit = sqrt(N)
//        let upperLimitInteger = Int(upperLimit)
//        var currentSpinValue = true
//        var isThereAnythingInMyVariable: Bool = false
//
//        if (spinConfiguration != nil) {
//            isThereAnythingInMyVariable = true
//        }
//
//        for y in 0..<(upperLimitInteger - 1){
//
//            for x in 0..<(upperLimitInteger - 1){
//
//                if (spinConfiguration![x][y] == 0.5) {
//                    currentSpinValue = true
//                }
//                else {
//                    currentSpinValue = false
//                }
//                    spins.append(Spin(x: Double(x), y: Double(y), spin: currentSpinValue))
//            }
//
//        }
//    }
//
//    func update(to date: Date, N: Int, isThereAnythingInMyVariable: Bool) {
//        //print("Spin Configuration in Update:")
//        //print(spinConfiguration)
//        let N = Double(N)
//        let upperLimit = sqrt(N)
//        let upperLimitInteger = Int(upperLimit)
//        var currentSpinValue = true
//        var isThereAnythingInMyVariable: Bool = false
//
//        if (spinConfiguration != nil) {
//            isThereAnythingInMyVariable = true
//        }
//
//        if (isThereAnythingInMyVariable == true) {
//            for y in 0..<(upperLimitInteger){
//
//                for x in 0..<(upperLimitInteger) {
//
//                    if (spinConfiguration![x][y] == 0.5) {
//                        currentSpinValue = true
//                    }
//                    else {
//                        currentSpinValue = false
//                    }
//                    spins.append(Spin(x: Double(x), y: Double(y), spin: currentSpinValue))
//                }
//            }
//        }
//    }
//}
