//
//  ContentView.swift
//  Final Project
//
//  Created by Tim Stack on 4/7/23.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @State var upOrDown = [1.0, -1.0]
    @State var spinArray: [Double] = []
    @State var nextSpinArray: [Double] = []
    @State var timeArray: [Double] = []
    @State var N: String = "1000"
    @State var J: String = "1.0"
    @State var g: String = "1.0"
    @State var B: String = "0.0"
    @State var kT: String = "10"
    @State var potentialArray: [Double] = []
    @State var trialEnergy: Double = 0.0
    @State var energy: Double = 0.0
    @State var ktForX: [Double] = []
    @State var specificHeat: [Double] = []
    @State var magnetizationForPlot: [Double] = []
    @StateObject var mySpins = Spins()
    @StateObject var myEnergy = Energy()
    @StateObject var myPotential = Potential()
    @StateObject var twoDMagnet = TwoDMagnet()
    @State var thermalProperties = [ThermalProperties]()
    let upColor = Color(red: 0.25, green: 0.5, blue: 0.75)
    let downColor = Color(red: 0.75, green: 0.5, blue: 0.25)
    @State var spinWidth = 25
    
    var body: some View {
            VStack {
                HStack {
                    VStack {
                        Text("Magnetization vs. kT")
                        Chart {
                            ForEach(thermalProperties, id: \.kT) { item in
                                PointMark(
                                    x: .value("kT", item.kT),
                                    y: .value("Magnetization", item.magnetization)
                                )
                            }
                        }
                        .padding()
                    }
                    VStack {
                        Text("Specific Heat vs. kT")
                        Chart {
                            ForEach(thermalProperties, id: \.kT) { item in
                                PointMark(
                                    x: .value("kT", item.kT),
                                    y: .value("Specific Heat", item.specificHeat)
                                )
                            }
                        }
                        .padding()
                    }
                    VStack {
                        Text("Energy vs. kT")
                        Chart {
                            ForEach(thermalProperties, id: \.kT) { item in
                                PointMark(
                                    x: .value("kT", item.kT),
                                    y: .value("Energy", item.energy)
                                )
                            }
                        }
                        .padding()
                    }
                    //                Button(action: {
                    //                    self.calculateColdSpinConfiguration2D()})
                    //                {Text("Calculate Cold Spin Configuration")}
                    //                Button(action: {
                    //                    self.calculateArbitrarySpinConfiguration2D()})
                    //                {Text("Calculate Arbitrary Spin Configuration")}
                    //                Button(action: {
                    //                    self.calculateTrialConfiguration2D()})
                    //                {Text("Calculate Trial Configuration")}
                    //                Button(action: {
                    //                    self.calculateColdMetropolisAlgorithm2D()})
                    //                {Text("Calculate Cold Metropolis Algorithm")}
                    //                Button(action: {
                    //                    self.calculateArbitraryMetropolisAlgorithm2D()})
                    //                {Text("Calculate Cold Metropolis Algorithm")}
                    TimelineView(.animation) { timeline in
                        Canvas { context, size in
                            twoDMagnet.update(to: timeline.date)
                            
                            for spin in twoDMagnet.plotSpinConfiguration.plotSpinConfiguration {
                                let rect = CGRect(x: spin.x * (size.width/CGFloat(spinWidth)), y: spin.y * (size.height/CGFloat(spinWidth)), width: (size.height/CGFloat(spinWidth)), height: (size.height/CGFloat(spinWidth)))
                                let shape = Rectangle().path(in: rect)
                                if (spin.spin){
                                    context.fill(shape, with: .color(upColor))}
                                else{
                                    context.fill(shape, with: .color(downColor))
                                    
                                }
                            }
                        }
                    }
                    
                    .background(.black)
                    .ignoresSafeArea()
                    .padding()
                }
                    
                    HStack{
                        
                        Button("Start from Cold", action: setupSpinsfromCold)
                            .padding()
                        Button("SpinMeCold", action: changeSpinsfromCold)
                            .padding()
                        Button("Start from Arbitrary", action: setupSpinsfromArbitrary)
                            .padding()
                        Button("SpinMeArbitrary", action: changeSpinsfromArbitrary)
                            .padding()
                        
                        Text("N:")
                        TextField("N:", text: $N)
                            .padding()
                        
                        Text("kT:")
                        TextField("kT:", text: $kT)
                            .padding()
                    }
                }
            }
        
        func setupSpinsfromCold(){
            let N = Double(N)!
            spinWidth = Int(sqrt(N))
            var currentSpinValue = true
            self.calculateColdSpinConfiguration2D()
            
            for j in 0..<spinWidth {
                for i in 0..<spinWidth {
                    if (mySpins.spinConfiguration[i][j] == 1.0) {
                        currentSpinValue = true
                    }
                    else {
                        currentSpinValue = false
                    }
                    twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
                }
            }
        }
        
        func changeSpinsfromCold(){
            Task{
                await self.calculateColdMetropolisAlgorithm2D()
            }
        }
        
        func setupSpinsfromArbitrary(){
            let N = Double(N)!
            spinWidth = Int(sqrt(N))
            var currentSpinValue = true
            self.calculateArbitrarySpinConfiguration2D()
            
            for j in 0..<spinWidth {
                for i in 0..<spinWidth {
                    if (mySpins.spinConfiguration[i][j] == 1.0) {
                        currentSpinValue = true
                    }
                    else {
                        currentSpinValue = false
                    }
                    twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
                }
            }
        }
        
        func changeSpinsfromArbitrary(){
            Task{
                await self.calculateArbitraryMetropolisAlgorithm2D()
            }
        }
        
        func setupColdSpins() -> [[Double]]{
            let N = Double(N)!
            self.clearParameters ()
            self.calculateColdSpinConfiguration2D()
            return mySpins.spinConfiguration
        }
        
        func setupArbitrarySpins() -> [[Double]] {
            let N = Double(N)!
            self.clearParameters ()
            self.calculateArbitrarySpinConfiguration2D()
            return mySpins.spinConfiguration
        }
        
        func clearParameters () {
            myEnergy.energy1D = []
            mySpins.spinConfiguration = []
            spinArray = []
            nextSpinArray = []
        }
        
        /// 1. Start with an arbitrary spin configuration α(k) = {s1, s2,...,sN }.
        func calculateColdSpinConfiguration2D (){
            mySpins.spinConfiguration = []
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            var spinValue: [Double] = []
            for j in 1...upperLimitInteger {
                for i in 1...(upperLimitInteger) {
                    if (j > 1) {
                        spinValue.removeLast()
                    }
                    spinValue.append(1.0)
                }
                mySpins.spinConfiguration.append(spinValue)
            }
            print(mySpins.spinConfiguration)
        }
        /// 1. Start with an arbitrary spin configuration α(k) = {s1, s2,...,sN }.
        func calculateArbitrarySpinConfiguration2D (){
            mySpins.spinConfiguration = []
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            var spinValue: [Double] = []
            
            for j in 1...upperLimitInteger {
                for i in 1...upperLimitInteger {
                    if (j > 1) {
                        spinValue.removeLast()
                    }
                    let s = Int.random(in: 0...1)
                    spinValue.append(upOrDown[s])
                }
                mySpins.spinConfiguration.append(spinValue)
            }
            print(mySpins.spinConfiguration)
        }
        /// 2. Generate a trial configuration α(k+1) by
        ///     a. picking a particle i randomly and
        ///     b. flipping its spin.1
        /// Takes the arbitrary spin configuration created in calculateArbitrarySpinConfiguration and copies it.
        /// Then it takes the value of a random particle in the 2x2 matrix and flips its spin.
        func calculateTrialConfiguration2D () -> [[Double]] {
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            let randParticleX = Int.random(in: 0...(upperLimitInteger - 1))
            let randParticleY = Int.random(in: 0...(upperLimitInteger - 1))
            var trialConfiguration = mySpins.spinConfiguration
            
            if (trialConfiguration[randParticleX][randParticleY] == 0.5) {
                trialConfiguration[randParticleX][randParticleY] = -0.5
            }
            else {
                trialConfiguration[randParticleX][randParticleY] = 0.5
            }
            //print(trialConfiguration)
            return trialConfiguration
        }
        
        func calculateEnergyOfTrialConfiguration2D (x: Int, J: Int, trialConfiguration: [[Double]]) {
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            trialEnergy = 0.0
            
            let J = Double(J)
            let eValue = 2.7182818284590452353602874713
            // hbarc in eV*Angstroms
            let hbarc = 1973.269804
            // mass of electron in eVc^2
            let m = 510998.95000
            let g = Double(g)!
            let bohrMagneton = (eValue*hbarc)/(2.0*m)
            let B = Double(B)!
            
            for j in 0..<upperLimitInteger {
                for i in 0..<upperLimitInteger {
                    if (i > 0 && i < (upperLimitInteger-1) && j > 0 && j < (upperLimitInteger-1)) {
                        let term1 = trialConfiguration[i+1][j]
                        let term2 = trialConfiguration[i-1][j]
                        let term3 = trialConfiguration[i][j+1]
                        let term4 = trialConfiguration[i][j-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[i][j])*(term1 + term2 + term3 + term4)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    else if (i == 0 && j == 0) {
                        let term1 = trialConfiguration[1][0]
                        let term2 = trialConfiguration[0][1]
                        let term3 = trialConfiguration[upperLimitInteger-1][0]
                        let term4 = trialConfiguration[0][upperLimitInteger-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[0][0])*(term1 + term2 + term3 + term4)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    else if (i == 0 && j == (upperLimitInteger-1)) {
                        let term1 = trialConfiguration[0][0]
                        let term2 = trialConfiguration[0][upperLimitInteger-2]
                        let term3 = trialConfiguration[upperLimitInteger-1][upperLimitInteger-1]
                        let term4 = trialConfiguration[1][upperLimitInteger-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[0][upperLimitInteger-1])*(term2 + term4 + term3 + term1)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    else if (i == (upperLimitInteger-1) && j == 0) {
                        let term1 = trialConfiguration[upperLimitInteger-1][1]
                        let term2 = trialConfiguration[upperLimitInteger-2][0]
                        let term3 = trialConfiguration[upperLimitInteger-1][upperLimitInteger-1]
                        let term4 = trialConfiguration[0][0]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[upperLimitInteger-1][0])*(term1 + term2 + term3 + term4)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    else if (i == (upperLimitInteger-1) && j == (upperLimitInteger-1)) {
                        let term1 = trialConfiguration[upperLimitInteger-1][0]
                        let term2 = trialConfiguration[upperLimitInteger-2][upperLimitInteger-1]
                        let term3 = trialConfiguration[upperLimitInteger-1][upperLimitInteger-2]
                        let term4 = trialConfiguration[0][upperLimitInteger-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[upperLimitInteger-1][upperLimitInteger-1])*(term2 + term1 + term3 + term4)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    // 0<x<N-1   y = N-1
                    else if (i > 0 && i < (upperLimitInteger-1) && j == (upperLimitInteger-1)) {
                        let term1 = trialConfiguration[i+1][j]
                        let term2 = trialConfiguration[i-1][j]
                        let term3 = trialConfiguration[i][0]
                        let term4 = trialConfiguration[i][j-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[i][j])*(term1 + term2 + term4 + term3)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    // 0<x<N-1   y = 0
                    else if (i > 0 && i < (upperLimitInteger-1) && j == 0) {
                        let term1 = trialConfiguration[i+1][j]
                        let term2 = trialConfiguration[i-1][j]
                        let term3 = trialConfiguration[i][j+1]
                        let term4 = trialConfiguration[i][upperLimitInteger-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[i][j])*(term1 + term2 + term3 + term4)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    // 0 < y < N-1     x = 0
                    else if (j > 0 && j < (upperLimitInteger-1) && i == 0) {
                        let term1 = trialConfiguration[i+1][j]
                        let term2 = trialConfiguration[upperLimitInteger-1][j]
                        let term3 = trialConfiguration[i][j+1]
                        let term4 = trialConfiguration[i][j-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[i][j])*(term3 + term4 + term1 + term2)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                    // 0 < y < N-1     x = N-1
                    else if (j > 0 && j < (upperLimitInteger-1) && i == upperLimitInteger-1) {
                        let term1 = trialConfiguration[0][j]
                        let term2 = trialConfiguration[i-1][j]
                        let term3 = trialConfiguration[i][j+1]
                        let term4 = trialConfiguration[i][j-1]
                        
                        let trialEnergyValue = -2.0*(trialConfiguration[i][j])*(term3 + term4 + term2 + term1)
                        trialEnergy = trialEnergy + trialEnergyValue
                    }
                }
            }
            print("Trial Energy:")
            print(trialEnergy)
        }
        
        
        func calculateEnergyOfPreviousConfiguration2D (x:Int, J: Int) {
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            energy = 0.0
            
            let J = Double(J)
            let eValue = 2.7182818284590452353602874713
            // hbarc in eV*Angstroms
            let hbarc = 1973.269804
            // mass of electron in eVc^2
            let m = 510998.95000
            // let g = Double(g)!
            let bohrMagneton = (eValue*hbarc)/(2.0*m)
            let B = Double(B)!
            
            if (x > 0) {
                for j in 0..<(upperLimitInteger) {
                    for i in 0..<(upperLimitInteger ) {
                        if (i > 0 && i < (upperLimitInteger-1) && j > 0 && j < (upperLimitInteger-1)) {
                            let term1 = mySpins.spinConfiguration[i+1][j]
                            let term2 = mySpins.spinConfiguration[i-1][j]
                            let term3 = mySpins.spinConfiguration[i][j+1]
                            let term4 = mySpins.spinConfiguration[i][j-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[i][j])*(term1 + term2 + term3 + term4)
                            energy = energy + energyValue
                        }
                        else if (i == 0 && j == 0) {
                            let term1 = mySpins.spinConfiguration[1][0]
                            let term2 = mySpins.spinConfiguration[0][1]
                            let term3 = mySpins.spinConfiguration[upperLimitInteger-1][0]
                            let term4 = mySpins.spinConfiguration[0][upperLimitInteger-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[0][0])*(term1 + term2 + term3 + term4)
                            energy = energy + energyValue
                        }
                        else if (i == 0 && j == (upperLimitInteger-1)) {
                            let term1 = mySpins.spinConfiguration[0][0]
                            let term2 = mySpins.spinConfiguration[0][upperLimitInteger-2]
                            let term3 = mySpins.spinConfiguration[upperLimitInteger-1][upperLimitInteger-1]
                            let term4 = mySpins.spinConfiguration[1][upperLimitInteger-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[0][upperLimitInteger-1])*(term2 + term4 + term3 + term1)
                            energy = energy + energyValue
                        }
                        else if (i == (upperLimitInteger-1) && j == 0) {
                            let term1 = mySpins.spinConfiguration[upperLimitInteger-1][1]
                            let term2 = mySpins.spinConfiguration[upperLimitInteger-2][0]
                            let term3 = mySpins.spinConfiguration[upperLimitInteger-1][upperLimitInteger-1]
                            let term4 = mySpins.spinConfiguration[0][0]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[upperLimitInteger-1][0])*(term1 + term2 + term3 + term4)
                            energy = energy + energyValue
                        }
                        else if (i == (upperLimitInteger-1) && j == (upperLimitInteger-1)) {
                            let term1 = mySpins.spinConfiguration[upperLimitInteger-1][0]
                            let term2 = mySpins.spinConfiguration[upperLimitInteger-2][upperLimitInteger-1]
                            let term3 = mySpins.spinConfiguration[upperLimitInteger-1][upperLimitInteger-2]
                            let term4 = mySpins.spinConfiguration[0][upperLimitInteger-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[upperLimitInteger-1][upperLimitInteger-1])*(term2 + term1 + term3 + term4)
                            energy = energy + energyValue
                        }
                        // 0<x<N-1   y = N-1
                        else if (i > 0 && i < (upperLimitInteger-1) && j == (upperLimitInteger-1)) {
                            let term1 = mySpins.spinConfiguration[i+1][j]
                            let term2 = mySpins.spinConfiguration[i-1][j]
                            let term3 = mySpins.spinConfiguration[i][0]
                            let term4 = mySpins.spinConfiguration[i][j-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[i][j])*(term1 + term2 + term4 + term3)
                            energy = energy + energyValue
                        }
                        // 0<x<N-1   y = 0
                        else if (i > 0 && i < (upperLimitInteger-1) && j == 0) {
                            let term1 = mySpins.spinConfiguration[i+1][j]
                            let term2 = mySpins.spinConfiguration[i-1][j]
                            let term3 = mySpins.spinConfiguration[i][j+1]
                            let term4 = mySpins.spinConfiguration[i][upperLimitInteger-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[i][j])*(term1 + term2 + term3 + term4)
                            energy = energy + energyValue
                        }
                        // 0 < y < N-1     x = 0
                        else if (j > 0 && j < (upperLimitInteger-1) && i == 0) {
                            let term1 = mySpins.spinConfiguration[i+1][j]
                            let term2 = mySpins.spinConfiguration[upperLimitInteger-1][j]
                            let term3 = mySpins.spinConfiguration[i][j+1]
                            let term4 = mySpins.spinConfiguration[i][j-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[i][j])*(term3 + term4 + term1 + term2)
                            energy = energy + energyValue
                        }
                        // 0 < y < N-1     x = N-1
                        else if (j > 0 && j < (upperLimitInteger-1) && i == upperLimitInteger-1) {
                            let term1 = mySpins.spinConfiguration[0][j]
                            let term2 = mySpins.spinConfiguration[i-1][j]
                            let term3 = mySpins.spinConfiguration[i][j+1]
                            let term4 = mySpins.spinConfiguration[i][j-1]
                            
                            let energyValue = -2.0*(mySpins.spinConfiguration[i][j])*(term3 + term4 + term2 + term1)
                            energy = energy + energyValue
                        }
                    }
                }
            }
            print("Energy:")
            print(energy)
        }
        
        func calculateEnergyCheck (x: Int, trialConfiguration: [[Double]]) {
            
            if (x > 0) {
                if (trialEnergy <= energy) {
                    mySpins.spinConfiguration = trialConfiguration
                    myEnergy.energy1D.append(trialEnergy)
                    print("Trial Accepted")
                    print(mySpins.spinConfiguration)
                }
                else {
                    let R = calculateRelativeProbability()
                    let uniformRandomNumber = Double.random(in: 0...1)
                    
                    if (R >= uniformRandomNumber){
                        mySpins.spinConfiguration = trialConfiguration
                        myEnergy.energy1D.append(trialEnergy)
                        print("Trial Accepted")
                        print(mySpins.spinConfiguration)
                    }
                    else {
                        //mySpins.spinConfiguration.removeLast()
                        myEnergy.energy1D.append(energy)
                        print("Trial Rejected")
                        print(mySpins.spinConfiguration)
                    }
                }
            }
            
            //twoDMagnet.spinConfiguration = mySpins.spinConfiguration
        }
        /// This calculates the relative probability from Equation 15.13 on page 395 in Landau.
        ///  R = exp(-deltaE/kT), where k is the boltzmann constant, T is temperature in Kelvin, and
        ///  deltaE = E(trial) - E(previous)
        func calculateRelativeProbability () -> Double {
            
            let deltaE = trialEnergy - energy
            // units =  m2 kg s-2 K-1
            var R = 0.0
            let kTDouble = Double(kT)!
            R = exp(-deltaE/(kTDouble))
            //print(R)
            
            return R
        }
        // From Equation 15.15
        // U(T) = <E>
        //
        
        func calculateInternalEnergy2D () -> Double {
            let energyCount = myEnergy.energy1D.count
            var totalEnergy: Double = 0.0
            var internalEnergy: Double = 0.0
            
            for U in 0...(energyCount - 1) {
                totalEnergy = totalEnergy + myEnergy.energy1D[U]
            }
            let energyCountDouble = Double(energyCount)
            internalEnergy = totalEnergy/energyCountDouble
            print("Internal Energy:")
            print(internalEnergy)
            return internalEnergy
        }
        // From Equation 15.14
        //       N
        //      ___
        //      \
        // M  =  >  s
        //  j   /    i
        //      ---
        //      i=1
        
        func calculateMagnetization2D () -> Double {
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            var magnetization: Double = 0.0
            
            for j in 0...(upperLimitInteger - 1){
                for i in 0...(upperLimitInteger - 1) {
                    magnetization = magnetization + mySpins.spinConfiguration[i][j]
                }
            }
            magnetizationForPlot.append(magnetization)
            
            return magnetization
        }
        //Equation 15.17:
        //                             _
        //       1                    |     2
        // U  = --- SUM(from t=1 to M)| (E )
        //  2    M                    |_  t
        //
        func calculateU2 () -> Double {
            var U2: Double = 0.0
            var U2Sum: Double = 0.0
            var energyValueForSum: Double = 0.0
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            
            //        for i in 1...(upperLimitInteger - 1) {
            //            energyValueForSum = myEnergy.energy1D[i]
            //            U2Sum = pow(energyValueForSum, 2.0)
            //        }
            U2 = U2Sum/N
            
            return U2
        }
        //Equation 15.18:
        //      1    U2 - (U)^2
        // C = ---- ------------
        //    (N)^2    kT^2
        
        func calculateSpecificHeat () -> Double {
            let N = Double(N)!
            let kT = Double(kT)!
            var specificHeatValue: Double = 0.0
            var U2 = calculateU2()
            var U = calculateInternalEnergy2D()
            
            specificHeatValue = (U2 - pow(U, 2.0))/(pow(N, 2.0)*pow(kT, 2.0))
            specificHeat.append(specificHeatValue)
            
            return specificHeatValue
        }
        
        // 15.4.1 Metropolis Algorithm Implementation
        func calculateColdMetropolisAlgorithm2D () async {
            print("Beginning of Metropolis Algorithm with Cold Initial Spin Configuration:")
            let J: Int = 1
            let N = Double(N)!
            let upperLimit = pow(N, 2.0)
            let upperLimitInteger = Int(upperLimit)
            var currentSpinValue = true
            
            ktForX.append(0.0)
            
            //  for y in 0...(upperLimitInteger - 1) {
            // might need to be for x in 1...(upperLimitInteger) not sure
            for x in 1...(1000000) {
                var trialConfiguration = calculateTrialConfiguration2D()
                calculateEnergyOfTrialConfiguration2D(x: x, J: J, trialConfiguration: trialConfiguration)
                calculateEnergyOfPreviousConfiguration2D(x: x, J: J)
                calculateEnergyCheck(x: x, trialConfiguration: trialConfiguration)
                //trialEnergy = 0.0
                //energy = 0.0
                await withTaskGroup(of: Void.self) { group in
                    for j in 0..<spinWidth {
                        for i in 0..<spinWidth {
                            if (mySpins.spinConfiguration[i][j] == 1.0) {
                                currentSpinValue = true
                            }
                            else {
                                currentSpinValue = false
                            }
                            
                            
                            twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
                        }
                    }
                }
                calculateInternalEnergy2D()
                calculateMagnetization2D()
                calculateSpecificHeat()
                let X = Double(x)
                ktForX.append(X)
                
                for i in 0...(myEnergy.energy1D.count - 1) {
                    let kT = Double(kT)!
                    
                    thermalProperties.append(ThermalProperties(kT: ktForX[i], specificHeat: specificHeat[i], magnetization: magnetizationForPlot[i], energy: myEnergy.energy1D[i]))
                }
            }
            
            //twoDMagnet.spinConfiguration = mySpins.spinConfiguration
            //0    timeValue = Double(y-1) + 1.0
            //  count.append(timeValue)
            //  mySpins.timeComponent.append(count)
            //   mySpins.spinConfiguration.append(mySpins.spinConfiguration[y])
            // }
            var internalEnergy = calculateInternalEnergy2D()
            var magnetization = calculateMagnetization2D()
            var specificHeat = calculateSpecificHeat()
            print("Number of Updates")
            print(mySpins.spinConfiguration.count)
            print("Spin Configuration:")
            print(mySpins.spinConfiguration)
            // print(mySpins.timeComponent)
            print("Energy of Each Update:")
            print(myEnergy.energy1D)
            print("Internal Energy:")
            print(internalEnergy)
            print("Magnetization:")
            print(magnetization)
            print("Specific Heat:")
            print(specificHeat)
        }
        
        
        func calculateArbitraryMetropolisAlgorithm2D () async {
            print("Beginning of Metropolis Algorithm with Arbitrary Initial Spin Configuration:")
            let J: Int = 1
            let N = Double(N)!
            let upperLimit = pow(N, 2.0)
            let upperLimitInteger = Int(upperLimit)
            var currentSpinValue = true
            //            var count: [Double] = []
            //        var timeValue = 0.0
            
            //   for y in 0...(upperLimitInteger - 1) {
            for x in 1...(1000000) {
                var trialConfiguration = calculateTrialConfiguration2D()
                calculateEnergyOfTrialConfiguration2D(x: x, J: J, trialConfiguration: trialConfiguration)
                calculateEnergyOfPreviousConfiguration2D(x: x, J: J)
                calculateEnergyCheck(x: x, trialConfiguration: trialConfiguration)
                //trialEnergy = 0.0
                //energy = 0.0
                await withTaskGroup(of: Void.self) { group in
                    for j in 0..<spinWidth {
                        for i in 0..<spinWidth {
                            if (mySpins.spinConfiguration[i][j] == 1.0) {
                                currentSpinValue = true
                            }
                            else {
                                currentSpinValue = false
                            }
                            twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
                        }
                    }
                }
                calculateInternalEnergy2D()
                calculateMagnetization2D()
                calculateSpecificHeat()
                let X = Double(x)
                ktForX.append(X)
                
                for i in 0...(myEnergy.energy1D.count - 1) {
                    let kT = Double(kT)!
                    
                    thermalProperties.append(ThermalProperties(kT: ktForX[i], specificHeat: specificHeat[i], magnetization: magnetizationForPlot[i], energy: myEnergy.energy1D[i]))
                }
                
            }
            //  timeValue = Double(y-1) + 1.0
            //  count.append(timeValue)
            //  mySpins.timeComponent.append(count)
            //   mySpins.spinConfiguration.append(mySpins.spinConfiguration[y])
            //  }
            var internalEnergy = calculateInternalEnergy2D()
            var magnetization = calculateMagnetization2D()
            var specificHeat = calculateSpecificHeat()
            print("Number of Updates")
            print(mySpins.spinConfiguration.count)
            print("Spin Configuration:")
            print(mySpins.spinConfiguration)
            // print(mySpins.timeComponent)
            print("Energy of Each Update:")
            print(myEnergy.energy1D)
            print("Internal Energy:")
            print(internalEnergy)
            print("Magnetization:")
            print(magnetization)
            print("Specific Heat:")
            print(specificHeat)
        }
    }

    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
