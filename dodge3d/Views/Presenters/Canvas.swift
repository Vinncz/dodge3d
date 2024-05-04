import SwiftUI
import ARKit
import RealityKit

@Observable class CanvasRepresentator : Colleague {
    struct MessageFormat {
        var contentName: String
        var messageContent: Any
    }
    
    var signature: String
    var mediator: Mediator?
    
    var playerHealth: Int = 10
    var shootingEngineIsReloading: Bool = false
    
    func receiveMessage (_ message: Any, sendersSignature from: String?) {
        switch ( from ) {
            case DefaultString.signatureOfShootingEngineForMediator:
                let msg = message as! ShootingEngine.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.shootingEngineSpawnNewProjectile:
//                        self.turretPosition = msg.messageContent as! SIMD3<Float>
                        break
                        
                    case DefaultString.shootingEnginHasGoneReloading:
                        self.shootingEngineIsReloading = true
                        break
                        
                    case DefaultString.shootingEnginHasFinishedReloading:
                        self.shootingEngineIsReloading = false
                        break
                        
                    default:
                        print("A message was not captured by \(self.signature)")
                        break
                }
                
                break
            case DefaultString.signatureOfHomingEngineForMediator:
                break
            case DefaultString.signatureOfPlayerForMediator:
                let msg = message as! Player.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.playerUpdatedHealth:
                        self.playerHealth = (msg.messageContent as! Int)
                        break
                        
                    default:
                        break
                }
                
                break
            case DefaultString.signatureOfBuffEngineForMediator:
                let msg = message as! BuffEngine.MessageFormat
                
                switch ( msg.contentName ) {
                    case DefaultString.buffEngineGrantsNewBuff:
                        let buffObj = msg.messageContent as! BuffEngine.BuffObject
                        
                        switch ( buffObj.buff ) {
                            case .healthRecovery:
                                /* tell the Player that they've recieved an extra hp from a buff */
                                sendMessage(
                                    to: DefaultString.signatureOfPlayerForMediator, 
                                    MessageFormat (
                                        contentName: DefaultString.playerHealthRegenerate,
                                        messageContent: Int(buffObj.amount * buffObj.multiplier)
                                    ),
                                    sendersSignature: self.signature
                                )
                                break
                                
                            default:
                                break
                        }
                        
                        break
                        
                    default:
                        break
                }
                break
            default:
                print("A message was not captured by \(self.signature)")
        }
    }
    
    init ( _ mediator: Mediator ) {
        self.signature = DefaultString.signatureOfCanvasForMediator
        self.mediator = mediator
    }
}

struct Canvas: View {
    @State var progress = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State var shootingEngine : ShootingEngine
    @State var homingEngineMi : HomingEngine
    @State var targetEngine   : BuffEngine
    var engines: [Engine]    = [ ]
    
    let mediator: Mediator
    @State var canvasRepresentator: CanvasRepresentator
    @State var player: Player
    
    @State var navigateToEndScreen = false
    @State var buttonColor: Color = .blue
    
    init () {
        self.shootingEngine = ShootingEngine()
        self.homingEngineMi = HomingEngine()
        self.targetEngine   = BuffEngine()
        
        self.mediator = Mediator()
        self.canvasRepresentator = CanvasRepresentator(self.mediator)
        self.player = Player()
        
        self.shootingEngine.mediator  = self.mediator
        self.homingEngineMi.mediator  = self.mediator
        self.targetEngine.mediator    = self.mediator
        self.player.mediator          = self.mediator
        
        self.mediator.add([canvasRepresentator, homingEngineMi, shootingEngine, player, targetEngine])
        
        initializeEngine()
    }
    
    mutating func initializeEngine () {
        self.engines = [
            shootingEngine,
            homingEngineMi,
            targetEngine
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                        if ( player.health <= 0 ) {
                            UIButton (
                                color: .red,
                                flex: true
                            ) {
                                Text("👎😝")
                            } action: {
                                self.navigateToEndScreen = true
                            }
                            
                        } else if ( homingEngineMi.turret.health <= 0 ){
                            UIButton (
                                color: .green,
                                flex: true
                            ) {
                                Image(systemName: "flag.checkered.2.crossed")
                            } action: {
                                self.navigateToEndScreen = true
                            }
                            
                        } else {
//                            BuffMessageView(message: shootingEngine.buffMessage, shootingEngineInstance: shootingEngine)
                            HStack{
                                ForEach(0..<10, id: \.self) { index in
                                    Image(systemName: index < canvasRepresentator.playerHealth ? "heart.fill" : "heart")
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
                                if ( canvasRepresentator.shootingEngineIsReloading ) {
                                    ProgressView().tint(.white)
                                    Text("Reloading")
                                } else {
                                    Image(systemName: "arrow.circlepath")
                                }
                                
                            } action: {
                                buttonColor = .red
                                shootingEngine.reload()
                                
                                DispatchQueue.main.asyncAfter( deadline: .now() + shootingEngine.reloadTime ) {
                                    buttonColor = .blue
                                }
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
                    Text("+\n\n\n\n\n")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.white)
            }
        }.onAppear() {
            self.mediator.listColleagues()
            
            self.mediator.broadcastMessage(message: "JAWAB WOI")
        }
    }
    
}

struct BuffMessageView: View {
    var message: String
    var shootingEngineInstance: ShootingEngine
    
    var body: some View {
        ZStack {
            Text(message)
                .font(.title3)
                .foregroundColor(.black)
                .padding()
//                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .transition(.scale)
                .padding()
        }
        .onAppear {
//            shootingEngineInstance.toggleIsBuffMessageShowing()
        }
    }
}

#Preview {
    Canvas()
}
