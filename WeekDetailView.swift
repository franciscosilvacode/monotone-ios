import SwiftUI

struct WeekDetailView: View {
    let week: Week
    
    var body: some View {
        List {
            if week.type == .detailed, let days = week.days {
                ForEach(Array(days.enumerated()), id: \.0) { idx, day in
                    DayRow(week: week, day: day, index: idx)
                }
                if week.totalMinutes > 0 {
                    Section {
                        Text("Total minutes: \(week.totalMinutes)")
                    }
                }
            } else if let cats = week.sessionCategories {
                ForEach(cats) { cat in
                    Section(header: Text(cat.name)) {
                        ForEach(Array(cat.items.enumerated()), id: \.0) { idx, item in
                            SessionRow(week: week, category: cat.name, item: item, index: idx)
                        }
                    }
                }
            }
            if let notes = week.notes, !notes.isEmpty {
                Section("Notes") {
                    ForEach(notes, id: \.self) { note in
                        Text(note)
                    }
                }
            }
        }
        .navigationTitle("Week \(week.displayNumber)")
        .toolbar {
            if #available(iOS 16.0, *) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    var shareText: String {
        var parts: [String] = []
        if week.type == .detailed, let days = week.days {
            for day in days {
                parts.append("\(day.day): \(day.type) \(day.summary)")
            }
        } else if let cats = week.sessionCategories {
            for cat in cats {
                parts.append("\(cat.name):")
                for item in cat.items { parts.append("- \(item)") }
            }
        }
        return parts.joined(separator: "\n")
    }
}

struct DayRow: View {
    let week: Week
    let day: Day
    let index: Int
    @AppStorage var completed: Bool
    @State private var showSheet = false

    init(week: Week, day: Day, index: Int) {
        self.week = week
        self.day = day
        self.index = index
        _completed = AppStorage("completion.\(week.storageKey).\(index)")
    }

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(day.day)
                    Text(day.type).font(.subheadline)
                }
                Spacer()
                if completed {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            DayView(title: day.day, detail: "\(day.type)\n\(day.summary)", weekKey: week.storageKey, itemKey: "\(index)")
        }
    }
}

struct SessionRow: View {
    let week: Week
    let category: String
    let item: String
    let index: Int
    @AppStorage var completed: Bool
    @State private var showSheet = false

    init(week: Week, category: String, item: String, index: Int) {
        self.week = week
        self.category = category
        self.item = item
        self.index = index
        let key = "completion.\(week.storageKey).\(category.replacingOccurrences(of: " ", with: "_"))\(index)"
        _completed = AppStorage(key)
    }

    var body: some View {
        Button { showSheet = true } label: {
            HStack {
                Text(item)
                Spacer()
                if completed {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            let key = "\(category.replacingOccurrences(of: " ", with: "_"))\(index)"
            DayView(title: item, detail: "", weekKey: week.storageKey, itemKey: key)
        }
    }
}
