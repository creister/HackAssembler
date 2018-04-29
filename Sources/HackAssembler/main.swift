import HackAssemblerCore

do {
    try HackAssembler.run()
} catch {
    print("Error: \(error.localizedDescription)")
}


