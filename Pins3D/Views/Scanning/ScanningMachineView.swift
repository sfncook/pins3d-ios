import SwiftUI
import ARKit

struct ScanningMachineView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = ScanningMachineViewModel()
    
    var contentBasedOnState: Text {
        switch $viewModel.cameraTrackingState.wrappedValue {
        case nil:
            return Text("Initializing")
        case .notAvailable:
            return Text("AR not available")
        case .normal:
            return Text("Ready")
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return Text("ARKit tracking LIMITED: Excessive motion")
            case .insufficientFeatures:
                return Text("ARKit tracking LIMITED: Low detail")
            case .initializing:
                return Text("ARKit is initializing")
            case .relocalizing:
                return Text("ARKit is relocalizing")
            @unknown default:
                return Text("ARKit tracking LIMITED")
            }
        }
    }
    
//    var state: ScanningState {
//        get {
//            return self.scanningState
//        }
//        set {
//            // 1. Check that preconditions for the state change are met.
//            var newState = newValue
//            switch newValue {
//            case .startARSession:
//                break
//            case .notReady:
//                // Immediately switch to .ready if tracking state is normal.
//                if let camera = self.sceneView.session.currentFrame?.camera {
//                    switch camera.trackingState {
//                    case .normal:
//                        newState = .scanning
//                    default:
//                        break
//                    }
//                } else {
//                    newState = .startARSession
//                }
//            case .scanning:
//                // Immediately switch to .notReady if tracking state is not normal.
//                if let camera = self.sceneView.session.currentFrame?.camera {
//                    switch camera.trackingState {
//                    case .normal:
//                        break
//                    default:
//                        newState = .notReady
//                    }
//                } else {
//                    newState = .startARSession
//                }
//            case .testing:
//                guard scan?.boundingBoxExists == true || referenceObjectToTest != nil else {
//                    print("Error: Scan is not ready to be tested.")
//                    return
//                }
//            }
//            
//            // 2. Apply changes as needed per state.
//            internalState = newState
//            
//            switch newState {
//            case .startARSession:
//                print("State: Starting ARSession")
//                scan = nil
//                testRun = nil
//                modelURL = nil
//                self.setNavigationBarTitle("")
//                instructionsVisible = false
//                showBackButton(false)
//                nextButton.isEnabled = true
//                scanModelButton.isHidden = false
//                loadModelButton.isHidden = false
//                loadModelButton.setTitle("Load", for: [])
////                flashlightButton.isHidden = true
//                
//                // Make sure the SCNScene is cleared of any SCNNodes from previous scans.
//                sceneView.scene = SCNScene()
//                
//                let configuration = ARObjectScanningConfiguration()
//                configuration.planeDetection = .horizontal
//                sceneView.session.run(configuration, options: .resetTracking)
//                cancelMaxScanTimeTimer()
//                cancelMessageExpirationTimer()
//            case .notReady:
//                print("State: Not ready to scan")
//                scan = nil
//                testRun = nil
//                self.setNavigationBarTitle("")
//                scanModelButton.isHidden = true
//                loadModelButton.isHidden = true
////                flashlightButton.isHidden = true
//                showBackButton(false)
//                nextButton.isEnabled = false
//                nextButton.setTitle("Next", for: [])
////                displayInstruction(Message("Please wait for stable tracking"))
//                cancelMaxScanTimeTimer()
//            case .scanning:
//                print("State: Scanning")
//                if scan == nil {
//                    self.scan = Scan(sceneView)
//                    self.scan?.state = .ready
//                }
//                testRun = nil
//                instructionsVisible = false
//                
//                startMaxScanTimeTimer()
//            case .testing:
//                print("State: Testing")
//                self.setNavigationBarTitle("")
//                scanModelButton.isHidden = true
//                loadModelButton.isHidden = false
//                loadModelButton.setTitle("Save", for: [])
////                flashlightButton.isHidden = false
////                showMergeScanButton()
////                nextButton.isEnabled = true
////                nextButton.setTitle("Share", for: [])
//                instructionsVisible = false
//                
//                testRun = TestRun(sceneView: sceneView)
//                testObjectDetection()
//                cancelMaxScanTimeTimer()
//            }
//            
//            NotificationCenter.default.post(name: ViewController.appStateChangedNotification,
//                                            object: self,
//                                            userInfo: [ViewController.appStateUserInfoKey: self.state])
//        }
//    }
    
    var body: some View {
        ZStack {
            ARViewContainer()

            VStack {
                contentBasedOnState
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("Done pressed")
                    }) {
                        Text("Done")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.all, 20)
            }
            .padding(.top, 10)
        }
        .navigationBarTitle("Machine Scan", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
}
