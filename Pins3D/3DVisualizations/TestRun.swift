/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages the process of testing detection after scanning an object.
*/

import Foundation
import ARKit

// This class represents a test run of a scanned object.
class TestRun {
    
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
        self.detectedObject?.removeFromParentNode()
        
        if self.sceneView.session.configuration as? ARWorldTrackingConfiguration != nil {
            // Make sure we switch back to an object scanning configuration & no longer
            // try to detect the object.
            let configuration = ARObjectScanningConfiguration()
            configuration.planeDetection = .horizontal
            self.sceneView.session.run(configuration, options: .resetTracking)
        }
    }
    
    var statistics: String {
        let lastDelayMilliseconds = String(format: "%.0f", lastDetectionDelayInSeconds * 1000)
        let averageDelayMilliseconds = String(format: "%.0f", averageDetectionDelayInSeconds * 1000)
        return "Detected after: \(lastDelayMilliseconds) ms. Avg: \(averageDelayMilliseconds) ms"
    }
    
    func setReferenceObject(_ object: ARReferenceObject, screenshot: UIImage?, sidesNodeObject: SCNNode?) {
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

    // This function calculates the shortest distance from a point to a ray
    func distanceFromRay(rayOrigin: SCNVector3, rayDirection: SCNVector3, point: SCNVector3) -> Float {
        let w = point - rayOrigin
        let c1 = dot(w, rayDirection)
        let c2 = dot(rayDirection, rayDirection)
        let b = c1 / c2
        let pb = rayOrigin + (rayDirection * b)
        let delta = point - pb
        return delta.length
    }


    func dot(_ left: SCNVector3, _ right: SCNVector3) -> Float {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }
    
    func successfulDetection(_ objectAnchor: ARObjectAnchor) {
        
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
    
    func rayFromCenterOfScreen(in sceneView: ARSCNView) -> (origin: SCNVector3, direction: SCNVector3)? {
        let screenCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)

        // Convert 2D screen position (near plane) to 3D world space position
        let nearVector = sceneView.unprojectPoint(SCNVector3(screenCenter.x, screenCenter.y, 0))

        // Convert 2D screen position (far plane) to 3D world space position
        let farVector = sceneView.unprojectPoint(SCNVector3(screenCenter.x, screenCenter.y, 1))
        
        // Calculate the direction from the near point to the far point
        let direction = normalize(farVector - nearVector)
        let rayCamera = (origin: nearVector, direction: direction)
        
        // Convert from Camera coords --> World coords
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraMatrix = SCNMatrix4(cameraTransform!)
        let rayWorld = (origin: rayCamera.origin.transformed(by: cameraMatrix), direction: normalize(rayCamera.direction.transformed(by: cameraMatrix)))
        
        let objectMatrix = self.detectedObject!.transform
        // Convert the world transform of the object to an SCNMatrix4
//            let objectMatrix = SCNMatrix4(objectTransform)
        
        // Compute the inverse of the object's transformation matrix
        let inverseObjectMatrix = SCNMatrix4Invert(objectMatrix)
        
        // Transform the ray's origin and direction by the inverse matrix
        let rayObjectOrigin = rayWorld.origin.transformed(by: inverseObjectMatrix)
        let rayObjectDirection = rayWorld.direction.transformed(by: inverseObjectMatrix)
        let rayObject = (origin: rayObjectOrigin, direction: normalize(rayObjectDirection))
        
        return rayObject
    }

    func normalize(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
    }

    
    private let semaphore = DispatchSemaphore(value: 1)
    
    func updateOnEveryFrame() {
        if let detectedObject = self.detectedObject {
            if let currentPointCloud = self.sceneView.session.currentFrame?.rawFeaturePoints {
                detectedObject.updatePointCloud(currentPointCloud)
            }
        }
        
//        if semaphore.wait(timeout: .now() ) == .success {
//            DispatchQueue.main.async {
//                if let referenceObject = self.referenceObject {
//                    if let ray = self.rayFromCenterOfScreen(in: self.sceneView) {
//                        let points = referenceObject.rawFeaturePoints.points
//
//                        // Find the point from the point cloud that is closest to the ray
//                        var closestPoint: SIMD3<Float>? = nil
//                        var smallestDistance = Float.infinity
//
//                        for i in 0..<points.count {
//                            let point = points[i]
//                            let ptVector = point.scnVector3
//                            let distance = self.distanceFromRay(rayOrigin: ray.origin, rayDirection: ray.direction, point: ptVector)
//                            if distance < smallestDistance {
//                                closestPoint = point
//                                smallestDistance = distance
//                            }
//                        }
//
//                        // Place a sphere node at the closest point
//                        if let closestPoint = closestPoint {
//                            self.sphereNode.position = SCNVector3(closestPoint)
//                        } else {
//                            print("Place sphere: No closestPoint")
//                        }
//                    }
//                } else {
//                    print("Place sphere: No reference object")
//                }
//                self.semaphore.signal()
//            }//DispatchQueue.main.async
//        } else {
////            print("Place sphere: Thread blocked, skipping")
//        }
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

extension SIMD3 where Scalar == Float {
    var scnVector3: SCNVector3 {
        return SCNVector3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}

extension SCNVector3 {
    func transformed(by matrix: SCNMatrix4) -> SCNVector3 {
        return SCNVector3(
            matrix.m11 * self.x + matrix.m21 * self.y + matrix.m31 * self.z + matrix.m41,
            matrix.m12 * self.x + matrix.m22 * self.y + matrix.m32 * self.z + matrix.m42,
            matrix.m13 * self.x + matrix.m23 * self.y + matrix.m33 * self.z + matrix.m43
        )
    }
    
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func *(vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
    
    static func *(scalar: Float, vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
    
    var length: Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    public static func !=(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return !(lhs == rhs)
    }
}

extension SCNView {
    func ray(through point: CGPoint) -> (origin: SCNVector3, direction: SCNVector3, farPoint: SCNVector3)? {
        let nearPoint = unprojectPoint(SCNVector3(x: Float(point.x), y: Float(point.y), z: 0))
        let farPoint = unprojectPoint(SCNVector3(x: Float(point.x), y: Float(point.y), z: 1))
        
        guard nearPoint != farPoint else { return nil }
        
        let direction = normalize(vector: farPoint - nearPoint)
        return (origin: nearPoint, direction: direction, farPoint: farPoint)
    }
    
    private func normalize(vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        guard length != 0 else { return SCNVector3(0, 0, 0) }
        return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
    }
}


