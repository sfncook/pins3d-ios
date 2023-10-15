import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    
    init() {
        print("ARViewContainer.init")
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arSCNView = ARSCNView(frame: .zero)
        arSCNView.delegate = context.coordinator
        arSCNView.session.delegate = context.coordinator
        context.coordinator.sceneView = arSCNView
        ARSCNView.sceneView = arSCNView
        
        // Start AR session with horizontal plane detection
        let configuration = ARObjectScanningConfiguration()
        configuration.planeDetection = .horizontal
        arSCNView.session.run(configuration, options: .resetTracking)
        
        return arSCNView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
