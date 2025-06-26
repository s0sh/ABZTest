
import SwiftUI

struct SplashScreenView: View {
    
    @EnvironmentObject var viewModel: UserViewModel
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    @StateObject var network = Network.shared
    
    var body: some View {
        ZStack {
            AppConstants.Colors.Main.primary.ignoresSafeArea()
            if isActive {
                if !network.connected {
                    Color.white.ignoresSafeArea()
                    NoInternetConnectionEmptyStateView()
                        .environmentObject(viewModel)
                } else {
                    ContentView()
                        .environmentObject(viewModel)
                }
            } else {
                VStack {
                    VStack {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 106)
                            .foregroundColor(.black)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
