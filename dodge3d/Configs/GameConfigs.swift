import Foundation

struct GameConfigs {
    
    /** The time taken between rendering projectile to the screen  */
    static let summonDelay: TimeInterval = 0.2
    static let despawnDelay: Double = 2.5
    static let projectileSpeed: Float = 0.05
    static let projectileRandomnessMultiplier: Float = 0.01
    static let projectileRandomnessSpecifier: Float = Float.pi / 8
    
    static let spawnDistance: Float = -2.5
    
    static let defaultSphereRadius: Float = 0.05
    
    static let projectileScreenOffsetY: Float = 0.1
    static let projectileScreenOffsetZ: Float = 0.3
    
}
