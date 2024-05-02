import Foundation
import SwiftUI

struct GameConfigs {
    
    static var rng1: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng2: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng3: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng4: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    
    /** Determines whether your app: should print the debug informations to console */
    static let debug: Bool = false
    
    /** Variable which controls how frequent does a projectile should be spawned  */
    static let spawnDelay: TimeInterval = 0.3
    /** Variable which controls how long should it take before a projectile self-despawn  */
    static let despawnDelay: Double = 3
    
    /** Variable which controls how many health does a player has */
    static let playerHealth: Int = 10
    /** Variable which controls how many health does a hostile turret has */
    static let hostileTurretHealth: Int = 16
    /** Variable which controls how many ammo can a player shoot, before having to reload for a specified amount of time */
    static let playerAmmoCapacity: Int = 8
    /** Variable which controls how many ammo can a hostile turret shoot, before having to reload for a specified amount of time */
    static let hostileAmmoCapacity: Int = 16
    /** Variable which controls how long does a player must wait before firing the next salvo of projectiles */
    static let playerReloadDuration: TimeInterval = 1
    /** Variable which controls how long does a hostile turret must wait before firing the next salvo of projectiles */
    static let hostileReloadDuration: TimeInterval = 2
    /** Variable which controls how near does a friendly projectile should be, to be treated as a hit -- which will reduce the turret's health */
    static let hostileHitboxRadius: Float = 0.5
    
    /** Variable which controls how fast projectiles should move */
    static let defaultProjectileSpeed: Float = 0.05
    /** Variable which controls how fast projectiles of enemy-allegiance are moving */
    static let hostileProjectileSpeed: Float  = 0.1
    /** Variable which controls how fast projectiles of your allegiance are moving */
    static let friendlyProjectileSpeed: Float = 0.05
    
    /** Variable which controls how accurate your shooting are */
    static let friendlyProjectileInaccuracy: ClosedRange<Float> = 96...128 // the least accurate being 1 ÷ 96 and the most accurate being 1 ÷ 128
    /** Variable which controls how accurate your enemies shooting are */
    static let hostileProjectileInaccuracy : ClosedRange<Float> = 72...96
    
    /** Variable which is used by LegacyHomingEngine. It controls how far away, from camera, should a projectile spawn at */
    static let homingSpawnDistance: Float = -5
    /** Variable which controls where the turret will spawn initially */
    static let hostileTurretInitialSpawnPosition: SIMD3<Float> = [0, -2, -6]
    
    /** Variable which controls how near does a friendly projectile should be, to be treated as a hit -- which will then give some buffs to the shooter */
    static let buffBoxesHitboxRadius: Float = 1  
    
    /** Variable which controls how large a default projectile should be. Default projectile use the ModelEntity of Sphere -- thus this variable will be used. */
    static let defaultSphereRadius : Float = 0.05
    /** Variable which controls how large does a friendly projectile will be, when spawned */
    static let friendlySpehreRadius: Float = 0.025
    /** Variable which controls how large does a hostile projectile will be, when spawned */
    static let hostileSphereRadius : Float = 0.75
    
    /** Variable which controls how strong the initial gravity is */
    static let projectileGravityInitialStrength: Float = 0.0025
    /** Variable which controls how parabolic will a trajectory be, given the initial gravity are not zero */
    static let projectileGravityParabolicMultiplier: Float = 0.01
    
    static let friendlyProjectileSpawnDistance: Float = -0.5
    static let friendlyProjectileScreenOffsetX: Float = 0.2
    static let friendlyProjectileScreenOffsetY: Float = -0.125
    static let friendlyProjectileScreenOffsetZ: Float = -0.25
    
    /** DEPRECATED -- Variable which controls how close does a projectile should be, to be treated as a hit */
    static let defaultCollisionRadius: Float = 0.1
    
    /** Variable which controls how many buff boxes can spawn at a time */
    static let maxTargetCount: Int = 5
    
    static var neonBlue: Color = Color(red: 0.38, green: 0.86, blue: 0.96)
    static var neonPink: Color = Color(red: 1.0, green: 0.0, blue: 0.67)
    
}
