import SwiftUI
import ARKit

class FacilityScanningCoordinator2: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    static let facilityCameraTrackingStateChangedNotification = Notification.Name("facilityCameraTrackingStateChangedNotification")
    static let facilityCameraTrackingStateKey = "facilityCameraTrackingStateKey"
    static let fetchPinNotification = Notification.Name("fetchPinNotification")
    static let pinReadyCallbackKey = "pinReadyCallbackKey"
    static let pinIdKey = "pinIdKey"
    static let nodeKey = "nodeKey"
    
    private var sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
//    private var sphereNode = PinCursorNode()
    var pinDictionary: [String: Pin] = [:]
    var pinCurorWorldTransform: simd_float4x4?
    
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.loadWorldMap(_:)),
                                               name: ScanningAndAnnotatingFacilityViewModel.loadWorldMapNotification,
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
                self.pinCurorWorldTransform = hit.worldTransform
                self.sphereNode.simdWorldPosition = hit.worldTransform.position
            }
        }
    }
    
    // On Anchor added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorName = anchor.name
            else { return }
        
        print("FacilityScanningCoordinator anchor/pin added:\(anchorName)")
        if anchorName.hasPrefix("textpin_") {
            let pinId = String(anchorName.dropFirst("textpin_".count))
            if let textPin = pinDictionary[pinId] as? TextPin {
                print("Found this fucking pin: \(pinId)")
                let textPinNode = TextPinNode(textPin)
                node.addChildNode(textPinNode)
            } else {
                print("Pin not found.")
                NotificationCenter.default.post(name: FacilityScanningCoordinator.fetchPinNotification,
                                                object: self,
                                                userInfo: [
                                                    FacilityScanningCoordinator.pinReadyCallbackKey: self,
                                                    FacilityScanningCoordinator.pinIdKey: pinId,
                                                    FacilityScanningCoordinator.nodeKey: node
                                                ])
            }
            
        } else {
            print("The string does not start with the prefix 'textpin_'.")
        }
    }
    
    func pinReady(pin: Pin, node: SCNNode) {
        print("FacilityScanningCoordinator.pinReady: \(pin.id!)")
        let textPinNode = TextPinNode(pin as! TextPin)
        node.addChildNode(textPinNode)
    }
    
    // MARK: - ARSessionDelegate
    // On Camera Tracking State change
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        NotificationCenter.default.post(name: FacilityScanningCoordinator.facilityCameraTrackingStateChangedNotification,
                                        object: self,
                                        userInfo: [FacilityScanningCoordinator.facilityCameraTrackingStateKey: camera.trackingState])
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
    private func loadWorldMap(_ notification: Notification) {
        print("FacilityScanningCoordinator.loadWorldMap")
        guard let worldMap = notification.userInfo?[ScanningAndAnnotatingFacilityViewModel.worldMapKey] as? ARWorldMap else { return }
        let configuration = FacilityScanningARViewContainer.defaultConfiguration // this app's standard world tracking settings
        configuration.initialWorldMap = worldMap
        ARSCNView.sceneView!.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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

