import Foundation

public protocol LogJSONDecoder: Sendable {
    func decode<T: Decodable>(_: T.Type, from string: Data) throws -> T
}

public protocol LogJSONEncoder: Sendable {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONDecoder: LogJSONDecoder {}

extension JSONEncoder: LogJSONEncoder {}


public extension LogJSONEncoder where Self == JSONEncoder {
  static var defaultForLog: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    return encoder
  }
}


public extension LogJSONDecoder where Self == JSONDecoder {
  static var defaultForLog: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
  }
}
