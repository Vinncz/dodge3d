import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    @State var progress = 0.0
    @State var ammoCapacity: Int = 12
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let shootingEngine       = ShootingEngine(ammoCapacity: ammoCapacity, reloadTimeInSeconds: 3)
    let homingEngine         = HomingEngine()
    let legacyHomingEngine   = LegacyHomingEngine()
    let legacyHomingEngineLe = LegacyHomingEngine(0.2)
    let legacyHomingEngineRi = LegacyHomingEngine(-0.2)
    let targetEngine         = TargetEngine()
    var engines: [Engine]    = [ ]
    
    func checkForShootingEngineGotCollidedWithProjectile () {
        if ( shootingEngine.handleCollisionWithCamera(objectResponsible: <#T##MovingObject#>) )
    }
    
    init () {
        self.engines = [
            shootingEngine,
            homingEngine,
            targetEngine
//            ,legacyHomingEngine
        ]
        self.shootingEngine.targetEngineInstance = targetEngine
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {_ in
            checkForShootingEngineGotCollidedWithProjectile()
        }
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
