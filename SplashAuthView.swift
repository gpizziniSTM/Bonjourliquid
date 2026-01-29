import SwiftUI

struct SplashAuthView: View {

    @EnvironmentObject var auth: AuthSession
    @FocusState private var focus: Field?

    enum Field { case email, pin }

    var body: some View {
        VStack(spacing: 18) {

            Spacer()

            Text("Bonjour")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(.white)

            Text("Inserisci la tua email @stmitalia.com")
                .foregroundStyle(.gray)

            VStack(spacing: 12) {

                TextField("nome.cognome@stmitalia.com", text: $auth.enteredEmail)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .foregroundStyle(.white)
                    .focused($focus, equals: .email)

                if auth.isAwaitingPIN {
                    TextField("PIN", text: $auth.enteredPIN)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.white)
                        .focused($focus, equals: .pin)
                }

                Button {
                    Task {
                        if auth.isAwaitingPIN {
                            await auth.submitPIN()
                        } else {
                            await auth.submitEmail()
                        }
                    }
                } label: {
                    Text(auth.isAwaitingPIN ? "Invia PIN" : "Continua")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(auth.isLoading)

                if let err = auth.errorMessage {
                    Text(err)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                }
            }
            .padding(.horizontal, 28)

            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear { focus = .email }
    }
}
