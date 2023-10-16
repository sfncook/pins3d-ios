import SwiftUI
import CoreData

struct AreasListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Facility.name, ascending: true)],
        animation: .default)
    var facilities: FetchedResults<Facility>
    
    @State private var selectedFacility: Facility?
    
    var body: some View {
        VStack {
            List {
                ForEach(facilities) { facility in
                    Button(action: {
                        self.selectedFacility = facility
//                        self.showScanningFacilityView = true
//                        self.showAnnotatingMachineView = false
//                        self.showScanningMachineView = false
                    })  {
                        Text("\(facility.name!) - \(facility.worldMapFilename ?? "NO World Map Filename")")
                    }
                }
                .onDelete(perform: deleteFacilities)
            }
            .navigationBarTitle("All Areas", displayMode: .inline)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        self.selectedFacility = nil
//                        self.showPickModuleTypeView = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            
            Spacer()
        }// VStack
        
    }// body: View
    
    func deleteFacilities(offsets: IndexSet) {
        withAnimation {
            offsets.map { facilities[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
