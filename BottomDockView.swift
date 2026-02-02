import SwiftUI

struct BottomDockView: View {
    @State private var selectedAction: String = "ferie"
    let onMalattia: () -> Void
    let onFerie: () -> Void
    let onROL: () -> Void
    let onCongedo: () -> Void
    let onEsci: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))

            HStack(spacing: 12) {
                DockButton(
                    icon: "🛏️",
                    label: "Malattia",
                    color: Color(red: 1, green: 0.2, blue: 0.2),
                    isSelected: selectedAction == "malattia",
                    action: {
                        selectedAction = "malattia"
                        onMalattia()
                    }
                )

                DockButton(
                    icon: "🏝️",
                    label: "Ferie",
                    color: .orange,
                    isSelected: selectedAction == "ferie",
                    action: {
                        selectedAction = "ferie"
                        onFerie()
                    }
                )

                DockButton(
                    icon: "⏱️",
                    label: "ROL",
                    color: Color(red: 1, green: 0.8, blue: 0),
                    isSelected: selectedAction == "rol",
                    action: {
                        selectedAction = "rol"
                        onROL()
                    }
                )

                DockButton(
                    icon: "🤝",
                    label: "Congedo",
                    color: .purple,
                    isSelected: selectedAction == "congedo",
                    action: {
                        selectedAction = "congedo"
                        onCongedo()
                    }
                )

                DockButton(
                    icon: "🚪",
                    label: "Esci",
                    color: Color(red: 1, green: 0.3, blue: 0.3),
                    isSelected: selectedAction == "esci",
                    action: {
                        selectedAction = "esci"
                        onEsci()
                    }
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.3), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color.black)
    }
}

struct DockButton: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(icon)
                    .font(.system(size: 24))

                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isSelected ? 0.8 : 0.5))
            )
        }
    }
}

#Preview {
    BottomDockView(
        onMalattia: {},
        onFerie: {},
        onROL: {},
        onCongedo: {},
        onEsci: {}
    )
}
