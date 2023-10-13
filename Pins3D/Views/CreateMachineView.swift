import SwiftUI

struct CreateMachineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var machineName: String = ""
    @Binding var createdMachine: Machine?
    @Binding var showPickModuleTypeView: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter machine name", text: $machineName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                saveNewMachine()
                showPickModuleTypeView = false
            }) {
                Text("Machine Scan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            .navigationBarTitle("Machine name?", displayMode: .inline)
            
            Spacer()
        }
        .padding(.vertical)
        .onAppear{
            print("CreateMachineView.onAppear")
        }
    }
    
    private func saveNewMachine() {
        createdMachine = Machine(context: viewContext)
        createdMachine!.id = UUID()
        createdMachine!.name = self.machineName

        do {
            try viewContext.save()
            print("Machine saved \(self.machineName) \(createdMachine!.name!)")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
