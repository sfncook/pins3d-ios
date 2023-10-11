//
//  ScanningMachineViewModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/11/23.
//
import SwiftUI
import ARKit

class ScanningMachineViewModel: ObservableObject {
    @Published var cameraTrackingState: ARCamera.TrackingState?
    
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
    }
}
