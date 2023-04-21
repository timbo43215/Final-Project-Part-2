//
//  Spins.swift
//  Final Project
//
//  Created by Tim Stack PHYS 440 on 4/7/23.
//

import Foundation

class Spins: ObservableObject {
    
    @Published var arbitrarySpinConfiguration: [[Double]] = []
    @Published var trialSpinConfiguration: [[Double]] = []
    @Published var spinConfiguration: [[Double]] = []
    @Published var timeComponent: [[Double]] = []
}
