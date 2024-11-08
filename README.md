# LogKit

LogKit is a Swift logging framework that provides a flexible, protocol-based approach to logging with support for multiple logging services, custom log entries, and structured metadata.

## Features

- 🔄 Asynchronous logging with Swift concurrency support
- 🎯 Protocol-based design for extensibility
- 🏷 Support for structured logging with metadata, tags, and labels
- 🔌 Multiple logging service support through a unified interface
- 🛡 Type-safe logging actions
- 💪 Written in Swift with full Sendable compliance for thread safety

## Installation

[Add installation instructions based on your package manager]

## Core Components

### LogService

The central coordinator that manages multiple logging services:

```swift
let logService = LogService()
await logService.register(myCustomLogger)
```

### LogKitServiceable

The main protocol for implementing logging services:

```swift
public protocol LogKitServiceable: Sendable {
    associatedtype Action: LogKitAction
    associatedtype Entry: LogKitEntry
    
    var id: LogKitIdentifier { get }
    var handler: LogHandler { get }
    
    func log(_ action: Action, entry: Entry) async throws
    func log(_ entry: some DataProtocol, as _: Entry.Type) async throws
}
```

### LogKitEntry

Protocol for defining log entries with structured data:

```swift
public protocol LogKitEntry: Codable, Sendable {
    var level: Logger.Level? { get set }
    var tags: [String]? { get set }
    var labels: [String: String]? { get set }
    var metadata: Logger.Metadata? { get set }
    var timestamp: Date? { get set }
    var message: String? { get set }
    var source: String? { get set }
    var file: String? { get set }
    var function: String? { get set }
    var line: UInt? { get set }
    
    func log() async throws
}
```

## Error Handling

LogKit provides a comprehensive error handling system through `LogKitError`:

- `generic`: General purpose errors
- `invalidData`: Data formatting or parsing errors
- `invalidEntry`: Log entry validation errors
- `invalidService`: Service configuration errors
- `missingService`: Service availability errors

## Example Usage

```swift
// Define a custom log entry
struct MyLogEntry: LogKitEntry {
    var level: Logger.Level?
    var tags: [String]?
    var labels: [String: String]?
    var metadata: Logger.Metadata?
    var timestamp: Date?
    var message: String?
    var source: String?
    var file: String?
    var function: String?
    var line: UInt?
    
    func log() async throws {
        // Implement logging logic
    }
}

// Define a custom logging action
struct MyLogAction: LogKitAction {
    let base: String
    
    var description: String { base }
}

// Create and register a logging service
class MyLogService: LogKitServiceable {
    let id: LogKitIdentifier = "my-logger"
    let handler: LogHandler
    
    func log(_ action: MyLogAction, entry: MyLogEntry) async throws {
        // Implement logging logic
    }
}

// Use the logging service
let service = LogService()
let logger = MyLogService()
try await service.register(logger)
```

## Best Practices

1. **Structured Logging**: Use tags, labels, and metadata to organize your logs
2. **Error Handling**: Always handle logging errors appropriately
3. **Async/Await**: Take advantage of Swift's concurrency system for non-blocking logging
4. **Type Safety**: Use custom `LogKitAction` types to ensure type-safe logging operations

## Contributing

[Add contribution guidelines]

## License

[Add license information]
