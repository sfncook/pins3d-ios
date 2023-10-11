import SwiftUI

struct FirstDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            Text("First Detail View")
            
            // Navigation to Third Detail View
            NavigationLink(destination: ThirdDetailView()) {
                Text("Go to Third Detail View")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }
}
