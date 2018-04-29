//
//  FirstPass.swift
//  HackAssemblerCore
//
//  Created by Colin Reisterer on 4/28/18.
//

import Foundation

/**
 Resolve symbols to addresses for input to second pass
 Also, symbolic label lines will be stripped out
 */
func translateSymbolsOnly(lines: [String]) throws -> [String] {
    let (linesWithoutLabels, labelMap) = try extractLabels(lines: lines)
    let output = parseVariables(lines: linesWithoutLabels, labelMap: labelMap)
    return output
}

private func extractLabels(lines: [String]) throws -> ([String], [String: Int16]) {
    var instructionNumber: Int16 = 0
    
    var labelMap = [String: Int16]()
    
    var linesWithoutLabels = [String]()
    
    try lines.enumerated().forEach { (n, line) in
        do {
            if line.first == "(" && line.last == ")" {
                let label = String(line.dropFirst().dropLast())
                
                // ensure label exists and doesn't start with decimal
                guard let first = label.unicodeScalars.first, !CharacterSet.decimalDigits.contains(first) else {
                    throw InternalError.invalidLabel
                }
                
                // ensure label isn't a reserved symbol, illegal to reassign these
                guard builtInVariableMap[label] == nil else {
                    throw InternalError.labelConflictsPredefined(label)
                }
                
                labelMap[String(label)] = instructionNumber
            } else {
                linesWithoutLabels.append(line)
                instructionNumber += 1
            }
        } catch {
            throw HackAssemblerError.lineError(n, line, error)
        }
    }
    
    return (linesWithoutLabels, labelMap)
}

private func parseVariables(lines: [String], labelMap: [String: Int16]) -> [String] {
    // combine built in with labels. We don't expect merges as this is handled in an internal error above
    var variableMap = builtInVariableMap.merging(labelMap) { (_, _) -> Int16 in
        fatalError("Unexpected conflict between predefined variables and labels")
    }
    
    var newVariableAddress: Int16 = 16
    
    let output = lines.map { line -> String in
        if line.first == "@" {
            let address = String(line.dropFirst())
            if Int16(address) != nil {
                return line
            } else if let mapped = variableMap[address] {
                return "@" + String(mapped)
            } else {
                // new variable, assign and add to map
                variableMap[address] = newVariableAddress
                newVariableAddress += 1
                return "@" + String(variableMap[address]!)
            }
        } else {
            return line
        }
    }
    
    return output
}

private let builtInVariableMap: [String: Int16] = [
    "SP": 0,
    "LCL": 1,
    "ARG": 2,
    "THIS": 3,
    "THAT": 4,
    "R0": 0,
    "R1": 1,
    "R2": 2,
    "R3": 3,
    "R4": 4,
    "R5": 5,
    "R6": 6,
    "R7": 7,
    "R8": 8,
    "R9": 9,
    "R10": 10,
    "R11": 11,
    "R12": 12,
    "R13": 13,
    "R14": 14,
    "R15": 15,
    "SCREEN": 16384,
    "KBD": 24576
]
