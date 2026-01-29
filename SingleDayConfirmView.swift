import SwiftUI

struct SingleDayConfirmView: View {
    let title: String
    let actionId: Int

    @ObservedObject var viewModel: AbsenceViewModel
    @ObservedObject var locationProvider: LocationProvider

    @State private var date = Date()
    @State private var isSending = false

    var body: some View {
        Form {
            Section(header: Text(title)) {
                DatePicker("Data", selection: $date, displayedComponents: .date)
            }

            Section {
                Button {
                    Task { await send() }
                } label: {
                    HStack {
                        if isSending { ProgressView().padding(.trailing, 8) }
                        Text("Conferma")
                    }
                }
                .disabled(isSending)
            }
        }
        .navigationTitle(title)
        .onAppear { locationProvider.requestOnce() }
        .alert(item: $viewModel.resultAlert) { a in
            Alert(title: Text(a.title), message: Text(a.message), dismissButton: .default(Text("OK")))
        }
    }

    private func send() async {
        isSending = true
        defer { isSending = false }

        await viewModel.submitAction(
            actionName: title,
            actionId: actionId,
            startDate: date,
            endDate: date,
            location: locationProvider.lastLocation
        )
    }
}
