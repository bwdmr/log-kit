import Foundation



public protocol LogKitBase: Codable, Equatable, Sendable {
    static var base: Self { get }
}


public protocol LogKitAction: Codable, Equatable, Sendable {
    associatedtype Base: LogKitBase
    
    var base: Base { get }
    
    init(_ base: Base)
    
    var description: String { get }
}
