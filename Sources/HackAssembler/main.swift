import Foundation

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
}

struct InstructionComponents {
    let computeInstruction: Substring
    let destinationInstruction: Substring?
    let jumpInstruction: Substring?
}

private let jumpMap: [String: String] = [
    "JGT": "001",
    "JEQ": "010",
    "JGE": "011",
    "JLT": "100",
    "JNE": "101",
    "JLE": "110",
    "JMP": "111"
]

private let destinationMap: [String: String] = [
    "M"  : "001",
    "D"  : "010",
    "MD" : "011",
    "A"  : "100",
    "AM" : "101",
    "AD" : "110",
    "AMD": "111"
]

private let computationMap: [String: String] = [
    "0"  : "0101010",
    "1"  : "0111111",
    "-1" : "0111010",
    "D"  : "0001100",
    "A"  : "0110000",
    "!D" : "0001101",
    "!A" : "0110001",
    "-D" : "0001111",
    "-A" : "0110011",
    "D+1": "0011111",
    "A+1": "0110111",
    "D-1": "0001110",
    "A-1": "0110010",
    "D+A": "0000010",
    "D-A": "0010011",
    "A-D": "0000111",
    "D&A": "0000000",
    "D|A": "0010101",
    
    "M"  : "1110000",
    "!M" : "1110001",
    "-M" : "1110011",
    "M+1": "1110111",
    "M-1": "1110010",
    "D+M": "1000010",
    "D-M": "1010011",
    "D&M": "1000000",
    "D|M": "1010101"
]

extension Int16 {
    func paddedBinaryString() -> String {
        let binaryString = String(self, radix: 2)
        let padding = String(repeating: "0", count: 16 - binaryString.count)
        return padding + binaryString
    }
}

func translateNoSymbols(lines: [String]) throws -> [String] {
    return try lines.map(translateLineNoSymbols)
}

private func translateLineNoSymbols(line: String) throws -> String {
    switch line.first! {
    case "@": return try parseAddress(line: line)
    default: return try translateInstruction(line: line)
    }
}

private func parseAddress(line: String) throws -> String {
    let index1 = line.index(after: line.startIndex)
    let address = line[index1...]
    guard let value = Int16(address) else {
        throw AssemblerError.invalidAddress
    }
    return value.paddedBinaryString()
}

private func translateInstruction(line: String) throws -> String {
    let components = try parseInstructionComponents(line)
    let jump = try translateJump(components.jumpInstruction)
    let destination = try translateDestination(components.destinationInstruction)
    let computation = try translateCompute(components.computeInstruction)
    return "111" + computation + destination + jump
}


private func translateJump(_ jump: Substring?) throws -> String {
    guard let jump = jump else { return "000" }
    guard let translated = jumpMap[String(jump)] else {
        throw AssemblerError.invalidJump
    }
    return translated
}

private func translateDestination(_ destination: Substring?) throws -> String {
    guard let destination = destination else { return "000" }
    guard let translated = destinationMap[String(destination)] else {
        throw AssemblerError.invalidDestination
    }
    return translated
}

private func translateCompute(_ computation: Substring) throws -> String {
    guard let translated = computationMap[String(computation)] else {
        throw AssemblerError.invalidCompute
    }
    return translated
}

private func parseInstructionComponents(_ line: String) throws -> InstructionComponents {
    let jumpInstruction: Substring?
    let destinationInstruction: Substring?
    let computeInstruction: Substring
    
    let splitOnSemicolon = line.split(separator: ";")
    guard splitOnSemicolon.count <= 2 else {
        throw AssemblerError.unexpectedSemicolon
    }
    
    if splitOnSemicolon.count == 2 {
        jumpInstruction = splitOnSemicolon[1]
    } else {
        jumpInstruction = nil
    }
    
    let splitOnEquals = splitOnSemicolon[0].split(separator: "=")
    guard splitOnEquals.count <= 2 else {
        throw AssemblerError.unexpectedEquals
    }
    
    if splitOnEquals.count == 2 {
        destinationInstruction = splitOnEquals[0]
        computeInstruction = splitOnEquals[1]
    } else {
        destinationInstruction = nil
        computeInstruction = splitOnEquals[0]
    }
    
    return InstructionComponents(computeInstruction: computeInstruction, destinationInstruction: destinationInstruction, jumpInstruction: jumpInstruction)
}

private func translateJump<S: StringProtocol>(_ string: S) -> String {
    return "111"
}

guard CommandLine.arguments.count > 1 else {
    throw AssemblerError.noFileArgument
}

let filePath = CommandLine.arguments[1]

guard let fileData = FileManager().contents(atPath: filePath) else {
    throw AssemblerError.noFile
}

guard let fileString = String(data: fileData, encoding: .utf8) else {
    throw AssemblerError.cannotReadFile
}

let lines = fileString.components(separatedBy: .newlines)
    .map { $0.trimmingCharacters(in: .whitespaces) }            // ignore leading and trailing whitespace
    .filter { !($0.isEmpty || $0.starts(with: "//")) }          // ignore empty lines or lines that start with a comment
    .map { $0.components(separatedBy: .whitespaces).joined() }  // ignore white space within a line
    .map { $0.components(separatedBy: "//").first }             // drop comments appearing after an instruction
    .flatMap { $0 }

let translated = try translateNoSymbols(lines: lines)
translated.forEach { print($0) }
