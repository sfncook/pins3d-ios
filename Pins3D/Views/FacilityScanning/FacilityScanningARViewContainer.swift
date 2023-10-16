import SwiftUI
import ARKit

struct FacilityScanningARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }
    
    func makeCoordinator() -> FacilityScanningCoordinator {
        return FacilityScanningCoordinator()
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arSCNView = ARSCNView(frame: .zero)
        arSCNView.delegate = context.coordinator
        arSCNView.session.delegate = context.coordinator
        ARSCNView.sceneView = arSCNView
        arSCNView.session.run(defaultConfiguration)
        arSCNView.debugOptions = [ .showFeaturePoints ]
        
        return arSCNView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
