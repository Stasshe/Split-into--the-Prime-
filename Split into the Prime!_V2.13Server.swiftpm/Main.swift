import SwiftUI

@main
struct GameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .edgesIgnoringSafeArea(.all) // 画面全体を使用
                .accessibilityIgnoresInvertColors()
                .accentColor(.blue)
                
        }
    }
}
