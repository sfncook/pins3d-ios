import ARKit
import SceneKit

extension Coordinator {
    func testObjectDetection() {
        // In case an object for testing has been received, use it right away...
        if let object = referenceObjectToTest {
            testObjectDetection(of: object)
            referenceObjectToTest = nil
//            sidesNodeObjectToTest = nil
            return
        }
        
        // ...otherwise attempt to create a reference object from the current scan.
        guard let scan = Coordinator.scan, scan.boundingBoxExists else {
            print("Error: Bounding box not yet created.")
            return
        }
        
        scan.createReferenceObject { scannedObject in
            if let object = scannedObject {
                self.testObjectDetection(of: object)
            } else {
                let title = "Scan failed"
                let message = "Saving the scan failed."
                let buttonTitle = "Restart Scan"
//                self.showAlert(title: title, message: message, buttonTitle: buttonTitle, showCancel: false) { _ in
//                    self.state = .startARSession
//                }
            }
        }
    }
    
    func testObjectDetection(of object: ARReferenceObject) {
        self.testRun?.setReferenceObject(object, screenshot: Coordinator.scan?.screenshot, sidesNodeObject: nil)
//        self.testRun?.detectedObject?.pointCloudVisualization.viewCtl = self // viewCtl is only used for displaying alerts
        
        // Delete the scan to make sure that users cannot go back from
        // testing to scanning, because:
        // 1. Testing and scanning require running the ARSession with different configurations,
        //    thus the scanned environment is lost when starting a test.
        // 2. We encourage users to move the scanned object during testing, which invalidates
        //    the feature point cloud which was captured during scanning.
        Coordinator.scan = nil
//        self.displayInstruction(Message("""
//                    Test detection of the object from different angles. Consider moving the object to different environments and test there.
//                    """))
    }
    
    func loadModelAndStartScanning(_ referenceObject: ARReferenceObject) {
        print("loadModelAndStartScanning")
                DispatchQueue.main.async {
                    self.referenceObjectToTest = referenceObject
                    self.state = .testing
                    print("3. Done.")
////                    self.displayInstruction(Message("Load complete"))
                }
    }
}
