import SwiftUI
import ARKit
import MultipeerConnectivity

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
