import SwiftUI

struct PickModuleTypeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedType: CatalogView.ModuleType?
    @Binding var createdMachine: Machine?
    @Binding var showPickModuleTypeView: Bool
    
    var body: some View {
        if self.selectedType == CatalogView.ModuleType.machine {
            CreateMachineView(
                createdMachine: $createdMachine,
                showPickModuleTypeView: $showPickModuleTypeView
            )
        } else {
            VStack(spacing: 20) {
                Button(action: {
                    print("Click facility")
                    selectedType = .facility
                })  {
                    Text("Facility Scan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Button(action: {
                    print("Click machine")
                    selectedType = .machine
                })  {
                    Text("Machine Scan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Button(action: {
                    print("Click procedure")
                    selectedType = .procedure
                })  {
                    Text("Procedure")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                .navigationBarTitle("Module type?", displayMode: .inline)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}
