//
//  CatalogView.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/10/23.
//

import SwiftUI
import CoreData

struct CatalogView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MyItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MyItem>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Facility.name, ascending: true)],
        animation: .default)
    private var facilities: FetchedResults<Facility>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Machine.name, ascending: true)],
        animation: .default)
    private var machines: FetchedResults<Machine>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Procedure.name, ascending: true)],
        animation: .default)
    private var procedures: FetchedResults<Procedure>
    
    private var title: String
    
    @State private var showPickModuleTypeView = false
    @State private var showSelectedMachineView = false
    @State private var selectedMachine: Machine?
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        if self.showPickModuleTypeView {
            NavigationLink(destination: PickModuleTypeView(), isActive: $showPickModuleTypeView) {
                EmptyView()
            }
        } else if self.showSelectedMachineView {
            NavigationLink(destination: ScanningMachineView(self.selectedMachine!), isActive: $showSelectedMachineView) {
                EmptyView()
            }
        } else {
            VStack {
                
                List {
                    ForEach(facilities) { facility in
                        NavigationLink {
                            Text(facility.name!)
                        } label: {
                            Text(facility.name!)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                
                List {
                    ForEach(machines) { machine in
                        Button(action: {
                            self.selectedMachine = machine
                            self.showSelectedMachineView = true
                        })  {
                            Text(machine.name!)
                        }
                    }
                    .onDelete(perform: deleteMachines)
                }
                List {
                    ForEach(procedures) { procedure in
                        NavigationLink {
                            Text(procedure.name!)
                        } label: {
                            Text(procedure.name!)
                        }
                    }
                    .onDelete(perform: deleteProcedures)
                }
                .navigationBarTitle(self.title, displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                            // 4. Trigger navigation when the button is pressed
                            self.showPickModuleTypeView = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                
                Spacer()
            }// VStack
        }
    }

    private func deleteMachines(offsets: IndexSet) {
        withAnimation {
            offsets.map { machines[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteProcedures(offsets: IndexSet) {
        withAnimation {
            offsets.map { procedures[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = MyItem(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
