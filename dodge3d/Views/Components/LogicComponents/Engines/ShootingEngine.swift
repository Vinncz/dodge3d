import ARKit
import RealityKit
import SwiftUI

@Observable class ShootingEngine: Engine {
    struct MessageFormat {
        var contentName: String
        var messageContent: Any
    }
    
    enum ShootingEngineState {
        case normal
        case outOfAmmo
        case reloading
    }
    
    init ( ammoCapacity: Int = GameConfigs.playerAmmoCapacity, reloadTimeInSeconds: TimeInterval = GameConfigs.playerReloadDuration, signature: String = DefaultString.signatureOfShootingEngineForMediator, mediator: Mediator? = nil ) {
        self.ammoCapacity = ammoCapacity
        self.reloadTime = reloadTimeInSeconds

        super.init()

        self.signature = signature
        self.mediator  = mediator
    }
    
    override func receiveMessage (_ message: Any, sendersSignature from: String?) {
        switch ( from ) {
            case DefaultString.signatureOfHomingEngineForMediator:
                let msg = message as! HomingEngine.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.homingEngineNewTurretPosition:
                        self.turretPosition = msg.messageContent as! SIMD3<Float>
                        break
                        
                    default:
                        handleDebug(message: "A message was not captured by \(self.signature)")
                        break
                }
                
                break
                
            case DefaultString.signatureOfPlayerForMediator:
                break
                
            case DefaultString.signatureOfTargetEngineForMediator:
                let msg = message as! TargetEngine.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.targetEngineNewBuff:
                        self.buffPositions.append(msg.messageContent as! SIMD3<Float>)
                        break
                        
                    default:
                        handleDebug(message: "A message was not captured by \(self.signature)")
                        break
                }
                
                break
                
