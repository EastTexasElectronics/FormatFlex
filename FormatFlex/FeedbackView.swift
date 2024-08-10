import SwiftUI

/// A view that provides feedback to the user during and after the conversion process.
/// It displays the progress, success, or failure of the conversion operation.
struct FeedbackView: View {
    /// A binding to control whether the view is presented.
    @Binding var isPresenting: Bool
    
    /// A state variable indicating whether the conversion process is ongoing.
    @State private var isProcessing: Bool = true
    
    /// A state variable indicating whether the conversion was successful.
    @State private var success: Bool = false
    
    /// A state variable that holds an error message if the conversion fails.
    @State private var errorMessage: String?
    
    /// A state variable that holds the file path of the converted file.
    @State private var resultFilePath: String = ""
    
    /// A state variable that stores the start time of the conversion.
    @State private var startTime: Date = Date()
    
    /// A state variable that stores the end time of the conversion, if availabl
    @State private var endTime: Date?
    
    var body: some View {
        VStack {
            if isProcessing {
                processingView()
            } else if success {
                successView()
            } else {
                failureView()
            }
        }
        .padding()
        .frame(width: 300, height: 300)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
    
    /// Displays the view shown during the processing state.
    private func processingView() -> some View {
        VStack {
            Text("Processing...")
                .font(.title)
                .padding()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        }
    }
    
    /// Displays the view shown when the conversion is successful.
    private func successView() -> some View {
        VStack {
            Text("Conversion Successful!")
                .font(.title)
                .foregroundColor(.green)
                .padding()
            
            Text("File saved at:")
                .padding(.top)
            Text(resultFilePath)
                .font(.caption)
                .padding(.bottom)
            
            if let endTime = endTime {
                Text("Time taken: \(endTime.timeIntervalSince(startTime), specifier: "%.2f") seconds")
                    .padding(.bottom)
            }
            
            openFileButton()
            closeButton()
        }
    }
    
    /// Displays the view shown when the conversion fails.
    private func failureView() -> some View {
        VStack {
            Text("Conversion Failed")
                .font(.title)
                .foregroundColor(.red)
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            reportIssueButton()
            closeButton()
        }
    }
    
    /// Button to open the file location of the converted file.
    private func openFileButton() -> some View {
        Button(action: {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: resultFilePath)
        }) {
            Text("Open File Location")
        }
        .padding(.bottom)
    }
    
    /// Button to close the feedback view.
    private func closeButton() -> some View {
        Button(action: {
            isPresenting = false
        }) {
            Text("Close")
        }
        .padding()
    }
    
    /// Button to report an issue with the conversion process.
    private func reportIssueButton() -> some View {
        Button(action: {
            if let url = URL(string: "https://www.roberthavelaar.dev/data-file-converter-app#report-issue") {
                NSWorkspace.shared.open(url)
            }
        }) {
            Text("Report Issue")
        }
        .padding(.bottom)
    }
}
