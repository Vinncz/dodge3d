import ARKit
import RealityKit
import SwiftUI
import Observation

@Observable class BuffEngine: Engine {
    enum Buff {
        case increasedAmmoCapacity
        case reducedReloadTime
        case healthRecovery
    }
    
    struct BuffObject {
        var buff       : Buff
        var amount     : Float
        var multiplier : Float
    }
    
    struct MessageFormat {
        var contentName: String
        var messageContent: Any
    }
    
    override init( signature: String = DefaultString.signatureOfBuffEngineForMediator, mediator: Mediator? = nil ) {
        super.init()
        
        self.signature = signature
        self.mediator = mediator
    }
    
    private func broadcastGivenBuff ( _ buffBox: BuffEngine.TargetObject ) {
        switch ( buffBox.buff ) {
            case 1:
                sendMessage (
                    to: DefaultString.signatureOfShootingEngineForMediator,
                    MessageFormat (
                        contentName: DefaultString.buffEngineGrantsNewBuff,
                        messageContent: BuffObject (
                            buff       : .increasedAmmoCapacity,
                            amount     : 3,
                            multiplier : 1
                        )
                    ),
                    sendersSignature: self.signature
                )
                break
                
            case 2:
                sendMessage (
                    to: DefaultString.signatureOfShootingEngineForMediator,
                    MessageFormat (
                        contentName: DefaultString.buffEngineGrantsNewBuff,
                        messageContent: BuffObject (
                            buff       : .reducedReloadTime,
                            amount     : -0.5,
                            multiplier : 1
                        )
                    ),
                    sendersSignature: self.signature
                )
                break
                
            case 3:
                sendMessage (
                    to: DefaultString.signatureOfCanvasForMediator,
                    MessageFormat (
                        contentName: DefaultString.buffEngineGrantsNewBuff,
                        messageContent: BuffObject (
                            buff       : .healthRecovery,
                            amount     : 1,
                            multiplier : 1
                        )
                    ),
                    sendersSignature: self.signature
                )
                break
                
            default:
                handleDebug(message: "BuffBox located at \(buffBox.boxAnchor.anchor!.position(relativeTo: nil)) does not seem to affect the player")
                break
        }
    }
    
    override func receiveMessage ( _ message: Any, sendersSignature from: String? ) {
        switch ( from ) {
            case DefaultString.signatureOfShootingEngineForMediator:
                let msg = message as! ShootingEngine.MessageFormat
                switch ( msg.contentName ) {
                    case DefaultString.shootingEngineHasHitBuffBox:
                        self.targetObjects.forEach {
                            if ( $0.boxAnchor.anchor!.position(relativeTo: nil) == (msg.messageContent as! SIMD3<Float>) ) {
                                broadcastGivenBuff($0)
                                
                                despawnObject(targetAnchor: $0.boxAnchor.anchor! as! AnchorEntity, delayInSeconds: 0)
                                
                                self.targetObjects.removeAll {
                                    $0.boxAnchor.anchor!.position(relativeTo: nil) == (msg.messageContent as! SIMD3<Float>)
                                }
                            }
                        }
                        
                        break
                                        
                    default:
                        break
                }
                
                break
            case DefaultString.signatureOfPlayerForMediator:
                break
            case DefaultString.signatureOfBuffEngineForMediator:
                break
            default:
                handleDebug(message: "A message was not captured by \(self.signature)")
        }
    }
    
    var instanceCount = 0
    var targetObjects: [TargetObject] = []
    
    @Observable class TargetObject {
        var boxAnchor: AnchorEntity
        var buff: Int
        
        init (boxAnchor: AnchorEntity, buff: Int){
            self.boxAnchor = boxAnchor
            self.buff = buff
        }
    }
    
    private func randomPositionInFrontOfCamera() -> SIMD3<Float> {
        let randomToTheRightOrLeft = Float.random(in: -(Float.pi / 2)...(Float.pi / 2))
        let randomToTheFront = Float.random(in: 4...6) * -1
        
        let camerasFront = manager!.getCameraFrontDirectionVector()
        var rotatedVector = manager!.rotateVetor(initialVector: camerasFront, angleInDegrees: randomToTheRightOrLeft, axis: .yaw)
        rotatedVector = manager!.rotateVetor(initialVector: rotatedVector, angleInDegrees: randomToTheRightOrLeft, axis: .pitch)
        rotatedVector.z += randomToTheFront

        return rotatedVector
    }
    
    func createBoxObject() -> ModelEntity {
        let object = try! ModelEntity.loadModel(named: "Gift_box")
        object.setScale([0.001, 0.001, 0.001], relativeTo: nil)
        
        object.generateCollisionShapes(recursive: true)
        object.physicsBody?.mode = .dynamic
        
        object.transform.translation.y -= 0.2
                
        return object
    }
    
    override func spawnObject() {
        let anchorPosition = randomPositionInFrontOfCamera()
        
        if ( self.instanceCount <= GameConfigs.maxTargetCount ) {
            sendMessage (
                to: DefaultString.signatureOfShootingEngineForMediator,
                MessageFormat (
                    contentName: DefaultString.buffEngineNewBuff, 
                    messageContent: anchorPosition
                ),
                sendersSignature: self.signature
            )
            let anchor = AnchorEntity(world: anchorPosition)
            anchor.addChild(createBoxObject())
            self.manager!.scene.addAnchor(anchor)
            
            self.instanceCount += 1
            
            let target = TargetObject(boxAnchor: anchor, buff: Int.random(in: 1...3))
            
            self.targetObjects.append(target)
        }
    }
    
    override func setup ( manager: ARView ) {
        self.manager = manager
        self.spawnObject()
        self.spawnObject()
        self.spawnObject()
    }
}
