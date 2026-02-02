import SwiftUI

struct AbsenceCalendarView: View {
    @Binding var month: Date
    let events: [Date: [Color]]
    let isLoading: Bool
    let errorMessage: String?

    private let calendar = Calendar.current

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: month).capitalized
    }

    private var daysOfWeek: [String] {
        ["L", "M", "M", "G", "V", "S", "D"]
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    month = calendar.date(byAdding: .month, value: -1, to: month) ?? month
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthTitle)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    month = calendar.date(byAdding: .month, value: 1, to: month) ?? month
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }

            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(monthDays(), id: \.id) { item in
                    dayCell(item)
                }
            }

            if isLoading {
                ProgressView()
                    .tint(.white)
                    .padding(.top, 4)
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }

    private func dayCell(_ item: MonthDay) -> some View {
        VStack(spacing: 6) {
            if let date = item.date {
                let isToday = calendar.isDateInToday(date)
                let colors = events[calendar.startOfDay(for: date)] ?? []
                let backgroundColor = colors.first ?? Color.clear

                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(colors.isEmpty ? (item.isCurrentMonth ? .white : .white.opacity(0.35)) : .white)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor.opacity(colors.isEmpty ? 0 : 0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isToday ? .white : .clear, lineWidth: 1)
                    )

                if colors.count > 1 {
                    HStack(spacing: 4) {
                        ForEach(Array(colors.prefix(3).enumerated()), id: \.offset) { _, color in
                            Circle()
                                .fill(color)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(height: 10)
                } else {
                    Spacer()
                        .frame(height: 10)
                }
            } else {
                Spacer()
                    .frame(height: 38)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
    }

    private func monthDays() -> [MonthDay] {
        var cal = calendar
        cal.firstWeekday = 2

        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month
        let range = cal.range(of: .day, in: .month, for: startOfMonth) ?? (1..<31)
        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        let leadingEmpty = (firstWeekday - cal.firstWeekday + 7) % 7

        var days: [MonthDay] = Array(repeating: MonthDay(date: nil, isCurrentMonth: false), count: leadingEmpty)

        for day in range {
            if let date = cal.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(MonthDay(date: date, isCurrentMonth: true))
            }
        }

        while days.count % 7 != 0 {
            days.append(MonthDay(date: nil, isCurrentMonth: false))
        }

        return days
    }
}

private struct MonthDay: Identifiable {
    let id = UUID()
    let date: Date?
    let isCurrentMonth: Bool
}