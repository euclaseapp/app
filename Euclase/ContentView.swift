import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TextInputView()
            Button("Cow says what?") {
                CommandRunner.run(
                    file: "/Users/rony/.config/euclase/extensions/cowsay/index.ts"
                ) { message in
                    DispatchQueue.main.async {
                        guard
                            let data = message.data(using: .utf8),
                            let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let method = payload["method"] as? String,
                            method == "print",
                            let params = payload["params"]
                        else {
                            print(message)
                            return
                        }

                        print(params)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
