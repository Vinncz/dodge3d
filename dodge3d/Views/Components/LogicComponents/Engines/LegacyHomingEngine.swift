import ARKit
import RealityKit
import SwiftUI

@Observable class LegacyHomingEngine: Engine {
    var projectileSpeed = GameConfigs.hostileProjectileSpeed
    
    var scounter: Int = 0
    var offset : Float
    
    init(_ offset: Float = 0) {
        self.offset = offset
    }
    
    override func spawnObject ( ) {
        let cameraTransform = self.manager!.cameraTransform
        
        var anchor = AnchorEntity(world: self.manager!.cameraTransform.translation)
        if let cameraTransform = self.manager!.session.currentFrame?.camera.transform {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = GameConfigs.homingSpawnDistance  // The object will appear 2 meters in the direction the camera is facing
            let modifiedTransform = simd_mul(cameraTransform, translation)
            let position = SIMD3<Float>(modifiedTransform.columns.3.x + offset, modifiedTransform.columns.3.y, modifiedTransform.columns.3.z)
            anchor = AnchorEntity(world: position)
        }
        
        let object = createObject()
        anchor.addChild(object)
        self.manager!.scene.addAnchor(anchor)
        
        let trajectory = calculateObjectMovingDirection(from: anchor, to: anchor)
        projectiles.append (
            MovingObject (
                object: object, 
                anchor: anchor,
                direction: trajectory,
                id: self.counter
            )
        )
        counter += 1
        
        despawnObject (targetAnchor: anchor)
    }
    
    override func calculateObjectMovingDirection ( from: AnchorEntity, to: AnchorEntity ) -> SIMD3<Float> {
        let cameraTransform = self.manager!.cameraTransform
        let cameraForwardDirection = SIMD3<Float>(x: cameraTransform.matrix.columns.2.x - (self.offset / 2), y: cameraTransform.matrix.columns.2.y, z: cameraTransform.matrix.columns.2.z)
        
        // multiply by -1 to direct the projectile to the front of the camera
        let direction = cameraForwardDirection
        
//        let angle = Float.random(in: -GameConfigs.projectileRandomnessSpecifier...GameConfigs.projectileRandomnessSpecifier)
//        let offset = SIMD3<Float>(cos(angle), 0, sin(angle)) * GameConfigs.projectileRandomnessMultiplier
//        direction += offset
        
        return direction
    }
    
//    override func spawnObject ( ) {
//        var anchor = AnchorEntity(world: self.manager!.cameraTransform.translation)
//        if let cameraTransform = self.manager!.session.currentFrame?.camera.transform {
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = GameConfigs.spawnDistance  // The object will appear 2 meters in the direction the camera is facing
//            let modifiedTransform = simd_mul(cameraTransform, translation)
//            let position = SIMD3<Float>(modifiedTransform.columns.3.x + offset, modifiedTransform.columns.3.y, modifiedTransform.columns.3.z)
//            anchor = AnchorEntity(world: position)
//        }
//        
//        anchor.addChild(createObject())
//        self.manager!.scene.addAnchor(anchor)
//        
//        let trajectory = calculateObjectTrajectory(from: anchor, to: cameraAnchor)
//        projectiles.append (
//            MovingObject (
//                anchor: anchor,
//                direction: trajectory
//            )
//        )
//        
//        despawnObject(targetAnchor: anchor)
//    }
//    
//    override func calculateObjectTrajectory () -> SIMD3<Float> {
//        let cameraTransform = self.manager!.cameraTransform
//        let cameraForwardDirection = SIMD3<Float>(x: cameraTransform.matrix.columns.2.x - (self.offset / 2), y: cameraTransform.matrix.columns.2.y, z: cameraTransform.matrix.columns.2.z)
//        
//        // multiply by -1 to direct the projectile to the front of the camera
//        var direction = cameraForwardDirection
//        
//        let angle = Float.random(in: -GameConfigs.projectileRandomnessSpecifier...GameConfigs.projectileRandomnessSpecifier)
//        let offset = SIMD3<Float>(cos(angle), 0, sin(angle)) * GameConfigs.projectileRandomnessMultiplier
//        direction += offset
//        
//        return direction
//    }
    
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
    
    override func handleCollisionWithCamera ( objectResponsible: Engine.MovingObject ) {
        scounter += 1
    }
    
    override func handleDebug(message: Any) {
        if ( GameConfigs.debug ) {
            print(message)
        }
    }
}
