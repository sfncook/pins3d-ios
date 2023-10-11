import SwiftUI

struct FirstDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            Text("First Detail View")
            NavigationLink(destination: ThirdDetailView()) {
                Text("Go to Third Detail View")
            }
        }
    }
}
