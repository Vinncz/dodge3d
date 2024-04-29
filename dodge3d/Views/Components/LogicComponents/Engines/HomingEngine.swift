import ARKit
import RealityKit
import SwiftUI

@Observable class HomingEngine: Engine {
    var spawnPosition: SIMD3<Float> = [0, 0, -5]
    var projectileSpeed: Float = GameConfigs.hostileProjectileSpeed
    
    var previousCameraPosition: SIMD3<Float>?
    var previousTime: Float?
    
    override func setup ( manager: ARView ) {
        self.manager = manager
        
        spawnTurret()
    }
    
    func spawnTurret () {
        
    }
    
    func setSpawnPosition ( newPosition: SIMD3<Float> ) -> HomingEngine {
        self.spawnPosition = newPosition
        
        return self
    } 
    
    override func createObject ( ) -> ModelEntity {
//        guard let entity = try? ModelEntity.loadModel(named: "Anti-Tank_Turret") else {
            let object = ModelEntity(mesh: .generateSphere(radius: GameConfigs.defaultSphereRadius), materials: [SimpleMaterial(color: .red, isMetallic: true)])
            object.physicsBody?.mode = .dynamic
            object.generateCollisionShapes(recursive: true)
            
            return object
//        }
        
//        return entity
    }
    
    override func spawnObject ( ) {
        let spawnPosition    = self.spawnPosition
        
        let anchor = AnchorEntity(world: spawnPosition)
        
        let createdObject = createObject()
        anchor.addChild(createdObject)
        
        self.manager!.scene.addAnchor(anchor)
        
        let trajectory = calculateObjectMovingDirection(from: anchor, to: anchor)
        projectiles.append (
            MovingObject (
                object    : createdObject,
                anchor    : anchor,
                direction : trajectory
            )
        )
        
        despawnObject(targetAnchor: anchor)
    }
    
    override func calculateObjectMovingDirection ( from: AnchorEntity, to: AnchorEntity ) -> SIMD3<Float> {
        /* makes projectile go either left or right */
        let inaccuracyFactor = Float.random (  
            in: GameConfigs.hostileProjectileInaccuracy,
            using: &GameConfigs.rng1
        )
        
        /* makes projectile go either up or down */
        let recoil = Float.random (  
            in: -1...1,
            using: &GameConfigs.rng2 
        )
        
        /* inaccuracy leads to the projectile being amiss by a few degrees */
        let angle = inaccuracyFactor != 0 ? (Float.pi / inaccuracyFactor) * recoil : 0

        let objectPosition = from.position(relativeTo: nil)
        let cameraPosition = self.manager!.cameraTransform.translation
        
        let currentTime = Float(Date().timeIntervalSince1970)
        let timeElapsed = previousTime != nil ? currentTime - previousTime! : 0
        previousTime = currentTime
        
        let cameraVelocity = (previousCameraPosition != nil && timeElapsed != 0) ? (cameraPosition - previousCameraPosition!) / timeElapsed : SIMD3<Float>(0, 0, 0)
        previousCameraPosition = cameraPosition
        
        let objectToCameraDistance = length(cameraPosition - objectPosition)
        let timeToReachCamera = (objectToCameraDistance != 0 && projectileSpeed != 0) ? objectToCameraDistance / projectileSpeed : 0
        
        let predictedCameraPosition = cameraPosition + cameraVelocity * timeToReachCamera
        
        var movingDirection = normalize(predictedCameraPosition - objectPosition)
        
        let rotationY = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
        let rotationZ = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 0, 1))
        movingDirection = rotationY.act(movingDirection)
        movingDirection = rotationZ.act(movingDirection)
        
        return movingDirection
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
//        counter += 1
    }
    
    override func handleDebug(message: Any) {
        if ( GameConfigs.debug ) {
            print(message)
        }
    }
}
