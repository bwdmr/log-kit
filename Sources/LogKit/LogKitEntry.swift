import Foundation
import Logging


//
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

