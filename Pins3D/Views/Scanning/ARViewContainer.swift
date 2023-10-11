import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    
    @Binding var cameraTrackingState: ARCamera.TrackingState?
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARViewContainer
                
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        }
        
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            parent.$cameraTrackingState.wrappedValue = camera.trackingState
        }

    }
    
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arSCNView = ARSCNView(frame: .zero)
        arSCNView.delegate = context.coordinator
        arSCNView.session.delegate = context.coordinator
        
        // Start AR session with horizontal plane detection
        let configuration = ARObjectScanningConfiguration()
        configuration.planeDetection = .horizontal
        arSCNView.session.run(configuration, options: .resetTracking)
        
        return arSCNView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
