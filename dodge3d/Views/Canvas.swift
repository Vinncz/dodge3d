import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    var engines: [Engine] = [
        ShootingEngine(),
        HomingEngine()
    ]
    
    var body: some View {
        ContentManagement (
            manages: self.engines
        )
    }
}

#Preview {
    Canvas()
}
