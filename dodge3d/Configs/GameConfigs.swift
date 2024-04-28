import Foundation
import SwiftUI

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
    
    static let friendlyProjectileInaccuracy: ClosedRange<Float> = 96...128 // the least accurate being 1 ÷ 96 and the most accurate being 1 ÷ 128
    static let hostileProjectileInaccuracy : ClosedRange<Float> = 96...128 
    
    static let shootingSpawnDistance: Float = -0.5
    static let homingSpawnDistance: Float = -2.5
    
    static let defaultSphereRadius: Float = 0.05
    
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
