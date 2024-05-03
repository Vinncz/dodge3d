import ARKit
import RealityKit
import SwiftUI

@Observable class HomingEngine: Engine {
    struct MessageFormat {
        var contentName: String
        var messageContent: Any
    }
    
    override init ( signature: String = DefaultString.signatureOfHomingEngineForMediator, mediator: Mediator? = nil ) {
        super.init()

        self.signature = signature
        self.mediator  = mediator
    }
    
    override func receiveMessage ( _ message: Any, sendersSignature from: String? ) {
        switch ( from ) {
            case DefaultString.signatureOfShootingEngineForMediator:
                break
            case DefaultString.signatureOfPlayerForMediator:
                break
            case DefaultString.signatureOfBuffEngineForMediator:
                break
            default:
                handleDebug(message: "A message was not captured by \(self.signature)")
        }
    }
    
    var turret: Turret = Turret()
    var spawnPosition: SIMD3<Float> = [0, 0, -5]
    var turretIsSpawned:Bool = false
    
    @Observable class Turret {
        var maxHealth: Int          = GameConfigs.hostileTurretHealth
        var health   : Int          = 0
        var position : SIMD3<Float> = GameConfigs.hostileTurretInitialSpawnPosition
        var entity   : ModelEntity?
        var anchor   : AnchorEntity
//        var nullifiedProjectile: [MovingObject] = []
        
        init () {
            self.anchor = AnchorEntity(world: GameConfigs.hostileTurretInitialSpawnPosition)
            self.health = self.maxHealth
        }
    }
    
    var projectilesWhoHitCamera: [MovingObject] = []
    
    var projectileSpeed: Float = GameConfigs.hostileProjectileSpeed
    
    var previousCameraPosition: SIMD3<Float>?
    var previousTime: Float?
    
    override func setup ( manager: ARView ) {
        self.manager = manager
    }
    
    func spawnTurret ( ) {
        turret.entity = try! ModelEntity.loadModel(named: "Anti-Tank_Turret")
        turret.entity!.setScale([0.005, 0.005, 0.005], relativeTo: nil)
        
        let directionToCamera = normalize(manager!.getCameraPosition() - spawnPosition)
        let angle = atan2(directionToCamera.x, directionToCamera.z)
        
        let forwardDirection = SIMD3(-sin(angle), 0, -cos(angle))
        
        turret.position = spawnPosition + forwardDirection * 0.5
        turret.anchor = AnchorEntity(world: turret.position)
        turret.anchor.transform.translation.y -= 0.15
        turret.anchor.transform.rotation = simd_quatf(angle: angle - Float.pi / 2, axis: [0, 1, 0])
        
        /* 
         tell the ShootingEngine that a new turret has been spawned at the specified position.
         failure to do so will result in:
             - the ShootingEngine will lose track whether any of its projectiles might've hit the turret
         */
        sendMessage (
            to: DefaultString.signatureOfShootingEngineForMediator, 
            MessageFormat (
                contentName: DefaultString.homingEngineNewTurretPosition, 
                messageContent: turret.anchor.transform.translation
            ),
            sendersSignature: DefaultString.signatureOfHomingEngineForMediator
        )

        turret.anchor.addChild(turret.entity!)
        self.manager!.scene.addAnchor(turret.anchor)
    }
    
    func despawnTurret () {
        turret.anchor.removeChild(turret.entity!)
        turret.entity = nil
        self.manager!.scene.removeAnchor(turret.anchor)
    }    
    
    func setSpawnPosition ( ) {
        if (turretIsSpawned) { despawnTurret() }
        turretIsSpawned = true
        self.spawnPosition = manager!.getPositionRelativeToCamera(distanceToCamera: GameConfigs.homingSpawnDistance, angleInDegrees: 0)
        spawnTurret()
    } 
    
    override func createObject ( ) -> ModelEntity {
        let object = ModelEntity(mesh: .generateSphere(radius: GameConfigs.defaultSphereRadius), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        object.physicsBody?.mode = .dynamic
        object.generateCollisionShapes(recursive: true)
        
        return object
    }
    
    override func spawnObject ( ) {
        guard (  turretIsSpawned  ) else { return }
        guard ( turret.health > 0 ) else { return }
        
        let spawnPosition = self.spawnPosition
        
        let anchor = AnchorEntity(world: spawnPosition)
        
        let createdObject = createObject()
        anchor.addChild(createdObject)
        
        self.manager!.scene.addAnchor(anchor)
        
        let trajectory = calculateObjectMovingDirection(from: anchor, to: anchor)
        projectiles.append (
            MovingObject (
                object    : createdObject,
                anchor    : anchor,
                direction : trajectory,
                id        : self.counter
            )
        )
        self.counter += 1
        
        despawnObject (targetAnchor: anchor)
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
//        func printNodeNames(entity: ModelEntity, prefix: String = "") {
//            print(prefix + entity.name)
//            for child in entity.children {
//                printNodeNames(entity: child as! ModelEntity, prefix: prefix + "  ")
//            }
//        }
//        
//        if ( turretIsSpawned ) {
//            let directionToCamera = normalize(manager!.getCameraPosition() - spawnPosition)
//            let angle = atan2(directionToCamera.x, directionToCamera.z)
//            
////            printNodeNames(entity: turret.entity!)
//            
//            if let part = turret.entity!.findEntity(named: "Scene/scene/Meshes/Sketchfab_model/Collada_visual_scene_group/Dome_low/defaultMaterial/defaultMaterial") as? ModelEntity {
//                print("masuk let")
//                part.transform.rotation = simd_quatf(angle: angle - Float.pi / 2, axis: [0, 1, 0])
//            }
//        }
        
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
        let treshold = GameConfigs.hostileSphereRadius + 0.2
        
        if ( distanceFromCamera <= treshold && !projectilesWhoHitCamera.contains(where: { $0.id == object.id })) { 
            handleDebug(message: "they collided!") 
            projectilesWhoHitCamera.append(object)
            return true
        }
        
        return false
    }
    
    override func handleCollisionWithCamera ( objectResponsible: Engine.MovingObject ) {
//        ShootingEngineInstance!.health -= 1
    }
    
    override func handleDebug(message: Any) {
        if ( GameConfigs.debug ) {
            `print`(message)
        }
    }
}