            default:
                handleDebug(message: "A message was not captured by \(self.signature)")
        }
    }
    
    var turretPosition   : SIMD3<Float> = GameConfigs.hostileTurretInitialSpawnPosition
    var buffPositions    : [SIMD3<Float>] = []
    
    var projectileSpeed  : Float  = GameConfigs.friendlyProjectileSpeed
    var projectileRadius : Float = GameConfigs.friendlySpehreRadius
    
    var health           : Int = 10
    var ammoCapacity     : Int
    var reloadTime       : TimeInterval
    
    var state            : ShootingEngineState = .normal
    var usedAmmo         : Int = 0
    
    func reload ( ) {
        guard ( self.state == .normal || self.state == .outOfAmmo ) else { return }
        self.state = .outOfAmmo
        sendMessage (
            to: DefaultString.signatureOfCanvasForMediator,
            MessageFormat (
                contentName: DefaultString.shootingEnginHasGoneReloading,
                messageContent: ""
            ),
            sendersSignature: self.signature
        )
        
        DispatchQueue.main.asyncAfter ( deadline: .now() + reloadTime ) {
            self.state = .normal
            self.usedAmmo = 0
            
            self.sendMessage (
                to: DefaultString.signatureOfCanvasForMediator,
                MessageFormat (
                    contentName: DefaultString.shootingEnginHasFinishedReloading,
                    messageContent: ""
                ),
                sendersSignature: self.signature
            )
        }
    }
    
    override func createObject ( ) -> ModelEntity {
        let object = ModelEntity(mesh: .generateSphere(radius: self.projectileRadius), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
        object.generateCollisionShapes(recursive: true)
        
        object.collision = CollisionComponent(shapes: [.generateSphere(radius: self.projectileRadius)], mode: .default, filter: .default)
      
        return object
    }
    
    override func spawnObject ( ) {
        guard (  self.state == .normal  ) else { return }
        guard (        health > 0       ) else { return } 
        guard ( usedAmmo < ammoCapacity ) else { return }
        
        let offsetX = GameConfigs.friendlyProjectileScreenOffsetX
        let offsetY = GameConfigs.friendlyProjectileScreenOffsetY
        let offsetZ = GameConfigs.friendlyProjectileScreenOffsetZ

        let spawnPosition = self.manager!.getPositionRelativeToCamera(
            x: offsetX, 
            y: offsetY, 
            z: offsetZ
        )
        
        /* set up the coordinate on where you could place an object to the world */
        let anchor = AnchorEntity(world: spawnPosition)
        
        /* place your object on the allocated coordinate */
        let createdObject = createObject()
        anchor.addChild(createdObject)
        usedAmmo += 1
        if ( self.usedAmmo >= self.ammoCapacity ) {
            self.state = .outOfAmmo
        }
        
        /* make sure to make your anchor visible */
        self.manager!.scene.addAnchor(anchor)
        
        /* determine where your object will be heading to, and append it to the projectiles array */
        let trajectory = calculateObjectMovingDirection( from: anchor, to: anchor )
        let movingObject = MovingObject (
            object: createdObject,
            anchor: anchor,
            direction: trajectory,
            id: self.counter
        )
        projectiles.append( movingObject )
        self.counter += 1
        
        sendMessage (
            to: DefaultString.signatureOfCanvasForMediator,
            MessageFormat (
                contentName: DefaultString.shootingEngineSpawnNewProjectile,
                messageContent: movingObject
            ),
            sendersSignature: self.signature
        )
        
        /* automate object's despawn rule */
        despawnObject(targetAnchor: anchor)
    }
    
    override func calculateObjectMovingDirection ( from: AnchorEntity, to: AnchorEntity ) -> SIMD3<Float> {    
        let directionVectorToCamerasFront = self.manager!.getCameraFrontDirectionVector()
        
        /* inaccuracy makes projectile go either left or right */
        let inaccuracyFactor = Float.random (  
            in: GameConfigs.friendlyProjectileInaccuracy,
            using: &GameConfigs.rng1
        )
        
        /* inaccuracy also makes projectile go either up or down */
        let recoil = Float.random (  
            in: -1...1,
            using: &GameConfigs.rng2 
        )
        
        /* inaccuracy leads to the projectile being amiss by a few degrees */
        let angle = (Float.pi / inaccuracyFactor) * recoil

        /* determine the projectile's moving direction based on the inaccuracy */
        let movingDirection = self.manager!.rotateVetor (
            initialVector: directionVectorToCamerasFront,
            angleInDegrees: angle,
            axis: .yaw
        ) * -1 /* multiply by -1 to send the projectiles into the screen; not to your (the user's) direction  */
        
        return movingDirection
    }
    
    override func updateObjectPosition(frame: ARFrame) {
        for projectile in projectiles {
            let projectileCurrentPosition = projectile.anchor.position(relativeTo: nil)
            let projectedPositionModifier = projectile.direction * self.projectileSpeed

            var projectedPosition = projectileCurrentPosition + projectedPositionModifier
            projectedPosition.y -= projectile.gravityEf

            projectile.anchor.setPosition(projectedPosition, relativeTo: nil)
            projectile.gravityEf += projectile.gravityEf * GameConfigs.projectileGravityParabolicMultiplier

            for buffPosition in buffPositions {
                if ( length( buffPosition - projectile.anchor.position) <= GameConfigs.buffBoxesHitboxRadius ) {
                    sendMessage(
                        to: DefaultString.signatureOfTargetEngineForMediator, 
                        "kena buff di posisi \(projectile.anchor.position)", 
                        sendersSignature: self.signature
                    )
                }
            }
            
            // Detect collision with HomingEngine's turret
//            let distanceFromTurret = length(projectedPosition - self.homingEngineInstance!.turret.position)
//            let thisProjectileHasHitTheTurretAndThusShouldNotReduceItsHealthAnymore = self.homingEngineInstance!.turret.nullifiedProjectile.contains(where: {
//                return $0.id == projectile.id
//            })            
//            if ( distanceFromTurret <= GameConfigs.hostileHitboxRadius && thisProjectileHasHitTheTurretAndThusShouldNotReduceItsHealthAnymore == false ) {
//                self.homingEngineInstance?.turret.nullifiedProjectile.append(projectile)
//                if ( self.homingEngineInstance!.turret.health > 0 ) {
//                    self.homingEngineInstance!.turret.health -= 1
//                }
//            }
//            
//            // Deteksi kollision dengan setiap box dari TargetEngine
//            self.targetEngineInstance!.targetObjects.forEach({ target in
//                let anchor = target.boxAnchor
//                if ( length(anchor.position(relativeTo: nil) - projectedPosition) < GameConfigs.buffBoxesHitboxRadius ) {
//                    self.manager?.scene.removeAnchor(anchor)
//                    
//                    self.targetEngineInstance!.targetObjects.removeAll{
//                        $0.boxAnchor == anchor
//                    }
//                }
//            })
//        }
//        
//        // Deteksi collision camera dengan HomingEngine
//        for projectile in homingEngineInstance!.projectiles {
//            let projectileCurrentPosition = projectile.anchor.position(relativeTo: nil)
//            let projectedPositionModifier = projectile.direction * self.projectileSpeed
//            
//            let projectedPosition         = projectileCurrentPosition + projectedPositionModifier
//            
//            projectile.anchor.setPosition(projectedPosition, relativeTo: nil)
//
//            let cameraTransform = frame.camera.transform
//            let cameraPosition  = SIMD3<Float> (
//                cameraTransform.columns.3.x,
//                cameraTransform.columns.3.y,
//                cameraTransform.columns.3.z
//            )
//            
//            let distanceFromCamera = length(cameraPosition - projectedPosition)
//            
//            if ( homingEngineInstance!.detectCollisionWithCamera( objectInQuestion: projectile, distance: distanceFromCamera) ) {
//                handleCollisionWithCamera(objectResponsible: projectile)
//            }
        }
    }
    
    override func handleCollisionWithCamera ( objectResponsible: Engine.MovingObject ) {
        if (self.health > 0){
            self.health -= 1
            
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
        }
    }
}

