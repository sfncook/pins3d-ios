import SwiftUI
import ARKit
import CoreData

class ScanningFacilityViewModel: ObservableObject {
    
    @Published var showCreateAreaFragment: Bool = false
    @Published var showCreatePinTypeFragment: Bool = false
    @Published var isPlacingPin: Bool = false
    
    var facility: Facility? = nil
    let viewContext: NSManagedObjectContext
    
    init(facility: Facility?, viewContext: NSManagedObjectContext) {
        print("ScanningAndAnnotatingFacilityViewModel.init")
        self.facility = facility
        self.viewContext = viewContext
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showCreateAreaFragment = self.facility == nil
        }
    }
    
    func createNewFacility(facilityName: String) {
        facility = Facility(context: viewContext)
        facility!.id = UUID()
        facility!.name = facilityName
        saveFacility()
    }
    
    func saveFacility() {
        do {
            try viewContext.save()
            print("Facility saved \(self.facility?.name!)")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func dropPin() {
        withAnimation {
            showCreateAreaFragment.toggle()
        }
    }
}
