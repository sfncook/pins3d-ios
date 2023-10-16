import SwiftUI
import ARKit

extension ScanningAndAnnotatingFacilityViewModel {
    func convertToCamelCase(_ input: String) -> String {
        // Remove all non-alphanumeric characters
        let alphanumericString = input.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        
        // Convert string to a list of words
        let words = alphanumericString.split(separator: " ")
        
        // Capitalize the first letter of each word except the first one and combine
        var camelCaseString = words.first?.lowercased() ?? ""
        for word in words.dropFirst() {
            camelCaseString += word.capitalized
        }
        
        return "facility_\(camelCaseString)"
    }
    
    func onSaveWorld() {
        NotificationCenter.default.post(name: ScanningAndAnnotatingFacilityViewModel.getWorldMapNotification,
                                        object: self,
                                        userInfo: [ScanningAndAnnotatingFacilityViewModel.worldMapReadyCallback: self])
    }
    
    func saveWorldMapAndUpload(worldMapFilename: String, worldMap: ARWorldMap, completionHandler: @escaping () -> Void) {
//        self.displayInstruction(Message("Saving..."))
        print("saveWorldMapAndUpload")
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
            let url = URL(string: "https://us-central1-cook-250617.cloudfunctions.net/ar-model/\(worldMapFilename)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    print("Error uploading worldMap: \(error.localizedDescription)")
//                    self.savingMsg = "Error uploading worldMap"
                } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Received response: \(responseString)") //{"filename":"test1","success":true}
                    // TODO: How to save anchors/pins?
//                    self.saveSidesObject()
                }
                completionHandler()
            }
            task.resume()
        } catch {
//            self.displayInstruction(Message("Error saving referenceObject"))
            print("Can't save worldMap: \(error.localizedDescription)")
//            self.savingMsg = "Can't save referenceObject"
            completionHandler()
        }
    }
    func worldMapReady(worldMap: ARWorldMap) {
//        self.showSavingMsg = true
        let msg = "Saving AR Ref file..."
        print(msg)
//        self.savingMsg = msg
        let worldMapFilename = convertToCamelCase(facility.name!)
        saveWorldMapAndUpload(worldMapFilename: worldMapFilename, worldMap: worldMap) {
            let msg = "Updating facility info..."
            print(msg)
            DispatchQueue.main.async {
//                self.savingMsg = msg
            }
            self.facility.worldMapFilename = worldMapFilename
            let context = self.facility.managedObjectContext
            do {
                try context?.save()
                DispatchQueue.main.async {
//                    self.showScanningMachineView = false
//                    self.showAnnotatingMachineView = true
                }
                print("Done saving")
            } catch {
                print("ERROR saveMachineAndRefObjectFile Failed to save arFilename to machine: \(error)")
//                self.savingMsg = "Error saving machine info"
            }
        }
    }
}

protocol WorldMapReadyCallback {
    func worldMapReady(worldMap: ARWorldMap)
}
