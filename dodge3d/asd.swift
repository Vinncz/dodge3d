import SwiftUI
import ARKit
import RealityKit
import MultipeerConnectivity


struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        arViewModel.setup(arView: arView)
        
        arView.addGestureRecognizer(UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleHold(_:))))
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(arViewModel: arViewModel)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var arViewModel: ARViewModel
        var holdTimer: Timer?

        init(arViewModel: ARViewModel) {
            self.arViewModel = arViewModel
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            arViewModel.updateEntityPosition(frame: frame)
        }
        
        @objc func handleHold (_ gesture: UILongPressGestureRecognizer) {            
            if gesture.state == .began {
                holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
                    self.arViewModel.spawnObject(arView: arViewModel.arView!)
                }
                
            } else if ( gesture.state == .ended || gesture.state == .cancelled ) {
                holdTimer?.invalidate()
                holdTimer = nil
            }
        }
    }
}

class ARViewModel: ObservableObject {
    
    enum PlayerRole {
        case shooter
        case defender
    }
    
    let role: PlayerRole = .shooter
    
    enum GameMode {
        case singleplayer
        case multiplayer
    }
    
    let mode: GameMode = .singleplayer
    
    struct MovingObject {
        let anchor: AnchorEntity
        let direction: SIMD3<Float>
    }

    var arView: ARView?
    var objects: [MovingObject] = []
    var startingPosition: SIMD3<Float>?
    let speed: Float = 0.05 // Speed of the object
    var timer: Timer?
    
    // define dummy target untuk ditembak

    func setup(arView: ARView) {
        self.arView = arView
        
        if startingPosition == nil {
            let cameraPosition = arView.cameraTransform.translation
            startingPosition = cameraPosition + SIMD3<Float>(0, 0, -2.5)
        }

        if ( self.mode == .singleplayer ) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                self.spawnObject(arView: arView)
            }
        }
        
        addSpawner(arView: arView)
        addSpawner(arView: arView)
        addSpawner(arView: arView)
    }
    
    func addSpawner (arView: ARView) {
        var anchor: AnchorEntity
        if ( self.mode == .multiplayer ) {
            anchor = AnchorEntity(world: arView.cameraTransform.translation)
        } else {
            anchor = AnchorEntity(world: [Float.random(in: -1...1), Float.random(in: -0.5...0.5), Float.random(in: 2...5) * -1])
        }
        
        let spawnerEntity = ModelEntity(mesh: .generateBox(size: 0.1), materials: [SimpleMaterial(color: .black, isMetallic: false)])
        anchor.addChild(spawnerEntity)
        arView.scene.addAnchor(anchor)
    }
    
    func spawnObject(arView: ARView) {
        var anchor: AnchorEntity
        if ( self.mode == .multiplayer ) {
            anchor = AnchorEntity(world: arView.cameraTransform.translation)
        } else {
//            anchor = AnchorEntity(world: [Float.random(in: -1...1), Float.random(in: -0.5...0.5), Float.random(in: 2...5) * -1])
            anchor = AnchorEntity(world: arView.cameraTransform.translation)
            if let cameraTransform = arView.session.currentFrame?.camera.transform {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = GameConfigs.homingSpawnDistance  // The object will appear 2 meters in the direction the camera is facing
                let modifiedTransform = simd_mul(cameraTransform, translation)
                let position = SIMD3<Float>(modifiedTransform.columns.3.x, modifiedTransform.columns.3.y, modifiedTransform.columns.3.z)
                anchor = AnchorEntity(world: position)
            }
            
//            anchor.position.z -= 2
        }
        
        let modelEntity = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        anchor.addChild(modelEntity)
        
        arView.scene.addAnchor(anchor)

        // Calculate the direction vector from the object to the camera
        let cameraTransform = arView.cameraTransform
        let cameraForwardDirection = SIMD3<Float>(x: -cameraTransform.matrix.columns.2.x, y: -cameraTransform.matrix.columns.2.y, z: -cameraTransform.matrix.columns.2.z)
        var direction = cameraForwardDirection
        
        if ( !(self.mode == .multiplayer && self.role == .shooter) ) {
            direction *= -1
            
        } else {
            direction.x = -direction.x
            direction.z = -direction.z
        }

        let angle = Float.random(in: -Float.pi/8...Float.pi/8) // Random angle within +/- 22.5 degrees
        let offset = SIMD3<Float>(cos(angle), 0, sin(angle)) // Offset vector
        direction -= offset

        // Add the object to the list
        objects.append(MovingObject(anchor: anchor, direction: direction))

        // Despawn the object after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            arView.scene.removeAnchor(anchor)
            self.objects.removeAll { $0.anchor == anchor }
            
        }
    }

    func updateEntityPosition(frame: ARFrame) {
        for object in objects {
            let newPosition = object.anchor.position(relativeTo: nil) + object.direction * speed

            // Move the object in the set direction
            object.anchor.setPosition(newPosition, relativeTo: nil)
            
            let cameraTransform = frame.camera.transform
            let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            
            let objectPosition = object.anchor.position(relativeTo: nil)
            let distance = length(cameraPosition - objectPosition)
            if distance < 0.05 {
                // Collision detected
                handleCollisionWithCamera(object: object)
            }
        }
    }
    
    func handleCollisionWithCamera(object: MovingObject) {
        print("kena kamera nih!")
    }
}



struct ARDodgeballView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        let scene = SCNScene()
        arView.scene = scene
        arView.autoenablesDefaultLighting = true
        arView.showsStatistics = true
        
        // Set up AR tracking configuration
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject {
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARSCNView else { return }
            let scene = arView.scene
            let camera = arView.session.currentFrame?.camera
            
            // Create a ball node
            let ballNode = SCNNode(geometry: SCNSphere(radius: 0.05))
            ballNode.position = SCNVector3(camera!.transform.columns.3.x, camera!.transform.columns.3.y, camera!.transform.columns.3.z)
            ballNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            
            // Apply force to the ball
            let force = simd_make_float4(0, 0, -1, 0)
            let rotatedForce = camera!.transform * force
            let vectorForce = SCNVector3(x: rotatedForce.x, y: rotatedForce.y, z: rotatedForce.z)
            ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            ballNode.physicsBody?.applyForce(vectorForce, asImpulse: true)
            
            scene.rootNode.addChildNode(ballNode)
        }
    }
}

struct asd: View {
    var body: some View {
        ARDodgeballView()
            .edgesIgnoringSafeArea(.all)
    }
}
