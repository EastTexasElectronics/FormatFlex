import SwiftUI
import UniformTypeIdentifiers
import Foundation
import CoreXLSX
import Yams

/// The main content view of the application, allowing users to upload a file and convert it to various formats.
struct ContentView: View {
    @State private var inputFilePath: String = ""
    @State private var outputFormat: String = "JSON"
    @State private var convertedContent: String = ""
    @State private var trimData: Bool = false
    @State private var parseTypes: Bool = false
    @State private var ignoreEmpty: Bool = false
    @State private var noHeader: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                fileUploadSection()
                outputFormatSection()
                formatOptionsSection()
                convertButton()
            }
            .padding()
        }
    }
    
    /// Creates the file upload section UI.
    private func fileUploadSection() -> some View {
        VStack {
            Text("Upload File")
                .font(.headline)
                .padding()
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .cornerRadius(10)
                
                VStack {
                    Image(systemName: "doc")
                    Text(inputFilePath.isEmpty ? "Drag & Drop a file or Select a file" : inputFilePath)
                        .foregroundColor(.gray)
                }
            }
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleDrop(providers: providers)
                return true
            }
            .onTapGesture {
                openFile()
            }
        }
        .padding()
    }
    
    /// Creates the output format selection UI.
    private func outputFormatSection() -> some View {
        HStack {
            Text("Output Format")
            Spacer()
            Picker("Select Format", selection: $outputFormat) {
                Text("JSON").tag("JSON")
                Text("TXT").tag("TXT")
                Text("YAML").tag("YAML")
                Text("CSV").tag("CSV")
                Text("XLSX").tag("XLSX")
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
        }
        .padding()
    }
    
    /// Creates the format-specific options UI.
    private func formatOptionsSection() -> some View {
        Group {
            if outputFormat == "CSV" {
                Toggle("Trim Data", isOn: $trimData)
                Toggle("Parse Types", isOn: $parseTypes)
                Toggle("Ignore Empty", isOn: $ignoreEmpty)
                Toggle("No Header", isOn: $noHeader)
            } else if ["TXT", "JSON", "YAML"].contains(outputFormat) {
                Toggle("Ignore Empty", isOn: $ignoreEmpty)
            } else if outputFormat == "XLSX" {
                Toggle("No Header", isOn: $noHeader)
            }
        }
    }
    
    /// Creates the convert button UI.
    private func convertButton() -> some View {
        HStack {
            Spacer()
            Button("Convert") {
                convertFile(inputFilePath: inputFilePath, outputFormat: outputFormat)
            }
            .padding()
        }
    }
    
    /// Converts the file at the given path to the specified output format.
    ///
    /// - Parameters:
    ///   - inputFilePath: The path of the input file to be converted.
    ///   - outputFormat: The format to which the file should be converted.
    private func convertFile(inputFilePath: String, outputFormat: String) {
        guard let content = loadFileContent(from: inputFilePath) else {
            convertedContent = "Failed to load file."
            return
        }
        
        switch outputFormat {
        case "JSON":
            convertedContent = handleJSONConversion(content: content)
        case "TXT":
            convertedContent = handleTXTConversion(content: content)
        case "YAML":
            convertedContent = handleYAMLConversion(content: content)
        case "CSV":
            convertedContent = handleCSVConversion(content: content)
        case "XLSX":
            convertedContent = handleXLSXConversion(filePath: inputFilePath)
        default:
            convertedContent = "Unsupported output format."
        }
    }
    
    /// Loads the content of a file from the specified path.
    ///
    /// - Parameter filePath: The path of the file to be loaded.
    /// - Returns: The content of the file as a string, or `nil` if loading failed.
    private func loadFileContent(from filePath: String) -> String? {
        return try? String(contentsOfFile: filePath)
    }
    
    /// Converts the content to JSON format.
    ///
    /// - Parameter content: The string content to be converted.
    /// - Returns: The JSON-formatted string.
    private func handleJSONConversion(content: String) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: content, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "Failed to convert to JSON."
        }
        return jsonString
    }
    
    /// Converts the content to plain text format.
    ///
    /// - Parameter content: The string content to be converted.
    /// - Returns: The plain text string.
    private func handleTXTConversion(content: String) -> String {
        let words = content.split(separator: "\n").map { String($0) }
        return words.joined(separator: noHeader ? "," : "\n")
    }
    
    /// Converts the content from YAML to JSON format.
    ///
    /// - Parameter content: The string content to be converted.
    /// - Returns: The JSON-formatted string converted from YAML.
    private func handleYAMLConversion(content: String) -> String {
        do {
            guard let yamlObject = try parseYAML(content: content) else {
                return "YAML format is not valid for conversion."
            }
            
            guard let jsonString = convertToJSONString(from: yamlObject) else {
                return "Failed to serialize YAML to JSON."
            }
            
            return jsonString
        } catch {
            return "Failed to parse YAML."
        }
    }

    /// Parses the YAML content into a dictionary object.
    ///
    /// - Parameter content: The YAML string to parse.
    /// - Returns: A dictionary representation of the YAML content, or `nil` if parsing fails.
    private func parseYAML(content: String) throws -> [String: Any]? {
        return try Yams.load(yaml: content) as? [String: Any]
    }

    /// Converts a dictionary object into a pretty-printed JSON string.
    ///
    /// - Parameter yamlObject: The dictionary object to convert to JSON.
    /// - Returns: A JSON-formatted string, or `nil` if serialization fails.
    private func convertToJSONString(from yamlObject: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: yamlObject, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// Converts the content to CSV format.
    ///
    /// - Parameter content: The string content to be converted.
    /// - Returns: The CSV-formatted string.
    private func handleCSVConversion(content: String) -> String {
        let rows = content.split(separator: "\n").map { String($0) }
        return noHeader ? rows.joined(separator: ",") : rows.joined(separator: "\n")
    }
    
    /// Converts an XLSX file to a readable string format.
    ///
    /// - Parameter filePath: The path of the XLSX file to be converted.
    /// - Returns: The string representation of the XLSX file.
    private func handleXLSXConversion(filePath: String) -> String {
        guard let file = XLSXFile(filepath: filePath) else {
            return "Failed to open XLSX file."
        }
        
        var result = ""
        
        do {
            for workbook in try file.parseWorkbooks() {
                result += processWorkbook(file: file, workbook: workbook)
            }
        } catch {
            return "Failed to parse XLSX file: \(error.localizedDescription)"
        }
        
        return result
    }

    /// Processes a workbook and extracts data from each worksheet.
    ///
    /// - Parameters:
    ///   - file: The XLSXFile object.
    ///   - workbook: The workbook object to process.
    /// - Returns: A string containing the extracted data from the workbook.
    private func processWorkbook(file: XLSXFile, workbook: Workbook) -> String {
        var result = ""
        
        do {
            for (path, name) in try file.parseWorksheetPathsAndNames(workbook: workbook) {
                result += processWorksheet(file: file, path: path, name: name)
            }
        } catch {
            result += "Failed to process workbook: \(error.localizedDescription)\n"
        }
        
        return result
    }

    /// Processes a worksheet and extracts data from its cells.
    ///
    /// - Parameters:
    ///   - file: The XLSXFile object.
    ///   - path: The path to the worksheet.
    ///   - name: The name of the worksheet.
    /// - Returns: A string containing the extracted data from the worksheet.
    private func processWorksheet(file: XLSXFile, path: String?, name: String) -> String {
        guard let path = path else {
            return "Skipped worksheet '\(name)': Invalid path\n\n"
        }
        
        do {
            let worksheet = try file.parseWorksheet(at: path)
            return extractData(from: worksheet, worksheetName: name)
        } catch {
            return "Error parsing worksheet '\(name)': \(error.localizedDescription)\n\n"
        }
    }

    /// Extracts data from a worksheet's cells and formats it as a string.
    ///
    /// - Parameters:
    ///   - worksheet: The worksheet object to extract data from.
    ///   - worksheetName: The name of the worksheet.
    /// - Returns: A string containing the extracted and formatted data.
    private func extractData(from worksheet: Worksheet, worksheetName: String) -> String {
        var result = "Worksheet: \(worksheetName)\n"
        let rows = worksheet.data?.rows ?? []
        
        for row in rows {
            let rowContent = row.cells.compactMap { cell -> String? in
                return extractValue(from: cell)
            }.joined(separator: ", ")
            result += rowContent + "\n"
        }
        
        result += "\n" // Add a blank line between worksheets
        return result
    }

    /// Extracts the value from a worksheet cell.
    ///
    /// - Parameter cell: The cell to extract the value from.
    /// - Returns: The extracted value as a string, or `nil` if no value exists.
    private func extractValue(from cell: Cell) -> String? {
        if let value = cell.value {
            return value
        } else if let inlineString = cell.inlineString {
            return inlineString.text
        } else {
            return nil
        }
    }

    /// Handles the drop event to update the file path.
    ///
    /// - Parameter providers: An array of NSItemProvider objects representing the dropped items.
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    if let url = item as? URL {
                        DispatchQueue.main.async {
                            inputFilePath = url.path
                        }
                    }
                }
            }
        }
    }
    
    /// Opens the file selection dialog for the user to choose a file.
    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.text, UTType.json, UTType.commaSeparatedText, UTType.yaml, UTType.data]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            inputFilePath = panel.url?.path ?? ""
        }
    }
}
