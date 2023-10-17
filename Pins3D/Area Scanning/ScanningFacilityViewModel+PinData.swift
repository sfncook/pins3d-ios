import SwiftUI
import ARKit
import CoreData

extension ScanningFacilityViewModel {
    func fetchTextPin(pinId: String) -> TextPin? {
        let fetchRequest: NSFetchRequest<TextPin> = TextPin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", pinId as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let foundTextPin = results.first {
                return foundTextPin
            } else {
                print("No TextPin with the given id was found.")
            }
        } catch {
            print("Failed to fetch TextPin with error: \(error)")
        }
        return nil
    }
    
    func fetchProcedurePin(pinId: String) -> ProcedurePin? {
        let fetchRequest: NSFetchRequest<ProcedurePin> = ProcedurePin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", pinId as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let foundPin = results.first {
                return foundPin
            } else {
                print("No ProcedurePin with the given id was found.")
            }
        } catch {
            print("Failed to fetch ProcedurePin with error: \(error)")
        }
        return nil
    }
    
    func fetchStepPin(pinId: String) -> StepPin? {
        let fetchRequest: NSFetchRequest<StepPin> = StepPin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", pinId as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let foundPin = results.first {
                return foundPin
            } else {
                print("No StepPin with the given id was found.")
            }
        } catch {
            print("Failed to fetch StepPin with error: \(error)")
        }
        return nil
    }
    
    func fetchStepPinsForProcedure(procedure: Procedure) -> [StepPin] {
        let fetchRequest: NSFetchRequest<StepPin> = StepPin.fetchRequest()

        // Set a predicate to fetch StepPin entities that are related to the given Procedure
        fetchRequest.predicate = NSPredicate(format: "procedure == %@", procedure)

        do {
            let stepPins = try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch StepPin entities with error: \(error)")
        }
        return []
    }
    
    /* This method does two things that results in a new pin:
     *  1.) It captures the current 3D position of the pin cursor in the environment
     *  2.) It opens the "CreatePinTypeFragment" - which is another class and that class
     *      is what actually creates the pin.  That fragment shares THIS view model and will
     *      call addTextPin() or addProcedurePin() (see below)
     *  NOTE: The addTextPin and addProcedurePin functions (below) call the coordinator to add the pin node
     */
    func dropPin() {
        pinCursorLocationWhenDropped = coordinator.getPinCursorLocation()
        if self.isPlacingStepPin {
            withAnimation {
                showCreateStepFragment.toggle()
            }
        } else {
            withAnimation {
                showCreatePinTypeFragment.toggle()
            }
        }
    }
    
    func addTextPin(pinText: String) {
        guard let pinCursorLocationWhenDropped = self.pinCursorLocationWhenDropped else {
            print("Unable to retrieve pinCursorLocationWhenDropped, perhaps it's nil")
            return
        }
        let textPin = createAndSaveNewTextPin(pinText: pinText)
        coordinator.addPin(pin: textPin, transform: pinCursorLocationWhenDropped)
    }
    
    func addProcedurePin(pinText: String) {
        guard let pinCursorLocationWhenDropped = self.pinCursorLocationWhenDropped else {
            print("Unable to retrieve pinCursorLocationWhenDropped, perhaps it's nil")
            return
        }
        let procedurePin = createAndSaveNewProcedurePin(pinText: pinText)
        
        // Add pin to scene
        coordinator.addPin(pin: procedurePin, transform: pinCursorLocationWhenDropped)
        
        // Now that we have created the procedure and added the ProcedurePin to the scene
        //   let's go back to the ARView and start adding StepPins for this procedure
        let procedure = Procedure(context: viewContext)
        procedure.id = UUID()
        procedure.name = pinText

        do {
            try viewContext.save()
            startAddingStepPinsForProcedure(procedure)
            print("Procedure saved:\(procedure.name ?? "NOT_SET")")
        } catch {
            let nsError = error as NSError
            fatalError("Create Procedure unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func startAddingStepPinsForProcedure(_ procedure: Procedure) {
        self.creatingProcedure = procedure
        self.creatingStepNumber = 1 // Initialize step number
        self.isPlacingStepPin = true
        if let creatingProcedure = self.creatingProcedure {
            coordinator.showOnlyStepPinsForProcedure(procedure: creatingProcedure)
        }
    }
    
    func addStepPin(
        stepSummary: String,
        stepDetails: String
    ) {
        guard let pinCursorLocationWhenDropped = self.pinCursorLocationWhenDropped else {
            print("Unable to retrieve pinCursorLocationWhenDropped, perhaps it's nil")
            return
        }
        let stepPin = createAndSaveNewStepPin(stepSummary: stepSummary)
        
        // Add pin to scene
        coordinator.addPin(pin: stepPin, transform: pinCursorLocationWhenDropped)
        
        // Now that we have created the procedure and added the ProcedurePin to the scene
        //   let's go back to the ARView and start adding StepPins for this procedure
        let step = Step(context: viewContext)
        step.id = UUID()
        step.summary = stepSummary
        step.details = stepDetails
        step.number = Int16(self.creatingStepNumber)
        
        self.creatingProcedure?.addToSteps(step)

        do {
            try viewContext.save()
            self.creatingStepNumber += 1
            print("Step #\(step.number) saved")
        } catch {
            let nsError = error as NSError
            fatalError("Create Step unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func createAndSaveNewTextPin(pinText: String) -> TextPin {
        let textPin = TextPin(context: viewContext)
        textPin.id = UUID()
        textPin.text = pinText

        do {
            try viewContext.save()
            print("Pin saved text:\(textPin.text ?? "NOT_SET")")
        } catch {
            let nsError = error as NSError
            fatalError("Create Pin unresolved error \(nsError), \(nsError.userInfo)")
        }
        return textPin
    }
    
    func createAndSaveNewProcedurePin(pinText: String) -> ProcedurePin {
        let procedurePin = ProcedurePin(context: viewContext)
        procedurePin.id = UUID()
        procedurePin.text = pinText

        do {
            try viewContext.save()
            print("Pin saved text:\(procedurePin.text ?? "NOT_SET")")
        } catch {
            let nsError = error as NSError
            fatalError("Create Pin unresolved error \(nsError), \(nsError.userInfo)")
        }
        return procedurePin
    }
    
    func createAndSaveNewStepPin(stepSummary: String) -> StepPin {
        let stepPin = StepPin(context: viewContext)
        stepPin.id = UUID()
        stepPin.text = stepSummary
        stepPin.number = Int16(creatingStepNumber)
        stepPin.procedure = self.creatingProcedure

        do {
            try viewContext.save()
            print("Pin saved text:\(stepPin.text ?? "NOT_SET")")
        } catch {
            let nsError = error as NSError
            fatalError("Create Pin unresolved error \(nsError), \(nsError.userInfo)")
        }
        return stepPin
    }
}
