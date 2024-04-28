import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    @State var progress = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let shootingEngine    = ShootingEngine(ammoCapacity: 12, reloadTimeInSeconds: 4)
    let homingEngine      = LegacyHomingEngine()
    let homingEngineLe    = LegacyHomingEngine(0.2)
    let homingEngineRi    = LegacyHomingEngine(-0.2)
    let targetEngine      = TargetEngine()
    var engines: [Engine] = [ ]
    
    init () {
        self.engines = [
            shootingEngine
            ,homingEngine
        ]
    }
    
    var body: some View {
        ZStack {
            VStack {
                ContentManagement (
                    manages: self.engines
                )
                VStack {
                    if ( shootingEngine.isReloading ) {
                        Text("Reloading")
                        
                        ProgressView(value: progress, total: 1)
                            .progressViewStyle(.circular)
                            .onReceive(timer, perform: { _ in
                                if self.progress < 1.0 {
                                    self.progress += 0.025
                                }
                            })
                    } else {
                        Text("Ammo: \( (shootingEngine.ammoCapacity) - shootingEngine.usedAmmo)/\(shootingEngine.ammoCapacity)")
                        
                        Button {
                            shootingEngine.reload()
                        } label: {
                            Text("Reload")
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
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
