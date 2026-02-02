import SwiftUI

struct DateRangeAbsenceView: View {
    let title: String
    let actionId: Int

    @ObservedObject var viewModel: AbsenceViewModel
    @ObservedObject var locationProvider: LocationProvider

    @EnvironmentObject private var auth: AuthSession
    @Environment(\.dismiss) private var dismiss

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isSending = false

    @State private var showStartPicker = false
    @State private var showEndPicker = false

    @State private var showLocalAlert = false
    @State private var localAlertMessage = ""

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
                    Text("Inserisci \(title)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    dateField(title: "Data inizio", date: startDate) {
                        showStartPicker = true
                    }

                    dateField(title: "Data fine", date: endDate) {
                        showEndPicker = true
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func send() async {
        // ✅ controllo date
        showLocalAlert = false
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
