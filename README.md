# log-kit


a library to serve as a generic cover for most log related libraries.
create your custom log entries within your log folder and manage
the behaviour from your customized log function.
store to a database. use a client to send it over the wire, or between microservices.
                                            
by default an entry follows the elastic common schema and its most common fields.
Expand from there. use LogActions to design your service along your imagination,
just pass the entry and the desired action to your registered service and done.
                                            
its actually just a log preset collection with a if else block to determine which
option you have selected.
the options need to be written by yourself.
                                            
gains:
- manage your logs from a centralized location. ideally a custom folder.
= structure your logs deterministically. there should be no random strings passed around.
= log on top of serverless architecture by independence from access to the underlying system.
- maintain your logs from within the glorious monolith, dont venture to vault 11 and roll down the steep learning curve you came from.
                                            
                                            
### Action
```swift
// Example Action
public struct ClientAction: LogAction {
    public enum Base: String, Sendable {
        case clientAuthenticated
        case clientDeAuthenticated
    }
    
    public let base: Base
    
    public init(_ base: Base) { self.base = base }
    
    public static let clientAuthenticated: ClientAction = .init(.clientAuthenticated)
    public static let clientDeAuthenticated: ClientAction = .init(.clientDeAuthenticated)
    
    public var description: String {
        base.rawValue
    }
}
```



### Service
```swift
// Example Service
public struct ClientLogService: LogServiceable {
    public let id: LogIdentifier = LogIdentifier(string: "ecs")
    
    public var handler: LogHandler
    
    public var action: ClientAction
    
    
    //
    public init(
        _ handler: LogHandler,
        action: ClientAction
    ) {
        self.handler = handler
        self.action = action
    }
    
    
    //
    public func prepareMetadata(_ metadata: Logger.Metadata? = nil) -> Logger.Metadata {
        var _combinedMetadata = self.handler.metadata
        
        if let metadata = metadata {
            _combinedMetadata.merge(metadata) { (_, new) in new }
        }
        
        let combinedMetadata = _combinedMetadata
        
        return combinedMetadata
    }
    
    
    //
    public func log<Entry>(
        action: ClientAction,
        entry: Entry
    ) async throws where Entry: LogEntry {
        
        var _entry: LogEntry = entry
        _entry.metadata = prepareMetadata(entry.metadata)
        
        let entry = _entry
        if action == .clientAuthenticated {
            try await entry.log() }
        
        if action == .clientDeAuthenticated {
            
        }
        
        throw LogError.invalidEntry("clientEntry")
    }
}
```


### Entry
```swift
// Example Entry
public struct ClientEntry: LogEntry {
    
    public var level: Logger.Level?
    
    public var tags: [String]?
    
    public var labels: [String : String]?
    
    public var metadata: Logger.Metadata?
    
    public var timestamp: Date?
    
    public var message: String?
    
    public var source: String?
    
    public var file: String?
    
    public var function: String?
    
    public var line: UInt?
    
    public let address: String?
    
    public let ip: String?
    
    public let port: Int?
    
    public let bytes: Int?
    
    public let domain: String?
    
    public let mac: String?
    
    public let packets: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case level = "log.level"
        case tags = "log.tags"
        case labels = "log.labels"
        case version = "log.version"
        case metadata = "log.metadata"
        case timestamp = "@timestamp"
        case message = "log.message"
        case source = "log.source"
        case file = "log.file"
        case function = "log.function"
        case line = "log.line"
    }
    
    public init(
        level: Logger.Level? = nil,
        tags: [String]? = nil,
        labels: [String : String]? = nil,
        version: String? = nil,
        metadata: Logger.Metadata? = nil,
        timestamp: Date? = nil,
        message: String? = nil,
        source: String? = nil,
        file: String? = nil,
        function: String? = nil,
        line: UInt? = nil,
        address: String? = nil,
        ip: String? = nil,
        port: Int? = nil,
        bytes: Int? = nil,
        domain: String? = nil,
        mac: String? = nil,
        packets: Int? = nil
    ) {
        self.level = level
        self.tags = tags
        self.labels = labels
        self.metadata = metadata
        self.timestamp = timestamp
        self.message = message
        self.source = source
        self.file = file
        self.function = function
        self.line = line
        self.address = address
        self.ip = ip
        self.port = port
        self.bytes = bytes
        self.domain = domain
        self.mac = mac
        self.packets = packets
    }
    
    
    public func log() async throws {
        // do custom stuff here
    }
}

```
