import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var hasAddedCube = false
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//            guard !hasAddedCube, let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal else {
//                return
//            }
//            hasAddedCube = true
        }

    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arSCNView = ARSCNView(frame: .zero)
        arSCNView.delegate = context.coordinator
        
        // Start AR session with horizontal plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arSCNView.session.run(configuration)
        
        return arSCNView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
