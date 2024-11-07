import Foundation


public protocol LogKitAction: Equatable, Sendable {
    associatedtype Base
    
    var base: Base { get }
    
    init(_ base: Base)
    
    var description: String { get }
}
