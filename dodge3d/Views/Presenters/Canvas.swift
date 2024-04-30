import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    @State var progress = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let shootingEngine       = ShootingEngine(ammoCapacity: 6, reloadTimeInSeconds: 4)
    let homingEngineLe       = HomingEngine()
    let homingEngineMi       = HomingEngine()
    let homingEngineRi       = HomingEngine()
    let legacyHomingEngine   = LegacyHomingEngine()
    let legacyHomingEngineLe = LegacyHomingEngine(0.2)
    let legacyHomingEngineRi = LegacyHomingEngine(-0.2)
    let targetEngine         = TargetEngine()
    var engines: [Engine]    = [ ]
    
    @State var navigateToEndScreen = false
    @State var buttonColor: Color = .blue
    
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
     }
    
    var body: some View {
        NavigationView {
            ZStack (alignment: .center) {
                VStack {
                    HStack {
                        Image("turret")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(": \(homingEngineMi.turret.health) / \(homingEngineMi.turret.maxHealth)")
                    }
                    .background(Color.clear)
                    
                    ContentManagement (
                        manages: self.engines
                    )
                
                    VStack {
                        if ( homingEngineMi.turret.health <= 0 ) {
                            UIButton (
                                color: .green,
                                flex: true
                            ) {
                                Image(systemName: "flag.checkered.2.crossed")
                            } action: {
                                self.navigateToEndScreen = true
                            }
                        } else if (shootingEngine.health <= 0){
                            UIButton (
                                color: .red,
                                flex: true
                            ) {
                                Text("👎😝")
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
                            
                            HStack {
                                Image("bullet")
                                    .resizable()
                                    .frame(width: 30, height: 15)
                                Text(": \( (shootingEngine.ammoCapacity) - shootingEngine.usedAmmo)/\(shootingEngine.ammoCapacity)")
                            }
                            
                            
                            UIButton (
                                color: buttonColor,
                                flex: true
                            ) {
                                if ( shootingEngine.isReloading ) {
                                    ProgressView().tint(.white)
                                    Image("bullet")
                                        .resizable()
                                        .frame(width: 30, height: 15)
                                    Text("++")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color.white)
                                } else {
                                    Image(systemName: "arrow.circlepath")
                                }
                                
                            } action: {
                                self.buttonColor = shootingEngine.isReloading ? .red : .blue
                                guard ( !shootingEngine.isReloading ) else { return }
                                shootingEngine.reload()
                            }
                            
                            UIButton (
                                flex: true
                            ) {
                                Image(systemName: "play.fill")
                            } action: {
                                homingEngineMi.setSpawnPosition()
                            }
                        }
                        
                    }
                    .padding()
                    .frame(height: 200)
                    .background(Color.clear)
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .background(
                    NavigationLink(destination: EndScreen(), isActive: $navigateToEndScreen) {
                        EmptyView()
                    }
                )
                Text("+\n\n\n\n\n").font(.system(size: 24))
                    .foregroundStyle(Color.white)
            }
        }
    }
}

#Preview {
    Canvas()
}
