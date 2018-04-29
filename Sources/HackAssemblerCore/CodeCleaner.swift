//
//  CodeCleaner.swift
//  HackAssemblerCore
//
//  Created by Colin Reisterer on 4/28/18.
//

import Foundation

/**
 Remove whitespace and comments from assembly code
 */
func clean(lines: [String]) -> [String] {
    return lines
        .map { $0.trimmingCharacters(in: .whitespaces) }            // ignore leading and trailing whitespace
        .filter { !($0.isEmpty || $0.starts(with: "//")) }          // ignore empty lines or lines that start with a comment
        .map { $0.components(separatedBy: .whitespaces).joined() }  // ignore white space within a line
        .map { $0.components(separatedBy: "//").first }             // drop comments appearing after an instruction
        .flatMap { $0 }
}

