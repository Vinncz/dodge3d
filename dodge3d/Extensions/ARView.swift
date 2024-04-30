import RealityKit

extension ARView {
    
    enum RotationAxis {
        case yaw
        case pitch
        case roll
        case all
    }
    
    /** Converts a degree to radian. */
    func convertDegreesToRadians ( _ angleInDegrees: Float ) -> Float {
        return angleInDegrees * Float.pi / 180
    }
    
    /** Converts a radian to degree. */
    func convertRadiansToDegrees ( _ angleInRadians: Float ) -> Float {
        return angleInRadians * 180 / Float.pi
    }
    
    /** Retrieves camera's current x, y, and z position in 3D space. */
    func getCameraPosition ( ) -> SIMD3<Float> {
        return self.cameraTransform.translation
    }
   
    /** Retrieves camera's current x position in 3D space. */
    func getCameraHorizontalPosition ( ) -> Float {
        return self.cameraTransform.matrix.columns.3.x
    }
    
    /** Retrieves camera's current y position in 3D space. */
    func getCameraVerticalPosition ( ) -> Float {
        return self.cameraTransform.matrix.columns.3.y
    }
    
    /** Retrieves camera's current z position in 3D space. */
    func getCameraDepthPosition ( ) -> Float {
        return self.cameraTransform.matrix.columns.3.z
    }
    
    /** Retrieves a vector which points to the right of where the camera is currently facing.
        
    The following illustrations will be using the pov of the y-axis, looking straight down, in the world of 3 dimensions.
    
    North (negative z-axis) is up.
    
    Say, if the camera is pointing the following direction:
     
     \   /
      \ /
       O
     
    Then its right direction vector would look something like:
     
     \   /
      \ /
       O -------->
     */
    func getCameraRightDirectionVector ( ) -> SIMD3<Float> {
        return SIMD3<Float> (
            x: self.cameraTransform.matrix.columns.0.x,
            y: self.cameraTransform.matrix.columns.0.y,
            z: self.cameraTransform.matrix.columns.0.z
        )
    }
    
    /** Retrieves a vector which points to up above, of where the camera is currently facing.
        
    The following illustrations will be using the pov of the x-axis, looking into the negative z-axis, in the world of 3 dimensions.
    
    North (negative z-axis) is into the screen.
    
    Say, if the camera is pointing the following direction:
     
     - - O - -
     
    Then its up direction vector would look something like:
     
         ▲
         |
         |
     - - O - -
     */
    func getCameraUpDirectionVector ( ) -> SIMD3<Float> {
        return SIMD3<Float> (
            x: self.cameraTransform.matrix.columns.1.x,
            y: self.cameraTransform.matrix.columns.1.y,
            z: self.cameraTransform.matrix.columns.1.z
        )
    }
    
    /** Retrieves a vector which points to the front of where the camera is currently facing.
        
    The following illustrations will be using the pov of the y-axis, looking straight down, in the world of 3 dimensions
    
    North (negative z-axis) is up.
     
    Say, if the camera is pointing the following direction:
     
     \   /
      \ /
       O
     
    Then its front direction vector would look something like:
     
       ▲
       |
     \ | /
      \|/
       O
     */
    func getCameraFrontDirectionVector ( ) -> SIMD3<Float> {
        return SIMD3<Float> (
            x: self.cameraTransform.matrix.columns.2.x,
            y: self.cameraTransform.matrix.columns.2.y,
            z: self.cameraTransform.matrix.columns.2.z
        )
    }
    
    /** Calculates in 3D space, relative to the camera, where the final position will be -- given the distances along the x (horizontal), y (vertical), and z (depth) axes. */
    func getPositionRelativeToCamera ( x unitToRight: Float, y unitToAbove: Float, z unitToFront: Float ) -> SIMD3<Float> {
        let                            cameraTransform = self.cameraTransform
        let                      cameraCurrentPosition = cameraTransform.translation
        
        let                 cameraRightDirectionVector = getCameraRightDirectionVector()
        let                    cameraUpDirectionVector = getCameraUpDirectionVector()
        let                 cameraFrontDirectionVector = getCameraFrontDirectionVector()
        
        let              newPositionToTheRightOfCamera = cameraCurrentPosition              + unitToRight * cameraRightDirectionVector
        let         newPositionToTheRightAndUpOfCamera = newPositionToTheRightOfCamera      + unitToAbove * cameraUpDirectionVector
        let newPositionToTheRightAndUpAndFrontOfCamera = newPositionToTheRightAndUpOfCamera + unitToFront * cameraFrontDirectionVector
        
        return newPositionToTheRightAndUpAndFrontOfCamera
    }
    
    /** Calculates in 3D space, relative to the camera, where the final position will be -- given the distance-towards-camera, along with the angle (in degrees) from where the camera is currently pointing. */
    func getPositionRelativeToCamera ( distanceToCamera: Float, angleInDegrees: Float ) -> SIMD3<Float> {
        let       cameraTransform = self.cameraTransform
        let cameraCurrentPosition = cameraTransform.translation
        let  cameraFrontDirection = getCameraFrontDirectionVector()
        
        let directionVectorToWhereTheSpawnPointWillBe = rotateVetor (
            initialVector: cameraFrontDirection,
            angleInDegrees: angleInDegrees,
            axis: .all
        )
        
        let         spawnPosition = cameraCurrentPosition + distanceToCamera * directionVectorToWhereTheSpawnPointWillBe
        
        return spawnPosition
    }
    
    /** Rotates the vector given to it, by the supplied degree. You can choose any variant of the rotation: whether it is yaw, pitch, or roll. Defaults to yaw, due to how coomonly used it is. */
    func rotateVetor ( initialVector: SIMD3<Float>, angleInDegrees: Float, axis: RotationAxis = .yaw ) -> SIMD3<Float> {
        let sinResult = sin(angleInDegrees)
        let cosResult = cos(angleInDegrees)
        
        switch axis {
            case .yaw:
                return SIMD3<Float>(
                    x: cosResult * initialVector.x - sinResult * initialVector.z,
                    y: initialVector.y,
                    z: sinResult * initialVector.x + cosResult * initialVector.z
                )
            case .pitch:
                return SIMD3<Float>(
                    x: initialVector.x,
                    y: cosResult * initialVector.y - sinResult * initialVector.z,
                    z: sinResult * initialVector.y + cosResult * initialVector.z
                )
            case .roll:
                return SIMD3<Float>(
                    x: cosResult * initialVector.x - sinResult * initialVector.y,
                    y: sinResult * initialVector.x + cosResult * initialVector.y,
                    z: initialVector.z
                )
            case .all:
                return rotateVectorAllAxes (
                    initialVector: initialVector, 
                    angleInDegrees: angleInDegrees
                )
        }
    }
    
    /** You cannot call recursively to a function upon the time it is being declared. Therefore this function was written to help circumvent the restriction. */
    fileprivate func rotateVectorAllAxes ( initialVector: SIMD3<Float>, angleInDegrees: Float ) -> SIMD3<Float> {
        let yawedVector = rotateVetor (
            initialVector: initialVector, 
            angleInDegrees: angleInDegrees, 
            axis: .yaw
        )
        let pitchedAndYawedVector = rotateVetor (
            initialVector: yawedVector, 
            angleInDegrees: angleInDegrees, 
            axis: .pitch
        )
        let rolledAndPitchedAndYawedVector = rotateVetor (
            initialVector: pitchedAndYawedVector, 
            angleInDegrees: angleInDegrees, 
            axis: .roll
        )
        
        return rolledAndPitchedAndYawedVector
    }
     
}
