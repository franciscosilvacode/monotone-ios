import SwiftUI

@main
struct MarathonLiteApp: App {
    @StateObject private var store = PlanStore()
    var body: some Scene {
        WindowGroup {
            WeeksView()
                .environmentObject(store)
        }
    }
}
