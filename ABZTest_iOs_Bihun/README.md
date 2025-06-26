# ABZ Test iOS Application

This is a sample iOS application built with SwiftUI that demonstrates fetching, displaying, and creating users from a test API.

## Building the Application

To build and run the application, follow these steps:
1.  Clone the repository to your local machine.
2.  Open the `ABZTest_iOs_Bihun.xcodeproj` file in Xcode (version 15 or newer is recommended).
3.  Select a target simulator or a connected physical device.
4.  Press the "Run" button (or `Cmd+R`) to build and launch the app.

## Dependencies

This project is self-contained and does not rely on any external third-party libraries managed by CocoaPods or Swift Package Manager. It is built using Apple's native frameworks:
-   **SwiftUI**: For building the user interface.
-   **Combine**: For handling asynchronous events and reactive programming.
-   **Network**: For monitoring the device's network connectivity status.

## Configuration

The main configuration options are located in `ABZTest_iOs_Bihun/Utilities/NetworkService.swift`:

-   **`baseURL`**: The base URL for the backend API.
-   **`token`**: The authentication token required for API requests.

If you need to target a different API endpoint or use a new token, you can modify these properties within the `NetworkService` class.

## Troubleshooting

-   **App fails to load users**:
    -   Ensure your device or simulator has an active internet connection. The app has a built-in network monitor and will display an "No Internet" message if it's offline.
    -   Verify that the `baseURL` and `token` in `NetworkService.swift` are correct and that the API server is reachable.
-   **Images are not loading**:
    -   This is likely a network issue. Check your internet connection and ensure the image URLs provided by the API are valid. The app caches images, so subsequent loads should be faster.
-   **Build Fails**:
    -   Ensure you are using a version of Xcode that supports the Swift features used in the project (Xcode 15+ is recommended).
    -   If you encounter persistent build issues, try cleaning the build folder (`Cmd+Shift+K`) and rebuilding the project. 