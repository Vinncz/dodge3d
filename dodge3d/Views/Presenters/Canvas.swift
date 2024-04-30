import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    @State var progress = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let shootingEngine       = ShootingEngine(ammoCapacity: 12, reloadTimeInSeconds: 4)
    let homingEngineLe       = HomingEngine()
    let homingEngineMi       = HomingEngine()
    let homingEngineRi       = HomingEngine()
    let legacyHomingEngine   = LegacyHomingEngine()
    let legacyHomingEngineLe = LegacyHomingEngine(0.2)
    let legacyHomingEngineRi = LegacyHomingEngine(-0.2)
    let targetEngine         = TargetEngine()
    var engines: [Engine]    = [ ]
    
    @State var navigateToEndScreen = false
    
    init () {
        self.engines = [
            shootingEngine
//            ,homingEngineLe
            ,homingEngineMi
//            ,homingEngineRi
            ,targetEngine
//            ,legacyHomingEngine
        ]
        self.shootingEngine.targetEngineInstance = targetEngine
        self.shootingEngine.homingEngineInstance = homingEngineMi
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {_ in
//            checkForShootingEngineGotCollidedWithProjectile()
//        }
     }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("Turret health: \(homingEngineMi.turret.health) / \(homingEngineMi.turret.maxHealth)")
                }
                ContentManagement (
                    manages: self.engines
                )
                VStack {
                    if ( homingEngineMi.turret.health <= 0 ) {
                        UIButton (
                            color: .red,
                            flex: true
                        ) {
                            Text("Complete Level")
                        } action: {
                            self.navigateToEndScreen = true
                        }
                        
                    } else {
                        HStack{
                            ForEach(0..<10, id: \.self) { index in
                                Image(systemName: index < shootingEngine.health ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 7))
                            }
                        }
                        
                        Text("Ammo: \( (shootingEngine.ammoCapacity) - shootingEngine.usedAmmo)/\(shootingEngine.ammoCapacity)")
                        
                        UIButton (
                            flex: true
                        ) {
                            if ( shootingEngine.isReloading ) {
                                ProgressView().tint(.white)
                                Text("Reloading")
                            } else {
                                Image(systemName: "arrow.circlepath")
                                Text("Reload")
                            }
                            
                        } action: {
                            guard ( !shootingEngine.isReloading ) else { return } 
                            shootingEngine.reload()
                        }
                        
                        UIButton (
                            flex: true
                        ) {
                            Text("Change spawn position")
                        } action: {
                            homingEngineMi.setSpawnPosition()
                        }
                    }
                    
                }.padding()
                    .frame(height: 256)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: EndScreen(), isActive: $navigateToEndScreen) {
                    EmptyView()
                }
            )
        }
    }
}

#Preview {
    Canvas()
}
