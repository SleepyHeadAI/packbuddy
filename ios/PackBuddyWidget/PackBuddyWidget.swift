import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PackBuddyEntry {
        PackBuddyEntry(
            date: Date(),
            tripTitle: "PackBuddy",
            destination: "Paris, France",
            daysUntil: 5,
            packingProgress: "8/15",
            budgetSpent: "$450"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PackBuddyEntry) -> Void) {
        let entry = getCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PackBuddyEntry>) -> Void) {
        let entry = getCurrentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getCurrentEntry() -> PackBuddyEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.sleepyhead.packbuddy")
        let title = userDefaults?.string(forKey: "trip_title") ?? "PackBuddy"
        let destination = userDefaults?.string(forKey: "trip_destination") ?? ""
        let days = userDefaults?.integer(forKey: "trip_days") ?? 0
        let packing = userDefaults?.string(forKey: "trip_packing") ?? "0/0"
        let budget = userDefaults?.string(forKey: "trip_budget") ?? ""

        return PackBuddyEntry(
            date: Date(),
            tripTitle: title,
            destination: destination,
            daysUntil: days,
            packingProgress: packing,
            budgetSpent: budget
        )
    }
}

struct PackBuddyEntry: TimelineEntry {
    let date: Date
    let tripTitle: String
    let destination: String
    let daysUntil: Int
    let packingProgress: String
    let budgetSpent: String
}

struct PackBuddyWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color(red: 0.08, green: 0.12, blue: 0.18))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "suitcase.fill")
                        .foregroundColor(Color(red: 0.38, green: 0.65, blue: 0.98))
                        .font(.system(size: 14, weight: .bold))
                    Text(entry.tripTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    if entry.daysUntil > 0 {
                        Text("\(entry.daysUntil)d")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.22, green: 0.44, blue: 0.88).opacity(0.35))
                            .foregroundColor(Color(red: 0.58, green: 0.78, blue: 1.0))
                            .cornerRadius(6)
                    }
                }

                if !entry.destination.isEmpty {
                    Text(entry.destination)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PACKED")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.gray)
                        Text(entry.packingProgress)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }

                    if !entry.budgetSpent.isEmpty {
                        Divider()
                            .frame(height: 20)
                            .background(Color.gray.opacity(0.4))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SPENT")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.gray)
                            Text(entry.budgetSpent)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.55))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(12)
        }
    }
}

@main
struct PackBuddyWidget: Widget {
    let kind: String = "PackBuddyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PackBuddyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("PackBuddy Trip")
        .description("Track upcoming trip countdown, packing progress, and budget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
