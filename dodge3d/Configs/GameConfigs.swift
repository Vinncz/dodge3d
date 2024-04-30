import Foundation
import SwiftUI

struct GameConfigs {
    
    static var rng1: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng2: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng3: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng4: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    
    /** Determines whether your app should print debug information to console */
    static let debug: Bool = false
    
    /** Variable which controls how frequent a projectile should be spawned  */
    static let spawnDelay: TimeInterval = 0.4
    /** Variable which controls how long should it take before a projectile self-despawn  */
    static let despawnDelay: Double = 3
    
    static let hostileTurretHealth: Int = 63
    static let hostileAmmoCapacity: Int = 30
    static let hostileReloadDuration: TimeInterval = 4
    
    /** Variable which controls how fast projectiles should move */
    static let defaultProjectileSpeed: Float = 0.05
    /** Variable which controls how fast projectiles of enemy-allegiance are moving */
    static let hostileProjectileSpeed: Float  = 0.075
    /** Variable which controls how fast projectiles of your allegiance are moving */
    static let friendlyProjectileSpeed: Float = 0.05
    
    /** Variable which controls how accurate your shooting are */
    static let friendlyProjectileInaccuracy: ClosedRange<Float> = 96...128 // the least accurate being 1 ÷ 96 and the most accurate being 1 ÷ 128
    /** Variable which controls how accurate your enemies shooting are */
    static let hostileProjectileInaccuracy : ClosedRange<Float> = 48...72
    
    /** Variable which is used by LegacyHomingEngine. It controls how far away, from camera, should a projectile spawn at */
    static let homingSpawnDistance: Float = -5
    
    /** Variable which controls how large a default projectile should be. Default projectile use the ModelEntity of Sphere -- thus this variable will be used. */
    static let defaultSphereRadius: Float = 0.05
    
    static let friendlySpehreRadius: Float = 0.025
    static let hostileSphereRadius : Float = 0.75
    
    static let projectileGravityInitialStrength: Float = 0.0025
    static let projectileGravityParabolicMultiplier: Float = 0.01
    
    static let friendlyProjectileSpawnDistance: Float = -0.5
    static let friendlyProjectileScreenOffsetX: Float = 0.2
    static let friendlyProjectileScreenOffsetY: Float = -0.125
    static let friendlyProjectileScreenOffsetZ: Float = -1
    
    static let defaultCollisionRadius: Float = 0.05
    
    static let maxTargetCount: Int = 5
    
    static var neonBlue: Color = Color(red: 0.38, green: 0.86, blue: 0.96)
    static var neonPink: Color = Color(red: 1.0, green: 0.0, blue: 0.67)
    
}
