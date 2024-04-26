import SwiftUI
import ARKit
import RealityKit

@Observable class Engine {
    var manager: ARView?
    var projectiles: [MovingObject] = []
    var projectileSpeed:Float = GameConfigs.projectileSpeed
    var timer: Timer?
    
    struct MovingObject {
        var anchor   : AnchorEntity
        var direction: SIMD3<Float>
    }
    
    /** Sets up the required ARView to attribute. Without the supplied ARView, nothing will be placed, moved, or visible. -- Think of ARView as a management agency that you signed up for. Without them, you cannot perform onto stage. */
    func setup ( manager: ARView ) { 
        self.manager = manager
    }
    
    /** The method which creates an object, which then will need to be placed somewhere  */
    func createObject ( ) -> ModelEntity {
        let object = ModelEntity(mesh: .generateSphere(radius: GameConfigs.defaultSphereRadius), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        object.generateCollisionShapes(recursive: true)
        object.physicsBody?.mode = .dynamic
        
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
    func calculateObjectTrajectory ( ) -> SIMD3<Float> {
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
}

@Observable class ShootingEngine: Engine {
    
    override func createObject ( ) -> ModelEntity {
        let object = ModelEntity(mesh: .generateSphere(radius: GameConfigs.defaultSphereRadius - 0.025), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
        object.generateCollisionShapes(recursive: true)
        object.physicsBody?.mode = .dynamic
        
        return object
    }
    
    override func spawnObject ( ) {
        let anchor = AnchorEntity (
            world: self.manager!.cameraTransform.translation
        )
        
        anchor.position.x = self.manager!.cameraTransform.translation.x + GameConfigs.projectileScreenOffsetX
        anchor.position.y = self.manager!.cameraTransform.translation.y + GameConfigs.projectileScreenOffsetY
        anchor.position.z = self.manager!.cameraTransform.translation.z + GameConfigs.projectileScreenOffsetZ
        
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
    
    override func calculateObjectTrajectory () -> SIMD3<Float> {
        let cameraTransform = self.manager!.cameraTransform
        let cameraForwardDirection = SIMD3<Float>(x: cameraTransform.matrix.columns.2.x, y: cameraTransform.matrix.columns.2.y, z: cameraTransform.matrix.columns.2.z)
        
        // multiply by -1 to direct the projectile to the front of the camera
        var direction = cameraForwardDirection * -1
        
        let angle = Float.random(in: -GameConfigs.projectileRandomnessSpecifier...GameConfigs.projectileRandomnessSpecifier)
        let offset = SIMD3<Float>(cos(angle), 0, sin(angle)) * GameConfigs.projectileRandomnessMultiplier
        direction += offset
        
        return direction
    }
    
    override func updateObjectPosition ( frame: ARFrame ) {
        for projectile in projectiles {
            let projectileCurrentPosition = projectile.anchor.position(relativeTo: nil)
            let projectedPositionModifier = projectile.direction * self.projectileSpeed
            
            let projectedPosition         = projectileCurrentPosition + projectedPositionModifier
            
            projectile.anchor.setPosition(projectedPosition, relativeTo: nil)
        }
    }

}

@Observable class HomingEngine: Engine {
    var counter: Int = 0
    var offset : Float
    
    init(_ offset: Float = 0) {
        self.offset = offset
    }
    
    override func spawnObject ( ) {
        var anchor = AnchorEntity(world: self.manager!.cameraTransform.translation)
        if let cameraTransform = self.manager!.session.currentFrame?.camera.transform {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = GameConfigs.spawnDistance  // The object will appear 2 meters in the direction the camera is facing
            let modifiedTransform = simd_mul(cameraTransform, translation)
            let position = SIMD3<Float>(modifiedTransform.columns.3.x + offset, modifiedTransform.columns.3.y, modifiedTransform.columns.3.z)
            anchor = AnchorEntity(world: position)
        }
        
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
    
    override func calculateObjectTrajectory () -> SIMD3<Float> {
        let cameraTransform = self.manager!.cameraTransform
        let cameraForwardDirection = SIMD3<Float>(x: cameraTransform.matrix.columns.2.x - (self.offset / 2), y: cameraTransform.matrix.columns.2.y, z: cameraTransform.matrix.columns.2.z)
        
        // multiply by -1 to direct the projectile to the front of the camera
        var direction = cameraForwardDirection
        
        let angle = Float.random(in: -GameConfigs.projectileRandomnessSpecifier...GameConfigs.projectileRandomnessSpecifier)
        let offset = SIMD3<Float>(cos(angle), 0, sin(angle)) * GameConfigs.projectileRandomnessMultiplier
        direction += offset
        
        return direction
    }
    
    override func updateObjectPosition ( frame: ARFrame ) {
        for projectile in projectiles {
            let projectileCurrentPosition = projectile.anchor.position(relativeTo: nil)
            let projectedPositionModifier = projectile.direction * self.projectileSpeed
            
            let projectedPosition         = projectileCurrentPosition + projectedPositionModifier
            
            projectile.anchor.setPosition(projectedPosition, relativeTo: nil)

            let cameraTransform = frame.camera.transform
            let cameraPosition  = SIMD3<Float> (
                cameraTransform.columns.3.x,
                cameraTransform.columns.3.y,
                cameraTransform.columns.3.z
            )
            
            let distanceFromCamera = length(cameraPosition - projectedPosition)
            
            /* somehow, posisi projectile-nya stale, sehingga dia hanya ngukur posisi projectile sekarang ke posisi lamanya */
//            if ( detectCollision(of: AnchorEntity(world: cameraPosition), to: projectile.anchor) ) {
//                handleCollisionWithCamera(objectResponsible: projectile)   
//            }
            
            if ( detectCollisionWithCamera( objectInQuestion: projectile, distance: distanceFromCamera) ) {
                handleCollisionWithCamera(objectResponsible: projectile)
            }
        }
    }
    
    override func detectCollisionWithCamera ( objectInQuestion object: MovingObject, distance distanceFromCamera: Float ) -> Bool {
        handleDebug(message: "distance: \(distanceFromCamera)")
        let treshold = GameConfigs.defaultCollisionRadius
        
        if ( distanceFromCamera <= treshold ) { handleDebug(message: "they collided!") }
        return distanceFromCamera < GameConfigs.defaultSphereRadius ? true : false
    }
    
    override func handleCollisionWithCamera(objectResponsible: Engine.MovingObject) {
        counter += 1
    }
    
    override func handleDebug(message: Any) {
        if ( GameConfigs.debug ) {
            print(message)
        }
    }
}

@Observable class TargetEngine: Engine {
    var instanceCount = 0
    
    private func randomPositionInFrontOfCamera() -> SIMD3<Float> {
        let cameraTransform = self.manager!.cameraTransform
        let cameraForwardDirection = SIMD3<Float>(x: cameraTransform.matrix.columns.2.x, y: cameraTransform.matrix.columns.2.y, z: cameraTransform.matrix.columns.2.z)
        
        let randomDistance = Float.random(in: 1.0...4.0) // Jarak acak dari kamera
        let randomAngle = Float.random(in: -Float.pi...Float.pi) // Sudut acak
        
        let randomOffset = SIMD3<Float>(cos(randomAngle), 0, sin(randomAngle)) * randomDistance
        let randomPosition = cameraTransform.translation + randomOffset
        
        return randomPosition
    }
    
    func createBoxObject() -> ModelEntity {
        let boxSize = Float.random(in: 0.1...0.5) // Ukuran acak untuk kotak
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
