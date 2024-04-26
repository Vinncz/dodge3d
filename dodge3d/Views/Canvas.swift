import SwiftUI
import ARKit
import RealityKit

struct Canvas: View {
    var engines: [Engine] = [
        ShootingEngine(),
        HomingEngine(0.2),
        HomingEngine(-0.2)
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
