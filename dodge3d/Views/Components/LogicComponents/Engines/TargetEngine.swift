import ARKit
import RealityKit
import SwiftUI

@Observable class TargetEngine: Engine {
    var instanceCount = 0
    var boxesAnchors: [AnchorEntity] = []
    
    private func randomPositionInFrontOfCamera() -> SIMD3<Float> {
//        let cameraTransform = self.manager!.cameraTransform
        
        let randomToTheRightOrLeft = Float.random(in: -180...180, using: &GameConfigs.rng3)
        let randomToTheFront = Float.random(in: 3...5) * -1
        let spawnPosition = self.manager!.getPositionRelativeToCamera(distanceToCamera: randomToTheFront, angleInDegrees: self.manager!.convertDegreesToRadians(randomToTheRightOrLeft))
        
        let camerasFront = manager!.getCameraFrontDirectionVector()
        var rotatedVector = manager!.rotateVetor(initialVector: camerasFront, angleInDegrees: randomToTheRightOrLeft, axis: .yaw)
        rotatedVector = manager!.rotateVetor(initialVector: rotatedVector, angleInDegrees: randomToTheRightOrLeft, axis: .pitch)
        rotatedVector.z += randomToTheFront
        
//        let randomDistance = Float.random(in: 1.5...3.0) // Jarak acak dari kamera
//        let randomAngle = Float.random(in: -Float.pi...Float.pi) // Sudut acak
//        
//        let randomOffset = SIMD3<Float>(cos(randomAngle), 0, sin(randomAngle)) * randomDistance
//        let randomPosition = cameraTransform.translation + randomOffset
        
//        return randomPosition
//        print(rotatedVector)
        return rotatedVector
    }
    
    func createBoxObject() -> ModelEntity {
        let boxSize: Float = 0.5
        let object = ModelEntity(mesh: .generateBox(size: SIMD3<Float>(repeating: boxSize)), materials: [SimpleMaterial(color: .magenta, isMetallic: true)])
        
        object.generateCollisionShapes(recursive: true)
        object.physicsBody?.mode = .dynamic
        
//        adding collision
//        object.collision = CollisionComponent(shapes: [.generateBox(size: [randomSize, randomSize, randomSize])], mode: .default, filter: .default)
        
        return object
    }
    
    override func spawnObject() {
        let anchorPosition = randomPositionInFrontOfCamera()
        
        if ( self.instanceCount <= GameConfigs.maxTargetCount ) {
            let anchor = AnchorEntity(world: anchorPosition)
            anchor.addChild(createBoxObject())
            self.manager!.scene.addAnchor(anchor)
            
            self.instanceCount += 1
            self.boxesAnchors.append(anchor)
        }
    }
    
    override func setup ( manager: ARView ) {
        self.manager = manager
        self.spawnObject()
        self.spawnObject()
        self.spawnObject()
    }
}
