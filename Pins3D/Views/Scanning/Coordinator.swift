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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.setScanningReady(_:)),
                                               name: ScanningMachineViewModel.setScanningReadyNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.startDefiningBox(_:)),
                                               name: ScanningMachineViewModel.startDefiningBoxNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.startScanning(_:)),
                                               name: ScanningMachineViewModel.startScanningNotification,
                                               object: nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let frame = sceneView?.session.currentFrame else { return }
        Coordinator.scan?.updateOnEveryFrame(frame)
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
    
    @objc
    private func setScanningReady(_ notification: Notification) {
        setScanningReady()
    }
    
    @objc
    private func startDefiningBox(_ notification: Notification) {
        startDefiningBox()
    }
    
    @objc
    private func startScanning(_ notification: Notification) {
        startScanning()
    }

}
