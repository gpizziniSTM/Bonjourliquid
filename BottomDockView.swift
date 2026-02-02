import SwiftUI

struct BottomDockView: View {
    @State private var selectedAction: String = "calendario"
    
    let onMalattia: () -> Void
    let onFerie: () -> Void
    let onROL: () -> Void
    let onCongedo: () -> Void
    let onClienti: () -> Void
    let onAltro: () -> Void
    let onOggi: () -> Void
    let onEsci: () -> Void
    let onIndietro: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                // Riga 1: Oggi, Esci, Indietro
                HStack(spacing: 12) {
                    DockButton(
                        icon: "📅",
                        label: "Oggi",
                        color: Color(red: 0.2, green: 0.6, blue: 1),
                        isSelected: false,
                        action: {
                            selectedAction = "oggi"
                            onOggi()
                        }
                    )
                    
                    Spacer()
                    
                    DockButton(
                        icon: "🚪",
                        label: "Esci",
                        color: Color(red: 1, green: 0.3, blue: 0.3),
                        isSelected: false,
                        action: {
                            selectedAction = "esci"
                            onEsci()
                        }
                    )
                    
                    DockButton(
                        icon: "⬅️",
                        label: "Indietro",
                        color: Color(red: 0.7, green: 0.7, blue: 0.7),
                        isSelected: false,
                        action: {
                            selectedAction = "indietro"
                            onIndietro()
                        }
                    )
                }
                
                // Riga 2: Malattia, Ferie, Congedo, Clienti
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
                        label: "Ferie/ROL",
                        color: .orange,
                        isSelected: selectedAction == "ferie" || selectedAction == "rol",
                        action: {
                            selectedAction = "ferie"
                            onFerie()
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
                        icon: "👥",
                        label: "Clienti",
                        color: Color(red: 0.2, green: 0.8, blue: 0.6),
                        isSelected: selectedAction == "clienti",
                        action: {
                            selectedAction = "clienti"
                            onClienti()
                        }
                    )
                    
                    DockButton(
                        icon: "📝",
                        label: "Altro",
                        color: Color(red: 0.9, green: 0.5, blue: 0.2),
                        isSelected: selectedAction == "altro",
                        action: {
                            selectedAction = "altro"
                            onAltro()
                        }
                    )
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.35), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 12)
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
        onClienti: {},
        onAltro: {},
        onOggi: {},
        onEsci: {},
        onIndietro: {}
    )
}
