import SwiftUI

struct PickModuleTypeView: View {
    @Binding var selectedModuleTypeToCreate: String
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                self.selectedModuleTypeToCreate = CatalogView.ModuleType.facility.rawValue
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
                self.selectedModuleTypeToCreate = CatalogView.ModuleType.machine.rawValue
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
                self.selectedModuleTypeToCreate = CatalogView.ModuleType.procedure.rawValue
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
