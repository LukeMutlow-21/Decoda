import Foundation

struct ConversionService {

    static func convert(input: URL, output: URL) throws {

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["cms", "-D", "-i", input.path]

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: errorData, encoding: .utf8) ?? "Conversion failed"
            throw NSError(domain: "Decoda", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
        }

        let xmlData = stdout.fileHandleForReading.readDataToEndOfFile()
        try xmlData.write(to: output, options: .atomic)
    }
}
