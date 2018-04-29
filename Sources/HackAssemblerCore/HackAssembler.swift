import Foundation

public struct HackAssembler {
    
    public static func run(arguments: [String] = CommandLine.arguments) throws {
        guard arguments.count > 1 else {
            throw AssemblerError.noFileArgument
        }
        
        let filePath = CommandLine.arguments[1]
        
        let fileManager = FileManager()
        
        guard let fileData = fileManager.contents(atPath: filePath) else {
            throw AssemblerError.noFile
        }
        
        guard let fileString = String(data: fileData, encoding: .utf8) else {
            throw AssemblerError.cannotReadFile
        }
        
        let lines = fileString.components(separatedBy: .newlines)
        
        let cleanedLines = clean(lines: lines)
        
        let linesNoSymbols = try translateSymbolsOnly(lines: cleanedLines)
        
        let translatedLines = try translateNoSymbols(lines: linesNoSymbols)
        
        let outputString = translatedLines.joined(separator: "\n").appending("\n")
        let outputData = outputString.data(using: .utf8)
        
        // create output file with "[input file name].hack" in current directory
        let fileURL = URL(fileURLWithPath: filePath)
        let outputFileURL = fileURL.deletingPathExtension().appendingPathExtension("hack").lastPathComponent
        
        fileManager.createFile(atPath: outputFileURL, contents: outputData, attributes: nil)
    }
        
}

enum AssemblerError: Error {
    case noFileArgument
    case noFile
    case cannotReadFile
    case invalidAddress
    case unexpectedSemicolon
    case unexpectedEquals
    case invalidJump
    case invalidDestination
    case invalidCompute
    case invalidLabel
    case lineError(Int, String, Error)
}
