import SwiftUI

struct DateRangeAbsenceView: View {
    let title: String
    let actionId: Int

    @ObservedObject var viewModel: AbsenceViewModel
    @ObservedObject var locationProvider: LocationProvider

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isSending = false

    @State private var showLocalAlert = false
    @State private var localAlertMessage = ""

    var body: some View {
        Form {
            Section(header: Text(title)) {
                DatePicker("Data inizio", selection: $startDate, displayedComponents: .date)
                DatePicker("Data fine", selection: $endDate, displayedComponents: .date)
            }

            Section {
                Button {
                    Task { await send() }
                } label: {
                    HStack {
                        if isSending { ProgressView().padding(.trailing, 8) }
                        Text("Invia")
                    }
                }
                .disabled(isSending)
            }
        }
        .navigationTitle(title)
        .onAppear { locationProvider.requestOnce() }
        .alert("Attenzione", isPresented: $showLocalAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(localAlertMessage)
        }
        .alert(item: $viewModel.resultAlert) { a in
            Alert(title: Text(a.title), message: Text(a.message), dismissButton: .default(Text("OK")))
        }
    }

    private func send() async {
        // ✅ controllo date
        if endDate < startDate {
            localAlertMessage = "La data di fine non può essere precedente alla data di inizio."
            showLocalAlert = true
            return
        }

        isSending = true
        defer { isSending = false }

        await viewModel.submitAction(
            actionName: title,
            actionId: actionId,
            startDate: startDate,
            endDate: endDate,
            location: locationProvider.lastLocation
        )
    }
}
