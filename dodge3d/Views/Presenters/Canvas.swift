import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    @State var progress = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let shootingEngine       = ShootingEngine(ammoCapacity: 12, reloadTimeInSeconds: 4)
    let homingEngineLe       = HomingEngine().setSpawnPosition(newPosition: [-2, 0, -5])
    let homingEngineMi       = HomingEngine().setSpawnPosition(newPosition: [0, 0, -5])
    let homingEngineRi       = HomingEngine().setSpawnPosition(newPosition: [2, 0, -5])
    let legacyHomingEngine   = LegacyHomingEngine()
    let legacyHomingEngineLe = LegacyHomingEngine(0.2)
    let legacyHomingEngineRi = LegacyHomingEngine(-0.2)
    let targetEngine         = TargetEngine()
    var engines: [Engine]    = [ ]
    
    init () {
        self.engines = [
            shootingEngine
//            ,homingEngineLe
            ,homingEngineMi
//            ,homingEngineRi
            ,targetEngine
//            ,legacyHomingEngine
        ]
    }
    
    var body: some View {
        ZStack {
            VStack {
                ContentManagement (
                    manages: self.engines
                )
                VStack {
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
                    
                }.padding()
                    .frame(height: 100)
            }
        }
    }
}

#Preview {
    Canvas()
}
