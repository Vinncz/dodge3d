//
//  Canvas.swift
//  dodge3d
//
//  Created by Vin on 25/04/24.
//

import SwiftUI
import ARKit
import RealityKit
import Observation

struct Canvas: View {
    @State var engines: [Engine] = [
        ShootingEngine()
    ]
    
    var body: some View {
        ContentManagement (
            manages: self.$engines
        )
    }
}

struct ContentManagement: UIViewRepresentable {
    @Binding var manages: [Engine]
    
    /* Inherited from protocol UIViewRepresentable. Refrain from renaming the following */
    func makeUIView ( context: Context ) -> some UIView {
        let arView = ARView()
        
        exertConfigs(arView, ARWorldTrackingConfiguration())
        
        attachTapGestureRecognizer(context, arView)
        attachHoldGestureRecognizer(context, arView)
        
        setupEngines(arView)
        
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func setupEngines ( _ view: ARView ) {
        manages.forEach { engine in
            engine.setup(_manager: view)
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
        
        init ( _managedEngine: [Engine] ) {
            self.managedEngine = _managedEngine
        }
        
        /* Inherited from protocol ARSessionDelegate. Refrain from renaming the following */
        func session ( _ session: ARSession, didUpdate frame: ARFrame ) {
            print("masuk session!")
            
            for engine in self.managedEngine {
                (engine as! ShootingEngine).updateObjectPosition(_frame: frame)
            }
        }
        
        @objc func handleTap ( _ gesture: UITapGestureRecognizer ) {
            print("layar kena tap!")
        }
        
        @objc func handleHold ( _ gesture: UILongPressGestureRecognizer ) {
            if ( gesture.state == .began ) {
                holdTimer = Timer.scheduledTimer(withTimeInterval: GameConfigs.summonDelay, repeats: true) { [self] _ in
                    self.managedEngine[0].spawnObject()
                }
                
            } else if ( gesture.state == .ended || gesture.state == .cancelled ) {
                holdTimer?.invalidate()
                holdTimer = nil
                
            }
        }
    }
    
    func exertConfigs ( _ arView: ARView, _ configs: ARWorldTrackingConfiguration ) {
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

@Observable class Engine {
    var manager: ARView?
    var projectiles: [MovingObject] = []
    let projectileSpeed:Float = GameConfigs.projectileSpeed
    var timer: Timer?
    
    struct MovingObject {
        var anchor   : AnchorEntity
        var direction: SIMD3<Float>
    }
    
    func setup                     ( _manager: ARView  ) { self.manager = _manager }
    func spawnObject               ( ) {}
    func despawnObject             ( targetAnchor: AnchorEntity ) {}
    func updateObjectPosition      ( _frame  : ARFrame ) {}
    func calculateObjectTrajectory ( ) -> SIMD3<Float> { return SIMD3<Float>(x: 0, y: 0, z: 0) }
    func createObject              ( ) -> ModelEntity { return ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .red, isMetallic: true)]) }
    func handleCollisionWithCamera ( objectResponsible: MovingObject ) {}
}

@Observable class ShootingEngine: Engine {
    
    override func spawnObject ( ) {
        // anchor bisa dimengerti sebagai 
        // 'lokasi yang lu tunjuk, yang nantinya bakal ditempatin suatu object'
        let anchor = AnchorEntity (
            world: self.manager!.cameraTransform.translation
        )
        
        // semua object memerlukan anchor agar bisa tampil
        // likewise, semua anchor memerlukan scene agar bisa tampil
        anchor.addChild(createObject())
        self.manager!.scene.addAnchor(anchor)
        
        let trajectory = calculateObjectTrajectory()
        projectiles.append (
            MovingObject (
                anchor: anchor, 
                direction: trajectory
            )
        )
        
        despawnObject(targetAnchor: anchor)
    }
    
    override func despawnObject ( targetAnchor: AnchorEntity ) {
        DispatchQueue.main.asyncAfter(deadline: GameConfigs.despawnDelay) {
            self.manager!.scene.removeAnchor(targetAnchor)
            self.projectiles.removeAll { $0.anchor == targetAnchor }
        }
    }
    
    override func calculateObjectTrajectory () -> SIMD3<Float> {
        let cameraTransform = self.manager!.cameraTransform
        let cameraForwardDirection = SIMD3<Float>(x: cameraTransform.matrix.columns.2.x, y: cameraTransform.matrix.columns.2.y, z: cameraTransform.matrix.columns.2.z)
        var direction = cameraForwardDirection

        let angle = Float.random(in: -Float.pi/8...Float.pi/8)
        let offset = SIMD3<Float>(cos(angle), 0, sin(angle)) * 0.01
        direction -= offset
        
        return direction
    }
    
    override func updateObjectPosition ( _frame: ARFrame ) {
        for projectile in projectiles {
            let projectileCurrentPosition = projectile.anchor.position(relativeTo: nil)
            let projectedPositionModifier = projectile.direction * self.projectileSpeed
            
            let projectedPosition         = projectileCurrentPosition + projectedPositionModifier
            
            projectile.anchor.setPosition(projectedPosition, relativeTo: nil)
            
            // transform is a 4x4 matrix that contains
            // 1. where the camera is
            // 2. where its looking at
            // 3. any tilt?
            let cameraTransform = _frame.camera.transform
            let cameraPosition  = SIMD3<Float> (
                cameraTransform.columns.3.x,
                cameraTransform.columns.3.y,
                cameraTransform.columns.3.z
            )
            
            let distanceFromCamera = length(cameraPosition - projectedPosition)
            detectCollisionWithCamera( objectInQuestion: projectile, distance: distanceFromCamera)
        }
    }
    
    func detectCollisionWithCamera ( objectInQuestion object: MovingObject, distance distanceFromCamera: Float ) {
        if ( distanceFromCamera < GameConfigs.defaultSphereRadius ) {
            handleCollisionWithCamera(objectResponsible: object)
        }
    } 

    override func handleCollisionWithCamera(objectResponsible: Engine.MovingObject) {
        print("kena kamera nih!")
    }
}

@Observable class HomingEngine: Engine {
    
}

#Preview {
    Canvas()
}
