# 🛒 ShopApp

A production-ready e-commerce iOS application built with **MVVM architecture**, featuring comprehensive unit testing, async networking, and persistent cart/favorites system.

## Screenshots

*Screenshots coming soon*

## Tech Stack

| Category | Technologies |
|----------|-------------|
| **Language** | Swift |
| **Architecture** | MVVM |
| **UI** | UIKit (Storyboard), Auto Layout |
| **Networking** | URLSession, async/await |
| **Image Caching** | NSCache → SDWebImage |
| **Persistence** | UserDefaults |
| **Testing** | XCTest |
| **Dependency Management** | SPM |

## Architecture

The project follows **MVVM** (Model-View-ViewModel) architecture with protocol-based dependency injection and SOLID principles:

```
ShopApp/
├── Models/             # Data models and entities
├── Views/              # UI layer (ViewControllers, Storyboards, custom views)
├── ViewModels/         # Business logic and data transformation
├── Network/            # URLSession-based API service with async/await
├── Managers/           # Cart, favorites, and app-wide managers
├── Utilities/          # Helper classes and extensions
├── Assets.xcassets/    # Images and colors
└── ShopAppTests/       # Unit tests with XCTest
```

## Features

- 🛍️ Product listing with search functionality
- 📄 Detailed product view
- 🛒 Cart management with real-time price calculation
- ❤️ Persistent favorites system using UserDefaults
- 🌐 Async/await networking layer with Codable JSON parsing
- ⚠️ Custom error handling with user-facing alerts
- 🖼️ Image caching (NSCache → SDWebImage migration)
- 💉 Protocol-based dependency injection for testability
- ✅ Comprehensive XCTest suite with mock objects, XCTestExpectation, and AAA pattern

## Testing

The project includes a full unit test suite covering:

- **Mock Objects** — Protocol-based mocks for network and service layers
- **Async Testing** — XCTestExpectation for testing async/await operations
- **AAA Pattern** — Arrange, Act, Assert structure for readable and maintainable tests

```bash
# Run tests in Xcode
Cmd + U
```

## Setup

1. Clone the repository
```bash
git clone https://github.com/Aliboztepe/ShopApp.git
```

2. Open `ShopApp.xcodeproj` in Xcode

3. Resolve SPM packages (Xcode will do this automatically)

4. Run the project (Cmd + R)
