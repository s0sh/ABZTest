import Foundation
import Network

/// A singleton class that monitors the device's network path for connectivity changes.
///
/// It uses `NWPathMonitor` to provide a reactive stream of network status updates
/// through a Combine `@Published` property.
class Network: ObservableObject {
    
    static let shared = Network()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    /// A published property that indicates whether the device is connected to the internet.
    @Published var connected: Bool = false
    
    private init() {
        checkConnection()
    }
    
    /// Starts monitoring the network connection status.
    ///
    /// Updates the `connected` property on the main thread whenever the network path status changes.
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                        self.connected = true
                } else {
                        self.connected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case unknownError
    case emailAlreadyTaken
    case unauthorized
}

/// Provides a centralized service for all API interactions.
///
/// This class encapsulates the logic for making network requests to the backend API,
/// including fetching users, creating users, and getting positions. It uses modern
/// Swift concurrency with `async/await`.
final class NetworkService {
    
    // The base URL for the API.
    private let baseURL = "https://frontend-test-assignment-api.abz.agency/api/v1"//"https://openapi_apidocs.abz.dev/api/v1"
    // The authentication token for API requests.
    private let tokenKey = "api_token"
    
    private var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }
    
    // MARK: - Shared Instance
    static let shared = NetworkService()
    
    private init() {}
    
    // MARK: - Generic Request Method
    
    /// Performs a generic network request.
    /// - Parameters:
    ///   - endpoint: The API endpoint to append to the base URL.
    ///   - method: The HTTP method (e.g., "GET", "POST").
    ///   - body: The request body data for "POST" requests.
    /// - Returns: The decoded response object.
    /// - Throws: A `NetworkError` if the request fails at any stage.
    private func request<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            print("Using token: \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        print(request.httpBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Users Endpoints
    
    /// Fetches a list of users
    /// - Parameters:
    ///   - page: Page number to fetch (default: 1)
    ///   - count: Number of users per page (default: 5)
    func getUsers(page: Int = 1, count: Int = 5) async throws -> UserResponse {
        let endpoint = "/users?page=\(page)&count=\(count)"
        return try await request(endpoint: endpoint)
    }
    
    /// Creates a new user (multipart/form-data, Token header)
    /// - Parameter user: UserCreateRequest object with user data
    /// - Parameter photoData: JPEG image data
    func createUser(_ user: UserCreateRequest, photoData: Data) async throws -> CreateUserResponse {
        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
            throw NetworkError.unauthorized
        }
        let endpoint = "/users"
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Token")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createMultipartBody(with: user, photoData: photoData, boundary: boundary)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        do {
            let decodedData = try JSONDecoder().decode(CreateUserResponse.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.decodingError
        }
    }

    /// Helper to build multipart/form-data body
    private func createMultipartBody(with user: UserCreateRequest, photoData: Data, boundary: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        // name
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n")
        body.append("\(user.name)\r\n")
        // email
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n")
        body.append("\(user.email)\r\n")
        // phone
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"phone\"\r\n\r\n")
        body.append("\(user.phone)\r\n")
        // position_id
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"position_id\"\r\n\r\n")
        body.append("\(user.positionId)\r\n")
        // photo
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(photoData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    /// Gets a specific user by ID
    /// - Parameter id: User ID
    func getUser(id: Int) async throws -> User {
        let endpoint = "/users/\(id)"
        return try await request(endpoint: endpoint)
    }
    
    // MARK: - Positions Endpoints
    
    /// Fetches all available positions
    func getPositions() async throws -> PositionsResponse {
        let endpoint = "/positions"
        return try await request(endpoint: endpoint)
    }
    
    // MARK: - Token Endpoint
    
    /// Gets a new token
    func getToken() async throws -> TokenResponse {
        let endpoint = "/token"
        return try await request(endpoint: endpoint, method: "POST")
    }

    /// Call this to refresh and store a new token
    func refreshToken() async throws {
        let endpoint = "/token"
        let response: TokenResponse = try await request(endpoint: endpoint, method: "POST")
        self.token = response.token
        print("Refreshed token: \(response.token)")
    }

    /// Use this to get the current token, refreshing if needed
    func getValidToken() async throws -> String {
        if let token = self.token { return token }
        try await refreshToken()
        guard let token = self.token else { throw NetworkError.unknownError }
        return token
    }
}

// MARK: - Data Models (same as before)

struct UserResponse: Codable {
    let success: Bool
    let page: Int
    let totalPages: Int
    let totalUsers: Int
    let count: Int
    let links: Links
    let users: [User]
    
    enum CodingKeys: String, CodingKey {
        case success
        case page
        case totalPages = "total_pages"
        case totalUsers = "total_users"
        case count
        case links
        case users
    }
}

struct User: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let position: String
    let positionId: Int
    let photo: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case position
        case positionId = "position_id"
        case photo
    }
}

struct Links: Codable {
    let nextUrl: String?
    let prevUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case nextUrl = "next_url"
        case prevUrl = "prev_url"
    }
}

struct UserCreateRequest: Codable {
    let name: String
    let email: String
    let phone: String
    let positionId: Int
    let photo: String // Base64 encoded image
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case phone
        case positionId = "position_id"
        case photo
    }
}

struct PositionsResponse: Codable {
    let success: Bool
    let positions: [Position]
}

struct Position: Codable, Identifiable {
    let id: Int
    let name: String
}

struct TokenResponse: Codable {
    let success: Bool
    let token: String
}

struct CreateUserResponse: Codable {
    let success: Bool
    let message: String?
    let userId: Int?
    let users: [User]?
    let fails: [String: [String]]?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case userId = "user_id"
        case users
        case fails
    }
}

// MARK: - Data.append(String) extension for multipart
import Foundation
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
