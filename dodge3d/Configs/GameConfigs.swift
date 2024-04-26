import Foundation

struct GameConfigs {
    
    /** Determines whether your app should print debug information to console */
    static let debug: Bool = false
    
    /** The time taken between rendering projectile to the screen  */
    static let summonDelay: TimeInterval = 0.2
    static let despawnDelay: Double = 3
    static let projectileSpeed: Float = 0.05
    static let projectileRandomnessMultiplier: Float = 0.01
    static let projectileRandomnessSpecifier: Float = Float.pi / 8
    
    static let spawnDistance: Float = -2.5
    
    static let defaultSphereRadius: Float = 0.05
    
    static let projectileScreenOffsetX: Float = 0
    static let projectileScreenOffsetY: Float = 0.125
    static let projectileScreenOffsetZ: Float = 0.05
    
    static let defaultCollisionRadius: Float = 0.05
    
    static let maxTargetCount: Int = 5
    
}
