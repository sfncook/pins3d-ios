import SwiftUI
import ARKit

struct FacilityScanningARViewContainer2: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    
    let coordinator: FacilityScanningCoordinator2
    
    init(coordinator: FacilityScanningCoordinator2) {
        self.coordinator = coordinator
    }
    
    static public var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }
    
    func makeCoordinator() -> FacilityScanningCoordinator2 {
        return coordinator
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arSCNView = ARSCNView(frame: .zero)
        arSCNView.delegate = context.coordinator
        arSCNView.session.delegate = context.coordinator
        ARSCNView.sceneView = arSCNView
        arSCNView.session.run(FacilityScanningARViewContainer.defaultConfiguration)
        arSCNView.debugOptions = [ .showFeaturePoints ]
        
        return arSCNView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
