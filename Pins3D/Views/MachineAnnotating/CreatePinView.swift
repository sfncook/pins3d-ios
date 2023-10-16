import SwiftUI

struct CreatePinView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var pinText: String = ""
    @Binding var createdPin: TextPin?
    @Binding var showCreatePinView: Bool
    
    let viewModel: AnnotatingMachineViewModel
    let x: Float
    let y: Float
    let z: Float
    
    init(
        viewModel: AnnotatingMachineViewModel,
        x: Float,
        y: Float,
        z: Float,
        showCreatePinView: Binding<Bool>,
        createdPin: Binding<TextPin?>
    ) {
        self.viewModel = viewModel
        self.x = x
        self.y = y
        self.z = z
        self._showCreatePinView = showCreatePinView
        self._createdPin = createdPin
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter pin text", text: $pinText)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                saveNewPin()
                showCreatePinView = false
            }) {
                Text("Drop a Text Pin")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            .navigationBarTitle("Pin Info?", displayMode: .inline)
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    private func saveNewPin() {
        createdPin = TextPin(context: viewContext)
        createdPin!.id = UUID()
        createdPin!.text = self.pinText
        createdPin!.x = self.x
        createdPin!.y = self.y
        createdPin!.z = self.z
        
        viewModel.addPinYoMama(pin: createdPin!)

        do {
            try viewContext.save()
            print("Pin saved text:\(createdPin?.text ?? "NOT_SET")")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Create Pin unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
