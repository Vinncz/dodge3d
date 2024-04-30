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
        
        return arView
    }
    
    func setupEngines ( _ view: ARView ) {
        var spawnCountForHomingEngine: Int = 0
        var timer: Timer?
        
        func beginHomingEngineAutoShootAndReloadLogic () {
            timer = Timer.scheduledTimer (
                withTimeInterval: GameConfigs.spawnDelay, 
                repeats: true
            ) { _ in 
                
                self.manages.forEach { e in 
                    guard ( e is HomingEngine ) else { return }
                    
                    e.spawnObject()
                    spawnCountForHomingEngine += 1
                    
                    if ( spawnCountForHomingEngine >= GameConfigs.hostileAmmoCapacity ) {
                        timer?.invalidate()
                        spawnCountForHomingEngine = 0
                        
                        Timer.scheduledTimer(withTimeInterval: GameConfigs.hostileReloadDuration, repeats: false) { _ in
                            beginHomingEngineAutoShootAndReloadLogic()
                        }
                    }
                }
                
            }
        }
        
        manages.forEach { engine in
            engine.setup(manager: view)
            
            switch ( engine ) {
                case is ShootingEngine:
                    let e = engine as! ShootingEngine
                    e.setup(manager: view)
                    
                    break
                    
                case is HomingEngine:
                    let e = engine as! HomingEngine
                    e.setup(manager: view)
                    
                    beginHomingEngineAutoShootAndReloadLogic()
                    break
                    
                case is TargetEngine:
                    let e = engine as! TargetEngine
                    e.setup(manager: view)
                    
                    break
                    
                default:
                    engine.setup(manager: view)
                    
                    break
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
                        let e = engine as! ShootingEngine
                        e.spawnObject()

                        break
                        
                    case is HomingEngine:
                        let e = engine as! HomingEngine                        
//                        let cameraTransform = e.manager!.cameraTransform.matrix
//                        
//                        var translation = matrix_identity_float4x4
//                        translation.columns.3.z -= 5
//                        let transform = simd_mul(cameraTransform, translation)
//                        
//                        let raycastQuery = ARRaycastQuery (
//                            origin: SIMD3([
//                                transform.columns.3.x,
//                                transform.columns.3.y,
//                                transform.columns.3.z
//                            ]),
//                            direction: SIMD3(0, -1, 0),
//                            allowing: .estimatedPlane,
//                            alignment: .horizontal
//                        )
//                        
//                        let results = e.manager!.session.raycast(raycastQuery)
//                        
//                        if let firstResult = results.first {
//                            let groundPosition = SIMD3(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
//                            e.setSpawnPosition(newPosition: groundPosition)
//                            
//                        } else {
//                            e.setSpawnPosition(newPosition: SIMD3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z))
//                        }
                        break
                        
                    case is LegacyHomingEngine:
                        let e = engine as! LegacyHomingEngine
                        e.spawnObject()
                    
                        break
                        
                    case is TargetEngine:
//                      let e = engine as! TargetEngine

                        break
                        
                    default:
                        break
                }
            })
        }
        
        @objc func handleHold ( _ gesture: UILongPressGestureRecognizer ) {
            if ( gesture.state == .began ) {
                holdTimer = Timer.scheduledTimer(withTimeInterval: GameConfigs.spawnDelay, repeats: true) { [self] _ in
                    self.managedEngine.forEach({ engine in
                        switch engine {
                            case is ShootingEngine:
                                let e = engine as! ShootingEngine
                                e.spawnObject()

                                break
                                
                            case is HomingEngine:
                                let e = engine as! HomingEngine
                            
                                break
                                
                            case is LegacyHomingEngine:
                                let e = engine as! LegacyHomingEngine
                                e.spawnObject()
                            
                                break
                                
                            case is TargetEngine:
        //                      let e = engine as! TargetEngine

                                break
                                
                            default:
                                break
                        }
                    })
                }
                
            } else if ( gesture.state == .ended || gesture.state == .cancelled ) {
                holdTimer?.invalidate()
                holdTimer = nil
                
            }
        }
    }
    
    func exertConfigs ( _ arView: ARView, _ configs: ARConfiguration ) {
        switch ( configs ) {
            case is ARWorldTrackingConfiguration:
                let c = configs as! ARWorldTrackingConfiguration
                c.planeDetection = [.horizontal, .vertical]
                
                break
                
            default:
                break
        }
        
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
