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
    
    func dropPin() {
        pinCursorLocationWhenDropped = coordinator.getPinCursorLocation()
        withAnimation {
            // Show
            showCreatePinTypeFragment.toggle()
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
    
    func addTextPin(pinText: String) {
        guard let pinCursorLocationWhenDropped = self.pinCursorLocationWhenDropped else {
            print("Unable to retrieve pinCursorLocationWhenDropped, perhaps it's nil")
            return
        }
        let textPin = createAndSaveNewTextPin(pinText: pinText)
        coordinator.addPin(pin: textPin, transform: pinCursorLocationWhenDropped)
    }
    
    func addProcedurePin(pinTest: String) {
        // TODO: Create ProcedurePin, add to scene
    }
}
