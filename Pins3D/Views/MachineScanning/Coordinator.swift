import SwiftUI
import ARKit

class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    static let cameraTrackingStateChangedNotification = Notification.Name("CameraTrackingStateChanged")
    static let cameraTrackingStateKey = "CameraTrackingState"
    static let appStateChangedNotification = Notification.Name("ApplicationStateChanged")
    static let appStateUserInfoKey = "AppState"
    static let referenceObjectReadyNotification = Notification.Name("referenceObjectReady")
    static let referenceObjectKey = "referenceObjectKey"
    
    var internalState: AppState = .startARSession
    static var scan: Scan?
    var testRun: TestRun?
    var referenceObjectToTest: ARReferenceObject?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.resetAppAndScanningStates(_:)),
                                               name: ScanningMachineViewModel.resetAppAndScanningStatesNotification,
                                               object: nil)
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.saveModel(_:)),
                                               name: ScanningMachineViewModel.saveModelNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.loadModel(_:)),
                                               name: AnnotatingMachineViewModel.loadModelNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.requestCameraStateUpdate(_:)),
                                               name: AnnotatingMachineViewModel.requestCameraStateUpdateNotification,
                                               object: nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = ARSCNView.sceneView?.session.currentFrame else { return }
        Coordinator.scan?.updateOnEveryFrame(frame)
        testRun?.updateOnEveryFrame()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        print("render object anchor found")
        if let objectAnchor = anchor as? ARObjectAnchor {
            if let testRun = self.testRun, objectAnchor.referenceObject == testRun.referenceObject {
                testRun.successfulDetection(objectAnchor)
//                let messageText = """
//                    Object successfully detected from this angle.
//
//                    """ + testRun.statistics
//                displayMessage(messageText, expirationTime: testRun.resultDisplayDuration)
            }
        } else if state == .scanning, let planeAnchor = anchor as? ARPlaneAnchor {
            Coordinator.scan?.scannedObject.tryToAlignWithPlanes([planeAnchor])
            
            // After a plane was found, disable plane detection for performance reasons.
            ARSCNView.sceneView?.stopPlaneDetection()
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        NotificationCenter.default.post(name: Coordinator.cameraTrackingStateChangedNotification,
                                        object: self,
                                        userInfo: [Coordinator.cameraTrackingStateKey: camera.trackingState])
    }
    
    @objc
    private func resetAppAndScanningStates(_ notification: Notification) {
        resetAppAndScanningStates()
    }
    
    @objc
    private func updateCenterPoint(_ notification: Notification) {
        CGPoint.screenCenter = ARSCNView.sceneView?.center ?? CGPoint()
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
    
    @objc
    private func saveModel(_ notification: Notification) {
        guard let createArRefModelCallback = notification.userInfo?[ScanningMachineViewModel.referenceObjectCallbackKey] as? CreateArRefModelCallback else { return }
        saveModelAndCallback(createArRefModelCallback)
    }
    
    @objc
    private func loadModel(_ notification: Notification) {
        guard let referenceObject = notification.userInfo?[AnnotatingMachineViewModel.referenceObjectKey] as? ARReferenceObject else { return }
        loadModelAndStartScanning(referenceObject)
    }
    
    @objc
    private func requestCameraStateUpdate(_ notification: Notification) {
        if let cameraTrackingState = ARSCNView.sceneView?.session.currentFrame?.camera.trackingState {
            NotificationCenter.default.post(name: Coordinator.cameraTrackingStateChangedNotification,
                                            object: self,
                                            userInfo: [Coordinator.cameraTrackingStateKey: cameraTrackingState])
        }
        
        NotificationCenter.default.post(name: Coordinator.appStateChangedNotification,
                                        object: self,
                                        userInfo: [Coordinator.appStateUserInfoKey: self.state])

    }

}
