import SwiftUI

struct SplashView: View {

    let onEnter: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            TopBarView(
                userName: nil,
                userSubtitle: nil,
                pictureURL: nil,
                showsExit: false,
                onExit: {}
            )

            Spacer()

            Image("logoTitle")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300)

            Spacer()

            Button {
                onEnter()
            } label: {
                Text("Entra")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 48)
            .padding(.bottom, 40)
        }
        .padding(.top, 8)
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SplashView(onEnter: {})
}
