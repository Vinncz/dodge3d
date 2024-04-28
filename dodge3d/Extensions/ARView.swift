import RealityKit

extension ARView {
    
    /** Retrieves camera's current x position in 3D space */
    func getCameraHorizontalPosition () -> SIMD3<Float> {
        return SIMD3<Float> (
            x: self.cameraTransform.matrix.columns.0.x,
            y: self.cameraTransform.matrix.columns.0.y,
            z: self.cameraTransform.matrix.columns.0.z
        )
    }
    
    /** Retrieves camera's current y position in 3D space */
    func getCameraVerticalPosition () -> SIMD3<Float> {
        return SIMD3<Float> (
            x: self.cameraTransform.matrix.columns.1.x,
            y: self.cameraTransform.matrix.columns.1.y,
            z: self.cameraTransform.matrix.columns.1.z
        )
    }
    
    /** Retrieves camera's current z position in 3D space */
    func getCameraDepthPosition () -> SIMD3<Float> {
        return SIMD3<Float> (
            x: self.cameraTransform.matrix.columns.2.x,
            y: self.cameraTransform.matrix.columns.2.y,
            z: self.cameraTransform.matrix.columns.2.z
        )
    }
    
    /** Calculates in 3D space, relative to the camera, where the final position will be -- given the distances along the x (horizontal), y (vertical), and z (depth) axes */
    func getPositionRelativeToCamera ( x: Float, y: Float, z: Float ) -> SIMD3<Float> {
        let                       cameraTransform = self.cameraTransform
        let                     cameraTranslation = cameraTransform.translation
        
        let              cameraHorizontalPosition = getCameraHorizontalPosition()
        let                cameraVerticalPosition = getCameraVerticalPosition()
        let                   cameraDepthPosition = getCameraDepthPosition()
        
        let                    horizontalPosition = cameraTranslation + x * cameraHorizontalPosition
        let         verticalAndHorizontalPosition = horizontalPosition + y * cameraVerticalPosition
        let depthAndVerticalAndHorizontalPosition = verticalAndHorizontalPosition + z * cameraDepthPosition
        
        return depthAndVerticalAndHorizontalPosition
    }
    
    /** Converts a degree to radian */
    func convertDegreesToRadians ( _ angleInDegrees: Float ) -> Float {
        return angleInDegrees * Float.pi / 180
    }
    
    /** Converts a radian to degree */
    func convertRadiansToDegrees ( _ angleInRadians: Float ) -> Float {
        return angleInRadians * 180 / Float.pi
    }
    
    /** Calculates in 3D space, relative to the camera, where the final position will be -- given the distance-towards-camera, along with the angle (in degrees) from where the camera is currently pointing */
    func getPositionRelativeToCamera ( distanceToCamera: Float, angleInDegrees: Float ) -> SIMD3<Float> {
        let               cameraTransform = self.cameraTransform
        let           cameraDepthPosition = getCameraDepthPosition()
        
        let spawnPositionRelativeToCamera = calculateNewPositionByRotatingDirection (
            initialPosition: SIMD3<Float> (
                x: cameraDepthPosition.x,
                y: cameraDepthPosition.y,
                z: cameraDepthPosition.z
            ),
            angleInDegrees: angleInDegrees
        )
        
        let                 spawnPosition = cameraTransform.translation + distanceToCamera * spawnPositionRelativeToCamera
        
        return spawnPosition
    }
    
    func calculateNewPositionByRotatingDirection ( initialPosition: SIMD3<Float>, angleInDegrees: Float ) -> SIMD3<Float> {        
        return SIMD3<Float> (
            x: cos(angleInDegrees) * initialPosition.x - sin(angleInDegrees) * initialPosition.z,
            y: initialPosition.y + angleInDegrees,
            z: sin(angleInDegrees) * initialPosition.x + cos(angleInDegrees) * initialPosition.z
        )
    }
    
}
