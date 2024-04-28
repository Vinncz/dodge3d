import SwiftUI
import ARKit
import RealityKit
import Observation

@Observable class Engine {
    var manager: ARView?
    var projectiles: [MovingObject] = []
    var timer: Timer?
    
    class MovingObject {
        var object   : ModelEntity
        var anchor   : AnchorEntity
        var direction: SIMD3<Float>
        var gravityEf: Float = GameConfigs.projectileGravityInitialStrength
        
        init ( object: ModelEntity, anchor: AnchorEntity, direction: SIMD3<Float> ) {
            self.object = object
            self.anchor = anchor
            self.direction = direction
        }
    }
    
    /** Sets up the required ARView to attribute. Without the supplied ARView, nothing will be placed, moved, or visible. -- Think of ARView as a management agency that you signed up for. Without them, you cannot perform onto stage. */
    func setup ( manager: ARView ) { 
        self.manager = manager
    }
    
    /** The method which creates an object, which then will need to be placed somewhere  */
    func createObject ( ) -> ModelEntity {
        let object = ModelEntity(mesh: .generateSphere(radius: GameConfigs.defaultSphereRadius), materials: [SimpleMaterial(color: .white, isMetallic: true)])
        object.physicsBody?.mode = .dynamic
        object.generateCollisionShapes(recursive: true)
        
        return object
    }
    
    /** The method which places an object onto canvas, making it visible */
    func spawnObject ( ) {}
    
    /** The method which makes an object disappear, and then deletes it */
    func despawnObject ( targetAnchor: AnchorEntity ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConfigs.despawnDelay) {
            self.manager!.scene.removeAnchor(targetAnchor)
            self.projectiles.removeAll { $0.anchor == targetAnchor }
        }
    }
    
    /** The method which moves an object to somewhere */
    func updateObjectPosition ( frame : ARFrame ) {}
    
    /** The method which calculates where the object is going to be, influenced by its speed and its direction vector */
    func calculateObjectMovingDirection ( from: AnchorEntity, to: AnchorEntity ) -> SIMD3<Float> {
        return SIMD3<Float>(x: 0, y: 0, z: 0) 
    }
    
    /** The method which determines whether an object has collided with another object. CANNOT BE USED TO TRACK COLLISION BETWEEN OBJECT AND CAMERA */
    func detectCollision ( of objectA: Entity, to objectB: Entity ) -> Bool {
        
        /* When either object isn't visible, they can't possibly collide */
        guard let anchorA = objectA.anchor, let anchorB = objectB.anchor else {
            return false
        }
        
        let distance = length(anchorB.transform.translation - anchorA.transform.translation)
        print("distance: \(distance)")
        let treshold = GameConfigs.defaultCollisionRadius
        
        if ( distance <= treshold ) { print("they collided!") }
        
        return distance <= treshold
    }
    
    /** The method which determines whether an object has collided with the camera */
    func detectCollisionWithCamera ( objectInQuestion object: MovingObject, distance distanceFromCamera: Float ) -> Bool { 
        return false
    }
    
    /** The method which dictates what happens when an object colided with the camera */
    func handleCollisionWithCamera ( objectResponsible: MovingObject ) {}
    
    func handleDebug ( message: Any ) {}
    
//    func loadUSDZ(named name: String) -> ModelEntity? {
//        let url = Bundle.main.url(forResource: name, withExtension: "usdz")
//        guard let url = url else {
//            debugPrint("Error: Unable to find USDZ asset \(name)")
//            return nil
//        }
//        return ModelEntity(url: url)
//    }
//
//    func createObject() -> ModelEntity? {
//        guard let entity = loadUSDZ(named: "Plasma") else {
//            return nil
//        }
//        entity.generateCollisionShapes(recursive: true)
//        entity.physicsBody?.mode = .dynamic
//        return entity
//    }
}
