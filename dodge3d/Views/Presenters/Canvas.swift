import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    @State var progress = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let shootingEngine       = ShootingEngine(ammoCapacity: 12, reloadTimeInSeconds: 3)
    let homingEngine         = HomingEngine()
    let legacyHomingEngine   = LegacyHomingEngine()
    let legacyHomingEngineLe = LegacyHomingEngine(0.2)
    let legacyHomingEngineRi = LegacyHomingEngine(-0.2)
    let targetEngine         = TargetEngine()
    var engines: [Engine]    = [ ]
    
    @State var health = 10
    @State var navigateToEndScreen = false
//    func checkForShootingEngineGotCollidedWithProjectile () {
//        if ( shootingEngine.handleCollisionWithCamera(objectResponsible: <#T##MovingObject#>) )
//    }
    
    init () {
        self.engines = [
            shootingEngine,
            homingEngine,
            targetEngine
//            ,legacyHomingEngine
        ]
        self.shootingEngine.targetEngineInstance = targetEngine
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {_ in
//            checkForShootingEngineGotCollidedWithProjectile()
//        }
     }
    
//    func updateHealth () {
//        shootingEngine.detectCollisionWithCamera(objectInQuestion: <#T##Engine.MovingObject#>, distance: <#T##Float#>)
//    }
    
    var body: some View {
        NavigationView {
            VStack {
                ContentManagement (
                    manages: self.engines
                )
                VStack {
                    // Health bar
                    HStack{
                        ForEach(0..<health, id: \.self) { _ in
                                Image(systemName: "heart.fill")
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
                    
                }.padding()
                    .frame(height: 130)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: EndScreen(), isActive: $navigateToEndScreen) {
                    EmptyView()
                }
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.navigateToEndScreen = true
                }
            }
        }
    }
}

#Preview {
    Canvas()
}
