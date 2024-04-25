//
//  Canvas.swift
//  dodge3d
//
//  Created by Vin on 25/04/24.
//

import SwiftUI
import ARKit
import RealityKit
import Observation

struct Canvas: View {
    @State var engines: [Engine] = [
        ShootingEngine()
    ]
    
    var body: some View {
        ContentManagement (
            manages: self.$engines
        )
    }
}

#Preview {
    Canvas()
}
