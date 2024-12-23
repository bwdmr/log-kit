import Foundation



public struct LogKitIdentifier: Sendable, Hashable, Equatable {
    public let string: String
    
    public init(string: String) {
        self.string = string
    }
}


extension LogKitIdentifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(string: container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.string)
    }
}


extension LogKitIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)
    }
}
