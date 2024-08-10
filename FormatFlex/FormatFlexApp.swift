import SwiftUI

@main
struct FormatFlex: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("How to Use Data File Converter") {
                    openHelpPage()
                }
                .keyboardShortcut("?", modifiers: [.command])
                
                Divider()
                
                Button("About Data File Converter") {
                    openAboutPage()
                }
            }
        }
    }
    
    /// Opens the help page in the default web browser
    private func openHelpPage() {
        if let url = URL(string: "https://www.roberthavelaar.dev/data-file-converter-app#help") {
            NSWorkspace.shared.open(url)
        }
    }
    
    /// Opens the about page in the default web browser or in an in-app modal.
    private func openAboutPage() {
        let aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        aboutWindow.center()
        aboutWindow.title = "About Data File Converter"
        aboutWindow.isReleasedWhenClosed = false
        aboutWindow.contentView = NSHostingView(rootView: AboutView())
        aboutWindow.makeKeyAndOrderFront(nil)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "doc.text.magnifyingglass")
                .resizable()
                .frame(width: 50, height: 50)
            Text("Data File Converter")
                .font(.headline)
            Text("Version 1.0")
                .font(.subheadline)
            Text("© 2024 Robert Havelaar")
                .font(.footnote)
            Text("Data File Converter is a versatile tool to convert files between multiple formats, including JSON, CSV, XLSX, YAML, and more. For more details, visit our website.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            Button("Visit Website") {
                if let url = URL(string: "https://www.roberthavelaar.dev/data-file-converter-app") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .frame(width: 400, height: 200)
        .padding()
    }
}
