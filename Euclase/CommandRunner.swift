import Foundation

class CommandRunner {
    private static let bunExecutableURL = URL(fileURLWithPath: "/Users/rony/.bun/bin/bun")

    static func bunProcess(arguments: [String]) -> Process {
        let process = Process()
        process.executableURL = bunExecutableURL
        process.arguments = arguments
        process.qualityOfService = .userInitiated
        return process
    }

    static func run(file: String, onMessage: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let stdout = Pipe()
            let stderr = Pipe()
            let process = bunProcess(arguments: [file])

            process.standardOutput = stdout
            process.standardError = stderr

            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Failed to run process: \(error)")
                return
            }

            let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderr.fileHandleForReading.readDataToEndOfFile()

            if let stderrText = String(data: stderrData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               !stderrText.isEmpty {
                print("Command stderr: \(stderrText)")
            }

            guard let stdoutText = String(data: stdoutData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !stdoutText.isEmpty
            else { return }

            DispatchQueue.main.async {
                onMessage(stdoutText)
            }
        }
    }
}
