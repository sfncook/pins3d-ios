//
//  ScanningMachineViewModel+SaveModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/12/23.
//

import SwiftUI
import ARKit
import CoreData

extension ScanningMachineViewModel {
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
        
        return camelCaseString
    }
    
    func defaultArFilename() -> String {
        let epochMillis = Int(Date().timeIntervalSince1970 * 1000)
        let epochString = String(epochMillis)
        return "arRefObj_\(epochString)"
    }
    
    func saveArModelAndUpload(arObjectFilename: String, referenceObject: ARReferenceObject, completionHandler: @escaping () -> Void) {
//        self.displayInstruction(Message("Saving..."))
        print("Saving referenceObject file")

        // Save referenceObject w/out annotations - WORKING
        do {
//            guard let testRun = self.testRun, let object = testRun.referenceObject
//            else {
//                print("can't get refObject")
//                self.displayInstruction(Message("Error: couldn't get the referenceObject"))
//                return
//            }
            let data = try NSKeyedArchiver.archivedData(withRootObject: referenceObject, requiringSecureCoding: true)
            let url = URL(string: "https://us-central1-cook-250617.cloudfunctions.net/ar-model/\(arObjectFilename)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    print("Error uploading referenceObject: \(error.localizedDescription)")
                    self.savingMsg = "Error uploading referenceObject"
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
            print("Can't save referenceObject: \(error.localizedDescription)")
            self.savingMsg = "Can't save referenceObject"
            completionHandler()
        }
    }
    
    func referenceObjectReady(referenceObject: ARReferenceObject) {
        self.showSavingMsg = true
        self.savingMsg = "Saving AR Ref file..."
        let arObjectFilename = convertToCamelCase(machine.name ?? defaultArFilename())
        saveArModelAndUpload(arObjectFilename: arObjectFilename, referenceObject: referenceObject) {
            self.savingMsg = "Updating machine info..."
            self.machine.arFilename = arObjectFilename
            let context = self.machine.managedObjectContext
            do {
                try context?.save()
                self.savingMsg = "Done."
            } catch {
                print("ERROR saveMachineAndRefObjectFile Failed to save arFilename to machine: \(error)")
                self.savingMsg = "Error saving machine info"
            }
        }
    }
}

protocol CreateArRefModelCallback {
    func referenceObjectReady(referenceObject: ARReferenceObject)
}
