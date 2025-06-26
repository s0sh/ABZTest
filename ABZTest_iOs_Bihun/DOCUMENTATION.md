# Project Documentation

This document provides a high-level overview of the application's architecture, external dependencies, and important modules.

## Code Structure

The project follows the MVVM (Model-View-ViewModel) design pattern to separate the user interface (View) from the business logic and data (ViewModel and Model). The files are organized into the following main groups:

-   **`ABZTest_iOs_BihunApp.swift`**: The main entry point for the SwiftUI application.
-   **`ViewModels/`**:
    -   `UserViewModel.swift`: The central hub of the application. It manages application state, handles all business logic (like user input validation), and communicates with the `NetworkService` to fetch and update data.
-   **`Views/`**: Contains all SwiftUI views, organized by feature.
    -   `List/`: Contains `UserListView` for displaying the list of users and `UserRowView` for each individual cell.
    -   `CreateUser/`: Contains `CreateUserView` and its helper extensions for the user creation form.
    -   `NoInternetConnectionEmptyStateView.swift` & `NoUsersEmptyStateView.swift`: Reusable views for different empty states.
-   **`Utilities/`**: Houses shared services and helper classes.
    -   `NetworkService.swift`: Handles all API communication. It encapsulates URL construction, request creation, and response handling.
    -   `Image/`: Contains the image loading and caching infrastructure (`ImageURLStorage`, `ImageLoader`).
-   **`Models` (Implicit)**: The data models (e.g., `User`, `Position`) are defined within `NetworkService.swift`. In a larger application, these would be moved to their own `Models/` group.
-   **`Extensions/`**: Contains convenient extensions to standard Swift types, like `String+EmailValidation.swift`.
-   **`AppConstants.swift`**: A place for storing globally used constants, such as color definitions.

## Caching Strategy

The application employs two levels of caching to ensure a smooth user experience and reduce network overhead:

1.  **User Object Cache**:
    -   **Location**: `UserViewModel.swift`
    -   **Mechanism**: A simple in-memory `Dictionary<Int, User>` (`userCache`) is used to store `User` objects by their unique ID.
    -   **Purpose**: This prevents the app from re-fetching user data from the network when scrolling up and down the list. When new pages of users are loaded, they are added to the cache, and the list is populated from this single source of truth. This cache is session-specific and will be cleared when the app is terminated.

2.  **Image Cache**:
    -   **Location**: `ImageURLStorage.swift`
    -   **Mechanism**: Leverages Apple's native `URLCache`.
    -   **Purpose**: This provides a persistent (in-memory and on-disk) cache for downloaded images. When a user's avatar is requested, the system first checks this cache. If the image is present, it's displayed instantly, avoiding a network request. This significantly improves scrolling performance and data usage.

## External APIs and Libraries

The application is designed to be lightweight and avoids external third-party libraries. It leverages Apple's native frameworks for its core functionality.

### APIs

-   **Test API (`frontend-test-assignment-api.abz.agency`)**:
    -   **Purpose**: This is the backend service from which the application fetches the list of users and positions, and to which it submits new users.
    -   **Reason for Use**: This is the required API for the test assignment. All communication is encapsulated within `NetworkService.swift`.

### Native Frameworks Used

-   **SwiftUI**:
    -   **Purpose**: Used for the entire user interface.
    -   **Reason for Use**: It's Apple's modern, declarative framework for building UIs across all Apple platforms.
-   **Combine**:
    -   **Purpose**: Used within the `ImageLoader` and `UserViewModel` to handle asynchronous operations and create reactive data streams (e.g., for network status).
    -   **Reason for Use**: It provides a powerful, native way to manage asynchronous events over time, fitting perfectly with the MVVM pattern.
-   **Network (`NWPathMonitor`)**:
    -   **Purpose**: Used in the `Network` singleton class to monitor the device's internet connectivity.
    -   **Reason for Use**: This is Apple's recommended framework for checking network status. It's more reliable and efficient than older methods.
-   **URLCache**:
    -   **Purpose**: Used by `ImageURLStorage` to provide both in-memory and on-disk caching for downloaded images.
    -   **Reason for Use**: It's a built-in and powerful caching mechanism that requires minimal configuration, significantly improving performance and reducing network usage for repeated image views. 