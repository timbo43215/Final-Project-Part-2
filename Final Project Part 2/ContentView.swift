//
//  ContentView.swift
//  Final Project
//
//  Created by Tim Stack on 4/7/23.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @State var upOrDown = [0.5, -0.5]
    @State var spinArray: [Double] = []
    @State var nextSpinArray: [Double] = []
    @State var timeArray: [Double] = []
    @State var N: String = "100.0"
    @State var J: String = "1.0"
    @State var g: String = "1.0"
    @State var B: String = "0.0"
    @State var kT: String = "100.0"
    @State var potentialArray: [Double] = []
    @State var trialEnergy: Double = 0.0
    @State var energy: Double = 0.0
    @StateObject var mySpins = Spins()
    @StateObject var myEnergy = Energy()
    @StateObject var myPotential = Potential()
    @StateObject var twoDMagnet = TwoDMagnet()
    let upColor = Color(red: 0.25, green: 0.5, blue: 0.75)
    let downColor = Color(red: 0.75, green: 0.5, blue: 0.25)
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("N:")
                    TextField("N:", text: $N)
                }
                HStack {
                    Text("kT:")
                    TextField("kT:", text: $kT)
                }
                Button(action: {
                    self.calculateColdSpinConfiguration2D()})
                {Text("Calculate Cold Spin Configuration")}
                Button(action: {
                    self.calculateArbitrarySpinConfiguration2D()})
                {Text("Calculate Arbitrary Spin Configuration")}
                Button(action: {
                    self.calculateTrialConfiguration2D()})
                {Text("Calculate Trial Configuration")}
                Button(action: {
                    self.calculateColdMetropolisAlgorithm2D()})
                {Text("Calculate Cold Metropolis Algorithm")}
                Button(action: {
                    self.calculateArbitraryMetropolisAlgorithm2D()})
                {Text("Calculate Cold Metropolis Algorithm")}
            }
            VStack(){
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        twoDMagnet.update(to: timeline.date, N: Int(Double(N)!), isThereAnythingInMyVariable: false)
                        
                        for spin in twoDMagnet.spins {
                            let N = Double(N)!
                            let upperLimit = sqrt(N)
                            let upperLimitInteger = Int(upperLimit)
                            let rect = CGRect(x: spin.x * (size.width/CGFloat(mySpins.spinConfiguration.count)), y: spin.y * (size.height/CGFloat(upperLimitInteger)), width: (size.height/CGFloat(mySpins.spinConfiguration.count - 1)), height: (size.height/CGFloat(upperLimitInteger)))
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
                
                
                Button("Start from Cold", action: setupColdSpins)
                Button("Start from Arbitrary", action: setupArbitrarySpins)
            }
        }
    }
    
    func setupColdSpins(){
        let N = Double(N)!
        self.clearParameters ()
        self.calculateColdMetropolisAlgorithm2D()
        twoDMagnet.spinConfiguration = mySpins.spinConfiguration
        twoDMagnet.setup(N: Int(N), isThereAnythingInMyVariable: false)
    }
    func setupArbitrarySpins(){
        let N = Double(N)!
        self.clearParameters ()
        self.calculateArbitraryMetropolisAlgorithm2D()
        twoDMagnet.spinConfiguration = mySpins.spinConfiguration
        twoDMagnet.setup(N: Int(N), isThereAnythingInMyVariable: false)
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
                spinValue.append(0.5)
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
        //print(mySpins.spinConfiguration)
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
        
        if (x > 0) {
            for j in 1...upperLimitInteger {
                for i in 1...(upperLimitInteger - 1) {
                    let trialEnergyValue = -J*(trialConfiguration[j-1][i-1]*trialConfiguration[j-1][i]) - (B*bohrMagneton*trialConfiguration[j-1][i])
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
            for j in 1...(upperLimitInteger - 1) {
                for i in 1...(upperLimitInteger - 1) {
                    let energyValue = -J*(mySpins.spinConfiguration[j-1][i-1]*mySpins.spinConfiguration[j-1][i]) - (B*bohrMagneton*mySpins.spinConfiguration[j-1][i])
                    energy = energy + energyValue
                }
            }
        }
       // print(energy)
    }
    func calculateEnergyCheck (x: Int, trialConfiguration: [[Double]]) {
            let uniformRandomNumber = Double.random(in: 0...1)
            if (x > 0) {
                if (trialEnergy <= energy) {
                    mySpins.spinConfiguration = trialConfiguration
                    myEnergy.energy1D.append(trialEnergy)
                    print("Trial Accepted")
                    print(mySpins.spinConfiguration)
                }
                else {
                    if (calculateRelativeProbability() >= uniformRandomNumber){
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
        /// U
        func calculateInternalEnergy1D () {
            
        }
        // 15.4.1 Metropolis Algorithm Implementation
    func calculateColdMetropolisAlgorithm2D () {
            let J: Int = 1
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            var count: [Double] = []
            var timeValue = 0.0
            calculateColdSpinConfiguration2D ()
          //  for y in 0...(upperLimitInteger - 1) {
                for x in 1...(upperLimitInteger) {
                    var trialConfiguration = calculateTrialConfiguration2D()
                    calculateEnergyOfTrialConfiguration2D(x: x, J: J, trialConfiguration: trialConfiguration)
                    calculateEnergyOfPreviousConfiguration2D(x: x, J: J)
                    calculateEnergyCheck(x: x, trialConfiguration: trialConfiguration)
                    //trialEnergy = 0.0
                    //energy = 0.0
                }
            //0    timeValue = Double(y-1) + 1.0
              //  count.append(timeValue)
              //  mySpins.timeComponent.append(count)
             //   mySpins.spinConfiguration.append(mySpins.spinConfiguration[y])
           // }
            print(mySpins.spinConfiguration.count)
            print(mySpins.spinConfiguration)
            //print(mySpins.timeComponent)
            print(myEnergy.energy1D)
        
        }
    func calculateArbitraryMetropolisAlgorithm2D () {
            let J: Int = 1
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
//            var count: [Double] = []
    //        var timeValue = 0.0
            calculateArbitrarySpinConfiguration2D ()
            
         //   for y in 0...(upperLimitInteger - 1) {
                for x in 1...(upperLimitInteger) {
                    var trialConfiguration = calculateTrialConfiguration2D()
                    calculateEnergyOfTrialConfiguration2D(x: x, J: J, trialConfiguration: trialConfiguration)
                    calculateEnergyOfPreviousConfiguration2D(x: x, J: J)
                    calculateEnergyCheck(x: x, trialConfiguration: trialConfiguration)
                    //trialEnergy = 0.0
                    //energy = 0.0
                }
              //  timeValue = Double(y-1) + 1.0
              //  count.append(timeValue)
              //  mySpins.timeComponent.append(count)
             //   mySpins.spinConfiguration.append(mySpins.spinConfiguration[y])
          //  }
            print(mySpins.spinConfiguration.count)
            print(mySpins.spinConfiguration)
           // print(mySpins.timeComponent)
            print(myEnergy.energy1D)
        }
}

    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
