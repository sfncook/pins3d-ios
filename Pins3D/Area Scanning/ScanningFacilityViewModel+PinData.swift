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
        let fetchRequest: NSFetchRequest<Step> = Step.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "procedure == %@", procedure)
        do {
            let steps = try viewContext.fetch(fetchRequest)
            return steps.compactMap { $0.pin }
        } catch {
            print("Failed to fetch Step entities with error: \(error)")
        }
        return []
    }
    
    func fetchProcedure(procedureId: UUID) -> Procedure? {
        let fetchRequest: NSFetchRequest<Procedure> = Procedure.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", procedureId as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let found = results.first {
                return found
            } else {
                print("No Procedure with the given id was found.")
            }
        } catch {
            print("Failed to fetch Procedure with error: \(error)")
        }
        return nil
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
        
        // Now that we have created the procedure and added the ProcedurePin to the scene
        //   let's go back to the ARView and start adding StepPins for this procedure
        let procedure = Procedure(context: viewContext)
        procedure.id = UUID()
        procedure.name = pinText

        do {
            try viewContext.save()
            
            let procedurePin = ProcedurePin(context: viewContext)
            procedurePin.id = UUID()
            procedurePin.text = pinText
            procedurePin.procedureId = procedure.id
            procedurePin.procedure = procedure
            procedure.pin = procedurePin

            do {
                try viewContext.save()
                print("Pin saved text:\(procedurePin.text ?? "NOT_SET")")
                
                // Add pin to scene
                coordinator.addPin(pin: procedurePin, transform: pinCursorLocationWhenDropped)
                
                startAddingStepPinsForProcedure(procedure)
            } catch {
                let nsError = error as NSError
                fatalError("(2) Create Pin unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            // Add pin to scene
            coordinator.addPin(pin: procedurePin, transform: pinCursorLocationWhenDropped)
            
            startAddingStepPinsForProcedure(procedure)
        } catch {
            let nsError = error as NSError
            fatalError("(1) Create Pin unresolved error \(nsError), \(nsError.userInfo)")
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
        
        // Now that we have created the procedure and added the ProcedurePin to the scene
        //   let's go back to the ARView and start adding StepPins for this procedure
        let step = Step(context: viewContext)
        step.id = UUID()
        step.summary = stepSummary
        step.details = stepDetails
        step.number = Int16(self.creatingStepNumber)
        step.procedure = self.creatingProcedure
        
        self.creatingProcedure?.addToSteps(step)
        
        let stepPin = StepPin(context: viewContext)
        stepPin.id = UUID()
        stepPin.text = stepSummary
        stepPin.number = Int16(creatingStepNumber)
        stepPin.step = step
        step.pin = stepPin


        do {
            try viewContext.save()
            self.creatingStepNumber += 1
            print("Step #\(step.number) saved")
            coordinator.addPin(pin: stepPin, transform: pinCursorLocationWhenDropped)
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
}
