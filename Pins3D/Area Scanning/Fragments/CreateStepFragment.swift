import SwiftUI

struct CreateStepFragment: View {
    let viewModel: ScanningFacilityViewModel
    @State private var stepSummary: String = ""
    @State private var stepDetails: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                Text("Add Step")
                    .font(.title)
                    .bold()
                Spacer().frame(height: 16)
                
                Text("Procedure Name")
                    .font(.caption)
                    .padding(.bottom, 2)
                Text(viewModel.creatingProcedure?.name ?? "NOT SET")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer().frame(height: 16)
                
                Text("Step Number")
                    .font(.caption)
                Text("\(viewModel.creatingStepNumber)")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Summary")
                    .font(.caption)
                    .padding(.bottom, 2)
                TextField("Step Summary", text: $stepSummary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .border(Color.gray, width: 1)
                
                Text("Details (optional)")
                    .font(.caption)
                    .padding(.bottom, 2)
                TextEditor(text: $stepDetails)
                    .frame(height: 60, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Button(action: {
                    // TODO
                }) {
                    Text("Add Photo (optional)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(true)
                
                Button(action: {
                    viewModel.addStepPin(
                        stepSummary: stepSummary,
                        stepDetails: stepDetails
                    )
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                }) {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }//ScrollView
        }//Vstack
        .padding() // Add padding to the entire VStack
        
//        .frame(
//            minWidth: UIScreen.main.bounds.width,
//            maxWidth: UIScreen.main.bounds.width,
//            maxHeight: UIScreen.main.bounds.height,
//            alignment: .top
//        )
        .background(Color.white)
        .cornerRadius(5)
        .padding()
    }//body
}
