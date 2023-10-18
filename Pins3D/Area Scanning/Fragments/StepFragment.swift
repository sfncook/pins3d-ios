import SwiftUI

struct StepFragment: View {
    let viewModel: ScanningFacilityViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.executingProcedure?.name ?? "NOT SET")
                Spacer()
                Text("#\(String(describing: viewModel.executingStep?.number))")
            }
            Text(viewModel.executingStep?.summary ?? "NOT SET")
            Text(viewModel.executingStep?.details ?? "")
            HStack {
                Button(action: {
                    print("Click previous")
                }) {
                    Text("Prev")
                }
                
                Spacer()
                
                Button(action: {
                    print("Click Done")
                }) {
                    Text("Done")
                }
                
                Spacer()
                
                Button(action: {
                    print("Click Next")
                }) {
                    Text("Next")
                }
            }
        }
//        .frame(
//            minWidth: UIScreen.main.bounds.width,
//            maxWidth: UIScreen.main.bounds.width,
//            maxHeight: UIScreen.main.bounds.height,
//            alignment: .top
//        )
        .background(Color.white)
        .cornerRadius(20)
        .padding()
    }
}
