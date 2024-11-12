import Foundation
import Logging


public protocol LogKitEntry: Codable, Sendable {
    var tags: [String]? { get set }
    
    var timestamp: Date? { get set }
    
    var message: String? { get set }
    
    var file: String? { get set }
    
    var function: String? { get set }
    
    var line: UInt? { get set }
    
    
    func log() async throws
}

