import Foundation

final class PlanStore: ObservableObject {
    @Published var plan: Plan

    init() {
        guard let url = Bundle.main.url(forResource: "plan", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let plan = try? JSONDecoder().decode(Plan.self, from: data) else {
            fatalError("Unable to load plan.json")
        }
        self.plan = plan
    }

    func progress(for week: Week) -> Double {
        guard let days = week.days else { return 0 }
        var completed = 0
        for index in days.indices {
            if UserDefaults.standard.bool(forKey: "completion.\(week.storageKey).\(index)") {
                completed += 1
            }
        }
        return Double(completed) / Double(days.count)
    }
}
