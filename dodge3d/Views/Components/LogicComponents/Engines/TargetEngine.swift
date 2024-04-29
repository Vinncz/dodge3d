import ARKit
import RealityKit
import SwiftUI

@Observable class TargetEngine: Engine {
    var instanceCount = 0
    
    private func randomPositionInFrontOfCamera() -> SIMD3<Float> {
        let cameraTransform = self.manager!.cameraTransform
        
        let randomDistance = Float.random(in: 1.0...4.0) // Jarak acak dari kamera
        let randomAngle = Float.random(in: -Float.pi...Float.pi) // Sudut acak
        
        let randomOffset = SIMD3<Float>(cos(randomAngle), 0, sin(randomAngle)) * randomDistance
        let randomPosition = cameraTransform.translation + randomOffset
        
        return randomPosition
    }
    
    func createBoxObject() -> ModelEntity {
        let randomSize = Float.random(in: 0.1...0.5) // Ukuran acak untuk target box
        let boxSize = randomSize
        let object = ModelEntity(mesh: .generateBox(size: SIMD3<Float>(repeating: boxSize)), materials: [SimpleMaterial(color: .magenta, isMetallic: true)])
        
        object.generateCollisionShapes(recursive: true)
        object.physicsBody?.mode = .dynamic
                
        return object
    }
    
    override func spawnObject() {
        if ( self.instanceCount <= GameConfigs.maxTargetCount ) {
            let anchor = AnchorEntity(world: randomPositionInFrontOfCamera())
            anchor.addChild(createBoxObject())
            self.manager!.scene.addAnchor(anchor)
            
            self.instanceCount += 1
        }
    }
    
    override func setup ( manager: ARView ) {
        self.manager = manager
        self.spawnObject()
        self.spawnObject()
        self.spawnObject()
        self.spawnObject()
        self.spawnObject()
    }
}
