//
//  Keychain client.swift
//

import Foundation
import Security

public struct Keychain {
  let encoder: JSONEncoder
  let decoder: JSONDecoder
  
  public init(
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
  ) {
    self.encoder = encoder
    self.decoder = decoder
  }
  
  private func setupQuery(for key: String) -> [String : Any] {
    var query: [String : Any] = [kSecClass as String : kSecClassGenericPassword]
    query[kSecAttrAccount as String] = key.data(using: .utf8)
    return query
  }
  
  public func set<Value>(value: Value, forKey key: String) throws where Value: Encodable {
    let data = try JSONEncoder().encode(value)
    
    guard !key.isEmpty else {
      throw Error.unsupportedKey
    }
    guard !data.isEmpty else {
      throw Error.unsupportedValue
    }
    try? remove(key)
    
    var query = setupQuery(for: key)
    query[kSecValueData as String] = data
    
    let status = SecItemAdd(query as CFDictionary, nil)
    if status != errSecSuccess {
      throw Error.failure(status: status)
    }
  }
  
  public func value<Value>(forKey key: String) throws -> Value? where Value: Decodable {
    guard !key.isEmpty else {
      throw Error.unsupportedKey
    }
    var query = setupQuery(for: key)
    query[kSecReturnData as String] = kCFBooleanTrue
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    
    var data: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &data)
    guard status == errSecSuccess else {
      throw Error.failure(status: status)
    }
    if let data = data as? Data {
      return try JSONDecoder().decode(Value.self, from: data)
    } else {
      return nil
    }
  }
  
  public func remove(_ key: String) throws {
    guard !key.isEmpty else {
      throw Error.unsupportedKey
    }
    let query = setupQuery(for: key)
    let status = SecItemDelete(query as CFDictionary)
    if status != errSecSuccess {
      throw Error.failure(status: status)
    }
  }
}
