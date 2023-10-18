import SwiftUI
import ARKit
import CoreData

extension ScanningFacilityViewModel {
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
    
    func saveFacility() {
        do {
            try viewContext.save()
            print("Facility saved \(self.facility?.name! ?? "Facility Name NOT SET")")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func uploadWorldMap(worldMapFilename: String, worldMap: ARWorldMap, completionHandler: @escaping () -> Void) {
//        self.displayInstruction(Message("Saving..."))
        print("Uploading WorldMap")
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
    
    func saveWorldMap() {
        self.startTimerInfoMsg(infoMsg: "Saving Area Map")
        coordinator.getWorldMap { worldMap in
            guard let facility = self.facility else {
                print("Error: Facility is nil, unable to save")
                return
            }
            
            guard let worldMap = worldMap else {
                print("Error: WorldMap nil, unable to save")
                return
            }
            
            let worldMapFilename = self.convertToCamelCase(facility.name!)
            self.uploadWorldMap(worldMapFilename: worldMapFilename, worldMap: worldMap) {
                let msg = "Saving facility CoreData info..."
                print(msg)
                DispatchQueue.main.async {
    //                self.savingMsg = msg
                }
                facility.worldMapFilename = worldMapFilename
                let context = facility.managedObjectContext
                do {
                    try context?.save()
                    DispatchQueue.main.async {
    //                    self.showScanningMachineView = false
    //                    self.showAnnotatingMachineView = true
                    }
                    print("Done saving")
                    self.startTimerInfoMsg(infoMsg: "Save Complete")
                } catch {
                    print("ERROR saveMachineAndRefObjectFile Failed to save arFilename to machine: \(error)")
    //                self.savingMsg = "Error saving machine info"
                }
            }
        }
    }
}
