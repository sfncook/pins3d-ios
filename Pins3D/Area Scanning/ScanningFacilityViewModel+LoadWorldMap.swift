import SwiftUI
import ARKit

extension ScanningFacilityViewModel {
    func loadWorldMap() {
        var msg = "ScanningAndAnnotatingFacilityViewModel.loadWorldMap"
        print(msg)
//        self.loadingMsg = msg
//        showStartLoadButtons = false
//        self.isModelLoading = true
        
        // Load referenceObject w/out annotations - WORKING
        guard let worldMapFilename = facility?.worldMapFilename else {
            print("ScanningAndAnnotatingFacilityViewModel.loadWorldMap facility.worldMapFilename is nil")
            return
        }
        let urlStr = "https://us-central1-cook-250617.cloudfunctions.net/ar-model/\(worldMapFilename)"
        let url = URL(string: urlStr)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                msg = "Error downloading worldMap: \(error!)"
                print(msg)
//                DispatchQueue.main.async {
//                    self.loadingMsg = msg
//                }
                return
            }

            guard let data = data else {
                msg = "No data returned from the server!"
                print(msg)
//                DispatchQueue.main.async {
//                    self.loadingMsg = msg
//                }
                return
            }

            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
                    msg = "No ARWorldMap in archive."
                    print(msg)
//                    DispatchQueue.main.async {
//                        self.loadingMsg = msg
//                    }
                    return
                }
                
                self.coordinator.loadWorldMap(worldMap)
                
                msg = "Done Loading"
                print(msg)
//                DispatchQueue.main.async {
//                    self.loadingMsg = msg
//                    self.hasModelBeenLoaded = true
//                }
            } catch {
                msg = "Error unarchiving ARReferenceObject: \(error)"
                print(msg)
//                self.loadingMsg = msg
            }
//            DispatchQueue.main.async {
//                self.isModelLoading = false
//            }
        }

        task.resume()
    }
}
