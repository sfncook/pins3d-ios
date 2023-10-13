import SwiftUI

struct CreateMachineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var machineName: String = ""
    @State private var showScanningMachineView = false
    @State private var newMachine: Machine? = nil
    
    var body: some View {
        if self.showScanningMachineView {
            ScanningMachineView(newMachine!)
        } else {
            VStack(spacing: 20) {
                TextField("Enter machine name", text: $machineName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button(action: {
                    self.newMachine = saveNewMachine()
                    self.showScanningMachineView = true
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
