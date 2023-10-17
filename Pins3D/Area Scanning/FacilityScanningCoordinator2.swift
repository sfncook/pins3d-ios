import ARKit

class FacilityScanningCoordinator2: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    static let facilityCameraTrackingStateChangedNotification = Notification.Name("facilityCameraTrackingStateChangedNotification")
    static let facilityCameraTrackingStateKey = "facilityCameraTrackingStateKey"
    static let fetchPinNotification = Notification.Name("fetchPinNotification")
    static let pinReadyCallbackKey = "pinReadyCallbackKey"
    static let pinIdKey = "pinIdKey"
    static let nodeKey = "nodeKey"
    
    private var sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
    var pinCurorWorldTransform: simd_float4x4?
    let fetchPinWithId: FetchPinWithId
    
    init(fetchPinWithId: FetchPinWithId) {
        self.fetchPinWithId = fetchPinWithId
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.saveFacility(_:)),
                                               name: ScanningAndAnnotatingFacilityViewModel.getWorldMapNotification,
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
}
