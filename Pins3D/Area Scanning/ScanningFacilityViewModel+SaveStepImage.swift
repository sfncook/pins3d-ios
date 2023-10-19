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
    func uploadStepImage(stepImageFilename: String, stepImage: UIImage) {
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
}
