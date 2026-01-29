import SwiftUI

struct FerieRolAbsenceView: View {
    @ObservedObject var viewModel: AbsenceViewModel
    @ObservedObject var locationProvider: LocationProvider

    private let actionName = "Ferie/Rol"
    private let actionId = 1

    enum Tipo: String, CaseIterable, Identifiable {
        case ferie = "Ferie"
        case rol = "Rol"
        var id: String { rawValue }
    }

    @State private var tipo: Tipo = .ferie

    @State private var startDate = Date()
    @State private var endDate = Date()

    @State private var oraInizio = Date()
    @State private var oraFine = Date()

    @State private var isSending = false

    @State private var showLocalAlert = false
    @State private var localAlertMessage = ""

    var body: some View {
        Form {
            Section(header: Text(actionName)) {
                Picker("Tipo richiesta", selection: $tipo) {
                    ForEach(Tipo.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.menu)
            }

            if tipo == .ferie {
                Section(header: Text("Periodo")) {
                    DatePicker("Data inizio", selection: $startDate, displayedComponents: .date)
                    DatePicker("Data fine", selection: $endDate, displayedComponents: .date)
                }
            } else {
                Section(header: Text("Giorno ROL")) {
                    DatePicker("Data", selection: $startDate, displayedComponents: .date)
                }
                Section(header: Text("Orario")) {
                    DatePicker("Ora inizio", selection: $oraInizio, displayedComponents: .hourAndMinute)
                    DatePicker("Ora fine", selection: $oraFine, displayedComponents: .hourAndMinute)
                }
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
        .navigationTitle(actionName)
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
        // ✅ controlli
        if tipo == .ferie {
            if endDate < startDate {
                localAlertMessage = "La data di fine non può essere precedente alla data di inizio."
                showLocalAlert = true
                return
            }
        } else {
            // ROL: stessa data
            endDate = startDate

            if oraFine < oraInizio {
                localAlertMessage = "L'ora di fine non può essere precedente all'ora di inizio."
                showLocalAlert = true
                return
            }
        }

        isSending = true
        defer { isSending = false }

        var extra: [String: Any] = [
            "tipo_richiesta": tipo.rawValue
        ]

        if tipo == .rol {
            extra["ora_inizio_rol"] = AbsenceViewModel.formatHourMinute(oraInizio)
            extra["ora_fine_rol"] = AbsenceViewModel.formatHourMinute(oraFine)
        }

        await viewModel.submitAction(
            actionName: actionName,
            actionId: actionId,
            extraJSON: extra,
            startDate: startDate,
            endDate: endDate,
            location: locationProvider.lastLocation
        )
    }
}
