import SwiftUI

struct AbsenceHomeView: View {
    @ObservedObject var viewModel: AbsenceViewModel
    let onExit: () -> Void

    @EnvironmentObject private var auth: AuthSession
    @StateObject private var locationProvider = LocationProvider()

    @State private var calendarMonth = Date()
    @State private var calendarEvents: [Date: [Color]] = [:]
    @State private var isCalendarLoading = false
    @State private var calendarError: String?

    private var userName: String {
        auth.displayName ?? auth.fallbackName()
    }

    var body: some View {
        VStack(spacing: 16) {

            TopBarView(
                userName: userName,
                userSubtitle: "Oggi: Presenza",
                pictureURL: auth.pictureURL,
                showsExit: true,
                onExit: onExit
            )

            AbsenceCalendarView(
                month: $calendarMonth,
                events: calendarEvents,
                isLoading: isCalendarLoading,
                errorMessage: calendarError
            )

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16
            ) {

                AbsenceTile(title: "Ferie/Rol", icon: "🏝️", color: .orange) {
                    FerieRolAbsenceView(
                        viewModel: viewModel,
                        locationProvider: locationProvider
                    )
                    .environmentObject(auth)
                }

                AbsenceTile(title: "Malattia", icon: "🛏️", color: Color(red: 1, green: 0.2, blue: 0.2)) {
                    DateRangeAbsenceView(
                        title: "Malattia",
                        actionId: 2,
                        viewModel: viewModel,
                        locationProvider: locationProvider
                    )
                }

                AbsenceTile(title: "Congedo", icon: "📅", color: .purple) {
                    DateRangeAbsenceView(
                        title: "Congedo",
                        actionId: 3,
                        viewModel: viewModel,
                        locationProvider: locationProvider
                    )
                }

                AbsenceTile(title: "Clienti", icon: "🐝", color: .blue) {
                    SingleDayConfirmView(
                        title: "Clienti",
                        actionId: 4,
                        viewModel: viewModel,
                        locationProvider: locationProvider
                    )
                }

                AbsenceTile(title: "Altro", icon: "❓", color: .green) {
                    SingleDayConfirmView(
                        title: "Altro",
                        actionId: 5,
                        viewModel: viewModel,
                        locationProvider: locationProvider
                    )
                }

                AbsenceTile(title: "Oggi", icon: "📊", color: Color(red: 1, green: 0.2, blue: 0.3)) {
                    TodayReportView(viewModel: viewModel)
                }
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            locationProvider.requestOnce()
            Task { await loadCalendarEvents() }
        }
        .onChange(of: calendarMonth) { _ in
            Task { await loadCalendarEvents() }
        }
        .alert(item: $viewModel.resultAlert) { a in
            Alert(
                title: Text(a.title),
                message: Text(a.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func loadCalendarEvents() async {
        isCalendarLoading = true
        calendarError = nil

        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendarMonth)) ?? calendarMonth
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? startOfMonth

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        do {
            let events = try await viewModel.fetchTodayReport(
                startDate: formatter.string(from: startOfMonth),
                endDate: formatter.string(from: endOfMonth)
            )

            var mapped: [Date: [Color]] = [:]
            for event in events {
                guard let start = formatter.date(from: event.data_inizio),
                      let end = formatter.date(from: event.data_fine) else { continue }

                var day = calendar.startOfDay(for: start)
                let lastDay = calendar.startOfDay(for: end)
                let color = calendarColor(for: event)

                while day <= lastDay {
                    mapped[day, default: []].append(color)
                    guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                    day = next
                }
            }

            calendarEvents = mapped
        } catch {
            calendarError = error.localizedDescription
        }

        isCalendarLoading = false
    }

    private func calendarColor(for event: ExportTodayEvent) -> Color {
        let action = event.azione.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if action.contains("malattia") { return Color(red: 1, green: 0.2, blue: 0.2) }
        if action.contains("congedo") { return .purple }
        if action.contains("clienti") { return .blue }
        if action.contains("altro") { return .green }
        if action.contains("ferie") || action.contains("rol") {
            let tipo = calendarTipoRichiesta(for: event)?.lowercased() ?? ""
            return tipo.contains("rol") ? .yellow : .orange
        }
        return .gray
    }

    private func calendarTipoRichiesta(for event: ExportTodayEvent) -> String? {
        if let tipo = event.tipo_richiesta { return tipo }
        if let raw = event.json_data["tipo_richiesta"],
           case let .string(value) = raw {
            return value
        }
        return nil
    }
}
