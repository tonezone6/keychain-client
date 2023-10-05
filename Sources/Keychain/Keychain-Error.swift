//
//  Keychain-Error.swift
//

import Foundation
import Security

extension Keychain {
  public enum `Error`: Swift.Error {
    case failure(status: OSStatus)
    case unsupportedKey
    case unsupportedValue
  }
}

extension Keychain.Cypher {
  public enum `Error`: Swift.Error {
    case failure(status: OSStatus)
    case forwarded(Swift.Error)
    case keyGenerationError
    case noPublicKey
    case noPrivateKey
    case unsupported(algorithm: SecKeyAlgorithm)
    case unsupportedInput
    case unknown
  }
}
