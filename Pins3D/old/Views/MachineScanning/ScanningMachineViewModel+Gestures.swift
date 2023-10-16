import SwiftUI
import ARKit

extension ScanningMachineViewModel {
    static let draggingGestureOnBeganNotification = Notification.Name("draggingGestureOnBegan")
    static let draggingGestureOnChangedNotification = Notification.Name("draggingGestureOnChanged")
    static let draggingGestureOnEndedNotification = Notification.Name("draggingGestureOnEnded")
    static let draggingLocationKey = "draggingLocationKey"
    static let magnifyingGestureOnChangedNotification = Notification.Name("magnifyingGestureOnChanged")
    static let magnificationScaleKey = "magnificationScaleKey"
    
    func draggingGestureOnChanged(_ value: DragGesture.Value) {
        if(self.isDragging) {
            NotificationCenter.default.post(name: ScanningMachineViewModel.draggingGestureOnChangedNotification,
                                            object: self,
                                            userInfo: [ScanningMachineViewModel.draggingLocationKey: value.location])
        } else {
            self.isDragging = true
            NotificationCenter.default.post(name: ScanningMachineViewModel.draggingGestureOnBeganNotification,
                                            object: self,
                                            userInfo: [ScanningMachineViewModel.draggingLocationKey: value.location])
        }
    }
    
    func draggingGestureOnEnded(_ value: DragGesture.Value) {
        self.isDragging = false
        NotificationCenter.default.post(name: ScanningMachineViewModel.draggingGestureOnEndedNotification, object: self)
    }
    
    func magnifyingGestureOnChanged(_ value: MagnificationGesture.Value) {
        let delta = value / lastScale
        lastScale = value
        NotificationCenter.default.post(name: ScanningMachineViewModel.magnifyingGestureOnChangedNotification,
                                        object: self,
                                        userInfo: [ScanningMachineViewModel.magnificationScaleKey: delta])
    }
    
}
