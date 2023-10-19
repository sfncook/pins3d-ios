import SwiftUI
import CoreData

extension ScanningFacilityViewModel {
    func getStepImageFilename(_ step: Step) -> String? {
        let stepSummaryId = step.summary ?? "\(step.id!)"
        guard let procedure = step.procedure else {
            self.setSavingMsg(savingMsg: "Error (StepImage-3)", withTimeout: true)
            return nil
        }
        let procedureNameId = procedure.name ?? "\(procedure.id!)"
        return "stepimage_\(convertToCamelCase(procedureNameId))_\(stepSummaryId)"
    }
    
    func saveStepImage(stepImageFilename: String, stepImage: UIImage) {
        print("Uploading StepImage")
        self.setSavingMsg(savingMsg: "Uploading Image")
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: stepImage, requiringSecureCoding: true)
            let url = URL(string: "https://us-central1-cook-250617.cloudfunctions.net/ar-model/\(stepImageFilename)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    print("Error uploading stepImage: \(error.localizedDescription)")
                    self.setSavingMsg(savingMsg: "Error (StepImage-1)", withTimeout: true)
                } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Received response: \(responseString)") //{"filename":"test1","success":true}
                    self.clearTimerSavingMsg()
                }
            }
            task.resume()
        } catch {
            print("Can't save step iamge: \(error.localizedDescription)")
            self.setSavingMsg(savingMsg: "Error (StepImage-2)", withTimeout: true)
        }
    }
    
    func loadStepImage(stepImageName: String, completionHandler: @escaping (UIImage) -> Void) {
        var msg = "loadStepImage"
        print(msg)
        
        let urlStr = "https://us-central1-cook-250617.cloudfunctions.net/ar-model/\(stepImageName)"
        let url = URL(string: urlStr)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                msg = "Error downloading step image: \(error!)"
                print(msg)
                return
            }

            guard let data = data else {
                msg = "No data returned from the server!"
                print(msg)
                return
            }

            do {
                guard let stepImage = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: data) else {
                    msg = "No Step Image in archive."
                    print(msg)
                    return
                }
                completionHandler(stepImage)
            } catch {
                msg = "Error loading Step Image: \(error)"
                print(msg)
            }
        }

        task.resume()
    }// loadStepImage
}
