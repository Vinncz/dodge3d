import ARKit
import RealityKit
import SwiftUI

@Observable class ShootingEngine: Engine {
    var projectileSpeed = GameConfigs.projectileSpeed
    
    var ammoCapacity: Int
    var reloadTime  : TimeInterval
    
    var isReloading : Bool = false
    var usedAmmo    : Int = 0
    
    init ( ammoCapacity: Int, reloadTimeInSeconds: TimeInterval ) {
        self.ammoCapacity = ammoCapacity
        self.reloadTime = reloadTimeInSeconds
    }
    
    func reload ( ) {
        isReloading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + reloadTime) {
            self.isReloading = false
            self.usedAmmo = 0
        }
    }
    
    override func createObject ( ) -> ModelEntity {
        let object = ModelEntity(mesh: .generateSphere(radius: GameConfigs.defaultSphereRadius / 2), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
        object.generateCollisionShapes(recursive: true)
      
        return object
    }
    
    override func spawnObject ( ) {
        guard !isReloading else { return }
        guard usedAmmo < ammoCapacity else {
            return
        }
        
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
        usedAmmo += 1
        anchor.addChild(createdObject)
        
        /* make sure to make your anchor visible */
        self.manager!.scene.addAnchor(anchor)
        
        /* determine where your object will be heading to, and append it to the projectiles array */
        let trajectory = calculateObjectMovingDirection( from: anchor, to: anchor )
        projectiles.append (
            MovingObject (
                object: createdObject,
                anchor: anchor,
                direction: trajectory
            )
        )
        
        /* automate object's despawn rule */
        despawnObject(targetAnchor: anchor)
    }
    
    override func calculateObjectMovingDirection ( from: AnchorEntity, to: AnchorEntity ) -> SIMD3<Float> {    
        let directionVectorToCamerasFront = self.manager!.getCameraFrontDirectionVector()
        
        /* makes projectile go either left or right */
        let inaccuracyFactor = Float.random (  
            in: GameConfigs.friendlyProjectileInaccuracy,
            using: &GameConfigs.rng1
        )
        
        /* makes projectile go either up or down */
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
    
    override func updateObjectPosition ( frame: ARFrame ) {
        for projectile in projectiles {
            let projectileCurrentPosition = projectile.anchor.position(relativeTo: nil)
            let projectedPositionModifier = projectile.direction * self.projectileSpeed
            
            var projectedPosition         = projectileCurrentPosition + projectedPositionModifier
            projectedPosition.y          -= projectile.gravityEf
            
            projectile.anchor.setPosition(projectedPosition, relativeTo: nil)
            projectile.gravityEf += projectile.gravityEf * GameConfigs.projectileGravityParabolicMultiplier
        }
    }
}
