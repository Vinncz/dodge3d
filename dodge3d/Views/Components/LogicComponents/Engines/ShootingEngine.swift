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
                        self.turretPosition = (msg.messageContent as! SIMD3<Float>)
                        break
                        
                    default:
                        handleDebug(message: "A message was not captured by \(self.signature)")
                        break
                }
                
                break
                
            case DefaultString.signatureOfPlayerForMediator:
                let msg = message as! Player.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.playerNewPosition:
                        self.playerPosition = (msg.messageContent as! SIMD3<Float>)
                        break
                        
                    case DefaultString.playerUpdatedHealth:
                        self.health = (msg.messageContent as! Int)
                        break
                        
                    default:
                        handleDebug(message: "A message was not captured by \(self.signature)")
                        break
                }
                break
                
            case DefaultString.signatureOfBuffEngineForMediator:
                let msg = message as! BuffEngine.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.buffEngineNewBuff:
                        self.buffPositions.append(msg.messageContent as! SIMD3<Float>)
                        break
                        
                    case DefaultString.buffEngineGrantsNewBuff:
                        let buffObj = msg.messageContent as! BuffEngine.BuffObject
                        switch ( buffObj.buff ) {
                            case .increasedAmmoCapacity:
                                self.ammoCapacity += Int(buffObj.amount * buffObj.multiplier)
                                break
                            case .reducedReloadTime:
                                self.reloadTime += Double(buffObj.amount * buffObj.multiplier)
                                break
                            default:
                                break
                        }
                        
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
    
    var turretPosition   : SIMD3<Float>?  = nil
    var playerPosition   : SIMD3<Float>?  = nil
    var buffPositions    : [SIMD3<Float>] = []
    
    var projectileSpeed  : Float          = GameConfigs.friendlyProjectileSpeed
    var projectileRadius : Float          = GameConfigs.friendlySpehreRadius
    
    var health           : Int            = 10

    var state            : ShootingEngineState = .normal

    var ammoCapacity     : Int
    var reloadTime       : TimeInterval
    var usedAmmo         : Int = 0
        
    func reload ( ) {
        guard ( self.state != .reloading ) else { return }
        
        self.state = .reloading
        
        /* tell the canvas that: this engine is currently reloading, so the canvas can handle any visual changes that are needed */
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
            
            /* tell the canvas that: this engine is now locked and loaded */
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
        guard (  self.state == .normal  ) else { return } /* you cannot shoot if you have no ammo, or in the middle of reloading your gun */
        guard (        health > 0       ) else { return } /* you cannot shoot back if you're dead */
        guard ( usedAmmo < ammoCapacity ) else { return } /* you cannot shoot if your magazine is empty */
        
        let offsetX = GameConfigs.friendlyProjectileScreenOffsetX
        let offsetY = GameConfigs.friendlyProjectileScreenOffsetY
        let offsetZ = GameConfigs.friendlyProjectileScreenOffsetZ

        let spawnPosition = self.manager!.getPositionRelativeToCamera (
            x: offsetX, 
            y: offsetY, 
            z: offsetZ
        )
        
        /* set up the coordinate on where you could place an object to the world */
        let anchor = AnchorEntity(world: spawnPosition)
        
        /* place your object on the allocated coordinate */
        let createdObject = createObject()
        anchor.addChild(createdObject)
        
        /* ammo logic */
        usedAmmo += 1
        if ( self.usedAmmo >= self.ammoCapacity ) { self.state = .outOfAmmo }
        
        /* make sure to make your anchor visible */
        self.manager!.scene.addAnchor(anchor)
        
        /* 
         determine the travelling direction of your object, 
         and append it to the projectiles array.
         
         failure of doing so will result in:
             - your object being stuck in place
         */
        let trajectory = calculateObjectMovingDirection( from: anchor, to: anchor )
        let movingObject = MovingObject (
            object: createdObject,
            anchor: anchor,
            direction: trajectory,
            id: self.counter
        )
        projectiles.append( movingObject )
        self.counter += 1
        
        /* tell the canvas that this engine has spawned one more projectile into the screen */
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
    
    fileprivate func validateBuffBoxHit ( _ projectile: Engine.MovingObject ) {
        for buffPosition in buffPositions {
            if ( length( buffPosition - projectile.anchor.position) <= GameConfigs.buffBoxesHitboxRadius ) {
                
                /* immidiately despawn the projectile */
                despawnObject( targetAnchor: projectile.anchor, delayInSeconds: 0 )
                
                /* 
                 tell the BuffEngine that a projectile has hit a specified BuffBox.
                 
                 make sure to attach the BuffBox's position, so the engine knows which buff should it give to the player                     
                 */
                sendMessage(
                    to: DefaultString.signatureOfBuffEngineForMediator, 
                    MessageFormat (
                        contentName: DefaultString.shootingEngineHasHitBuffBox,
                        messageContent: buffPosition
                    ),
                    sendersSignature: self.signature
                )
                
                self.buffPositions.removeAll {
                    $0 == buffPosition
                }
                
            }
        }
    }
    
    fileprivate func validateTurretHit  ( _ computedDistanceFromTurret: Float, _ projectile: Engine.MovingObject ) {
        if ( computedDistanceFromTurret <= GameConfigs.hostileTurretHitboxRadius ) {
            
            /* tell the HomingEngine that its turret has taken a hit, and there's the need to reduce its healthpoints */
            sendMessage (
                to: DefaultString.signatureOfHomingEngineForMediator,
                MessageFormat (
                    contentName: DefaultString.shootingEngineHasHitHostileTurret,
                    messageContent: projectile
                ),
                sendersSignature: self.signature
            )
            
            /* immidiately despawn the object, before it might inflict anymore damage to the turret */
            despawnObject( targetAnchor: projectile.anchor, delayInSeconds: 0 )
            
        }
    }
    
    override func updateObjectPosition(frame: ARFrame) {
        for projectile in projectiles {
            let projectileCurrentPosition = projectile.anchor.position(relativeTo: nil)
            let projectedPositionModifier = projectile.direction * self.projectileSpeed

            var projectedPosition = projectileCurrentPosition + projectedPositionModifier
            projectedPosition.y -= projectile.gravityEf

            projectile.anchor.setPosition(projectedPosition, relativeTo: nil)
            projectile.gravityEf += projectile.gravityEf * GameConfigs.projectileGravityParabolicMultiplier

            /* check whether any of the ShootingEngine's projectile has hit a BuffBox */
            validateBuffBoxHit( projectile )
            
            /* 
             check whether the HomingEngine has placed a turret somewhere on the screen
             if there is no turret, simply continue
             */
            guard ( self.turretPosition != nil ) else { continue }
            /* if so, check whether any of the ShootingEngine's projectile has hit the turret */
//            let computedDistanceFromTurret = length( projectedPosition - turretPosition! )
            validateTurretHit( length( projectedPosition - turretPosition! ), projectile )
        }
    }
    
}

