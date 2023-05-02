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
    @State var N: String = "4"
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
    
    @State var spinWidth = 25
    
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
//                Button(action: {
//                    self.calculateColdMetropolisAlgorithm2D()})
//                {Text("Calculate Cold Metropolis Algorithm")}
                Button(action: {
                    self.calculateArbitraryMetropolisAlgorithm2D()})
                {Text("Calculate Cold Metropolis Algorithm")}
            }
            VStack(){
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
                
                Button("Start from Cold", action: setupSpins)
                
                Button("SpinMe", action: changeSpins)
                
                
               // Button("Start from Cold", action: setupColdSpins)
                Button("Start from Arbitrary", action: setupArbitrarySpins)
            }
        }
    }
    func setupSpins(){
        let N = Double(N)!
        spinWidth = Int(sqrt(N))
        var currentSpinValue = true
        self.calculateColdSpinConfiguration2D()
        
        for j in 0..<spinWidth {
            for i in 0..<spinWidth {
                if (mySpins.spinConfiguration[i][j] == 0.5) {
                                    currentSpinValue = true
                                }
                                else {
                                    currentSpinValue = false
                                }

                twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
            }
        }
        
        //twoDMagnet.setup(number: Int(spinWidth))
        
    }
    
    func spinChangeMethod(thing: inout [Spin]) {
        for i in 0..<twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.count {
            
            thing[i].spin = Bool.random()
        }
    }
    
    func changeSpins(){
        
        Task{
            
           // for _ in 0...10000{
//                await withTaskGroup(of: Void.self) { group in

            await self.calculateColdMetropolisAlgorithm2D()
//                    //spinChangeMethod(thing: &thing)
//
//                   // self.twoDMagnet.plotSpinConfiguration.plotSpinConfiguration = thing
//
//
 //               }
                
                
          //  }
            
        }
    }

    
    func setupColdSpins() -> [[Double]]{
        let N = Double(N)!
        self.clearParameters ()
        self.calculateColdSpinConfiguration2D()
        return mySpins.spinConfiguration
//        twoDMagnet.spinConfiguration = mySpins.spinConfiguration
//        twoDMagnet.setup(N: Int(N), isThereAnythingInMyVariable: false)
    }
    func setupArbitrarySpins(){
        let N = Double(N)!
        self.clearParameters ()
        self.calculateArbitraryMetropolisAlgorithm2D()
//        twoDMagnet.spinConfiguration = mySpins.spinConfiguration
//        twoDMagnet.setup(N: Int(N), isThereAnythingInMyVariable: false)
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
            var currentSpinValue = true

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
            print("Internal Energy:"); print(internalEnergy)
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
        
        for i in 1...(upperLimitInteger - 1) {
            energyValueForSum = myEnergy.energy1D[i]
            U2Sum = pow(energyValueForSum, 2.0)
        }
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
        var specificHeat: Double = 0.0
        var U2 = calculateU2()
        var U = calculateInternalEnergy2D()
            
        specificHeat = (U2 - pow(U, 2.0))/(pow(N, 2.0)*pow(kT, 2.0))
        
        return specificHeat
    }
    
        // 15.4.1 Metropolis Algorithm Implementation
    func calculateColdMetropolisAlgorithm2D () async {
            print("Beginning of Metropolis Algorithm with Cold Initial Spin Configuration:")
            let J: Int = 1
            let N = Double(N)!
            let upperLimit = sqrt(N)
            let upperLimitInteger = Int(upperLimit)
            var count: [Double] = []
            var timeValue = 0.0
            var currentSpinValue = true
          //  for y in 0...(upperLimitInteger - 1) {
          // might need to be for x in 1...(upperLimitInteger) not sure
                for x in 1...(10) {
                    var trialConfiguration = calculateTrialConfiguration2D()
                    calculateEnergyOfTrialConfiguration2D(x: x, J: J, trialConfiguration: trialConfiguration)
                    calculateEnergyOfPreviousConfiguration2D(x: x, J: J)
                    calculateEnergyCheck(x: x, trialConfiguration: trialConfiguration)
                    //trialEnergy = 0.0
                    //energy = 0.0
                    await withTaskGroup(of: Void.self) { group in
                        for j in 0..<spinWidth {
                            for i in 0..<spinWidth {
                                if (mySpins.spinConfiguration[i][j] == 0.5) {
                                    currentSpinValue = true
                                }
                                else {
                                    currentSpinValue = false
                                }
                                
                                
                                twoDMagnet.plotSpinConfiguration.plotSpinConfiguration.append(Spin(x: Double(i), y: Double(j), spin: currentSpinValue))
                            }
                        }
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
    func calculateArbitraryMetropolisAlgorithm2D () {
            print("Beginning of Metropolis Algorithm with Arbitrary Initial Spin Configuration:")
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
