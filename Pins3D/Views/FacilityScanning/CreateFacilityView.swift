import SwiftUI

struct CreateFacilityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var facilityName: String = ""
    @Binding var createdFacility: Facility?
    @Binding var showPickModuleTypeView: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter facility name", text: $facilityName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                saveNewFacility()
                showPickModuleTypeView = false
            }) {
                Text("Create")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            .navigationBarTitle("Name of the facility?", displayMode: .inline)
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    private func saveNewFacility() {
        createdFacility = Facility(context: viewContext)
        createdFacility!.id = UUID()
        createdFacility!.name = self.facilityName

        do {
            try viewContext.save()
            print("Facility saved \(self.facilityName) \(createdFacility!.name!)")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
