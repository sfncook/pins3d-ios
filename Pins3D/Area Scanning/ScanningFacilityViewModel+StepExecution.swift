import SwiftUI
import ARKit
import CoreData

extension ScanningFacilityViewModel {
    func startExecutingProcedure(procedure: Procedure) {
        if let stepsSet = procedure.steps as? Set<Step> {
            let firstStep = stepsSet.min { $0.number < $1.number }
            guard let firstStep = firstStep else {return}
            self.executingProcedure = procedure
            self.executingStep = firstStep
            coordinator.showAllStepPinsForProcedure(highlightStep: firstStep, procedure: procedure)
            updateHasNextPrev()
        }
    }
    
    func nextStep() {
        guard let procedure = self.executingProcedure else { return }
        guard let curStep = self.executingStep else { return }
        guard let stepsSet = procedure.steps as? Set<Step> else { return }
        
        let nextStep = stepsSet.first {
            print("curStep.number:\(curStep.number) \($0.number)")
            return $0.number == curStep.number+1
        }
        guard let nextStep = nextStep else {
            // TODO: End procedure
            return
        }
        coordinator.showAllStepPinsForProcedure(highlightStep: nextStep, procedure: procedure)
        self.executingStep = nextStep
        updateHasNextPrev()
    }
    
    func prevStep() {
        guard let procedure = self.executingProcedure else { return }
        guard let curStep = self.executingStep else { return }
        guard let stepsSet = procedure.steps as? Set<Step> else { return }
        
        let nextStep = stepsSet.first {
            print("curStep.number:\(curStep.number) \($0.number)")
            return $0.number == curStep.number-1
        }
        guard let nextStep = nextStep else {
            // TODO: End procedure
            return
        }
        coordinator.showAllStepPinsForProcedure(highlightStep: nextStep, procedure: procedure)
        self.executingStep = nextStep
        updateHasNextPrev()
    }
    
    func updateHasNextPrev() {
        guard let curStep = executingStep else {return}
        guard let procedure = executingProcedure else {return}
        let manySteps = procedure.steps?.count ?? 0
        let curStepNumber = curStep.number
        self.hasNextStep = curStepNumber < manySteps
        self.hasPrevStep = curStepNumber > 1
    }
    
    func stopExecutingProcedure() {
        self.executingProcedure = nil
        self.executingStep = nil
        self.panCameraDirection = nil
        coordinator.showAllAreaPins()
    }
    
    func doneCreatingStepsForProcedure() {
        DispatchQueue.main.async {
            self.isPlacingStepPin = false
            self.coordinator.showAllAreaPins()
            self.creatingProcedure = nil
            self.saveWorldMap()
            if let facility = self.facility {
                self.preloadAllImages(facility: facility)
            }
        }
    }
}
