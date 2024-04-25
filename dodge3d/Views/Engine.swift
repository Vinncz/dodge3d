import SwiftUI
import ARKit
import RealityKit

@Observable class Engine {
    var manager: ARView?
    var projectiles: [MovingObject] = []
    let projectileSpeed:Float = GameConfigs.projectileSpeed
    var timer: Timer?
    
    struct MovingObject {
        var anchor   : AnchorEntity
        var direction: SIMD3<Float>
    }
    
    func setup                     ( manager: ARView ) { self.manager = manager }
    func spawnObject               ( ) {}
    func despawnObject             ( targetAnchor: AnchorEntity ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConfigs.despawnDelay) {
            self.manager!.scene.removeAnchor(targetAnchor)
            self.projectiles.removeAll { $0.anchor == targetAnchor }
        }
    }
    func updateObjectPosition      ( frame  : ARFrame ) {}
    func calculateObjectTrajectory ( ) -> SIMD3<Float> {
        return SIMD3<Float>(x: 0, y: 0, z: 0) 
    }
    func createObject              ( ) -> ModelEntity {
        let object = ModelEntity(mesh: .generateSphere(radius: GameConfigs.defaultSphereRadius), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        object.generateCollisionShapes(recursive: true)
        object.physicsBody?.mode = .dynamic
        
        return object
    }
    func detectCollisionWithCamera ( objectInQuestion object: MovingObject, distance distanceFromCamera: Float ) {}
    func handleCollisionWithCamera ( objectResponsible: MovingObject ) {}
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
    override func spawnObject ( ) {
        var anchor = AnchorEntity(world: self.manager!.cameraTransform.translation)
        if let cameraTransform = self.manager!.session.currentFrame?.camera.transform {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = GameConfigs.spawnDistance  // The object will appear 2 meters in the direction the camera is facing
            let modifiedTransform = simd_mul(cameraTransform, translation)
            let position = SIMD3<Float>(modifiedTransform.columns.3.x, modifiedTransform.columns.3.y, modifiedTransform.columns.3.z)
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
        let cameraForwardDirection = SIMD3<Float>(x: cameraTransform.matrix.columns.2.x, y: cameraTransform.matrix.columns.2.y, z: cameraTransform.matrix.columns.2.z)
        
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
            detectCollisionWithCamera( objectInQuestion: projectile, distance: distanceFromCamera)
        }
    }
    
    override func detectCollisionWithCamera ( objectInQuestion object: MovingObject, distance distanceFromCamera: Float ) {
        if ( distanceFromCamera < GameConfigs.defaultSphereRadius ) {
            handleCollisionWithCamera(objectResponsible: object)
        }
    }
    
    override func handleCollisionWithCamera(objectResponsible: Engine.MovingObject) {
        print("kena kamera nih!")
    }
}

