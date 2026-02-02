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
                // Riga 1: Altro, Oggi, Esci, Indietro
                HStack(spacing: 12) {
                    DockButton(
                        icon: "📝",
                        label: "Altro",
                        color: Color(red: 0.498, green: 0.0, blue: 1.0),  // Ultra Purple #7F00FF
                        isSelected: selectedAction == "altro",
                        action: {
                            selectedAction = "altro"
                            onAltro()
                        }
                    )
                    
                    DockButton(
                        icon: "📅",
                        label: "Oggi",
                        color: Color(red: 0.102, green: 0.451, blue: 0.910),  // Deep Tech Blue #1A73E8
                        isSelected: false,
                        action: {
                            selectedAction = "oggi"
                            onOggi()
                        }
                    )
                    
                    DockButton(
                        icon: "🚪",
                        label: "Esci",
                        color: Color(red: 0.95, green: 0.95, blue: 0.95),  // Vivid White
                        isSelected: false,
                        action: {
                            selectedAction = "esci"
                            onEsci()
                        },
                        textColor: .black
                    )
                    
                    DockButton(
                        icon: "⬅️",
                        label: "Indietro",
                        color: Color(red: 0.95, green: 0.95, blue: 0.95),  // Vivid White
                        isSelected: false,
                        action: {
                            selectedAction = "indietro"
                            onIndietro()
                        },
                        textColor: .black
                    )
                }
                
                // Riga 2: Malattia, Ferie/ROL, Congedo, Clienti
                HStack(spacing: 12) {
                    DockButton(
                        icon: "🛏️",
                        label: "Malattia",
                        color: Color(red: 1.0, green: 0.231, blue: 0.188),  // iOS Danger Red #FF3B30
                        isSelected: selectedAction == "malattia",
                        action: {
                            selectedAction = "malattia"
                            onMalattia()
                        }
                    )
                    
                    DockButton(
                        icon: "🏝️",
                        label: "Ferie/ROL",
                        color: Color(red: 0.956, green: 0.766, blue: 0.188),  // Warm Gold #F4C430
                        isSelected: selectedAction == "ferie" || selectedAction == "rol",
                        action: {
                            selectedAction = "ferie"
                            onFerie()
                        }
                    )
                    
                    DockButton(
                        icon: "🤝",
                        label: "Congedo",
                        color: Color(red: 0.118, green: 0.913, blue: 0.714),  // Neon Aqua #1DE9B6
                        isSelected: selectedAction == "congedo",
                        action: {
                            selectedAction = "congedo"
                            onCongedo()
                        }
                    )
                    
                    DockButton(
                        icon: "👥",
                        label: "Clienti",
                        color: Color(red: 0.0, green: 0.784, blue: 0.325),  // Mint Intense #00C853
                        isSelected: selectedAction == "clienti",
                        action: {
                            selectedAction = "clienti"
                            onClienti()
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
        }
        .padding(.bottom)
    }
}

struct DockButton: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    var textColor: Color = .white

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
            .foregroundColor(textColor)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isSelected ? 1.0 : 0.8))
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
