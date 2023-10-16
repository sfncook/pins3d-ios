import SwiftUI
import CoreData

struct AreasListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Facility.name, ascending: true)],
        animation: .default)
    var facilities: FetchedResults<Facility>
    
    @State private var selectedFacility: Facility?
    @State private var showScanningFacilityView: Bool = false
    
    var body: some View {
        if(self.showScanningFacilityView) {
            ScanningFacilityView(
                facility: self.selectedFacility,
                showScanningFacilityView: $showScanningFacilityView,
                viewContext: viewContext
            )
        } else {
            NavigationView {
                VStack {
                    List {
                        ForEach(facilities) { facility in
                            Button(action: {
                                self.selectedFacility = facility
                                self.showScanningFacilityView = true
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
                                self.showScanningFacilityView = true
                            }) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
                    
                    Spacer()
                }// VStack
            }// NavigationView
        }// else
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
