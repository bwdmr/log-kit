import Foundation
import Logging




// LogService
public actor LogService: Sendable {
  
    private var storage: [LogKitIdentifier: LogKitServiceable]

    public init() {
        self.storage = [:]
    }
  
  
    @discardableResult
    public func register(_ service: LogKitServiceable)
    async throws -> Self {
        
        let id = await service.id
        if self.storage[id] != nil {
            print("Warning: Overwriting existing OAuth configuration for service identifier; '\(id)'.") }
        self.storage[id] = service
        
        return self
    }
}


//
public protocol LogKitServiceable: Sendable {
    
    var id: LogKitIdentifier { get }
    
    var handler: LogHandler { get }
    
    func log(
        action: any LogKitAction,
        entry: LogKitEntry
    ) async throws
}


// Decode from JSON to <Entry>
extension LogKitServiceable {
    public func log<Entry>(_ entry: some DataProtocol)
    async throws -> Entry where Entry: LogKitEntry {
        let jsonDecoder: JSONDecoder = .defaultForLog
        
        var _logentry: Entry
        do {
            let encodedEntry = Array(entry)
            _logentry = try jsonDecoder.decode(
                Entry.self, from: .init(encodedEntry.base64URLDecodedBytes()) )
        } catch {
            throw LogKitError.invalidEntry(
                "Couldn't decode Entry with error: \(String(describing: error))")
        }
        
        try await _logentry.log()
        return _logentry
    }
}


// Encode from URLQueryItems to Data
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
