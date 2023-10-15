//
//  ScanningMachineViewModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/11/23.
//
import SwiftUI
import ARKit

class ScanningMachineViewModel: ObservableObject, CreateArRefModelCallback {
    static let resetAppAndScanningStatesNotification = Notification.Name("resetAppAndScanningStates")
    static let updateCenterPointNotification = Notification.Name("UpdateCenterPoint")
    static let setScanningReadyNotification = Notification.Name("SetScanningReady")
    static let startDefiningBoxNotification = Notification.Name("StartDefiningBox")
    static let startScanningNotification = Notification.Name("StartScanning")
    static let saveModelNotification = Notification.Name("SaveModel")
    static let referenceObjectCallbackKey = "referenceObjectCallbackKey"
    
    
    @Published var cameraTrackingState: ARCamera.TrackingState?
    @Published var appState: Coordinator.AppState?
    @Published var showAlert: Bool = false
    @Published var showSetScanningReadyButton: Bool = false
    @Published var showStartDefiningBoxButton: Bool = false
    @Published var showStartScanningButton: Bool = false
    @Published var showStartScanningButtons: Bool = false
    @Published var showScanningButtons: Bool = false
    @Published var showSavingMsg: Bool = false
    @Published var savingMsg: String?
    @Binding var showScanningMachineView: Bool
    @Binding var showAnnotatingMachineView: Bool
    
    var machine: Machine
    
    // Gestures
    var isDragging = false
    var currentScale: CGFloat = 1.0
    var lastScale: CGFloat = 1.0
    
    init(machine: Machine, showScanningMachineView: Binding<Bool>, showAnnotatingMachineView: Binding<Bool>) {
        print("ScanningMachineViewModel.init \(machine.name)")
        self.machine = machine
        self._showScanningMachineView = showScanningMachineView
        self._showAnnotatingMachineView = showAnnotatingMachineView
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.cameraTrackingStateChanged(_:)),
                                               name: Coordinator.cameraTrackingStateChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appStateChanged(_:)),
                                               name: Coordinator.appStateChangedNotification,
                                               object: nil)
    }
    
    @objc
    private func cameraTrackingStateChanged(_ notification: Notification) {
        guard let cameraTrackingState = notification.userInfo?[Coordinator.cameraTrackingStateKey] as? ARCamera.TrackingState else { return }
        self.cameraTrackingState = cameraTrackingState
        if self.cameraTrackingState == .normal {
            self.showSetScanningReadyButton = true
        }
    }
    
    @objc
    private func appStateChanged(_ notification: Notification) {
        guard let appState = notification.userInfo?[Coordinator.appStateUserInfoKey] as? Coordinator.AppState else { return }
        self.appState = appState
    }
    
    func updateCenter() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.updateCenterPointNotification, object: self)
    }
    
    func setScanningReady() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.setScanningReadyNotification, object: self)
        showSetScanningReadyButton = false
        showStartDefiningBoxButton = true
        updateCenter()
    }
    
    func startDefiningBox() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.startDefiningBoxNotification, object: self)
        showStartDefiningBoxButton = false
        showStartScanningButton = true
    }
    
    func startScanning() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.startScanningNotification, object: self)
        showStartScanningButton = false
        showScanningButtons = true
    }
    
    func saveModel() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.saveModelNotification,
                                        object: self,
                                        userInfo: [ScanningMachineViewModel.referenceObjectCallbackKey: self])
        showSetScanningReadyButton = false
        showStartDefiningBoxButton = false
        showStartScanningButton = false
        showStartScanningButtons = false
        showScanningButtons = false
    }
    
    func resetAppAndScanningStates() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.resetAppAndScanningStatesNotification, object: self)
        showSetScanningReadyButton = false
        showStartDefiningBoxButton = false
        showStartScanningButton = false
        showStartScanningButtons = false
        showScanningButtons = false
    }
}
