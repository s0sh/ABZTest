import Foundation
import Combine
import SwiftUI

/// Manages the state and business logic for user-related views.
///
/// This ViewModel is responsible for:
/// - Fetching users and positions from the network.
/// - Handling pagination for the user list.
/// - Managing the creation of new users.
/// - Observing network connectivity status.
/// - Validating user input fields for the creation form.
final class UserViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// The list of users to be displayed.
    @Published var users: [User] = []
    /// The list of available positions for user creation.
    @Published var positions: [Position] = []
    /// A flag to indicate if a network operation is in progress (e.g., for showing a loading indicator).
    @Published var isLoading = false
    /// A flag to indicate if more users are being loaded for pagination.
    @Published var isLoadingMore = false
    /// An optional string containing an error message to be displayed to the user.
    @Published var errorMessage: String? = nil
    /// The current page of the user list.
    @Published var currentPage = 0
    /// The total number of pages available for the user list.
    @Published var totalPages = 1
    /// A flag indicating if there is more data to fetch for pagination.
    @Published var hasMoreData = true
    /// The ID of the position selected in the user creation form.
    @Published var selectedPositionId = 1
    /// The name entered in the user creation form.
    @Published var name = ""
    /// The email entered in the user creation form.
    @Published var email = ""
    /// The phone number entered in the user creation form.
    @Published var phone = ""
    /// A flag indicating the device's current internet connection status.
    @Published var isOnline: Bool = false
    
    // MARK: - Validation Properties
    
    /// A flag indicating if the name field is valid.
    @Published var nameFieldValid = true
    /// A flag indicating if the email field is valid.
    @Published var emailFieldValid = true
    /// A flag indicating if the phone field is valid.
    @Published var phoneFieldValid = true
    /// A flag indicating if a photo has been selected.
    @Published var photoFieldValid = true
    /// A flag to track if the user has attempted to submit the creation form, used to trigger validation UI.
    @Published var hasAttemptedSignUp = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    private var userCache: [Int: User] = [:]
    
    var imageLoader = OptionalImageLoader()
    
    // MARK: - Initialization
    /// Initializes the ViewModel.
    /// - Parameter networkService: A service conforming to `NetworkServiceProtocol`. Defaults to the shared `NetworkService` instance.
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
        
        // Subscribe to network status changes.
        Network.shared.$connected
            .receive(on: DispatchQueue.main)
            .removeDuplicates() // Only react to changes in state (e.g., false -> true)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                self.isOnline = isConnected
                
                // If we just came online and we don't have any users, load them automatically.
                if isConnected && self.users.isEmpty {
                    self.loadUsers()
                }
            }
            .store(in: &cancellables)
            
        loadPositions()
    }
    
    // MARK: - Public Methods
    /// Validates all fields for user creation.
    /// Sets the `hasAttemptedSignUp` flag to true, which triggers validation UI in the view.
    /// - Returns: A boolean indicating if all fields are valid.
    @discardableResult
    func validateFields() -> Bool {
        hasAttemptedSignUp = true
        
        nameFieldValid = name.count > 1 && name.count < 61
        emailFieldValid = email.isEmailValid()
        phoneFieldValid = (phone.count == 13 && phone.contains("+380"))
        
        // This assumes the photo is passed in separately, so we'll need a way to track it.
        // For now, let's add a placeholder check. We'll update createUser to handle this.
        
        return nameFieldValid && emailFieldValid && phoneFieldValid && photoFieldValid
    }
    
    /// Loads the first page of users from the network.
    func loadUsers(page: Int = 1, count: Int = 6) {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let response = try await networkService.getUsers(page: page, count: count)
                // Update the cache with new users
                for user in response.users {
                    userCache[user.id] = user
                }
                // Use cached users for display
                let newUsers = response.users.compactMap { userCache[$0.id] }
                if page == 1 {
                    self.users = newUsers
                } else {
                    // Avoid duplicates
                    let existingIds = Set(self.users.map { $0.id })
                    let filteredNewUsers = newUsers.filter { !existingIds.contains($0.id) }
                    self.users += filteredNewUsers
                }
                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.isLoading = false
                self.hasMoreData = response.count == 6
            } catch {
                self.handleError(error)
            }
        }
    }
    /// Loads more users (pagination)
    func loadMoreUsers() {
        guard !isLoadingMore && hasMoreData else { return }
        
        guard currentPage < totalPages, !isLoading else { return }
        loadUsers(page: currentPage + 1)
        
    }
    
    /// Creates a new user after validating the input fields.
    func createUser(photoData: Data?) {
        photoFieldValid = photoData != nil
        guard validateFields() else { return }

        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                let request = UserCreateRequest(
                    name: name,
                    email: email,
                    phone: phone,
                    positionId: selectedPositionId,
                    photo: "" // Not used in multipart, but required by struct
                )
                guard let photoData = photoData else {
                    self.errorMessage = "Photo is required."
                    self.isLoading = false
                    return
                }
                do {
                    let response = try await networkService.createUser(request, photoData: photoData)
                    if response.success, let newUserId = response.userId {
                        let newUser = try await networkService.getUser(id: newUserId)
                        self.users.insert(newUser, at: 0)
                        self.userCache[newUser.id] = newUser
                        self.isLoading = false
                    } else  {
                        self.errorMessage = "Email should be valid."
                        self.isLoading = false
                    }
                } catch NetworkError.unauthorized {
                    try await networkService.refreshToken()
                    let response = try await networkService.createUser(request, photoData: photoData)
                    if response.success, let newUserId = response.users?.last?.id {
                        let newUser = try await networkService.getUser(id: newUserId)
                        self.users.insert(newUser, at: 0)
                        self.userCache[newUser.id] = newUser
                        self.isLoading = false
                    } else {
                        self.errorMessage = "Cannot create user. Authentification failed[Token expired?]."
                        self.isLoading = false
                    }
                }
            } catch {
                self.handleError(error)
            }
        }
    }
    
    /// Loads all available positions
    func loadPositions() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let response = try await networkService.getPositions()
                self.positions = response.positions
                self.isLoading = false
                if isLoadingMore == true {
                    isLoadingMore = false
                }
            } catch {
                self.handleError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    /// A centralized method to handle errors from network operations.
    /// - Parameter error: The error that occurred.
    private func handleError(_ error: Error) {
        isLoading = false
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                errorMessage = "Invalid URL"
            case .noData:
                errorMessage = "No data received"
            case .decodingError:
                errorMessage = "Failed to decode response"
            case .serverError(let statusCode):
            var messageFromeCode = switch statusCode {
                case 422:
                    errorMessage = "Email should be valid."
                //...Other cases... //
                default:
                    errorMessage = "Server error: \(statusCode)"
                }
                errorMessage = "Server error: \(statusCode)"
            case .unknownError:
                errorMessage = "Unknown error occurred"
            case .emailAlreadyTaken:
                errorMessage = "Email exists"
            case .unauthorized:
                print("Token expired..Refreshing...")
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Protocol for Network Service (for testing/mocking)

/// A protocol defining the network service interface.
/// This allows for dependency injection and easier testing by using mock services.
protocol NetworkServiceProtocol {
    func getUsers(page: Int, count: Int) async throws -> UserResponse
    func createUser(_ user: UserCreateRequest, photoData: Data) async throws -> CreateUserResponse
    func getUser(id: Int) async throws -> User
    func getPositions() async throws -> PositionsResponse
    func getToken() async throws -> TokenResponse
    func refreshToken() async throws
    func getValidToken() async throws -> String
}

// MARK: - Conform NetworkService to NetworkServiceProtocol
extension NetworkService: NetworkServiceProtocol {}
