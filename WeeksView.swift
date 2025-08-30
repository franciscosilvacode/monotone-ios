import SwiftUI

struct WeeksView: View {
    @EnvironmentObject var store: PlanStore

    var body: some View {
        NavigationStack {
            List(store.plan.weeks) { week in
                NavigationLink(destination: WeekDetailView(week: week)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Week \(week.displayNumber)")
                                .font(.headline)
                            Text(week.dateRange)
                                .font(.subheadline)
                        }
                        Spacer()
                        if week.type == .detailed {
                            ProgressRing(progress: store.progress(for: week))
                                .frame(width: 32, height: 32)
                        } else {
                            Text("Guide")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Weeks")
        }
    }
}
