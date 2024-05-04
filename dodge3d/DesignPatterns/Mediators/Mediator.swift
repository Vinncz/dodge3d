struct AnyColleague: Hashable {
    let base: Colleague

    init ( _ base: Colleague ) {
        self.base = base
    }

    static func == ( lhs: AnyColleague, rhs: AnyColleague ) -> Bool {
        return lhs.base.signature == rhs.base.signature
    }

    func hash ( into hasher: inout Hasher ) {
        hasher.combine(base.signature)
    }
}

protocol Colleague: AnyObject {
    var signature : String    { get set }
    var mediator  : Mediator? { get set }
    
    func setupMediator  ( _ newMediator: Mediator, signature: String )
    func sendMessage    ( to recipient: String, _ message: Any, sendersSignature from: String? )
    func receiveMessage ( _ message: Any, sendersSignature from: String? )
}

extension Colleague {
    func setupMediator ( _ newMediator: Mediator, signature: String ) {
        self.mediator  = newMediator
        self.signature = signature
    }
    
    func sendMessage ( to recipient: String, _ message: Any, sendersSignature from: String? = nil ) {
        if ( GameConfigs.debug ) { print("\(recipient) will recieve a message: \(message); from: \(String(describing: from))") }
        self.mediator?.forwardMessage(to: recipient, message, sendersSignature: from)
    }
}

class Mediator {
    private let identifier: String
    private var colleagues: Set<AnyColleague> = []
    
    init ( identifier: String = "Mediator" ) {
        self.identifier = identifier
    }
    
    func add ( _ newColleague: Colleague ) {
        self.colleagues.insert( AnyColleague(newColleague) )
    }
    
    func add ( _ newColleagues: [Colleague] ) {
        self.colleagues.formUnion( newColleagues.map(AnyColleague.init) )
    }
    
    func broadcastMessage ( message: Any ) {
        for colleague in self.colleagues {
            colleague.base.receiveMessage(message, sendersSignature: "mediator")
        }
    }
    
    func forwardMessage ( to recipientSignature: String, _ message: Any, sendersSignature: String? = nil ) {
        for colleague in self.colleagues {
            guard ( colleague.base.signature == recipientSignature ) else { continue }
            colleague.base.receiveMessage(message, sendersSignature: sendersSignature)
        }
    }
    
    func forwardMessage ( to recipientSignatures: Set<String>, _ message: Any, sendersSignature: String? = nil ) {
        for colleague in colleagues {
            if ( recipientSignatures.contains( colleague.base.signature ) ) {
                colleague.base.receiveMessage(message, sendersSignature: sendersSignature)
            }
        }
    }
    
    func listColleagues ( ) {
        self.colleagues.forEach { c in
            print(c.base.signature)
        }
    }
}
