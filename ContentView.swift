import SwiftUI

struct ContentView: View {

    @StateObject private var auth: AuthSession
    @StateObject private var viewModel: AbsenceViewModel

    @State private var didTapEnter = false

    init() {
        let a = AuthSession()
        _auth = StateObject(wrappedValue: a)
        _viewModel = StateObject(wrappedValue: AbsenceViewModel(auth: a))
    }

    var body: some View {
        NavigationStack {
            if auth.isAuthenticated && auth.isUnlocked {
                AbsenceHomeView(viewModel: viewModel, onExit: { auth.lock() })
                    .environmentObject(auth)

            } else if auth.isAuthenticated && !auth.isUnlocked {
                LockedView()
                    .environmentObject(auth)

            } else {
                if !didTapEnter {
                    SplashView(onEnter: {
                        didTapEnter = true
                    })
                } else {
                    SplashAuthView()
                        .environmentObject(auth)
                }
            }
        }
    }
}
