//
//  LoggedOutSplashView.swift
//  Bonjourliquid
//
//  Created by Giuseppe Pizzini on 15/12/25.
//


import SwiftUI

struct LoggedOutSplashView: View {
    let onEnter: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("🐝")
                .font(.system(size: 64))

            Text("Sei uscito")
                .font(.title2)
                .bold()

            Text("Torna alla schermata principale quando vuoi.")
                .foregroundStyle(.secondary)

            Button("Rientra") {
                onEnter()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        LoggedOutSplashView(onEnter: {})
    }
}