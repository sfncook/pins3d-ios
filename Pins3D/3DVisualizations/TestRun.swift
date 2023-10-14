/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages the process of testing detection after scanning an object.
*/

import Foundation
import ARKit

// This class represents a test run of a scanned object.
class TestRun {
    
    static let objectDetectedNotification = Notification.Name("objectDetectedNotification")
    
    // The ARReferenceObject to be tested in this run.
    var referenceObject: ARReferenceObject?
    
    var detectedObject: DetectedObject?
    
    var detections = 0
    var lastDetectionDelayInSeconds: Double = 0
    var averageDetectionDelayInSeconds: Double = 0
    
    var resultDisplayDuration: Double {
        // The recommended display duration for detection results
        // is the average time it takes to detect it, plus 200 ms buffer.
        return averageDetectionDelayInSeconds + 0.2
    }
    
    private var lastDetectionStartTime: Date?
    
    private var sceneView: ARSCNView
    
    private(set) var previewImage = UIImage()
    
    private var sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    deinit {
        print("TestRun.deinit")
        self.detectedObject?.removeFromParentNode()
        
        if self.sceneView.session.configuration as? ARWorldTrackingConfiguration != nil {
            // Make sure we switch back to an object scanning configuration & no longer
            // try to detect the object.
            let configuration = ARObjectScanningConfiguration()
            configuration.planeDetection = .horizontal
            self.sceneView.session.run(configuration, options: .resetTracking)
        }
    }
    
    func setReferenceObject(_ object: ARReferenceObject, screenshot: UIImage?, sidesNodeObject: SCNNode?) {
        print("TestRun.setReferenceObject")
        referenceObject = object
        if let screenshot = screenshot {
            previewImage = screenshot
        }
        detections = 0
        lastDetectionDelayInSeconds = 0
        averageDetectionDelayInSeconds = 0
        
        self.detectedObject = DetectedObject(referenceObject: object, sidesNodeObject: sidesNodeObject)
        self.sceneView.scene.rootNode.addChildNode(self.detectedObject!)
        
        self.detectedObject?.addChildNode(self.sphereNode)
        
        self.lastDetectionStartTime = Date()
        
        print("Starting WorldTrackingConfig now")
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionObjects = [object]
        self.sceneView.session.run(configuration)
        
        startNoDetectionTimer()
    }
    
    func didTapWhileTesting(_ gesture: UITapGestureRecognizer) {
        if let detectedObject = self.detectedObject {
            detectedObject.updateCubes(sceneView: sceneView, screenPos: gesture.location(in: sceneView))
        }
    }

    func successfulDetection(_ objectAnchor: ARObjectAnchor) {
        if(detections==0) {
            // Send notification on first detection
            NotificationCenter.default.post(name: TestRun.objectDetectedNotification, object: self)
        }
        // Compute the time it took to detect this object & the average.
        lastDetectionDelayInSeconds = Date().timeIntervalSince(self.lastDetectionStartTime!)
        detections += 1
        averageDetectionDelayInSeconds = (averageDetectionDelayInSeconds * Double(detections - 1) + lastDetectionDelayInSeconds) / Double(detections)
        
        // Update the detected object's display duration
        self.detectedObject?.displayDuration = resultDisplayDuration
        
        // Immediately remove the anchor from the session again to force a re-detection.
        self.lastDetectionStartTime = Date()
        self.sceneView.session.remove(anchor: objectAnchor)
        
        if let currentPointCloud = self.sceneView.session.currentFrame?.rawFeaturePoints {
            self.detectedObject?.updateVisualization(newTransform: objectAnchor.transform,
                                                     currentPointCloud: currentPointCloud)
        }
        
        startNoDetectionTimer()
    }
    
    func updateOnEveryFrame() {
//        print("TestRun.updateOnEveryFrame")
        if let detectedObject = self.detectedObject {
            if let currentPointCloud = self.sceneView.session.currentFrame?.rawFeaturePoints {
//                print("currentPointCloud.points.count: \(currentPointCloud.points.count)")
                detectedObject.updatePointCloud(currentPointCloud)
            }
        }
    }
    
    var noDetectionTimer: Timer?
    
    func startNoDetectionTimer() {
        cancelNoDetectionTimer()
        noDetectionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.cancelNoDetectionTimer()
//            ViewController.instance?.displayMessage("""
//                Shift the phone's position, please
//                """, expirationTime: 3.0)
        }
    }
    
    func cancelNoDetectionTimer() {
        noDetectionTimer?.invalidate()
        noDetectionTimer = nil
    }
}


