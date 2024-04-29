import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @StateObject var arViewModel = ARViewModel()

    var body: some View {
        Canvas()
//        HomeView()
//        ARViewContainer(arViewModel: arViewModel)
//        ARDodgeballView()
    }
}

#Preview {
    ContentView()
}
