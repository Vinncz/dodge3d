import Foundation
import SwiftUI

struct DefaultString {
    
    static let signatureOfBaseEngineForMediator    : String = "BaseEngineDefaultIdentifierForMediator"
    static let signatureOfShootingEngineForMediator: String = "ShootingEngineDefaultIdentifierForMediator"
    static let signatureOfHomingEngineForMediator  : String = "HomingEngineDefaultIdentifierForMediator"
    static let signatureOfTargetEngineForMediator  : String = "TargetEngineDefaultIdentifierForMediator"
    static let signatureOfPlayerForMediator        : String = "PlayerDefaultIdentifierForMediator"
    static let signatureOfCanvasForMediator        : String = "CanvasDefaultIdentifierForMediator"
    
    static let shootingEngineSpawnNewProjectile    : String = "ShootingEngineHasSpawnedNewProjectile"
    static let shootingEnginHasGoneReloading       : String = "ShootingEngineHasGoneReloading"
    static let shootingEnginHasFinishedReloading   : String = "ShootingEngineHasFinishedReloading"
    
    static let homingEngineNewTurretPosition       : String = "HomingEngineHasMovedItsTurret"
    
    static let playerNewPosition                   : String = "PlayerHasMoved"
    
    static let targetEngineNewBuff                 : String = "TargetEngineHasSpawnedNewBuff"
    
}
