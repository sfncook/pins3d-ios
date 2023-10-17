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
    var nodeTypesToShow: [String] = [ProcedurePinNode.typeName, TextPinNode.typeName]
    var stepPinsToShow: [StepPin] = []
    var procedurePinNodes: [ProcedurePinNode] = []
    
    init(fetchPinWithId: FetchPinWithId) {
        self.fetchPinWithId = fetchPinWithId
        super.init()
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
            
            var hitProcedurePinBackgroundNode: ProcedurePinNode? = nil

            for procedurePinNode in self.procedurePinNodes {
                let hitResults = scnView.hitTest(screenPos, options: [
                    .rootNode: procedurePinNode.backgroundNode,
                    .ignoreChildNodes: false,
                    .ignoreHiddenNodes: false,
                    .backFaceCulling: false,
                    .boundingBoxOnly: false,
                    .searchMode: SCNHitTestSearchMode.all.rawValue
                ])
                
                if !hitResults.isEmpty {
                    hitProcedurePinBackgroundNode = procedurePinNode
                    break
                }
            }

            if let hitNode = hitProcedurePinBackgroundNode {
                hitNode.addHighlight()
            }
            for procedurePinNode in self.procedurePinNodes {
                if procedurePinNode != hitProcedurePinBackgroundNode {
                    procedurePinNode.removeHighlight()
                }
            }
            
            let hitResults = scnView.hitTest(screenPos, types: [.featurePoint])
            if !hitResults.isEmpty {
                let hit = hitResults[0]
                self.pinCurorWorldTransform = hit.worldTransform
                self.sphereNode.simdWorldPosition = hit.worldTransform.position
            }
        }
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
        // TODO: Add user info for session tracking status
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
    
    func getWorldMap(completionHandler: @escaping (ARWorldMap?) -> Void) {
        ARSCNView.sceneView!.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
            else {
                print("Can't get current world map \(error!.localizedDescription)")
                completionHandler(nil)
                return
            }
            if error == nil {
                completionHandler(map)
            } else {
                print("Error getCurrentWorldMap: \(error!.localizedDescription)")
                completionHandler(nil)
            }
            
        }
    }
    
    func loadWorldMap(_ worldMap: ARWorldMap) {
        print("FacilityScanningCoordinator.loadWorldMap")
        let configuration = FacilityScanningARViewContainer.defaultConfiguration
        configuration.initialWorldMap = worldMap
        ARSCNView.sceneView!.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
