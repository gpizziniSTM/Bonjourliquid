import SwiftUI

struct TopBarView: View {
    let userName: String?
    let userSubtitle: String?
    let pictureURL: String?
    let showsExit: Bool
    let onExit: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            if let userName, !userName.isEmpty {
                avatar
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.system(.headline, design: .default))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if let userSubtitle, !userSubtitle.isEmpty {
                        Text(userSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }

            Spacer()

            Image("logoSTM")
                .resizable()
                .scaledToFit()
                .frame(height: 30)

            if showsExit {
                Button("Esci", action: onExit)
                    .buttonStyle(.bordered)
                    .tint(.red)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.3), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private var avatar: some View {
        if let pictureURL,
           let url = URL(string: pictureURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    fallbackAvatar
                }
            }
        } else {
            fallbackAvatar
        }
    }

    private var fallbackAvatar: some View {
        Circle()
            .fill(.gray.opacity(0.25))
            .overlay(Text(String((userName ?? "").prefix(1))).bold())
    }
}
