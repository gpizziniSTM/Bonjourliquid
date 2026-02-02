import SwiftUI

struct FerieRolAbsenceView: View {
    @ObservedObject var viewModel: AbsenceViewModel
    @ObservedObject var locationProvider: LocationProvider

    @EnvironmentObject private var auth: AuthSession
    @Environment(\.dismiss) private var dismiss

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

    @State private var showStartPicker = false
    @State private var showEndPicker = false
    @State private var showSingleDayPicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 8)

                VStack(spacing: 16) {
                    Text("Inserisci \(actionName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Picker("Tipo richiesta", selection: $tipo) {
                        ForEach(Tipo.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)

                    if tipo == .ferie {
                        dateField(title: "Data inizio", date: startDate) {
                            showStartPicker = true
                        }

                        dateField(title: "Data fine", date: endDate) {
                            showEndPicker = true
                        }
                    } else {
                        dateField(title: "Data", date: startDate) {
                            showSingleDayPicker = true
                        }

                        timeField(title: "Ora inizio", date: oraInizio) {
                            showStartTimePicker = true
                        }

                        timeField(title: "Ora fine", date: oraFine) {
                            showEndTimePicker = true
                        }
                    }

                    if showLocalAlert {
                        Text(localAlertMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

                HStack(spacing: 16) {
                    Button("Annulla") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.25))

                    Button {
                        Task { await send() }
                    } label: {
                        HStack {
                            if isSending { ProgressView().padding(.trailing, 8) }
                            Text("Conferma")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSending)
                }
                .padding(.top, 6)

                Spacer()
            }
            .padding()
        }
        .onAppear { locationProvider.requestOnce() }
        .sheet(isPresented: $showStartPicker) {
            datePickerSheet(title: "Data inizio", selection: $startDate) {
                showStartPicker = false
            }
        }
        .sheet(isPresented: $showEndPicker) {
            datePickerSheet(title: "Data fine", selection: $endDate) {
                showEndPicker = false
            }
        }
        .sheet(isPresented: $showSingleDayPicker) {
            datePickerSheet(title: "Data", selection: $startDate) {
                showSingleDayPicker = false
            }
        }
        .sheet(isPresented: $showStartTimePicker) {
            timePickerSheet(title: "Ora inizio", selection: $oraInizio) {
                showStartTimePicker = false
            }
        }
        .sheet(isPresented: $showEndTimePicker) {
            timePickerSheet(title: "Ora fine", selection: $oraFine) {
                showEndTimePicker = false
            }
        }
        .alert(item: $viewModel.resultAlert) { a in
            Alert(title: Text(a.title), message: Text(a.message), dismissButton: .default(Text("OK")))
        }
    }

    private func dateField(title: String, date: Date, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Text(formattedDate(date))
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "calendar")
                    .font(.headline)
                    .foregroundColor(.cyan)
                    .padding(8)
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(14)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func timeField(title: String, date: Date, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Text(formattedTime(date))
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "clock")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(14)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func datePickerSheet(title: String, selection: Binding<Date>, onClose: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            DatePicker("", selection: selection, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()

            Button("Chiudi") {
                onClose()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }

    private func timePickerSheet(title: String, selection: Binding<Date>, onClose: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()

            Button("Chiudi") {
                onClose()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium])
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func send() async {
        // ✅ controlli
        showLocalAlert = false
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
