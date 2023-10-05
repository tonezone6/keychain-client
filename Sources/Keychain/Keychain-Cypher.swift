//
//  Keychain-Cypher.swift
//

import Foundation
import Security

extension Keychain {

  public struct Cypher {
    private let tag: String
    private let algorithm: SecKeyAlgorithm
    private let keySize: UInt
    
    public init(
      _ tag: String,
      algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512,
      keySize: UInt = 2048
    ) {
      self.tag = tag
      self.keySize = keySize
      self.algorithm = algorithm
    }
    
    public var publicKey: SecKey? {
      guard let key = privateKey else { return nil }
      return SecKeyCopyPublicKey(key)
    }
    
    public var privateKey: SecKey? {
      try? retrievePrivateKey() ?? (try? generatePrivateKey()) ?? nil
    }
    
    public func encrypt(_ text: String) throws -> Data {
      guard let secKey = publicKey else {
        throw Error.noPublicKey
      }
      guard SecKeyIsAlgorithmSupported(secKey, .encrypt, algorithm) else {
        throw Error.unsupported(algorithm: algorithm)
      }
      guard let textData = text.data(using: .utf8) else {
        throw Error.unsupportedInput
      }
      var error: Unmanaged<CFError>?
      guard let encryptedTextData = SecKeyCreateEncryptedData(secKey, algorithm, textData as CFData, &error) as Data? else {
        if let encryptionError = error {
          throw Error.forwarded(encryptionError.takeRetainedValue() as Swift.Error)
        } else {
          throw Error.unknown
        }
      }
      
      return encryptedTextData
    }
    
    public func decrypt(_ data: Data) throws -> Data {
      guard let secKey = privateKey else {
        throw Error.noPrivateKey
      }
      guard SecKeyIsAlgorithmSupported(secKey, .decrypt, algorithm) else {
        throw Error.unsupported(algorithm: algorithm)
      }
      var error: Unmanaged<CFError>?
      guard let decryptedData = SecKeyCreateDecryptedData(secKey, algorithm, data as CFData, &error) as Data? else {
        if let decryptionError = error {
          throw Error.forwarded(decryptionError.takeRetainedValue() as Swift.Error)
        } else {
          throw Error.unknown
        }
      }
      return decryptedData
    }
    
    private var keyAttributes: [String: Any] {
      return [
        kSecAttrType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits as String: keySize,
        kSecAttrApplicationTag as String: tag,
        kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String : true]
      ]
    }
    
    private func generatePrivateKey() throws -> SecKey {
      guard let privateKey = SecKeyCreateRandomKey(keyAttributes as CFDictionary, nil) else {
        throw Error.keyGenerationError
      }
      return privateKey
    }
    
    private func retrievePrivateKey() throws -> SecKey? {
      let privateKeyQuery: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrApplicationTag as String: tag,
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecReturnRef as String: true
      ]
      var privateKeyRef: CFTypeRef?
      let status = SecItemCopyMatching(privateKeyQuery as CFDictionary, &privateKeyRef)
      guard status == errSecSuccess else {
        if status == errSecItemNotFound {
          return nil
        } else {
          throw Error.failure(status: status)
        }
      }
      return privateKeyRef != nil ? (privateKeyRef as! SecKey) : nil
    }
  }
}
