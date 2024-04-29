import SwiftUI
import ARKit
import RealityKit
import Combine

struct ContentManagement: UIViewRepresentable {
    var manages: [Engine]
    
    /* Inherited from protocol UIViewRepresentable. Refrain from renaming the following */
    func makeUIView ( context: Context ) -> some UIView {
        let arView = ARView()
        arView.session.delegate = context.coordinator
        
        exertConfigs(arView, ARWorldTrackingConfiguration())
        
        attachTapGestureRecognizer(context, arView)
        attachHoldGestureRecognizer(context, arView)
        
        setupEngines(arView)
        
        context.coordinator.setupCollisions()
        
        return arView
    }
    
    func setupEngines ( _ view: ARView ) {
        manages.forEach { engine in
            engine.setup(manager: view)
            
            if ( engine is HomingEngine ) {
                Timer.scheduledTimer(withTimeInterval: GameConfigs.summonDelay, repeats: true) {_ in 
                    engine.spawnObject()
                }
            }
        }
    }
    
    /* Inherited from protocol UIViewRepresentable. Refrain from renaming the following */
    func updateUIView ( _ uiView: UIViewType, context: Context ) {}
    
    /* Inherited from protocol UIViewRepresentable. Refrain from renaming the following */
    func makeCoordinator () -> Coordinator {
        return Coordinator (
            _managedEngine: manages
        )
    }
    
    /* Inherited from protocol UIViewRepresentable. Refrain from renaming the following */
    class Coordinator: NSObject, ARSessionDelegate {
        var managedEngine: [Engine]
        var holdTimer: Timer?
        
        //array for collisions
        var collisionSubscriptions = [Cancellable]()
        
        init ( _managedEngine: [Engine] ) {
            self.managedEngine = _managedEngine
        }
        
        //function to set up Collisions -> to add every single arView to collisionSubcriptions array
        func setupCollisions(){
            self.managedEngine.forEach({engine in
                collisionSubscriptions.append((engine.manager?.scene.subscribe(to: CollisionEvents.Began.self){ event in
                    //begin event
                    print("BEGIN")
                })!)
                collisionSubscriptions.append((engine.manager?.scene.subscribe(to: CollisionEvents.Ended.self){ event in
                    //end event
                    print("ENDED")
                })!)
            })
        }
        
        /* Inherited from protocol ARSessionDelegate. Refrain from renaming the following */
        func session ( _ session: ARSession, didUpdate frame: ARFrame ) {
            self.managedEngine.forEach({ engine in
                switch engine {
                    case is ShootingEngine:
//                        let e = engine as! ShootingEngine
//                        what to do when engine is an instance of ShootingEngine
                        break
                        
                    case is HomingEngine:
//                        let e = engine as! HomingEngine
//                        what to do when engine is an instace of HomingEngine
                        break
                        
                    case is LegacyHomingEngine:
//                        let e = engine as! LegacyHomingEngine
//                        what to do when engine is an instace of HomingEngine
                        break
                        
                    case is TargetEngine:
//                        let e = engine as! TargetEngine
//                        what to do when engine is an instance of TargetEngine
                        break
                        
                    default:
                        break
                }
                
                engine.updateObjectPosition(frame: frame)
            })
        }
        
        @objc func handleTap ( _ gesture: UITapGestureRecognizer ) {
            self.managedEngine.forEach({ engine in
                switch engine {
                    case is ShootingEngine:
//                        let e = engine as! ShootingEngine
//                        what to do when engine is an instance of ShootingEngine
                        break
                        
                    case is HomingEngine:
//                        let e = engine as! HomingEngine
//                        what to do when engine is an instace of HomingEngine
                        break
                        
                    case is LegacyHomingEngine:
//                        let e = engine as! LegacyHomingEngine
//                        what to do when engine is an instace of HomingEngine
                        break
                        
                    case is TargetEngine:
//                        let e = engine as! TargetEngine
//                        what to do when engine is an instance of TargetEngine
                        break
                        
                    default:
                        break
                }
                
                engine.spawnObject()
            })
        }
        
        @objc func handleHold ( _ gesture: UILongPressGestureRecognizer ) {
            if ( gesture.state == .began ) {
                holdTimer = Timer.scheduledTimer(withTimeInterval: GameConfigs.summonDelay, repeats: true) { [self] _ in
                    self.managedEngine.forEach({ engine in
                        switch engine {
                            case is ShootingEngine:
//                                let e = engine as! ShootingEngine
//                                what to do when engine is an instance of ShootingEngine
                                break
                                
                            case is HomingEngine:
//                                let e = engine as! HomingEngine
//                                what to do when engine is an instace of HomingEngine
                                break
                                
                            case is LegacyHomingEngine:
//                                let e = engine as! LegacyHomingEngine
//                                what to do when engine is an instace of HomingEngine
                                break
                                
                            case is TargetEngine:
//                                let e = engine as! TargetEngine
//                                what to do when engine is an instance of TargetEngine
                                break
                                
                            default:
                                break
                        }
                        
                        engine.spawnObject()
                    })
                }
                
            } else if ( gesture.state == .ended || gesture.state == .cancelled ) {
                holdTimer?.invalidate()
                holdTimer = nil
                
            }
        }
    }
    
    func exertConfigs ( _ arView: ARView, _ configs: ARConfiguration ) {
        arView.session.run(configs)
    }
    func attachHoldGestureRecognizer ( _ context: ContentManagement.Context, _ arView: ARView ) {
        let holdGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleHold(_:))
        )
        arView.addGestureRecognizer(holdGesture)
    }
    func attachTapGestureRecognizer  ( _ context: ContentManagement.Context, _ arView: ARView ) {
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)
    }
}
