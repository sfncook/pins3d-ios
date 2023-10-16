import SwiftUI
import ARKit

class FacilityScanningCoordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    
    private var sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.saveFacility(_:)),
                                               name: ScanningAndAnnotatingFacilityViewModel.getWorldMapNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.addPin(_:)),
                                               name: ScanningAndAnnotatingFacilityViewModel.addPinToFacilityNotification,
                                               object: nil)
    }
    
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
    
    @objc
    private func saveFacility(_ notification: Notification) {
        guard let worldMapReady = notification.userInfo?[ScanningAndAnnotatingFacilityViewModel.worldMapReadyCallback] as? WorldMapReadyCallback else { return }
        ARSCNView.sceneView!.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
            else {
                print("Can't get current world map \(error!.localizedDescription)")
                return
            }
            worldMapReady.worldMapReady(worldMap: map)
        }
    }
    
    @objc
    private func addPin(_ notification: Notification) {
        guard let pin = notification.userInfo?[ScanningAndAnnotatingFacilityViewModel.pinFacilityKey] as? Pin else { return }
        let targetPosition = SCNVector3(x: pin.x, y: pin.y, z: pin.z)
        if let textPin = pin as? TextPin {
            let textPinNode = TextPinNode(textPin)
            ARSCNView.sceneView!.scene.rootNode.addChildNode(textPinNode)
            textPinNode.position = targetPosition
        } else {
            print("This pin is not a TextPin")
        }

    }
}
