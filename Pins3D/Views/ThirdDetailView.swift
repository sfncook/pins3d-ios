import SwiftUI

struct ThirdDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        let newItem = MyItem(context: viewContext)
//        newItem.timestamp = Date()
        Text("Third Detail View")
        // And so on...
    }
}
