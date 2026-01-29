import SwiftUI

struct SplashView: View {

    let onEnter: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Image("logoTitle")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360)

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
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SplashView(onEnter: {})
}
