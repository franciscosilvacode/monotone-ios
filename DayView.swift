import SwiftUI

struct DayView: View {
    let title: String
    let detail: String
    let weekKey: String
    let itemKey: String
    @AppStorage private var completed: Bool
    @AppStorage private var notes: String
    @Environment(\.dismiss) private var dismiss

    init(title: String, detail: String, weekKey: String, itemKey: String) {
        self.title = title
        self.detail = detail
        self.weekKey = weekKey
        self.itemKey = itemKey
        _completed = AppStorage("completion.\(weekKey).\(itemKey)", defaultValue: false)
        _notes = AppStorage("notes.\(weekKey).\(itemKey)", defaultValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Workout") { Text(detail) }
                Section("Notes") { TextEditor(text: $notes).frame(minHeight: 100) }
                Toggle("Completed", isOn: $completed)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
