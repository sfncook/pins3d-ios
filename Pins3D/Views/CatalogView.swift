//
//  CatalogView.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/10/23.
//

import SwiftUI
import CoreData

struct CatalogView: View {
    @Environment(\.managedObjectContext) var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MyItem.timestamp, ascending: true)],
        animation: .default)
    var items: FetchedResults<MyItem>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Facility.name, ascending: true)],
        animation: .default)
    var facilities: FetchedResults<Facility>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Machine.name, ascending: true)],
        animation: .default)
    var machines: FetchedResults<Machine>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Procedure.name, ascending: true)],
        animation: .default)
    var procedures: FetchedResults<Procedure>
    
    enum ModuleType: String {
        case facility
        case machine
        case procedure
    }
    
    private var title: String
    
    @State private var showPickModuleTypeView = false
    @State private var showScanningFacilityView = false
    @State private var showScanningMachineView = false
    @State private var showAnnotatingMachineView = false
    @State private var selectedFacility: Facility?
    @State private var selectedMachine: Machine?
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        if(self.showScanningFacilityView) {
            ScanningAndAnnotatingFacilityView(
                facility: self.selectedFacility!,
                showScanningFacilityView: $showScanningFacilityView
            )
        } else if(self.showAnnotatingMachineView) {
            AnnotatingMachineView(
                self.selectedMachine!,
                showAnnotatingMachineView: $showAnnotatingMachineView
            )
        } else {
            VStack {
                
                List {
                    ForEach(facilities) { facility in
                        Button(action: {
                            self.selectedFacility = facility
                            self.showScanningFacilityView = true
                            self.showAnnotatingMachineView = false
                            self.showScanningMachineView = false
                        })  {
                            Text(facility.name!)
                        }
                    }
                    .onDelete(perform: deleteFacilities)
                }
                
                List {
                    ForEach(machines) { machine in
                        Button(action: {
                            self.selectedMachine = machine
                            self.showScanningFacilityView = false
                            self.showAnnotatingMachineView = true
                            self.showScanningMachineView = false
                        })  {
                            Text("\(machine.name!) \(machine.arFilename ?? "NO AR Filename")")
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
                            self.showPickModuleTypeView = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                        .sheet(isPresented: $showPickModuleTypeView, onDismiss: {
                            print("PickModuleTypeView was dismissed")
                            self.showScanningFacilityView = self.selectedFacility != nil
                            self.showScanningMachineView = self.selectedMachine != nil
                        }) {
                            PickModuleTypeView(
                                createdFacility: $selectedFacility,
                                createdMachine: $selectedMachine,
                                showPickModuleTypeView: $showPickModuleTypeView
                            )
                        }
                    }
                }
                
                Spacer()
            }// VStack
            
            .fullScreenCover(isPresented: $showScanningMachineView, onDismiss: {
                print("ScanningMachineView was dismissed")
            }) {
                ScanningMachineView(
                    self.selectedMachine!,
                    showScanningMachineView: $showScanningMachineView,
                    showAnnotatingMachineView: $showAnnotatingMachineView
                )
            }
        }
        
    }// body: View
}// struct CatalogView
