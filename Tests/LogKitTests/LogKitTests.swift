import XCTest
import Logging
@testable import LogKit 

final class LogKitTests: XCTestCase {
    
    // MARK: - LogService Tests
    
    func testLogServiceRegistration() async throws {
        let service = LogService()
        let mockLogger = MockLogService()
        
        try await service.register(mockLogger)
        
        // Test duplicate registration warning
        // Note: We can't directly test the print statement, but we can verify it doesn't throw
        try await service.register(mockLogger)
    }
    
    // MARK: - LogKitIdentifier Tests
    
    func testLogKitIdentifierInitialization() {
        let identifier = LogKitIdentifier(string: "test-service")
        XCTAssertEqual(identifier.string, "test-service")
    }
    
    func testLogKitIdentifierCoding() throws {
        let original = LogKitIdentifier(string: "test-service")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(LogKitIdentifier.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testLogKitIdentifierStringLiteral() {
        let identifier: LogKitIdentifier = "test-service"
        XCTAssertEqual(identifier.string, "test-service")
    }
    
    // MARK: - LogKitError Tests
    
    func testLogKitErrorCreation() {
        let genericError = LogKitError.generic(identifier: "test-id", reason: "test failed")
        XCTAssertEqual(genericError.identifier, "test-id")
        XCTAssertEqual(genericError.reason, "test failed")
        
        let invalidDataError = LogKitError.invalidData("test-data")
        XCTAssertEqual(invalidDataError.name, "test-data")
        XCTAssertEqual(invalidDataError.errorType.description, "invalidData")
        
        let missingServiceError = LogKitError.missingService("test-service")
        XCTAssertEqual(missingServiceError.name, "test-service")
        XCTAssertEqual(missingServiceError.errorType.description, "missingService")
    }
    
    // MARK: - Mock Objects
    
    private struct MockLogEntry: LogKitEntry {
        var level: Logger.Level?
        var tags: [String]?
        var labels: [String : String]?
        var metadata: Logger.Metadata?
        var timestamp: Date?
        var message: String?
        var source: String?
        var file: String?
        var function: String?
        var line: UInt?
        
        func log() async throws {
            // Mock implementation
        }
    }
    
    private struct MockLogAction: LogKitAction {
        typealias Base = String
        var base: String
        
        var description: String { base }
        
        init(_ base: String) {
            self.base = base
        }
    }
    
    private actor MockLogService: LogKitServiceable {
        typealias Action = MockLogAction
        typealias Entry = MockLogEntry
        
        let id: LogKitIdentifier = "mock-service"
        let handler: LogHandler = SwiftLogNoOpLogHandler()
        
        func log(_ action: MockLogAction, entry: MockLogEntry) async throws {
            // Mock implementation
        }
    }
    
    // MARK: - Logger.MetadataValue Tests
    
    func testLoggerMetadataValueCoding() throws {
        // Test string value
        let stringValue: Logger.MetadataValue = .string("test")
        let encodedString = try JSONEncoder().encode(stringValue)
        let decodedString = try JSONDecoder().decode(Logger.MetadataValue.self, from: encodedString)
        XCTAssertEqual(stringValue, decodedString)
        
        // Test dictionary value
        let dictionaryValue: Logger.MetadataValue = .dictionary(["key": .string("value")])
        let encodedDict = try JSONEncoder().encode(dictionaryValue)
        let decodedDict = try JSONDecoder().decode(Logger.MetadataValue.self, from: encodedDict)
        XCTAssertEqual(dictionaryValue, decodedDict)
        
        // Test array value
        let arrayValue: Logger.MetadataValue = .array([.string("item1"), .string("item2")])
        let encodedArray = try JSONEncoder().encode(arrayValue)
        let decodedArray = try JSONDecoder().decode(Logger.MetadataValue.self, from: encodedArray)
        XCTAssertEqual(arrayValue, decodedArray)
    }
    
    // MARK: - Integration Tests
    
    func testCompleteLoggingFlow() async throws {
        // Setup
        let service = LogService()
        let mockLogger = MockLogService()
        try await service.register(mockLogger)
        
        // Create test entry
        let entry = MockLogEntry(
            level: .info,
            tags: ["test"],
            labels: ["environment": "test"],
            metadata: ["key": .string("value")],
            timestamp: Date(),
            message: "Test message",
            source: "TestCase",
            file: #file,
            function: #function,
            line: #line
        )
        
        // Create test action
        let action = MockLogAction("test-action")
        
        // Test logging
        try await mockLogger.log(action, entry: entry)
    }
}

// MARK: - Additional Test Cases for URL Query Items

extension LogKitTests {
    func testQueryItemBuffer() async throws {
        let mockLogger = MockLogService()
        let queryItems = [
            URLQueryItem(name: "test", value: "value"),
            URLQueryItem(name: "spaces", value: "test value")
        ]
        
        let buffer = try await mockLogger.queryitemBuffer(queryItems)
        let resultString = String(bytes: buffer, encoding: .utf8)
        
        XCTAssertNotNil(resultString)
        XCTAssertTrue(resultString?.contains("test=value") ?? false)
        XCTAssertTrue(resultString?.contains("spaces=test%20value") ?? false)
    }
    
    func testQueryItemBufferWithInvalidData() async throws {
        let mockLogger = MockLogService()
        let queryItems = [
            URLQueryItem(name: "test", value: nil)
        ]
        
        do {
            _ = try await mockLogger.queryitemBuffer(queryItems)
            XCTFail("Should throw an error for nil value")
        } catch let error as LogKitError {
            XCTAssertEqual(error.errorType.description, "invalidData")
        }
    }
}
