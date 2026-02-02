import SwiftUI

struct TopBarView: View {
    let userName: String?
    let userSubtitle: String?
    let pictureURL: String?

    var body: some View {
        HStack(spacing: 16) {

            if let userName, !userName.isEmpty {
                avatar
                    .frame(width: 56, height: 56)
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
                .frame(height: 48)
                .padding(.trailing, 4)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.35), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
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
