//
//  ScanningMachineViewModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/11/23.
//
import SwiftUI
import ARKit

class ScanningMachineViewModel: ObservableObject {
    static let updateCenterPointNotification = Notification.Name("UpdateCenterPoint")
    static let setScanningReadyNotification = Notification.Name("SetScanningReady")
    static let startDefiningBoxNotification = Notification.Name("StartDefiningBox")
    static let startScanningNotification = Notification.Name("StartScanning")
    static let resetAppAndScanningStatesNotification = Notification.Name("resetAppAndScanningStates")
    
    @Published var cameraTrackingState: ARCamera.TrackingState?
    @Published var showAlert: Bool = false
    @Published var showSetScanningReadyButton: Bool = false
    @Published var showStartDefiningBoxButton: Bool = false
    @Published var showStartScanningButton: Bool = false
    @Published var showStartScanningButtons: Bool = false
    @Published var showScanningButtons: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.cameraTrackingStateChanged(_:)),
                                               name: Coordinator.cameraTrackingStateChangedNotification,
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
    
    func updateCenter() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.updateCenterPointNotification, object: self)
    }
    
    func setScanningReady() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.setScanningReadyNotification, object: self)
        showSetScanningReadyButton = false
        showStartDefiningBoxButton = true
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
    
    func resetAppAndScanningStates() {
        NotificationCenter.default.post(name: ScanningMachineViewModel.resetAppAndScanningStatesNotification, object: self)
        showSetScanningReadyButton = false
        showStartDefiningBoxButton = false
        showStartScanningButton = false
        showStartScanningButtons = false
        showScanningButtons = false
    }
}
