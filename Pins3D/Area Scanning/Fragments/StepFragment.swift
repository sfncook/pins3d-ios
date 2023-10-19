import SwiftUI

struct StepFragment: View {
    let viewModel: ScanningFacilityViewModel
    @Binding var executingStep: Step?
    @Binding var hasNextStep: Bool
    @Binding var hasPrevStep: Bool
    
    @State private var stepImage: UIImage? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.executingProcedure?.name ?? "NOT SET")
                Spacer()
                Text("#\(viewModel.executingStep?.number ?? 0)")
            }
            .padding(20)
            
            // Display Image if it exists
            if let image = stepImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            
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
                prevButton
                Spacer()
                
                Button(action: {
                    viewModel.stopExecutingProcedure()
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                nextButton
            }
            .padding(20)
        }
        .background(Color.white)
        .cornerRadius(5)
        .padding([.leading, .trailing], 20)
        .onAppear(perform: loadImage)
    }
    
    var nextButton: some View {
        var opacity = 0.0
        if hasNextStep {
            opacity = 1.0
        }
        return Button(action: {
            viewModel.nextStep()
        }) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .opacity(opacity)
    }
    
    var prevButton: some View {
        var opacity = 0.0
        if hasPrevStep {
            opacity = 1.0
        }
        return Button(action: {
            viewModel.prevStep()
        }) {
            Text("Prev")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .opacity(opacity)
    }
    
    func loadImage() {
        if let imageName = viewModel.executingStep?.imageFilename {
            viewModel.loadStepImage(stepImageName: imageName) { stepImage in
                self.stepImage = stepImage
            }
        }
    }
}
