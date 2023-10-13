import SwiftUI

struct CreateMachineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var machineName: String = ""
    @Binding var createdMachine: Machine?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter machine name", text: $machineName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                createdMachine = saveNewMachine()
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
    
    private func saveNewMachine() -> Machine {
        let newMachine = Machine(context: viewContext)
        newMachine.id = UUID()
        newMachine.name = self.machineName

        do {
            try viewContext.save()
            print("Machine saved \(self.machineName)")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return newMachine
    }
}
