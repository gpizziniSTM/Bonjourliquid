import SwiftUI

struct LockedView: View {

    @EnvironmentObject private var auth: AuthSession

    var body: some View {
        VStack(spacing: 18) {

            Spacer()

            Text("App bloccata")
                .font(.title2).bold()

            Text("Sblocca con Face ID / Touch ID")
                .foregroundStyle(.secondary)

            Button {
                auth.unlockWithBiometrics()
            } label: {
                Text("Sblocca")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            if let err = auth.errorMessage, !err.isEmpty {
                Text(err)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Cambia utente") {
                auth.clearSessionAndGoToRegistration()
            }
            .padding(.top, 6)

            Spacer()
        }
        .padding()
    }
}
