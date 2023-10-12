import SwiftUI
import ARKit

class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    static let cameraTrackingStateChangedNotification = Notification.Name("CameraTrackingStateChanged")
    static let cameraTrackingStateKey = "CameraTrackingState"
    static let appStateChangedNotification = Notification.Name("ApplicationStateChanged")
    static let appStateUserInfoKey = "AppState"
    
    var sceneView: ARSCNView?
    var internalState: AppState = .startARSession
    static var scan: Scan?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateCenterPoint(_:)),
                                               name: ScanningMachineViewModel.updateCenterPointNotification,
                                               object: nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        NotificationCenter.default.post(name: Coordinator.cameraTrackingStateChangedNotification,
                                        object: self,
                                        userInfo: [Coordinator.cameraTrackingStateKey: camera.trackingState])
    }
    
    @objc
    private func updateCenterPoint(_ notification: Notification) {
        CGPoint.screenCenter = sceneView?.center ?? CGPoint()
    }

}
