import Foundation


public struct LogKitError: Error, Sendable {
    public struct ErrorType: Sendable, Hashable, CustomStringConvertible {
        
        enum Base: String, Sendable {
            case generic
            case invalidData
            case invalidEntry
            case invalidService
            case missingService
        }
        
        let base: Base
        
        private init(_ base: Base) { self.base = base }
        
        public static let generic = Self(.generic)
        public static let invalidData = Self(.invalidData)
        public static let invalidEntry = Self(.invalidEntry)
        public static let invalidService = Self(.invalidService)
        public static let missingService = Self(.missingService)
        
        public var description: String {
            base.rawValue
        }
    }
    
    
    private final class Backing: Sendable {
        fileprivate let errorType: ErrorType
        fileprivate let name: String?
        fileprivate let reason: String?
        fileprivate let underlying: Error?
        fileprivate let identifier: String?
        fileprivate let failedLogKitEntry: (any LogKitEntry)?
        
        init(
            errorType: ErrorType,
            name: String? = nil,
            reason: String? = nil,
            underlying: Error? = nil,
            identifier: String? = nil,
            failedLogKitEntry: (any LogKitEntry)? = nil
        ) {
            self.errorType = errorType
            self.name = name
            self.reason = reason
            self.underlying = underlying
            self.identifier = identifier
            self.failedLogKitEntry = failedLogKitEntry
        }
    }
    
    private var backing: Backing
    
    public var errorType: ErrorType { backing.errorType }
    public var name: String? { backing.name }
    public var reason: String? { backing.reason }
    public var underlying: (any Error)? { backing.underlying }
    public var identifier: String? { backing.identifier }
    public var failedLogKitEntry: (any LogKitEntry)? { backing.failedLogKitEntry }
    
    private init(backing: Backing) {
        self.backing = backing }
    
    private init(errorType: ErrorType) {
        self.backing = .init(errorType: errorType) }
    
    ///
    public static func generic(identifier: String, reason: String) -> Self {
        .init(backing: .init(errorType: .generic, reason: reason, identifier: identifier))
    }
    
    ///
    public static func invalidData(_ name: String) -> Self {
        .init(backing: .init(errorType: .invalidData, name: name))
    }
    
    public static func invalidEntry(_ name: String) -> Self {
        .init(backing: .init(errorType: .invalidEntry, name: name))
    }
    
    public static func invalidService(_ name: String) -> Self {
        .init(backing: .init(errorType: .invalidService, name: name))
    }
    
    ///
    public static func missingService(_ name: String) -> Self {
        .init(backing: .init(errorType: .missingService, name: name))
    }
}


extension LogKitError: CustomStringConvertible {
    public var description: String {
        var result = #"LogKitError(errorType: \#(self.errorType)"#
        
        if let name {
            result.append(", name: \(String(reflecting: name))") }
        
        if let failedLogKitEntry {
            result.append(", failedEntry: \(String(reflecting: failedLogKitEntry))") }
        
        if let reason {
            result.append(", reason: \(String(reflecting: reason))") }
        
        if let underlying {
            result.append(", underlying: \(String(reflecting: underlying))") }
        
        if let identifier {
            result.append(", identifier: \(String(reflecting: identifier))") }
        
        result.append(")")
        return result
    }
}
