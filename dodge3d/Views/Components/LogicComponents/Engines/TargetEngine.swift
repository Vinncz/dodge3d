import ARKit
import RealityKit
import SwiftUI

@Observable class TargetEngine: Engine {
    struct MessageFormat {
        var contentName: String
        var messageContent: Any
    }
    
    override init( signature: String = DefaultString.signatureOfTargetEngineForMediator, mediator: Mediator? = nil ) {
        super.init()
        
        self.signature = signature
        self.mediator = mediator
    }
    
    override func receiveMessage ( _ message: Any, sendersSignature from: String? ) {
        switch ( from ) {
            case DefaultString.signatureOfShootingEngineForMediator:
                print (message)
                break
            case DefaultString.signatureOfPlayerForMediator:
                break
            case DefaultString.signatureOfTargetEngineForMediator:
                break
            default:
                handleDebug(message: "A message was not captured by \(self.signature)")
        }
    }
    
    var instanceCount = 0
    var targetObjects: [TargetObject] = []
    
    class TargetObject {
        var boxAnchor: AnchorEntity
        var buff: Int
        //1 -> buff ammo
        //2 -> buff ...
        
        init (boxAnchor: AnchorEntity, buff: Int){
            self.boxAnchor = boxAnchor
            self.buff = buff
        }
    }
    
    private func randomPositionInFrontOfCamera() -> SIMD3<Float> {
//        let cameraTransform = self.manager!.cameraTransform
        
        let randomToTheRightOrLeft = Float.random(in: -(Float.pi/2)...(Float.pi/2))
        let randomToTheFront = Float.random(in: 4...6) * -1
        let spawnPosition = self.manager!.getPositionRelativeToCamera(distanceToCamera: randomToTheFront, angleInDegrees: self.manager!.convertDegreesToRadians(randomToTheRightOrLeft))
        
        let camerasFront = manager!.getCameraFrontDirectionVector()
        var rotatedVector = manager!.rotateVetor(initialVector: camerasFront, angleInDegrees: randomToTheRightOrLeft, axis: .yaw)
        rotatedVector = manager!.rotateVetor(initialVector: rotatedVector, angleInDegrees: randomToTheRightOrLeft, axis: .pitch)
        rotatedVector.z += randomToTheFront
        
//        let randomDistance = Float.random(in: 1.5...3.0) // Jarak acak dari kamera
//        let randomAngle = Float.random(in: -Float.pi...Float.pi) // Sudut acak
//        
//        let randomOffset = SIMD3<Float>(cos(randomAngle), 0, sin(randomAngle)) * randomDistance
//        let randomPosition = cameraTransform.translation + randomOffset
        
//        return randomPosition
//        print(rotatedVector)
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
                    contentName: DefaultString.targetEngineNewBuff, 
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
