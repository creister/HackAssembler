//
//  Int16+Extensions.swift
//  HackAssemblerPackageDescription
//
//  Created by Colin Reisterer on 4/28/18.
//

import Foundation

extension Int16 {
    func paddedBinaryString() -> String {
        let binaryString = String(self, radix: 2)
        let padding = String(repeating: "0", count: 16 - binaryString.count)
        return padding + binaryString
    }
}
