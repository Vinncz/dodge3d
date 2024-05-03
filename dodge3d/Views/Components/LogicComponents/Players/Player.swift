class Player : Colleague {
    var signature: String = "Player"
    var mediator: Mediator?
    
    init ( signature: String = DefaultString.signatureOfPlayerForMediator, mediator: Mediator? = nil ) {
        self.signature = signature
        self.mediator  = mediator
    }
    
    func receiveMessage ( _ message: Any, sendersSignature from: String? ) {
        switch ( from ) {
            case DefaultString.signatureOfShootingEngineForMediator:
                break
            case DefaultString.signatureOfPlayerForMediator:
                break
            case DefaultString.signatureOfBuffEngineForMediator:
                break
            default:
                print("A message was not captured by \(self.signature)")
        }
    }
    
    
}
