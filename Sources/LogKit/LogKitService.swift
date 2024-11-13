import Foundation
import Logging




public actor LogService: Sendable {
    private var storage: [LogKitIdentifier: any LogKitServiceable]
    
    public init() {
        self.storage = [:]
    }
    
    public subscript(id: LogKitIdentifier) -> (any LogKitServiceable)? {
        get {
            return storage[id]
        }
    }
    
    @discardableResult
    public func register(_ service: any LogKitServiceable)
    throws -> Self {
        
        let id = service.id
        if self.storage[id] != nil {
            print("Warning: Overwriting existing OAuth configuration for service identifier; '\(id)'.") }
        self.storage[id] = service
        
        return self
    }
    
    public func log<Service>(_ service: Service, entry: Service.Entry)
    throws where Service: LogKitServiceable {
        try service.log(entry)
    }
}



public protocol LogKitBase: RawRepresentable, Codable, Equatable, Sendable {
    var rawValue: String { get }
}


public protocol LogKitServiceable: Sendable, LogHandler {
    associatedtype Base: LogKitBase
    associatedtype Entry: LogKitEntry where Entry.Base == Base

    var id: LogKitIdentifier { get }
    
    var logLevel: Logger.Level { get set }
    
    var metadata: Logger.Metadata { get set }
    
    func log(_ entry: Entry) throws
    
    func log(_ entry: some DataProtocol, as _: Entry.Type) throws
}


extension LogKitServiceable {
    public func log<Entry>(_ entry: some DataProtocol, as _: Entry.Type = Entry.self)
    throws where Entry: LogKitEntry {
        let jsonDecoder: JSONDecoder = .defaultForLog
        
        var _logentry: Entry
        do {
            let encodedEntry = Array(entry)
            _logentry = try jsonDecoder.decode(
                Entry.self, from: .init(encodedEntry.base64URLDecodedBytes()) )
        }
        
        catch {
            throw LogKitError.invalidEntry(
                "Couldn't decode Entry with error: \(String(describing: error))")
        }
        
       _logentry.log()
    }
}



extension LogKitServiceable {
    public func queryitemBuffer(_ items: [URLQueryItem]) throws -> [UInt8] {
        let bodyString = try items.map({
            let key = $0.name
            guard let value = $0.value?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                throw LogKitError.invalidData("logentry query item") }
            return String(describing: "\(key)=\(value)")
        }).joined(separator: "&")
        
        let bodyData = Array(bodyString.utf8)
        return bodyData
    }
}



extension Logger.MetadataValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    private enum ValueType: String, Codable {
        case string
        case stringConvertible
        case dictionary
        case array
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .string(let stringValue):
            try container.encode(ValueType.string, forKey: .type)
            try container.encode(stringValue, forKey: .value)
            
        case .stringConvertible(let customValue):
            try container.encode(ValueType.stringConvertible, forKey: .type)
            try container.encode(customValue.description, forKey: .value) // Encode description
            
        case .dictionary(let dictValue):
            try container.encode(ValueType.dictionary, forKey: .type)
            try container.encode(dictValue, forKey: .value)
            
        case .array(let arrayValue):
            try container.encode(ValueType.array, forKey: .type)
            try container.encode(arrayValue, forKey: .value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)
        
        switch type {
        case .string:
            let stringValue = try container.decode(String.self, forKey: .value)
            self = .string(stringValue)
            
        case .stringConvertible:
            let stringValue = try container.decode(String.self, forKey: .value)
            self = .stringConvertible(stringValue) // Store as `stringConvertible` using `String` type
            
        case .dictionary:
            let dictValue = try container.decode(Logger.Metadata.self, forKey: .value)
            self = .dictionary(dictValue)
            
        case .array:
            let arrayValue = try container.decode([Logger.MetadataValue].self, forKey: .value)
            self = .array(arrayValue)
        }
    }
}
