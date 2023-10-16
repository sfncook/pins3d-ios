import SwiftUI
import ARKit

class FacilityScanningCoordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    
    private var sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
    var pinDictionary: [String: Pin] = [:]
    
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
        guard let anchorName = anchor.name
            else { return }
        
        if anchorName.hasPrefix("textpin_") {
            let pinId = String(anchorName.dropFirst("textpin_".count))
            if let textPin = pinDictionary[pinId] as? TextPin {
                print("Found this fucking pin: \(pinId)")
                let textPinNode = TextPinNode(textPin)
                node.addChildNode(textPinNode)
            } else {
                print("Pin not found.")
            }
            
        } else {
            print("The string does not start with the prefix 'textpin_'.")
        }
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
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4<Float>(targetPosition.x, targetPosition.y, targetPosition.z, 1.0)
        if let textPin = pin as? TextPin {
            let textPinNode = TextPinNode(textPin)
            pinDictionary["\(pin.id!)"] = textPin
            let anchor = ARAnchor(name: "textpin_\(pin.id!)", transform: transform)
            ARSCNView.sceneView!.session.add(anchor: anchor)
        } else {
            print("This pin is not a TextPin")
        }

    }
}
