//
//  AnnotatingMachineViewViewModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/12/23.
//

import SwiftUI
import ARKit

class AnnotatingMachineViewModel: ObservableObject, GetAnnotationPointCallback {
    static let loadModelNotification = Notification.Name("LoadModel")
    static let referenceObjectKey = "referenceObjectKey"
    static let getAnnotationPointNotification = Notification.Name("getAnnotationPointNotification")
    static let getAnnotationPointCallbackKey = "getAnnotationPointCallbackKey"
    
    @Published var cameraTrackingState: ARCamera.TrackingState?
    @Published var appState: Coordinator.AppState?
    @Published var showStartLoadButtons: Bool = false
    @Published var showLoadingMsg: Bool = false
    @Published var loadingMsg: String?
    @Published var isModelLoading: Bool = false
    @Published var hasModelBeenLoaded: Bool = false
    @Published var hasObjectBeenDetected: Bool = false
    @Published var showCreatePinView: Bool = false
    
    var machine: Machine
    
    init(machine: Machine) {
//        print("AnnotatingMachineViewViewModel.init \(machine.name!) \(machine.arFilename ?? "NO AR Filename")")
        self.machine = machine
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.cameraTrackingStateChanged(_:)),
                                               name: Coordinator.cameraTrackingStateChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appStateChanged(_:)),
                                               name: Coordinator.appStateChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.objectDetected(_:)),
                                               name: TestRun.objectDetectedNotification,
                                               object: nil)
    }
    
    @objc
    private func cameraTrackingStateChanged(_ notification: Notification) {
        guard let cameraTrackingState = notification.userInfo?[Coordinator.cameraTrackingStateKey] as? ARCamera.TrackingState else { return }
        self.cameraTrackingState = cameraTrackingState
        self.updateShowLoadButton()
    }
    
    @objc
    private func appStateChanged(_ notification: Notification) {
        guard let appState = notification.userInfo?[Coordinator.appStateUserInfoKey] as? Coordinator.AppState else { return }
        self.appState = appState
    }
    
    @objc
    private func objectDetected(_ notification: Notification) {
        DispatchQueue.main.async {
            self.hasObjectBeenDetected = true
        }
    }
    
    private func updateShowLoadButton() {
        self.showStartLoadButtons = self.cameraTrackingState == .normal && !self.hasModelBeenLoaded && !self.isModelLoading
    }
    
    func onDropPin() {
        NotificationCenter.default.post(name: AnnotatingMachineViewModel.getAnnotationPointNotification,
                                        object: self,
                                        userInfo: [AnnotatingMachineViewModel.getAnnotationPointCallbackKey: self])
    }
    
    func setAnnotationPoint(x: Float?, y: Float?, z: Float?) {
        print("setAnnotationPoint \(x), \(y), \(z)")
        self.showCreatePinView = true
    }
}

protocol GetAnnotationPointCallback {
    func setAnnotationPoint(x: Float?, y: Float?, z: Float?)
}
