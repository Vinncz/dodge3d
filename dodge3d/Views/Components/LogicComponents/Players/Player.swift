import SwiftUI

@Observable class Player : Colleague {
    var signature: String
    var mediator: Mediator?
    
    init ( signature: String = DefaultString.signatureOfPlayerForMediator, mediator: Mediator? = nil ) {
        self.signature = signature
        self.mediator  = mediator
        
        sendMessage (
            to: DefaultString.signatureOfShootingEngineForMediator,
            MessageFormat (
                contentName: DefaultString.playerUpdatedHealth, 
                messageContent: self.health
            ),
            sendersSignature: self.signature
        )
    }
    
    struct MessageFormat {
        var contentName: String
        var messageContent: Any
    }
    
    var health : Int = GameConfigs.playerHealth
    
    func receiveMessage ( _ message: Any, sendersSignature from: String? ) {
        switch ( from ) {
            case DefaultString.signatureOfCanvasForMediator:
                let msg = message as! CanvasRepresentator.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.playerHealthRegenerate:
                        self.health += (msg.messageContent as! Int)
                        break
                        
                    default:
                        break
                }
                break
                
            case DefaultString.signatureOfHomingEngineForMediator:
                let msg = message as! HomingEngine.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.homingEngineHasHitPlayer:
                        guard ( health > 0 ) else { return }
                        health -= 1
                        
                        /* tell the ShootingEngine of the current player's hp */
                        sendMessage (
                            to: DefaultString.signatureOfShootingEngineForMediator,
                            MessageFormat (
                                contentName: DefaultString.playerUpdatedHealth, 
                                messageContent: self.health
                            ),
                            sendersSignature: self.signature
                        )
                        
                        /* tell the canvas of the current player's hp */
                        sendMessage (
                            to: DefaultString.signatureOfCanvasForMediator,
                            MessageFormat (
                                contentName: DefaultString.playerUpdatedHealth, 
                                messageContent: self.health
                            ),
                            sendersSignature: self.signature
                        )
                        break
                        
                    default:
                        break
                }
                break
            default:
                print("A message was not captured by \(self.signature)")
        }
    }
    
    
}
