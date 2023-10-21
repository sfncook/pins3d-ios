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
    let cursorActionsDelegate: CursorActions
    let loadAnchorsCompleteCallback: LoadAnchorsCompleteCallback
    var nodeTypesToShow: [String] = [ProcedurePinNode.typeName, TextPinNode.typeName]
    var stepPinsToShow: [StepPin] = []
    var highlightStepPin: StepPin?
    var procedurePinNodes: [ProcedurePinNode] = []
    var firstAnchorLoaded: Bool = false
    var updateWorldTrackingStatusDelegate: UpdateWorldTrackingStatus
    
    init(
        fetchPinWithId: FetchPinWithId,
        cursorActionsDelegate: CursorActions,
        loadAnchorsCompleteCallback: LoadAnchorsCompleteCallback,
        updateWorldTrackingStatusDelegate: UpdateWorldTrackingStatus
    ) {
        self.fetchPinWithId = fetchPinWithId
        self.cursorActionsDelegate = cursorActionsDelegate
        self.loadAnchorsCompleteCallback = loadAnchorsCompleteCallback
        self.updateWorldTrackingStatusDelegate = updateWorldTrackingStatusDelegate
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
                if let hitProcedureId = hitNode.procedurePin.procedureId {
                    self.cursorActionsDelegate.onCursorOverProcedurePin(procedureId: hitProcedureId)
                }
            } else {
                self.cursorActionsDelegate.onCursorOutProcedurePin()
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
        }// Dispatch main.async
        
        findHighlightedPin(renderer: renderer)
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
        switch frame.worldMappingStatus {
        case .extending:
            updateWorldTrackingStatusDelegate.setExtending()
        case .mapped:
            updateWorldTrackingStatusDelegate.setMapped()
        default:
            break
        }
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
    
    func pauseArSession() {
        ARSCNView.sceneView!.session.pause()
    }
    
    func resumeArSession() {
        ARSCNView.sceneView!.session.run(FacilityScanningARViewContainer.defaultConfiguration)
        ARSCNView.sceneView!.debugOptions = [ .showFeaturePoints ]
    }
    
    func captureSnapshotImage() -> UIImage? {
        guard let frame = ARSCNView.sceneView!.session.currentFrame
            else { return nil }
        
        let image = CIImage(cvPixelBuffer: frame.capturedImage)
        let orientation = CGImagePropertyOrientation(cameraOrientation: UIDevice.current.orientation)
        
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let data = context.jpegRepresentation(of: image.oriented(orientation),
                                                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                    options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.7])
        else { return nil }
        
        return UIImage(data: data)
    }
}

protocol CursorActions {
    func onCursorOverProcedurePin(procedureId: UUID)
    func onCursorOutProcedurePin()
}

protocol UpdateWorldTrackingStatus {
    func setExtending()
    func setMapped()
}
