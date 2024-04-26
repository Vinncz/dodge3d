import Foundation

struct GameConfigs {
    
    static var rng1: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng2: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng3: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    static var rng4: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    
    /** Determines whether your app should print debug information to console */
    static let debug: Bool = false
    
    /** The time taken between rendering projectile to the screen  */
    static let summonDelay: TimeInterval = 0.2
    static let despawnDelay: Double = 3
    static let projectileSpeed: Float = 0.05
    
    static let friendlyProjectileInaccuracy: ClosedRange<Float> = 96...128 
    static let hostileProjectileInaccuracy : ClosedRange<Float> = 96...128 
    
    static let shootingSpawnDistance: Float = -0.5
    static let homingSpawnDistance: Float = -2.5
    
    static let defaultSphereRadius: Float = 0.05
    
    static let friendlyProjectileScreenOffsetX: Float = 6 // in degrees
    static let friendlyProjectileScreenOffsetY: Float = 0.125 // in meters
    static let friendlyProjectileScreenOffsetZ: Float = 0 // in degrees
    
    static let defaultCollisionRadius: Float = 0.05
    
    static let maxTargetCount: Int = 5
    
}
