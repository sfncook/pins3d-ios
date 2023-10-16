import SwiftUI
import ARKit

class FacilityScanningCoordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    
    private var sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
    
    // MARK: - ARSCNViewDelegate
    
    // Update On Every Frame
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if sphereNode.parent == nil {
            ARSCNView.sceneView!.scene.rootNode.addChildNode(sphereNode)
        }
        DispatchQueue.main.async {
            let scnView = ARSCNView.sceneView!
            let screenPos = CGPoint(x: scnView.bounds.midX, y: scnView.bounds.midY)
            let hitResults = scnView.hitTest(screenPos, types: [.featurePoint])
            if !hitResults.isEmpty {
                let hit = hitResults[0]
                self.sphereNode.simdWorldPosition = hit.worldTransform.position
            }
        }
    }
    
    /// - Tag: RestoreVirtualContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard anchor.name == virtualObjectAnchorName
//            else { return }
//        
//        // save the reference to the virtual object anchor when the anchor is added from relocalizing
//        if virtualObjectAnchor == nil {
//            virtualObjectAnchor = anchor
//        }
//        node.addChildNode(virtualObject)
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
//        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
//        switch frame.worldMappingStatus {
//            case .extending, .mapped:
//                saveExperienceButton.isEnabled =
//                    virtualObjectAnchor != nil && frame.anchors.contains(virtualObjectAnchor!)
//            default:
//                saveExperienceButton.isEnabled = false
//        }
//        statusLabel.text = """
//        Mapping: \(frame.worldMappingStatus.description)
//        Tracking: \(frame.camera.trackingState.description)
//        """
//        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
}
