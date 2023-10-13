//
//  AnnotatingMachineViewViewModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/12/23.
//

import SwiftUI
import ARKit

class AnnotatingMachineViewViewModel: ObservableObject {
    static let loadModelNotification = Notification.Name("LoadModel")
    static let referenceObjectKey = "referenceObjectKey"
    
    @Published var showStartLoadButtons: Bool = true
    @Published var showDropPinButtons: Bool = false
    
    var machine: Machine
    
    init(machine: Machine) {
//        print("AnnotatingMachineViewViewModel.init \(machine.name!) \(machine.arFilename ?? "NO AR Filename")")
        self.machine = machine
    }
    
    func loadModel() {
        print("loading file")
        showStartLoadButtons = false
//        self.displayInstruction(Message("Loading..."))
        
        // Load referenceObject w/out annotations - WORKING
        let arFilename = machine.arFilename!
//        print("AnnotatingMachineViewViewModel.loadModel \(machine.name!) \(arFilename)")
        let urlStr = "https://us-central1-cook-250617.cloudfunctions.net/ar-model/\(arFilename)"
        let url = URL(string: urlStr)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                print("Error downloading test file: \(error!)")
//                self.displayInstruction(Message("Error downloading test file: \(error!)"))
//                self.displayInstruction(Message("Error downloading file"))
                return
            }

            guard let data = data else {
                print("No data returned from the server!")
//                self.displayInstruction(Message("Error: No data returned from the server"))
                return
            }

            do {
                guard let referenceObject = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARReferenceObject.self, from: data) else {
//                    self.displayInstruction(Message("Error: No ARReferenceObject in archive"))
                    fatalError("No ARReferenceObject in archive.")
                }
                
                NotificationCenter.default.post(name: AnnotatingMachineViewViewModel.loadModelNotification,
                                                object: self,
                                                userInfo: [AnnotatingMachineViewViewModel.referenceObjectKey: referenceObject])
            } catch {
                print("Error unarchiving ARReferenceObject: \(error)")
//                self.displayInstruction(Message("Error, the big one. Not sure what happened"))
            }
        }

        task.resume()
    }
}
