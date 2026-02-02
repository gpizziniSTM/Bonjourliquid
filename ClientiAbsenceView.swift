import SwiftUI

struct ClientiAbsenceView: View {
    @ObservedObject var viewModel: AbsenceViewModel
    @ObservedObject var locationProvider: LocationProvider

    @EnvironmentObject private var auth: AuthSession
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate = Date()
    @State private var isSending = false

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
                    Text("Inserisci Clienti")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    dateField(title: "Data", date: selectedDate) {
                        // Date picker would go here
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
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    private func dateField(title: String, date: Date, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func send() async {
        // Implement sending logic for Clienti
        showLocalAlert = true
        localAlertMessage = "Funzionalità in corso di implementazione"
    }
}
