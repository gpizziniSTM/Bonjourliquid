import SwiftUI

struct TopBarView: View {
    let userName: String
    let userEmail: String
    let pictureURL: String?
    let onExit: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            avatar
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(userName)
                    .font(.system(.headline, design: .default))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }

            Spacer()

            Button("Esci", action: onExit)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 3)
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
            .overlay(Text(String(userName.prefix(1))).bold())
    }
}
