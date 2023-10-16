//
//  AnnotatingMachineViewViewModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/12/23.
//

import SwiftUI
import ARKit

extension AnnotatingMachineViewModel {
    
    func loadModel() {
        var msg = "Loading file"
        print(msg)
        self.loadingMsg = msg
        showStartLoadButtons = false
        self.isModelLoading = true
        
        // Load referenceObject w/out annotations - WORKING
        let arFilename = machine.arFilename!
        let urlStr = "https://us-central1-cook-250617.cloudfunctions.net/ar-model/\(arFilename)"
//        let urlStr = "https://us-central1-cook-250617.cloudfunctions.net/ar-model/referenceObject1"
        let url = URL(string: urlStr)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                msg = "Error downloading test file: \(error!)"
                print(msg)
                DispatchQueue.main.async {
                    self.loadingMsg = msg
                }
                return
            }

            guard let data = data else {
                msg = "No data returned from the server!"
                print(msg)
                DispatchQueue.main.async {
                    self.loadingMsg = msg
                }
                return
            }

            do {
                guard let referenceObject = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARReferenceObject.self, from: data) else {
                    msg = "No ARReferenceObject in archive."
                    print(msg)
                    DispatchQueue.main.async {
                        self.loadingMsg = msg
                    }
                    return
                }
                
                NotificationCenter.default.post(name: AnnotatingMachineViewModel.loadModelNotification,
                                                object: self,
                                                userInfo: [AnnotatingMachineViewModel.referenceObjectKey: referenceObject])
                msg = "Done Loading"
                print(msg)
                DispatchQueue.main.async {
                    self.loadingMsg = msg
                    self.hasModelBeenLoaded = true
                }
            } catch {
                msg = "Error unarchiving ARReferenceObject: \(error)"
                print(msg)
                self.loadingMsg = msg
            }
            DispatchQueue.main.async {
                self.isModelLoading = false
            }
        }

        task.resume()
    }
}
