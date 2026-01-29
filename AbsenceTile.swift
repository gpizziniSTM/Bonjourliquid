import SwiftUI

struct AbsenceTile<Destination: View>: View {
    let title: String
    let icon: String
    let color: Color
    let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            VStack(spacing: 12) {
                Circle()
                    .stroke(.black.opacity(0.6), lineWidth: 2)
                    .frame(width: 72, height: 72)
                    .overlay(Text(icon).font(.system(size: 32)))

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 170)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(radius: 4)
        }
        .buttonStyle(.plain)
    }
}
