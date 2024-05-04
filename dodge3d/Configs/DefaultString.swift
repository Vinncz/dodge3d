import Foundation
import SwiftUI

struct DefaultString {
    
    static let signatureOfBaseEngineForMediator    : String = "BaseEngineDefaultIdentifierForMediator"
    static let signatureOfShootingEngineForMediator: String = "ShootingEngineDefaultIdentifierForMediator"
    static let signatureOfHomingEngineForMediator  : String = "HomingEngineDefaultIdentifierForMediator"
    static let signatureOfBuffEngineForMediator    : String = "BuffEngineDefaultIdentifierForMediator"
    static let signatureOfPlayerForMediator        : String = "PlayerDefaultIdentifierForMediator"
    static let signatureOfCanvasForMediator        : String = "CanvasDefaultIdentifierForMediator"
    
    static let shootingEngineHasHitBuffBox         : String = "ShootingEngineHasHitBuffBox"
    static let shootingEngineHasHitHostileTurret   : String = "ShootingEngineHasHitHostileTurret"
    static let shootingEngineSpawnNewProjectile    : String = "ShootingEngineHasSpawnedNewProjectile"
    static let shootingEnginHasGoneReloading       : String = "ShootingEngineHasGoneReloading"
    static let shootingEnginHasFinishedReloading   : String = "ShootingEngineHasFinishedReloading"
    
    static let homingEngineNewTurretPosition       : String = "HomingEngineHasMovedItsTurret"
    static let homingEngineHasHitPlayer            : String = "HomingEngineHasHitPlayer"
    
    static let playerNewPosition                   : String = "PlayerHasMoved"
    static let playerUpdatedHealth                 : String = "PlayerHasUpdatedHealth"
    static let playerHealthRegenerate              : String = "PlayerHasRegeneratedTheirHealth"
    
    static let buffEngineNewBuff                   : String = "BuffEngineHasSpawnedNewBuff"
    static let buffEngineGrantsNewBuff             : String = "BuffEngineHasGrantedBuff"
    
}
