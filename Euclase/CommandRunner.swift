import Foundation

class CommandRunner {
    private static let bunExecutableURL = URL(fileURLWithPath: "/Users/rony/.bun/bin/bun")

    static func bunProcess(arguments: [String]) -> Process {
        let process = Process()
        process.executableURL = bunExecutableURL
        process.arguments = arguments
        return process
    }

    static func run(file: String, onMessage: @escaping (String) -> Void) {
        let stdout = Pipe()
        let process = bunProcess(arguments: [file])

        process.standardOutput = stdout

        stdout.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let line = String(data: data, encoding: .utf8) else { return }
            onMessage(line.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        do {
            try process.run()
        } catch {
            print("Failed to run process: \(error)")
        }
    }
}
