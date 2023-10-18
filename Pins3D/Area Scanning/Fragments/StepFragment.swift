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
            .padding(20)
            
            HStack {
                Text(viewModel.executingStep?.summary ?? "NOT SET")
                Spacer()
            }
            .padding(20)
            
            HStack {
                Text(viewModel.executingStep?.details ?? "")
                Spacer()
            }
            .padding(20)
            
            HStack {
                Button(action: {
                    print("Click previous")
                }) {
                    Text("Prev")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    print("Click Done")
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    print("Click Next")
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .cornerRadius(5)
        .padding([.leading, .trailing], 20)
    }
}
