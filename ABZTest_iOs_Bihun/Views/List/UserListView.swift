import SwiftUI
#Preview {
    UserListView()
        .environmentObject(UserViewModel())
}
struct UserListView: View {
    
    @EnvironmentObject var viewModel: UserViewModel
    
    var body: some View {
            ZStack {
                if !viewModel.isOnline {
                    NoInternetConnectionEmptyStateView()
                        .environmentObject(viewModel)
                } else if viewModel.users.isEmpty {
                    ZStack {
                        VStack {
                            Spacer()
                            NoUsersEmptyStateView()
                            Spacer()
                        }
                        .onAppear {
                            viewModel.loadUsers()
                        }
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        
                        CommonHeader(requestType: "GET")
                        
                        List {
                            ForEach(viewModel.users) { user in
                                UserRowView(user: user)
                                    .onAppear {
                                        if user.id == viewModel.users.last?.id {
                                            viewModel.loadMoreUsers()
                                        }
                                    }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .overlay {
                            if viewModel.isLoading && !viewModel.users.isEmpty {
                                ProgressView()
                            }
                        }
                        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                            Button("OK") { viewModel.errorMessage = nil }
                        } message: {
                            Text(viewModel.errorMessage ?? "")
                        }
                    }
                    .background(
                        Color.white.ignoresSafeArea()
                    )
                    
                    .onAppear {
                        if viewModel.users.isEmpty {
                            viewModel.loadUsers()
                        }
                    }
                }
            }
        
    }
}
