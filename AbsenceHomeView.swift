import SwiftUI

struct AbsenceHomeView: View {
    @ObservedObject var viewModel: AbsenceViewModel
    let onExit: () -> Void

    @EnvironmentObject private var auth: AuthSession
    @StateObject private var locationProvider = LocationProvider()

    private var userName: String {
        auth.displayName ?? auth.fallbackName()
    }

    private var userEmail: String {
        auth.email ?? ""
    }

    var body: some View {
        VStack(spacing: 16) {

            TopBarView(
                userName: userName,
                userEmail: userEmail,
                pictureURL: auth.pictureURL,
                onExit: onExit
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
        .onAppear { locationProvider.requestOnce() }
        .alert(item: $viewModel.resultAlert) { a in
            Alert(
                title: Text(a.title),
                message: Text(a.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
